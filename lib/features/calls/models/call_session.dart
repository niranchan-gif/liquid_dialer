import 'call_state.dart';

/// Models an individual cellular telephone call session tracked by Android Telecom.
class CallSession {
  const CallSession({
    required this.sessionId,
    required this.phoneNumber,
    this.displayName,
    this.state = CallState.connecting,
    this.direction = CallDirection.outgoing,
    this.connectTimeMillis,
    this.disconnectReason,
  });

  final String sessionId;
  final String phoneNumber;
  final String? displayName;
  final CallState state;
  final CallDirection direction;
  final int? connectTimeMillis;
  final String? disconnectReason;

  factory CallSession.fromMap(Map<dynamic, dynamic> map) {
    return CallSession(
      sessionId: map['sessionId'] as String? ?? 'unknown',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      displayName: map['displayName'] as String?,
      state: CallState.fromString(map['state'] as String?),
      direction: CallDirection.fromString(map['direction'] as String?),
      connectTimeMillis: (map['connectTimeMillis'] as num?)?.toInt(),
      disconnectReason: map['disconnectReason'] as String?,
    );
  }

  CallSession copyWith({
    String? sessionId,
    String? phoneNumber,
    String? displayName,
    CallState? state,
    CallDirection? direction,
    int? connectTimeMillis,
    String? disconnectReason,
  }) {
    return CallSession(
      sessionId: sessionId ?? this.sessionId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      state: state ?? this.state,
      direction: direction ?? this.direction,
      connectTimeMillis: connectTimeMillis ?? this.connectTimeMillis,
      disconnectReason: disconnectReason ?? this.disconnectReason,
    );
  }

  /// Returns the most descriptive contact label available.
  String get effectiveName {
    if (displayName != null && displayName!.trim().isNotEmpty) {
      return displayName!.trim();
    }
    if (phoneNumber.trim().isNotEmpty) {
      return phoneNumber.trim();
    }
    return 'Unknown Caller';
  }

  /// Whether a contact display name is present.
  bool get hasCallerName =>
      displayName != null && displayName!.trim().isNotEmpty;

  /// Returns avatar monogram initials (e.g. "JD" for John Doe).
  String get initials {
    final name = effectiveName;
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  /// Calculates call duration relative to [now] based on the authoritative connect timestamp.
  Duration getElapsedDuration([DateTime? now]) {
    if (connectTimeMillis == null || connectTimeMillis! <= 0) {
      return Duration.zero;
    }
    final currentTime = now ?? DateTime.now();
    final start = DateTime.fromMillisecondsSinceEpoch(connectTimeMillis!);
    final diff = currentTime.difference(start);
    return diff.isNegative ? Duration.zero : diff;
  }
}
