import 'package:flutter/material.dart';

import '../../../core/theme/glass_styles.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../models/audio_route.dart';

/// Modal bottom sheet allowing selection between Telecom-supported audio routes.
class AudioRouteSelector extends StatelessWidget {
  const AudioRouteSelector({
    super.key,
    required this.audioState,
    required this.onSelectRoute,
  });

  final AudioRouteState audioState;
  final ValueChanged<AudioRoute> onSelectRoute;

  static Future<void> show(
    BuildContext context, {
    required AudioRouteState audioState,
    required ValueChanged<AudioRoute> onSelectRoute,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AudioRouteSelector(
        audioState: audioState,
        onSelectRoute: onSelectRoute,
      ),
    );
  }

  IconData _iconForRoute(AudioRoute route) {
    switch (route) {
      case AudioRoute.speaker:
        return Icons.volume_up_rounded;
      case AudioRoute.bluetooth:
        return Icons.bluetooth_audio_rounded;
      case AudioRoute.wiredHeadset:
        return Icons.headphones_rounded;
      case AudioRoute.earpiece:
        return Icons.phone_android_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: GlassColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 16.0,
        bottom: MediaQuery.of(context).padding.bottom + 20.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: GlassColors.borderLight,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),
          const SizedBox(height: 20.0),

          const Text(
            'AUDIO OUTPUT',
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: GlassColors.textMuted,
            ),
          ),
          const SizedBox(height: 12.0),

          for (final route in audioState.supportedRoutes) ...[
            () {
              final isSelected = route == audioState.currentRoute;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: GestureDetector(
                  onTap: () {
                    onSelectRoute(route);
                    Navigator.of(context).pop();
                  },
                  child: GlassPanel(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 14.0,
                    ),
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              GlassColors.cyanAccent.withValues(alpha: 0.15),
                              GlassColors.icyBlue.withValues(alpha: 0.08),
                            ],
                          )
                        : null,
                    border: isSelected
                        ? Border.all(
                            color: GlassColors.cyanAccent.withValues(
                              alpha: 0.5,
                            ),
                            width: 1.5,
                          )
                        : null,
                    child: Row(
                      children: [
                        Icon(
                          _iconForRoute(route),
                          color: isSelected
                              ? GlassColors.cyanAccent
                              : GlassColors.textSecondary,
                          size: 22.0,
                        ),
                        const SizedBox(width: 14.0),
                        Expanded(
                          child: Text(
                            route.displayName,
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? GlassColors.textPrimary
                                  : GlassColors.textSecondary,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: GlassColors.cyanAccent,
                            size: 20.0,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }(),
          ],
        ],
      ),
    );
  }
}
