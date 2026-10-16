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
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(33.0),
                  gradient: GlassDecorations.panelFillGradient,
                  border: GlassDecorations.specularBorder,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    final isSelected = index == currentIndex;

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
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 6.0,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24.0),
                              color: isSelected
                                  ? GlassColors.cardFill
                                  : Colors.transparent,
                              border: isSelected
                                  ? Border.all(
                                      color: GlassColors.silverAccent
                                          .withValues(alpha: 0.28),
                                      width: 1.0,
                                    )
                                  : Border.all(
                                      color: Colors.transparent,
                                      width: 1.0,
                                    ),
                              boxShadow: isSelected
                                  ? GlassDecorations.tabActiveGlow
                                  : null,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isSelected ? item.activeIcon : item.icon,
                                  size: 22.0,
                                  color: isSelected
                                      ? GlassColors.silverHighlight
                                      : GlassColors.textSecondary,
                                ),
                                const SizedBox(height: 3.0),
                                Text(
                                  item.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isSelected
                                        ? GlassColors.textPrimary
                                        : GlassColors.textSecondary,
                                    fontSize: 11.0,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    letterSpacing: 0.2,
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
            ),
          ),
        ),
      ),
    );
  }
}
