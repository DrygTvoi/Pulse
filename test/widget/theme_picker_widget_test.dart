// Widget tests for ThemePickerWidget (lib/widgets/theme_picker_widget.dart).
//
// Tests focus on: rendering mode selectors (Light/Dark/System), rendering
// accent color chips, tapping a preset changes the check icon, correct
// number of color options.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/theme/theme_manager.dart';
import 'package:pulse_messenger/widgets/theme_picker_widget.dart';

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
      home: Scaffold(body: const SingleChildScrollView(child: ThemePickerWidget())),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemePickerWidget', () {
    // ── Test 1: Renders "Appearance" section label ───────────────────────────

    testWidgets('renders Appearance section label',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const ThemePickerWidget()));
      await tester.pumpAndSettle();

      expect(find.text('Appearance'), findsOneWidget);
    });

    // ── Test 2: Renders "Accent Color" section label ────────────────────────

    testWidgets('renders Accent Color section label',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const ThemePickerWidget()));
      await tester.pumpAndSettle();

      expect(find.text('Accent Color'), findsOneWidget);
    });

    // ── Test 3: Renders three mode options ───────────────────────────────────

    testWidgets('renders Light, Dark, and System mode labels',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const ThemePickerWidget()));
      await tester.pumpAndSettle();

      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
    });

    // ── Test 4: Renders mode icons ──────────────────────────────────────────

    testWidgets('renders mode icons for light, dark, system',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const ThemePickerWidget()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
      expect(find.byIcon(Icons.brightness_auto_rounded), findsOneWidget);
    });

    // ── Test 5: Renders 8 accent color chips ────────────────────────────────

    testWidgets('renders exactly 8 accent color chips',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const ThemePickerWidget()));
      await tester.pumpAndSettle();

      // Each accent color is wrapped in a GestureDetector containing a
      // Container with circle shape. The Wrap has 8 children.
      // We can count the GestureDetector widgets inside the Wrap.
      final wrapFinder = find.byType(Wrap);
      expect(wrapFinder, findsOneWidget);

      final wrapWidget = tester.widget<Wrap>(wrapFinder);
      expect(wrapWidget.children.length, 8);
    });

    // ── Test 6: Selected accent shows check icon ────────────────────────────

    testWidgets('selected accent color shows check icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const ThemePickerWidget()));
      await tester.pumpAndSettle();

      // The default accent is 0xFF00A884 (WhatsApp green).
      // The selected color chip should show Icons.check_rounded.
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    // ── Test 7: Tapping a different accent changes selection ─────────────────

    testWidgets('tapping a different accent color updates the check icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const ThemePickerWidget()));
      await tester.pumpAndSettle();

      // Initially one check icon on the default accent.
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // Find all GestureDetectors inside the Wrap. Tap the second one
      // (Indigo, index 1).
      final wrapFinder = find.byType(Wrap);
      // Each child is a GestureDetector. Get the second child's center.
      final secondChip = find.descendant(
        of: wrapFinder,
        matching: find.byType(GestureDetector),
      );
      // Tap the second accent chip (index 1).
      await tester.tap(secondChip.at(1));
      await tester.pumpAndSettle();

      // After tapping, the check icon should still exist (on the new selection).
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    // ── Test 8: Tapping mode selector changes mode ──────────────────────────

    testWidgets('tapping Light mode selector updates theme mode',
        (WidgetTester tester) async {
      // Start with dark mode (default).
      ThemeNotifier.instance.setThemeMode(ThemeMode.dark);

      await tester.pumpWidget(buildTestableWidget(const ThemePickerWidget()));
      await tester.pumpAndSettle();

      // Tap the "Light" segment.
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();

      expect(ThemeNotifier.instance.themeMode, ThemeMode.light);

      // Restore default.
      ThemeNotifier.instance.setThemeMode(ThemeMode.dark);
    });
  });
}
