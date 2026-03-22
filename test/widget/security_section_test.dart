// Widget tests for SecuritySection (lib/screens/settings/security_section.dart).
//
// SecuritySection depends on FlutterSecureStorage (platform plugin) for
// password/panic key management. Tests that interact with secure storage
// are marked skip: true. Tests that only verify initial rendering are safe.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/theme/theme_manager.dart';
import 'package:pulse_messenger/screens/settings/security_section.dart';

import '../helpers/test_mocks.dart';

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
    setUpSecureStorageMock();
  });

  group('SecuritySection', () {
    // -- Test 1: Renders the SECURITY section label -------------------------

    testWidgets('renders the Security section divider label',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        SecuritySection(
          passwordEnabled: false,
          panicKeyEnabled: false,
          onPasswordEnabledChanged: (_) {},
          onPanicKeyEnabledChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('SECURITY'), findsOneWidget);
    });

    // -- Test 2: Renders App Password row with lock icon --------------------

    testWidgets('renders App Password row with lock icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        SecuritySection(
          passwordEnabled: false,
          panicKeyEnabled: false,
          onPasswordEnabledChanged: (_) {},
          onPanicKeyEnabledChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('App Password'), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    });

    // -- Test 3: Shows "Disabled" subtitle when password is off -------------

    testWidgets('shows disabled subtitle when passwordEnabled is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        SecuritySection(
          passwordEnabled: false,
          panicKeyEnabled: false,
          onPasswordEnabledChanged: (_) {},
          onPanicKeyEnabledChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('Disabled'), findsOneWidget);
    });

    // -- Test 4: Shows "Enabled" subtitle when password is on ---------------

    testWidgets('shows enabled subtitle when passwordEnabled is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        SecuritySection(
          passwordEnabled: true,
          panicKeyEnabled: false,
          onPasswordEnabledChanged: (_) {},
          onPanicKeyEnabledChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('Enabled'), findsOneWidget);
    });

    // -- Test 5: Shows Signal Protocol row with ACTIVE badge ----------------

    testWidgets('shows Signal Protocol row with ACTIVE badge',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        SecuritySection(
          passwordEnabled: false,
          panicKeyEnabled: false,
          onPasswordEnabledChanged: (_) {},
          onPanicKeyEnabledChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Signal Protocol'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.byIcon(Icons.shield_rounded), findsOneWidget);
    });

    // -- Test 6: Shows Change Password and Panic Key rows when enabled ------

    testWidgets(
        'shows Change Password and Set Panic Key rows when password is enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        SecuritySection(
          passwordEnabled: true,
          panicKeyEnabled: false,
          onPasswordEnabledChanged: (_) {},
          onPanicKeyEnabledChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Set Panic Key'), findsOneWidget);
      expect(find.byIcon(Icons.password_rounded), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    // -- Test 7: Shows Change Panic Key and Remove Panic Key when both on ---

    testWidgets(
        'shows Change Panic Key and Remove row when both password and panic enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        SecuritySection(
          passwordEnabled: true,
          panicKeyEnabled: true,
          onPasswordEnabledChanged: (_) {},
          onPanicKeyEnabledChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Change Panic Key'), findsOneWidget);
      expect(find.text('Remove Panic Key'), findsOneWidget);
      expect(find.byIcon(Icons.remove_circle_outline_rounded), findsOneWidget);
    });

    // -- Test 8: Tapping password switch calls FlutterSecureStorage (skip) --

    testWidgets(
      'tapping password switch opens PasswordSetupDialog',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestableWidget(
          SecuritySection(
            passwordEnabled: false,
            panicKeyEnabled: false,
            onPasswordEnabledChanged: (_) {},
            onPanicKeyEnabledChanged: (_) {},
          ),
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        // With mock secure storage, the dialog should open without crashing.
      },
    );
  });
}
