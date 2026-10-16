import 'package:flutter/material.dart';

import '../../../core/permissions/phone_permissions_service.dart';
import '../../../core/theme/liquid_theme.dart';
import '../../../shared/widgets/liquid_button.dart';
import '../../../shared/widgets/liquid_droplet.dart';
import '../../../shared/widgets/liquid_surface.dart';

/// Explanatory Pure Liquid card requesting device contact access.
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
      child: LiquidSurface(
        level: LiquidSurfaceLevel.card,
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LiquidDroplet(
              size: 64.0,
              surfaceColor: const Color(0xFF222222),
              bottomColor: const Color(0xFF101010),
              borderColor: const Color(0x35FFFFFF),
              glowColor: const Color(0x20FFFFFF),
              child: const Icon(
                Icons.contacts_rounded,
                size: 30.0,
                color: LiquidColors.silverPrimary,
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              isPermanent ? 'Contacts Access Disabled' : 'Access Your Contacts',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
                color: LiquidColors.textPrimary,
                letterSpacing: 0.2,
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
                color: LiquidColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24.0),
            LiquidButton(
              key: Key(
                isPermanent
                    ? 'contactsOpenSettingsButton'
                    : 'contactsGrantAccessButton',
              ),
              height: 48.0,
              theme: LiquidButtonTheme.graphite,
              onTap: isPermanent ? onOpenSettings : onRequestPermission,
              icon: isPermanent
                  ? Icons.settings_rounded
                  : Icons.lock_open_rounded,
              label: isPermanent ? 'Open Settings' : 'Grant Contact Access',
            ),
          ],
        ),
      ),
    );
  }
}
