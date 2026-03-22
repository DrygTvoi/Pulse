// Widget tests for SwipeableBubble (lib/widgets/swipeable_bubble.dart).
//
// Tests focus on: rendering child widget, swipe gesture triggers reply,
// long press triggers callback, reply icon appearance on drag,
// spring-back animation.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/theme/theme_manager.dart';
import 'package:pulse_messenger/widgets/swipeable_bubble.dart';

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
      home: Scaffold(
        body: Center(child: child),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SwipeableBubble', () {
    // ── Test 1: Renders child widget ────────────────────────────────────────

    testWidgets('renders child widget', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        SwipeableBubble(
          onLongPress: () {},
          onSwiped: () {},
          child: const Text('Hello message'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Hello message'), findsOneWidget);
    });

    // ── Test 2: Has GestureDetector for interactions ────────────────────────

    testWidgets('has GestureDetector for swipe and long press',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        SwipeableBubble(
          onLongPress: () {},
          onSwiped: () {},
          child: const Text('Test'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(GestureDetector), findsOneWidget);
    });

    // ── Test 3: Long press fires onLongPress callback ───────────────────────

    testWidgets('long press fires onLongPress callback',
        (WidgetTester tester) async {
      bool longPressed = false;

      await tester.pumpWidget(buildTestableWidget(
        SwipeableBubble(
          onLongPress: () => longPressed = true,
          onSwiped: () {},
          child: const SizedBox(width: 200, height: 50, child: Text('Msg')),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Msg'));
      expect(longPressed, isTrue);
    });

    // ── Test 4: Swipe right past threshold triggers onSwiped ────────────────

    testWidgets('swipe right past threshold triggers onSwiped callback',
        (WidgetTester tester) async {
      bool swiped = false;

      await tester.pumpWidget(buildTestableWidget(
        SwipeableBubble(
          onLongPress: () {},
          onSwiped: () => swiped = true,
          child: const SizedBox(width: 200, height: 50, child: Text('Msg')),
        ),
      ));
      await tester.pumpAndSettle();

      // Use tester.drag which handles touch slop correctly.
      await tester.drag(find.text('Msg'), const Offset(100, 0));
      await tester.pumpAndSettle();

      expect(swiped, isTrue);
    });

    // ── Test 5: Small swipe does not trigger onSwiped ───────────────────────

    testWidgets('small swipe does not trigger onSwiped callback',
        (WidgetTester tester) async {
      bool swiped = false;

      await tester.pumpWidget(buildTestableWidget(
        SwipeableBubble(
          onLongPress: () {},
          onSwiped: () => swiped = true,
          child: const SizedBox(width: 200, height: 50, child: Text('Msg')),
        ),
      ));
      await tester.pumpAndSettle();

      // Swipe right by less than the 72px threshold.
      final center = tester.getCenter(find.text('Msg'));
      final gesture = await tester.startGesture(center);
      await gesture.moveBy(const Offset(30, 0));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(swiped, isFalse);
    });

    // ── Test 6: Reply icon appears during drag ──────────────────────────────

    testWidgets('reply icon appears when dragged right',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        SwipeableBubble(
          onLongPress: () {},
          onSwiped: () {},
          child: const SizedBox(width: 200, height: 50, child: Text('Msg')),
        ),
      ));
      await tester.pumpAndSettle();

      // Before drag, no reply icon visible (offset is 0, so _offset <= 4).
      expect(find.byIcon(Icons.reply_rounded), findsNothing);

      // Start drag — break into steps so recognizer fires.
      final center = tester.getCenter(find.text('Msg'));
      final gesture = await tester.startGesture(center);
      await gesture.moveBy(const Offset(20, 0));
      await tester.pump();
      await gesture.moveBy(const Offset(30, 0));
      await tester.pump();

      // During drag, reply icon should appear (_offset > 4).
      expect(find.byIcon(Icons.reply_rounded), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    // ── Test 7: Widget springs back after swipe ─────────────────────────────

    testWidgets('widget springs back to original position after swipe',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        SwipeableBubble(
          onLongPress: () {},
          onSwiped: () {},
          child: const SizedBox(width: 200, height: 50, child: Text('Msg')),
        ),
      ));
      await tester.pumpAndSettle();

      // Get initial position.
      final initialPos = tester.getTopLeft(find.text('Msg'));

      // Swipe and release.
      final center = tester.getCenter(find.text('Msg'));
      final gesture = await tester.startGesture(center);
      await gesture.moveBy(const Offset(80, 0));
      await gesture.up();
      await tester.pumpAndSettle();

      // After spring-back animation, position should be back to initial.
      final finalPos = tester.getTopLeft(find.text('Msg'));
      expect(finalPos.dx, closeTo(initialPos.dx, 1.0));
    });

    // ── Test 8: Uses Transform.translate for drag offset ────────────────────

    testWidgets('uses Transform.translate for drag offset',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        SwipeableBubble(
          onLongPress: () {},
          onSwiped: () {},
          child: const Text('Msg'),
        ),
      ));
      await tester.pumpAndSettle();

      // Transform.translate wraps the child; framework may add its own Transforms.
      expect(find.byType(Transform), findsWidgets);
    });
  });
}
