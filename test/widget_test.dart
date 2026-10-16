import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_dialer/app.dart';
import 'package:liquid_dialer/features/dialer/dialer_controller.dart';
import 'package:liquid_dialer/features/dialer/phone_number_display.dart';

void main() {
  group('Liquid Dialer UI Integration Tests', () {
    // Configure viewport dimensions reflecting the OnePlus Nord 4 portrait display
    void setPhoneViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    testWidgets(
      '1. Application starts without errors and shows default Keypad tab',
      (tester) async {
        setPhoneViewport(tester);
        await tester.pumpWidget(
          const LiquidDialerApp(callService: MockCallService()),
        );
        await tester.pumpAndSettle();

        expect(find.byType(LiquidDialerApp), findsOneWidget);
        expect(find.text('Enter a number'), findsOneWidget);
        expect(find.text('LIQUID'), findsOneWidget);
      },
    );

    testWidgets('2. All twelve keypad keys are rendered', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(
        const LiquidDialerApp(callService: MockCallService()),
      );
      await tester.pumpAndSettle();

      final expectedKeys = [
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9',
        '*',
        '0',
        '#',
      ];

      for (final keyChar in expectedKeys) {
        expect(
          find.byKey(Key('keypad_$keyChar')),
          findsOneWidget,
          reason: 'Keypad key $keyChar should be rendered',
        );
      }
    });

    testWidgets('3. Tapping digits updates the number display', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(
        const LiquidDialerApp(callService: MockCallService()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('keypad_1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('keypad_2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('keypad_3')));
      await tester.pumpAndSettle();

      expect(find.text('123'), findsOneWidget);
    });

    testWidgets('4. Delete removes exactly one digit', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(
        const LiquidDialerApp(callService: MockCallService()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('keypad_5')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('keypad_8')));
      await tester.pumpAndSettle();
      expect(find.text('58'), findsOneWidget);

      await tester.tap(find.byKey(const Key('deleteButton')));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(PhoneNumberDisplay),
          matching: find.text('5'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('5. Long-press delete clears the complete number', (
      tester,
    ) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(
        const LiquidDialerApp(callService: MockCallService()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('keypad_9')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('keypad_9')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('keypad_9')));
      await tester.pumpAndSettle();
      expect(find.text('999'), findsOneWidget);

      await tester.longPress(find.byKey(const Key('deleteButton')));
      await tester.pumpAndSettle();

      expect(find.text('Enter a number'), findsOneWidget);
    });

    testWidgets('6. Empty-number interactions do not crash', (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(
        const LiquidDialerApp(callService: MockCallService()),
      );
      await tester.pumpAndSettle();

      // Empty state call button tap
      await tester.tap(find.byKey(const Key('callButton')));
      await tester.pumpAndSettle();

      expect(find.text('Calling is not available yet.'), findsOneWidget);
    });

    testWidgets('7. Bottom navigation changes the active screen', (
      tester,
    ) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(
        const LiquidDialerApp(callService: MockCallService()),
      );
      await tester.pumpAndSettle();

      // Tap Recents tab
      await tester.tap(find.text('Recents'));
      await tester.pumpAndSettle();
      expect(find.text('Device Call History'), findsOneWidget);

      // Tap Contacts tab
      await tester.tap(find.text('Contacts'));
      await tester.pumpAndSettle();
      expect(find.text('Access Your Contacts'), findsOneWidget);

      // Return to Keypad
      await tester.tap(find.text('Keypad'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a number'), findsOneWidget);
    });

    testWidgets('8. The call button displays the Phase 1 placeholder message', (
      tester,
    ) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(
        const LiquidDialerApp(callService: MockCallService()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('keypad_5')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('callButton')));
      await tester.pumpAndSettle();

      expect(find.text('Calling is not available yet.'), findsOneWidget);
    });

    testWidgets('9. The settings screen can be opened and closed', (
      tester,
    ) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(
        const LiquidDialerApp(callService: MockCallService()),
      );
      await tester.pumpAndSettle();

      // Open settings from header
      await tester.tap(find.byKey(const Key('headerSettingsButton')));
      await tester.pumpAndSettle();

      expect(find.text('Theme & Settings'), findsOneWidget);
      expect(find.text('Liquid Glass Specular Engine'), findsOneWidget);

      // Close settings via back button
      await tester.tap(find.byKey(const Key('settingsBackButton')));
      await tester.pumpAndSettle();

      expect(find.text('Theme & Settings'), findsNothing);
      expect(find.text('LIQUID'), findsOneWidget);
    });

    testWidgets('10. The UI remains functional after switching between tabs', (
      tester,
    ) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(
        const LiquidDialerApp(callService: MockCallService()),
      );
      await tester.pumpAndSettle();

      // Enter digits
      await tester.tap(find.byKey(const Key('keypad_7')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('keypad_8')));
      await tester.pumpAndSettle();
      expect(find.text('78'), findsOneWidget);

      // Switch to Recents
      await tester.tap(find.text('Recents'));
      await tester.pumpAndSettle();
      expect(find.text('Device Call History'), findsOneWidget);

      // Switch back to Keypad
      await tester.tap(find.text('Keypad'));
      await tester.pumpAndSettle();

      // Digits must be preserved
      expect(find.text('78'), findsOneWidget);

      // Additional input works seamlessly
      await tester.tap(find.byKey(const Key('keypad_9')));
      await tester.pumpAndSettle();
      expect(find.text('789'), findsOneWidget);
    });
  });
}
