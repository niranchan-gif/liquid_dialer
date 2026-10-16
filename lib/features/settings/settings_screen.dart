import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/glass_styles.dart';
import '../../shared/widgets/glass_icon_button.dart';
import '../../shared/widgets/glass_panel.dart';

import '../calls/call_controller.dart';
import '../privacy/privacy_center_screen.dart';
import 'widgets/default_dialer_tile.dart';

/// Settings and Theme Preview screen.
///
/// Features a visual theme preview of Liquid Glass elements and descriptive
/// indicators for future customization, avoiding nonfunctional switches.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, this.callController});

  final CallController? callController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlassColors.background,
      body: Stack(
        children: [
          // Ambient background glow
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 240,
              height: 240,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x1838BDF8), Colors.transparent],
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
                            color: GlassColors.textPrimary,
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
                      GlassPanel(
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
                                  color: GlassColors.mintPrimary.withValues(
                                    alpha: 0.15,
                                  ),
                                  border: Border.all(
                                    color: GlassColors.mintLight.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.security_rounded,
                                  size: 20.0,
                                  color: GlassColors.mintLight,
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
                                        color: GlassColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 2.0),
                                    Text(
                                      'Review system roles, permissions & zero-tracking',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: GlassColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: GlassColors.textSecondary,
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
                          color: GlassColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 10.0),

                      GlassPanel(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 12.0,
                                  height: 12.0,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: GlassColors.cyanAccent,
                                    boxShadow: [
                                      BoxShadow(
                                        color: GlassColors.cyanAccent,
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
                                      color: GlassColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12.0),
                            const Text(
                              'Designed for the OnePlus Nord 4 120Hz AMOLED display. Features real-time translucent backdrop blur, subtle edge specular highlights, and restrained cyan/violet ambient lighting.',
                              style: TextStyle(
                                fontSize: 13.0,
                                color: GlassColors.textSecondary,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 16.0),

                            // Color token swatches preview
                            Row(
                              children: [
                                _buildColorToken(
                                  'Cyan',
                                  GlassColors.cyanAccent,
                                ),
                                const SizedBox(width: 8.0),
                                _buildColorToken(
                                  'Icy Blue',
                                  GlassColors.icyBlue,
                                ),
                                const SizedBox(width: 8.0),
                                _buildColorToken(
                                  'Violet',
                                  GlassColors.softViolet,
                                ),
                                const SizedBox(width: 8.0),
                                _buildColorToken(
                                  'Mint',
                                  GlassColors.mintPrimary,
                                ),
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
                          color: GlassColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 10.0),

                      GlassPanel(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              icon: Icons.blur_on_rounded,
                              title: 'Backdrop Blur Intensity',
                              subtitle: 'Default: 16.0 sigma (Configurable in Phase 2)',
                            ),
                            const Divider(
                              color: GlassColors.borderSubtle,
                              height: 24.0,
                            ),
                            _buildInfoRow(
                              icon: Icons.vibration_rounded,
                              title: 'Tactile Haptic Feedback',
                              subtitle: 'Active: Light impact per keypress',
                            ),
                            const Divider(
                              color: GlassColors.borderSubtle,
                              height: 24.0,
                            ),
                            _buildInfoRow(
                              icon: Icons.palette_outlined,
                              title: 'Accent Palette Presets',
                              subtitle: 'Cyan Ice / Neon Violet / Emerald Glow',
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
                          color: GlassColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 10.0),

                      GlassPanel(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              icon: Icons.phone_android_rounded,
                              title: 'Target Device',
                              subtitle: 'OnePlus Nord 4 (Android 16 Ready)',
                            ),
                            const Divider(
                              color: GlassColors.borderSubtle,
                              height: 24.0,
                            ),
                            _buildInfoRow(
                              icon: Icons.layers_rounded,
                              title: 'Current Milestone',
                              subtitle: 'Phase 5 — Production Hardened & Liquid Glass Dialing',
                            ),
                            const Divider(
                              color: GlassColors.borderSubtle,
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
          color: color.withValues(alpha: 0.15),
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
                color: color,
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
        Container(
          width: 38.0,
          height: 38.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: GlassColors.glassFillLight,
            border: Border.all(color: GlassColors.borderSubtle),
          ),
          child: Icon(icon, size: 20.0, color: GlassColors.icyBlue),
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
                  color: GlassColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: GlassColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
