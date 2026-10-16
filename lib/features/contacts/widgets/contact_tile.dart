import 'package:flutter/material.dart';

import '../../../core/theme/glass_styles.dart';
import '../models/contact_item.dart';

/// Translucent Liquid Glass contact row item optimized for long scrolling lists.
class ContactTile extends StatelessWidget {
  const ContactTile({
    super.key,
    required this.contact,
    required this.onTap,
    required this.onToggleFavorite,
  });

  final ContactItem contact;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: GlassColors.glassFillUltraLight,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: GlassColors.borderSubtle, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          splashColor: GlassColors.cyanAccent.withValues(alpha: 0.08),
          highlightColor: GlassColors.glassFillLight,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                // Avatar (Photo or initials)
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
                          color: GlassColors.textPrimary,
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
                                  color: GlassColors.icyBlue,
                                ),
                              ),
                              const SizedBox(width: 6.0),
                              Container(
                                width: 3.0,
                                height: 3.0,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: GlassColors.textMuted,
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
                                  color: GlassColors.textSecondary,
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
                            color: GlassColors.textMuted,
                          ),
                        ),
                    ],
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
                        : GlassColors.textMuted.withValues(alpha: 0.6),
                    size: 24.0,
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
    );
  }

  Widget _buildAvatar() {
    if (contact.thumbnail != null && contact.thumbnail!.isNotEmpty) {
      return Container(
        width: 44.0,
        height: 44.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: GlassColors.borderLight, width: 1.0),
          image: DecorationImage(
            image: MemoryImage(contact.thumbnail!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: 44.0,
      height: 44.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GlassColors.icyBlue.withValues(alpha: 0.25),
            GlassColors.softViolet.withValues(alpha: 0.15),
          ],
        ),
        border: Border.all(color: GlassColors.borderLight, width: 1.0),
      ),
      child: Center(
        child: Text(
          contact.initials,
          style: const TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.w700,
            color: GlassColors.cyanAccent,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
