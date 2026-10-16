import 'dart:async';

import '../../../core/platform/dialer_bridge.dart';
import '../models/audio_route.dart';
import '../models/call_session.dart';

/// Snapshot containing all current call sessions and audio routing status.
class CallSnapshot {
  const CallSnapshot({
    this.calls = const [],
    this.audioState = const AudioRouteState(),
  });

  final List<CallSession> calls;
  final AudioRouteState audioState;

  factory CallSnapshot.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return const CallSnapshot();

    final rawCalls = map['calls'] as List<dynamic>?;
    final parsedCalls = rawCalls != null
        ? rawCalls
              .map((c) => CallSession.fromMap(c as Map<dynamic, dynamic>))
              .toList()
        : <CallSession>[];

    final rawAudio = map['audioState'] as Map<dynamic, dynamic>?;
    final audio = AudioRouteState.fromMap(rawAudio);

    return CallSnapshot(calls: parsedCalls, audioState: audio);
  }

  /// Primary call displayed in UI: prioritizes incoming, then active, then connecting.
  CallSession? get primaryCall {
    if (calls.isEmpty) return null;
    return calls.firstWhere(
      (c) => c.state.isIncoming,
      orElse: () => calls.firstWhere(
        (c) => c.state.isActive,
        orElse: () => calls.firstWhere(
          (c) => c.state.isConnecting,
          orElse: () => calls.firstWhere(
            (c) => c.state.isHolding,
            orElse: () => calls.first,
          ),
        ),
      ),
    );
  }

  /// Incoming ringing call if present.
  CallSession? get incomingCall {
    try {
      return calls.firstWhere((c) => c.state.isIncoming);
    } catch (_) {
      return null;
    }
  }

  /// Foreground active call if present.
  CallSession? get activeCall {
    try {
      return calls.firstWhere((c) => c.state.isActive);
    } catch (_) {
      return null;
    }
  }

  /// Held call session if present.
  CallSession? get heldCall {
    try {
      return calls.firstWhere((c) => c.state.isHolding);
    } catch (_) {
      return null;
    }
  }

  bool get hasCalls => calls.isNotEmpty;
}

/// Service mediating real-time Telecom call events and action dispatches.
class CallEventService {
  CallEventService({DialerBridge? bridge})
    : _bridge = bridge ?? DialerBridge.instance;

  final DialerBridge _bridge;
  StreamSubscription<Map<dynamic, dynamic>>? _eventSubscription;
  final StreamController<CallSnapshot> _snapshotController =
      StreamController<CallSnapshot>.broadcast();

  CallSnapshot _lastSnapshot = const CallSnapshot();
  CallSnapshot get lastSnapshot => _lastSnapshot;

  bool _isListening = false;

  /// Stream emitting authoritative call snapshots whenever Telecom state changes.
  Stream<CallSnapshot> get onCallSnapshotChanged {
    _ensureListening();
    return _snapshotController.stream;
  }

  void _ensureListening() {
    if (!_isListening) {
      _isListening = true;
      try {
        _eventSubscription = _bridge.callEvents.listen(
          (map) {
            _lastSnapshot = CallSnapshot.fromMap(map);
            _snapshotController.add(_lastSnapshot);
          },
          onError: (_) {
            // Safe fallback during reconnection
          },
        );
      } catch (_) {}
    }
  }

  /// Fetches immediate snapshot from the platform.
  Future<CallSnapshot> getSnapshot() async {
    final map = await _bridge.getCallSnapshot();
    if (map != null) {
      _lastSnapshot = CallSnapshot.fromMap(map);
      _snapshotController.add(_lastSnapshot);
    }
    return _lastSnapshot;
  }

  Future<bool> answerCall([String? sessionId]) => _bridge.answerCall(sessionId);

  Future<bool> rejectCall([String? sessionId]) => _bridge.rejectCall(sessionId);

  Future<bool> disconnectCall([String? sessionId]) =>
      _bridge.disconnectCall(sessionId);

  Future<bool> holdCall(String sessionId) => _bridge.holdCall(sessionId);

  Future<bool> unholdCall(String sessionId) => _bridge.unholdCall(sessionId);

  Future<bool> setMuted(bool muted) => _bridge.setMuted(muted);

  Future<bool> setAudioRoute(AudioRoute route) {
    String routeStr;
    switch (route) {
      case AudioRoute.speaker:
        routeStr = 'speaker';
        break;
      case AudioRoute.bluetooth:
        routeStr = 'bluetooth';
        break;
      case AudioRoute.wiredHeadset:
        routeStr = 'wiredHeadset';
        break;
      case AudioRoute.earpiece:
        routeStr = 'earpiece';
        break;
    }
    return _bridge.setAudioRoute(routeStr);
  }

  void dispose() {
    _eventSubscription?.cancel();
    _snapshotController.close();
  }
}
