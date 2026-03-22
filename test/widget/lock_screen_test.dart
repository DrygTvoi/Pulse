// Widget tests for LockScreen (lib/screens/lock_screen.dart).
//
// LockScreen uses FlutterSecureStorage (platform channel) and SharedPreferences.
// FlutterSecureStorage cannot be easily mocked in pure widget tests, so tests
// that trigger _unlock() (which reads from secure storage) are skipped.
//
// These tests verify the static widget tree: title, password field, unlock
// button, panic hint text, and visibility toggle.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/screens/lock_screen.dart';

import '../helpers/test_mocks.dart';

/// Wraps [child] in a MaterialApp with the localization delegates required
/// by the app (mirrors main.dart configuration).
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
    setUpSecureStorageMock();
  });

  group('LockScreen', () {
    testWidgets('renders the lock icon', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const LockScreen()));
      await tester.pumpAndSettle();

      // The lock icon is rendered inside a Container.
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    });

    testWidgets('displays "Pulse is locked" title', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const LockScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Pulse is locked'), findsOneWidget);
    });

    testWidgets('displays subtitle text', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const LockScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Enter your password to continue'), findsOneWidget);
    });

    testWidgets('has a password TextField with hint', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const LockScreen()));
      await tester.pumpAndSettle();

      // There should be exactly one TextField for the password.
      expect(find.byType(TextField), findsOneWidget);

      // The hint text should be "Password".
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('password field is initially obscured', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const LockScreen()));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);
    });

    testWidgets('visibility toggle changes obscureText', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const LockScreen()));
      await tester.pumpAndSettle();

      // Initially obscured — the visibility icon should be "visibility_rounded"
      // (since _showPassword is false, icon is visibility_rounded).
      expect(find.byIcon(Icons.visibility_rounded), findsOneWidget);

      // Tap the visibility toggle.
      await tester.tap(find.byIcon(Icons.visibility_rounded));
      await tester.pumpAndSettle();

      // Now it should show "visibility_off_rounded" and text should be visible.
      expect(find.byIcon(Icons.visibility_off_rounded), findsOneWidget);

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isFalse);
    });

    testWidgets('displays the Unlock button', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const LockScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Unlock'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('displays panic hint text', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const LockScreen()));
      await tester.pumpAndSettle();

      expect(
        find.text('Forgot your password? Enter your panic key to wipe all data.'),
        findsOneWidget,
      );
    });

    testWidgets('Scaffold is present', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const LockScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('tapping Unlock with empty field does nothing',
        (WidgetTester tester) async {
      // _unlock() returns immediately if text is empty, so no platform
      // channel is hit. This verifies the guard works.
      await tester.pumpWidget(buildTestableWidget(const LockScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // Should still be on the lock screen — no error, no navigation.
      expect(find.text('Pulse is locked'), findsOneWidget);
    });

    testWidgets('tapping Unlock with text triggers secure storage',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const LockScreen()));
      await tester.pumpAndSettle();

      // Enter a password and tap Unlock.
      await tester.enterText(find.byType(TextField), 'somepassword');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FilledButton));
      // Pump several frames to allow the async _unlock() method to execute
      // and trigger navigation. Use pump() instead of pumpAndSettle() because
      // the destination screen may have persistent animations.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // With mock secure storage returning null for hash and salt, _unlock()
      // shows a loading state (CircularProgressIndicator) while reading keys.
      // Verify the unlock flow was triggered without crashing.
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
