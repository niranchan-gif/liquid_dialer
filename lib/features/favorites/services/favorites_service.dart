import 'package:shared_preferences/shared_preferences.dart';

/// Contract for managing and persisting contact favorite selections locally.
abstract class FavoritesService {
  Future<Set<String>> getFavoriteContactIds();
  Future<void> addFavorite(String contactId);
  Future<void> removeFavorite(String contactId);
  Future<bool> toggleFavorite(String contactId);
  Future<bool> isFavorite(String contactId);
}

/// SharedPreferences-backed local persistence for favorite contact IDs.
class SharedPreferencesFavoritesService implements FavoritesService {
  SharedPreferencesFavoritesService({this.preferences});

  static const String _storageKey = 'liquid_dialer_favorite_contact_ids';
  SharedPreferences? preferences;

  Future<SharedPreferences> _getPrefs() async {
    return preferences ??= await SharedPreferences.getInstance();
  }

  @override
  Future<Set<String>> getFavoriteContactIds() async {
    final prefs = await _getPrefs();
    final list = prefs.getStringList(_storageKey) ?? [];
    return list.toSet();
  }

  @override
  Future<void> addFavorite(String contactId) async {
    if (contactId.trim().isEmpty) return;
    final prefs = await _getPrefs();
    final favorites = (prefs.getStringList(_storageKey) ?? []).toSet();
    if (favorites.add(contactId)) {
      await prefs.setStringList(_storageKey, favorites.toList());
    }
  }

  @override
  Future<void> removeFavorite(String contactId) async {
    final prefs = await _getPrefs();
    final favorites = (prefs.getStringList(_storageKey) ?? []).toSet();
    if (favorites.remove(contactId)) {
      await prefs.setStringList(_storageKey, favorites.toList());
    }
  }

  @override
  Future<bool> toggleFavorite(String contactId) async {
    final prefs = await _getPrefs();
    final favorites = (prefs.getStringList(_storageKey) ?? []).toSet();
    final isFav = favorites.contains(contactId);
    if (isFav) {
      favorites.remove(contactId);
    } else {
      favorites.add(contactId);
    }
    await prefs.setStringList(_storageKey, favorites.toList());
    return !isFav;
  }

  @override
  Future<bool> isFavorite(String contactId) async {
    final ids = await getFavoriteContactIds();
    return ids.contains(contactId);
  }
}

/// In-memory implementation for deterministic testing and preview environments.
class InMemoryFavoritesService implements FavoritesService {
  InMemoryFavoritesService([Set<String>? initialIds])
    : _favorites = initialIds != null
          ? Set<String>.from(initialIds)
          : <String>{};

  final Set<String> _favorites;

  @override
  Future<Set<String>> getFavoriteContactIds() async {
    return Set<String>.from(_favorites);
  }

  @override
  Future<void> addFavorite(String contactId) async {
    if (contactId.trim().isNotEmpty) {
      _favorites.add(contactId);
    }
  }

  @override
  Future<void> removeFavorite(String contactId) async {
    _favorites.remove(contactId);
  }

  @override
  Future<bool> toggleFavorite(String contactId) async {
    if (_favorites.contains(contactId)) {
      _favorites.remove(contactId);
      return false;
    } else {
      _favorites.add(contactId);
      return true;
    }
  }

  @override
  Future<bool> isFavorite(String contactId) async {
    return _favorites.contains(contactId);
  }
}
