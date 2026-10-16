import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_dialer/core/permissions/phone_permissions_service.dart';
import 'package:liquid_dialer/core/platform/dialer_bridge.dart';
import 'package:liquid_dialer/core/utils/privacy_logger.dart';
import 'package:liquid_dialer/features/calls/call_controller.dart';
import 'package:liquid_dialer/features/calls/models/call_session.dart';
import 'package:liquid_dialer/features/calls/models/call_state.dart';
import 'package:liquid_dialer/features/calls/screens/active_call_screen.dart';
import 'package:liquid_dialer/features/calls/widgets/call_status_indicator.dart';
import 'package:liquid_dialer/features/calls/widgets/incoming_call_actions.dart';
import 'package:liquid_dialer/features/privacy/privacy_center_screen.dart';
import 'package:liquid_dialer/features/settings/settings_screen.dart';
import 'package:liquid_dialer/shared/widgets/glass_icon_button.dart';
import 'package:liquid_dialer/shared/widgets/glass_key.dart';

class MockFullPhonePermissionsService implements PhonePermissionsService {
  MockFullPhonePermissionsService({
    this.contactsStatus = AppPermissionStatus.granted,
    this.callLogStatus = AppPermissionStatus.granted,
    this.callPhoneStatus = AppPermissionStatus.granted,
    this.notificationStatus = AppPermissionStatus.granted,
  });

  AppPermissionStatus contactsStatus;
  AppPermissionStatus callLogStatus;
  AppPermissionStatus callPhoneStatus;
  AppPermissionStatus notificationStatus;

  bool requestedContacts = false;
  bool requestedCallLog = false;
  bool requestedCallPhone = false;
  bool requestedNotification = false;
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
      callPhoneStatus;

  @override
  Future<AppPermissionStatus> requestCallPhonePermission() async {
    requestedCallPhone = true;
    return callPhoneStatus;
  }

  @override
  Future<AppPermissionStatus> checkNotificationPermission() async =>
      notificationStatus;

  @override
  Future<AppPermissionStatus> requestNotificationPermission() async {
    requestedNotification = true;
    return notificationStatus;
  }

  @override
  Future<bool> openAppSettings() async {
    openedSettings = true;
    return true;
  }
}

