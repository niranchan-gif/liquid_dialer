import 'package:flutter/material.dart';

import '../../core/theme/glass_styles.dart';
import '../../shared/widgets/glass_icon_button.dart';
import '../../shared/widgets/glass_panel.dart';
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
      backgroundColor: GlassColors.background,
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
                      color: GlassColors.textPrimary,
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
                          : GlassColors.textSecondary,
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

                    // Avatar Card
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 108.0,
                            height: 108.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(
                                colors: [Color(0x2E00E5FF), Colors.transparent],
                              ),
                            ),
                          ),
                          _buildLargeAvatar(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16.0),

                    // Name
                    Text(
                      contact.effectiveName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                        color: GlassColors.textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 28.0),

                    // Numbers Section
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'PHONE NUMBERS',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: GlassColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),

                    if (contact.phones.isEmpty)
                      GlassPanel(
                        padding: const EdgeInsets.all(20.0),
                        child: const Center(
                          child: Text(
                            'No phone numbers registered for this contact.',
                            style: TextStyle(
                              color: GlassColors.textSecondary,
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      )
                    else
                      ...contact.phones.map((phone) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          decoration: BoxDecoration(
                            color: GlassColors.glassFillUltraLight,
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: GlassColors.borderSubtle,
                              width: 1.0,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16.0),
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
                                    Container(
                                      width: 40.0,
                                      height: 40.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: GlassColors.cyanAccent
                                            .withValues(alpha: 0.12),
                                      ),
                                      child: const Icon(
                                        Icons.phone_rounded,
                                        color: GlassColors.cyanAccent,
                                        size: 20.0,
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
                                              color: GlassColors.textPrimary,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 2.0),
                                          Text(
                                            phone.label,
                                            style: const TextStyle(
                                              fontSize: 12.0,
                                              color: GlassColors.textSecondary,
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
                                        color: GlassColors.mintPrimary
                                            .withValues(alpha: 0.15),
                                        border: Border.all(
                                          color: GlassColors.mintPrimary
                                              .withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.dialpad_rounded,
                                            size: 14.0,
                                            color: GlassColors.mintLight,
                                          ),
                                          SizedBox(width: 4.0),
                                          Text(
                                            'Dial',
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w600,
                                              color: GlassColors.mintLight,
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
          border: Border.all(color: GlassColors.borderLight, width: 2.0),
          image: DecorationImage(
            image: MemoryImage(contact.thumbnail!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: 88.0,
      height: 88.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GlassColors.icyBlue.withValues(alpha: 0.3),
            GlassColors.deepViolet.withValues(alpha: 0.2),
          ],
        ),
        border: Border.all(color: GlassColors.borderLight, width: 2.0),
      ),
      child: Center(
        child: Text(
          contact.initials,
          style: const TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.w700,
            color: GlassColors.cyanAccent,
          ),
        ),
      ),
    );
  }
}
