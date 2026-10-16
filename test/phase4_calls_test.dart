import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_dialer/app.dart';
import 'package:liquid_dialer/core/platform/dialer_bridge.dart';
import 'package:liquid_dialer/features/calls/call_controller.dart';
import 'package:liquid_dialer/features/calls/models/audio_route.dart';
import 'package:liquid_dialer/features/calls/models/call_session.dart';
import 'package:liquid_dialer/features/calls/models/call_state.dart';
import 'package:liquid_dialer/features/calls/screens/active_call_screen.dart';
import 'package:liquid_dialer/features/calls/screens/incoming_call_screen.dart';
import 'package:liquid_dialer/features/calls/services/call_event_service.dart';
import 'package:liquid_dialer/features/calls/widgets/audio_route_selector.dart';
import 'package:liquid_dialer/features/dialer/dialer_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  void setPhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('Phase 4 — Incoming & Active Call Unit & Widget Tests', () {
    late List<MethodCall> methodCalls;
    late MethodChannel testMethodChannel;
    late StreamController<Map<dynamic, dynamic>> eventStreamController;
    late EventChannel testEventChannel;
    late DialerBridge bridge;
    late CallController controller;

    setUp(() {
      methodCalls = [];
      testMethodChannel = const MethodChannel(
        'com.liquid.dialer/telecom_test_p4',
      );
      testEventChannel = const EventChannel(
        'com.liquid.dialer/call_events_test_p4',
      );
      eventStreamController =
          StreamController<Map<dynamic, dynamic>>.broadcast();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(testMethodChannel, (MethodCall call) async {
            methodCalls.add(call);
            switch (call.method) {
              case 'answerCall':
                return true;
              case 'rejectCall':
                return true;
              case 'disconnectCall':
                return true;
              case 'holdCall':
                return true;
              case 'unholdCall':
                return true;
              case 'setMuted':
                return true;
              case 'setAudioRoute':
                return true;
              case 'getCallSnapshot':
                return {
                  'calls': <dynamic>[],
                  'audioState': {
                    'currentRoute': 'earpiece',
                    'isMuted': false,
                    'supportedRoutes': ['earpiece', 'speaker', 'bluetooth'],
                  },
                };
              default:
                return true;
            }
          });

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('flutter.baseflow.com/permissions/methods'),
            (MethodCall call) async {
              if (call.method == 'checkPermissionStatus') {
                return 0; // PermissionStatus.denied (safe default for tests)
              }
              return 0;
            },
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

    testWidgets(
      '1. Incoming-call state rendering displays caller name, number, avatar',
      (tester) async {
        setPhoneViewport(tester);

        const session = CallSession(
          sessionId: 'session_101',
          phoneNumber: '+18005550199',
          displayName: 'Johnathan Vance',
          state: CallState.incoming,
          direction: CallDirection.incoming,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: IncomingCallScreen(session: session, controller: controller),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Johnathan Vance'), findsOneWidget);
        expect(find.text('+18005550199'), findsOneWidget);
        expect(find.text('JV'), findsOneWidget); // Monogram initials
        expect(find.text('INCOMING CELLULAR CALL'), findsOneWidget);
        expect(find.byKey(const Key('incomingAnswerButton')), findsOneWidget);
        expect(find.byKey(const Key('incomingDeclineButton')), findsOneWidget);
      },
    );

    testWidgets(
      '2. Answer and reject button behavior invokes native Telecom actions',
      (tester) async {
        setPhoneViewport(tester);

        const session = CallSession(
          sessionId: 'session_102',
          phoneNumber: '+15559876543',
          displayName: 'Alice Cooper',
          state: CallState.incoming,
          direction: CallDirection.incoming,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: IncomingCallScreen(session: session, controller: controller),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        // Tap Answer
        await tester.tap(find.byKey(const Key('incomingAnswerButton')));
        await tester.pump(const Duration(milliseconds: 100));

        final answerCall = methodCalls.firstWhere(
          (c) => c.method == 'answerCall',
        );
        expect(answerCall.arguments['sessionId'], 'session_102');

        // Tap Decline
        await tester.tap(find.byKey(const Key('incomingDeclineButton')));
        await tester.pump(const Duration(milliseconds: 100));

        final rejectCall = methodCalls.firstWhere(
          (c) => c.method == 'rejectCall',
        );
        expect(rejectCall.arguments['sessionId'], 'session_102');
      },
    );

    testWidgets('3. Active-call state transitions render correctly', (
      tester,
    ) async {
      setPhoneViewport(tester);

      const dialingSession = CallSession(
        sessionId: 'session_103',
        phoneNumber: '5551234',
        displayName: 'Doctor Office',
        state: CallState.dialing,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ActiveCallScreen(
            session: dialingSession,
            controller: controller,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('DIALING...'), findsOneWidget);
      expect(find.text('Calling...'), findsOneWidget);

      // Re-pump with active state
      final activeSession = CallSession(
        sessionId: 'session_103',
        phoneNumber: '5551234',
        displayName: 'Doctor Office',
        state: CallState.active,
        connectTimeMillis: DateTime.now().millisecondsSinceEpoch - 15000,
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

      expect(find.text('ACTIVE CALL'), findsOneWidget);
    });

    testWidgets('4. Mute state updates and triggers native setMuted', (
      tester,
    ) async {
      setPhoneViewport(tester);

      final activeSession = CallSession(
        sessionId: 'session_104',
        phoneNumber: '1234567890',
        state: CallState.active,
        connectTimeMillis: DateTime.now().millisecondsSinceEpoch,
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

      await tester.tap(find.byKey(const Key('activeCallMuteButton')));
      await tester.pump(const Duration(milliseconds: 100));

      final muteCall = methodCalls.firstWhere((c) => c.method == 'setMuted');
      expect(muteCall.arguments['isMuted'], isTrue);
    });

    testWidgets(
      '5. Audio-route selection sheet lists supported routes and invokes native route',
      (tester) async {
        setPhoneViewport(tester);

        AudioRoute? selected;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AudioRouteSelector(
                audioState: const AudioRouteState(
                  currentRoute: AudioRoute.earpiece,
                  supportedRoutes: [
                    AudioRoute.earpiece,
                    AudioRoute.speaker,
                    AudioRoute.bluetooth,
                  ],
                ),
                onSelectRoute: (r) => selected = r,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Phone Earpiece'), findsOneWidget);
        expect(find.text('Speaker'), findsOneWidget);
        expect(find.text('Bluetooth Device'), findsOneWidget);

        // Tap Speaker
        await tester.tap(find.text('Speaker'));
        await tester.pumpAndSettle();

        expect(selected, AudioRoute.speaker);
      },
    );

    test('6. Call duration survives rebuilds and is derived from connect timestamp', () {
      final now = DateTime.now();
      final connectTime = now
          .subtract(const Duration(minutes: 2, seconds: 45))
          .millisecondsSinceEpoch;

      final session = CallSession(
        sessionId: 'session_106',
        phoneNumber: '5559999',
        state: CallState.active,
        connectTimeMillis: connectTime,
      );

      final duration = session.getElapsedDuration(now);
      expect(duration.inMinutes, 2);
      expect(duration.inSeconds, 165);

      // Survives new session instance with same connect timestamp
      final rebuiltSession = CallSession(
        sessionId: 'session_106',
        phoneNumber: '5559999',
        state: CallState.active,
        connectTimeMillis: connectTime,
      );
      expect(rebuiltSession.getElapsedDuration(now), duration);
    });

    testWidgets('7. Disconnected-call shows reason and invokes onDismiss', (
      tester,
    ) async {
      setPhoneViewport(tester);
      bool dismissed = false;

      const disconnectedSession = CallSession(
        sessionId: 'session_107',
        phoneNumber: '5551234',
        state: CallState.disconnected,
        disconnectReason: 'Call ended by remote party',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ActiveCallScreen(
            session: disconnectedSession,
            controller: controller,
            onDismiss: () => dismissed = true,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Call ended by remote party'), findsWidgets);

      // Fast-forward dismiss timer
      await tester.pump(const Duration(milliseconds: 1500));
      expect(dismissed, isTrue);
    });

    test(
      '8. Duplicate and successive event emissions update state cleanly',
      () async {
        final sub = controller.callSnapshot;
        expect(sub.calls, isEmpty);

        // Emit event with an active call
        eventStreamController.add({
          'type': 'calls_changed',
          'calls': [
            {
              'sessionId': 'call_99',
              'phoneNumber': '5551111',
              'state': 'active',
              'direction': 'outgoing',
              'connectTimeMillis': 100000,
            },
          ],
          'audioState': {
            'currentRoute': 'earpiece',
            'isMuted': false,
            'supportedRoutes': ['earpiece', 'speaker'],
          },
        });

        await Future.delayed(Duration.zero);
        expect(controller.allCalls.length, 1);
        expect(controller.activeCall?.sessionId, 'call_99');

        // Duplicate event
        eventStreamController.add({
          'type': 'calls_changed',
          'calls': [
            {
              'sessionId': 'call_99',
              'phoneNumber': '5551111',
              'state': 'active',
              'direction': 'outgoing',
              'connectTimeMillis': 100000,
            },
          ],
          'audioState': {
            'currentRoute': 'earpiece',
            'isMuted': false,
            'supportedRoutes': ['earpiece', 'speaker'],
          },
        });

        await Future.delayed(Duration.zero);
        expect(controller.allCalls.length, 1);
      },
    );

    test('9. Missing caller name or photo produces safe fallbacks', () {
      const sessionWithoutName = CallSession(
        sessionId: 'call_fallback',
        phoneNumber: '+18005550199',
      );

      expect(sessionWithoutName.hasCallerName, isFalse);
      expect(sessionWithoutName.effectiveName, '+18005550199');
      expect(sessionWithoutName.initials, '+');

      const completelyEmptySession = CallSession(
        sessionId: 'call_empty',
        phoneNumber: '',
      );

      expect(completelyEmptySession.effectiveName, 'Unknown Caller');
      expect(completelyEmptySession.initials, 'UC');
    });

    test('10. Multiple call sessions: call waiting prioritizes incoming ringing call', () {
      final snapshot = CallSnapshot(
        calls: [
          CallSession(
            sessionId: 'call_active_1',
            phoneNumber: '111',
            state: CallState.active,
            connectTimeMillis: DateTime.now().millisecondsSinceEpoch,
          ),
          const CallSession(
            sessionId: 'call_waiting_2',
            phoneNumber: '222',
            state: CallState.incoming,
          ),
        ],
      );

      expect(snapshot.calls.length, 2);
      expect(snapshot.activeCall?.sessionId, 'call_active_1');
      expect(snapshot.incomingCall?.sessionId, 'call_waiting_2');
      // Primary call for user attention should be the incoming call
      expect(snapshot.primaryCall?.sessionId, 'call_waiting_2');
    });

    testWidgets(
      '11. LiquidDialerApp seamlessly transitions between shell and call screens',
      (tester) async {
        setPhoneViewport(tester);

        await tester.pumpWidget(
          LiquidDialerApp(
            callService: const MockCallService(),
            callController: controller,
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        // Normal dialer shell is visible
        expect(find.text('Enter a number'), findsOneWidget);

        // Simulate incoming call via EventStream
        eventStreamController.add({
          'type': 'calls_changed',
          'calls': [
            {
              'sessionId': 'call_incoming_live',
              'phoneNumber': '5554321',
              'displayName': 'Sarah Connor',
              'state': 'incoming',
              'direction': 'incoming',
            },
          ],
          'audioState': {'currentRoute': 'earpiece', 'isMuted': false},
        });

        await tester.runAsync(
          () => Future.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump(const Duration(milliseconds: 100));

        // Incoming call screen is now prominently active
        expect(find.text('Sarah Connor'), findsOneWidget);
        expect(find.text('INCOMING CELLULAR CALL'), findsOneWidget);

        // Simulate user answering: transition to active call
        eventStreamController.add({
          'type': 'calls_changed',
          'calls': [
            {
              'sessionId': 'call_incoming_live',
              'phoneNumber': '5554321',
              'displayName': 'Sarah Connor',
              'state': 'active',
              'direction': 'incoming',
              'connectTimeMillis': DateTime.now().millisecondsSinceEpoch,
            },
          ],
          'audioState': {'currentRoute': 'earpiece', 'isMuted': false},
        });

        await tester.runAsync(
          () => Future.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump(const Duration(milliseconds: 100));

        // Active call screen with controls is now visible
        expect(find.text('ACTIVE CALL'), findsOneWidget);
        expect(find.byKey(const Key('activeCallEndButton')), findsOneWidget);

        // Simulate call termination
        eventStreamController.add({
          'type': 'calls_changed',
          'calls': [
            {
              'sessionId': 'call_incoming_live',
              'phoneNumber': '5554321',
              'displayName': 'Sarah Connor',
              'state': 'disconnected',
              'disconnectReason': 'Call ended',
            },
          ],
        });

        await tester.runAsync(
          () => Future.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump(const Duration(milliseconds: 100));

        // Fast-forward dismiss timer
        await tester.pump(const Duration(milliseconds: 1500));

        // Call removed from list
        eventStreamController.add({
          'type': 'calls_changed',
          'calls': <dynamic>[],
        });
        await tester.runAsync(
          () => Future.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump(const Duration(milliseconds: 100));

        // Smoothly returned to dialer shell
        expect(find.text('Enter a number'), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
      },
    );

    testWidgets(
      '12. Keypad, Contacts, Recents, and Settings remain fully operational',
      (tester) async {
        setPhoneViewport(tester);

        await tester.pumpWidget(
          LiquidDialerApp(
            callService: const MockCallService(),
            callController: controller,
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        // Keypad input
        await tester.tap(find.byKey(const Key('keypad_1')));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(find.byKey(const Key('keypad_2')));
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('12'), findsOneWidget);

        // Recents
        await tester.tap(find.text('Recents'));
        await tester.pumpAndSettle();
        expect(find.text('Device Call History'), findsOneWidget);

        // Contacts
        await tester.tap(find.text('Contacts'));
        await tester.pumpAndSettle();
        expect(find.text('Access Your Contacts'), findsOneWidget);

        // Return to Keypad
        await tester.tap(find.text('Keypad'));
        await tester.pumpAndSettle();
        expect(find.text('12'), findsOneWidget);
      },
    );
  });
}
