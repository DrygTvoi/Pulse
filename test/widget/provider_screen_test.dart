// Widget tests for ProviderScreen (lib/screens/settings/provider_screen.dart).
//
// The ProviderScreen relies on SharedPreferences, FlutterSecureStorage, and
// the ChatController singleton. Because ChatController is a non-injectable
// singleton that calls into platform channels (SQLite, secure storage, etc.),
// full integration pumping is not feasible in a pure widget-test environment.
//
// These tests therefore focus on the widget tree structure: verifying that
// the screen renders, that the provider chips are present, and that the
// save button exists.  Tests that would trigger ChatController are skipped
// with a descriptive message.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/screens/settings/provider_screen.dart';

import '../helpers/test_mocks.dart';

/// Wraps [child] in a [MaterialApp] with the localization delegates and
/// supported locales required by the app (mirrors main.dart configuration).
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
  // Required for SharedPreferences in test environment.
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Mock SharedPreferences with empty values so the widget can call
    // SharedPreferences.getInstance() without hitting platform channels.
    SharedPreferences.setMockInitialValues({});
    setUpSecureStorageMock();
    createTestChatController();
  });

  group('ProviderScreen', () {
    // ─── Test 1: Renders without errors ──────────────────────────────────────

    testWidgets('renders with Inboxes title and shows loading indicator initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const ProviderScreen()));

      // The AppBar title should be "Inboxes" (hardcoded in build()).
      expect(find.text('Inboxes'), findsOneWidget);

      // On the very first frame the screen is in _loading == true state,
      // so it shows a CircularProgressIndicator.adaptive().
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // ─── Test 2: Provider chips are displayed after loading ──────────────────

    testWidgets('displays Firebase, Nostr, Session provider chip texts',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const ProviderScreen()));

      // Pump once more to allow the async _load() to complete.
      // _load() reads SharedPreferences (mocked) and sets _loading = false.
      await tester.pumpAndSettle();

      // After loading, the provider chips should be in the tree.
      // Each chip renders the provider name as a Text widget inside a Row.
      expect(find.text('Firebase'), findsWidgets);
      expect(find.text('Nostr'), findsWidgets);
      expect(find.text('Session'), findsWidgets);
    },
        // FlutterSecureStorage calls may fail in test environment because
        // there is no platform channel mock for it. Skip gracefully if so.
        skip: false);

    // ─── Test 3: Save button exists ──────────────────────────────────────────

    testWidgets('shows Save & Connect button after loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const ProviderScreen()));
      await tester.pumpAndSettle();

      // The save button is an ElevatedButton with localized text
      // "Save & Connect" (providerSaveAndConnect).
      expect(find.byType(ElevatedButton), findsWidgets);

      // Verify the localized text is present.
      expect(find.text('Save & Connect'), findsOneWidget);
    },
        skip: false);

    // ─── Test 4: AppBar is properly configured ──────────────────────────────

    testWidgets('has an AppBar with correct title', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const ProviderScreen()));

      expect(find.byType(AppBar), findsOneWidget);

      // Title text "Inboxes" should be within the AppBar.
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.title, isA<Text>());
      expect((appBar.title! as Text).data, equals('Inboxes'));
    });

    // ─── Test 5: Secondary inboxes section is displayed ─────────────────────

    testWidgets('displays secondary inboxes section label after loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const ProviderScreen()));
      await tester.pumpAndSettle();

      // The secondary inboxes section shows a "SECONDARY INBOXES" label
      // (hardcoded in the build method).
      expect(find.text('SECONDARY INBOXES'), findsOneWidget);
    },
        skip: false);

    // ─── Test 6: Add Secondary Inbox button exists ──────────────────────────

    testWidgets('displays Add Secondary Inbox button after loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const ProviderScreen()));
      await tester.pumpAndSettle();

      // The "Add Secondary Inbox" button text comes from l10n.
      expect(find.text('Add Secondary Inbox'), findsOneWidget);
    },
        skip: false);

    // ─── Test 7: Default selected provider is Firebase ──────────────────────

    testWidgets('Firebase is the default selected provider',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const ProviderScreen()));
      await tester.pumpAndSettle();

      // When Firebase is selected, the Firebase-specific config fields
      // should be visible: "Database URL" label.
      expect(find.text('Database URL'), findsOneWidget);
    },
        skip: false);

    // ─── Test 8: Scaffold uses correct background ───────────────────────────

    testWidgets('Scaffold is present in widget tree',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const ProviderScreen()));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    // ─── Test 9: Saving interaction (skipped — requires ChatController) ─────

    testWidgets('tapping Save & Connect triggers save flow',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const ProviderScreen()));
      await tester.pumpAndSettle();

      // Tap Save & Connect — with mock secure storage and test ChatController,
      // the save flow should execute without unhandled exceptions.
      await tester.tap(find.text('Save & Connect'));
      await tester.pumpAndSettle();
    });

    // ─── Test 10: Loading state transitions to content ──────────────────────

    testWidgets('transitions from loading indicator to content',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const ProviderScreen()));

      // Initially loading.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Save & Connect'), findsNothing);

      // After settling, content should be visible.
      await tester.pumpAndSettle();

      // Loading indicator should be gone, content should be shown.
      // The save button text should now be present.
      expect(find.text('Save & Connect'), findsOneWidget);
    },
        skip: false);
  });
}
