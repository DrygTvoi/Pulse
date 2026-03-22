// Widget tests for TurnConfigSection (lib/widgets/turn_config_section.dart).
//
// TurnConfigSection is a pure StatelessWidget with no service dependencies.
// All state is passed via constructor params: enabledPresets, controllers,
// onPresetsChanged callback.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/widgets/turn_config_section.dart';

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

  group('TurnConfigSection', () {
    // ── Test 1: Renders section labels ──────────────────────────────────────
    testWidgets('renders TURN section labels', (WidgetTester tester) async {
      final urlCtrl = TextEditingController();
      final userCtrl = TextEditingController();
      final passCtrl = TextEditingController();

      await tester.pumpWidget(buildTestableWidget(
        TurnConfigSection(
          enabledPresets: const [],
          turnUrlController: urlCtrl,
          turnUsernameController: userCtrl,
          turnPasswordController: passCtrl,
          onPresetsChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('COMMUNITY TURN SERVERS'), findsOneWidget);
      expect(find.text('CUSTOM TURN SERVER (BYOD)'), findsOneWidget);
    });

    // ── Test 2: Renders TURN info banner ────────────────────────────────────
    testWidgets('renders TURN info banner text', (WidgetTester tester) async {
      final urlCtrl = TextEditingController();
      final userCtrl = TextEditingController();
      final passCtrl = TextEditingController();

      await tester.pumpWidget(buildTestableWidget(
        TurnConfigSection(
          enabledPresets: const [],
          turnUrlController: urlCtrl,
          turnUsernameController: userCtrl,
          turnPasswordController: passCtrl,
          onPresetsChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('TURN servers only relay'), findsOneWidget);
    });

    // ── Test 3: Shows preset names from kTurnPresets ────────────────────────
    testWidgets('renders community preset names', (WidgetTester tester) async {
      final urlCtrl = TextEditingController();
      final userCtrl = TextEditingController();
      final passCtrl = TextEditingController();

      await tester.pumpWidget(buildTestableWidget(
        TurnConfigSection(
          enabledPresets: const [],
          turnUrlController: urlCtrl,
          turnUsernameController: userCtrl,
          turnPasswordController: passCtrl,
          onPresetsChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      // All presets should have a "FREE" badge
      expect(find.text('FREE'), findsWidgets);
      // Open Relay is the first preset
      expect(find.text('Open Relay'), findsOneWidget);
    });

    // ── Test 4: Custom TURN fields are rendered ─────────────────────────────
    testWidgets('renders custom TURN input fields',
        (WidgetTester tester) async {
      final urlCtrl = TextEditingController();
      final userCtrl = TextEditingController();
      final passCtrl = TextEditingController();

      await tester.pumpWidget(buildTestableWidget(
        TurnConfigSection(
          enabledPresets: const [],
          turnUrlController: urlCtrl,
          turnUsernameController: userCtrl,
          turnPasswordController: passCtrl,
          onPresetsChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      // Three TextFields: URL, Username, Password
      expect(find.byType(TextField), findsNWidgets(3));
      // Helper text
      expect(find.textContaining('Self-host coturn'), findsOneWidget);
    });

    // ── Test 5: onPresetsChanged fires when a preset is tapped ──────────────
    testWidgets('onPresetsChanged fires when preset is tapped',
        (WidgetTester tester) async {
      List<String>? updatedPresets;
      final urlCtrl = TextEditingController();
      final userCtrl = TextEditingController();
      final passCtrl = TextEditingController();

      await tester.pumpWidget(buildTestableWidget(
        TurnConfigSection(
          enabledPresets: const [],
          turnUrlController: urlCtrl,
          turnUsernameController: userCtrl,
          turnPasswordController: passCtrl,
          onPresetsChanged: (p) => updatedPresets = p,
        ),
      ));
      await tester.pumpAndSettle();

      // Tap the "Open Relay" preset
      await tester.tap(find.text('Open Relay'));

      expect(updatedPresets, isNotNull);
      expect(updatedPresets, contains('openrelay'));
    });

    // ── Test 6: Enabled preset shows check icon ─────────────────────────────
    testWidgets('enabled preset shows check_circle icon',
        (WidgetTester tester) async {
      final urlCtrl = TextEditingController();
      final userCtrl = TextEditingController();
      final passCtrl = TextEditingController();

      await tester.pumpWidget(buildTestableWidget(
        TurnConfigSection(
          enabledPresets: const ['openrelay'],
          turnUrlController: urlCtrl,
          turnUsernameController: userCtrl,
          turnPasswordController: passCtrl,
          onPresetsChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      // When enabled, the icon should be check_circle_rounded
      expect(find.byIcon(Icons.check_circle_rounded), findsWidgets);
    });
  });
}
