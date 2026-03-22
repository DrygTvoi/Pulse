// Widget tests for DynamicThemeScreen (lib/screens/dynamic_theme_screen.dart).
//
// DynamicThemeScreen depends on:
// - ThemeNotifier (via context.watch<ThemeNotifier>()) — provided via Provider
// - SharedPreferences (for ThemeNotifier persistence)
//
// The screen renders preset buttons, a color picker grid, a border radius
// slider, font selector, dark/light toggle, and a UI style toggle.
// All tests should pass without mocks since no platform channels are used
// beyond SharedPreferences (mocked via setMockInitialValues).

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/screens/dynamic_theme_screen.dart';
import 'package:pulse_messenger/theme/theme_manager.dart';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DynamicThemeScreen', () {
    testWidgets('has an AppBar with "Theme Engine" title',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const DynamicThemeScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Theme Engine'), findsOneWidget);
    });

    testWidgets('renders preset buttons (Pulse, Telegram, Signal, Midnight, Light)',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const DynamicThemeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Pulse'), findsOneWidget);
      expect(find.text('Telegram'), findsOneWidget);
      expect(find.text('Signal'), findsOneWidget);
      expect(find.text('Midnight'), findsOneWidget);
      // "Light" appears as both a preset button and an appearance mode toggle.
      expect(find.text('Light'), findsAtLeastNWidgets(1));
    });

    testWidgets('renders color palette section with label "Primary Color"',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const DynamicThemeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Primary Color'), findsOneWidget);
    });

    testWidgets('renders border radius slider with "Sharp" and "Round" labels',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const DynamicThemeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Border Radius'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      expect(find.text('Sharp'), findsOneWidget);
      expect(find.text('Round'), findsOneWidget);
    });

    testWidgets('renders appearance mode toggle with Dark, Light, Auto',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const DynamicThemeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      // Light appears in both the presets and the mode toggle
      expect(find.text('Auto'), findsAtLeast(1));
    });
  });
}
