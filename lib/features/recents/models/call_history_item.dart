import 'package:intl/intl.dart';

/// Supported call classification categories.
enum CallHistoryType {
  incoming,
  outgoing,
  missed,
  rejected,
  blocked,
  unknown;

  String get label {
    switch (this) {
      case CallHistoryType.incoming:
        return 'Incoming';
      case CallHistoryType.outgoing:
        return 'Outgoing';
      case CallHistoryType.missed:
        return 'Missed';
      case CallHistoryType.rejected:
        return 'Rejected';
      case CallHistoryType.blocked:
        return 'Blocked';
      case CallHistoryType.unknown:
        return 'Unknown';
    }
  }
}

/// Represents an individual call log record for the Recents screen.
class CallHistoryItem implements Comparable<CallHistoryItem> {
  const CallHistoryItem({
    this.id,
    this.name,
    required this.number,
    required this.callType,
    required this.timestamp,
    this.durationSeconds = 0,
  });

  final String? id;
  final String? name;
  final String number;
  final CallHistoryType callType;
  final DateTime timestamp;
  final int durationSeconds;

  /// Effective readable label, falling back to number or unknown label.
  String get displayName {
    if (name != null && name!.trim().isNotEmpty) {
      return name!.trim();
    }
    final trimmedNumber = number.trim();
    if (trimmedNumber.isNotEmpty) {
      return trimmedNumber;
    }
    return 'Unknown Caller';
  }

  /// Human-readable duration representation.
  String get formattedDuration {
    if (callType == CallHistoryType.missed) return 'Missed';
    if (callType == CallHistoryType.rejected) return 'Rejected';
    if (durationSeconds <= 0) return '0s';

    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  /// User-friendly date and time string.
  String get formattedTimestamp {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final callDay = DateTime(timestamp.year, timestamp.month, timestamp.day);

    final timeStr = DateFormat('h:mm a').format(timestamp);

    if (callDay == today) {
      return 'Today, $timeStr';
    } else if (callDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, $timeStr';
    } else if (now.difference(timestamp).inDays < 7) {
      final dayName = DateFormat('EEEE').format(timestamp);
      return '$dayName, $timeStr';
    } else {
      return DateFormat('MMM d, h:mm a').format(timestamp);
    }
  }

  @override
  int compareTo(CallHistoryItem other) {
    // Sort newest first
    return other.timestamp.compareTo(timestamp);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallHistoryItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          number == other.number &&
          callType == other.callType &&
          timestamp == other.timestamp &&
          durationSeconds == other.durationSeconds;

  @override
  int get hashCode =>
      id.hashCode ^
      number.hashCode ^
      callType.hashCode ^
      timestamp.hashCode ^
      durationSeconds.hashCode;
}
