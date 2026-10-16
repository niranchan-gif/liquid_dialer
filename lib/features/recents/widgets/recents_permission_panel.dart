import 'package:flutter/material.dart';

import '../../../core/permissions/phone_permissions_service.dart';
import '../../../core/theme/glass_styles.dart';
import '../../../shared/widgets/glass_panel.dart';

/// Explanatory Liquid Glass card requesting call-log permission at the point of use.
class RecentsPermissionPanel extends StatelessWidget {
  const RecentsPermissionPanel({
    super.key,
    required this.status,
    required this.onRequestPermission,
    required this.onOpenSettings,
  });

  final AppPermissionStatus status;
  final VoidCallback onRequestPermission;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final isPermanent = status.isPermanentlyDenied;

    return Center(
      child: GlassPanel(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.0,
              height: 64.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: GlassColors.icyBlue.withValues(alpha: 0.15),
                border: Border.all(
                  color: GlassColors.icyBlue.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 32.0,
                color: GlassColors.icyBlue,
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              isPermanent ? 'Call History Disabled' : 'Device Call History',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
                color: GlassColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10.0),
            Text(
              isPermanent
                  ? 'Call log permission has been permanently denied in Android settings. Enable it in app permissions or view your call history in the default system Phone app.'
                  : 'Android requires explicit user permission to read incoming, outgoing, and missed call history from your device. Keypad and Contacts work without it.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.0,
                color: GlassColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24.0),
            GestureDetector(
              key: Key(
                isPermanent
                    ? 'recentsOpenSettingsButton'
                    : 'recentsEnableHistoryButton',
              ),
              onTap: isPermanent ? onOpenSettings : onRequestPermission,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  gradient: const LinearGradient(
                    colors: [GlassColors.cyanAccent, GlassColors.icyBlue],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: GlassColors.cyanAccent.withValues(alpha: 0.3),
                      blurRadius: 16.0,
                      spreadRadius: -2.0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isPermanent
                          ? Icons.settings_rounded
                          : Icons.playlist_add_check_rounded,
                      size: 18.0,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 8.0),
                    Flexible(
                      child: Text(
                        isPermanent ? 'Open Settings' : 'Enable Call History',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
