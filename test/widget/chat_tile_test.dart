// Widget tests for ChatTile (lib/widgets/chat_tile.dart).
//
// Tests focus on structure: contact name, last message preview, unread badge,
// muted icon. ChatTile is a pure rendering widget with no platform deps.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/models/contact.dart';
import 'package:pulse_messenger/models/message.dart';
import 'package:pulse_messenger/widgets/chat_tile.dart';

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
    home: Scaffold(body: child),
  );
}

Contact _makeContact({
  String id = 'c1',
  String name = 'Alice',
  bool isGroup = false,
  List<String> alternateAddresses = const [],
}) {
  return Contact(
    id: id,
    name: name,
    provider: 'Nostr',
    databaseId: 'pubkey@wss://relay.example.com',
    publicKey: 'pk123',
    isGroup: isGroup,
    alternateAddresses: alternateAddresses,
  );
}

Message _makeMessage({
  String senderId = 'me',
  String text = 'Hello there',
  DateTime? timestamp,
}) {
  return Message(
    id: 'msg1',
    senderId: senderId,
    receiverId: 'c1',
    encryptedPayload: text,
    timestamp: timestamp ?? DateTime.now(),
    adapterType: 'nostr',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ChatTile', () {
    // ── Test 1: Renders contact name ──────────────────────────────────────────

    testWidgets('renders contact name', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        ChatTile(
          contact: _makeContact(name: 'Bob'),
          lastMsg: null,
          unreadCount: 0,
          myId: 'me',
          isOnline: false,
          isMuted: false,
          avatarBytes: null,
          onTap: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Bob'), findsOneWidget);
    });

    // ── Test 2: Shows last message preview ────────────────────────────────────

    testWidgets('shows last message preview with "You:" prefix for own messages',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        ChatTile(
          contact: _makeContact(),
          lastMsg: _makeMessage(senderId: 'me', text: 'Hey Alice'),
          unreadCount: 0,
          myId: 'me',
          isOnline: false,
          isMuted: false,
          avatarBytes: null,
          onTap: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // The chat tile uses context.l10n.chatTileYouPrefix(text) which produces
      // "You: Hey Alice" in English.
      expect(find.textContaining('You:'), findsOneWidget);
    });

    // ── Test 3: Shows unread badge ────────────────────────────────────────────

    testWidgets('shows unread badge with count when unreadCount > 0',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        ChatTile(
          contact: _makeContact(),
          lastMsg: _makeMessage(senderId: 'c1', text: 'New message'),
          unreadCount: 5,
          myId: 'me',
          isOnline: false,
          isMuted: false,
          avatarBytes: null,
          onTap: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('5'), findsOneWidget);
    });

    // ── Test 4: No unread badge when count is 0 ───────────────────────────────

    testWidgets('does not show unread badge when unreadCount is 0',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        ChatTile(
          contact: _makeContact(),
          lastMsg: null,
          unreadCount: 0,
          myId: 'me',
          isOnline: false,
          isMuted: false,
          avatarBytes: null,
          onTap: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // The unread badge renders '0' text when count > 0. Since count is 0,
      // no badge container should exist.
      expect(find.text('0'), findsNothing);
    });

    // ── Test 5: Shows muted icon when muted ───────────────────────────────────

    testWidgets('shows notifications_off icon when muted',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        ChatTile(
          contact: _makeContact(),
          lastMsg: null,
          unreadCount: 0,
          myId: 'me',
          isOnline: false,
          isMuted: true,
          avatarBytes: null,
          onTap: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.notifications_off_rounded), findsOneWidget);
    });

    // ── Test 6: Does not show muted icon when not muted ───────────────────────

    testWidgets('does not show notifications_off icon when not muted',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        ChatTile(
          contact: _makeContact(),
          lastMsg: null,
          unreadCount: 0,
          myId: 'me',
          isOnline: false,
          isMuted: false,
          avatarBytes: null,
          onTap: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.notifications_off_rounded), findsNothing);
    });

    // ── Test 7: Shows "Tap to start chatting" when no last message ────────────

    testWidgets('shows default subtitle when lastMsg is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        ChatTile(
          contact: _makeContact(),
          lastMsg: null,
          unreadCount: 0,
          myId: 'me',
          isOnline: false,
          isMuted: false,
          avatarBytes: null,
          onTap: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Tap to start chatting'), findsOneWidget);
    });

    // ── Test 8: InkWell is present for tap handling ───────────────────────────

    testWidgets('has InkWell for tap handling', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        ChatTile(
          contact: _makeContact(),
          lastMsg: null,
          unreadCount: 0,
          myId: 'me',
          isOnline: false,
          isMuted: false,
          avatarBytes: null,
          onTap: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(InkWell), findsOneWidget);
    });
  });
}
