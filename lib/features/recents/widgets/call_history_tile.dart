import 'package:flutter/material.dart';

import '../../../core/theme/glass_styles.dart';
import '../models/call_history_item.dart';

/// Translucent Liquid Glass call-log row item with call-type indicators and direct call action.
class CallHistoryTile extends StatelessWidget {
  const CallHistoryTile({super.key, required this.item, required this.onTap});

  final CallHistoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(item.callType);
    final typeIcon = _getTypeIcon(item.callType);

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0x1AFFFFFF), width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          splashColor: const Color(0x18FFFFFF),
          highlightColor: const Color(0x0CFFFFFF),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                // Call type indicator icon
                Container(
                  width: 42.0,
                  height: 42.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: typeColor.withValues(alpha: 0.12),
                    border: Border.all(
                      color: typeColor.withValues(alpha: 0.25),
                      width: 1.0,
                    ),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 20.0),
                ),
                const SizedBox(width: 14.0),

                // Name / Number & Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: item.callType == CallHistoryType.missed
                              ? GlassColors.danger
                              : GlassColors.textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 3.0),
                      Row(
                        children: [
                          Text(
                            item.callType.label,
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                              color: typeColor,
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          Container(
                            width: 3.0,
                            height: 3.0,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: GlassColors.textMuted,
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          Text(
                            item.formattedDuration,
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: GlassColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Timestamp & Quick Call Action
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.formattedTimestamp,
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: GlassColors.textMuted,
                      ),
                    ),
                    if (item.number.isNotEmpty) ...[
                      const SizedBox(width: 10.0),
                      Semantics(
                        button: true,
                        label: 'Call ${item.displayName}',
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            key: Key('callButton_${item.number}'),
                            borderRadius: BorderRadius.circular(20.0),
                            splashColor: const Color(0x30FFFFFF),
                            onTap: onTap,
                            child: Container(
                              width: 36.0,
                              height: 36.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF1B1B1B),
                                border: Border.all(
                                  color: const Color(0x30FFFFFF),
                                  width: 1.0,
                                ),
                              ),
                              child: const Icon(
                                Icons.call_rounded,
                                size: 18.0,
                                color: GlassColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(CallHistoryType type) {
    switch (type) {
      case CallHistoryType.incoming:
        return const Color(0xFF4EBE88);
      case CallHistoryType.outgoing:
        return GlassColors.silverHighlight;
      case CallHistoryType.missed:
      case CallHistoryType.rejected:
      case CallHistoryType.blocked:
        return GlassColors.danger;
      case CallHistoryType.unknown:
        return GlassColors.textSecondary;
    }
  }

  IconData _getTypeIcon(CallHistoryType type) {
    switch (type) {
      case CallHistoryType.incoming:
        return Icons.call_received_rounded;
      case CallHistoryType.outgoing:
        return Icons.call_made_rounded;
      case CallHistoryType.missed:
        return Icons.call_missed_rounded;
      case CallHistoryType.rejected:
      case CallHistoryType.blocked:
        return Icons.phone_disabled_rounded;
      case CallHistoryType.unknown:
        return Icons.phone_rounded;
    }
  }
}
