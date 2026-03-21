import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Sentry Service untuk Error Tracking dan Reporting
class SentryService {
  static const String _dsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '', // Set di Vercel/GitHub Secrets
  );

  static bool get isEnabled => _dsn.isNotEmpty;

  /// Initialize Sentry
  static Future<void> init() async {
    if (!isEnabled) {
      debugPrint('Sentry disabled: SENTRY_DSN not set');
      return;
    }

    await SentryFlutter.init(
      (options) {
        options.dsn = _dsn;
        options.tracesSampleRate = 1.0;
        options.profilesSampleRate = 1.0;
        options.sessionSamplingRate = 1.0;

        // Filter sensitive data
        options.beforeSend = (event, hint) {
          // Remove sensitive data dari breadcrumbs
          event.breadcrumbs?.removeWhere((breadcrumb) {
            final message = breadcrumb.message?.toLowerCase() ?? '';
            return message.contains('password') ||
                message.contains('token') ||
                message.contains('api_key') ||
                message.contains('secret');
          });

          return event;
        };

        // Environment info
        options.environment = const String.fromEnvironment(
          'ENVIRONMENT',
          defaultValue: 'production',
        );

        // Release version
        options.release = const String.fromEnvironment(
          'APP_VERSION',
          defaultValue: '1.0.0',
        );

        debugPrint('Sentry initialized successfully');
      },
      appRunner: () => debugPrint('App runner initialized'),
    );
  }

  /// Capture exception dan kirim ke Sentry
  static void captureException(
    dynamic exception, {
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) {
    if (!isEnabled) return;

    Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      hint: extras,
    );
  }

  /// Capture message
  static void captureMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
  }) {
    if (!isEnabled) return;

    Sentry.captureMessage(
      message,
      level: level,
    );
  }

  /// Capture user feedback
  static Future<void> captureUserFeedback({
    required String eventId,
    required String name,
    required String email,
    required String comments,
  }) async {
    if (!isEnabled) return;

    await Sentry.captureUserFeedback(
      UserFeedback(
        eventId: SentryId(eventId),
        name: name,
        email: email,
        comments: comments,
      ),
    );
  }

  /// Set user context
  static void setUser({
    String? id,
    String? email,
    String? username,
  }) {
    if (!isEnabled) return;

    Sentry.setUser(
      User(
        id: id,
        email: email,
        username: username,
      ),
    );
  }

  /// Add breadcrumb untuk tracking
  static void addBreadcrumb({
    required String message,
    String? category,
    Map<String, dynamic>? data,
  }) {
    if (!isEnabled) return;

    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: category,
        data: data,
      ),
    );
  }

  /// Capture error dari Flutter widget
  static void captureError(
    dynamic error,
    StackTrace? stack, {
    Map<String, dynamic>? extras,
  }) {
    if (!isEnabled) return;

    Sentry.captureException(
      error,
      stackTrace: stack,
      hint: extras,
    );
  }
}
