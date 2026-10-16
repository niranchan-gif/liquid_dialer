import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/liquid_theme.dart';
import '../../shared/widgets/glass_icon_button.dart';
import '../../shared/widgets/liquid_surface.dart';
import '../../shared/widgets/liquid_wave_background.dart';

/// Theme & Appearance configuration screen matching Screen 14 of the reference design.
///
/// Features a miniature liquid dialpad preview, accent color selection swatches,
/// and toggles for liquid animations, AMOLED dark mode, and haptic feedback.
class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  int _selectedColorIndex = 0;
  bool _liquidEffectEnabled = true;
  bool _darkModeEnabled = true;
  bool _hapticFeedbackEnabled = true;

  final List<Color> _accentColors = const [
    Color(0xFFE6EEF8), // Silver / Mercury
    Color(0xFF38BDF8), // Liquid Sky Blue
    Color(0xFFA855F7), // Neon Violet
    Color(0xFF4ADE80), // Emerald Green
  ];

  @override
  Widget build(BuildContext context) {
    final activeColor = _accentColors[_selectedColorIndex];

    return Scaffold(
      backgroundColor: LiquidColors.background,
      body: LiquidWaveBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header with Back Button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    GlassIconButton(
                      key: const Key('appearanceBackButton'),
                      icon: Icons.arrow_back_ios_new_rounded,
                      tooltip: 'Back',
                      iconSize: 18.0,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 16.0),
                    const Text(
                      'Appearance',
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: LiquidColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 12.0,
                  ),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Miniature Keypad Liquid Preview Card (matching Screen 14)
                    _buildMiniatureKeypadPreview(activeColor),

                    const SizedBox(height: 24.0),

                    // Color Swatches Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_accentColors.length, (index) {
                        final color = _accentColors[index];
                        final isSelected = index == _selectedColorIndex;

                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedColorIndex = index);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                            width: 36.0,
                            height: 36.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(
                                    alpha: isSelected ? 0.6 : 0.2,
                                  ),
                                  blurRadius: isSelected ? 12.0 : 4.0,
                                  spreadRadius: isSelected ? 2.0 : 0.0,
                                ),
                              ],
                            ),
                            child: isSelected
                                ? const Center(
                                    child: Icon(
                                      Icons.check_rounded,
                                      size: 18.0,
                                      color: Colors.black,
                                    ),
                                  )
                                : null,
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 32.0),

                    // Toggle 1: Liquid effect
                    _buildToggleRow(
                      icon: Icons.water_drop_outlined,
                      title: 'Liquid effect',
                      subtitle: 'Enable smooth liquid animations',
                      value: _liquidEffectEnabled,
                      onChanged: (val) {
                        HapticFeedback.lightImpact();
                        setState(() => _liquidEffectEnabled = val);
                      },
                    ),

                    const SizedBox(height: 14.0),

                    // Toggle 2: Dark mode
                    _buildToggleRow(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark mode',
                      subtitle: 'Always on (AMOLED)',
                      value: _darkModeEnabled,
                      onChanged: (val) {
                        HapticFeedback.lightImpact();
                        setState(() => _darkModeEnabled = val);
                      },
                    ),

                    const SizedBox(height: 14.0),

                    // Toggle 3: Haptic feedback
                    _buildToggleRow(
                      icon: Icons.vibration_rounded,
                      title: 'Haptic feedback',
                      subtitle: 'Gentle touch response',
                      value: _hapticFeedbackEnabled,
                      onChanged: (val) {
                        HapticFeedback.lightImpact();
                        setState(() => _hapticFeedbackEnabled = val);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniatureKeypadPreview(Color accentColor) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['*', '0', '#'],
    ];

    return Center(
      child: Container(
        width: 210.0,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: const Color(0xCC0E1015),
          borderRadius: BorderRadius.circular(28.0),
          border: Border.all(color: const Color(0x40FFFFFF), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x90000000),
              blurRadius: 28.0,
              offset: Offset(0, 10),
            ),
            BoxShadow(
              color: Color(0x18FFFFFF),
              blurRadius: 8.0,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final row in keys) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (final key in row)
                      Container(
                        width: 38.0,
                        height: 38.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF14171E),
                          border: Border.all(
                            color: const Color(0x35FFFFFF),
                            width: 0.8,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x40000000),
                              blurRadius: 6.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            key,
                            style: const TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              color: LiquidColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8.0),
            // Miniature wide pill call button
            Container(
              width: 90.0,
              height: 28.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                gradient: const LinearGradient(
                  colors: [Color(0xFF262C38), Color(0xFF141720)],
                ),
                border: Border.all(color: const Color(0x50FFFFFF), width: 0.9),
              ),
              child: const Center(
                child: Icon(
                  Icons.call_rounded,
                  size: 14.0,
                  color: Color(0xFFF5F5F5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return LiquidSurface(
      level: LiquidSurfaceLevel.card,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x18FFFFFF),
              border: Border.all(color: const Color(0x28FFFFFF), width: 1.0),
            ),
            child: Icon(icon, color: LiquidColors.textPrimary, size: 20.0),
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
          Switch(
            value: value,
            activeThumbColor: const Color(0xFF4ADE80),
            activeTrackColor: const Color(0xFF14341C),
            inactiveThumbColor: LiquidColors.mistGrey,
            inactiveTrackColor: const Color(0xFF1E2028),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
