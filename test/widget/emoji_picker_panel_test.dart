// Widget tests for EmojiPickerPanel (lib/widgets/emoji_picker_panel.dart).

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/widgets/emoji_picker_panel.dart';

Widget _buildTestApp(Widget child) {
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EmojiPickerPanel', () {
    testWidgets('renders EmojiPicker widget', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(
        EmojiPickerPanel(
          onEmojiSelected: (_) {},
          onBackspace: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(EmojiPicker), findsOneWidget);
    });

    testWidgets('has height of 280', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(
        EmojiPickerPanel(
          onEmojiSelected: (_) {},
          onBackspace: () {},
        ),
      ));
      await tester.pumpAndSettle();

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(EmojiPicker),
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(sizedBox.height, equals(280));
    });

    testWidgets('wraps content in SizedBox', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(
        EmojiPickerPanel(
          onEmojiSelected: (_) {},
          onBackspace: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}
