import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/liquid_theme.dart';

/// Pure Liquid search field with specular water meniscus and clear action for filtering contacts.
class ContactSearchField extends StatelessWidget {
  const ContactSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.hintText = 'Search contacts by name or number...',
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.0,
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: LiquidColors.borderMedium, width: 1.0),
        boxShadow: LiquidDecorations.subtleDepth,
      ),
      child: Stack(
        children: [
          // Top specular meniscus light
          Positioned(
            top: 0,
            left: 14.0,
            right: 14.0,
            height: 1.2,
            child: Container(
              decoration: LiquidDecorations.meniscusDecoration(opacity: 0.45),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  size: 20.0,
                  color: LiquidColors.silverSecondary,
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: TextField(
                    key: const Key('contactSearchInput'),
                    controller: controller,
                    onChanged: onChanged,
                    style: const TextStyle(
                      fontSize: 15.0,
                      color: LiquidColors.textPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                    cursorColor: LiquidColors.silverPrimary,
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: TextStyle(
                        fontSize: 14.0,
                        color: LiquidColors.textMuted.withValues(alpha: 0.8),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                      ),
                    ),
                  ),
                ),
                if (controller.text.isNotEmpty)
                  GestureDetector(
                    key: const Key('contactSearchClearButton'),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      controller.clear();
                      onClear();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF202020),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16.0,
                        color: LiquidColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
