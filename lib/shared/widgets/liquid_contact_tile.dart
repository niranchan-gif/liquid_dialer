import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/liquid_theme.dart';
import 'liquid_button.dart';
import 'liquid_droplet.dart';
import 'liquid_surface.dart';

/// Tactile, water-droplet styled contact tile for the pure liquid AMOLED design system.
///
/// Features a subtle graphite liquid surface with a specular top edge reflection,
/// a curved droplet avatar, and direct one-tap call action.
class LiquidContactTile extends StatelessWidget {
  const LiquidContactTile({
    super.key,
    required this.name,
    required this.phone,
    this.phoneLabel,
    this.initials = '?',
    this.thumbnail,
    this.isFavorite = false,
    required this.onTap,
    this.onCallTap,
    this.onToggleFavorite,
    this.onLongPress,
  });

  final String name;
  final String phone;
  final String? phoneLabel;
  final String initials;
  final Uint8List? thumbnail;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback? onCallTap;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: LiquidSurface(
        level: LiquidSurfaceLevel.card,
        borderRadius: BorderRadius.circular(16.0),
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16.0),
            splashColor: const Color(0x18FFFFFF),
            highlightColor: const Color(0x0CFFFFFF),
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            onLongPress: onLongPress != null
                ? () {
                    HapticFeedback.mediumImpact();
                    onLongPress!();
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 11.0,
              ),
              child: Row(
                children: [
                  // Avatar droplet
                  _buildAvatar(),
                  const SizedBox(width: 14.0),

                  // Name and phone details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: LiquidColors.textPrimary,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 3.0),
                        if (phone.isNotEmpty)
                          Row(
                            children: [
                              if (phoneLabel != null &&
                                  phoneLabel!.isNotEmpty) ...[
                                Text(
                                  phoneLabel!,
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500,
                                    color: LiquidColors.mistGrey,
                                  ),
                                ),
                                const SizedBox(width: 6.0),
                                Container(
                                  width: 3.0,
                                  height: 3.0,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: LiquidColors.textMuted,
                                  ),
                                ),
                                const SizedBox(width: 6.0),
                              ],
                              Expanded(
                                child: Text(
                                  phone,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13.0,
                                    color: LiquidColors.textSecondary,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          const Text(
                            'No phone number',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontStyle: FontStyle.italic,
                              color: LiquidColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Direct Call Action Droplet Button
                  if (phone.isNotEmpty && onCallTap != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: LiquidButton(
                        onTap: onCallTap!,
                        theme: LiquidButtonTheme.callGreen,
                        isCircle: true,
                        width: 38.0,
                        height: 38.0,
                        child: const Icon(
                          Icons.phone_rounded,
                          color: Color(0xFF4ADE80),
                          size: 18.0,
                        ),
                      ),
                    ),

                  // Favorite Star Button
                  if (onToggleFavorite != null)
                    IconButton(
                      icon: Icon(
                        isFavorite
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: isFavorite
                            ? const Color(0xFFFFB800)
                            : LiquidColors.textMuted.withValues(alpha: 0.6),
                        size: 22.0,
                      ),
                      tooltip: isFavorite
                          ? 'Remove from favorites'
                          : 'Add to favorites',
                      onPressed: onToggleFavorite,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (thumbnail != null && thumbnail!.isNotEmpty) {
      return Container(
        width: 44.0,
        height: 44.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: LiquidColors.specularMeniscus.withValues(alpha: 0.3),
            width: 1.0,
          ),
          image: DecorationImage(
            image: MemoryImage(thumbnail!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return LiquidDroplet(
      size: 44.0,
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
            color: LiquidColors.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
