import 'package:flutter/material.dart';
import 'sentry_service.dart';
import 'telegram_service.dart';

/// Global Error Handler untuk TaskFlow Pro
/// Handles all errors, captures ke Sentry dan kirim notif ke Telegram
class ErrorHandler {
  /// Initialize error handler
  static Future<void> init() async {
    // Initialize Sentry
    await SentryService.init();

    // Set global error handler untuk Flutter errors
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      handleError(
        details.exception,
        details.stack,
        context: 'Flutter Error',
        extras: {
          'library': details.library,
          'context': details.context?.toString(),
        },
      );
    };

    // Set global error handler untuk uncaught async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      handleError(
        error,
        stack,
        context: 'Uncaught Async Error',
      );
      return true;
    };

    debugPrint('ErrorHandler initialized');
  }

  /// Handle error dan kirim ke Sentry + Telegram
  static void handleError(
    dynamic error, {
    StackTrace? stack,
    String? context,
    Map<String, dynamic>? extras,
    bool sendToTelegram = true,
  }) {
    debugPrint('ErrorHandler caught error: $error');

    // Capture ke Sentry
    SentryService.captureException(
      error,
      stackTrace: stack,
      extras: extras,
    );

    // Kirim ke Telegram (untuk critical errors)
    if (sendToTelegram && _isCriticalError(error)) {
      TelegramService.sendErrorReport(
        error: error.toString(),
        stackTrace: stack?.toString(),
        context: context,
        extras: extras,
      );
    }
  }

  /// Check apakah error adalah critical error
  static bool _isCriticalError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Critical error keywords
    const criticalKeywords = [
      'crash',
      'fatal',
      'exception',
      'failed to load',
      'network',
      'database',
      'authentication',
      'firebase',
    ];

    return criticalKeywords.any((keyword) => errorString.contains(keyword));
  }

  /// Handle error dari try-catch block
  static void tryCatchError(
    dynamic error,
    StackTrace? stack, {
    String? context,
    Map<String, dynamic>? extras,
  }) {
    handleError(
      error,
      stack: stack,
      context: context,
      extras: extras,
    );
  }

  /// Report user feedback
  static Future<void> reportUserFeedback({
    required String name,
    required String feedback,
    String? email,
  }) async {
    // Kirim ke Telegram
    await TelegramService.sendUserFeedback(
      name: name,
      feedback: feedback,
      email: email,
    );

    // Capture ke Sentry sebagai user feedback
    await SentryService.captureUserFeedback(
      eventId: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email ?? '',
      comments: feedback,
    );
  }

  /// Handle crash report
  static void handleCrash({
    required String error,
    String? stackTrace,
    String? userId,
    String? userEmail,
    Map<String, dynamic>? deviceInfo,
  }) {
    // Capture ke Sentry
    SentryService.captureException(
      error,
      stackTrace: stackTrace != null ? StackTrace.fromString(stackTrace) : null,
      extras: {
        'user_id': userId,
        'user_email': userEmail,
        ...?deviceInfo,
      },
    );

    // Kirim crash report ke Telegram
    TelegramService.sendCrashReport(
      error: error,
      stackTrace: stackTrace,
      userId: userId,
      userEmail: userEmail,
      deviceInfo: deviceInfo,
    );
  }

  /// Log breadcrumb untuk tracking
  static void logBreadcrumb({
    required String message,
    String? category,
    Map<String, dynamic>? data,
  }) {
    SentryService.addBreadcrumb(
      message: message,
      category: category,
      data: data,
    );
  }

  /// Set user info untuk error context
  static void setUserInfo({
    String? id,
    String? email,
    String? username,
  }) {
    SentryService.setUser(
      id: id,
      email: email,
      username: username,
    );
  }
}
