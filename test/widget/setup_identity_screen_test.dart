// Widget tests for SetupIdentityScreen (lib/screens/setup_identity_screen.dart).
//
// SetupIdentityScreen has text fields for nickname, password, and confirm
// password. It validates min 16 chars, 3-of-4 character class variety, and
// shows an entropy indicator. The _createAccount() method uses platform
// channels (FlutterSecureStorage, SignalService, etc.), so interaction tests
// that trigger account creation are skipped.

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
    testWidgets('renders Pulse title', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const SetupIdentityScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Pulse'), findsOneWidget);
    });

    testWidgets('renders subtitle text', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const SetupIdentityScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Create an anonymous account'), findsOneWidget);
    });

    testWidgets('has nickname text field', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const SetupIdentityScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Your nickname'), findsOneWidget);
    });

    testWidgets('has password text field', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const SetupIdentityScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Recovery password (min. 16)'), findsOneWidget);
    });

    testWidgets('has confirm password text field', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const SetupIdentityScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Confirm password'), findsOneWidget);
    });

    testWidgets('has three TextFields total', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const SetupIdentityScreen()));
      await tester.pumpAndSettle();

      // nickname + password + confirm password = 3 TextFields
      expect(find.byType(TextField), findsNWidgets(3));
    });

    testWidgets('Create account button exists but is disabled initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const SetupIdentityScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Create account'), findsOneWidget);

      // Button should be disabled (onPressed is null) because fields are empty.
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('shows password warning banner', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const SetupIdentityScreen()));
      await tester.pumpAndSettle();

      // The warning banner has a warning icon.
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('shows "Restore" link', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const SetupIdentityScreen()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Already have an account?'), findsOneWidget);
    });

    testWidgets('avatar shows "?" initially', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const SetupIdentityScreen()));
      await tester.pumpAndSettle();

      // With empty name, the avatar initial is '?'
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('entropy indicator not shown when password is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const SetupIdentityScreen()));
      await tester.pumpAndSettle();

      // The entropy label (Weak/OK/Strong) should NOT be visible
      // when the password field is empty.
      expect(find.text('Weak'), findsNothing);
      expect(find.text('OK'), findsNothing);
      expect(find.text('Strong'), findsNothing);
    });

    testWidgets('typing a short password shows entropy indicator as Weak',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const SetupIdentityScreen()));
      await tester.pumpAndSettle();

      // Find the password field (second TextField — index 1).
      final passwordFields = find.byType(TextField);
      // Enter a short lowercase-only password (< 50 bits entropy, no variety).
      await tester.enterText(passwordFields.at(1), 'abcdef');
      await tester.pumpAndSettle();

      // The entropy indicator should now be visible with "Weak" label.
      expect(find.textContaining('Weak'), findsOneWidget);
    });

    testWidgets('password with 3+ char classes and >= 16 chars shows OK or Strong',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const SetupIdentityScreen()));
      await tester.pumpAndSettle();

      final passwordFields = find.byType(TextField);
      // Enter a password with lowercase, uppercase, digit (3 classes), 16+ chars.
      await tester.enterText(passwordFields.at(1), 'Abcdefgh12345678');
      await tester.pumpAndSettle();

      // Should show OK or Strong (not Weak).
      // With 3 classes (26+26+10=62 charset), 16 chars, uniqueRatio ~1:
      // entropy = 16 * log2(62) * (unique/16) which is ~95 bits -> Strong
      expect(find.textContaining('Strong'), findsOneWidget);
    });

    testWidgets('password without variety shows weak needs variety label',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const SetupIdentityScreen()));
      await tester.pumpAndSettle();

      final passwordFields = find.byType(TextField);
      // Enter a 16-char lowercase-only password (only 1 char class, need 3).
      await tester.enterText(passwordFields.at(1), 'abcdefghijklmnop');
      await tester.pumpAndSettle();

      // Should show "Weak (need 3 char types)"
      expect(find.textContaining('need 3 char types'), findsOneWidget);
    });

    testWidgets('button stays disabled with password < 16 chars',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const SetupIdentityScreen()));
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      // Fill in name
      await tester.enterText(fields.at(0), 'Alice');
      // Short password (only 10 chars)
      await tester.enterText(fields.at(1), 'Abc1234!@#');
      // Matching confirm
      await tester.enterText(fields.at(2), 'Abc1234!@#');
      await tester.pumpAndSettle();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('button stays disabled when passwords do not match',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const SetupIdentityScreen()));
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Alice');
      await tester.enterText(fields.at(1), 'Abcdefgh12345678!');
      await tester.enterText(fields.at(2), 'DifferentPassword1!');
      await tester.pumpAndSettle();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('button becomes enabled when all validation passes',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const SetupIdentityScreen()));
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      // Name
      await tester.enterText(fields.at(0), 'Alice');
      // Password with 3+ char classes and >= 16 chars
      await tester.enterText(fields.at(1), 'StrongPassword1!');
      // Matching confirm
      await tester.enterText(fields.at(2), 'StrongPassword1!');
      await tester.pumpAndSettle();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('tapping Create account triggers platform channels',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const SetupIdentityScreen()));
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      // Name
      await tester.enterText(fields.at(0), 'Alice');
      // Password with 3+ char classes and >= 16 chars
      await tester.enterText(fields.at(1), 'StrongPassword1!');
      // Matching confirm
      await tester.enterText(fields.at(2), 'StrongPassword1!');
      await tester.pumpAndSettle();

      // Button should be enabled.
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull);

      // Tap Create account — with mock secure storage returning null,
      // services will encounter nulls but should not throw unhandled exceptions.
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
    });

    testWidgets('avatar initial updates when name is typed',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const SetupIdentityScreen()));
      await tester.pumpAndSettle();

      // Initially shows '?'
      expect(find.text('?'), findsOneWidget);

      // Type a name
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Bob');
      await tester.pumpAndSettle();

      // Now should show 'B'
      expect(find.text('B'), findsOneWidget);
      expect(find.text('?'), findsNothing);
    });

    testWidgets('tapping color lens icon cycles avatar color',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const SetupIdentityScreen()));
      await tester.pumpAndSettle();

      // The color lens icon exists.
      expect(find.byIcon(Icons.color_lens_rounded), findsOneWidget);

      // Tapping it should not crash (color cycles internally).
      await tester.tap(find.byIcon(Icons.color_lens_rounded));
      await tester.pumpAndSettle();

      // Still renders without error.
      expect(find.text('Pulse'), findsOneWidget);
    });
  });
}
