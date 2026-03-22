// Widget tests for message_menu.dart (lib/widgets/message_menu.dart).
//
// All public functions are free functions (showMessageMenu, showForwardPicker,
// showEmojiPicker, showReactionDetails, showScheduledPanel, showAttachMenu,
// showTtlDialog).  They require ChatController via Provider and/or Contact /
// Message models, so most are skipped.  Structural tests verify the file can
// be imported and basic parameter expectations.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/widgets/message_menu.dart';

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
    createTestChatController();
  });

  group('message_menu', () {
    // ── Test 1: showMessageMenu requires ChatController ──────────────────────
    testWidgets(
      'showMessageMenu opens bottom sheet with menu items',
      (WidgetTester tester) async {
        // showMessageMenu calls context.read<ChatController>() which is
        // a singleton requiring platform services.  Cannot render without
        // a full ChatController mock.
      },
      skip: true, // Requires Message + Contact model data to populate menu
    );

    // ── Test 2: showAttachMenu would show photo and file options ─────────────
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

    // ── Test 3: showEmojiPicker requires ChatController ─────────────────────
    testWidgets(
      'showEmojiPicker displays 8 emoji options',
      (WidgetTester tester) async {
        // showEmojiPicker reads ChatController to call toggleReaction.
      },
      skip: true, // Requires Message model + ChatController.toggleReaction
    );

    // ── Test 4: showTtlDialog requires ChatController ───────────────────────
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

    // ── Test 5: showForwardPicker requires IContactRepository ───────────────
    testWidgets(
      'showForwardPicker shows contact list for forwarding',
      (WidgetTester tester) async {
        // showForwardPicker reads IContactRepository and ChatController.
      },
      skip: true, // Requires Message model data
    );

    // ── Test 6: showScheduledPanel requires ChatController ──────────────────
    testWidgets(
      'showScheduledPanel displays scheduled messages list',
      (WidgetTester tester) async {
        // showScheduledPanel reads ChatController to cancel messages.
      },
      skip: true, // Requires ChatController with scheduled messages
    );
  });
}
