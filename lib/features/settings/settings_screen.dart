import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/liquid_theme.dart';
import '../../shared/widgets/glass_icon_button.dart';
import '../../shared/widgets/liquid_droplet.dart';
import '../../shared/widgets/liquid_surface.dart';

import '../calls/call_controller.dart';
import '../privacy/privacy_center_screen.dart';
import 'widgets/default_dialer_tile.dart';

/// Settings and Theme Preview screen with pure water-droplet design system.
///
/// Features a visual theme preview of Liquid Glass elements and descriptive
/// indicators for future customization, avoiding nonfunctional switches.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, this.callController});

  final CallController? callController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LiquidColors.background,
      body: Stack(
        children: [
          // Subtle top liquid halo (silver specular depth, no neon)
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    LiquidColors.specularMeniscus.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
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
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
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
                    children: [
                      DefaultDialerTile(controller: callController),
                      const SizedBox(height: 14.0),

                      // Permissions & Privacy Center Entry Tile
                      LiquidSurface(
                        level: LiquidSurfaceLevel.card,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 14.0,
                        ),
                        child: InkWell(
                          key: const Key('settingsPrivacyCenterButton'),
                          borderRadius: BorderRadius.circular(12.0),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PrivacyCenterScreen(
                                  callController: callController,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 38.0,
                                height: 38.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0x2034D399),
                                  border: Border.all(
                                    color: const Color(0x6034D399),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.security_rounded,
                                  size: 20.0,
                                  color: Color(0xFF4ADE80),
                                ),
                              ),
                              const SizedBox(width: 14.0),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Permissions & Privacy Center',
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w600,
                                        color: LiquidColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 2.0),
                                    Text(
                                      'Review system roles, permissions & zero-tracking',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: LiquidColors.textSecondary,
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
                      const SizedBox(height: 24.0),

                      // Section 1: Liquid Glass Theme Preview
                      const Text(
                        'THEME PREVIEW',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: LiquidColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 10.0),

                      LiquidSurface(
                        level: LiquidSurfaceLevel.card,
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 12.0,
                                  height: 12.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: LiquidColors.silverHighlight,
                                    boxShadow: [
                                      BoxShadow(
                                        color: LiquidColors.silverHighlight
                                            .withValues(alpha: 0.5),
                                        blurRadius: 8.0,
                                        spreadRadius: 1.0,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10.0),
                                const Expanded(
                                  child: Text(
                                    'Liquid Glass Specular Engine',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      color: LiquidColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12.0),
                            const Text(
                              'Designed for the OnePlus Nord 4 120Hz AMOLED display. Features pure water droplets flowing over dark glass, tactile scale compression, and directional specular edge highlights.',
                              style: TextStyle(
                                fontSize: 13.0,
                                color: LiquidColors.textSecondary,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 16.0),

                            // Color token swatches preview
                            Row(
                              children: [
                                _buildColorToken(
                                  'Silver',
                                  LiquidColors.silverHighlight,
                                ),
                                const SizedBox(width: 8.0),
                                _buildColorToken(
                                  'Graphite',
                                  LiquidColors.surfaceElevated,
                                ),
                                const SizedBox(width: 8.0),
                                _buildColorToken(
                                  'Meniscus',
                                  LiquidColors.specularMeniscus,
                                ),
                                const SizedBox(width: 8.0),
                                _buildColorToken('Mist', LiquidColors.mistGrey),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24.0),

                      // Section 2: Future Customization Preview
                      const Text(
                        'UPCOMING CUSTOMIZATION',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: LiquidColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 10.0),

                      LiquidSurface(
                        level: LiquidSurfaceLevel.card,
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              icon: Icons.water_drop_rounded,
                              title: 'Droplet Surface Tension',
                              subtitle: 'Active: Physical curvature & edge reflections',
                            ),
                            const Divider(
                              color: LiquidColors.borderSubtle,
                              height: 24.0,
                            ),
                            _buildInfoRow(
                              icon: Icons.vibration_rounded,
                              title: 'Tactile Water Haptics',
                              subtitle: 'Active: Light impact per droplet compression',
                            ),
                            const Divider(
                              color: LiquidColors.borderSubtle,
                              height: 24.0,
                            ),
                            _buildInfoRow(
                              icon: Icons.palette_outlined,
                              title: 'Liquid AMOLED Aesthetics',
                              subtitle:
                                  'Pure Black / Silver Highlights / Mist Grey',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24.0),

                      // Section 3: App Information
                      const Text(
                        'ABOUT',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: LiquidColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 10.0),

                      LiquidSurface(
                        level: LiquidSurfaceLevel.card,
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              icon: Icons.phone_android_rounded,
                              title: 'Target Device',
                              subtitle: 'OnePlus Nord 4 (Android 16 Ready)',
                            ),
                            const Divider(
                              color: LiquidColors.borderSubtle,
                              height: 24.0,
                            ),
                            _buildInfoRow(
                              icon: Icons.layers_rounded,
                              title: 'Current Milestone',
                              subtitle: 'Phase 5 — Production Hardened & Liquid Glass Dialing',
                            ),
                            const Divider(
                              color: LiquidColors.borderSubtle,
                              height: 24.0,
                            ),
                            _buildInfoRow(
                              icon: Icons.terminal_rounded,
                              title: 'App Identifier',
                              subtitle: AppTheme.appTitle,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildColorToken(String name, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: LiquidColors.surfaceElevated,
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.0),
        ),
        child: Column(
          children: [
            Container(
              width: 14.0,
              height: 14.0,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(height: 4.0),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.0,
                fontWeight: FontWeight.w500,
                color: color == LiquidColors.surfaceElevated
                    ? LiquidColors.textSecondary
                    : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        LiquidDroplet(
          size: 38.0,
          child: Center(
            child: Icon(icon, size: 20.0, color: LiquidColors.silverHighlight),
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
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: LiquidColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: LiquidColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
