// Widget tests for EmojiPickerPanel (lib/widgets/emoji_picker_panel.dart).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import 'package:pulse_messenger/widgets/emoji_picker_panel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EmojiPickerPanel', () {
    testWidgets('renders EmojiPicker widget', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EmojiPickerPanel(
            onEmojiSelected: (_) {},
            onBackspace: () {},
          ),
        ),
      ));
      await tester.pump();

      expect(find.byType(EmojiPicker), findsOneWidget);
    });

    testWidgets('has height of 280', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EmojiPickerPanel(
            onEmojiSelected: (_) {},
            onBackspace: () {},
          ),
        ),
      ));
      await tester.pump();

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.height, equals(280));
    });

    testWidgets('wraps content in SizedBox', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EmojiPickerPanel(
            onEmojiSelected: (_) {},
            onBackspace: () {},
          ),
        ),
      ));
      await tester.pump();

      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}
