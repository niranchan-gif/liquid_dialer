import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/glass_styles.dart';
import '../../shared/widgets/glass_icon_button.dart';
import '../settings/settings_screen.dart';
import 'dialer_controller.dart';
import 'dialer_keypad.dart';
import 'phone_number_display.dart';

/// Main Liquid Glass dialer screen with ambient lighting, header, display, and keypad.
class DialerScreen extends StatelessWidget {
  const DialerScreen({
    super.key,
    required this.controller,
    this.onNavigateToContacts,
  });

  final DialerController controller;
  final VoidCallback? onNavigateToContacts;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          // Ambient AMOLED specular highlights (subtle restrained silver glow)
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x0AFFFFFF), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 140,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x06FFFFFF), Colors.transparent],
                ),
              ),
            ),
          ),

          // Main screen content with responsive scrollable layout to prevent overflows
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final content = Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 6.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Contacts shortcut
                          GlassIconButton(
                            key: const Key('headerContactsButton'),
                            icon: Icons.person_search_rounded,
                            tooltip: 'Contacts',
                            iconColor: GlassColors.textSecondary,
                            onTap: onNavigateToContacts,
                          ),

                          // Configurable app title badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14.0,
                              vertical: 6.0,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: GlassColors.glassFillUltraLight,
                              border: Border.all(
                                color: GlassColors.borderSubtle,
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7.0,
                                  height: 7.0,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: GlassColors.silverAccent,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x33FFFFFF),
                                        blurRadius: 6.0,
                                        spreadRadius: 0.5,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                const Text(
                                  AppTheme.appShortName,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2.2,
                                    color: GlassColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Settings shortcut
                          GlassIconButton(
                            key: const Key('headerSettingsButton'),
                            icon: Icons.tune_rounded,
                            tooltip: 'Settings',
                            iconColor: GlassColors.textSecondary,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const SettingsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6.0),

                    // Phone number display
                    PhoneNumberDisplay(controller: controller),

                    const SizedBox(height: 6.0),

                    // Keypad with digits and call action
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: DialerKeypad(controller: controller),
                    ),
                  ],
                );

                if (constraints.maxHeight >= 540) {
                  return SizedBox(
                    height: constraints.maxHeight,
                    child: content,
                  );
                }

                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: content,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
