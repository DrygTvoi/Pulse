// Widget tests for ChatScreen (lib/screens/chat_screen.dart).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pulse_messenger/screens/chat_screen.dart';

import '../helpers/test_mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    setUpSecureStorageMock();
    setUpServiceMocks();
    createTestChatController();
  });

  group('ChatScreen', () {
    // ── Test 1: Renders message list and input bar ──────────────────────────
    testWidgets(
      'renders message list with MessageInputBar',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(ChatScreen(contact: testContact())),
        );
        // Use pump with duration instead of pumpAndSettle because
        // flutter_animate creates persistent animations.
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // The screen should render a Scaffold
        expect(find.byType(Scaffold), findsWidgets);

        // The MessageInputBar should be present at the bottom
        expect(find.byType(TextField), findsWidgets);
      },
    );

    // ── Test 2: Shows empty conversation state ──────────────────────────────
    testWidgets(
      'shows empty conversation state with lock icon and E2EE message',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(ChatScreen(contact: testContact())),
        );
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // When room has no messages, ChatScreen shows a lock icon
        expect(find.byIcon(Icons.lock_rounded), findsWidgets);
      },
    );

    // ── Test 3: Search mode ─────────────────────────────────────────────────
    testWidgets(
      'activating search mode shows search TextField in AppBar',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(ChatScreen(contact: testContact())),
        );
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // Tap the search icon in the AppBar to activate search mode
        final searchIcon = find.byIcon(Icons.search_rounded);
        expect(searchIcon, findsOneWidget);
        await tester.tap(searchIcon);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // After activating search, the AppBar switches to buildSearchAppBar
        // which contains a TextField with autofocus for the search query.
        // There should now be at least two TextFields: one for search, one
        // for message input.
        final textFields = find.byType(TextField);
        expect(textFields, findsAtLeast(2));
      },
    );
  });
}
