// Widget tests for AboutSection (lib/screens/settings/about_section.dart).
//
// Tests focus on: section label, privacy policy row, crash reporting toggle,
// and toggling the Sentry opt-in switch.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/theme/theme_manager.dart';
import 'package:pulse_messenger/screens/settings/about_section.dart';

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
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AboutSection', () {
    // -- Test 1: Renders the ABOUT section label ----------------------------

    testWidgets('renders the About section divider label',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const AboutSection()));
      await tester.pumpAndSettle();

      // settingsSectionDivider uppercases the label; "About" becomes "ABOUT"
      expect(find.text('ABOUT'), findsOneWidget);
    });

    // -- Test 2: Renders Privacy Policy row ---------------------------------

    testWidgets('renders Privacy Policy row with icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const AboutSection()));
      await tester.pumpAndSettle();

      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.byIcon(Icons.privacy_tip_outlined), findsOneWidget);
    });

    // -- Test 3: Renders Crash Reporting row ---------------------------------

    testWidgets('renders Crash Reporting row with icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const AboutSection()));
      await tester.pumpAndSettle();

      expect(find.text('Crash reporting'), findsOneWidget);
      expect(find.byIcon(Icons.bug_report_outlined), findsOneWidget);
    });

    // -- Test 4: Crash reporting switch defaults to off ---------------------

    testWidgets('crash reporting switch defaults to off',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const AboutSection()));
      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      final switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, isFalse);
    });

    // -- Test 5: Toggling switch shows snackbar -----------------------------

    testWidgets('toggling crash reporting switch shows snackbar',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const AboutSection()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // After toggling ON, should show "Crash reporting enabled" snackbar
      expect(find.textContaining('Crash reporting enabled'), findsOneWidget);
    });

    // -- Test 6: Switch reflects persisted sentry_opt_in = true -------------

    testWidgets('switch shows ON when sentry_opt_in is persisted as true',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'sentry_opt_in': true});

      await tester.pumpWidget(buildTestableWidget(const AboutSection()));
      await tester.pumpAndSettle();

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);
    });
  });
}
