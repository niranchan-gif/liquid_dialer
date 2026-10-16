import 'package:flutter/material.dart';

import '../../core/theme/liquid_theme.dart';
import '../../shared/widgets/glass_icon_button.dart';
import '../../shared/widgets/liquid_droplet.dart';
import '../../shared/widgets/liquid_loading_indicator.dart';
import '../../shared/widgets/liquid_surface.dart';
import '../settings/settings_screen.dart';
import 'contact_details_screen.dart';
import 'controllers/contacts_controller.dart';
import 'models/contact_item.dart';
import 'widgets/contact_permission_panel.dart';
import 'widgets/contact_search_field.dart';
import 'widgets/contact_tile.dart';
import 'widgets/favorite_contacts_section.dart';

/// Full-featured Liquid Glass contacts screen managing real device contacts,
/// local favorites, fast search, and dialer integration.
class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key, this.controller, this.onSelectNumber});

  final ContactsController? controller;
  final ValueChanged<String>? onSelectNumber;

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  late final ContactsController _controller;
  late final TextEditingController _searchController;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = ContactsController();
      _ownsController = true;
    }
    _searchController = TextEditingController();

    // Check permission or load contacts upon navigating to this screen
    _controller.initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _openContactDetails(ContactItem contact) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ContactDetailsScreen(
          contact: contact,
          onToggleFavorite: _controller.toggleFavorite,
          onSelectNumber: (number) {
            widget.onSelectNumber?.call(number);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SizedBox.expand(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12.0),

                  // Header with Title and Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Contacts',
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                          color: LiquidColors.textPrimary,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_controller.isPermissionGranted)
                            GlassIconButton(
                              key: const Key('contactsRefreshButton'),
                              icon: Icons.refresh_rounded,
                              tooltip: 'Refresh contacts',
                              onTap: () =>
                                  _controller.loadContacts(forceReload: true),
                            ),
                          const SizedBox(width: 8.0),
                          GlassIconButton(
                            key: const Key('contactsSettingsButton'),
                            icon: Icons.tune_rounded,
                            tooltip: 'Settings',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const SettingsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 14.0),

                  // Search Bar (rendered when permission is granted)
                  if (_controller.isPermissionGranted) ...[
                    ContactSearchField(
                      controller: _searchController,
                      onChanged: _controller.setSearchQuery,
                      onClear: _controller.clearSearch,
                    ),
                    const SizedBox(height: 14.0),
                  ],

                  // Main Body State
                  Expanded(child: _buildBodyContent()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBodyContent() {
    // 1. Loading State
    if (_controller.isLoading && _controller.allContacts.isEmpty) {
      return const Center(
        child: LiquidLoadingIndicator(label: 'Loading contacts...'),
      );
    }

    // 2. Permission Denied / Not Requested State
    if (!_controller.isPermissionGranted) {
      return ContactPermissionPanel(
        status: _controller.permissionStatus,
        onRequestPermission: _controller.requestPermissionAndLoad,
        onOpenSettings: _controller.openAppSettings,
      );
    }

    // 3. Error State
    if (_controller.errorMessage != null && _controller.allContacts.isEmpty) {
      return Center(
        child: LiquidSurface(
          level: LiquidSurfaceLevel.card,
          margin: const EdgeInsets.symmetric(horizontal: 12.0),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 40.0,
                color: LiquidColors.callRed,
              ),
              const SizedBox(height: 14.0),
              const Text(
                'Failed to Load Contacts',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: LiquidColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                _controller.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.0,
                  color: LiquidColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18.0),
              ElevatedButton.icon(
                key: const Key('contactsRetryButton'),
                onPressed: () => _controller.loadContacts(forceReload: true),
                icon: const Icon(Icons.refresh_rounded, size: 16.0),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: LiquidColors.silverHighlight,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 4. Device has 0 contacts
    if (_controller.isEmpty) {
      return Center(
        child: LiquidSurface(
          level: LiquidSurfaceLevel.card,
          margin: const EdgeInsets.symmetric(horizontal: 12.0),
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LiquidDroplet(
                size: 60.0,
                child: const Center(
                  child: Icon(
                    Icons.person_off_rounded,
                    size: 28.0,
                    color: LiquidColors.silverHighlight,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'No Contacts Found',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: LiquidColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'There are no contacts stored on this device.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.0,
                  color: LiquidColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 5. Search Yielded 0 Matches
    if (_controller.isSearchEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 42.0,
              color: LiquidColors.textMuted,
            ),
            const SizedBox(height: 12.0),
            Text(
              'No matches for "${_controller.searchQuery}"',
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: LiquidColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6.0),
            const Text(
              'Check name spelling or digits.',
              style: TextStyle(fontSize: 13.0, color: LiquidColors.textMuted),
            ),
          ],
        ),
      );
    }

    // 6. Active Contacts List with Favorites Section
    final contacts = _controller.filteredContacts;
    final showFavorites =
        !_controller.hasSearchQuery && _controller.favoriteContacts.isNotEmpty;

    return RefreshIndicator(
      color: LiquidColors.silverHighlight,
      backgroundColor: LiquidColors.surfaceElevated,
      onRefresh: () => _controller.loadContacts(forceReload: true),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.only(bottom: 90.0),
        itemCount: contacts.length + (showFavorites ? 1 : 0),
        itemBuilder: (context, index) {
          if (showFavorites && index == 0) {
            return FavoriteContactsSection(
              favorites: _controller.favoriteContacts,
              onContactTap: (contact) {
                if (contact.primaryPhone.isNotEmpty) {
                  widget.onSelectNumber?.call(contact.primaryPhone);
                } else {
                  _openContactDetails(contact);
                }
              },
            );
          }

          final contactIndex = showFavorites ? index - 1 : index;
          final contact = contacts[contactIndex];

          return ContactTile(
            key: Key('contactTile_${contact.id}'),
            contact: contact,
            onTap: () {
              if (contact.primaryPhone.isNotEmpty) {
                widget.onSelectNumber?.call(contact.primaryPhone);
              } else {
                _openContactDetails(contact);
              }
            },
            onLongPress: () => _openContactDetails(contact),
            onToggleFavorite: () => _controller.toggleFavorite(contact),
          );
        },
      ),
    );
  }
}
