// Widget tests for MessageInputBar (lib/widgets/message_input_bar.dart).
//
// Tests focus on: text field presence, attach button, send/mic button.
// MessageInputBar is a pure rendering widget with callbacks.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/widgets/message_input_bar.dart';

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

MessageInputBar _makeInputBar({
  TextEditingController? controller,
  FocusNode? focusNode,
}) {
  return MessageInputBar(
    controller: controller ?? TextEditingController(),
    focusNode: focusNode ?? FocusNode(),
    inputFocused: false,
    isRecording: false,
    recordingSeconds: 0,
    replyingTo: null,
    editingMessageId: null,
    scheduledCount: 0,
    onSend: () {},
    onAttach: () {},
    onStartRecording: () {},
    onStopRecording: () {},
    onCancelRecording: () {},
    onCancelReply: () {},
    onCancelEdit: () {},
    onSchedulePicker: () {},
    onShowScheduledPanel: () {},
    onToggleEmojiPicker: () {},
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MessageInputBar', () {
    // ── Test 1: Has a text field ──────────────────────────────────────────────

    testWidgets('has a TextField', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(_makeInputBar()));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    // ── Test 2: Text field has "Message..." hint ──────────────────────────────

    testWidgets('text field shows "Message..." hint',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(_makeInputBar()));
      await tester.pumpAndSettle();

      // The l10n key inputMessage is "Message..."
      expect(find.text('Message...'), findsOneWidget);
    });

    // ── Test 3: Has attach button (attach_file icon) ──────────────────────────

    testWidgets('has an attach button with attach_file icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(_makeInputBar()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.attach_file_rounded), findsOneWidget);
    });

    // ── Test 4: Shows mic button when text is empty ───────────────────────────

    testWidgets('shows mic button when text field is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(_makeInputBar()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
    });

    // ── Test 5: Shows send button when text is entered ────────────────────────

    testWidgets('shows send button when text is entered',
        (WidgetTester tester) async {
      final controller = TextEditingController(text: 'Hello');
      await tester.pumpWidget(buildTestableWidget(
        _makeInputBar(controller: controller),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    });

    // ── Test 6: Attach button has Semantics label ─────────────────────────────

    testWidgets('attach button has Semantics label',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(_makeInputBar()));
      await tester.pumpAndSettle();

      // The Semantics label is context.l10n.inputAttachFile = "Attach file"
      final semantics = find.bySemanticsLabel('Attach file');
      expect(semantics, findsOneWidget);
    });

    // ── Test 7: SafeArea wraps content ────────────────────────────────────────

    testWidgets('wraps content in SafeArea', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(_makeInputBar()));
      await tester.pumpAndSettle();

      expect(find.byType(SafeArea), findsOneWidget);
    });

    // ── Test 8: Has emoji toggle button ──────────────────────────────────────

    testWidgets('has emoji toggle button (smiley icon)',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(_makeInputBar()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.emoji_emotions_outlined), findsOneWidget);
    });

    // ── Test 9: Emoji button shows keyboard icon when picker is open ─────────

    testWidgets('shows keyboard icon when emoji picker is open',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        MessageInputBar(
          controller: TextEditingController(),
          focusNode: FocusNode(),
          inputFocused: false,
          isRecording: false,
          recordingSeconds: 0,
          replyingTo: null,
          editingMessageId: null,
          scheduledCount: 0,
          showEmojiPicker: true,
          onSend: () {},
          onAttach: () {},
          onStartRecording: () {},
          onStopRecording: () {},
          onCancelRecording: () {},
          onCancelReply: () {},
          onCancelEdit: () {},
          onSchedulePicker: () {},
          onShowScheduledPanel: () {},
          onToggleEmojiPicker: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.keyboard_rounded), findsOneWidget);
      expect(find.byIcon(Icons.emoji_emotions_outlined), findsNothing);
    });
  });
}
