// Widget tests for OnboardingScreen (lib/screens/onboarding_screen.dart).
//
// Tests focus on: PageView rendering, dot indicators, Skip/Next buttons,
// page navigation, and the "Get Started" text on the last page.

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
    // ── Test 1: Renders a PageView ────────────────────────────────────────────

    testWidgets('renders a PageView', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(PageView), findsOneWidget);
    });

    // ── Test 2: Displays Skip button ──────────────────────────────────────────

    testWidgets('displays Skip button', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Skip'), findsOneWidget);
    });

    // ── Test 3: Displays Next button on first page ────────────────────────────

    testWidgets('displays Next button on first page',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Next'), findsOneWidget);
    });

    // ── Test 4: Has 5 dot indicators ──────────────────────────────────────────

    testWidgets('has 5 dot indicators (AnimatedContainer)',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();

      // 5 pages = 5 AnimatedContainer dots
      expect(find.byType(AnimatedContainer), findsNWidgets(5));
    });

    // ── Test 5: Shows welcome title on first page ─────────────────────────────

    testWidgets('shows welcome title on first page',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Welcome to Pulse'), findsOneWidget);
    });

    // ── Test 6: Swiping to second page changes content ────────────────────────

    testWidgets('swiping to second page shows Transport-Agnostic title',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();

      // Swipe left to go to page 2
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(find.text('Transport-Agnostic'), findsOneWidget);
    });

    // ── Test 7: Next button advances to the next page ─────────────────────────

    testWidgets('tapping Next advances to the next page',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();

      // Tap Next
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Transport-Agnostic'), findsOneWidget);
    });

    // ── Test 8: Last page shows "Get Started" button ──────────────────────────

    testWidgets('last page shows "Get Started" button',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();

      // Navigate to the last page (page index 4) by tapping Next 4 times
      for (int i = 0; i < 4; i++) {
        final buttonText = i < 4 ? 'Next' : 'Get Started';
        await tester.tap(find.text(buttonText));
        await tester.pumpAndSettle();
      }

      expect(find.text('Get Started'), findsOneWidget);
    });
  });
}
