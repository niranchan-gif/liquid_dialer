import 'package:flutter/foundation.dart';

import '../../core/permissions/phone_permissions_service.dart';
import '../../core/platform/dialer_bridge.dart';
import '../contacts/models/contact_item.dart';
import '../contacts/services/contacts_service.dart';
import '../contacts/utils/phone_number_matcher.dart';

/// Service interface to isolate calling functionality for Phase 3 integration.
abstract class CallService {
  /// Attempt an outgoing call or return user feedback.
  Future<String> placeCall(String phoneNumber);
}

/// Native Android Telecom call service utilizing DialerBridge.
class NativeCallService implements CallService {
  const NativeCallService({this.bridge});

  final DialerBridge? bridge;

  DialerBridge get activeBridge => bridge ?? DialerBridge.instance;

  @override
  Future<String> placeCall(String phoneNumber) async {
    final trimmed = phoneNumber.trim();
    if (trimmed.isEmpty) {
      return 'Please enter a phone number to call.';
    }
    final result = await activeBridge.placeCall(phoneNumber);
    return result.message;
  }
}

/// Phase 1 placeholder call service.
class MockCallService implements CallService {
  const MockCallService();

  @override
  Future<String> placeCall(String phoneNumber) async {
    return 'Calling is not available yet.';
  }
}

/// State controller for phone number entry, deletion, calling logic,
/// and live device contact matching.
class DialerController extends ChangeNotifier {
  DialerController({
    CallService? callService,
    ContactsService? contactsService,
    PhonePermissionsService? permissionsService,
  }) : _callService = callService ?? const NativeCallService(),
       _contactsService = contactsService ?? const DeviceContactsService(),
       _permissionsService =
           permissionsService ?? const DevicePhonePermissionsService();

  final CallService _callService;
  final ContactsService _contactsService;
  final PhonePermissionsService _permissionsService;

  String _rawNumber = '';
  String? _lastCallFeedback;
  bool _isPlacingCall = false;

  List<ContactItem> _contactsCache = [];
  bool _hasAttemptedContactLoad = false;
  MatchedContact? _primaryMatchedContact;
  List<MatchedContact> _matchedSuggestions = const [];

  /// Whether a call initiation request is currently in-flight.
  bool get isPlacingCall => _isPlacingCall;

  /// The raw input string containing digits and symbols ('*', '#', '+').
  String get rawNumber => _rawNumber;

  /// Whether any characters have been entered.
  bool get hasNumber => _rawNumber.isNotEmpty;

  /// The most recent feedback message from a call action.
  String? get lastCallFeedback => _lastCallFeedback;

  /// Primary contact matched to the currently entered phone number, if any.
  MatchedContact? get primaryMatchedContact => _primaryMatchedContact;

  /// List of contacts matching the current entry (exact matches prioritized).
  List<MatchedContact> get matchedSuggestions => _matchedSuggestions;

  /// Whether at least one device contact matches the entered number.
  bool get hasContactMatch => _primaryMatchedContact != null;

  /// Unmodifiable view of currently cached device contacts.
  List<ContactItem> get contactsCache => List.unmodifiable(_contactsCache);

  /// Pre-loads or directly injects device contacts (useful for testing and instant matching).
  void setContactsCache(List<ContactItem> contacts) {
    _contactsCache = List.from(contacts);
    _hasAttemptedContactLoad = true;
    _updateContactMatches();
    notifyListeners();
  }

  /// Updates contact matching against cached contacts and triggers lazy load if permitted.
  void _updateContactMatches() {
    if (_rawNumber.isEmpty) {
      _primaryMatchedContact = null;
      _matchedSuggestions = const [];
      return;
    }

    if (_contactsCache.isEmpty && !_hasAttemptedContactLoad) {
      _lazyLoadContacts();
    }

    final matches = PhoneNumberMatcher.findMatches(_rawNumber, _contactsCache);
    if (matches.isNotEmpty) {
      _primaryMatchedContact = matches.first;
      _matchedSuggestions = matches;
    } else {
      _primaryMatchedContact = null;
      _matchedSuggestions = const [];
    }
  }

