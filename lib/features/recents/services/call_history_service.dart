import 'package:call_log/call_log.dart' as cl;

import '../models/call_history_item.dart';

/// Abstract contract for querying call logs from the underlying platform.
abstract class CallHistoryService {
  Future<List<CallHistoryItem>> fetchCallHistory();
}

/// Real Android call history service querying device CallLog.
class DeviceCallHistoryService implements CallHistoryService {
  const DeviceCallHistoryService();

  @override
  Future<List<CallHistoryItem>> fetchCallHistory() async {
    final entries = await cl.CallLog.query();

    final List<CallHistoryItem> items = [];
    for (final entry in entries) {
      final item = CallHistoryItem(
        id: entry.timestamp != null
            ? '${entry.timestamp}_${entry.number ?? ""}'
            : null,
        name: entry.name?.trim(),
        number: entry.number?.trim() ?? '',
        callType: _mapCallType(entry.callType),
        timestamp: DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0),
        durationSeconds: entry.duration ?? 0,
      );
      items.add(item);
    }

    // Sort newest first
    items.sort();
    return items;
  }

  CallHistoryType _mapCallType(cl.CallType? type) {
    if (type == null) return CallHistoryType.unknown;
    switch (type) {
      case cl.CallType.incoming:
        return CallHistoryType.incoming;
      case cl.CallType.outgoing:
        return CallHistoryType.outgoing;
      case cl.CallType.missed:
        return CallHistoryType.missed;
      case cl.CallType.rejected:
        return CallHistoryType.rejected;
      case cl.CallType.blocked:
        return CallHistoryType.blocked;
      default:
        return CallHistoryType.unknown;
    }
  }
}

/// Mock call history service for tests.
class MockCallHistoryService implements CallHistoryService {
  MockCallHistoryService({
    List<CallHistoryItem>? history,
    this.shouldThrow = false,
  }) : _history = history ?? [];

  final List<CallHistoryItem> _history;
  final bool shouldThrow;

  @override
  Future<List<CallHistoryItem>> fetchCallHistory() async {
    if (shouldThrow) {
      throw Exception('Failed to query device call log.');
    }
    final list = List<CallHistoryItem>.from(_history);
    list.sort();
    return list;
  }
}
