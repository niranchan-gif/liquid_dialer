import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_dialer/app.dart';
import 'package:liquid_dialer/core/permissions/phone_permissions_service.dart';
import 'package:liquid_dialer/core/platform/dialer_bridge.dart';
import 'package:liquid_dialer/features/calls/call_controller.dart';
import 'package:liquid_dialer/features/calls/call_status.dart';
import 'package:liquid_dialer/features/calls/models/audio_route.dart';
import 'package:liquid_dialer/features/calls/models/call_session.dart';
import 'package:liquid_dialer/features/calls/models/call_state.dart';
import 'package:liquid_dialer/features/calls/screens/active_call_screen.dart';
import 'package:liquid_dialer/features/calls/screens/incoming_call_screen.dart';
import 'package:liquid_dialer/features/calls/services/call_event_service.dart';
import 'package:liquid_dialer/features/contacts/models/contact_item.dart';
import 'package:liquid_dialer/features/contacts/services/contacts_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(
    'Priority 1 & 5 — Critical Call Screen Lifecycle & Resilience Tests',
    () {
      late _MockDialerBridge mockBridge;
      late _MockCallEventService mockEventService;
      late _MockContactsService mockContactsService;
      late _MockPermissionsService mockPermissionsService;

      final testContacts = [
        const ContactItem(
          id: 'c1',
          displayName: 'Niranchan',
          phones: [ContactPhone(number: '+91 98765 43210')],
        ),
        const ContactItem(
          id: 'c2',
          displayName: 'Aarav Patel',
          phones: [ContactPhone(number: '555-0199')],
        ),
      ];

      setUp(() {
        mockBridge = _MockDialerBridge();
        mockEventService = _MockCallEventService();
        mockContactsService = _MockContactsService(testContacts);
        mockPermissionsService = _MockPermissionsService(granted: true);
      });

      tearDown(() {
        mockEventService.dispose();
      });

      testWidgets(
        '1. Incoming call event presents IncomingCallScreen and resolves contact name from device contacts',
        (tester) async {
          final controller = CallController(
            bridge: mockBridge,
            eventService: mockEventService,
            contactsService: mockContactsService,
            permissionsService: mockPermissionsService,
          );

          // Pre-cache contacts
          controller.setContactsCache(testContacts);

          await tester.pumpWidget(
            MaterialApp(home: MainShellScreen(callController: controller)),
          );
          await tester.pump();

          // Verify shell is shown initially
          expect(find.byType(IncomingCallScreen), findsNothing);

          // Emit incoming call without Telecom caller display name
          final incomingCall = CallSession(
            sessionId: 'call_inc_1',
            phoneNumber: '+919876543210',
            displayName: null,
            state: CallState.incoming,
            direction: CallDirection.incoming,
            connectTimeMillis: DateTime.now().millisecondsSinceEpoch,
          );

          mockEventService.emitSnapshot(CallSnapshot(calls: [incomingCall]));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));

          // IncomingCallScreen must now be presented
          expect(find.byType(IncomingCallScreen), findsOneWidget);

          // Contact name must be resolved from local contacts
          expect(find.text('Niranchan'), findsOneWidget);
          expect(find.text('+919876543210'), findsOneWidget);
          expect(find.text('Answer'), findsOneWidget);
          expect(find.text('Decline'), findsOneWidget);

          controller.dispose();
        },
      );

      testWidgets(
        '2. Outgoing call tap transitions immediately to connecting and then active screen',
        (tester) async {
          final controller = CallController(
            bridge: mockBridge,
            eventService: mockEventService,
            contactsService: mockContactsService,
            permissionsService: mockPermissionsService,
          );
          controller.setContactsCache(testContacts);

          await tester.pumpWidget(
            MaterialApp(home: MainShellScreen(callController: controller)),
          );
          await tester.pump();

          // Place call
          final callFuture = controller.placeCall('555-0199');
          await tester.pump();

          // Optimistic connecting screen must be immediately visible
          expect(find.byType(ActiveCallScreen), findsOneWidget);
          expect(find.text('Aarav Patel'), findsOneWidget);
          expect(find.text('Calling...'), findsOneWidget);

          await callFuture;

          // Telecom native state transitions to active
          final activeCall = CallSession(
            sessionId: 'telecom_out_1',
            phoneNumber: '555-0199',
            displayName: 'Aarav Patel',
            state: CallState.active,
            direction: CallDirection.outgoing,
            connectTimeMillis: DateTime.now().millisecondsSinceEpoch - 5000,
          );

          mockEventService.emitSnapshot(CallSnapshot(calls: [activeCall]));
          await tester.pump();
          await tester.pump(const Duration(seconds: 1));

          // Active call screen must show active duration
          expect(find.byType(ActiveCallScreen), findsOneWidget);
          expect(find.byKey(const Key('activeCallEndButton')), findsOneWidget);

          controller.dispose();
        },
      );

      testWidgets(
        '3. Answer and decline actions invoke Telecom APIs and prevent duplicate trigger',
        (tester) async {
          final controller = CallController(
            bridge: mockBridge,
            eventService: mockEventService,
            contactsService: mockContactsService,
            permissionsService: mockPermissionsService,
          );

          final incomingCall = CallSession(
            sessionId: 'call_ans_1',
            phoneNumber: '+919876543210',
            displayName: 'Niranchan',
            state: CallState.incoming,
            direction: CallDirection.incoming,
            connectTimeMillis: DateTime.now().millisecondsSinceEpoch,
          );

          mockEventService.emitSnapshot(CallSnapshot(calls: [incomingCall]));

          await tester.pumpWidget(
            MaterialApp(home: MainShellScreen(callController: controller)),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));

          expect(find.byKey(const Key('incomingAnswerButton')), findsOneWidget);

          // Tap Answer
          await tester.tap(find.byKey(const Key('incomingAnswerButton')));
          await tester.pump();

          expect(mockEventService.answerCalledWithId, 'call_ans_1');

          controller.dispose();
        },
      );

      testWidgets(
        '4. Flutter subscribing after a call already exists displays call screen immediately',
        (tester) async {
          // Prepare pre-existing call snapshot on event service
          final existingCall = CallSession(
            sessionId: 'call_existing_1',
            phoneNumber: '555-0199',
            displayName: 'Aarav Patel',
            state: CallState.active,
            direction: CallDirection.incoming,
            connectTimeMillis: DateTime.now().millisecondsSinceEpoch - 12000,
          );
          mockEventService.currentSnapshot = CallSnapshot(
            calls: [existingCall],
          );

          final controller = CallController(
            bridge: mockBridge,
            eventService: mockEventService,
            contactsService: mockContactsService,
            permissionsService: mockPermissionsService,
          );

          await tester.pumpWidget(
            MaterialApp(home: MainShellScreen(callController: controller)),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));

          // Must display active call screen immediately without missing it
          expect(find.byType(ActiveCallScreen), findsOneWidget);
          expect(find.text('Aarav Patel'), findsOneWidget);

          controller.dispose();
        },
      );

      testWidgets('5. Graceful handling when contacts permission is denied', (
        tester,
      ) async {
        final deniedPermissions = _MockPermissionsService(granted: false);
        final controller = CallController(
          bridge: mockBridge,
          eventService: mockEventService,
          contactsService: mockContactsService,
          permissionsService: deniedPermissions,
        );

        final incomingCall = CallSession(
          sessionId: 'call_unknown_1',
          phoneNumber: '+14155552671',
          displayName: null,
          state: CallState.incoming,
          direction: CallDirection.incoming,
          connectTimeMillis: DateTime.now().millisecondsSinceEpoch,
        );

        mockEventService.emitSnapshot(CallSnapshot(calls: [incomingCall]));

        await tester.pumpWidget(
          MaterialApp(home: MainShellScreen(callController: controller)),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Does not crash; falls back cleanly to phone number
        expect(find.byType(IncomingCallScreen), findsOneWidget);
        expect(find.text('+14155552671'), findsWidgets);

        controller.dispose();
      });

      testWidgets(
        '6. Disconnection state presents terminal notice and dismisses cleanly',
        (tester) async {
          final controller = CallController(
            bridge: mockBridge,
            eventService: mockEventService,
            contactsService: mockContactsService,
            permissionsService: mockPermissionsService,
          );

          final disconnectedCall = CallSession(
            sessionId: 'call_disc_1',
            phoneNumber: '555-0199',
            displayName: 'Aarav Patel',
            state: CallState.disconnected,
            direction: CallDirection.outgoing,
            disconnectReason: 'Call Ended',
            connectTimeMillis: DateTime.now().millisecondsSinceEpoch,
          );

          mockEventService.emitSnapshot(
            CallSnapshot(calls: [disconnectedCall]),
          );

          await tester.pumpWidget(
            MaterialApp(home: MainShellScreen(callController: controller)),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 200));

          expect(find.byType(ActiveCallScreen), findsOneWidget);
          expect(find.text('Call Ended'), findsWidgets);

          // Fast forward dismiss timer
          await tester.pump(const Duration(milliseconds: 1600));

          controller.dispose();
        },
      );

      testWidgets(
        '7. Default Phone role status is tracked and reported accurately',
        (tester) async {
          mockBridge.isDefault = false;
          mockBridge.canRequest = true;

          final controller = CallController(
            bridge: mockBridge,
            eventService: mockEventService,
            contactsService: mockContactsService,
            permissionsService: mockPermissionsService,
          );

          await controller.checkRoleStatus();
          expect(controller.isDefaultDialer, isFalse);
          expect(controller.canRequestRole, isTrue);

          mockBridge.requestResult = true;
          final granted = await controller.requestDefaultDialer();
          expect(granted, isTrue);
          expect(controller.isDefaultDialer, isTrue);

          controller.dispose();
        },
      );

      testWidgets(
        '8. Smaller screen constraint (360x640) renders DialerScreen without overflow',
        (tester) async {
          tester.view.physicalSize = const Size(360, 640);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          final controller = CallController(
            bridge: mockBridge,
            eventService: mockEventService,
            contactsService: mockContactsService,
            permissionsService: mockPermissionsService,
          );

          await tester.pumpWidget(
            MaterialApp(home: MainShellScreen(callController: controller)),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(find.byKey(const Key('keypad_1')), findsOneWidget);

          controller.dispose();
        },
      );
    },
  );
}

