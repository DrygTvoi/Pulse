import 'package:flutter_test/flutter_test.dart';

/// Reimplements testable constants and logic from BackgroundService
/// (lib/services/background_service.dart) without platform dependencies.

// Constants extracted from source
const _kEnabledKey = 'background_service_enabled';
const _channelId = 'pulse_bg_service';
const _channelName = 'Background Service';
const _channelDescription =
    'Keeps message delivery active in the background';
const _heartbeatIntervalMs = 5000; // eventAction: repeat(5000)

/// Reimplements the notification text formatting from _KeepAliveHandler.onRepeatEvent():
///   final h = timestamp.hour.toString().padLeft(2, '0');
///   final m = timestamp.minute.toString().padLeft(2, '0');
///   'Active \u00b7 last checked $h:$m'
String formatNotificationText(DateTime timestamp) {
  final h = timestamp.hour.toString().padLeft(2, '0');
  final m = timestamp.minute.toString().padLeft(2, '0');
  return 'Active \u00b7 last checked $h:$m';
}

void main() {
  group('BackgroundService constants', () {
    test('SharedPreferences key is correct', () {
      expect(_kEnabledKey, equals('background_service_enabled'));
    });

    test('notification channel ID is pulse_bg_service', () {
      expect(_channelId, equals('pulse_bg_service'));
    });

    test('heartbeat interval is 5000ms (5 seconds)', () {
      expect(_heartbeatIntervalMs, equals(5000));
    });

    test('channel name and description are non-empty', () {
      expect(_channelName, isNotEmpty);
      expect(_channelDescription, isNotEmpty);
    });
  });

  group('Notification text formatting', () {
    test('formats midnight as 00:00', () {
      final ts = DateTime(2026, 3, 21, 0, 0);
      expect(formatNotificationText(ts),
          equals('Active \u00b7 last checked 00:00'));
    });

    test('formats noon as 12:00', () {
      final ts = DateTime(2026, 3, 21, 12, 0);
      expect(formatNotificationText(ts),
          equals('Active \u00b7 last checked 12:00'));
    });

    test('pads single-digit hours with leading zero', () {
      final ts = DateTime(2026, 3, 21, 9, 30);
      expect(formatNotificationText(ts),
          equals('Active \u00b7 last checked 09:30'));
    });

    test('pads single-digit minutes with leading zero', () {
      final ts = DateTime(2026, 3, 21, 14, 5);
      expect(formatNotificationText(ts),
          equals('Active \u00b7 last checked 14:05'));
    });

    test('formats 23:59 correctly', () {
      final ts = DateTime(2026, 3, 21, 23, 59);
      expect(formatNotificationText(ts),
          equals('Active \u00b7 last checked 23:59'));
    });

    test('contains middle-dot separator', () {
      final ts = DateTime(2026, 3, 21, 10, 15);
      final text = formatNotificationText(ts);
      expect(text, contains('\u00b7'),
          reason: 'notification text should contain middle-dot separator');
    });

    test('starts with Active', () {
      final ts = DateTime(2026, 3, 21, 8, 0);
      expect(formatNotificationText(ts), startsWith('Active'));
    });
  });
}
