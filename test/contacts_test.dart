import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_dialer/core/permissions/phone_permissions_service.dart';
import 'package:liquid_dialer/features/contacts/contacts_screen.dart';
import 'package:liquid_dialer/features/contacts/controllers/contacts_controller.dart';
import 'package:liquid_dialer/features/contacts/models/contact_item.dart';
import 'package:liquid_dialer/features/contacts/services/contacts_service.dart';
import 'package:liquid_dialer/features/contacts/widgets/favorite_contacts_section.dart';
import 'package:liquid_dialer/features/favorites/services/favorites_service.dart';

class MockPhonePermissionsService implements PhonePermissionsService {
  MockPhonePermissionsService({
    this.contactsStatus = AppPermissionStatus.granted,
    this.callLogStatus = AppPermissionStatus.granted,
  });

  AppPermissionStatus contactsStatus;
  AppPermissionStatus callLogStatus;
  bool requestedContacts = false;
  bool requestedCallLog = false;
  bool openedSettings = false;

  @override
  Future<AppPermissionStatus> checkContactsPermission() async => contactsStatus;

  @override
  Future<AppPermissionStatus> requestContactsPermission() async {
    requestedContacts = true;
    return contactsStatus;
  }

  @override
  Future<AppPermissionStatus> checkCallLogPermission() async => callLogStatus;

  @override
  Future<AppPermissionStatus> requestCallLogPermission() async {
    requestedCallLog = true;
    return callLogStatus;
  }

  @override
  Future<AppPermissionStatus> checkCallPhonePermission() async =>
      contactsStatus;

  @override
  Future<AppPermissionStatus> requestCallPhonePermission() async =>
      contactsStatus;

  @override
  Future<AppPermissionStatus> checkNotificationPermission() async =>
      contactsStatus;

  @override
  Future<AppPermissionStatus> requestNotificationPermission() async =>
      contactsStatus;

  @override
  Future<bool> openAppSettings() async {
    openedSettings = true;
    return true;
  }
}

