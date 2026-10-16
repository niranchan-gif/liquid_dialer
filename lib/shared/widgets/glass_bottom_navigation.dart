import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/glass_styles.dart';

/// Navigation item description for [GlassBottomNavigation].
class GlassNavItem {
  const GlassNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// Floating liquid glass bottom navigation dock.
///
/// Designed with rounded pill aesthetics, backdrop blur, active tab glow,
/// and smooth selection transitions.
class GlassBottomNavigation extends StatelessWidget {
  const GlassBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = defaultItems,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GlassNavItem> items;

  static const List<GlassNavItem> defaultItems = [
    GlassNavItem(
      label: 'Recents',
      icon: Icons.history_rounded,
      activeIcon: Icons.history_rounded,
    ),
    GlassNavItem(
      label: 'Keypad',
      icon: Icons.dialpad_outlined,
      activeIcon: Icons.dialpad_rounded,
    ),
    GlassNavItem(
      label: 'Contacts',
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final effectiveIndex = currentIndex.clamp(0, items.length - 1);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 14.0),
        child: Container(
          height: 66.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(33.0),
            boxShadow: GlassDecorations.subtleShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(33.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: GlassDecorations.defaultBlurSigma,
                sigmaY: GlassDecorations.defaultBlurSigma,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(33.0),
                  gradient: GlassDecorations.panelFillGradient,
                  border: GlassDecorations.specularBorder,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const outerPadHorizontal = 8.0;
                    final availableWidth =
                        constraints.maxWidth - (outerPadHorizontal * 2);
                    final itemWidth = availableWidth / items.length;

                    return Stack(
                      children: [
                        // Sliding Water-Drop Droplet Capsule
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          left:
                              outerPadHorizontal +
                              (itemWidth * effectiveIndex) +
                              4.0,
                          top: 6.0,
                          width: itemWidth - 8.0,
                          height: constraints.maxHeight - 12.0,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24.0),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFF2B2B2B), Color(0xFF151515)],
                              ),
                              border: Border.all(
                                color: const Color(0x38FFFFFF),
                                width: 1.0,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x28FFFFFF),
                                  blurRadius: 12.0,
                                  spreadRadius: 0.5,
                                  offset: Offset(0, 1),
                                ),
                                BoxShadow(
                                  color: Color(0x88000000),
                                  blurRadius: 8.0,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Top specular meniscus line on the sliding drop
                                Positioned(
                                  top: 0,
                                  left: 14.0,
                                  right: 14.0,
                                  height: 1.2,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Color(0x60FFFFFF),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Navigation Items Row
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: outerPadHorizontal,
                            vertical: 4.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(items.length, (index) {
                              final item = items[index];
                              final isSelected = index == effectiveIndex;

                              return Expanded(
                                child: Semantics(
                                  button: true,
                                  selected: isSelected,
                                  label: item.label,
                                  child: GestureDetector(
                                    key: Key('nav_${item.label.toLowerCase()}'),
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      if (!isSelected) {
                                        HapticFeedback.selectionClick();
                                        onTap(index);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0,
                                        vertical: 6.0,
                                      ),
                                      color: Colors.transparent,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          AnimatedScale(
                                            scale: isSelected ? 1.08 : 1.0,
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            curve: Curves.easeOutCubic,
                                            child: Icon(
                                              isSelected
                                                  ? item.activeIcon
                                                  : item.icon,
                                              size: 22.0,
                                              color: isSelected
                                                  ? GlassColors.silverHighlight
                                                  : GlassColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 3.0),
                                          AnimatedDefaultTextStyle(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            curve: Curves.easeOutCubic,
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: isSelected
                                                  ? GlassColors.textPrimary
                                                  : GlassColors.textSecondary,
                                              fontSize: 11.0,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                              letterSpacing: 0.2,
                                            ),
                                            child: Text(
                                              item.label,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
