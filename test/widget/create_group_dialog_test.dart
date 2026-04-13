// Widget tests for CreateGroupDialog (lib/screens/create_group_dialog.dart).
//
// CreateGroupDialog depends on:
// - IContactRepository (via context.read<IContactRepository>() in didChangeDependencies)
// - ChatController (via context.read<ChatController>() in _submit)
// - Function(Contact) onCreate callback
//
// IContactRepository can be provided with a fake implementation.
// Tests that trigger _submit are skipped because they require ChatController
// (which needs SQLite, secure storage, etc.).

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/models/contact.dart';
import 'package:pulse_messenger/models/contact_repository.dart';
import 'package:pulse_messenger/screens/create_group_dialog.dart';
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

Widget buildTestableWidget({
  required Widget child,
  IContactRepository? repository,
}) {
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
      home: Scaffold(body: Builder(builder: (context) {
        // Render a button that shows the dialog so we can test it
        return ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => MultiProvider(
                providers: [
                  Provider<IContactRepository>.value(
                      value: repository ?? _FakeContactRepository()),
                ],
                child: child,
              ),
            );
          },
          child: const Text('Show Dialog'),
        );
      })),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CreateGroupDialog', () {
    testWidgets('Step 1: shows "New Group" title and group name field',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        child: CreateGroupDialog(onCreate: (_) {}),
        repository: _FakeContactRepository(),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('New Group'), findsOneWidget);
      expect(find.text('Group name'), findsOneWidget);
      // Step 1 has Next button, not Create
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('Step 1: Next button disabled when name is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        child: CreateGroupDialog(onCreate: (_) {}),
        repository: _FakeContactRepository(),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Find the FilledButton and check it's disabled
      final button = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Next'));
      expect(button.onPressed, isNull);
    });

    testWidgets('Navigates to Step 2 after entering name and tapping Next',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        child: CreateGroupDialog(onCreate: (_) {}),
        repository: _FakeContactRepository([]),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Enter group name
      await tester.enterText(find.byType(TextField), 'Test Group');
      await tester.pumpAndSettle();

      // Tap Next
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Step 2 should show member selection and Create button
      expect(find.text('Select members (min 2)'), findsOneWidget);
      expect(find.textContaining('Create'), findsOneWidget);
    });

    testWidgets('Step 2: shows "No contacts yet" when repository is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        child: CreateGroupDialog(onCreate: (_) {}),
        repository: _FakeContactRepository([]),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Go to step 2
      await tester.enterText(find.byType(TextField), 'Test Group');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('No contacts yet. Add contacts first.'), findsOneWidget);
    });

    testWidgets('Step 2: back button returns to Step 1',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        child: CreateGroupDialog(onCreate: (_) {}),
        repository: _FakeContactRepository(),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Go to step 2
      await tester.enterText(find.byType(TextField), 'Test Group');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Tap back
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      // Should be back on step 1
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('New Group'), findsOneWidget);
    });
  });
}
