import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_dialer/core/permissions/phone_permissions_service.dart';
import 'package:liquid_dialer/features/recents/controllers/recents_controller.dart';
import 'package:liquid_dialer/features/recents/models/call_history_item.dart';
import 'package:liquid_dialer/features/recents/recents_screen.dart';
import 'package:liquid_dialer/features/recents/services/call_history_service.dart';
import 'package:liquid_dialer/features/recents/widgets/call_history_tile.dart';

class MockPhonePermissionsService implements PhonePermissionsService {
  MockPhonePermissionsService({
    this.callLogStatus = AppPermissionStatus.granted,
  });

  AppPermissionStatus callLogStatus;
  bool requestedCallLog = false;
  bool openedSettings = false;

  @override
  Future<AppPermissionStatus> checkContactsPermission() async =>
      AppPermissionStatus.granted;

  @override
  Future<AppPermissionStatus> requestContactsPermission() async =>
      AppPermissionStatus.granted;

  @override
  Future<AppPermissionStatus> checkCallLogPermission() async => callLogStatus;

  @override
  Future<AppPermissionStatus> requestCallLogPermission() async {
    requestedCallLog = true;
    return callLogStatus;
  }

  @override
  Future<AppPermissionStatus> checkCallPhonePermission() async => callLogStatus;

  @override
  Future<AppPermissionStatus> requestCallPhonePermission() async =>
      callLogStatus;

  @override
  Future<AppPermissionStatus> checkNotificationPermission() async =>
      callLogStatus;

  @override
  Future<AppPermissionStatus> requestNotificationPermission() async =>
      callLogStatus;

  @override
  Future<bool> openAppSettings() async {
    openedSettings = true;
    return true;
  }
}

void main() {
  group('Recents Call History Unit and Widget Tests', () {
    late MockPhonePermissionsService permissionsService;

    setUp(() {
      permissionsService = MockPhonePermissionsService();
    });

    test('1. Call-history sorting orders entries newest first', () async {
      final now = DateTime.now();
      final itemOld = CallHistoryItem(
        number: '111',
        callType: CallHistoryType.incoming,
        timestamp: now.subtract(const Duration(hours: 5)),
      );
      final itemNewest = CallHistoryItem(
        number: '222',
        callType: CallHistoryType.outgoing,
        timestamp: now.subtract(const Duration(minutes: 5)),
      );
      final itemMiddle = CallHistoryItem(
        number: '333',
        callType: CallHistoryType.missed,
        timestamp: now.subtract(const Duration(hours: 1)),
      );

      final controller = RecentsController(
        permissionsService: permissionsService,
        callHistoryService: MockCallHistoryService(
          history: [itemOld, itemNewest, itemMiddle],
        ),
      );

      await controller.loadCallHistory();

      expect(controller.callHistory.length, 3);
      expect(controller.callHistory[0].number, '222');
      expect(controller.callHistory[1].number, '333');
      expect(controller.callHistory[2].number, '111');
    });

    test(
      '2. Call-type labels, display names, and durations format accurately',
      () {
        final incoming = CallHistoryItem(
          name: 'Alan Turing',
          number: '+1234567890',
          callType: CallHistoryType.incoming,
          timestamp: DateTime.now(),
          durationSeconds: 125,
        );
        final missed = CallHistoryItem(
          number: '9876543210',
          callType: CallHistoryType.missed,
          timestamp: DateTime.now(),
          durationSeconds: 0,
        );
        final rejected = CallHistoryItem(
          number: '',
          callType: CallHistoryType.rejected,
          timestamp: DateTime.now(),
          durationSeconds: 0,
        );

        expect(incoming.displayName, 'Alan Turing');
        expect(incoming.callType.label, 'Incoming');
        expect(incoming.formattedDuration, '2m 5s');

        expect(missed.displayName, '9876543210');
        expect(missed.callType.label, 'Missed');
        expect(missed.formattedDuration, 'Missed');

        expect(rejected.displayName, 'Unknown Caller');
        expect(rejected.callType.label, 'Rejected');
        expect(rejected.formattedDuration, 'Rejected');
      },
    );

    test('3. Empty call history produces proper empty state', () async {
      final controller = RecentsController(
        permissionsService: permissionsService,
        callHistoryService: MockCallHistoryService(history: []),
      );

      await controller.loadCallHistory();

      expect(controller.callHistory, isEmpty);
      expect(controller.isEmpty, isTrue);
      expect(controller.isLoading, isFalse);
    });

    test('4. Permission-denied states and openSettings action', () async {
      permissionsService.callLogStatus = AppPermissionStatus.denied;

      final controller = RecentsController(
        permissionsService: permissionsService,
        callHistoryService: MockCallHistoryService(),
      );

      await controller.initialize();
      expect(controller.isPermissionGranted, isFalse);
      expect(controller.isPermanentlyDenied, isFalse);

      // User initiates explicit request
      permissionsService.callLogStatus = AppPermissionStatus.permanentlyDenied;
      await controller.requestPermissionAndLoad();

      expect(controller.isPermissionGranted, isFalse);
      expect(controller.isPermanentlyDenied, isTrue);

      await controller.openAppSettings();
      expect(permissionsService.openedSettings, isTrue);
    });

    test('5. Loading and error states with retry action', () async {
      final controller = RecentsController(
        permissionsService: permissionsService,
        callHistoryService: MockCallHistoryService(shouldThrow: true),
      );

      await controller.loadCallHistory();
      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNotNull);
      expect(controller.errorMessage, contains('Unable to load call history'));
    });

    testWidgets(
      '6. RecentsScreen displays history and enables number selection',
      (tester) async {
        final history = [
          CallHistoryItem(
            name: 'Grace Hopper',
            number: '1010101',
            callType: CallHistoryType.outgoing,
            timestamp: DateTime.now(),
            durationSeconds: 45,
          ),
        ];

        final controller = RecentsController(
          permissionsService: permissionsService,
          callHistoryService: MockCallHistoryService(history: history),
        );

        String? selectedNumber;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecentsScreen(
                controller: controller,
                onSelectNumber: (phone) => selectedNumber = phone,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Recents'), findsOneWidget);
        expect(find.byType(CallHistoryTile), findsOneWidget);
        expect(find.text('Grace Hopper'), findsOneWidget);
        expect(find.text('Outgoing'), findsOneWidget);

        await tester.tap(find.byType(CallHistoryTile));
        await tester.pumpAndSettle();

        expect(selectedNumber, '1010101');
      },
    );
  });
}
