// Widget tests for ContactsScreen (lib/screens/contacts_screen.dart).
//
// ContactsScreen depends on:
// - IContactRepository (via context.read<IContactRepository>()) — injectable
// - ChatController (indirectly, via ChatScreen navigation and CreateGroupDialog)
//
// IContactRepository can be provided with a simple in-memory implementation,
// allowing basic rendering tests to pass. Tests that trigger navigation to
// ChatScreen or CreateGroupDialog (which need ChatController) are skipped.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/models/contact.dart';
import 'package:pulse_messenger/models/contact_repository.dart';
import 'package:pulse_messenger/screens/contacts_screen.dart';
import 'package:pulse_messenger/theme/theme_manager.dart';

/// Minimal in-memory implementation of IContactRepository for tests.
class _FakeContactRepository implements IContactRepository {
  final List<Contact> _contacts;
  _FakeContactRepository([List<Contact>? contacts])
      : _contacts = contacts ?? [];

  @override
  List<Contact> get contacts => _contacts;

  @override
  Future<void> loadContacts() async {}

  @override
  Future<void> addContact(Contact contact) async {
    _contacts.add(contact);
  }

  @override
  Future<void> removeContact(String id) async {
    _contacts.removeWhere((c) => c.id == id);
  }

  @override
  Future<void> updateContact(Contact updated) async {
    final idx = _contacts.indexWhere((c) => c.id == updated.id);
    if (idx != -1) _contacts[idx] = updated;
  }

  @override
  Contact? findById(String id) =>
      _contacts.cast<Contact?>().firstWhere((c) => c?.id == id, orElse: () => null);

  @override
  Contact? findByAddress(String address) =>
      _contacts.cast<Contact?>().firstWhere((c) => c?.databaseId == address, orElse: () => null);
}

Widget buildTestableWidget(Widget child, {IContactRepository? repository}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ThemeNotifier>.value(value: ThemeNotifier.instance),
      Provider<IContactRepository>.value(
          value: repository ?? _FakeContactRepository()),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ContactsScreen', () {
    testWidgets('has a Scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const ContactsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('has an AppBar with "New chat" title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const ContactsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('New chat'), findsOneWidget);
    });

    testWidgets('has a search field with "Search..." hint',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const ContactsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search...'), findsOneWidget);
    });

    testWidgets('shows "New group" action tile',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const ContactsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('New group'), findsOneWidget);
      expect(find.byIcon(Icons.group_add_rounded), findsOneWidget);
    });

    testWidgets('shows empty state when no contacts',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestableWidget(const ContactsScreen(),
              repository: _FakeContactRepository()));
      await tester.pumpAndSettle();

      expect(find.text('No contacts yet'), findsOneWidget);
    });
  });
}
