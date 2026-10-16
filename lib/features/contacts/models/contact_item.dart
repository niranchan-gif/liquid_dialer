import 'dart:typed_data';

/// Represents an individual phone number associated with a contact.
class ContactPhone {
  const ContactPhone({required this.number, this.label = 'Mobile'});

  final String number;
  final String label;

  /// Strips whitespace, hyphens, parentheses, and other non-dialable symbols for search.
  String get normalizedDigits {
    final cleaned = number.replaceAll(RegExp(r'[^\d+]'), '');
    return cleaned;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactPhone &&
          runtimeType == other.runtimeType &&
          number == other.number &&
          label == other.label;

  @override
  int get hashCode => number.hashCode ^ label.hashCode;
}

/// Represents a contact item formatted for Liquid Glass UI and search indexing.
class ContactItem implements Comparable<ContactItem> {
  const ContactItem({
    required this.id,
    required this.displayName,
    this.phones = const [],
    this.thumbnail,
    this.isFavorite = false,
  });

  final String id;
  final String displayName;
  final List<ContactPhone> phones;
  final Uint8List? thumbnail;
  final bool isFavorite;

  /// Effective readable label, falling back when the contact has no name.
  String get effectiveName {
    final trimmed = displayName.trim();
    if (trimmed.isNotEmpty) return trimmed;
    if (phones.isNotEmpty && phones.first.number.trim().isNotEmpty) {
      return phones.first.number.trim();
    }
    return 'Unnamed Contact';
  }

  /// Primary phone number or empty string if no numbers available.
  String get primaryPhone {
    if (phones.isEmpty) return '';
    return phones.first.number;
  }

  /// Extracted initials for fallback avatar rendering (e.g. "JD" for "John Doe").
  String get initials {
    final name = effectiveName;
    final parts = name
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '#';
    if (parts.length == 1) {
      final first = parts[0];
      return first.isNotEmpty ? first[0].toUpperCase() : '#';
    }
    final firstChar = parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
    final lastChar = parts[parts.length - 1].isNotEmpty
        ? parts[parts.length - 1][0].toUpperCase()
        : '';
    final result = '$firstChar$lastChar'.trim();
    return result.isNotEmpty ? result : '#';
  }

  /// Evaluates whether this contact satisfies a user's search query.
  ///
  /// Supports:
  /// - Case-insensitive partial name match
  /// - Phone number matching that ignores harmless symbols (spaces, dashes, parentheses).
  bool matchesSearch(String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return true;

    // 1. Name match
    if (effectiveName.toLowerCase().contains(cleanQuery)) {
      return true;
    }

    // 2. Normalized phone number match
    final queryDigits = cleanQuery.replaceAll(RegExp(r'[^\d+]'), '');
    for (final phone in phones) {
      if (phone.number.toLowerCase().contains(cleanQuery)) {
        return true;
      }
      if (queryDigits.isNotEmpty &&
          phone.normalizedDigits.contains(queryDigits)) {
        return true;
      }
    }

    return false;
  }

  ContactItem copyWith({
    String? id,
    String? displayName,
    List<ContactPhone>? phones,
    Uint8List? thumbnail,
    bool? isFavorite,
  }) {
    return ContactItem(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      phones: phones ?? this.phones,
      thumbnail: thumbnail ?? this.thumbnail,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  int compareTo(ContactItem other) {
    final thisName = effectiveName.toLowerCase();
    final otherName = other.effectiveName.toLowerCase();
    return thisName.compareTo(otherName);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          displayName == other.displayName &&
          isFavorite == other.isFavorite;

  @override
  int get hashCode => id.hashCode ^ displayName.hashCode ^ isFavorite.hashCode;
}
