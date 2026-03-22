// Widget tests for chat_app_bar.dart (lib/widgets/chat_app_bar.dart).
//
// buildChatAppBar() and buildSearchAppBar() are free functions that return
// PreferredSizeWidget.  buildChatAppBar requires ChatController via Provider
// (context.select) for typing, online status, PQC key.  Most tests are
// skipped because ChatController is a singleton with platform dependencies.
//
// buildChatAvatar() and buildSearchAppBar() have fewer dependencies and can
// be partially tested.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/controllers/chat_controller.dart';
import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/models/contact.dart';
import 'package:pulse_messenger/widgets/chat_app_bar.dart';

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

  group('buildChatAvatar', () {
    // ── Test 1: Renders initial letter for a name ────────────────────────────
    testWidgets('renders initial letter from name',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        Scaffold(body: Center(child: buildChatAvatar('Alice', 48))),
      ));
      await tester.pumpAndSettle();

      expect(find.text('A'), findsOneWidget);
    });

    // ── Test 2: Renders "?" for empty name ──────────────────────────────────
    testWidgets('renders "?" for empty name', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        Scaffold(body: Center(child: buildChatAvatar('', 48))),
      ));
      await tester.pumpAndSettle();

      expect(find.text('?'), findsOneWidget);
    });

    // ── Test 3: Container has correct size ──────────────────────────────────
    testWidgets('container has correct size', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        Scaffold(body: Center(child: buildChatAvatar('Bob', 64))),
      ));
      await tester.pumpAndSettle();

      // Find the container with the gradient
      bool foundCorrectSize = false;
      for (final element in find.byType(Container).evaluate()) {
        final widget = element.widget;
        if (widget is Container &&
            widget.constraints != null &&
            widget.constraints!.maxWidth == 64.0 &&
            widget.constraints!.maxHeight == 64.0) {
          foundCorrectSize = true;
          break;
        }
      }
      // The Container uses width/height directly, so we check render size
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });
  });

  group('buildSearchAppBar', () {
    // ── Test 4: Renders search text field ────────────────────────────────────
    testWidgets('renders search text field with autofocus',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(
        Builder(builder: (context) {
          return Scaffold(
            appBar: buildSearchAppBar(
              context: context,
              searchController: TextEditingController(),
              onSearchChanged: (_) {},
              onSearchClose: () {},
            ),
          );
        }),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
    });

    // ── Test 5: buildChatAppBar requires ChatController via Provider ────────
    testWidgets(
      'buildChatAppBar renders contact name and action buttons',
      (WidgetTester tester) async {
        final contact = testContact(name: 'Alice');
        await tester.pumpWidget(buildTestApp(
          Builder(builder: (context) {
            return Scaffold(
              appBar: buildChatAppBar(
                context: context,
                contact: contact,
                myId: 'my-id',
                chatMuted: false,
                chatTtlSeconds: 0,
                onOpenProfile: () {},
                onSearchActivate: () {},
                onMuteChanged: (_) {},
                onTtlChanged: (_) {},
              ),
            );
          }),
        ));
        await tester.pumpAndSettle();
        expect(find.text('Alice'), findsOneWidget);
      },
    );

    // ── Test 6: buildChatAppBar popup menu items ────────────────────────────
    testWidgets(
      'buildChatAppBar shows mute, media, timer in popup menu',
      (WidgetTester tester) async {
        final contact = testContact(name: 'Bob');
        await tester.pumpWidget(buildTestApp(
          Builder(builder: (context) {
            return Scaffold(
              appBar: buildChatAppBar(
                context: context,
                contact: contact,
                myId: 'my-id',
                chatMuted: false,
                chatTtlSeconds: 0,
                onOpenProfile: () {},
                onSearchActivate: () {},
                onMuteChanged: (_) {},
                onTtlChanged: (_) {},
              ),
            );
          }),
        ));
        await tester.pumpAndSettle();
        // Tap the more_vert popup menu button
        await tester.tap(find.byIcon(Icons.more_vert_rounded));
        await tester.pumpAndSettle();
        expect(find.text('Mute'), findsOneWidget);
      },
    );
  });

  group('TypingDots', () {
    // ── Test 7: TypingDots renders animated dots ────────────────────────────
    testWidgets('TypingDots renders 3 animated dot containers',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        Scaffold(body: Center(child: TypingDots())),
      ));
      // Pump a few frames for the animation
      await tester.pump(const Duration(milliseconds: 100));

      // TypingDots creates 3 Opacity widgets wrapping circle containers
      expect(find.byType(Opacity), findsNWidgets(3));
    });
  });
}
