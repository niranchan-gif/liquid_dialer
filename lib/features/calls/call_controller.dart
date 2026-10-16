import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/permissions/phone_permissions_service.dart';
import '../../core/platform/dialer_bridge.dart';
import '../contacts/models/contact_item.dart';
import '../contacts/services/contacts_service.dart';
import '../contacts/utils/phone_number_matcher.dart';
import 'call_status.dart';
import 'models/audio_route.dart';
import 'models/call_session.dart';
import 'models/call_state.dart';
import 'services/call_event_service.dart';

/// State controller managing Android Default Phone role status, outgoing calls,
/// incoming-call detection, contact identity resolution, and active-call Telecom synchronization.
class CallController extends ChangeNotifier {
  CallController({
    DialerBridge? bridge,
    CallEventService? eventService,
    ContactsService? contactsService,
    PhonePermissionsService? permissionsService,
  }) : _bridge = bridge ?? DialerBridge.instance,
       _eventService =
           eventService ??
           CallEventService(bridge: bridge ?? DialerBridge.instance),
       _contactsService = contactsService ?? const DeviceContactsService(),
       _permissionsService =
           permissionsService ?? const DevicePhonePermissionsService() {
    _initCallEventStream();
    _loadContactsCache();
    checkRoleStatus();
  }

  final DialerBridge _bridge;
  final CallEventService _eventService;
  final ContactsService _contactsService;
  final PhonePermissionsService _permissionsService;

  StreamSubscription<CallSnapshot>? _snapshotSub;
  Timer? _durationTimer;
  Timer? _pendingOutgoingTimer;

  bool _isDefaultDialer = false;
  bool _canRequestRole = true;
  bool _isRequestingRole = false;
  String? _roleFeedbackMessage;

  bool _isPlacingCall = false;
  String? _lastCallFeedback;
  CallResult? _lastCallResult;

  CallSnapshot _callSnapshot = const CallSnapshot();
  Duration _elapsedDuration = Duration.zero;

  CallSession? _outgoingPendingSession;
  List<ContactItem> _contactsCache = [];
  bool _hasAttemptedContactLoad = false;

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

  /// Authoritative primary call. Falls back to optimistic pending outgoing session
  /// while Android Telecom initializes the telephony session.
  CallSession? get primaryCall {
    final nativePrimary = _callSnapshot.primaryCall;
    if (nativePrimary != null) {
      if (nativePrimary.displayName == null ||
          nativePrimary.displayName!.trim().isEmpty) {
        final resolved = _resolveContactName(nativePrimary.phoneNumber);
        if (resolved != null) {
          return nativePrimary.copyWith(displayName: resolved);
        }
      }
      return nativePrimary;
    }
    return _outgoingPendingSession;
  }

  CallSession? get incomingCall => _callSnapshot.incomingCall;
  CallSession? get activeCall => _callSnapshot.activeCall;
  CallSession? get heldCall => _callSnapshot.heldCall;
  AudioRouteState get audioRouteState => _callSnapshot.audioState;
  Duration get elapsedDuration => _elapsedDuration;

  bool get isAnswering => _isAnswering;
  bool get isRejecting => _isRejecting;
  bool get isDisconnecting => _isDisconnecting;

  /// Pre-loads or directly injects device contacts for caller identification.
  void setContactsCache(List<ContactItem> contacts) {
    _contactsCache = List.from(contacts);
    _hasAttemptedContactLoad = true;
    _refreshSnapshotContactNames();
    notifyListeners();
  }

  Future<void> _loadContactsCache() async {
    if (_hasAttemptedContactLoad) return;
    _hasAttemptedContactLoad = true;
    try {
      final status = await _permissionsService.checkContactsPermission();
      if (status.isGranted) {
        _contactsCache = await _contactsService.fetchContacts();
        _refreshSnapshotContactNames();
        notifyListeners();
      }
    } catch (_) {}
  }

  String? _resolveContactName(String phoneNumber) {
    if (phoneNumber.trim().isEmpty) return null;
    for (final contact in _contactsCache) {
      final match = PhoneNumberMatcher.matchContact(phoneNumber, contact);
      if (match != null) {
        return match.displayName;
      }
    }
    return null;
  }

  void _refreshSnapshotContactNames() {
    if (_callSnapshot.calls.isEmpty) return;
    final resolvedCalls = _callSnapshot.calls.map((c) {
      if (c.displayName == null || c.displayName!.trim().isEmpty) {
        final resolved = _resolveContactName(c.phoneNumber);
        if (resolved != null) {
          return c.copyWith(displayName: resolved);
        }
      }
      return c;
    }).toList();

    _callSnapshot = CallSnapshot(
      calls: resolvedCalls,
      audioState: _callSnapshot.audioState,
    );
  }

  void _initCallEventStream() {
    _snapshotSub = _eventService.onCallSnapshotChanged.listen(_handleSnapshot);
    _eventService.getSnapshot().then((snapshot) {
      if (snapshot.calls.isNotEmpty) {
        _handleSnapshot(snapshot);
      }
    });
  }

  void _handleSnapshot(CallSnapshot snapshot) {
    if (snapshot.calls.isNotEmpty) {
      _pendingOutgoingTimer?.cancel();
      _outgoingPendingSession = null;
    }

    final resolvedCalls = snapshot.calls.map((c) {
      if (c.displayName == null || c.displayName!.trim().isEmpty) {
        final resolved = _resolveContactName(c.phoneNumber);
        if (resolved != null) {
          return c.copyWith(displayName: resolved);
        }
      }
      return c;
    }).toList();

    _callSnapshot = CallSnapshot(
      calls: resolvedCalls,
      audioState: snapshot.audioState,
    );
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

      if (result.success) {
        // Optimistically present the connecting call screen while Telecom binds the session
        final resolvedName = _resolveContactName(phoneNumber);
        _outgoingPendingSession = CallSession(
          sessionId: 'pending_outgoing',
          phoneNumber: phoneNumber,
          displayName: resolvedName,
          state: CallState.connecting,
          direction: CallDirection.outgoing,
          connectTimeMillis: DateTime.now().millisecondsSinceEpoch,
        );

        _pendingOutgoingTimer?.cancel();
        _pendingOutgoingTimer = Timer(const Duration(seconds: 8), () {
          if (_outgoingPendingSession != null && _callSnapshot.calls.isEmpty) {
            _outgoingPendingSession = null;
            notifyListeners();
          }
        });
      }

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
    _pendingOutgoingTimer?.cancel();
    _outgoingPendingSession = null;
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
    final snapshot = await _eventService.getSnapshot();
    _handleSnapshot(snapshot);
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _pendingOutgoingTimer?.cancel();
    _snapshotSub?.cancel();
    _eventService.dispose();
    super.dispose();
  }
}
