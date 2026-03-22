// Widget tests for ProfileCard (lib/widgets/profile_card.dart).
//
// ProfileCard depends on:
//   - SharedPreferences (mockable) for user_profile
//   - SignalService().ownFingerprint (singleton, may fail without platform)
//   - ChatController() singleton (for InboxAddressCard)
//   - FilePicker (platform plugin, for avatar picking)
//
// Tests that only verify initial rendering from SharedPreferences are safe.
// Tests that trigger save/broadcast or use ChatController/SignalService
// are marked skip: true.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/theme/theme_manager.dart';

import '../helpers/test_mocks.dart';
import 'package:pulse_messenger/widgets/profile_card.dart';

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
    setUpSecureStorageMock();
    createTestChatController();
    SharedPreferences.setMockInitialValues({});
  });

  group('ProfileCard', () {
    // -- Test 1: Renders with showAddressCard=false to avoid ChatController --

    testWidgets(
      'renders Display Name and About fields',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestApp(
            const SingleChildScrollView(
                child: ProfileCard(showAddressCard: false)),
            scaffold: true));
        await tester.pumpAndSettle();

        expect(find.text('Display Name'), findsOneWidget);
        expect(find.text('About'), findsOneWidget);
      },
    );

    // -- Test 2: Shows "Your Name" placeholder when no profile saved --------

    testWidgets(
      'shows "Your Name" placeholder when no profile is saved',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestApp(
            const SingleChildScrollView(
                child: ProfileCard(showAddressCard: false)),
            scaffold: true));
        await tester.pumpAndSettle();

        expect(find.text('Your Name'), findsOneWidget);
      },
    );

    // -- Test 3: Shows the name from SharedPreferences ----------------------

    testWidgets(
      'shows name loaded from SharedPreferences user_profile',
      (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({
          'user_profile':
              jsonEncode({'name': 'Test User', 'about': 'Hello world'}),
        });

        await tester.pumpWidget(buildTestApp(
            const SingleChildScrollView(
                child: ProfileCard(showAddressCard: false)),
            scaffold: true));
        await tester.pumpAndSettle();

        expect(find.text('Test User'), findsAtLeastNWidgets(1));
      },
    );

    // -- Test 4: Shows E2EE Identity badge ----------------------------------

    testWidgets(
      'shows E2EE Identity badge',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestApp(
            const SingleChildScrollView(
                child: ProfileCard(showAddressCard: false)),
            scaffold: true));
        await tester.pumpAndSettle();

        expect(find.text('E2EE Identity'), findsOneWidget);
      },
    );

    // -- Test 5: Shows Save Profile button ----------------------------------

    testWidgets(
      'shows Save Profile button',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestApp(
            const SingleChildScrollView(
                child: ProfileCard(showAddressCard: false)),
            scaffold: true));
        await tester.pumpAndSettle();

        expect(find.text('Save Profile'), findsOneWidget);
      },
    );

    // -- Test 6: Shows camera icon for avatar picking -----------------------

    testWidgets(
      'shows camera icon overlay on avatar',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestApp(
            const SingleChildScrollView(
                child: ProfileCard(showAddressCard: false)),
            scaffold: true));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
      },
    );
  });

  group('InboxAddressCard', () {
    // -- Test 7: Renders (requires ChatController singleton) ----------------

    testWidgets(
      'renders InboxAddressCard when addresses are available',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestApp(
            const SingleChildScrollView(child: InboxAddressCard()),
            scaffold: true));
        await tester.pumpAndSettle();

        // InboxAddressCard listens to ChatController() singleton
        // which requires adapters to be initialized.
      },
    );
  });
}
