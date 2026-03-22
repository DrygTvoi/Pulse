// Widget tests for MessageBubble (lib/widgets/message_bubble.dart).
//
// Tests focus on structure and rendering: alignment, timestamp display,
// and status icon presence for different statuses.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/widgets/message_bubble.dart';

Widget buildTestableWidget(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MessageBubble', () {
    // ── Test 1: Sent message aligns right ─────────────────────────────────────

    testWidgets('sent message (isMe=true) aligns to centerRight',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        MessageBubble(
          message: 'Hello there',
          timestamp: DateTime(2026, 3, 21, 14, 30),
          isMe: true,
          status: 'sent',
        ),
      ));
      await tester.pumpAndSettle();

      final align = tester.widget<Align>(find.byType(Align).first);
      expect(align.alignment, Alignment.centerRight);
    });

    // ── Test 2: Received message aligns left ──────────────────────────────────

    testWidgets('received message (isMe=false) aligns to centerLeft',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        MessageBubble(
          message: 'Hi back',
          timestamp: DateTime(2026, 3, 21, 14, 31),
          isMe: false,
        ),
      ));
      await tester.pumpAndSettle();

      final align = tester.widget<Align>(find.byType(Align).first);
      expect(align.alignment, Alignment.centerLeft);
    });

    // ── Test 3: Shows timestamp ───────────────────────────────────────────────

    testWidgets('displays formatted timestamp', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        MessageBubble(
          message: 'Timestamp test',
          timestamp: DateTime(2026, 3, 21, 9, 5),
          isMe: true,
          status: 'sent',
        ),
      ));
      await tester.pumpAndSettle();

      // Timestamp should be formatted as HH:MM, padded with leading zeros.
      expect(find.text('09:05'), findsOneWidget);
    });

    // ── Test 4: Status icon for 'sending' ─────────────────────────────────────

    testWidgets('shows CircularProgressIndicator for sending status',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        MessageBubble(
          message: 'Sending...',
          timestamp: DateTime(2026, 3, 21, 10, 0),
          isMe: true,
          status: 'sending',
        ),
      ));
      // Use pump() instead of pumpAndSettle() because the
      // CircularProgressIndicator animates indefinitely.
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // ── Test 5: Status icon for 'sent' ────────────────────────────────────────

    testWidgets('shows single check icon for sent status',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        MessageBubble(
          message: 'Sent message',
          timestamp: DateTime(2026, 3, 21, 10, 1),
          isMe: true,
          status: 'sent',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.done_rounded), findsOneWidget);
    });

    // ── Test 6: Status icon for 'delivered' ───────────────────────────────────

    testWidgets('shows double check icon for delivered status',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        MessageBubble(
          message: 'Delivered message',
          timestamp: DateTime(2026, 3, 21, 10, 2),
          isMe: true,
          status: 'delivered',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.done_all_rounded), findsOneWidget);
    });

    // ── Test 7: Status icon for 'read' ────────────────────────────────────────

    testWidgets('shows double check icon for read status',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        MessageBubble(
          message: 'Read message',
          timestamp: DateTime(2026, 3, 21, 10, 3),
          isMe: true,
          status: 'read',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.done_all_rounded), findsOneWidget);
    });

    // ── Test 8: Status icon for 'failed' ──────────────────────────────────────

    testWidgets('shows error icon for failed status',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        MessageBubble(
          message: 'Failed message',
          timestamp: DateTime(2026, 3, 21, 10, 4),
          isMe: true,
          status: 'failed',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    // ── Test 9: Received message shows no status icon ─────────────────────────

    testWidgets('received message does not show status icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        MessageBubble(
          message: 'Incoming message',
          timestamp: DateTime(2026, 3, 21, 10, 5),
          isMe: false,
          status: '',
        ),
      ));
      await tester.pumpAndSettle();

      // No status icons should be present for received messages.
      expect(find.byIcon(Icons.done_rounded), findsNothing);
      expect(find.byIcon(Icons.done_all_rounded), findsNothing);
      expect(find.byIcon(Icons.error_outline_rounded), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    // ── Test 10: Message text is displayed ─────────────────────────────────────

    testWidgets('renders the message text', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        MessageBubble(
          message: 'Hello World',
          timestamp: DateTime(2026, 3, 21, 12, 0),
          isMe: true,
          status: 'sent',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Hello World'), findsOneWidget);
    });
  });
}
