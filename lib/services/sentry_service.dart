import 'package:sentry_flutter/sentry_flutter.dart';

/// Lightweight wrapper for Sentry breadcrumbs.
///
/// Privacy: never pass message content, contact names, or key material.
/// Use generic category labels only.
void sentryBreadcrumb(String message, {String? category}) {
  Sentry.addBreadcrumb(Breadcrumb(
    message: message,
    category: category ?? 'app',
    timestamp: DateTime.now(),
  ));
}