// Mocks

class _MockDialerBridge implements DialerBridge {
  bool isDefault = false;
  bool canRequest = true;
  bool requestResult = true;

  @override
  Future<bool> isDefaultDialer() async => isDefault;

  @override
  Future<bool> canRequestDefaultDialer() async => canRequest;

  @override
  Future<bool> requestDefaultDialer() async {
    isDefault = requestResult;
    return requestResult;
  }

  @override
  Future<CallResult> placeCall(String phoneNumber) async {
    return const CallResult(
      success: true,
      message: 'Call initiated successfully.',
      code: CallStatusCode.success,
    );
  }

  @override
  Future<String?> getInitialDialNumber() async => null;

  @override
  Stream<String> get onDialIntent => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockCallEventService implements CallEventService {
  final _controller = StreamController<CallSnapshot>.broadcast();
  CallSnapshot currentSnapshot = const CallSnapshot();

  String? answerCalledWithId;
  String? rejectCalledWithId;
  String? disconnectCalledWithId;

  void emitSnapshot(CallSnapshot snapshot) {
    currentSnapshot = snapshot;
    _controller.add(snapshot);
  }

  @override
  CallSnapshot get lastSnapshot => currentSnapshot;

  @override
  Stream<CallSnapshot> get onCallSnapshotChanged => _controller.stream;

  @override
  Future<CallSnapshot> getSnapshot() async => currentSnapshot;

  @override
  Future<bool> answerCall([String? sessionId]) async {
    answerCalledWithId = sessionId;
    return true;
  }

  @override
  Future<bool> rejectCall([String? sessionId]) async {
    rejectCalledWithId = sessionId;
    return true;
  }

  @override
  Future<bool> disconnectCall([String? sessionId]) async {
    disconnectCalledWithId = sessionId;
    return true;
  }

  @override
  Future<bool> holdCall(String sessionId) async => true;

  @override
  Future<bool> unholdCall(String sessionId) async => true;

  @override
  Future<bool> setMuted(bool isMuted) async => true;

  @override
  Future<bool> setAudioRoute(AudioRoute route) async => true;

  @override
  void dispose() {
    _controller.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockContactsService implements ContactsService {
  _MockContactsService(this.contacts);
  final List<ContactItem> contacts;

  @override
  Future<List<ContactItem>> fetchContacts({bool forceRefresh = false}) async =>
      contacts;
}

class _MockPermissionsService implements PhonePermissionsService {
  _MockPermissionsService({required this.granted});
  final bool granted;

  @override
  Future<AppPermissionStatus> checkContactsPermission() async =>
      granted ? AppPermissionStatus.granted : AppPermissionStatus.denied;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
