// Widget tests for PanicKeyDialog (lib/widgets/panic_key_dialog.dart).
//
// Tests focus on: two text fields, error on mismatch, error on too-short key,
// skip button, visibility toggle, and valid submission.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/theme/theme_manager.dart';
import 'package:pulse_messenger/widgets/panic_key_dialog.dart';

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

  group('PanicKeyDialog', () {
    // ── Test 1: Renders two text fields ────────────────────────────────────────

    testWidgets('renders two text fields (key + confirm)',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        PanicKeyDialog(
          onSet: (_) async {},
          onSkip: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(2));
    });

    // ── Test 2: Shows "Set Panic Key" title ───────────────────────────────────

    testWidgets('shows "Set Panic Key" title', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        PanicKeyDialog(
          onSet: (_) async {},
          onSkip: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // Title appears both as header text and as button text
      expect(find.text('Set Panic Key'), findsWidgets);
    });

    // ── Test 3: Shows error when key is too short ─────────────────────────────

    testWidgets('shows error when key is less than 8 characters',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        PanicKeyDialog(
          onSet: (_) async {},
          onSkip: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // Enter a short key
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'short');
      await tester.enterText(textFields.last, 'short');

      // Tap the Set Panic Key button (FilledButton)
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(find.text('Panic key must be at least 8 characters'), findsOneWidget);
    });

    // ── Test 4: Shows error on key mismatch ───────────────────────────────────

    testWidgets('shows error when keys do not match',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        PanicKeyDialog(
          onSet: (_) async {},
          onSkip: () {},
        ),
      ));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'mypanickey123');
      await tester.enterText(textFields.last, 'differentkey1');

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(find.text('Keys do not match'), findsOneWidget);
    });

    // ── Test 5: Skip button calls onSkip callback ─────────────────────────────

    testWidgets('skip button calls onSkip callback',
        (WidgetTester tester) async {
      bool skipped = false;

      await tester.pumpWidget(buildTestableWidget(
        PanicKeyDialog(
          onSet: (_) async {},
          onSkip: () => skipped = true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(skipped, isTrue);
    });

    // ── Test 6: Visibility toggle works ───────────────────────────────────────

    testWidgets('visibility toggle changes icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        PanicKeyDialog(
          onSet: (_) async {},
          onSkip: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // Initially both fields are obscured, so visibility_rounded icons shown
      expect(find.byIcon(Icons.visibility_rounded), findsNWidgets(2));
      expect(find.byIcon(Icons.visibility_off_rounded), findsNothing);

      // Tap the first visibility toggle
      await tester.tap(find.byIcon(Icons.visibility_rounded).first);
      await tester.pumpAndSettle();

      // Now one field shows visibility_off_rounded
      expect(find.byIcon(Icons.visibility_off_rounded), findsOneWidget);
      expect(find.byIcon(Icons.visibility_rounded), findsOneWidget);
    });

    // ── Test 7: Valid input calls onSet ────────────────────────────────────────

    testWidgets('valid matching keys call onSet callback',
        (WidgetTester tester) async {
      String? savedKey;

      await tester.pumpWidget(buildTestableWidget(
        PanicKeyDialog(
          onSet: (key) async {
            savedKey = key;
          },
          onSkip: () {},
        ),
      ));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'validpanic123');
      await tester.enterText(textFields.last, 'validpanic123');

      await tester.tap(find.byType(FilledButton));
      // Use pump (not pumpAndSettle) — dialog may have continuous animation.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(savedKey, 'validpanic123');
    });

    // ── Test 8: Warning banner is displayed ───────────────────────────────────

    testWidgets('displays warning banner text', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        PanicKeyDialog(
          onSet: (_) async {},
          onSkip: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('This action is irreversible'), findsOneWidget);
    });
  });
}
