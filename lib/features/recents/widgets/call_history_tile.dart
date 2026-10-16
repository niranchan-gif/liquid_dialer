import 'package:flutter/material.dart';

import '../../../core/theme/glass_styles.dart';
import '../models/call_history_item.dart';

/// Translucent Liquid Glass call-log row item with call-type indicators.
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
        color: GlassColors.glassFillUltraLight,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: GlassColors.borderSubtle, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          splashColor: GlassColors.cyanAccent.withValues(alpha: 0.08),
          highlightColor: GlassColors.glassFillLight,
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

                // Timestamp
                Text(
                  item.formattedTimestamp,
                  style: const TextStyle(
                    fontSize: 12.0,
                    color: GlassColors.textMuted,
                  ),
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
        return GlassColors.cyanAccent;
      case CallHistoryType.outgoing:
        return GlassColors.icyBlue;
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
