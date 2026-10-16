import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_dialer/features/dialer/dialer_controller.dart';

void main() {
  group('DialerController Unit Tests', () {
    late DialerController controller;

    setUp(() {
      controller = DialerController(callService: const MockCallService());
    });

    test('initial state is empty and safe', () {
      expect(controller.rawNumber, isEmpty);
      expect(controller.formattedNumber, isEmpty);
      expect(controller.hasNumber, isFalse);
      expect(controller.lastCallFeedback, isNull);
    });

    test('appendDigit updates raw and formatted numbers correctly', () {
      controller.appendDigit('5');
      controller.appendDigit('5');
      controller.appendDigit('5');
      expect(controller.rawNumber, '555');
      expect(controller.formattedNumber, '555');
      expect(controller.hasNumber, isTrue);

      controller.appendDigit('1');
      controller.appendDigit('2');
      controller.appendDigit('3');
      controller.appendDigit('4');
      // 7 digits: 555 1234
      expect(controller.rawNumber, '5551234');
      expect(controller.formattedNumber, '555 1234');
    });

    test('formatting groups 10-digit standard numbers', () {
      const number = '9876543210';
      for (final char in number.split('')) {
        controller.appendDigit(char);
      }
      expect(controller.rawNumber, '9876543210');
      expect(controller.formattedNumber, '987 654 3210');
    });

    test('formatting preserves USSD/special codes with * and #', () {
      const code = '*#06#';
      for (final char in code.split('')) {
        controller.appendDigit(char);
      }
      expect(controller.rawNumber, '*#06#');
      expect(controller.formattedNumber, '*#06#');
    });

    test('deleteDigit removes exactly one character at a time', () {
      controller.appendDigit('1');
      controller.appendDigit('2');
      controller.appendDigit('3');

      controller.deleteDigit();
      expect(controller.rawNumber, '12');

      controller.deleteDigit();
      expect(controller.rawNumber, '1');

      controller.deleteDigit();
      expect(controller.rawNumber, '');
      expect(controller.hasNumber, isFalse);
    });

    test('deleteDigit and clearNumber do not crash on empty state', () {
      expect(() => controller.deleteDigit(), returnsNormally);
      expect(controller.rawNumber, isEmpty);

      expect(() => controller.clearNumber(), returnsNormally);
      expect(controller.rawNumber, isEmpty);
    });

    test('clearNumber clears the complete number instantly', () {
      controller.appendDigit('1');
      controller.appendDigit('8');
      controller.appendDigit('0');
      controller.appendDigit('0');
      expect(controller.rawNumber, '1800');

      controller.clearNumber();
      expect(controller.rawNumber, isEmpty);
      expect(controller.hasNumber, isFalse);
    });

    test('call returns Phase 1 placeholder message', () async {
      final message = await controller.call();
      expect(message, 'Calling is not available yet.');
      expect(controller.lastCallFeedback, 'Calling is not available yet.');
    });

    test('supports injecting custom CallService for future phases', () async {
      final customService = _TestCallService();
      final customController = DialerController(callService: customService);

      customController.appendDigit('911');
      final result = await customController.call();

      expect(result, 'Custom: 911');
      expect(customService.lastAttemptedNumber, '911');
    });
  });
}

class _TestCallService implements CallService {
  String? lastAttemptedNumber;

  @override
  Future<String> placeCall(String phoneNumber) async {
    lastAttemptedNumber = phoneNumber;
    return 'Custom: $phoneNumber';
  }
}
