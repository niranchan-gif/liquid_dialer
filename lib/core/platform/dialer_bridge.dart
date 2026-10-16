import 'dart:async';

import 'package:flutter/services.dart';

import '../../features/calls/call_status.dart';

/// Platform bridge mediating communication between Flutter and Android Telecom.
class DialerBridge {
  DialerBridge({MethodChannel? channel, EventChannel? eventChannel})
    : _channel = channel ?? const MethodChannel('com.liquid.dialer/telecom'),
      _eventChannel =
          eventChannel ?? const EventChannel('com.liquid.dialer/call_events');

  static DialerBridge? _instance;
  static DialerBridge get instance => _instance ??= DialerBridge();

  final MethodChannel _channel;
  final EventChannel _eventChannel;
  final StreamController<String> _dialIntentController =
      StreamController<String>.broadcast();
  bool _handlerInitialized = false;

  void _ensureHandlerInitialized() {
    if (!_handlerInitialized) {
      try {
        _channel.setMethodCallHandler(_handleNativeCallback);
        _handlerInitialized = true;
      } catch (_) {
        // Safe fallback in test environments without active BinaryMessenger
      }
    }
  }

  /// Stream of phone numbers received via Android ACTION_DIAL intents.
  Stream<String> get onDialIntent {
    _ensureHandlerInitialized();
    return _dialIntentController.stream;
  }

  Future<void> _handleNativeCallback(MethodCall call) async {
    if (call.method == 'onDialIntent') {
      final number = call.arguments as String?;
      if (number != null && number.isNotEmpty) {
        _dialIntentController.add(number);
      }
    }
  }

  /// Checks if this application is currently recognized as the system Default Phone App.
  Future<bool> isDefaultDialer() async {
    try {
      final isDefault = await _channel.invokeMethod<bool>('isDefaultDialer');
      return isDefault ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Checks if the system supports requesting the Default Phone role.
  Future<bool> canRequestDefaultDialer() async {
    try {
      final canRequest = await _channel.invokeMethod<bool>(
        'canRequestDefaultDialer',
      );
      return canRequest ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Launches the native Android system dialog to request the Default Phone role.
  Future<bool> requestDefaultDialer() async {
    try {
      final granted = await _channel.invokeMethod<bool>('requestDefaultDialer');
      return granted ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Requests the native Telecom subsystem to place an outgoing call.
  Future<CallResult> placeCall(String phoneNumber) async {
    final sanitized = phoneNumber.trim();
    if (sanitized.isEmpty) {
      return CallResult.emptyNumber();
    }

    try {
      final result = await _channel.invokeMapMethod<dynamic, dynamic>(
        'placeCall',
        {'phoneNumber': sanitized},
      );
      return CallResult.fromMap(result);
    } on PlatformException catch (pe) {
      return CallResult(
        success: false,
        message: pe.message ?? 'Platform error occurred while placing call.',
        code: CallStatusCode.callFailed,
      );
    } catch (e) {
      return CallResult(
        success: false,
        message: 'Unexpected failure placing call: $e',
        code: CallStatusCode.callFailed,
      );
    }
  }

  /// Retrieves any pending dial number from the launch intent.
  Future<String?> getInitialDialNumber() async {
    try {
      return await _channel.invokeMethod<String>('getInitialDialNumber');
    } catch (_) {
      return null;
    }
  }

  /// Disconnects any active call through the native InCallService fallback.
  Future<bool> disconnectActiveCall() async {
    return disconnectCall();
  }

  /// Answers an incoming call.
  Future<bool> answerCall([String? sessionId]) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'answerCall',
        sessionId != null ? {'sessionId': sessionId} : null,
      );
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Rejects an incoming call.
  Future<bool> rejectCall([String? sessionId]) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'rejectCall',
        sessionId != null ? {'sessionId': sessionId} : null,
      );
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Disconnects an active or dialing call.
  Future<bool> disconnectCall([String? sessionId]) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'disconnectCall',
        sessionId != null ? {'sessionId': sessionId} : null,
      );
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Places an active call session on hold.
  Future<bool> holdCall(String sessionId) async {
    try {
      final result = await _channel.invokeMethod<bool>('holdCall', {
        'sessionId': sessionId,
      });
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Resumes a held call session.
  Future<bool> unholdCall(String sessionId) async {
    try {
      final result = await _channel.invokeMethod<bool>('unholdCall', {
        'sessionId': sessionId,
      });
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Sets microphone mute state.
  Future<bool> setMuted(bool isMuted) async {
    try {
      final result = await _channel.invokeMethod<bool>('setMuted', {
        'isMuted': isMuted,
      });
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Sets audio route (earpiece, speaker, bluetooth, wiredHeadset).
  Future<bool> setAudioRoute(String route) async {
    try {
      final result = await _channel.invokeMethod<bool>('setAudioRoute', {
        'route': route,
      });
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Queries snapshot of current active calls and audio route state.
  Future<Map<dynamic, dynamic>?> getCallSnapshot() async {
    try {
      return await _channel.invokeMapMethod<dynamic, dynamic>(
        'getCallSnapshot',
      );
    } catch (_) {
      return null;
    }
  }

  /// Stream of call state events from native Android Telecom.
  Stream<Map<dynamic, dynamic>> get callEvents {
    return _eventChannel.receiveBroadcastStream().map(
      (dynamic event) => (event as Map<dynamic, dynamic>?) ?? {},
    );
  }

  void dispose() {
    _dialIntentController.close();
  }
}
