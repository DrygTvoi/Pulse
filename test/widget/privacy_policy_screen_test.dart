// Widget tests for PrivacyPolicyScreen (lib/screens/privacy_policy_screen.dart).
//
// PrivacyPolicyScreen is a pure StatelessWidget with no platform dependencies.
// It renders an AppBar with title and a scrollable list of headings and body
// paragraphs from localization strings. All tests should pass without mocks.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/screens/privacy_policy_screen.dart';

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
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PrivacyPolicyScreen', () {
    testWidgets('renders AppBar with "Privacy Policy" title',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const PrivacyPolicyScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Privacy Policy'), findsOneWidget);
    });

    testWidgets('has an AppBar with back button', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const PrivacyPolicyScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('contains Overview section heading', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const PrivacyPolicyScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Overview'), findsOneWidget);
    });

    testWidgets('contains Data Collection section heading',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const PrivacyPolicyScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Data Collection'), findsOneWidget);
    });

    testWidgets('contains Encryption section heading',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const PrivacyPolicyScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Encryption'), findsOneWidget);
    });

    testWidgets('contains Network Architecture section heading',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const PrivacyPolicyScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Network Architecture'), findsOneWidget);
    });

    testWidgets('contains STUN/TURN Servers section heading',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const PrivacyPolicyScreen()));
      await tester.pumpAndSettle();

      expect(find.text('STUN/TURN Servers'), findsOneWidget);
    });

    testWidgets('contains Crash Reporting section heading',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const PrivacyPolicyScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Crash Reporting'), findsOneWidget);
    });

    testWidgets('contains Password & Keys section heading',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const PrivacyPolicyScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Password & Keys'), findsOneWidget);
    });

    testWidgets('contains Fonts section heading', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const PrivacyPolicyScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Fonts'), findsOneWidget);
    });

    testWidgets('contains Third-Party Services section heading',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const PrivacyPolicyScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Third-Party Services'), findsOneWidget);
    });

    testWidgets('contains Open Source section heading',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const PrivacyPolicyScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Open Source'), findsOneWidget);
    });

    testWidgets('contains Contact section heading',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const PrivacyPolicyScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Contact'), findsOneWidget);
    });

    testWidgets('contains "Last updated" footer text',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const PrivacyPolicyScreen()));
      await tester.pumpAndSettle();

      // Scroll to the bottom to reveal the footer.
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -3000));
      await tester.pumpAndSettle();

      expect(find.text('Last updated: March 2026'), findsOneWidget);
    });

    testWidgets('body is scrollable', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const PrivacyPolicyScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('Scaffold is present', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const PrivacyPolicyScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
