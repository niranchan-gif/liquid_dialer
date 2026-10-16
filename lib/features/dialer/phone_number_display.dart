import 'package:flutter/material.dart';

import '../../core/theme/glass_styles.dart';
import '../../shared/widgets/glass_icon_button.dart';
import '../contacts/utils/phone_number_matcher.dart';
import 'dialer_controller.dart';

/// Premium AMOLED phone-number display with live contact matching,
/// suggestion chips, centered typography, and dedicated backspace control.
class PhoneNumberDisplay extends StatelessWidget {
  const PhoneNumberDisplay({
    super.key,
    required this.controller,
    this.matchedContactName,
  });

  final DialerController controller;

  /// Optional override/fallback contact matching name.
  final String? matchedContactName;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final formatted = controller.formattedNumber;
        final hasNumber = controller.hasNumber;
        final primaryMatch = controller.primaryMatchedContact;
        final suggestions = controller.matchedSuggestions;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
          constraints: const BoxConstraints(minHeight: 88.0),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Contact Match / Live Suggestion Area
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, -0.15),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _buildContactInfo(
                  hasNumber: hasNumber,
                  primaryMatch: primaryMatch,
                  suggestionsCount: suggestions.length,
                ),
              ),

              const SizedBox(height: 6.0),

              // Main number row with centered typography and dedicated backspace
              Row(
                children: [
                  // Left spacer to ensure entered number remains precisely centered
                  const SizedBox(width: 44.0),

                  // Center phone number display
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 150),
                          child: Text(
                            hasNumber ? formatted : 'Enter a number',
                            key: ValueKey<String>(
                              hasNumber ? formatted : 'placeholder',
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 34.0,
                              fontWeight: hasNumber
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              letterSpacing: hasNumber ? 1.4 : 0.5,
                              color: hasNumber
                                  ? GlassColors.textPrimary
                                  : GlassColors.textMuted.withValues(
                                      alpha: 0.55,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Dedicated delete / backspace button
                  SizedBox(
                    width: 44.0,
                    child: AnimatedOpacity(
                      opacity: hasNumber ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 180),
                      child: IgnorePointer(
                        ignoring: !hasNumber,
                        child: GlassIconButton(
                          key: const Key('deleteButton'),
                          icon: Icons.backspace_outlined,
                          size: 42.0,
                          iconSize: 20.0,
                          iconColor: GlassColors.textSecondary,
                          tooltip: 'Delete',
                          semanticLabel: 'Delete one digit, hold to clear all',
                          onTap: () => controller.deleteDigit(),
                          onLongPress: () => controller.clearNumber(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Multiple matching contacts suggestion chip strip
              if (hasNumber && suggestions.length > 1) ...[
                const SizedBox(height: 6.0),
                _buildSuggestionsStrip(suggestions),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactInfo({
    required bool hasNumber,
    required MatchedContact? primaryMatch,
    required int suggestionsCount,
  }) {
    if (!hasNumber) {
      return const SizedBox(height: 22.0);
    }

    if (primaryMatch != null) {
      return Container(
        key: ValueKey<String>('match_${primaryMatch.contact.id}'),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: GlassColors.surfaceMid.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: GlassColors.borderSubtle.withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_rounded,
              size: 15.0,
              color: GlassColors.silverAccent.withValues(alpha: 0.85),
            ),
            const SizedBox(width: 6.0),
            Flexible(
              child: Text(
                primaryMatch.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: GlassColors.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Text(
              primaryMatch.phoneNumber,
              style: const TextStyle(
                color: GlassColors.textSecondary,
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (suggestionsCount > 1) ...[
              const SizedBox(width: 6.0),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5.0,
                  vertical: 1.5,
                ),
                decoration: BoxDecoration(
                  color: GlassColors.cardFill,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: GlassColors.borderLight,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  '+${suggestionsCount - 1}',
                  style: const TextStyle(
                    color: GlassColors.silverHighlight,
                    fontSize: 10.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    // Fallback when no contact match is found for entered digits
    final fallbackText = matchedContactName ?? 'Unknown number';
    return SizedBox(
      key: ValueKey<String>('fallback_$fallbackText'),
      height: 22.0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.help_outline_rounded,
            size: 13.0,
            color: GlassColors.textMuted.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 5.0),
          Text(
            fallbackText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: GlassColors.textSecondary,
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsStrip(List<MatchedContact> suggestions) {
    return SizedBox(
      height: 26.0,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: suggestions.length,
        separatorBuilder: (_, index) => const SizedBox(width: 6.0),
        itemBuilder: (context, index) {
          final match = suggestions[index];
          final isSelected = index == 0;

          return GestureDetector(
            onTap: () => controller.selectSuggestion(match),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 3.0,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? GlassColors.cardFill
                    : GlassColors.surfaceDark.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: isSelected
                      ? GlassColors.silverSubtle.withValues(alpha: 0.6)
                      : GlassColors.borderSubtle,
                  width: 0.9,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    match.displayName,
                    style: TextStyle(
                      color: isSelected
                          ? GlassColors.textPrimary
                          : GlassColors.textSecondary,
                      fontSize: 11.0,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    match.phoneNumber,
                    style: TextStyle(
                      color: GlassColors.textMuted,
                      fontSize: 10.0,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
