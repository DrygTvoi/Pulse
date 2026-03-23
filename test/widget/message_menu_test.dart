// Widget tests for message_menu.dart (lib/widgets/message_menu.dart).
//
// Tests the public free functions: showMessageMenu, showAttachMenu,
// showEmojiPicker, showForwardPicker, showScheduledPanel, showTtlDialog.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/widgets/message_menu.dart';

import '../helpers/test_mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    setUpSecureStorageMock();
    setUpServiceMocks();
    createTestChatController();
  });

  group('message_menu', () {
    // ── Test 1: showMessageMenu ─────────────────────────────────────────────
    testWidgets(
      'showMessageMenu opens bottom sheet with menu items',
      (WidgetTester tester) async {
        // Use a taller surface so the bottom sheet Column does not overflow.
        await tester.binding.setSurfaceSize(const Size(640, 1200));
        addTearDown(() => tester.binding.setSurfaceSize(const Size(800, 600)));

        final message = testMessage();
        final contact = testContact();

        await tester.pumpWidget(buildTestApp(
          Builder(builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () => showMessageMenu(
                  context: context,
                  message: message,
                  myId: 'me',
                  onReply: () {},
                  onForward: (_) {},
                  onShowEmojiPicker: (_) {},
                  onDelete: (_) {},
                  onEdit: (_, _) {},
                  contact: contact,
                ),
                child: const Text('Open'),
              ),
            );
          }),
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Verify core menu items are present
        expect(find.text('Reply'), findsOneWidget);
        expect(find.text('Forward'), findsOneWidget);
        expect(find.text('React'), findsOneWidget);
        expect(find.text('Copy'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);
      },
    );

    // ── Test 2: showAttachMenu ──────────────────────────────────────────────
    testWidgets(
      'showAttachMenu displays photo and file options',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestApp(
          Builder(builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () => showAttachMenu(
                  context: context,
                  onPickImage: () {},
                  onPickFile: () {},
                  onPickVideo: () {},
                ),
                child: const Text('Open'),
              ),
            );
          }),
        ));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(find.text('Photo'), findsOneWidget);
        expect(find.text('File'), findsOneWidget);
      },
    );

    // ── Test 3: showEmojiPicker ─────────────────────────────────────────────
    testWidgets(
      'showEmojiPicker displays 8 emoji options',
      (WidgetTester tester) async {
        final contact = testContact();

        await tester.pumpWidget(buildTestApp(
          Builder(builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () => showEmojiPicker(
                  context: context,
                  messageId: 'msg-1',
                  contact: contact,
                ),
                child: const Text('Open'),
              ),
            );
          }),
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Verify all 8 emoji options are displayed
        expect(find.text('👍'), findsOneWidget);
        expect(find.text('❤️'), findsOneWidget);
        expect(find.text('😂'), findsOneWidget);
        expect(find.text('😮'), findsOneWidget);
        expect(find.text('😢'), findsOneWidget);
        expect(find.text('🙏'), findsOneWidget);
        expect(find.text('🔥'), findsOneWidget);
        expect(find.text('👎'), findsOneWidget);
      },
    );

    // ── Test 4: showTtlDialog ───────────────────────────────────────────────
    testWidgets(
      'showTtlDialog displays disappearing message options',
      (WidgetTester tester) async {
        final contact = testContact(name: 'Alice');
        await tester.pumpWidget(buildTestApp(
          Builder(builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () => showTtlDialog(
                  context: context,
                  currentTtlSeconds: 0,
                  contact: contact,
                  onTtlChanged: (v) {},
                ),
                child: const Text('TTL'),
              ),
            );
          }),
        ));
        await tester.pumpAndSettle();
        await tester.tap(find.text('TTL'));
        await tester.pumpAndSettle();
        expect(find.text('Disappearing Messages'), findsOneWidget);
      },
    );

    // ── Test 5: showForwardPicker ───────────────────────────────────────────
    testWidgets(
      'showForwardPicker shows contact list for forwarding',
      (WidgetTester tester) async {
        final currentContact = testContact(
          id: 'contact-1',
          name: 'Alice',
        );
        final otherContact = testContact(
          id: 'contact-2',
          name: 'Bob',
          databaseId: 'bob123@wss://relay.example.com',
          publicKey: 'pubkey-bob',
        );
        final message = testMessage();

        // Create controller with contacts so the forward picker has entries
        final contacts = [currentContact, otherContact];
        final cc = createTestChatController(contacts);
        final repo = FakeContactRepository(contacts);

        await tester.pumpWidget(buildTestApp(
          Builder(builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () => showForwardPicker(
                  context: context,
                  message: message,
                  currentContact: currentContact,
                  avatarBuilder: (name, size) => CircleAvatar(
                    radius: size / 2,
                    child: Text(name[0]),
                  ),
                ),
                child: const Text('Open'),
              ),
            );
          }),
          chatController: cc,
          contactRepository: repo,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Verify the forward picker title appears
        expect(find.textContaining('Forward to'), findsOneWidget);
        // Verify Bob (the other contact) is listed, but not Alice (current)
        expect(find.text('Bob'), findsOneWidget);
        expect(find.text('Alice'), findsNothing);
      },
    );

    // ── Test 6: showScheduledPanel ──────────────────────────────────────────
    testWidgets(
      'showScheduledPanel displays scheduled messages list',
      (WidgetTester tester) async {
        final contact = testContact();
        final scheduledMessage = testMessage(
          id: 'sched-1',
          encryptedPayload: 'See you tomorrow!',
          status: 'scheduled',
        );

        await tester.pumpWidget(buildTestApp(
          Builder(builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () => showScheduledPanel(
                  context: context,
                  scheduled: [scheduledMessage],
                  contact: contact,
                ),
                child: const Text('Open'),
              ),
            );
          }),
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Verify the scheduled messages panel title
        expect(find.text('Scheduled messages'), findsOneWidget);
        // Verify the scheduled message content is displayed
        expect(find.text('See you tomorrow!'), findsOneWidget);
      },
    );

    // ── Test 7: showAttachMenu shows Video option ─────────────────────────
    testWidgets(
      'showAttachMenu displays Video option',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestApp(
          Builder(builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () => showAttachMenu(
                  context: context,
                  onPickImage: () {},
                  onPickFile: () {},
                  onPickVideo: () {},
                ),
                child: const Text('Open'),
              ),
            );
          }),
        ));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(find.text('Photo'), findsOneWidget);
        expect(find.text('Video'), findsOneWidget);
        expect(find.text('File'), findsOneWidget);
      },
    );

    // ── Test 8: showEmojiPicker has "+" button for full picker ────────────
    testWidgets(
      'showEmojiPicker displays quick reactions and "+" button',
      (WidgetTester tester) async {
        final contact = testContact();

        await tester.pumpWidget(buildTestApp(
          Builder(builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () => showEmojiPicker(
                  context: context,
                  messageId: 'msg-1',
                  contact: contact,
                ),
                child: const Text('Open'),
              ),
            );
          }),
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Verify the "+" button (add_rounded icon) for full emoji picker is present
        expect(find.byIcon(Icons.add_rounded), findsOneWidget);
        // Quick reactions still present
        expect(find.text('👍'), findsOneWidget);
        expect(find.text('❤️'), findsOneWidget);
      },
    );
  });
}
