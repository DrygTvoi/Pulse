// Widget tests for CustomTextField (lib/widgets/custom_text_field.dart).
//
// Tests focus on: TextField rendering, hint text, onSubmitted callback,
// prefix icon, pill-shaped border, and text input.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/theme/theme_manager.dart';
import 'package:pulse_messenger/widgets/custom_text_field.dart';

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
      home: Scaffold(body: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      )),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CustomTextField', () {
    // ── Test 1: Renders a TextField ───────────────────────────────────────────

    testWidgets('renders a TextField', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(buildTestableWidget(
        CustomTextField(
          controller: controller,
          hintText: 'Type here',
          onSubmitted: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);

      controller.dispose();
    });

    // ── Test 2: Shows hint text ───────────────────────────────────────────────

    testWidgets('shows hint text', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(buildTestableWidget(
        CustomTextField(
          controller: controller,
          hintText: 'Search...',
          onSubmitted: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Search...'), findsOneWidget);

      controller.dispose();
    });

    // ── Test 3: Calls onSubmitted when text is submitted ──────────────────────

    testWidgets('calls onSubmitted when text is submitted',
        (WidgetTester tester) async {
      final controller = TextEditingController();
      bool submitted = false;

      await tester.pumpWidget(buildTestableWidget(
        CustomTextField(
          controller: controller,
          hintText: 'Message',
          onSubmitted: () => submitted = true,
        ),
      ));
      await tester.pumpAndSettle();

      // Enter text and submit
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pumpAndSettle();

      expect(submitted, isTrue);

      controller.dispose();
    });

    // ── Test 4: Displays entered text ─────────────────────────────────────────

    testWidgets('displays text entered via controller',
        (WidgetTester tester) async {
      final controller = TextEditingController(text: 'Prefilled');

      await tester.pumpWidget(buildTestableWidget(
        CustomTextField(
          controller: controller,
          hintText: 'Hint',
          onSubmitted: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Prefilled'), findsOneWidget);

      controller.dispose();
    });

    // ── Test 5: Renders prefix icon when provided ─────────────────────────────

    testWidgets('renders prefix icon when provided',
        (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(buildTestableWidget(
        CustomTextField(
          controller: controller,
          hintText: 'Search',
          onSubmitted: () {},
          prefixIcon: const Icon(Icons.search),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);

      controller.dispose();
    });

    // ── Test 6: No prefix icon when not provided ──────────────────────────────

    testWidgets('does not render prefix icon when not provided',
        (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(buildTestableWidget(
        CustomTextField(
          controller: controller,
          hintText: 'Type',
          onSubmitted: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // No search icon should be present
      expect(find.byIcon(Icons.search), findsNothing);

      controller.dispose();
    });

    // ── Test 7: Uses TextInputAction.send ─────────────────────────────────────

    testWidgets('uses TextInputAction.send', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(buildTestableWidget(
        CustomTextField(
          controller: controller,
          hintText: 'Message',
          onSubmitted: () {},
        ),
      ));
      await tester.pumpAndSettle();

      final textField =
          tester.widget<TextField>(find.byType(TextField));
      expect(textField.textInputAction, TextInputAction.send);

      controller.dispose();
    });

    // ── Test 8: Has filled decoration ─────────────────────────────────────────

    testWidgets('has filled InputDecoration', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(buildTestableWidget(
        CustomTextField(
          controller: controller,
          hintText: 'Test',
          onSubmitted: () {},
        ),
      ));
      await tester.pumpAndSettle();

      final textField =
          tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.filled, isTrue);

      controller.dispose();
    });
  });
}
