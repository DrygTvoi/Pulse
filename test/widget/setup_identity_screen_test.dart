// Widget tests for SetupIdentityScreen (lib/screens/setup_identity_screen.dart).
//
// SetupIdentityScreen has text fields for nickname, password, and confirm
// password. It validates min 16 chars, 3-of-4 character class variety, and
// shows an entropy indicator with a requirements checklist.
// The _createAccount() method uses platform channels (FlutterSecureStorage,
// SignalService, etc.), so interaction tests that trigger account creation
// are limited.
//
// Note: probeBootstrapRelays() in initState() creates a 6-second timer.
// Each test must pump(Duration(seconds: 7)) at the end to drain the timer,
// otherwise the test framework will fail with "A Timer is still pending".

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/screens/setup_identity_screen.dart';

import '../helpers/test_mocks.dart';

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

  group('SetupIdentityScreen', () {
    testWidgets('renders "Create an anonymous account" title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const SetupIdentityScreen()));
      await tester.pump();
      await tester.pump();

      expect(find.text('Create an anonymous account'), findsOneWidget);

      // Drain the 6-second relay prober timer.
      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('renders password warning text', (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const SetupIdentityScreen()));
      await tester.pump();
      await tester.pump();

      expect(
        find.textContaining('This password is the only way'),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('has nickname text field', (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const SetupIdentityScreen()));
      await tester.pump();
      await tester.pump();

      expect(find.text('Your nickname'), findsOneWidget);

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('has password text field', (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const SetupIdentityScreen()));
      await tester.pump();
      await tester.pump();

      expect(find.text('Recovery password (min. 16)'), findsOneWidget);

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('has confirm password text field',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const SetupIdentityScreen()));
      await tester.pump();
      await tester.pump();

      expect(find.text('Confirm password'), findsOneWidget);

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('has three TextFields total', (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const SetupIdentityScreen()));
      await tester.pump();
      await tester.pump();

      // nickname + password + confirm password = 3 TextFields
      expect(find.byType(TextField), findsNWidgets(3));

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('Create account button exists but is disabled initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const SetupIdentityScreen()));
      await tester.pump();
      await tester.pump();

      expect(find.text('Create account'), findsOneWidget);

      // Button should be disabled (onPressed is null) because fields are empty.
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('has shield logo icon', (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const SetupIdentityScreen()));
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.shield_rounded), findsOneWidget);

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('shows "Already have an account?" link',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const SetupIdentityScreen()));
      await tester.pump();
      await tester.pump();

      expect(
          find.textContaining('Already have an account?'), findsOneWidget);

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('shows Restore link', (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const SetupIdentityScreen()));
      await tester.pump();
      await tester.pump();

      // The restore link is part of a Text.rich with "Restore" as a child span.
      expect(find.textContaining('Restore'), findsOneWidget);

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('entropy indicator not shown when password is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const SetupIdentityScreen()));
      await tester.pump();
      await tester.pump();

      // The entropy label (Weak/OK/Strong) should NOT be visible
      // when the password field is empty.
      expect(find.textContaining('Weak'), findsNothing);
      expect(find.textContaining('OK'), findsNothing);
      expect(find.textContaining('Strong'), findsNothing);

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('typing a short password shows entropy indicator as Weak',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const SetupIdentityScreen()));
      await tester.pump();
      await tester.pump();

      // Find the password field (second TextField -- index 1).
      final passwordFields = find.byType(TextField);
      // Enter a short lowercase-only password (< 50 bits entropy, no variety).
      await tester.enterText(passwordFields.at(1), 'abcdef');
      await tester.pump();
      await tester.pump();

      // The entropy indicator should now be visible with "Weak" label.
      // Format: "Weak (N bits)"
      expect(find.textContaining('Weak'), findsOneWidget);

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets(
        'password with 3+ char classes and >= 16 chars shows OK or Strong',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const SetupIdentityScreen()));
      await tester.pump();
      await tester.pump();

      final passwordFields = find.byType(TextField);
      // Enter a password with lowercase, uppercase, digit (3 classes), 16+ chars.
      await tester.enterText(passwordFields.at(1), 'Abcdefgh12345678');
      await tester.pump();
      await tester.pump();

      // Should show Strong (not Weak).
      expect(find.textContaining('Strong'), findsOneWidget);

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('password without variety shows weak needs variety label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const SetupIdentityScreen()));
      await tester.pump();
      await tester.pump();

      final passwordFields = find.byType(TextField);
      // Enter a 16-char lowercase-only password (only 1 char class, need 3).
      await tester.enterText(passwordFields.at(1), 'abcdefghijklmnop');
      await tester.pump();
      await tester.pump();

      // Should show "Weak (need 3 char types)"
      expect(find.textContaining('need 3 char types'), findsOneWidget);

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('button stays disabled with password < 16 chars',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const SetupIdentityScreen()));
      await tester.pump();
      await tester.pump();

      final fields = find.byType(TextField);
      // Fill in name
      await tester.enterText(fields.at(0), 'Alice');
      // Short password (only 10 chars)
      await tester.enterText(fields.at(1), 'Abc1234!@#');
      // Matching confirm
      await tester.enterText(fields.at(2), 'Abc1234!@#');
      await tester.pump();
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('button stays disabled when passwords do not match',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const SetupIdentityScreen()));
      await tester.pump();
      await tester.pump();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Alice');
      await tester.enterText(fields.at(1), 'Abcdefgh12345678!');
      await tester.enterText(fields.at(2), 'DifferentPassword1!');
      await tester.pump();
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('button becomes enabled when all validation passes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const SetupIdentityScreen()));
      await tester.pump();
      await tester.pump();

      final fields = find.byType(TextField);
      // Name
      await tester.enterText(fields.at(0), 'Alice');
      // Password with 3+ char classes and >= 16 chars
      await tester.enterText(fields.at(1), 'StrongPassword1!');
      // Matching confirm
      await tester.enterText(fields.at(2), 'StrongPassword1!');
      await tester.pump();
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull);

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('tapping Create account triggers platform channels',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const SetupIdentityScreen()));
      await tester.pump();
      await tester.pump();

      final fields = find.byType(TextField);
      // Name
      await tester.enterText(fields.at(0), 'Alice');
      // Password with 3+ char classes and >= 16 chars
      await tester.enterText(fields.at(1), 'StrongPassword1!');
      // Matching confirm
      await tester.enterText(fields.at(2), 'StrongPassword1!');
      await tester.pump();
      await tester.pump();

      // Button should be enabled.
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull);

      // Tap Create account -- with mock secure storage returning null,
      // services will encounter nulls but should not throw unhandled exceptions.
      await tester.tap(find.byType(FilledButton));
      await tester.pump(const Duration(seconds: 1));

      // Drain remaining timers.
      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('requirements checklist appears when typing password',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const SetupIdentityScreen()));
      await tester.pump();
      await tester.pump();

      // Initially no checklist
      expect(find.text('At least 16 characters'), findsNothing);

      // Type a password
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(1), 'abc');
      await tester.pump();
      await tester.pump();

      // Checklist should now appear
      expect(find.text('At least 16 characters'), findsOneWidget);
      expect(
        find.text('3 of 4: uppercase, lowercase, digits, symbols'),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('password visibility toggle works',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const SetupIdentityScreen()));
      await tester.pump();
      await tester.pump();

      // Initially obscured -- visibility icon shown (there are two: password + confirm).
      expect(find.byIcon(Icons.visibility_outlined), findsNWidgets(2));

      // Tap the first visibility icon (password field)
      await tester.tap(find.byIcon(Icons.visibility_outlined).first);
      await tester.pump();
      await tester.pump();

      // Now one should be visibility_off_outlined (password) and one still visibility_outlined (confirm)
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      await tester.pump(const Duration(seconds: 7));
    });
  });
}
