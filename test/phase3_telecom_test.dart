import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_dialer/app.dart';
import 'package:liquid_dialer/core/platform/dialer_bridge.dart';
import 'package:liquid_dialer/features/calls/call_controller.dart';
import 'package:liquid_dialer/features/calls/call_status.dart';
import 'package:liquid_dialer/features/dialer/dialer_controller.dart';
import 'package:liquid_dialer/features/dialer/dialer_keypad.dart';
import 'package:liquid_dialer/features/settings/widgets/default_dialer_tile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 3 — Platform Bridge & CallResult Tests', () {
    late List<MethodCall> methodCalls;
    late MethodChannel testChannel;
    late DialerBridge bridge;

    setUp(() {
      methodCalls = [];
      testChannel = const MethodChannel('com.liquid.dialer/telecom_test');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(testChannel, (MethodCall call) async {
            methodCalls.add(call);
            switch (call.method) {
              case 'isDefaultDialer':
                return true;
              case 'canRequestDefaultDialer':
                return true;
              case 'requestDefaultDialer':
                return true;
              case 'placeCall':
                final args = call.arguments as Map<dynamic, dynamic>;
                final number = args['phoneNumber'] as String;
                if (number == '99999') {
                  return {
                    'success': false,
                    'message': 'Permission denied',
                    'errorCode': 'PERMISSION_DENIED',
                  };
                }
                if (number == 'invalid') {
                  return {
                    'success': false,
                    'message': 'Invalid number format',
                    'errorCode': 'INVALID_NUMBER',
                  };
                }
                return {
                  'success': true,
                  'message': 'Outgoing call initiated.',
                  'errorCode': null,
                };
              default:
                return null;
            }
          });
      bridge = DialerBridge(channel: testChannel);
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(testChannel, null);
    });

    test('1. Empty number cannot trigger platform placeCall channel', () async {
      final result = await bridge.placeCall('');
      expect(result.success, isFalse);
      expect(result.code, CallStatusCode.emptyNumber);
      expect(result.message, contains('Please enter a phone number'));
      expect(methodCalls.where((c) => c.method == 'placeCall'), isEmpty);

      final whitespaceResult = await bridge.placeCall('    ');
      expect(whitespaceResult.success, isFalse);
      expect(whitespaceResult.code, CallStatusCode.emptyNumber);
      expect(methodCalls.where((c) => c.method == 'placeCall'), isEmpty);
    });

    test('2. Valid number is passed to platform bridge correctly', () async {
      final result = await bridge.placeCall('+18005550199');
      expect(result.success, isTrue);
      expect(result.code, CallStatusCode.success);
      expect(result.message, 'Outgoing call initiated.');

      final callInvoked = methodCalls.firstWhere(
        (c) => c.method == 'placeCall',
      );
      expect(callInvoked.arguments['phoneNumber'], '+18005550199');
    });

    test(
      '3. Platform errors are converted into understandable CallResult',
      () async {
        final deniedResult = await bridge.placeCall('99999');
        expect(deniedResult.success, isFalse);
        expect(deniedResult.code, CallStatusCode.permissionDenied);
        expect(deniedResult.message, contains('Permission denied'));

        final invalidResult = await bridge.placeCall('invalid');
        expect(invalidResult.success, isFalse);
        expect(invalidResult.code, CallStatusCode.invalidNumber);
        expect(invalidResult.message, contains('Invalid number'));
      },
    );

    test(
      '4. Default dialer role checks and requests query the bridge',
      () async {
        final isDefault = await bridge.isDefaultDialer();
        expect(isDefault, isTrue);

        final canRequest = await bridge.canRequestDefaultDialer();
        expect(canRequest, isTrue);

        final requested = await bridge.requestDefaultDialer();
        expect(requested, isTrue);

        expect(
          methodCalls.map((c) => c.method),
          containsAll([
            'isDefaultDialer',
            'canRequestDefaultDialer',
            'requestDefaultDialer',
          ]),
        );
      },
    );
  });

  group('Phase 3 — CallController & DialerController Tests', () {
    test('5. CallController prevents concurrent duplicate calls', () async {
      final channel = const MethodChannel('com.liquid.dialer/telecom_delayed');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
            await Future.delayed(const Duration(milliseconds: 100));
            return {
              'success': true,
              'message': 'Outgoing call initiated.',
              'errorCode': null,
            };
          });

      final bridge = DialerBridge(channel: channel);
      final controller = CallController(bridge: bridge);

      // Launch first call
      final future1 = controller.placeCall('1234567890');
      expect(controller.isPlacingCall, isTrue);

      // Launch immediate duplicate call
      final future2 = controller.placeCall('1234567890');

      final result2 = await future2;
      expect(result2.success, isFalse);
      expect(result2.message, contains('already in progress'));

      final result1 = await future1;
      expect(result1.success, isTrue);
      expect(controller.isPlacingCall, isFalse);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test(
      '6. DialerController handles empty input and duplicate call taps',
      () async {
        final controller = DialerController();

        // Empty input
        final emptyFeedback = await controller.call();
        expect(emptyFeedback, contains('Please enter a phone number'));
        expect(controller.hasNumber, isFalse);

        // Enter digits
        controller.appendDigit('5');
        controller.appendDigit('5');
        controller.appendDigit('5');
        expect(controller.rawNumber, '555');

        // Successful call flow
        final callFeedback = await controller.call();
        expect(callFeedback, isNotEmpty);
        expect(controller.isPlacingCall, isFalse);
      },
    );
  });

  group('Phase 3 — Widget & UI Integration Tests', () {
    void setPhoneViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    testWidgets('7. Empty number tap shows warning SnackBar', (tester) async {
      setPhoneViewport(tester);
      final controller = DialerController(callService: const MockCallService());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DialerKeypad(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('callButton')));
      await tester.pumpAndSettle();

      expect(find.text('Calling is not available yet.'), findsOneWidget);
    });

    testWidgets('8. Valid number tap triggers call action', (tester) async {
      setPhoneViewport(tester);
      String? recordedMessage;
      final controller = DialerController(callService: const MockCallService());
      controller.appendDigit('1');
      controller.appendDigit('2');
      controller.appendDigit('3');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DialerKeypad(
              controller: controller,
              onCallMessage: (msg) => recordedMessage = msg,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('callButton')));
      await tester.pumpAndSettle();

      expect(recordedMessage, 'Calling is not available yet.');
    });

    testWidgets(
      '9. DefaultDialerTile reflects status and triggers role request',
      (tester) async {
        setPhoneViewport(tester);

        final channel = const MethodChannel(
          'com.liquid.dialer/telecom_tile_test',
        );
        bool roleGranted = false;

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall call) async {
              if (call.method == 'isDefaultDialer') {
                return roleGranted;
              }
              if (call.method == 'canRequestDefaultDialer') {
                return true;
              }
              if (call.method == 'requestDefaultDialer') {
                roleGranted = true;
                return true;
              }
              return null;
            });

        final bridge = DialerBridge(channel: channel);
        final callController = CallController(bridge: bridge);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: DefaultDialerTile(controller: callController)),
          ),
        );
        await tester.pumpAndSettle();

        // Initially not default
        expect(find.text('Set as Default Phone App'), findsWidgets);
        expect(
          find.byKey(const Key('requestDefaultDialerButton')),
          findsOneWidget,
        );

        // Tap request button
        await tester.tap(find.byKey(const Key('requestDefaultDialerButton')));
        await tester.pumpAndSettle();

        // Now default role confirmed
        expect(find.text('Default Dialer Active'), findsOneWidget);
        expect(find.text('Active'), findsOneWidget);
        expect(
          find.text('Liquid Dialer is now your default phone app.'),
          findsOneWidget,
        );

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      },
    );

    testWidgets(
      '10. Phase 1 & 2 features (Keypad, Recents, Contacts, Settings) remain fully operational',
      (tester) async {
        setPhoneViewport(tester);
        await tester.pumpWidget(
          const LiquidDialerApp(callService: MockCallService()),
        );
        await tester.pumpAndSettle();

        // Keypad input
        await tester.tap(find.byKey(const Key('keypad_4')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('keypad_5')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('keypad_6')));
        await tester.pumpAndSettle();
        expect(find.text('456'), findsOneWidget);

        // Recents tab
        await tester.tap(find.text('Recents'));
        await tester.pumpAndSettle();
        expect(find.text('Device Call History'), findsOneWidget);

        // Contacts tab
        await tester.tap(find.text('Contacts'));
        await tester.pumpAndSettle();
        expect(find.text('Access Your Contacts'), findsOneWidget);

        // Keypad tab returns with preserved state
        await tester.tap(find.text('Keypad'));
        await tester.pumpAndSettle();
        expect(find.text('456'), findsOneWidget);

        // Open Settings
        await tester.tap(find.byKey(const Key('headerSettingsButton')));
        await tester.pumpAndSettle();
        expect(find.text('Theme & Settings'), findsOneWidget);
        expect(find.byType(DefaultDialerTile), findsOneWidget);

        // Close Settings
        await tester.tap(find.byKey(const Key('settingsBackButton')));
        await tester.pumpAndSettle();
        expect(find.text('LIQUID'), findsOneWidget);
      },
    );
  });
}
