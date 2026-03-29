// Widget tests for RestoreAccountScreen (lib/screens/restore_account_screen.dart).
//
// RestoreAccountScreen has fields for nickname and recovery password.
// The _restore() method uses platform channels (FlutterSecureStorage,
// SignalService, KeyDerivationService, OxenKeyService), so tests that
// trigger restore are limited.
//
// Note: probeBootstrapRelays() in initState() creates a 6-second timer.
// Each test must pump(Duration(seconds: 7)) at the end to drain the timer,
// otherwise the test framework will fail with "A Timer is still pending".

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/screens/restore_account_screen.dart';

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

  group('RestoreAccountScreen', () {
    testWidgets('renders AppBar with "Restore account" title',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(buildTestableWidget(const RestoreAccountScreen()));
      await tester.pump();
      await tester.pump();

      expect(find.text('Restore account'), findsWidgets);

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('has an AppBar with back button',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(buildTestableWidget(const RestoreAccountScreen()));
      await tester.pump();
      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('displays info banner with info icon',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(buildTestableWidget(const RestoreAccountScreen()));
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('has nickname text field', (WidgetTester tester) async {
      await tester
          .pumpWidget(buildTestableWidget(const RestoreAccountScreen()));
      await tester.pump();
      await tester.pump();

      expect(find.text('Your nickname'), findsOneWidget);

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('has password text field', (WidgetTester tester) async {
      await tester
          .pumpWidget(buildTestableWidget(const RestoreAccountScreen()));
      await tester.pump();
      await tester.pump();

      expect(find.text('Recovery password (min. 16)'), findsOneWidget);

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('has two TextFields total (name + password)',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(buildTestableWidget(const RestoreAccountScreen()));
      await tester.pump();
      await tester.pump();

      expect(find.byType(TextField), findsNWidgets(2));

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('Restore button exists', (WidgetTester tester) async {
      await tester
          .pumpWidget(buildTestableWidget(const RestoreAccountScreen()));
      await tester.pump();
      await tester.pump();

      // "Restore account" appears both in AppBar title and button text.
      expect(find.byType(FilledButton), findsOneWidget);

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('Restore button is disabled initially',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(buildTestableWidget(const RestoreAccountScreen()));
      await tester.pump();
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('avatar shows "?" when name is empty',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(buildTestableWidget(const RestoreAccountScreen()));
      await tester.pump();
      await tester.pump();

      expect(find.text('?'), findsOneWidget);

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('entropy indicator shown when password is typed',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(buildTestableWidget(const RestoreAccountScreen()));
      await tester.pump();
      await tester.pump();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(1), 'short');
      await tester.pump();
      await tester.pump();

      // Should show entropy indicator with "Weak".
      // Format: "Weak (N bits)"
      expect(find.textContaining('Weak'), findsOneWidget);

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('Restore button becomes enabled with valid inputs',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(buildTestableWidget(const RestoreAccountScreen()));
      await tester.pump();
      await tester.pump();

      final fields = find.byType(TextField);
      // Name
      await tester.enterText(fields.at(0), 'Alice');
      // Password with 3+ char classes and >= 16 chars
      await tester.enterText(fields.at(1), 'StrongPassword1!');
      await tester.pump();
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull);

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('Restore button stays disabled with short password',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(buildTestableWidget(const RestoreAccountScreen()));
      await tester.pump();
      await tester.pump();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Alice');
      await tester.enterText(fields.at(1), 'Short1!');
      await tester.pump();
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('Restore button stays disabled without name',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(buildTestableWidget(const RestoreAccountScreen()));
      await tester.pump();
      await tester.pump();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(1), 'StrongPassword1!');
      await tester.pump();
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('password visibility toggle works',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(buildTestableWidget(const RestoreAccountScreen()));
      await tester.pump();
      await tester.pump();

      // Initially obscured -- visibility icon shown.
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      await tester.pump(const Duration(seconds: 7));
    });

    testWidgets('tapping restore with valid data triggers platform channels',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(buildTestableWidget(const RestoreAccountScreen()));
      await tester.pump();
      await tester.pump();

      final fields = find.byType(TextField);
      // Fill in name
      await tester.enterText(fields.at(0), 'Alice');
      // Fill in valid password (>= 16 chars, 3+ char classes)
      await tester.enterText(fields.at(1), 'StrongPassword1!');
      await tester.pump();
      await tester.pump();

      // Button should be enabled now.
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull);

      // Tap restore -- with mock secure storage returning null, services
      // will encounter nulls but should not throw unhandled exceptions.
      await tester.tap(find.byType(FilledButton));
      // Use pump() with duration instead of pumpAndSettle() because the
      // restore flow shows a loading spinner that prevents settling.
      await tester.pump(const Duration(seconds: 1));

      // Drain remaining timers.
      await tester.pump(const Duration(seconds: 7));
    });
  });
}
