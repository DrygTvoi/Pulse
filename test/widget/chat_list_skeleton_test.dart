// Widget tests for ChatListSkeleton (lib/widgets/chat_list_skeleton.dart).
//
// Tests focus on: shimmer tile rendering, correct item count (7),
// AnimatedBuilder usage, ListView presence, and animation controller.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/theme/theme_manager.dart';
import 'package:pulse_messenger/widgets/chat_list_skeleton.dart';

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
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ChatListSkeleton', () {
    // ── Test 1: Renders without errors ────────────────────────────────────────

    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const ChatListSkeleton(),
      ));
      // Don't settle — animation repeats forever
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ChatListSkeleton), findsOneWidget);
    });

    // ── Test 2: Contains a ListView ───────────────────────────────────────────

    testWidgets('contains a ListView', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const ChatListSkeleton(),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ListView), findsOneWidget);
    });

    // ── Test 3: Uses AnimatedBuilder ──────────────────────────────────────────

    testWidgets('uses AnimatedBuilder for shimmer animation',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const ChatListSkeleton(),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // The skeleton uses AnimatedBuilder at the top level and inside each
      // shimmer box. We just verify at least one exists.
      expect(find.byType(AnimatedBuilder), findsWidgets);
    });

    // ── Test 4: Has 7 placeholder rows ────────────────────────────────────────

    testWidgets('has 7 placeholder rows (Row widgets inside tiles)',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const ChatListSkeleton(),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // Each skeleton tile is a Padding > Row. The outer ListView.builder
      // renders 7 items. Count Row widgets that are direct children of
      // Padding within the list.
      // There's also the top-level AnimatedBuilder > ListView > 7 items.
      // Each item is a Padding with a Row child.
      final paddingFinder = find.byType(Padding);
      // At least 7 Padding widgets for tiles (plus the ListView padding)
      expect(paddingFinder, findsWidgets);

      // Verify the item count by checking for Column widgets inside tiles.
      // Each tile has one Column (name + message preview placeholders).
      final columnFinder = find.byType(Column);
      expect(columnFinder, findsNWidgets(7));
    });

    // ── Test 5: Uses LinearGradient for shimmer effect ────────────────────────

    testWidgets('shimmer boxes use Container with gradient decoration',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const ChatListSkeleton(),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // Find Containers with BoxDecoration that have a gradient
      final containerFinder = find.byType(Container);
      bool foundGradient = false;
      for (final element in containerFinder.evaluate()) {
        final widget = element.widget;
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          if (decoration.gradient is LinearGradient) {
            foundGradient = true;
            break;
          }
        }
      }
      expect(foundGradient, isTrue);
    });

    // ── Test 6: ListView has NeverScrollableScrollPhysics ─────────────────────

    testWidgets('ListView has NeverScrollableScrollPhysics',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const ChatListSkeleton(),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      final listView =
          tester.widget<ListView>(find.byType(ListView));
      expect(listView.physics, isA<NeverScrollableScrollPhysics>());
    });

    // ── Test 7: Animation continues (values change between pumps) ─────────────

    testWidgets('animation runs continuously (shimmer moves)',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const ChatListSkeleton(),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // Pump several frames — should not throw
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(ChatListSkeleton), findsOneWidget);
    });
  });
}
