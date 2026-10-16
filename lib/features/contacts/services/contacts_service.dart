import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;

import '../models/contact_item.dart';

/// Abstract service providing contacts retrieval to keep UI decoupled from platform plugins.
abstract class ContactsService {
  Future<List<ContactItem>> fetchContacts();
}

/// Real device contacts service using the flutter_contacts package.
class DeviceContactsService implements ContactsService {
  const DeviceContactsService();

  @override
  Future<List<ContactItem>> fetchContacts() async {
    // Query contacts with phone properties and thumbnails for low-memory overhead
    final deviceContacts = await fc.FlutterContacts.getAll(
      properties: {
        fc.ContactProperty.name,
        fc.ContactProperty.phone,
        fc.ContactProperty.photoThumbnail,
      },
    );

    final List<ContactItem> items = [];

    for (final contact in deviceContacts) {
      final List<ContactPhone> uniquePhones = [];
      final Set<String> seenNumbers = {};

      for (final phone in contact.phones) {
        final cleanNumber = phone.number.trim();
        if (cleanNumber.isNotEmpty && seenNumbers.add(cleanNumber)) {
          final labelString = _formatPhoneLabel(phone.label.label);
          uniquePhones.add(
            ContactPhone(number: cleanNumber, label: labelString),
          );
        }
      }

      final item = ContactItem(
        id: (contact.id != null && contact.id!.isNotEmpty)
            ? contact.id!
            : UniqueKey().toString(),
        displayName: contact.displayName?.trim() ?? '',
        phones: uniquePhones,
        thumbnail: contact.photo?.thumbnail ?? contact.photo?.fullSize,
      );

      items.add(item);
    }

    // Sort alphabetically by effective name (case-insensitive)
    items.sort();
    return items;
  }

  String _formatPhoneLabel(fc.PhoneLabel label) {
    switch (label) {
      case fc.PhoneLabel.home:
        return 'Home';
      case fc.PhoneLabel.work:
        return 'Work';
      case fc.PhoneLabel.mobile:
      case fc.PhoneLabel.iPhone:
        return 'Mobile';
      case fc.PhoneLabel.main:
      case fc.PhoneLabel.companyMain:
        return 'Main';
      case fc.PhoneLabel.pager:
      case fc.PhoneLabel.workPager:
        return 'Pager';
      case fc.PhoneLabel.workMobile:
        return 'Work Mobile';
      case fc.PhoneLabel.school:
        return 'School';
      case fc.PhoneLabel.car:
        return 'Car';
      case fc.PhoneLabel.homeFax:
        return 'Home Fax';
      case fc.PhoneLabel.workFax:
        return 'Work Fax';
      default:
        return 'Other';
    }
  }
}

/// Mock contacts service for unit tests and widget tests.
class MockContactsService implements ContactsService {
  MockContactsService({List<ContactItem>? contacts, this.shouldThrow = false})
    : _contacts = contacts ?? [];

  final List<ContactItem> _contacts;
  final bool shouldThrow;

  @override
  Future<List<ContactItem>> fetchContacts() async {
    if (shouldThrow) {
      throw Exception('Failed to access contacts from device storage.');
    }
    final list = List<ContactItem>.from(_contacts);
    list.sort();
    return list;
  }
}
