// Widget tests for StatusViewerScreen (lib/screens/status_viewer_screen.dart).
//
// Tests focus on: status text rendering, progress bar, contact name display,
// close button, multiple entries, and navigation via tapping.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/theme/theme_manager.dart';
import 'package:pulse_messenger/models/user_status.dart';
import 'package:pulse_messenger/screens/status_viewer_screen.dart';

Widget buildTestableWidget(Widget child) {
  return ChangeNotifierProvider<ThemeNotifier>.value(
    value: ThemeNotifier.instance,
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: child,
    ),
  );
}

/// Creates a test UserStatus with given text.
UserStatus _makeStatus(String text) {
  final now = DateTime.now();
  return UserStatus(
    id: 'status-${text.hashCode}',
    text: text,
    createdAt: now,
    expiresAt: now.add(const Duration(hours: 24)),
  );
}

typedef StatusEntry = ({String contactId, String contactName, UserStatus status});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('StatusViewerScreen', () {
    // ── Test 1: Renders status text ───────────────────────────────────────────

    testWidgets('renders status text', (WidgetTester tester) async {
      final entries = <StatusEntry>[
        (
          contactId: 'c1',
          contactName: 'Alice',
          status: _makeStatus('Hello world!'),
        ),
      ];

      await tester.pumpWidget(buildTestableWidget(
        StatusViewerScreen(entries: entries),
      ));
      // Use pump (not pumpAndSettle) — progress bar animates continuously.
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Hello world!'), findsOneWidget);
    });

    // ── Test 2: Renders contact name ──────────────────────────────────────────

    testWidgets('renders contact name', (WidgetTester tester) async {
      final entries = <StatusEntry>[
        (
          contactId: 'c1',
          contactName: 'Bob',
          status: _makeStatus('My status'),
        ),
      ];

      await tester.pumpWidget(buildTestableWidget(
        StatusViewerScreen(entries: entries),
      ));
      // Use pump (not pumpAndSettle) — progress bar animates continuously.
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Bob'), findsOneWidget);
    });

    // ── Test 3: Has progress indicator ────────────────────────────────────────

    testWidgets('has a LinearProgressIndicator for current entry',
        (WidgetTester tester) async {
      final entries = <StatusEntry>[
        (
          contactId: 'c1',
          contactName: 'Charlie',
          status: _makeStatus('Status text'),
        ),
      ];

      await tester.pumpWidget(buildTestableWidget(
        StatusViewerScreen(entries: entries),
      ));
      // Pump once to let animation start (don't settle — animation is continuous)
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    // ── Test 4: Has close button ──────────────────────────────────────────────

    testWidgets('has a close button', (WidgetTester tester) async {
      final entries = <StatusEntry>[
        (
          contactId: 'c1',
          contactName: 'Dave',
          status: _makeStatus('Test'),
        ),
      ];

      await tester.pumpWidget(buildTestableWidget(
        StatusViewerScreen(entries: entries),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    // ── Test 5: Shows initial letter of contact name ──────────────────────────

    testWidgets('shows initial letter of contact name in avatar',
        (WidgetTester tester) async {
      final entries = <StatusEntry>[
        (
          contactId: 'c1',
          contactName: 'Frank',
          status: _makeStatus('A status'),
        ),
      ];

      await tester.pumpWidget(buildTestableWidget(
        StatusViewerScreen(entries: entries),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('F'), findsOneWidget);
    });

    // ── Test 6: Multiple entries show multiple progress segments ──────────────

    testWidgets('multiple entries show multiple progress segments',
        (WidgetTester tester) async {
      final entries = <StatusEntry>[
        (
          contactId: 'c1',
          contactName: 'Alice',
          status: _makeStatus('Status 1'),
        ),
        (
          contactId: 'c2',
          contactName: 'Bob',
          status: _makeStatus('Status 2'),
        ),
        (
          contactId: 'c3',
          contactName: 'Charlie',
          status: _makeStatus('Status 3'),
        ),
      ];

      await tester.pumpWidget(buildTestableWidget(
        StatusViewerScreen(entries: entries),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // 3 entries = 3 Expanded segments in the progress row
      // Each segment has a ClipRRect child
      expect(find.byType(ClipRRect), findsNWidgets(3));
    });

    // ── Test 7: Renders GestureDetector for tap navigation ────────────────────

    testWidgets('renders GestureDetector for tap-based navigation',
        (WidgetTester tester) async {
      final entries = <StatusEntry>[
        (
          contactId: 'c1',
          contactName: 'Eve',
          status: _makeStatus('Status A'),
        ),
        (
          contactId: 'c2',
          contactName: 'Grace',
          status: _makeStatus('Status B'),
        ),
      ];

      await tester.pumpWidget(buildTestableWidget(
        StatusViewerScreen(entries: entries),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(GestureDetector), findsWidgets);
    });

    // ── Test 8: Shows "Just now" for recent status ────────────────────────────

    testWidgets('shows "Just now" for recently created status',
        (WidgetTester tester) async {
      final entries = <StatusEntry>[
        (
          contactId: 'c1',
          contactName: 'Hank',
          status: _makeStatus('Recent'),
        ),
      ];

      await tester.pumpWidget(buildTestableWidget(
        StatusViewerScreen(entries: entries),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Just now'), findsOneWidget);
    });
  });
}
