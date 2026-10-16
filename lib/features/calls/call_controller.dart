import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/platform/dialer_bridge.dart';
import 'call_status.dart';
import 'models/audio_route.dart';
import 'models/call_session.dart';
import 'services/call_event_service.dart';

/// State controller managing Android Default Phone role status, outgoing calls,
/// incoming-call detection, and active-call Telecom synchronization.
class CallController extends ChangeNotifier {
  CallController({DialerBridge? bridge, CallEventService? eventService})
    : _bridge = bridge ?? DialerBridge.instance,
      _eventService =
          eventService ??
          CallEventService(bridge: bridge ?? DialerBridge.instance) {
    _initCallEventStream();
  }

  final DialerBridge _bridge;
  final CallEventService _eventService;

  StreamSubscription<CallSnapshot>? _snapshotSub;
  Timer? _durationTimer;

  bool _isDefaultDialer = false;
  bool _canRequestRole = true;
  bool _isRequestingRole = false;
  String? _roleFeedbackMessage;

  bool _isPlacingCall = false;
  String? _lastCallFeedback;
  CallResult? _lastCallResult;

  CallSnapshot _callSnapshot = const CallSnapshot();
  Duration _elapsedDuration = Duration.zero;

  bool _isAnswering = false;
  bool _isRejecting = false;
  bool _isDisconnecting = false;

  // Role Getters
  bool get isDefaultDialer => _isDefaultDialer;
  bool get canRequestRole => _canRequestRole;
  bool get isRequestingRole => _isRequestingRole;
  String? get roleFeedbackMessage => _roleFeedbackMessage;

  // Outgoing Call Getters
  bool get isPlacingCall => _isPlacingCall;
  String? get lastCallFeedback => _lastCallFeedback;
  CallResult? get lastCallResult => _lastCallResult;

  // Active / Incoming Call Getters
  CallSnapshot get callSnapshot => _callSnapshot;
  List<CallSession> get allCalls => _callSnapshot.calls;
  CallSession? get primaryCall => _callSnapshot.primaryCall;
  CallSession? get incomingCall => _callSnapshot.incomingCall;
  CallSession? get activeCall => _callSnapshot.activeCall;
  CallSession? get heldCall => _callSnapshot.heldCall;
  AudioRouteState get audioRouteState => _callSnapshot.audioState;
  Duration get elapsedDuration => _elapsedDuration;

  bool get isAnswering => _isAnswering;
  bool get isRejecting => _isRejecting;
  bool get isDisconnecting => _isDisconnecting;

  void _initCallEventStream() {
    _snapshotSub = _eventService.onCallSnapshotChanged.listen(_handleSnapshot);
    _eventService.getSnapshot();
  }

  void _handleSnapshot(CallSnapshot snapshot) {
    _callSnapshot = snapshot;
    _updateTimerState();
    notifyListeners();
  }

