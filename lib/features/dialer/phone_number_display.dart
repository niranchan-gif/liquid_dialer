import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/liquid_theme.dart';
import '../../shared/widgets/liquid_droplet.dart';
import '../../shared/widgets/liquid_surface.dart';
import '../contacts/utils/phone_number_matcher.dart';
import 'dialer_controller.dart';

/// Premium AMOLED phone-number display with live contact matching,
/// pure water-droplet suggestion chips, centered typography, and dedicated backspace control.
///
/// Exactly matches the reference design:
/// - Floating contact match chip with avatar, name, number, and 'x' clear button.
/// - Crisp, centered soft white phone number digits.
/// - Direct-call suggestion list when multiple contacts match entered digits.
class PhoneNumberDisplay extends StatelessWidget {
  const PhoneNumberDisplay({
    super.key,
    required this.controller,
    this.matchedContactName,
    this.onCallSuggestion,
  });

  final DialerController controller;
  final String? matchedContactName;
  final ValueChanged<String>? onCallSuggestion;

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
                  context: context,
                  hasNumber: hasNumber,
                  primaryMatch: primaryMatch,
                  suggestionsCount: suggestions.length,
                ),
              ),

              const SizedBox(height: 6.0),

              // Main number row with centered typography and dedicated backspace
              // Main number row with centered typography matching reference image
              Center(
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
                            ? LiquidColors.textPrimary
                            : LiquidColors.textMuted.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                ),
              ),

              // Multiple matching contacts suggestion chip strip / dropdown
              if (hasNumber && suggestions.length > 1) ...[
                const SizedBox(height: 8.0),
                _buildSuggestionsDropdown(context, suggestions),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactInfo({
    required BuildContext context,
    required bool hasNumber,
    required MatchedContact? primaryMatch,
    required int suggestionsCount,
  }) {
    if (!hasNumber) {
      return const SizedBox(height: 24.0);
    }

    if (primaryMatch != null) {
      return LiquidSurface(
        key: ValueKey<String>('match_${primaryMatch.contact.id}'),
        level: LiquidSurfaceLevel.card,
        borderRadius: BorderRadius.circular(20.0),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            LiquidDroplet(
              size: 26.0,
              child: Center(
                child: Text(
                  primaryMatch.contact.initials,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: LiquidColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8.0),

            // Name
            Flexible(
              child: Text(
                primaryMatch.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: LiquidColors.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(width: 8.0),

            // Phone
            Text(
              primaryMatch.phoneNumber,
              style: const TextStyle(
                color: LiquidColors.textSecondary,
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
                  color: LiquidColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: LiquidColors.specularMeniscus.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  '+${suggestionsCount - 1}',
                  style: const TextStyle(
                    color: LiquidColors.silverHighlight,
                    fontSize: 10.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],

            const SizedBox(width: 4.0),

            // Clear 'x' button
            GestureDetector(
              key: const Key('deleteButton'),
              onTap: () {
                HapticFeedback.lightImpact();
                controller.deleteDigit();
              },
              onLongPress: () {
                HapticFeedback.mediumImpact();
                controller.clearNumber();
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 22.0,
                height: 22.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: LiquidColors.surfaceElevated,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 13.0,
                  color: LiquidColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Fallback when no contact match is found for entered digits
    final fallbackText = matchedContactName ?? 'Unknown number';
    return SizedBox(
      key: ValueKey<String>('fallback_$fallbackText'),
      height: 24.0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.help_outline_rounded,
            size: 13.0,
            color: LiquidColors.textMuted.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 5.0),
          Text(
            fallbackText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: LiquidColors.textSecondary,
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 8.0),
          GestureDetector(
            key: const Key('deleteButton'),
            onTap: () {
              HapticFeedback.lightImpact();
              controller.deleteDigit();
            },
            onLongPress: () {
              HapticFeedback.mediumImpact();
              controller.clearNumber();
            },
            behavior: HitTestBehavior.opaque,
            child: const Icon(
              Icons.backspace_outlined,
              size: 14.0,
              color: LiquidColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsDropdown(
    BuildContext context,
    List<MatchedContact> suggestions,
  ) {
    // Renders up to 3 vertical suggestions with direct Call buttons matching CONTACT SUGGESTIONS screen
    final displayed = suggestions.take(3).toList();

    return LiquidSurface(
      level: LiquidSurfaceLevel.card,
      borderRadius: BorderRadius.circular(16.0),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: displayed.map((match) {
          return InkWell(
            onTap: () => controller.selectSuggestion(match),
            borderRadius: BorderRadius.circular(12.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 6.0,
              ),
              child: Row(
                children: [
                  LiquidDroplet(
                    size: 32.0,
                    child: Center(
                      child: Text(
                        match.contact.initials,
                        style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: LiquidColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: LiquidColors.textPrimary,
                            fontSize: 13.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          match.phoneNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: LiquidColors.textSecondary,
                            fontSize: 11.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Direct call button on suggestion item
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      controller.selectSuggestion(match);
                      controller.call();
                    },
                    child: Container(
                      width: 32.0,
                      height: 32.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF16251A),
                        border: Border.all(
                          color: const Color(0x4034D399),
                          width: 1.0,
                        ),
                      ),
                      child: const Icon(
                        Icons.phone_rounded,
                        color: Color(0xFF4ADE80),
                        size: 16.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
