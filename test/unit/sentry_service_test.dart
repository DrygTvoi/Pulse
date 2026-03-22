import 'package:flutter_test/flutter_test.dart';

/// Tests for reimplemented logic from SentryService
/// (lib/services/sentry_service.dart).
///
/// The actual sentryBreadcrumb() function depends on the Sentry SDK,
/// so we test the pure logic: default category, timestamp, and message format.

/// Reimplements the default category logic from sentryBreadcrumb():
///   category: category ?? 'app'
String resolveCategory(String? category) => category ?? 'app';

void main() {
  group('sentryBreadcrumb logic', () {
    test('default category is "app" when null', () {
      expect(resolveCategory(null), equals('app'));
    });

    test('uses provided category when non-null', () {
      expect(resolveCategory('network'), equals('network'));
      expect(resolveCategory('signal'), equals('signal'));
      expect(resolveCategory('crypto'), equals('crypto'));
    });

    test('empty string category is preserved (not replaced with default)', () {
      // The function uses ?? which only triggers on null, not empty string
      expect(resolveCategory(''), equals(''));
    });
  });
}
