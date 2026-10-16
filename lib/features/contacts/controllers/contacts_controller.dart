import 'package:flutter/foundation.dart';

import '../../../core/permissions/phone_permissions_service.dart';
import '../../favorites/services/favorites_service.dart';
import '../models/contact_item.dart';
import '../services/contacts_service.dart';

/// State controller managing contacts loading, permissions, search filtering, and favorites.
class ContactsController extends ChangeNotifier {
  ContactsController({
    PhonePermissionsService? permissionsService,
    ContactsService? contactsService,
    FavoritesService? favoritesService,
  }) : _permissionsService =
           permissionsService ?? const DevicePhonePermissionsService(),
       _contactsService = contactsService ?? const DeviceContactsService(),
       _favoritesService =
           favoritesService ?? SharedPreferencesFavoritesService();

  final PhonePermissionsService _permissionsService;
  final ContactsService _contactsService;
  final FavoritesService _favoritesService;

  bool _isLoading = false;
  String? _errorMessage;
  AppPermissionStatus _permissionStatus = AppPermissionStatus.denied;
  bool _hasCheckedPermission = false;

  List<ContactItem> _contacts = [];
  List<ContactItem> _filteredContacts = [];
  String _searchQuery = '';

  // Public getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AppPermissionStatus get permissionStatus => _permissionStatus;
  bool get hasCheckedPermission => _hasCheckedPermission;
  bool get isPermissionGranted => _permissionStatus.isGranted;
  bool get isPermanentlyDenied => _permissionStatus.isPermanentlyDenied;

  List<ContactItem> get allContacts => List.unmodifiable(_contacts);
  List<ContactItem> get filteredContacts =>
      List.unmodifiable(_filteredContacts);
  List<ContactItem> get favoriteContacts =>
      _contacts.where((c) => c.isFavorite).toList();
  String get searchQuery => _searchQuery;
  bool get hasSearchQuery => _searchQuery.trim().isNotEmpty;
  bool get isEmpty =>
      _contacts.isEmpty && !_isLoading && _permissionStatus.isGranted;
  bool get isSearchEmpty =>
      hasSearchQuery && _filteredContacts.isEmpty && !_isLoading;

  /// Initializes permission check and loads contacts if already authorized.
  ///
  /// Respects policy by not prompting for permission on application launch.
  Future<void> initialize({bool requestPermission = false}) async {
    if (requestPermission) {
      await requestPermissionAndLoad();
    } else {
      _permissionStatus = await _permissionsService.checkContactsPermission();
      _hasCheckedPermission = true;
      if (_permissionStatus.isGranted) {
        await loadContacts();
      } else {
        notifyListeners();
      }
    }
  }

  /// Explicit user-driven permission request at point of use.
  Future<void> requestPermissionAndLoad() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _permissionStatus = await _permissionsService.requestContactsPermission();
      _hasCheckedPermission = true;

      if (_permissionStatus.isGranted) {
        await _fetchAndIndexContacts();
      } else {
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Unable to request contact permissions: $e';
      notifyListeners();
    }
  }

  /// Refreshes or retrieves contacts from the service and merges local favorites.
  Future<void> loadContacts({bool forceReload = false}) async {
    if (_contacts.isNotEmpty && !forceReload && _permissionStatus.isGranted) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _permissionStatus = await _permissionsService.checkContactsPermission();
      _hasCheckedPermission = true;

      if (!_permissionStatus.isGranted) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      await _fetchAndIndexContacts();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load contacts: $e';
      notifyListeners();
    }
  }

  Future<void> _fetchAndIndexContacts() async {
    final rawContacts = await _contactsService.fetchContacts();
    final favoriteIds = await _favoritesService.getFavoriteContactIds();

    final List<ContactItem> resolved = [];
    for (final contact in rawContacts) {
      final isFav = favoriteIds.contains(contact.id);
      resolved.add(contact.copyWith(isFavorite: isFav));
    }

    resolved.sort();
    _contacts = resolved;
    _applySearchFilter();
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Updates search query and recalculates filtered list.
  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _applySearchFilter();
    notifyListeners();
  }

  /// Clears active search filter.
  void clearSearch() {
    if (_searchQuery.isEmpty) return;
    _searchQuery = '';
    _applySearchFilter();
    notifyListeners();
  }

  void _applySearchFilter() {
    if (_searchQuery.trim().isEmpty) {
      _filteredContacts = List.from(_contacts);
    } else {
      _filteredContacts = _contacts
          .where((c) => c.matchesSearch(_searchQuery))
          .toList();
    }
  }

  /// Toggles favorite status for a contact and persists across app restarts.
  Future<void> toggleFavorite(ContactItem contact) async {
    final newStatus = await _favoritesService.toggleFavorite(contact.id);

    final index = _contacts.indexWhere((c) => c.id == contact.id);
    if (index != -1) {
      _contacts[index] = _contacts[index].copyWith(isFavorite: newStatus);
      _applySearchFilter();
      notifyListeners();
    }
  }

  /// Helper to direct the user to device application settings when permanently denied.
  Future<bool> openAppSettings() async {
    return await _permissionsService.openAppSettings();
  }
}
