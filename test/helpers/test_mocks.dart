/// Lightweight test doubles for widget tests.
///
/// Provides mock infrastructure to un-skip widget tests that were blocked by
/// platform channel dependencies (FlutterSecureStorage, SQLite) and singleton
/// services (ChatController, SignalService).
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:pulse_messenger/controllers/chat_controller.dart';
import 'package:pulse_messenger/l10n/app_localizations.dart';
import 'package:pulse_messenger/models/contact.dart';
import 'package:pulse_messenger/models/contact_repository.dart';
import 'package:pulse_messenger/models/message.dart';
import 'package:pulse_messenger/services/connectivity_probe_service.dart';
import 'package:pulse_messenger/services/local_storage_service.dart';
import 'package:pulse_messenger/services/notification_service.dart';
import 'package:pulse_messenger/services/tor_service.dart';
import 'package:pulse_messenger/services/utls_service.dart';
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

// ─── FakeLocalStorageService ────────────────────────────────────────────────

/// Minimal [LocalStorageService] substitute for widget tests.
/// All methods are no-ops or return empty data.
class FakeLocalStorageService extends LocalStorageService {
  FakeLocalStorageService() : super.forTesting();

  @override
  Future<void> init() async {}

  @override
  Future<String?> loadDraft(String contactId) async => null;

  @override
  Future<void> saveDraft(String contactId, String text) async {}

  @override
  Future<void> deleteDraft(String contactId) async {}

  @override
  Future<List<Map<String, dynamic>>> getMessages(String recipientId,
      {int limit = 50, int offset = 0}) async => [];

  @override
  Future<void> saveMessage(String roomId, Map<String, dynamic> msg) async {}

  @override
  Future<void> saveMessagesBatch(
      String roomId, List<Map<String, dynamic>> messages) async {}

  @override
  Future<int> countMessages(String roomId) async => 0;

  @override
  Future<List<Map<String, dynamic>>> loadMessagesPage(
    String roomId, {
    int pageSize = 50,
    int? beforeTimestamp,
  }) async => [];

  @override
  Future<void> deleteMessage(String roomId, String messageId) async {}

  @override
  Future<List<Map<String, dynamic>>> loadMessages(String roomId) async => [];

  @override
  bool get isSqlcipherAvailable => true;

  @override
  Future<String?> loadAvatar(String contactId) async => null;

  @override
  Future<List<({String roomId, Map<String, dynamic> message})>> searchMessages(
    String query, {String? roomId, int limit = 50, void Function(int scanned, int total)? onProgress}) async => [];
}

// ─── Singleton mock setup ───────────────────────────────────────────────────

/// Installs lightweight singleton mocks for services that widget tests
/// depend on. Call in setUp() before pumping widgets.
///
/// Mocks: ConnectivityProbeService, TorService, UTLSService,
/// NotificationService.
void setUpServiceMocks() {
  // ConnectivityProbeService — just needs a working status stream
  ConnectivityProbeService.setInstanceForTesting(
      _FakeConnectivityProbeService());

  // TorService — just needs a working stateChanges stream
  TorService.setInstanceForTesting(_FakeTorService());

  // UTLSService — just needs available ValueNotifier
  UTLSService.setInstanceForTesting(_FakeUTLSService());

  // NotificationService — isChatMuted returns false
  NotificationService.setInstanceForTesting(_FakeNotificationService());

  // LocalStorageService — no-op draft/message methods
  LocalStorageService.setInstanceForTesting(FakeLocalStorageService());
}

class _FakeConnectivityProbeService extends ConnectivityProbeService {
  final _statusCtrl = StreamController<ProbeStatus>.broadcast();

  _FakeConnectivityProbeService() : super.forTesting();

  @override
  Stream<ProbeStatus> get status => _statusCtrl.stream;

  @override
  ProbeResult get lastResult => ProbeResult.empty();
}

class _FakeTorService extends TorService {
  final _stateCtrl = StreamController<void>.broadcast();

  _FakeTorService() : super.forTesting();

  @override
  Stream<void> get stateChanges => _stateCtrl.stream;

  @override
  bool get isRunning => false;

  @override
  bool get isBootstrapped => false;

  @override
  int get bootstrapPercent => 0;

  @override
  String get activePtLabel => '';
}

class _FakeUTLSService extends UTLSService {
  _FakeUTLSService() : super.forTesting();

  @override
  final ValueNotifier<bool> available = ValueNotifier<bool>(false);

  @override
  bool get isRunning => false;
}

class _FakeNotificationService extends NotificationService {
  _FakeNotificationService() : super.forTesting();

  @override
  Future<bool> isChatMuted(String contactId) async => false;

  @override
  Future<void> setChatMuted(String contactId, bool muted) async {}
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

// ─── Test Message factory ───────────────────────────────────────────────────

/// Creates a [Message] with sensible defaults for tests.
Message testMessage({
  String id = 'msg-1',
  String senderId = 'me',
  String receiverId = 'test-contact-id',
  String encryptedPayload = 'Hello, world!',
  DateTime? timestamp,
  String adapterType = 'nostr',
  bool isRead = false,
  String status = '',
}) =>
    Message(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      encryptedPayload: encryptedPayload,
      timestamp: timestamp ?? DateTime(2026, 1, 1, 12),
      adapterType: adapterType,
      isRead: isRead,
      status: status,
    );
