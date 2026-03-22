/// Lightweight test doubles for widget tests.
///
/// Provides mock infrastructure to un-skip widget tests that were blocked by
/// platform channel dependencies (FlutterSecureStorage, SQLite) and singleton
/// services (ChatController, SignalService).
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:pulse_messenger/controllers/chat_controller.dart';
import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/models/contact.dart';
import 'package:pulse_messenger/models/contact_repository.dart';
import 'package:pulse_messenger/theme/theme_manager.dart';

// ─── FlutterSecureStorage channel mock ──────────────────────────────────────

/// Mocks the FlutterSecureStorage platform channel so that read/write/delete
/// calls succeed without a native plugin. Call in setUp() or setUpAll().
void setUpSecureStorageMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/flutter_secure_storage'),
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'read':
          return null;
        case 'readAll':
          return <String, String>{};
        case 'write':
        case 'delete':
        case 'deleteAll':
          return null;
        case 'containsKey':
          return false;
        default:
          return null;
      }
    },
  );
}

/// Clears the FlutterSecureStorage platform channel mock. Call in tearDown().
void tearDownSecureStorageMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/flutter_secure_storage'),
    null,
  );
}

// ─── FakeContactRepository ──────────────────────────────────────────────────

/// In-memory [IContactRepository] for widget tests.
class FakeContactRepository implements IContactRepository {
  final List<Contact> _contacts;

  FakeContactRepository([List<Contact>? contacts])
      : _contacts = contacts != null ? List.of(contacts) : [];

  @override
  List<Contact> get contacts => List.unmodifiable(_contacts);

  @override
  Future<void> loadContacts() async {}

  @override
  Future<void> addContact(Contact contact) async => _contacts.add(contact);

  @override
  Future<void> removeContact(String id) async =>
      _contacts.removeWhere((c) => c.id == id);

  @override
  Future<void> updateContact(Contact updated) async {
    final idx = _contacts.indexWhere((c) => c.id == updated.id);
    if (idx >= 0) _contacts[idx] = updated;
  }

  @override
  Contact? findById(String id) =>
      _contacts.cast<Contact?>().firstWhere((c) => c?.id == id, orElse: () => null);

  @override
  Contact? findByAddress(String address) =>
      _contacts.cast<Contact?>().firstWhere((c) => c?.databaseId == address, orElse: () => null);
}

// ─── Test ChatController ────────────────────────────────────────────────────

/// Creates a [ChatController] backed by [FakeContactRepository].
/// Installs it as the singleton so that `ChatController()` returns it.
/// Returns the instance for use with [buildTestApp].
///
/// Requires [setUpSecureStorageMock] to have been called first.
ChatController createTestChatController([List<Contact>? contacts]) {
  final repo = FakeContactRepository(contacts);
  final cc = ChatController.forTesting(repo);
  ChatController.setInstanceForTesting(cc);
  return cc;
}

// ─── buildTestApp ───────────────────────────────────────────────────────────

/// Wraps [child] in a fully-configured MaterialApp with localization,
/// ThemeNotifier, ChatController, and IContactRepository providers.
///
/// Pass [chatController] to reuse an existing test instance; otherwise a
/// fresh one is created via [createTestChatController].
Widget buildTestApp(
  Widget child, {
  ChatController? chatController,
  IContactRepository? contactRepository,
  List<Contact>? contacts,
  bool scaffold = false,
}) {
  final cc = chatController ?? createTestChatController(contacts);
  final repo = contactRepository ?? FakeContactRepository(contacts);

  Widget body = scaffold ? Scaffold(body: child) : child;

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ChatController>.value(value: cc),
      Provider<IContactRepository>.value(value: repo),
      ChangeNotifierProvider<ThemeNotifier>.value(
          value: ThemeNotifier.instance),
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
      home: body,
    ),
  );
}

// ─── Test Contact factory ───────────────────────────────────────────────────

/// Creates a [Contact] with sensible defaults for tests.
Contact testContact({
  String id = 'test-contact-id',
  String name = 'Test User',
  String provider = 'Nostr',
  String databaseId = 'abc123@wss://relay.example.com',
  String publicKey = 'pubkey123',
  bool isGroup = false,
  List<String> members = const [],
  String? creatorId,
}) =>
    Contact(
      id: id,
      name: name,
      provider: provider,
      databaseId: databaseId,
      publicKey: publicKey,
      isGroup: isGroup,
      members: members,
      creatorId: creatorId,
    );
