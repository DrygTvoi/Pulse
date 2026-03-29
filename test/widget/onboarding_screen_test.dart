// Widget tests for OnboardingScreen (lib/screens/onboarding_screen.dart).
//
// The onboarding screen is a single-page welcome screen with the Pulse logo,
// app name, subtitle, a "Get Started" button, and a language picker link.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/theme/theme_manager.dart';
import 'package:pulse_messenger/screens/onboarding_screen.dart';

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

  group('OnboardingScreen', () {
    // ── Test 1: Renders the Pulse app name ──────────────────────────────────

    testWidgets('renders the Pulse app name', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Pulse'), findsOneWidget);
    });

    // ── Test 2: Renders the shield logo icon ────────────────────────────────

    testWidgets('renders the shield logo icon', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.shield_rounded), findsOneWidget);
    });

    // ── Test 3: Displays Get Started button ─────────────────────────────────

    testWidgets('displays Get Started button', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Get Started'), findsOneWidget);
    });

    // ── Test 4: Has a FilledButton ──────────────────────────────────────────

    testWidgets('has a FilledButton for Get Started',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(FilledButton), findsOneWidget);
    });

    // ── Test 5: Shows subtitle text from l10n ───────────────────────────────

    testWidgets('shows subtitle text', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();

      // The subtitle is the first line of onboardingWelcomeBody
      expect(
        find.text('A decentralized, end-to-end encrypted messenger.'),
        findsOneWidget,
      );
    });

    // ── Test 6: Shows language picker link ───────────────────────────────────

    testWidgets('shows language picker link', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('Continue in'), findsOneWidget);
    });

    // ── Test 7: Has a language icon ─────────────────────────────────────────

    testWidgets('has a language icon', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.language_rounded), findsOneWidget);
    });

    // ── Test 8: Get Started button is tappable ──────────────────────────────

    testWidgets('Get Started button is tappable', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull);
    });
  });
}
