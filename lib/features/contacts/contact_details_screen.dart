import 'package:flutter/material.dart';

import '../../core/theme/liquid_theme.dart';
import '../../shared/widgets/glass_icon_button.dart';
import '../../shared/widgets/liquid_droplet.dart';
import '../../shared/widgets/liquid_surface.dart';
import 'models/contact_item.dart';

/// Detailed view displaying all phone numbers, labels, avatar, and keypad forwarding for a contact.
class ContactDetailsScreen extends StatefulWidget {
  const ContactDetailsScreen({
    super.key,
    required this.contact,
    required this.onSelectNumber,
    required this.onToggleFavorite,
  });

  final ContactItem contact;
  final ValueChanged<String> onSelectNumber;
  final Future<void> Function(ContactItem contact) onToggleFavorite;

  @override
  State<ContactDetailsScreen> createState() => _ContactDetailsScreenState();
}

class _ContactDetailsScreenState extends State<ContactDetailsScreen> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.contact.isFavorite;
  }

  Future<void> _handleToggleFavorite() async {
    setState(() => _isFavorite = !_isFavorite);
    await widget.onToggleFavorite(widget.contact);
  }

  @override
  Widget build(BuildContext context) {
    final contact = widget.contact;

    return Scaffold(
      backgroundColor: LiquidColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GlassIconButton(
                    key: const Key('contactDetailsBackButton'),
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const Text(
                    'Contact Details',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: LiquidColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    key: const Key('contactDetailsFavoriteButton'),
                    icon: Icon(
                      _isFavorite
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: _isFavorite
                          ? const Color(0xFFFFB800)
                          : LiquidColors.textSecondary,
                      size: 26.0,
                    ),
                    tooltip: _isFavorite
                        ? 'Remove favorite'
                        : 'Add to favorites',
                    onPressed: _handleToggleFavorite,
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16.0),

                    // Avatar Droplet
                    Center(child: _buildLargeAvatar()),

                    const SizedBox(height: 16.0),

                    // Name
                    Text(
                      contact.effectiveName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                        color: LiquidColors.textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 28.0),

                    // Numbers Section
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'PHONE NUMBERS',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: LiquidColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),

                    if (contact.phones.isEmpty)
                      LiquidSurface(
                        level: LiquidSurfaceLevel.card,
                        padding: const EdgeInsets.all(20.0),
                        child: const Center(
                          child: Text(
                            'No phone numbers registered for this contact.',
                            style: TextStyle(
                              color: LiquidColors.textSecondary,
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      )
                    else
                      ...contact.phones.map((phone) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
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
                                  widget.onSelectNumber(phone.number);
                                  Navigator.of(context).pop();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 14.0,
                                  ),
                                  child: Row(
                                    children: [
                                      LiquidDroplet(
                                        size: 40.0,
                                        child: const Center(
                                          child: Icon(
                                            Icons.phone_rounded,
                                            color: LiquidColors.silverHighlight,
                                            size: 20.0,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              phone.number,
                                              style: const TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w600,
                                                color: LiquidColors.textPrimary,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 2.0),
                                            Text(
                                              phone.label,
                                              style: const TextStyle(
                                                fontSize: 12.0,
                                                color:
                                                    LiquidColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0,
                                          vertical: 6.0,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12.0,
                                          ),
                                          color: const Color(0xFF142419),
                                          border: Border.all(
                                            color: const Color(0x554EBE88),
                                            width: 1.0,
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.call_rounded,
                                              size: 14.0,
                                              color: Color(0xFF4ADE80),
                                            ),
                                            SizedBox(width: 5.0),
                                            Text(
                                              'Call',
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF4ADE80),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeAvatar() {
    final contact = widget.contact;
    if (contact.thumbnail != null && contact.thumbnail!.isNotEmpty) {
      return Container(
        width: 88.0,
        height: 88.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: LiquidColors.specularMeniscus.withValues(alpha: 0.3),
            width: 1.5,
          ),
          image: DecorationImage(
            image: MemoryImage(contact.thumbnail!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return LiquidDroplet(
      size: 88.0,
      child: Center(
        child: Text(
          contact.initials,
          style: const TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.w700,
            color: LiquidColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
