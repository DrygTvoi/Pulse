// Widget tests for StatusRow (lib/widgets/status_row.dart).
//
// Tests focus on: own status avatar rendering, contact status avatars,
// handling empty lists, onTap callbacks, SizedBox.shrink when no statuses.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/models/contact.dart';
import 'package:pulse_messenger/models/user_status.dart';
import 'package:pulse_messenger/theme/theme_manager.dart';
import 'package:pulse_messenger/widgets/status_row.dart';

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
  bool isGroup = false,
}) {
  return Contact(
    id: id,
    name: name,
    provider: 'Nostr',
    databaseId: 'pubkey@wss://relay.example.com',
    publicKey: 'pk123',
    isGroup: isGroup,
  );
}

UserStatus _makeStatus({String id = 's1', String text = 'Hello world'}) {
  final now = DateTime.now();
  return UserStatus(
    id: id,
    text: text,
    createdAt: now,
    expiresAt: now.add(const Duration(hours: 24)),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('StatusRow', () {
    // ── Test 1: Renders SizedBox.shrink when no statuses exist ───────────────

    testWidgets('renders SizedBox.shrink when no statuses exist',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        StatusRow(
          contacts: [],
          ownStatus: null,
          contactStatuses: const {},
          onOwnStatusTap: () {},
          onContactStatusTap: (_, __) {},
        ),
      ));
      await tester.pumpAndSettle();

      // When there are no statuses, the widget returns SizedBox.shrink().
      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    // ── Test 2: Renders own status avatar with "My Status" label ────────────

    testWidgets('renders own status avatar when ownStatus is set',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        StatusRow(
          contacts: [],
          ownStatus: _makeStatus(),
          contactStatuses: const {},
          onOwnStatusTap: () {},
          onContactStatusTap: (_, __) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('My Status'), findsOneWidget);
    });

    // ── Test 3: Renders contact status avatars ──────────────────────────────

    testWidgets('renders contact status avatars for contacts with statuses',
        (WidgetTester tester) async {
      final alice = _makeContact(id: 'c1', name: 'Alice');
      final bob = _makeContact(id: 'c2', name: 'Bob');

      await tester.pumpWidget(buildTestableWidget(
        StatusRow(
          contacts: [alice, bob],
          ownStatus: _makeStatus(),
          contactStatuses: {
            'c1': _makeStatus(id: 's1', text: 'Alice status'),
            'c2': _makeStatus(id: 's2', text: 'Bob status'),
          },
          onOwnStatusTap: () {},
          onContactStatusTap: (_, __) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('My Status'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    // ── Test 4: Does not render contacts without statuses ────────────────────

    testWidgets('does not render contacts that have no status',
        (WidgetTester tester) async {
      final alice = _makeContact(id: 'c1', name: 'Alice');
      final bob = _makeContact(id: 'c2', name: 'Bob');

      await tester.pumpWidget(buildTestableWidget(
        StatusRow(
          contacts: [alice, bob],
          ownStatus: _makeStatus(),
          contactStatuses: {
            'c1': _makeStatus(id: 's1'),
            // Bob has no status in the map
          },
          onOwnStatusTap: () {},
          onContactStatusTap: (_, __) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsNothing);
    });

    // ── Test 5: onOwnStatusTap callback fires ───────────────────────────────

    testWidgets('onOwnStatusTap fires when own status avatar is tapped',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(buildTestableWidget(
        StatusRow(
          contacts: [],
          ownStatus: _makeStatus(),
          contactStatuses: const {},
          onOwnStatusTap: () => tapped = true,
          onContactStatusTap: (_, __) {},
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('My Status'));
      expect(tapped, isTrue);
    });

    // ── Test 6: onContactStatusTap fires with correct contact ───────────────

    testWidgets('onContactStatusTap fires with correct contact',
        (WidgetTester tester) async {
      Contact? tappedContact;
      final alice = _makeContact(id: 'c1', name: 'Alice');

      await tester.pumpWidget(buildTestableWidget(
        StatusRow(
          contacts: [alice],
          ownStatus: _makeStatus(),
          contactStatuses: {
            'c1': _makeStatus(id: 's1'),
          },
          onOwnStatusTap: () {},
          onContactStatusTap: (contact, _) => tappedContact = contact,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Alice'));
      expect(tappedContact, isNotNull);
      expect(tappedContact!.id, 'c1');
    });

    // ── Test 7: Excludes group contacts from status row ─────────────────────

    testWidgets('excludes group contacts from status row',
        (WidgetTester tester) async {
      final groupContact =
          _makeContact(id: 'g1', name: 'My Group', isGroup: true);

      await tester.pumpWidget(buildTestableWidget(
        StatusRow(
          contacts: [groupContact],
          ownStatus: _makeStatus(),
          contactStatuses: {
            'g1': _makeStatus(id: 's1'),
          },
          onOwnStatusTap: () {},
          onContactStatusTap: (_, __) {},
        ),
      ));
      await tester.pumpAndSettle();

      // Group contacts are filtered out by nonGroupContacts filter.
      expect(find.text('My Group'), findsNothing);
      // Only "My Status" should appear.
      expect(find.text('My Status'), findsOneWidget);
    });

    // ── Test 8: Has a horizontal ListView ────────────────────────────────────

    testWidgets('uses a horizontal ListView for scrolling',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        StatusRow(
          contacts: [],
          ownStatus: _makeStatus(),
          contactStatuses: const {},
          onOwnStatusTap: () {},
          onContactStatusTap: (_, __) {},
        ),
      ));
      await tester.pumpAndSettle();

      final listViewFinder = find.byType(ListView);
      expect(listViewFinder, findsOneWidget);

      final listView = tester.widget<ListView>(listViewFinder);
      expect(listView.scrollDirection, Axis.horizontal);
    });
  });
}
