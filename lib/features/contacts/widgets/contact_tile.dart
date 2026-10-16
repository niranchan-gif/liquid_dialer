import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/liquid_theme.dart';
import '../../../shared/widgets/liquid_droplet.dart';
import '../../../shared/widgets/liquid_surface.dart';
import '../models/contact_item.dart';

/// Translucent Liquid Glass contact row item with pure water-droplet styling,
/// prominent caller initials, and direct one-tap call action.
class ContactTile extends StatelessWidget {
  const ContactTile({
    super.key,
    required this.contact,
    required this.onTap,
    required this.onToggleFavorite,
    this.onLongPress,
  });

  final ContactItem contact;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
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
                  // Avatar Droplet (Photo or initials)
                  _buildAvatar(),
                  const SizedBox(width: 14.0),

                  // Name and Phone details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          contact.effectiveName,
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
                        if (contact.primaryPhone.isNotEmpty)
                          Row(
                            children: [
                              if (contact.phones.isNotEmpty &&
                                  contact.phones.first.label.isNotEmpty) ...[
                                Text(
                                  contact.phones.first.label,
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
                                  contact.primaryPhone,
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

                  // Direct Call Action Button (One-tap call without numpad)
                  if (contact.primaryPhone.isNotEmpty)
                    GestureDetector(
                      key: Key('callButton_${contact.id}'),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onTap();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 38.0,
                        height: 38.0,
                        margin: const EdgeInsets.only(right: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF142419),
                          border: Border.all(
                            color: const Color(0x5534D399),
                            width: 1.0,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x2534D399),
                              blurRadius: 10.0,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.phone_rounded,
                            color: Color(0xFF4ADE80),
                            size: 18.0,
                          ),
                        ),
                      ),
                    ),

                  // Favorite Star Button
                  IconButton(
                    key: Key('favoriteButton_${contact.id}'),
                    icon: Icon(
                      contact.isFavorite
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: contact.isFavorite
                          ? const Color(0xFFFFB800)
                          : LiquidColors.textMuted.withValues(alpha: 0.6),
                      size: 22.0,
                    ),
                    tooltip: contact.isFavorite
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
    if (contact.thumbnail != null && contact.thumbnail!.isNotEmpty) {
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
            image: MemoryImage(contact.thumbnail!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return LiquidDroplet(
      size: 44.0,
      child: Center(
        child: Text(
          contact.initials,
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
