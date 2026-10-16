import '../models/contact_item.dart';

/// Represents a matched contact associated with the specific phone number that matched.
class MatchedContact {
  const MatchedContact({
    required this.contact,
    required this.matchedPhone,
    required this.isExactMatch,
  });

  final ContactItem contact;
  final ContactPhone matchedPhone;
  final bool isExactMatch;

  String get displayName => contact.effectiveName;
  String get phoneNumber => matchedPhone.number;
  String get phoneLabel => matchedPhone.label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchedContact &&
          runtimeType == other.runtimeType &&
          contact.id == other.contact.id &&
          matchedPhone.number == other.matchedPhone.number;

  @override
  int get hashCode => contact.id.hashCode ^ matchedPhone.number.hashCode;
}

/// Phone number matching utility for live dialer entry against device contacts.
///
/// Supports exact normalized comparisons, international country code variations (+91, +1, etc.),
/// national trunk prefixes (0), and partial substring suggestions.
class PhoneNumberMatcher {
  PhoneNumberMatcher._();

  /// Extracts pure digits for comparison while stripping formatting symbols.
  static String normalizeDigits(String? phone) {
    if (phone == null) return '';
    return phone.replaceAll(RegExp(r'\D'), '');
  }

  /// Evaluates whether [query] matches [contact], returning a [MatchedContact] if a match is found.
  static MatchedContact? matchContact(String query, ContactItem contact) {
    final cleanQuery = normalizeDigits(query);
    if (cleanQuery.isEmpty) return null;

    MatchedContact? bestPartialMatch;

    for (final phone in contact.phones) {
      final cleanPhone = normalizeDigits(phone.number);
      if (cleanPhone.isEmpty) continue;

      // 1. Identical normalized digits -> Exact Match
      if (cleanPhone == cleanQuery) {
        return MatchedContact(
          contact: contact,
          matchedPhone: phone,
          isExactMatch: true,
        );
      }

      // 2. International prefix / Trunk prefix tolerance (>= 7 digits)
      // E.g., Contact is +91 98765 43210 (digits: 919876543210), Query is 9876543210
      // Or Contact is 98765 43210, Query is +91 98765 43210
      if (cleanQuery.length >= 7) {
        if (cleanPhone.endsWith(cleanQuery) ||
            cleanQuery.endsWith(cleanPhone)) {
          return MatchedContact(
            contact: contact,
            matchedPhone: phone,
            isExactMatch: true,
          );
        }
      }

      // 3. Partial substring match for live typing suggestions (>= 2 digits)
      if (cleanQuery.length >= 2) {
        if (cleanPhone.contains(cleanQuery)) {
          bestPartialMatch ??= MatchedContact(
            contact: contact,
            matchedPhone: phone,
            isExactMatch: false,
          );
        }
      }
    }

    return bestPartialMatch;
  }

  /// Searches a collection of contacts and returns matching results, sorted with exact matches first.
  static List<MatchedContact> findMatches(
    String query,
    Iterable<ContactItem> contacts,
  ) {
    final cleanQuery = normalizeDigits(query);
    if (cleanQuery.isEmpty) return const [];

    final List<MatchedContact> exactMatches = [];
    final List<MatchedContact> partialMatches = [];
    final Set<String> seenContactIds = {};

    for (final contact in contacts) {
      final match = matchContact(query, contact);
      if (match != null && seenContactIds.add(contact.id)) {
        if (match.isExactMatch) {
          exactMatches.add(match);
        } else {
          partialMatches.add(match);
        }
      }
    }

    // Sort: exact matches first, then partial matches by display name
    exactMatches.sort((a, b) => a.displayName.compareTo(b.displayName));
    partialMatches.sort((a, b) => a.displayName.compareTo(b.displayName));

    return [...exactMatches, ...partialMatches];
  }
}
