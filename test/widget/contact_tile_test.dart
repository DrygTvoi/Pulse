// Widget tests for ContactTile (lib/widgets/contact_tile.dart).
//
// Tests focus on: contact name rendering, provider badge icon, E2EE lock icon,
// subtitle text, trailing text, onTap callback, group indicator.
// ContactTile is a pure rendering widget with no platform deps.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/models/contact.dart';
import 'package:pulse_messenger/theme/theme_manager.dart';
import 'package:pulse_messenger/widgets/contact_tile.dart';

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

Contact _makeContact({
  String id = 'c1',
  String name = 'Alice',
  String provider = 'Nostr',
  bool isGroup = false,
}) {
  return Contact(
    id: id,
    name: name,
    provider: provider,
    databaseId: 'pubkey@wss://relay.example.com',
    publicKey: 'pk123',
    isGroup: isGroup,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ContactTile', () {
    // ── Test 1: Renders contact name ──────────────────────────────────────────

    testWidgets('renders contact name', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        ContactTile(
          contact: _makeContact(name: 'Bob'),
          onTap: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Bob'), findsOneWidget);
    });

    // ── Test 2: Shows provider badge text for Nostr ──────────────────────────

    testWidgets('shows provider badge text for Nostr provider',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        ContactTile(
          contact: _makeContact(provider: 'Nostr'),
          onTap: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Nostr'), findsOneWidget);
    });

    // ── Test 3: Shows provider badge icon for Firebase ───────────────────────

    testWidgets('shows fire icon for Firebase provider',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        ContactTile(
          contact: _makeContact(provider: 'Firebase'),
          onTap: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
      expect(find.text('Firebase'), findsOneWidget);
    });

    // ── Test 4: Shows bolt icon for Nostr provider ──────────────────────────

    testWidgets('shows bolt icon for Nostr provider',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        ContactTile(
          contact: _makeContact(provider: 'Nostr'),
          onTap: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);
    });

    // ── Test 5: Shows E2EE lock icon when isE2eeActive is true ──────────────

    testWidgets('shows E2EE lock icon when isE2eeActive is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        ContactTile(
          contact: _makeContact(),
          onTap: () {},
          isE2eeActive: true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
      expect(find.text('E2EE'), findsOneWidget);
    });

    // ── Test 6: No E2EE lock icon when isE2eeActive is false ────────────────

    testWidgets('does not show E2EE lock icon when isE2eeActive is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        ContactTile(
          contact: _makeContact(),
          onTap: () {},
          isE2eeActive: false,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lock_rounded), findsNothing);
      expect(find.text('E2EE'), findsNothing);
    });

    // ── Test 7: onTap callback fires when tapped ────────────────────────────

    testWidgets('onTap callback fires when tapped',
        (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(buildTestableWidget(
        ContactTile(
          contact: _makeContact(),
          onTap: () => tapped = true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    // ── Test 8: Shows default subtitle "Tap to chat" ────────────────────────

    testWidgets('shows default subtitle "Tap to chat" when no override',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        ContactTile(
          contact: _makeContact(),
          onTap: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Tap to chat'), findsOneWidget);
    });

    // ── Test 9: Shows subtitleOverride instead of default ────────────────────

    testWidgets('shows subtitleOverride when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        ContactTile(
          contact: _makeContact(),
          onTap: () {},
          subtitleOverride: 'Last seen recently',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Last seen recently'), findsOneWidget);
      expect(find.text('Tap to chat'), findsNothing);
    });

    // ── Test 10: Shows group indicator icon for group contacts ───────────────

    testWidgets('shows group indicator icon for group contacts',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        ContactTile(
          contact: _makeContact(isGroup: true, provider: 'group'),
          onTap: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // The group badge shows group_rounded icon, and the avatar Stack
      // also has a group_rounded icon at the bottom-right.
      expect(find.byIcon(Icons.group_rounded), findsWidgets);
    });

    // ── Test 11: Shows trailing text when provided ──────────────────────────

    testWidgets('shows trailing text when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        ContactTile(
          contact: _makeContact(),
          onTap: () {},
          trailing: '12:30',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('12:30'), findsOneWidget);
    });

    // ── Test 12: Falls back to cloud icon for unknown provider ──────────────

    testWidgets('shows cloud icon for unknown provider',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        ContactTile(
          contact: _makeContact(provider: 'UnknownProvider'),
          onTap: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.cloud_rounded), findsOneWidget);
    });
  });
}
