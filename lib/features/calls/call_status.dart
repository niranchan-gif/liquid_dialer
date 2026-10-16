/// Standard status codes for outgoing call attempts.
enum CallStatusCode {
  success,
  emptyNumber,
  invalidNumber,
  permissionDenied,
  telecomUnavailable,
  securityException,
  callFailed;

  static CallStatusCode fromString(String? code) {
    switch (code) {
      case 'EMPTY_NUMBER':
        return CallStatusCode.emptyNumber;
      case 'INVALID_NUMBER':
        return CallStatusCode.invalidNumber;
      case 'PERMISSION_DENIED':
        return CallStatusCode.permissionDenied;
      case 'TELECOM_UNAVAILABLE':
        return CallStatusCode.telecomUnavailable;
      case 'SECURITY_EXCEPTION':
        return CallStatusCode.securityException;
      default:
        return CallStatusCode.callFailed;
    }
  }
}

/// Represents the normalized result of an outgoing call attempt.
class CallResult {
  const CallResult({
    required this.success,
    required this.message,
    required this.code,
  });

  final bool success;
  final String message;
  final CallStatusCode code;

  factory CallResult.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return const CallResult(
        success: false,
        message: 'No response from platform telecom service.',
        code: CallStatusCode.callFailed,
      );
    }

    final success = map['success'] as bool? ?? false;
    final message =
        map['message'] as String? ??
        (success ? 'Call initiated.' : 'Failed to place call.');
    final rawCode = map['errorCode'] as String?;

    return CallResult(
      success: success,
      message: message,
      code: success
          ? CallStatusCode.success
          : CallStatusCode.fromString(rawCode),
    );
  }

  factory CallResult.emptyNumber() {
    return const CallResult(
      success: false,
      message: 'Please enter a phone number to call.',
      code: CallStatusCode.emptyNumber,
    );
  }

  factory CallResult.invalidNumber() {
    return const CallResult(
      success: false,
      message: 'The entered number is not a valid dialable telephone number.',
      code: CallStatusCode.invalidNumber,
    );
  }
}
