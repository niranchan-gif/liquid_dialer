import 'package:flutter/material.dart';

import '../../../core/theme/glass_styles.dart';
import '../models/contact_item.dart';

/// Horizontal favorites carousel rendered at the top of the Contacts screen.
class FavoriteContactsSection extends StatelessWidget {
  const FavoriteContactsSection({
    super.key,
    required this.favorites,
    required this.onContactTap,
  });

  final List<ContactItem> favorites;
  final ValueChanged<ContactItem> onContactTap;

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            children: [
              const Icon(
                Icons.star_rounded,
                size: 18.0,
                color: Color(0xFFFFB800),
              ),
              const SizedBox(width: 6.0),
              const Text(
                'FAVORITES',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: GlassColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7.0,
                  vertical: 2.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: const Color(0xFF161616),
                  border: Border.all(
                    color: const Color(0x22FFFFFF),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  '${favorites.length}',
                  style: const TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                    color: GlassColors.silverHighlight,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 96.0,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: favorites.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12.0),
            itemBuilder: (context, index) {
              final contact = favorites[index];
              return _FavoriteTile(
                contact: contact,
                onTap: () => onContactTap(contact),
              );
            },
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile({required this.contact, required this.onTap});

  final ContactItem contact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key('favoriteItem_${contact.id}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      splashColor: const Color(0x18FFFFFF),
      highlightColor: const Color(0x0CFFFFFF),
      child: Container(
        width: 72.0,
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Avatar
                _buildAvatar(),
                // Star badge
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF141414),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(3.0),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFFB800),
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        size: 10.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6.0),
            Text(
              contact.effectiveName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.w500,
                color: GlassColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (contact.thumbnail != null && contact.thumbnail!.isNotEmpty) {
      return Container(
        width: 50.0,
        height: 50.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0x66FFB800), width: 1.5),
          image: DecorationImage(
            image: MemoryImage(contact.thumbnail!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: 50.0,
      height: 50.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF242424), Color(0xFF141414)],
        ),
        border: Border.all(color: const Color(0x80FFB800), width: 1.5),
      ),
      child: Center(
        child: Text(
          contact.initials,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
            color: GlassColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
