import 'package:flutter/material.dart';

import '../../../core/theme/glass_styles.dart';

/// Polished Liquid Glass search field for filtering contacts.
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
        color: GlassColors.glassFillLight,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: GlassColors.borderSubtle, width: 1.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            size: 20.0,
            color: GlassColors.icyBlue,
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: TextField(
              key: const Key('contactSearchInput'),
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 15.0,
                color: GlassColors.textPrimary,
                fontWeight: FontWeight.w400,
              ),
              cursorColor: GlassColors.cyanAccent,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  fontSize: 14.0,
                  color: GlassColors.textMuted.withValues(alpha: 0.8),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              key: const Key('contactSearchClearButton'),
              onTap: () {
                controller.clear();
                onClear();
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(4.0),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: GlassColors.glassFillLight,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16.0,
                  color: GlassColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
