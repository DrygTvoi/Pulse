// Widget tests for AppearanceIdentitySection
// (lib/screens/settings/appearance_identity_section.dart).
//
// Tests focus on: section label, ThemePickerWidget presence,
// Theme Engine row, and accent color swatches.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/theme/theme_manager.dart';
import 'package:pulse_messenger/screens/settings/appearance_identity_section.dart';
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
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppearanceIdentitySection', () {
    // -- Test 1: Renders the APPEARANCE section label -----------------------

    testWidgets('renders the Appearance section divider label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const AppearanceIdentitySection()));
      await tester.pumpAndSettle();

      expect(find.text('APPEARANCE'), findsOneWidget);
    });

    // -- Test 2: Contains ThemePickerWidget ---------------------------------

    testWidgets('contains ThemePickerWidget', (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const AppearanceIdentitySection()));
      await tester.pumpAndSettle();

      expect(find.byType(ThemePickerWidget), findsOneWidget);
    });

    // -- Test 3: Renders Theme Engine row -----------------------------------

    testWidgets('renders Theme Engine row with palette icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const AppearanceIdentitySection()));
      await tester.pumpAndSettle();

      expect(find.text('Theme Engine'), findsOneWidget);
      expect(find.text('Customize colors & fonts'), findsOneWidget);
      expect(find.byIcon(Icons.palette_rounded), findsOneWidget);
    });

    // -- Test 4: ThemePickerWidget shows Light/Dark/System modes ------------

    testWidgets('theme picker shows Light, Dark, System mode labels',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const AppearanceIdentitySection()));
      await tester.pumpAndSettle();

      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
    });

    // -- Test 5: ThemePickerWidget shows Accent Color label -----------------

    testWidgets('theme picker shows Accent Color label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const AppearanceIdentitySection()));
      await tester.pumpAndSettle();

      expect(find.text('Accent Color'), findsOneWidget);
    });

    // -- Test 6: ThemePickerWidget shows Appearance label -------------------

    testWidgets('theme picker shows inner Appearance label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const AppearanceIdentitySection()));
      await tester.pumpAndSettle();

      // The ThemePickerWidget itself has an "Appearance" label inside,
      // plus the section divider "APPEARANCE" above. Both should be present.
      expect(find.text('Appearance'), findsOneWidget);
    });
  });
}
