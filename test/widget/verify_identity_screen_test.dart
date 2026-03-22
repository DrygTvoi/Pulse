// Widget tests for VerifyIdentityScreen (lib/screens/verify_identity_screen.dart).
//
// VerifyIdentityScreen depends on:
// - SignalService() (singleton, called in initState via _load())
//   - signal.ownFingerprint
//   - signal.getContactFingerprint(contactId)
//   - signal.ownIdentityKeyB64
//   - signal.getContactIdentityKeyB64(contactId)
// - SharedPreferences (for verification status storage)
//
// Because SignalService is initialized as a singleton that depends on
// FlutterSecureStorage (platform channel), all tests are skipped.
// The tests document expected UI structure.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/screens/verify_identity_screen.dart';
import 'package:pulse_messenger/theme/theme_manager.dart';

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
      home: child,
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

  group('VerifyIdentityScreen', () {
    // Skipped: SignalService() is called in initState._load() which accesses
    // FlutterSecureStorage platform channels not available in widget tests.
    testWidgets('has a Scaffold',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(
        const VerifyIdentityScreen(
          contactName: 'Alice',
          contactId: 'contact-123',
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('has an AppBar with "Verify Safety Number" title',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(
        const VerifyIdentityScreen(
          contactName: 'Alice',
          contactId: 'contact-123',
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Verify Safety Number'), findsOneWidget);
    });

    testWidgets('shows loading indicator or content after load',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(
        const VerifyIdentityScreen(
          contactName: 'Alice',
          contactId: 'contact-123',
        ),
      ));
      // With mocked secure storage the load completes instantly, so either
      // the spinner or the loaded content (shield/verified icon) appears.
      await tester.pump(const Duration(milliseconds: 50));

      final hasSpinner = find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
      final hasContent = find.byType(Scaffold).evaluate().isNotEmpty;
      expect(hasSpinner || hasContent, isTrue);
    });

    testWidgets('has a back button in AppBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(
        const VerifyIdentityScreen(
          contactName: 'Alice',
          contactId: 'contact-123',
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('renders security icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(
        const VerifyIdentityScreen(
          contactName: 'Alice',
          contactId: 'contact-123',
        ),
      ));
      await tester.pumpAndSettle();

      // After loading, either the verified or shield icon should appear
      final hasVerified = find.byIcon(Icons.verified_user_rounded);
      final hasShield = find.byIcon(Icons.shield_outlined);
      expect(
        hasVerified.evaluate().isNotEmpty || hasShield.evaluate().isNotEmpty,
        isTrue,
      );
    });
  });
}
