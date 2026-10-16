import 'package:flutter/material.dart';

import '../../../core/permissions/phone_permissions_service.dart';
import '../../../core/theme/glass_styles.dart';
import '../../../shared/widgets/glass_panel.dart';

/// Explanatory Liquid Glass card requesting device contact access.
class ContactPermissionPanel extends StatelessWidget {
  const ContactPermissionPanel({
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
                color: GlassColors.softViolet.withValues(alpha: 0.15),
                border: Border.all(
                  color: GlassColors.softViolet.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: const Icon(
                Icons.contacts_rounded,
                size: 32.0,
                color: GlassColors.softViolet,
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              isPermanent ? 'Contacts Access Disabled' : 'Access Your Contacts',
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
                  ? 'Contact access has been permanently disabled in Android settings. Please open settings to allow Liquid Dialer to view your contacts.'
                  : 'To quickly find people, view caller identities, and bookmark favorites, grant contact access.',
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
                    ? 'contactsOpenSettingsButton'
                    : 'contactsGrantAccessButton',
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
                    colors: [GlassColors.icyBlue, GlassColors.deepViolet],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: GlassColors.icyBlue.withValues(alpha: 0.3),
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
                          : Icons.lock_open_rounded,
                      size: 18.0,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8.0),
                    Flexible(
                      child: Text(
                        isPermanent ? 'Open Settings' : 'Grant Contact Access',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
