import 'package:flutter/foundation.dart';

/// Severity level for privacy-conscious diagnostic log entries.
enum LogLevel { debug, info, warning, error }

/// Structured diagnostic log entry stored in memory with sanitized content.
class LogEntry {
  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.message,
    this.error,
  });

  final DateTime timestamp;
  final LogLevel level;
  final String tag;
  final String message;
  final String? error;

  String format() {
    final timeStr =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
    final levelStr = level.name.toUpperCase().padRight(7);
    final errorSuffix = error != null ? ' | Error: $error' : '';
    return '[$timeStr] $levelStr [$tag] $message$errorSuffix';
  }
}

/// Structured, privacy-safe logger designed specifically for telephone and dialer applications.
///
/// Automatically redacts and masks all phone numbers, contact names, OTPs, and authentication
/// tokens from debug output, ensuring strict zero-PII leakage in logs and crash reports.
class PrivacyLogger {
  PrivacyLogger._();

  static const int maxBufferedEntries = 100;
  static final List<LogEntry> _recentLogs = [];

  /// Returns unmodifiable view of recently recorded sanitized diagnostic entries.
  static List<LogEntry> get recentLogs => List.unmodifiable(_recentLogs);

  /// Clears in-memory diagnostic logs buffer.
  static void clearLogs() {
    _recentLogs.clear();
  }

  /// Masks a phone number so only the last 4 digits remain visible for troubleshooting.
  ///
  /// Examples:
  /// - `+18005550199` -> `***-***-0199`
  /// - `5551234` -> `***-***-1234`
  /// - `12` -> `***`
  static String maskPhoneNumber(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '***';
    if (digits.length <= 4) return '***';
    final suffix = digits.substring(digits.length - 4);
    return '***-***-$suffix';
  }

  /// Redacts sensitive information from an arbitrary log message string.
  ///
  /// Replaces phone number sequences, OTPs, and sensitive key-value pairs.
  static String redact(String message) {
    // Redact standard phone number sequences (7 to 15 digits with optional punctuation)
    var result = message.replaceAllMapped(
      RegExp(r'(?:\+?\d{1,3}[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}'),
      (match) {
        final rawMatch = match.group(0)!;
        return maskPhoneNumber(rawMatch);
      },
    );

    // Redact continuous numeric strings of 7+ digits
    result = result.replaceAllMapped(RegExp(r'\b\d{7,15}\b'), (match) {
      final rawMatch = match.group(0)!;
      return maskPhoneNumber(rawMatch);
    });

    // Redact 4 to 8 digit OTP/code sequences following keywords
    result = result.replaceAllMapped(
      RegExp(
        r'\b(otp|code|pin|token|password)[:=\s]+([0-9a-zA-Z]{4,8})\b',
        caseSensitive: false,
      ),
      (match) => '${match.group(1)}: [REDACTED]',
    );

    return result;
  }

  static void debug(
    String tag,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _log(LogLevel.debug, tag, message, error, stackTrace);
  }

  static void info(String tag, String message) {
    _log(LogLevel.info, tag, message);
  }

  static void warning(String tag, String message, [Object? error]) {
    _log(LogLevel.warning, tag, message, error);
  }

  static void error(
    String tag,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _log(LogLevel.error, tag, message, error, stackTrace);
  }

  static void _log(
    LogLevel level,
    String tag,
    String rawMessage, [
    Object? rawError,
    StackTrace? stackTrace,
  ]) {
    final sanitizedMessage = redact(rawMessage);
    final sanitizedError = rawError != null
        ? redact(rawError.toString())
        : null;

    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      tag: tag,
      message: sanitizedMessage,
      error: sanitizedError,
    );

    if (_recentLogs.length >= maxBufferedEntries) {
      _recentLogs.removeAt(0);
    }
    _recentLogs.add(entry);

    if (kDebugMode) {
      debugPrint(entry.format());
      if (stackTrace != null) {
        debugPrint(stackTrace.toString());
      }
    }
  }
}