void main() {
  group('Phase 5 — Production Hardening & Liquid Glass Polish Tests', () {
    late MethodChannel testMethodChannel;
    late EventChannel testEventChannel;
    late StreamController<Map<dynamic, dynamic>> eventStreamController;
    late DialerBridge bridge;
    late CallController controller;

    void setPhoneViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    setUp(() {
      testMethodChannel = const MethodChannel('com.liquid.dialer/telecom_p5');
      testEventChannel = const EventChannel('com.liquid.dialer/call_events_p5');
      eventStreamController =
          StreamController<Map<dynamic, dynamic>>.broadcast();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(testMethodChannel, (MethodCall call) async {
            switch (call.method) {
              case 'isDefaultDialer':
                return true;
              case 'canRequestDefaultDialer':
                return true;
              case 'requestDefaultDialer':
                return true;
              case 'getCallSnapshot':
                return {
                  'calls': <dynamic>[],
                  'audioState': {
                    'currentRoute': 'earpiece',
                    'isMuted': false,
                    'supportedRoutes': ['earpiece', 'speaker'],
                  },
                };
              default:
                return true;
            }
          });

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('flutter.baseflow.com/permissions/methods'),
            (MethodCall call) async => 1,
          );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockStreamHandler(
            testEventChannel,
            MockStreamHandler.inline(
              onListen: (arguments, events) {
                eventStreamController.stream.listen(events.success);
              },
            ),
          );

      bridge = DialerBridge(
        channel: testMethodChannel,
        eventChannel: testEventChannel,
      );
      controller = CallController(bridge: bridge);
    });

    tearDown(() {
      controller.dispose();
      eventStreamController.close();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(testMethodChannel, null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('flutter.baseflow.com/permissions/methods'),
            null,
          );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockStreamHandler(testEventChannel, null);
    });

    test('1. PrivacyLogger automatically redacts phone numbers and OTPs', () {
      PrivacyLogger.clearLogs();

      // Test direct number masking
      expect(PrivacyLogger.maskPhoneNumber('+18005550199'), '***-***-0199');
      expect(PrivacyLogger.maskPhoneNumber('5554321'), '***-***-4321');
      expect(PrivacyLogger.maskPhoneNumber('123'), '***');
      expect(PrivacyLogger.maskPhoneNumber(''), '');
      expect(PrivacyLogger.maskPhoneNumber(null), '');

      // Test sentence redaction
      final redacted = PrivacyLogger.redact(
        'Call placed to +1-800-555-0199 with verification otp: 849201 for user.',
      );
      expect(redacted, contains('***-***-0199'));
      expect(redacted, contains('otp: [REDACTED]'));
      expect(redacted, isNot(contains('849201')));

      // Test diagnostic logging buffer
      PrivacyLogger.info('TEST_TAG', 'Dialing number 5551234567');
      expect(PrivacyLogger.recentLogs.isNotEmpty, isTrue);
      final lastLog = PrivacyLogger.recentLogs.last;
      expect(lastLog.message, contains('***-***-4567'));
      expect(lastLog.message, isNot(contains('5551234567')));
    });

    testWidgets(
      '2. PrivacyCenterScreen renders all 5 permissions and on-device privacy guarantee',
      (tester) async {
        setPhoneViewport(tester);

        final permissions = MockFullPhonePermissionsService(
          contactsStatus: AppPermissionStatus.granted,
          callLogStatus: AppPermissionStatus.granted,
          callPhoneStatus: AppPermissionStatus.denied,
          notificationStatus: AppPermissionStatus.permanentlyDenied,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: PrivacyCenterScreen(
              permissionsService: permissions,
              callController: controller,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Privacy guarantee hero card
        expect(find.text('100% On-Device Privacy Guaranteed'), findsOneWidget);

        // Capability cards (scrolled sequentially in ListView)
        expect(find.text('Default Phone App'), findsOneWidget);
        expect(find.text('Direct Phone Calls'), findsOneWidget);

        await tester.scrollUntilVisible(find.text('Device Contacts'), 200);
        expect(find.text('Device Contacts'), findsOneWidget);

        await tester.scrollUntilVisible(find.text('Call History Log'), 200);
        expect(find.text('Call History Log'), findsOneWidget);

        await tester.scrollUntilVisible(
          find.text('Incoming Call Notifications'),
          200,
        );
        expect(find.text('Incoming Call Notifications'), findsOneWidget);

        // Scroll down to architecture card
        await tester.scrollUntilVisible(
          find.text('No Internet Permission'),
          200,
        );
        expect(find.text('No Internet Permission'), findsOneWidget);
      },
    );

    testWidgets(
      '3. PrivacyCenterScreen allows requesting permissions and opening settings',
      (tester) async {
        setPhoneViewport(tester);

        final permissions = MockFullPhonePermissionsService(
          contactsStatus: AppPermissionStatus.denied,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: PrivacyCenterScreen(
              permissionsService: permissions,
              callController: controller,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap grant contacts access
        final grantButton = find.text('Grant Contacts Access');
        await tester.scrollUntilVisible(grantButton, 200);
        await tester.pumpAndSettle();
        await tester.tap(grantButton);
        await tester.pumpAndSettle();

        expect(permissions.requestedContacts, isTrue);

        // Tap Open System Settings (scrolling down to the bottom)
        final settingsBtn = find.byKey(const Key('openSystemSettingsButton'));
        await tester.scrollUntilVisible(settingsBtn, 300);
        await tester.pumpAndSettle();
        await tester.tap(settingsBtn);
        await tester.pumpAndSettle();

        expect(permissions.openedSettings, isTrue);
      },
    );

    testWidgets(
      '4. SettingsScreen links directly to PrivacyCenterScreen and shows Phase 5 milestone',
      (tester) async {
        setPhoneViewport(tester);

        await tester.pumpWidget(
          MaterialApp(home: SettingsScreen(callController: controller)),
        );
        await tester.pumpAndSettle();

        // Scroll down to check Phase 5 milestone text
        await tester.scrollUntilVisible(
          find.text('Phase 5 — Production Hardened & Liquid Glass Dialing'),
          300,
        );
        expect(
          find.text('Phase 5 — Production Hardened & Liquid Glass Dialing'),
          findsOneWidget,
        );

        // Scroll back up and tap Permissions & Privacy Center button
        await tester.scrollUntilVisible(
          find.byKey(const Key('settingsPrivacyCenterButton')),
          -300,
        );
        final privacyCenterButton = find.byKey(
          const Key('settingsPrivacyCenterButton'),
        );
        expect(privacyCenterButton, findsOneWidget);
        await tester.tap(privacyCenterButton);
        await tester.pumpAndSettle();

        // Verify Privacy Center screen opened
        expect(find.text('Permissions & Privacy'), findsOneWidget);
        expect(find.text('100% On-Device Privacy Guaranteed'), findsOneWidget);
      },
    );

    testWidgets(
      '5. Reduced motion preferences disable looping and scaling animations',
      (tester) async {
        setPhoneViewport(tester);

        // Pump CallStatusIndicator with disableAnimations: true
        await tester.pumpWidget(
          const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: MaterialApp(
              home: Scaffold(
                body: CallStatusIndicator(state: CallState.active),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('ACTIVE CALL'), findsOneWidget);

        // Pump IncomingCallActions with disableAnimations: true
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: MaterialApp(
              home: Scaffold(
                body: IncomingCallActions(onAnswer: () {}, onReject: () {}),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Answer'), findsOneWidget);
        expect(find.text('Decline'), findsOneWidget);
      },
    );

    testWidgets(
      '6. GlassIconButton enforces 48dp minimum touch bounds and semantics',
      (tester) async {
        setPhoneViewport(tester);
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GlassIconButton(
                icon: Icons.star_rounded,
                size: 40.0, // Requested smaller size
                tooltip: 'Favorite contact',
                onTap: () => tapped = true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final size = tester.getSize(find.byType(GlassIconButton));
        expect(size.width, greaterThanOrEqualTo(48.0));
        expect(size.height, greaterThanOrEqualTo(48.0));

        await tester.tap(find.byType(GlassIconButton));
        await tester.pumpAndSettle();
        expect(tapped, isTrue);
      },
    );

    testWidgets(
      '7. ActiveCallScreen reveals in-call DTMF dialpad and accepts touch-tones',
      (tester) async {
        setPhoneViewport(tester);

        const activeSession = CallSession(
          sessionId: 'session_active_dtmf',
          phoneNumber: '+18005550199',
          displayName: 'Telecom Support',
          state: CallState.active,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: ActiveCallScreen(
              session: activeSession,
              controller: controller,
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        // Keypad button is rendered
        final keypadButton = find.byKey(const Key('activeCallKeypadButton'));
        expect(keypadButton, findsOneWidget);

        // Tap keypad button to show DTMF dialpad
        await tester.tap(keypadButton);
        await tester.pump(const Duration(milliseconds: 100));

        // DTMF touch-tone panel is now visible
        expect(find.text('Touch tones (DTMF)'), findsOneWidget);
        expect(find.byType(GlassKey), findsWidgets);

        // Tap digit 4, then digit 2
        await tester.tap(find.byKey(const Key('dtmf_key_4')));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.byKey(const Key('dtmf_key_2')));
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.text('42'), findsOneWidget);

        // Close DTMF dialpad
        await tester.tap(find.byKey(const Key('closeDtmfDialpadButton')));
        await tester.pump(const Duration(milliseconds: 100));

        // Monogram avatar returns
        expect(find.text('Telecom Support'), findsOneWidget);
      },
    );
  });
}
