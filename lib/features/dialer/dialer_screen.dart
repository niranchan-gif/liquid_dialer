import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/liquid_theme.dart';
import '../../shared/widgets/glass_icon_button.dart';
import '../../shared/widgets/liquid_wave_background.dart';
import '../settings/settings_screen.dart';
import 'dialer_controller.dart';
import 'dialer_keypad.dart';
import 'phone_number_display.dart';

/// Main Liquid Glass dialer screen matching the reference design.
///
/// Features organic liquid mercury wave backdrop, bold "Dial" header,
/// quick navigation subtabs (Favorites, Recents, Contacts), live contact matching,
/// and circular graphite keys with the signature liquid call button.
class DialerScreen extends StatelessWidget {
  const DialerScreen({
    super.key,
    required this.controller,
    this.onNavigateToContacts,
    this.onNavigateToRecents,
  });

  final DialerController controller;
  final VoidCallback? onNavigateToContacts;
  final VoidCallback? onNavigateToRecents;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: LiquidWaveBackground(
        showWaves: true,
        showFloatingDroplets: true,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final content = Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Header & Subtabs Row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 6.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Title "Dial" and Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'LIQUID',
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2.0,
                                    color: LiquidColors.textMuted,
                                  ),
                                ),
                                Text(
                                  'Dial',
                                  style: TextStyle(
                                    fontSize: 28.0,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.4,
                                    color: LiquidColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Contacts shortcut (preserving test key)
                                GlassIconButton(
                                  key: const Key('headerContactsButton'),
                                  icon: Icons.person_search_rounded,
                                  tooltip: 'Contacts',
                                  iconColor: LiquidColors.textSecondary,
                                  onTap: onNavigateToContacts,
                                ),
                                const SizedBox(width: 8.0),
                                // Settings shortcut (preserving test key)
                                GlassIconButton(
                                  key: const Key('headerSettingsButton'),
                                  icon: Icons.tune_rounded,
                                  tooltip: 'Settings',
                                  iconColor: LiquidColors.textSecondary,
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
                          ],
                        ),

                        const SizedBox(height: 10.0),

                        // Subtabs matching reference image: Favorites, Recents, Contacts
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _buildSubtab(
                                label: 'Favorites',
                                isSelected: false,
                                onTap: onNavigateToContacts,
                              ),
                              const SizedBox(width: 16.0),
                              _buildSubtab(
                                label: 'Recents\u200B',
                                isSelected: false,
                                onTap: onNavigateToRecents,
                              ),
                              const SizedBox(width: 16.0),
                              _buildSubtab(
                                label: 'Contacts\u200B',
                                isSelected: false,
                                onTap: onNavigateToContacts,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Phone number display with live suggestion chip
                  PhoneNumberDisplay(
                    controller: controller,
                    onCallSuggestion: (number) => controller.call(),
                  ),

                  // Keypad with circular droplets and signature liquid call button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: DialerKeypad(
                      controller: controller,
                      onAddContact: onNavigateToContacts,
                    ),
                  ),
                ],
              );

              if (constraints.maxHeight >= 620) {
                return SizedBox(height: constraints.maxHeight, child: content);
              }

              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: content,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSubtab({
    required String label,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.0,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? LiquidColors.textPrimary
                  : LiquidColors.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4.0),
          Container(
            height: 2.0,
            width: 24.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1.0),
              color: isSelected
                  ? LiquidColors.silverHighlight
                  : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
