import 'package:flutter/material.dart';

import '../../core/theme/liquid_theme.dart';
import '../../shared/widgets/glass_icon_button.dart';
import '../../shared/widgets/liquid_droplet.dart';
import '../../shared/widgets/liquid_surface.dart';
import '../../shared/widgets/liquid_wave_background.dart';

import '../calls/call_controller.dart';
import '../privacy/privacy_center_screen.dart';
import 'appearance_screen.dart';
import 'widgets/default_dialer_tile.dart';

/// Settings and Theme screen matching Screen 12 of the reference design.
///
/// Features grouped liquid surface navigation tiles with chevrons,
/// deep links to Appearance & Customization, Permissions & Privacy Center,
/// and default phone role status.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, this.callController});

  final CallController? callController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LiquidColors.background,
      body: LiquidWaveBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    GlassIconButton(
                      key: const Key('settingsBackButton'),
                      icon: Icons.arrow_back_ios_new_rounded,
                      tooltip: 'Back',
                      iconSize: 18.0,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 16.0),
                    const Expanded(
                      child: Text(
                        'Theme & Settings',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                          color: LiquidColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 12.0,
                  ),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Default Dialer Role Status
                    DefaultDialerTile(controller: callController),
                    const SizedBox(height: 16.0),

                    // 1. Appearance (Screen 14 entry)
                    _buildSettingsTile(
                      key: const Key('settingsAppearanceButton'),
                      icon: Icons.palette_outlined,
                      title: 'Appearance',
                      subtitle: 'Liquid Glass Specular Engine',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AppearanceScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 10.0),

                    // 2. Call Settings
                    _buildSettingsTile(
                      key: const Key('settingsCallSettingsButton'),
                      icon: Icons.phone_in_talk_outlined,
                      title: 'Call Settings',
                      subtitle: 'Calling behaviour',
                      onTap: () {},
                    ),

                    const SizedBox(height: 10.0),

                    // 3. Contacts
                    _buildSettingsTile(
                      key: const Key('settingsContactsPreferencesButton'),
                      icon: Icons.person_outline_rounded,
                      title: 'Contacts',
                      subtitle: 'Contact preferences',
                      onTap: () {},
                    ),

                    const SizedBox(height: 10.0),

                    // 4. Notifications
                    _buildSettingsTile(
                      key: const Key('settingsNotificationsButton'),
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      subtitle: 'Ringtone, alerts',
                      onTap: () {},
                    ),

                    const SizedBox(height: 10.0),

                    // 5. Permissions (Privacy Center Screen)
                    _buildSettingsTile(
                      key: const Key('settingsPrivacyCenterButton'),
                      icon: Icons.security_rounded,
                      title: 'Permissions',
                      subtitle: 'Required permissions & privacy',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PrivacyCenterScreen(
                              callController: callController,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 10.0),

                    // 6. Advanced
                    _buildSettingsTile(
                      key: const Key('settingsAdvancedButton'),
                      icon: Icons.tune_rounded,
                      title: 'Advanced',
                      subtitle: 'Developer options',
                      onTap: () {},
                    ),

                    const SizedBox(height: 10.0),

                    // 7. About
                    _buildSettingsTile(
                      key: const Key('settingsAboutButton'),
                      icon: Icons.info_outline_rounded,
                      title: 'About',
                      subtitle: 'Version 1.0.0',
                      onTap: () {},
                    ),

                    const SizedBox(height: 24.0),

                    // Milestone card containing Phase 5 requirement string
                    LiquidSurface(
                      level: LiquidSurfaceLevel.card,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10.0,
                                height: 10.0,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF4ADE80),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x604ADE80),
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              const Text(
                                'ACTIVE MILESTONE',
                                style: TextStyle(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: LiquidColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          const Text(
                            'Phase 5 — Production Hardened & Liquid Glass Dialing',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: LiquidColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          const Text(
                            'Liquid Glass Specular Engine',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: LiquidColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    Key? key,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return LiquidSurface(
      key: key,
      level: LiquidSurfaceLevel.card,
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          splashColor: const Color(0x18FFFFFF),
          highlightColor: const Color(0x0CFFFFFF),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
            child: Row(
              children: [
                LiquidDroplet(
                  size: 40.0,
                  child: Center(
                    child: Icon(
                      icon,
                      size: 20.0,
                      color: LiquidColors.silverHighlight,
                    ),
                  ),
                ),
                const SizedBox(width: 14.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                          color: LiquidColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: LiquidColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: LiquidColors.textSecondary,
                  size: 22.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
