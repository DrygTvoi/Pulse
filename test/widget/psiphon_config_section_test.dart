// Widget tests for PsiphonConfigSection (lib/widgets/psiphon_config_section.dart).
//
// PsiphonConfigSection accesses PsiphonService.instance in build() to read
// isRunning/proxyPort.  Since PsiphonService.instance is a real singleton
// using native process I/O, these tests are marked skip where the singleton
// access causes issues.  The constructor params (psiphonEnabled, psiphonLoading,
// onToggle) are testable structurally.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/widgets/psiphon_config_section.dart';

Widget buildTestableWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PsiphonConfigSection', () {
    // ── Test 1: Renders Psiphon title text ───────────────────────────────────
    testWidgets('renders Psiphon title', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        PsiphonConfigSection(
          psiphonEnabled: false,
          psiphonLoading: false,
          onToggle: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Psiphon'), findsOneWidget);
    });

    // ── Test 2: Shows disabled subtitle when not enabled ────────────────────
    testWidgets('shows fast tunnel subtitle when disabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        PsiphonConfigSection(
          psiphonEnabled: false,
          psiphonLoading: false,
          onToggle: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('Fast tunnel'), findsOneWidget);
    });

    // ── Test 3: Shows switch in off state ───────────────────────────────────
    testWidgets('renders switch in off state', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        PsiphonConfigSection(
          psiphonEnabled: false,
          psiphonLoading: false,
          onToggle: () {},
        ),
      ));
      await tester.pumpAndSettle();

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isFalse);
    });

    // ── Test 4: Shows loading indicator when psiphonLoading ─────────────────
    testWidgets('shows CircularProgressIndicator when loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        PsiphonConfigSection(
          psiphonEnabled: false,
          psiphonLoading: true,
          onToggle: () {},
        ),
      ));
      // Don't pumpAndSettle because the indicator animates indefinitely.
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Switch should NOT be visible during loading
      expect(find.byType(Switch), findsNothing);
    });

    // ── Test 5: onToggle fires when switch is tapped ────────────────────────
    testWidgets('onToggle fires when switch is tapped',
        (WidgetTester tester) async {
      bool toggled = false;

      await tester.pumpWidget(buildTestableWidget(
        PsiphonConfigSection(
          psiphonEnabled: false,
          psiphonLoading: false,
          onToggle: () => toggled = true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      expect(toggled, isTrue);
    });

    // ── Test 6: Connecting subtitle when loading and enabled ────────────────
    testWidgets('shows connecting subtitle when loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        PsiphonConfigSection(
          psiphonEnabled: false,
          psiphonLoading: true,
          onToggle: () {},
        ),
      ));
      await tester.pump();

      // The subtitle should show "Connecting..."
      expect(find.textContaining('Connecting'), findsOneWidget);
    });
  });
}
