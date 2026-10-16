import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_dialer/app.dart';
import 'package:liquid_dialer/features/dialer/dialer_controller.dart';
import 'package:liquid_dialer/features/dialer/phone_number_display.dart';

void main() {
  group('Dialer Integration & Phase 1 Backward Compatibility Tests', () {
    void setPhoneViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    test('1. DialerController setNumber populates raw and formatted numbers cleanly', () {
      final controller = DialerController();

      // Set clean 10-digit number
      controller.setNumber('1234567890');
      expect(controller.rawNumber, '1234567890');
      expect(controller.formattedNumber, '123 456 7890');

      // Set number containing spaces, hyphens, and parentheses
      controller.setNumber('+1 (800) 555-0199');
      expect(controller.rawNumber, '+18005550199');
      expect(controller.hasNumber, isTrue);

      // Overwrite cleanly without duplicating
      controller.setNumber('999');
      expect(controller.rawNumber, '999');
      expect(controller.formattedNumber, '999');

      // Clear after setNumber
      controller.clearNumber();
      expect(controller.hasNumber, isFalse);
      expect(controller.rawNumber, '');
    });

    testWidgets('2. Phase 1 keypad behavior remains completely functional', (
      tester,
    ) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(
        const LiquidDialerApp(callService: MockCallService()),
      );
      await tester.pumpAndSettle();

      // Enter digits
      await tester.tap(find.byKey(const Key('keypad_4')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('keypad_1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('keypad_5')));
      await tester.pumpAndSettle();

      expect(find.text('415'), findsOneWidget);

      // Delete one digit
      await tester.tap(find.byKey(const Key('deleteButton')));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(PhoneNumberDisplay),
          matching: find.text('41'),
        ),
        findsOneWidget,
      );

      // Call button tap gives feedback
      await tester.tap(find.byKey(const Key('callButton')));
      await tester.pumpAndSettle();

      expect(find.text('Calling is not available yet.'), findsOneWidget);
    });
  });
}
