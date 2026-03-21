import 'dart:convert';
import 'package:dio/dio.dart';

/// Telegram Service untuk mengirim error report dan notifikasi
class TelegramService {
  static const String _botToken = String.fromEnvironment(
    'TELEGRAM_BOT_TOKEN',
    defaultValue: '',
  );

  static const String _chatId = String.fromEnvironment(
    'TELEGRAM_CHAT_ID',
    defaultValue: '',
  );

  static const String _apiBaseUrl = 'https://api.telegram.org/bot';

  static bool get isEnabled => _botToken.isNotEmpty && _chatId.isNotEmpty;

  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Kirim error report ke Telegram
  static Future<bool> sendErrorReport({
    required String error,
    String? stackTrace,
    String? context,
    Map<String, dynamic>? extras,
  }) async {
    if (!isEnabled) {
      print('Telegram service disabled: TELEGRAM_BOT_TOKEN or TELEGRAM_CHAT_ID not set');
      return false;
    }

    try {
      final message = _formatErrorMessage(
        error: error,
        stackTrace: stackTrace,
        context: context,
        extras: extras,
      );

      final response = await _dio.post(
        '$_apiBaseUrl$_botToken/sendMessage',
        data: {
          'chat_id': _chatId,
          'text': message,
          'parse_mode': 'Markdown',
          'disable_web_page_preview': true,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Failed to send error report to Telegram: $e');
      return false;
    }
  }

  /// Kirim notifikasi biasa ke Telegram
  static Future<bool> sendNotification({
    required String message,
    bool showPreview = true,
  }) async {
    if (!isEnabled) return false;

    try {
      final response = await _dio.post(
        '$_apiBaseUrl$_botToken/sendMessage',
        data: {
          'chat_id': _chatId,
          'text': message,
          'parse_mode': 'Markdown',
          'disable_web_page_preview': !showPreview,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Failed to send notification to Telegram: $e');
      return false;
    }
  }

  /// Kirim pesan dengan action button
  static Future<bool> sendMessageWithButton({
    required String message,
    required String buttonText,
    required String buttonUrl,
  }) async {
    if (!isEnabled) return false;

    try {
      final response = await _dio.post(
        '$_apiBaseUrl$_botToken/sendMessage',
        data: {
          'chat_id': _chatId,
          'text': message,
          'parse_mode': 'Markdown',
          'reply_markup': {
            'inline_keyboard': [
              [
                {
                  'text': buttonText,
                  'url': buttonUrl,
                }
              ]
            ]
          }
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Failed to send message with button to Telegram: $e');
      return false;
    }
  }

  /// Format error message jadi readable
  static String _formatErrorMessage({
    required String error,
    String? stackTrace,
    String? context,
    Map<String, dynamic>? extras,
  }) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('🚨 *TaskFlow Pro Error Report*');
    buffer.writeln('');

    // Error message
    buffer.writeln('*Error:*');
    buffer.writeln('```');
    buffer.writeln(error.length > 500 ? error.substring(0, 500) + '...' : error);
    buffer.writeln('```');
    buffer.writeln('');

    // Context
    if (context != null && context.isNotEmpty) {
      buffer.writeln('*Context:*');
      buffer.writeln(context);
      buffer.writeln('');
    }

    // Stack trace (truncated)
    if (stackTrace != null && stackTrace.isNotEmpty) {
      buffer.writeln('*Stack Trace:*');
      buffer.writeln('```');
      final truncatedTrace = stackTrace.length > 1000
          ? stackTrace.substring(0, 1000) + '...'
          : stackTrace;
      buffer.writeln(truncatedTrace);
      buffer.writeln('```');
      buffer.writeln('');
    }

    // Extras
    if (extras != null && extras.isNotEmpty) {
      buffer.writeln('*Additional Info:*');
      extras.forEach((key, value) {
        buffer.writeln('• **$key**: $value');
      });
      buffer.writeln('');
    }

    // Footer
    buffer.writeln('---');
    buffer.writeln('📱 TaskFlow Pro v${const String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0')}');
    buffer.writeln('🕐 ${DateTime.now().toIso8601String()}');

    return buffer.toString();
  }

  /// Kirim user feedback ke Telegram
  static Future<bool> sendUserFeedback({
    required String name,
    required String feedback,
    String? email,
  }) async {
    if (!isEnabled) return false;

    try {
      final message = '''
💬 *User Feedback - TaskFlow Pro*

*Name:* $name
${email != null ? '*Email:* $email' : ''}

*Feedback:*
$feedback

---
📱 TaskFlow Pro v${const String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0')}
🕐 ${DateTime.now().toIso8601String()}
''';

      final response = await _dio.post(
        '$_apiBaseUrl$_botToken/sendMessage',
        data: {
          'chat_id': _chatId,
          'text': message,
          'parse_mode': 'Markdown',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Failed to send user feedback to Telegram: $e');
      return false;
    }
  }

  /// Kirim crash report dengan screenshot info (jika ada)
  static Future<bool> sendCrashReport({
    required String error,
    String? stackTrace,
    String? userId,
    String? userEmail,
    Map<String, dynamic>? deviceInfo,
  }) async {
    if (!isEnabled) return false;

    try {
      final message = '''
🔴 *CRASH REPORT - TaskFlow Pro*

*User:* ${userId ?? 'Unknown'} ${userEmail != null ? '($userEmail)' : ''}

*Error:*
```
${error.length > 500 ? error.substring(0, 500) + '...' : error}
```

${stackTrace != null ? '''
*Stack Trace:*
```
${stackTrace.length > 1000 ? stackTrace.substring(0, 1000) + '...' : stackTrace}
```
''' : ''}

${deviceInfo != null ? '''
*Device Info:*
${deviceInfo.entries.map((e) => '• ${e.key}: ${e.value}').join('\n')}
''' : ''}

---
📱 TaskFlow Pro v${const String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0')}
🕐 ${DateTime.now().toIso8601String()}
🔥 URGENT - Needs immediate attention!
''';

      final response = await _dio.post(
        '$_apiBaseUrl$_botToken/sendMessage',
        data: {
          'chat_id': _chatId,
          'text': message,
          'parse_mode': 'Markdown',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Failed to send crash report to Telegram: $e');
      return false;
    }
  }
}
