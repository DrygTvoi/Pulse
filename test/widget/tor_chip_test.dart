// Widget tests for TorChip (lib/widgets/tor_chip.dart).
//
// Tests focus on: bootstrap percentage display, "Tor" label when active,
// hidden when not running.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/widgets/tor_chip.dart';

Widget buildTestableWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('TorChip', () {
    // ── Test 1: Shows bootstrap percentage when bootstrapping ─────────────────

    testWidgets('shows bootstrap percentage when bootstrapping',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const TorChip(
          isRunning: true,
          bootstrapPercent: 45,
          activePtLabel: '',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Tor 45%'), findsOneWidget);
    });

    // ── Test 2: Shows "Tor" when fully active (100%) ──────────────────────────

    testWidgets('shows "Tor" label when bootstrap is 100%',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const TorChip(
          isRunning: true,
          bootstrapPercent: 100,
          activePtLabel: '',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Tor'), findsOneWidget);
    });

    // ── Test 3: Hidden when not running and 0% ────────────────────────────────

    testWidgets('renders SizedBox.shrink when not running and 0%',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const TorChip(
          isRunning: false,
          bootstrapPercent: 0,
          activePtLabel: '',
        ),
      ));
      await tester.pumpAndSettle();

      // Should not find any Chip or text.
      expect(find.byType(Chip), findsNothing);
      expect(find.text('Tor'), findsNothing);
    });

    // ── Test 4: Shows security icon when visible ──────────────────────────────

    testWidgets('shows security icon when chip is visible',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const TorChip(
          isRunning: true,
          bootstrapPercent: 100,
          activePtLabel: '',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.security_rounded), findsOneWidget);
    });

    // ── Test 5: Shows PT suffix for obfs4 ─────────────────────────────────────

    testWidgets('shows Tor with obfs4 suffix when activePtLabel is obfs4',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const TorChip(
          isRunning: true,
          bootstrapPercent: 100,
          activePtLabel: 'obfs4',
        ),
      ));
      await tester.pumpAndSettle();

      // The label should be 'Tor\u00B7obfs4' (Tor followed by middle dot and obfs4).
      expect(find.text('Tor\u00B7obfs4'), findsOneWidget);
    });

    // ── Test 6: Shows PT suffix for snowflake ─────────────────────────────────

    testWidgets('shows Tor with SF suffix when activePtLabel is snowflake',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const TorChip(
          isRunning: true,
          bootstrapPercent: 100,
          activePtLabel: 'snowflake',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Tor\u00B7SF'), findsOneWidget);
    });

    // ── Test 7: Chip widget is present when visible ───────────────────────────

    testWidgets('has a Chip widget when running',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const TorChip(
          isRunning: true,
          bootstrapPercent: 75,
          activePtLabel: '',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Chip), findsOneWidget);
    });
  });
}
