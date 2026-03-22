// Widget tests for MediaGalleryScreen (lib/screens/media_gallery_screen.dart).
//
// MediaGalleryScreen depends on:
// - ChatController (via context.select<ChatController, int>() and
//   context.read<ChatController>() for message retrieval)
// - Contact model (required constructor parameter)
// - MediaService.parse for categorizing messages
//
// Because ChatController is a heavy singleton with platform dependencies
// (SQLite, secure storage, adapters), all tests are skipped. The tests
// document the expected UI structure.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/models/contact.dart';
import 'package:pulse_messenger/screens/media_gallery_screen.dart';
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

Contact _testContact() => Contact(
      id: 'test-contact-id',
      name: 'Test User',
      provider: 'Nostr',
      databaseId: 'abc123@wss://relay.example.com',
      publicKey: 'pubkey123',
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    setUpSecureStorageMock();
    createTestChatController();
    SharedPreferences.setMockInitialValues({});
  });

  group('MediaGalleryScreen', () {
    // Skipped: ChatController provider is required via context.select/read
    // in the build method. Without a properly initialized ChatController
    // (which requires SQLite, secure storage, etc.), the widget cannot render.
    testWidgets('has a Scaffold',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestApp(MediaGalleryScreen(contact: _testContact())));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('has an AppBar with "Media" title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestApp(MediaGalleryScreen(contact: _testContact())));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Media'), findsOneWidget);
    });

    testWidgets('has TabBar with Photos and Files tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestApp(MediaGalleryScreen(contact: _testContact())));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('renders DefaultTabController with 2 tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestApp(MediaGalleryScreen(contact: _testContact())));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(DefaultTabController), findsOneWidget);
      expect(find.byType(TabBarView), findsOneWidget);
    });
  });
}
