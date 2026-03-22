// Widget tests for HomeScreen (lib/screens/home_screen.dart).
//
// ALL tests are skipped because HomeScreen depends on:
// - ChatController singleton (11+ stream subscriptions in initState)
// - IContactRepository via Provider
// - ConnectivityProbeService, TorService, UTLSService singletons
// - LocalStorageService (SQLite)
// - SharedPreferences (runtime reads for muted chats, SQLCipher warning)
// - StatusService singleton
// - flutter_animate package
//
// These tests document what should be tested once proper dependency injection
// or mock infrastructure is available.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';

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
  });

  group('HomeScreen', () {
    // ── Test 1: Renders chat list with contacts ─────────────────────────────
    testWidgets(
      'renders chat list with contacts sorted by last message time',
      (WidgetTester tester) async {
        // HomeScreen.initState subscribes to 11+ streams from ChatController,
        // ConnectivityProbeService, TorService, UTLSService.
        // It reads IContactRepository via Provider to list contacts.
        // Would need:
        // - Mock ChatController providing incomingCalls, incomingGroupCalls,
        //   groupInvites, groupInviteDeclines, newMessages, statusUpdates,
        //   failoverEvents, typingUpdates streams
        // - Mock IContactRepository with test contacts
        // - Mock ConnectivityProbeService.instance.status stream
        // - Mock TorService.instance.stateChanges stream
        // - Mock UTLSService.instance.available ValueNotifier
        // - Mock LocalStorageService for avatar loading
      },
      skip: true, // Requires ChatController, IContactRepository, and 5+ service singletons
    );

    // ── Test 2: Shows empty state when no contacts ──────────────────────────
    testWidgets(
      'shows empty state with "No chats yet" when contact list is empty',
      (WidgetTester tester) async {
        // When IContactRepository.contacts is empty, HomeScreen shows
        // a centered column with chat_bubble icon, "No chats yet" text,
        // "Add a contact" subtitle, and a "New Chat" button.
        // Requires same mock infrastructure as Test 1.
      },
      skip: true, // Requires ChatController, IContactRepository, and service singletons
    );

    // ── Test 3: FAB navigates to ContactsScreen ─────────────────────────────
    testWidgets(
      'floating action button navigates to ContactsScreen',
      (WidgetTester tester) async {
        // The FAB with chat_rounded icon calls Navigator.push to ContactsScreen.
        // Would test that tapping FAB pushes the ContactsScreen route.
        // Requires same mock infrastructure as Test 1.
      },
      skip: true, // Requires ChatController, IContactRepository, and service singletons
    );
  });
}
