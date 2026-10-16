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
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [Color(0x20FFFFFF), Colors.transparent],
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
                    const Align(
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
                      const GlassPanel(
                        padding: EdgeInsets.all(20.0),
                        child: Center(
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
                            color: const Color(0xFF101010),
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: const Color(0x1AFFFFFF),
                              width: 1.0,
                            ),
                          ),
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
                                    Container(
                                      width: 40.0,
                                      height: 40.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF1B1B1B),
                                        border: Border.all(
                                          color: const Color(0x28FFFFFF),
                                          width: 1.0,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.phone_rounded,
                                        color: GlassColors.textPrimary,
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
                                        color: const Color(0xFF172B1E),
                                        border: Border.all(
                                          color: const Color(0x444EBE88),
                                          width: 1.0,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.call_rounded,
                                            size: 14.0,
                                            color: Color(0xFF5CD898),
                                          ),
                                          SizedBox(width: 5.0),
                                          Text(
                                            'Call',
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF5CD898),
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
          border: Border.all(color: const Color(0x35FFFFFF), width: 1.5),
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF242424), Color(0xFF141414)],
        ),
        border: Border.all(color: const Color(0x35FFFFFF), width: 1.5),
      ),
      child: Center(
        child: Text(
          contact.initials,
          style: const TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.w700,
            color: GlassColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