  /// Background lazy loader that checks permission without UI block before loading contacts.
  Future<void> _lazyLoadContacts() async {
    _hasAttemptedContactLoad = true;
    try {
      final status = await _permissionsService.checkContactsPermission();
      if (status.isGranted) {
        final contacts = await _contactsService.fetchContacts();
        _contactsCache = contacts;
        _updateContactMatches();
        notifyListeners();
      }
    } catch (_) {
      // Gracefully handle permission denials or storage read failures
    }
  }

  /// Formatted phone number for presentation with readable grouping.
  ///
  /// Separates display formatting from internal state to avoid cursor corruption.
  String get formattedNumber {
    if (_rawNumber.isEmpty) return '';

    // If it contains symbols like * or #, keep raw layout for USSD/codes
    if (_rawNumber.contains('*') || _rawNumber.contains('#')) {
      return _rawNumber;
    }

    final hasPlus = _rawNumber.startsWith('+');
    final digits = hasPlus ? _rawNumber.substring(1) : _rawNumber;

    if (digits.isEmpty) {
      return '+';
    }

    // Standard digit grouping (e.g. 3-3-4 or 1-3-3-4)
    final buffer = StringBuffer(hasPlus ? '+' : '');
    final len = digits.length;

    if (len <= 3) {
      buffer.write(digits);
    } else if (len <= 7) {
      buffer.write('${digits.substring(0, 3)} ${digits.substring(3)}');
    } else if (len <= 10) {
      buffer.write(
        '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}',
      );
    } else if (len == 11) {
      buffer.write(
        '${digits.substring(0, 1)} ${digits.substring(1, 4)} ${digits.substring(4, 7)} ${digits.substring(7)}',
      );
    } else {
      // Long international format: chunks of 3-4
      buffer.write('${digits.substring(0, 3)} ');
      int i = 3;
      while (i < len) {
        final remaining = len - i;
        final chunkSize = remaining > 4 ? 3 : remaining;
        buffer.write(digits.substring(i, i + chunkSize));
        i += chunkSize;
        if (i < len) buffer.write(' ');
      }
    }

    return buffer.toString();
  }

  /// Appends a digit or dialer symbol ('0'-'9', '*', '#', '+').
  void appendDigit(String character) {
    if (character.isEmpty) return;
    _rawNumber += character;
    _updateContactMatches();
    notifyListeners();
  }

  /// Removes the last entered character if present.
  void deleteDigit() {
    if (_rawNumber.isNotEmpty) {
      _rawNumber = _rawNumber.substring(0, _rawNumber.length - 1);
      _updateContactMatches();
      notifyListeners();
    }
  }

  /// Clears the complete entered number.
  void clearNumber() {
    if (_rawNumber.isNotEmpty) {
      _rawNumber = '';
      _updateContactMatches();
      notifyListeners();
    }
  }

  /// Sets the dialer phone number directly from a selected contact or call history item.
  ///
  /// Replaces the current entry cleanly without duplicating characters or formatting glitches.
  void setNumber(String phoneNumber) {
    final sanitized = phoneNumber.replaceAll(RegExp(r'[^\d+*#]'), '');
    _rawNumber = sanitized;
    _updateContactMatches();
    notifyListeners();
  }

  /// Selects a matched contact suggestion, updating the dialer number to the matched phone number.
  void selectSuggestion(MatchedContact match) {
    setNumber(match.phoneNumber);
  }

  /// Triggers a call attempt via the configured [CallService].
  ///
  /// Prevents duplicate in-flight requests and captures status feedback.
  Future<String> call() async {
    if (_isPlacingCall) {
      return 'A call request is already in progress.';
    }

    _isPlacingCall = true;
    notifyListeners();

    try {
      final message = await _callService.placeCall(_rawNumber);
      _lastCallFeedback = message;
      _isPlacingCall = false;
      notifyListeners();
      return message;
    } catch (e) {
      final message = 'Call failed: $e';
      _lastCallFeedback = message;
      _isPlacingCall = false;
      notifyListeners();
      return message;
    }
  }
}
