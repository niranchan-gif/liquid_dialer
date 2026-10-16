import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_dialer/core/permissions/phone_permissions_service.dart';
import 'package:liquid_dialer/core/theme/glass_styles.dart';
import 'package:liquid_dialer/features/contacts/models/contact_item.dart';
import 'package:liquid_dialer/features/contacts/services/contacts_service.dart';
import 'package:liquid_dialer/features/contacts/utils/phone_number_matcher.dart';
import 'package:liquid_dialer/features/dialer/dialer_controller.dart';
import 'package:liquid_dialer/features/dialer/dialer_keypad.dart';
import 'package:liquid_dialer/features/dialer/phone_number_display.dart';
import 'package:liquid_dialer/shared/widgets/glass_key.dart';

void main() {
  group('AMOLED Liquid Redesign & Live Contact Matching Tests', () {
    late DialerController controller;
    late List<ContactItem> sampleContacts;

    setUp(() {
      sampleContacts = [
        const ContactItem(
          id: 'contact_1',
          displayName: 'Arun Kumar',
          phones: [
            ContactPhone(number: '+91 98765 43210', label: 'Mobile'),
            ContactPhone(number: '044 2828 1234', label: 'Work'),
          ],
        ),
        const ContactItem(
          id: 'contact_2',
          displayName: 'Ananya Sharma',
          phones: [ContactPhone(number: '+91 98765 99999', label: 'Mobile')],
        ),
        const ContactItem(
          id: 'contact_3',
          displayName: 'Vikram Singh',
          phones: [ContactPhone(number: '+1 (555) 234-5678', label: 'Home')],
        ),
      ];

      controller = DialerController(
        callService: const MockCallService(),
        contactsService: MockContactsService(contacts: sampleContacts),
      );
      controller.setContactsCache(sampleContacts);
    });

    test(
      '1. Number normalization handles international formatting differences',
      () {
        expect(
          PhoneNumberMatcher.normalizeDigits('+91 98765 43210'),
          '919876543210',
        );
        expect(
          PhoneNumberMatcher.normalizeDigits('+1 (555) 234-5678'),
          '15552345678',
        );
        expect(
          PhoneNumberMatcher.normalizeDigits('044-2828-1234'),
          '04428281234',
        );
        expect(PhoneNumberMatcher.normalizeDigits(null), '');
      },
    );

    test(
      '2. Exact contact match across international prefix and local entry',
      () {
        // User types local 10 digits without +91
        controller.setNumber('9876543210');
        expect(controller.hasContactMatch, isTrue);
        expect(controller.primaryMatchedContact!.displayName, 'Arun Kumar');
        expect(
          controller.primaryMatchedContact!.phoneNumber,
          '+91 98765 43210',
        );
        expect(controller.primaryMatchedContact!.isExactMatch, isTrue);

        // User types with +91
        controller.setNumber('+919876543210');
        expect(controller.hasContactMatch, isTrue);
        expect(controller.primaryMatchedContact!.displayName, 'Arun Kumar');
      },
    );

    test('3. Partial matching and multiple matches prioritization', () {
      // 98765 matches both Arun Kumar (98765 43210) and Ananya Sharma (98765 99999)
      controller.setNumber('98765');
      expect(controller.hasContactMatch, isTrue);
      expect(controller.matchedSuggestions.length, 2);

      final names = controller.matchedSuggestions
          .map((m) => m.displayName)
          .toList();
      expect(names, containsAll(['Ananya Sharma', 'Arun Kumar']));

      // Selecting suggestion replaces number with full phone number
      final ananyaMatch = controller.matchedSuggestions.firstWhere(
        (m) => m.displayName == 'Ananya Sharma',
      );
      controller.selectSuggestion(ananyaMatch);
      expect(controller.rawNumber, '+919876599999');
    });

    test('4. Empty input and non-matching fallback', () {
      controller.clearNumber();
      expect(controller.hasNumber, isFalse);
      expect(controller.hasContactMatch, isFalse);
      expect(controller.primaryMatchedContact, isNull);
      expect(controller.matchedSuggestions, isEmpty);

      // Number not in contacts
      controller.setNumber('1234567890');
      expect(controller.hasNumber, isTrue);
      expect(controller.hasContactMatch, isFalse);
      expect(controller.primaryMatchedContact, isNull);
      expect(controller.matchedSuggestions, isEmpty);
    });

    test('5. Rapid digit entry and deletion without stale suggestions', () {
      // Rapid sequence
      controller.appendDigit('9');
      controller.appendDigit('8');
      controller.appendDigit('7');
      controller.appendDigit('6');
      controller.appendDigit('5');
      expect(controller.hasContactMatch, isTrue);

      controller.appendDigit('0');
      controller.appendDigit('0'); // 9876500 (no match)
      expect(controller.hasContactMatch, isFalse);

      controller.deleteDigit();
      controller.deleteDigit(); // Back to 98765 (matches)
      expect(controller.hasContactMatch, isTrue);
      expect(controller.primaryMatchedContact!.displayName, isNotEmpty);

      controller.clearNumber();
      expect(controller.hasContactMatch, isFalse);
      expect(controller.primaryMatchedContact, isNull);
    });

    test('6. Contacts permission denied handles gracefully', () async {
      final deniedController = DialerController(
        callService: const MockCallService(),
        contactsService: MockContactsService(contacts: sampleContacts),
        permissionsService: const _AlwaysDeniedPermissionsService(),
      );

      // Does not throw and does not crash when digits are typed
      deniedController.appendDigit('9');
      deniedController.appendDigit('8');
      deniedController.appendDigit('7');
      expect(deniedController.hasContactMatch, isFalse);
      expect(deniedController.rawNumber, '987');
    });

    testWidgets(
      '7. PhoneNumberDisplay shows matched contact and delete interactions',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: Center(child: PhoneNumberDisplay(controller: controller)),
            ),
          ),
        );

        // Initially empty placeholder
        expect(find.text('Enter a number'), findsOneWidget);

        // Enter matching number
        controller.setNumber('9876543210');
        await tester.pumpAndSettle();

        expect(find.text('Arun Kumar'), findsOneWidget);
        expect(find.text('+91 98765 43210'), findsOneWidget);
        expect(find.byKey(const Key('deleteButton')), findsOneWidget);

        // Tap delete button once
        await tester.tap(find.byKey(const Key('deleteButton')));
        await tester.pumpAndSettle();
        expect(controller.rawNumber, '987654321');

        // Long press delete button clears number
        await tester.longPress(find.byKey(const Key('deleteButton')));
        await tester.pumpAndSettle();
        expect(controller.rawNumber, isEmpty);
        expect(find.text('Enter a number'), findsOneWidget);
      },
    );

    testWidgets(
      '8. DialerKeypad renders 3-column squircle grid and monochrome call button',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(body: DialerKeypad(controller: controller)),
          ),
        );

        // Digits 1-9, *, 0, # are present
        for (int i = 1; i <= 9; i++) {
          expect(find.byKey(Key('keypad_$i')), findsOneWidget);
        }
        expect(find.byKey(const Key('keypad_*')), findsOneWidget);
        expect(find.byKey(const Key('keypad_0')), findsOneWidget);
        expect(find.byKey(const Key('keypad_#')), findsOneWidget);

        // Monochrome call button
        expect(find.byKey(const Key('callButton')), findsOneWidget);

        // Tap '5'
        await tester.tap(find.byKey(const Key('keypad_5')));
        await tester.pumpAndSettle();
        expect(controller.rawNumber, '5');

        // Long press '0' inputs '+'
        await tester.longPress(find.byKey(const Key('keypad_0')));
        await tester.pumpAndSettle();
        expect(controller.rawNumber, '5+');
      },
    );

    testWidgets(
      '9. GlassKey water-drop ripple and animation lifecycle cleanup',
      (tester) async {
        int tapped = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: Center(
                child: GlassKey(
                  digit: '9',
                  letters: 'WXYZ',
                  onTap: () => tapped++,
                ),
              ),
            ),
          ),
        );

        // Tap down and up
        final gesture = await tester.startGesture(
          tester.getCenter(find.text('9')),
        );
        await tester.pump(const Duration(milliseconds: 50));
        await gesture.up();
        await tester.pumpAndSettle();

        expect(tapped, 1);

        // Clean disposal test: replacing widget unmounts without error
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
        );
        await tester.pumpAndSettle();
      },
    );

    test('10. AMOLED Theme tokens follow true AMOLED black and monochrome graphite palette', () {
      expect(GlassColors.background, const Color(0xFF000000));
      expect(GlassColors.surfaceDark, const Color(0xFF090909));
      expect(GlassColors.surfaceMid, const Color(0xFF101010));
      expect(GlassColors.surfaceHigh, const Color(0xFF171717));
      expect(GlassColors.textPrimary, const Color(0xFFF4F4F4));
      expect(GlassColors.textSecondary, const Color(0xFF969696));
      expect(GlassColors.silverAccent, const Color(0xFFE2E8F0));
    });
  });
}

class _AlwaysDeniedPermissionsService implements PhonePermissionsService {
  const _AlwaysDeniedPermissionsService();

  @override
  Future<AppPermissionStatus> checkContactsPermission() async =>
      AppPermissionStatus.denied;

  @override
  Future<AppPermissionStatus> requestContactsPermission() async =>
      AppPermissionStatus.denied;

  @override
  Future<AppPermissionStatus> checkCallPhonePermission() async =>
      AppPermissionStatus.denied;

  @override
  Future<AppPermissionStatus> requestCallPhonePermission() async =>
      AppPermissionStatus.denied;

  @override
  Future<AppPermissionStatus> checkCallLogPermission() async =>
      AppPermissionStatus.denied;

  @override
  Future<AppPermissionStatus> requestCallLogPermission() async =>
      AppPermissionStatus.denied;

  @override
  Future<AppPermissionStatus> checkNotificationPermission() async =>
      AppPermissionStatus.denied;

  @override
  Future<AppPermissionStatus> requestNotificationPermission() async =>
      AppPermissionStatus.denied;

  @override
  Future<bool> openAppSettings() async => true;
}
