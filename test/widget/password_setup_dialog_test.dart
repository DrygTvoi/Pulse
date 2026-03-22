// Widget tests for PasswordSetupDialog (lib/widgets/password_setup_dialog.dart).
//
// Tests focus on: password fields rendering, min length validation, mismatch
// validation, visibility toggle, skip callback, and valid submission.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/theme/theme_manager.dart';
import 'package:pulse_messenger/widgets/password_setup_dialog.dart';

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
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(child: child),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PasswordSetupDialog', () {
    // ── Test 1: Renders two text fields ────────────────────────────────────────

    testWidgets('renders two text fields (password + confirm)',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        PasswordSetupDialog(
          onSet: (_) async {},
          onSkip: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(2));
    });

    // ── Test 2: Shows "Set App Password" title ────────────────────────────────

    testWidgets('shows "Set App Password" title',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        PasswordSetupDialog(
          onSet: (_) async {},
          onSkip: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Set App Password'), findsOneWidget);
    });

    // ── Test 3: Shows error when password is too short ────────────────────────

    testWidgets('shows error when password is less than 6 characters',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        PasswordSetupDialog(
          onSet: (_) async {},
          onSkip: () {},
        ),
      ));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'ab');
      await tester.enterText(textFields.last, 'ab');

      // Tap the "Set Password" button (FilledButton)
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    // ── Test 4: Shows error on password mismatch ──────────────────────────────

    testWidgets('shows error when passwords do not match',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        PasswordSetupDialog(
          onSet: (_) async {},
          onSkip: () {},
        ),
      ));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'password123');
      await tester.enterText(textFields.last, 'different12');

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    // ── Test 5: Toggle visibility changes icon ────────────────────────────────

    testWidgets('toggle visibility changes icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        PasswordSetupDialog(
          onSet: (_) async {},
          onSkip: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // Initially both fields are obscured => visibility_rounded icons
      expect(find.byIcon(Icons.visibility_rounded), findsNWidgets(2));

      // Tap first toggle
      await tester.tap(find.byIcon(Icons.visibility_rounded).first);
      await tester.pumpAndSettle();

      // Now one shows visibility_off_rounded
      expect(find.byIcon(Icons.visibility_off_rounded), findsOneWidget);
      expect(find.byIcon(Icons.visibility_rounded), findsOneWidget);
    });

    // ── Test 6: Skip button calls onSkip ──────────────────────────────────────

    testWidgets('skip button calls onSkip callback',
        (WidgetTester tester) async {
      bool skipped = false;

      await tester.pumpWidget(buildTestableWidget(
        PasswordSetupDialog(
          onSet: (_) async {},
          onSkip: () => skipped = true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip for now'));
      await tester.pumpAndSettle();

      expect(skipped, isTrue);
    });

    // ── Test 7: Valid matching passwords call onSet ────────────────────────────

    testWidgets('valid matching passwords call onSet callback',
        (WidgetTester tester) async {
      String? savedPassword;

      await tester.pumpWidget(buildTestableWidget(
        PasswordSetupDialog(
          onSet: (password) async {
            savedPassword = password;
          },
          onSkip: () {},
        ),
      ));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'securepass');
      await tester.enterText(textFields.last, 'securepass');

      await tester.tap(find.byType(FilledButton));
      // Use pump (not pumpAndSettle) — dialog may have continuous animation.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(savedPassword, 'securepass');
    });

    // ── Test 8: Shows info banner text ────────────────────────────────────────

    testWidgets('shows info banner text', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        PasswordSetupDialog(
          onSet: (_) async {},
          onSkip: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(
        find.text('Required every time you open Pulse. If forgotten, your data cannot be recovered.'),
        findsOneWidget,
      );
    });
  });
}