void main() {
  group('Contacts & Favorites Unit and Widget Tests', () {
    late MockPhonePermissionsService permissionsService;
    late InMemoryFavoritesService favoritesService;

    setUp(() {
      permissionsService = MockPhonePermissionsService();
      favoritesService = InMemoryFavoritesService();
    });

    test('1. Contact sorting orders contacts alphabetically by name', () async {
      final contacts = [
        const ContactItem(
          id: '1',
          displayName: 'Zack Taylor',
          phones: [ContactPhone(number: '111')],
        ),
        const ContactItem(
          id: '2',
          displayName: 'Alice Cooper',
          phones: [ContactPhone(number: '222')],
        ),
        const ContactItem(
          id: '3',
          displayName: 'bob marley',
          phones: [ContactPhone(number: '333')],
        ),
      ];

      final contactsService = MockContactsService(contacts: contacts);
      final controller = ContactsController(
        permissionsService: permissionsService,
        contactsService: contactsService,
        favoritesService: favoritesService,
      );

      await controller.loadContacts();

      expect(controller.allContacts[0].displayName, 'Alice Cooper');
      expect(controller.allContacts[1].displayName, 'bob marley');
      expect(controller.allContacts[2].displayName, 'Zack Taylor');
    });

    test('2. Search matches contact names case-insensitively', () async {
      final contacts = [
        const ContactItem(
          id: '1',
          displayName: 'Alexander Graham',
          phones: [ContactPhone(number: '1234567890')],
        ),
        const ContactItem(
          id: '2',
          displayName: 'Beth Harmon',
          phones: [ContactPhone(number: '9876543210')],
        ),
      ];

      final controller = ContactsController(
        permissionsService: permissionsService,
        contactsService: MockContactsService(contacts: contacts),
        favoritesService: favoritesService,
      );

      await controller.loadContacts();

      controller.setSearchQuery('alex');
      expect(controller.filteredContacts.length, 1);
      expect(controller.filteredContacts.first.displayName, 'Alexander Graham');

      controller.setSearchQuery('BETH');
      expect(controller.filteredContacts.length, 1);
      expect(controller.filteredContacts.first.displayName, 'Beth Harmon');
    });

    test(
      '3. Search matches phone numbers with formatting differences',
      () async {
        final contacts = [
          const ContactItem(
            id: '1',
            displayName: 'OnePlus Support',
            phones: [ContactPhone(number: '+1 (800) 555-0199')],
          ),
          const ContactItem(
            id: '2',
            displayName: 'Local Pizza',
            phones: [ContactPhone(number: '555-1234')],
          ),
        ];

        final controller = ContactsController(
          permissionsService: permissionsService,
          contactsService: MockContactsService(contacts: contacts),
          favoritesService: favoritesService,
        );

        await controller.loadContacts();

        // Search with raw unformatted digits
        controller.setSearchQuery('8005550199');
        expect(controller.filteredContacts.length, 1);
        expect(
          controller.filteredContacts.first.displayName,
          'OnePlus Support',
        );

        // Search with partial formatted string
        controller.setSearchQuery('(800) 555');
        expect(controller.filteredContacts.length, 1);
        expect(
          controller.filteredContacts.first.displayName,
          'OnePlus Support',
        );

        // Search second contact digits
        controller.setSearchQuery('5551234');
        expect(controller.filteredContacts.length, 1);
        expect(controller.filteredContacts.first.displayName, 'Local Pizza');
      },
    );

    test('4. Contacts without phone numbers are handled gracefully', () async {
      final contactWithoutPhone = const ContactItem(
        id: 'no_phone',
        displayName: 'Ghost Contact',
        phones: [],
      );

      expect(contactWithoutPhone.primaryPhone, '');
      expect(contactWithoutPhone.effectiveName, 'Ghost Contact');
      expect(contactWithoutPhone.matchesSearch('Ghost'), isTrue);
      expect(contactWithoutPhone.matchesSearch('123'), isFalse);
    });

    test('5. Contacts without photos display initials properly', () {
      final twoWords = const ContactItem(
        id: '1',
        displayName: 'John Doe',
        phones: [],
      );
      final singleWord = const ContactItem(
        id: '2',
        displayName: 'Cher',
        phones: [],
      );
      final emptyName = const ContactItem(
        id: '3',
        displayName: '',
        phones: [ContactPhone(number: '+123456')],
      );
      final noNameNoPhone = const ContactItem(
        id: '4',
        displayName: '',
        phones: [],
      );

      expect(twoWords.initials, 'JD');
      expect(singleWord.initials, 'C');
      expect(emptyName.initials, '+');
      expect(noNameNoPhone.initials, 'UC'); // 'Unnamed Contact' initials
    });

    test('6. Empty contact results and clearSearch work correctly', () async {
      final contacts = [
        const ContactItem(
          id: '1',
          displayName: 'David Miller',
          phones: [ContactPhone(number: '4444')],
        ),
      ];

      final controller = ContactsController(
        permissionsService: permissionsService,
        contactsService: MockContactsService(contacts: contacts),
        favoritesService: favoritesService,
      );

      await controller.loadContacts();

      controller.setSearchQuery('XYZ_NON_EXISTENT');
      expect(controller.filteredContacts.isEmpty, isTrue);
      expect(controller.isSearchEmpty, isTrue);

      controller.clearSearch();
      expect(controller.searchQuery, '');
      expect(controller.filteredContacts.length, 1);
      expect(controller.isSearchEmpty, isFalse);
    });

    test('7. Adding and removing favorites updates state', () async {
      final contact = const ContactItem(
        id: 'fav_1',
        displayName: 'Sarah Connor',
        phones: [ContactPhone(number: '9999')],
      );

      final controller = ContactsController(
        permissionsService: permissionsService,
        contactsService: MockContactsService(contacts: [contact]),
        favoritesService: favoritesService,
      );

      await controller.loadContacts();
      expect(controller.favoriteContacts, isEmpty);

      // Add to favorite
      await controller.toggleFavorite(contact);
      expect(controller.favoriteContacts.length, 1);
      expect(controller.favoriteContacts.first.id, 'fav_1');
      expect(controller.allContacts.first.isFavorite, isTrue);

      // Remove from favorite
      await controller.toggleFavorite(controller.allContacts.first);
      expect(controller.favoriteContacts, isEmpty);
      expect(controller.allContacts.first.isFavorite, isFalse);
    });

    test('8. Favorites persist across service reloads', () async {
      final contact = const ContactItem(
        id: 'persisted_1',
        displayName: 'Elena Fisher',
        phones: [ContactPhone(number: '7777')],
      );

      // First controller session
      final controller1 = ContactsController(
        permissionsService: permissionsService,
        contactsService: MockContactsService(contacts: [contact]),
        favoritesService: favoritesService,
      );
      await controller1.loadContacts();
      await controller1.toggleFavorite(contact);

      // Second controller session using the same favorites service
      final controller2 = ContactsController(
        permissionsService: permissionsService,
        contactsService: MockContactsService(contacts: [contact]),
        favoritesService: favoritesService,
      );
      await controller2.loadContacts();

      expect(controller2.favoriteContacts.length, 1);
      expect(controller2.favoriteContacts.first.id, 'persisted_1');
      expect(controller2.favoriteContacts.first.isFavorite, isTrue);
    });

    test(
      '9. Missing or deleted favorite contacts are handled gracefully',
      () async {
        // Simulate stored favorite ID for a contact that no longer exists on the device
        await favoritesService.addFavorite('deleted_contact_id');

        final existingContact = const ContactItem(
          id: 'real_contact_id',
          displayName: 'Nathan Drake',
          phones: [ContactPhone(number: '123')],
        );

        final controller = ContactsController(
          permissionsService: permissionsService,
          contactsService: MockContactsService(contacts: [existingContact]),
          favoritesService: favoritesService,
        );

        // Should not throw or crash
        await controller.loadContacts();

        expect(controller.allContacts.length, 1);
        expect(controller.favoriteContacts.isEmpty, isTrue);
      },
    );

    test('10. Permission-denied and permanently denied states', () async {
      permissionsService.contactsStatus = AppPermissionStatus.denied;

      final controller = ContactsController(
        permissionsService: permissionsService,
        contactsService: MockContactsService(),
        favoritesService: favoritesService,
      );

      await controller.initialize();
      expect(controller.isPermissionGranted, isFalse);
      expect(controller.isPermanentlyDenied, isFalse);

      // User triggers permission request
      permissionsService.contactsStatus = AppPermissionStatus.permanentlyDenied;
      await controller.requestPermissionAndLoad();

      expect(controller.isPermissionGranted, isFalse);
      expect(controller.isPermanentlyDenied, isTrue);

      // Open app settings
      await controller.openAppSettings();
      expect(permissionsService.openedSettings, isTrue);
    });

    test('11. Loading and error states with retry action', () async {
      final controller = ContactsController(
        permissionsService: permissionsService,
        contactsService: MockContactsService(shouldThrow: true),
        favoritesService: favoritesService,
      );

      await controller.loadContacts();
      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNotNull);
      expect(controller.errorMessage, contains('Failed to load contacts'));
    });

    testWidgets(
      '12. ContactsScreen renders search, favorites, and contact tiles',
      (tester) async {
        final contacts = [
          const ContactItem(
            id: '1',
            displayName: 'Ada Lovelace',
            phones: [ContactPhone(number: '101010', label: 'Work')],
            isFavorite: true,
          ),
          const ContactItem(
            id: '2',
            displayName: 'Charles Babbage',
            phones: [ContactPhone(number: '202020', label: 'Mobile')],
            isFavorite: false,
          ),
        ];

        final controller = ContactsController(
          permissionsService: permissionsService,
          contactsService: MockContactsService(contacts: contacts),
          favoritesService: InMemoryFavoritesService({'1'}),
        );

        String? selectedNumber;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ContactsScreen(
                controller: controller,
                onSelectNumber: (phone) => selectedNumber = phone,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify Header
        expect(find.text('Contacts'), findsOneWidget);

        // Verify Favorites Section
        expect(find.byType(FavoriteContactsSection), findsOneWidget);
        expect(find.text('FAVORITES'), findsOneWidget);

        // Verify Contact Tiles
        expect(find.text('Ada Lovelace'), findsWidgets);
        expect(find.text('Charles Babbage'), findsOneWidget);

        // Tap single-number contact: populates onSelectNumber
        await tester.tap(find.byKey(const Key('contactTile_2')));
        await tester.pumpAndSettle();
        expect(selectedNumber, '202020');
      },
    );
  });
}