  void _updateTimerState() {
    final active = activeCall;
    if (active != null && active.state.isActive) {
      _elapsedDuration = active.getElapsedDuration();
      _startDurationTimer();
    } else {
      _durationTimer?.cancel();
      _durationTimer = null;
      if (active != null) {
        _elapsedDuration = active.getElapsedDuration();
      } else {
        _elapsedDuration = Duration.zero;
      }
    }
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final active = activeCall;
      if (active != null && active.state.isActive) {
        _elapsedDuration = active.getElapsedDuration();
        notifyListeners();
      }
    });
  }

  /// Queries the current role state from Android Telecom.
  Future<void> checkRoleStatus() async {
    final isDefault = await _bridge.isDefaultDialer();
    final canRequest = await _bridge.canRequestDefaultDialer();

    _isDefaultDialer = isDefault;
    _canRequestRole = canRequest;
    notifyListeners();
  }

  /// Requests the user to set this app as Android's Default Phone app.
  Future<bool> requestDefaultDialer() async {
    _isRequestingRole = true;
    _roleFeedbackMessage = null;
    notifyListeners();

    try {
      final granted = await _bridge.requestDefaultDialer();
      _isDefaultDialer = granted;
      _roleFeedbackMessage = granted
          ? 'Liquid Dialer is now your default phone app.'
          : 'Default phone app request was not granted.';
      _isRequestingRole = false;
      notifyListeners();
      return granted;
    } catch (e) {
      _isRequestingRole = false;
      _roleFeedbackMessage = 'Unable to request default phone role: $e';
      notifyListeners();
      return false;
    }
  }

  /// Initiates an outgoing call to [phoneNumber] via the native bridge.
  Future<CallResult> placeCall(String phoneNumber) async {
    if (_isPlacingCall) {
      return const CallResult(
        success: false,
        message: 'A call request is already in progress.',
        code: CallStatusCode.callFailed,
      );
    }

    _isPlacingCall = true;
    notifyListeners();

    try {
      final result = await _bridge.placeCall(phoneNumber);
      _lastCallResult = result;
      _lastCallFeedback = result.message;
      _isPlacingCall = false;
      notifyListeners();
      return result;
    } catch (e) {
      final failure = CallResult(
        success: false,
        message: 'Error initiating call: $e',
        code: CallStatusCode.callFailed,
      );
      _lastCallResult = failure;
      _lastCallFeedback = failure.message;
      _isPlacingCall = false;
      notifyListeners();
      return failure;
    }
  }

  /// Answers the incoming call. Prevents duplicate answer attempts.
  Future<bool> answerCall([String? sessionId]) async {
    if (_isAnswering) return false;
    _isAnswering = true;
    notifyListeners();

    try {
      final success = await _eventService.answerCall(sessionId);
      _isAnswering = false;
      notifyListeners();
      return success;
    } catch (_) {
      _isAnswering = false;
      notifyListeners();
      return false;
    }
  }

  /// Rejects the incoming call. Prevents duplicate reject attempts.
  Future<bool> rejectCall([String? sessionId]) async {
    if (_isRejecting) return false;
    _isRejecting = true;
    notifyListeners();

    try {
      final success = await _eventService.rejectCall(sessionId);
      _isRejecting = false;
      notifyListeners();
      return success;
    } catch (_) {
      _isRejecting = false;
      notifyListeners();
      return false;
    }
  }

  /// Terminates an active, dialing, or held call.
  Future<bool> disconnectCall([String? sessionId]) async {
    if (_isDisconnecting) return false;
    _isDisconnecting = true;
    notifyListeners();

    try {
      final success = await _eventService.disconnectCall(sessionId);
      _isDisconnecting = false;
      notifyListeners();
      return success;
    } catch (_) {
      _isDisconnecting = false;
      notifyListeners();
      return false;
    }
  }

  /// Holds an active call session.
  Future<bool> holdCall(String sessionId) => _eventService.holdCall(sessionId);

  /// Resumes a held call session.
  Future<bool> unholdCall(String sessionId) =>
      _eventService.unholdCall(sessionId);

  /// Toggles microphone mute.
  Future<bool> toggleMute() async {
    final nextMuted = !_callSnapshot.audioState.isMuted;
    return _eventService.setMuted(nextMuted);
  }

  /// Switches audio output route.
  Future<bool> setAudioRoute(AudioRoute route) =>
      _eventService.setAudioRoute(route);

  /// Toggles between speakerphone and phone earpiece.
  Future<bool> toggleSpeaker() {
    final nextRoute = _callSnapshot.audioState.isSpeakerOn
        ? AudioRoute.earpiece
        : AudioRoute.speaker;
    return setAudioRoute(nextRoute);
  }

  /// Manually refreshes the call snapshot from platform.
  Future<void> refreshCallSnapshot() async {
    await _eventService.getSnapshot();
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _snapshotSub?.cancel();
    _eventService.dispose();
    super.dispose();
  }
}
