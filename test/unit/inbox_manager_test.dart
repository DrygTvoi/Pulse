import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/adapters/inbox_manager.dart';
import 'package:pulse_messenger/models/message.dart';

// ── Mock implementations ─────────────────────────────────────────────────────

class MockMessageSender implements MessageSender {
  bool initialized = false;
  final List<(String, String, Message)> sentMessages = [];
  final List<(String, String, String, String, Map<String, dynamic>)>
      sentSignals = [];
  bool shouldFail = false;

  @override
  Future<void> initializeSender(String apiKey) async {
    initialized = true;
  }

  @override
  Future<bool> sendMessage(
      String targetDatabaseId, String roomId, Message message) async {
    if (shouldFail) return false;
    sentMessages.add((targetDatabaseId, roomId, message));
    return true;
  }

  @override
  Future<bool> sendSignal(String targetDatabaseId, String roomId,
      String senderId, String type, Map<String, dynamic> payload) async {
    if (shouldFail) return false;
    sentSignals.add((targetDatabaseId, roomId, senderId, type, payload));
    return true;
  }
}

class MockInboxReader implements InboxReader {
  bool initialized = false;
  String? apiKey;
  String? databaseId;

  @override
  Future<void> initializeReader(String apiKey, String databaseId) async {
    this.apiKey = apiKey;
    this.databaseId = databaseId;
    initialized = true;
  }

  @override
  Stream<List<Message>> listenForMessages() => Stream.empty();

  @override
  Stream<List<Map<String, dynamic>>> listenForSignals() =>
      Stream.empty();

  @override
  Stream<bool> get healthChanges => Stream<bool>.empty();

  @override
  Future<String?> provisionGroup(String groupName) async => null;

  @override
  Future<Map<String, dynamic>?> fetchPublicKeys() async => null;
}

Message _makeMessage({String id = 'msg1'}) => Message(
      id: id,
      senderId: 'sender',
      receiverId: 'receiver',
      encryptedPayload: 'encrypted_data',
      timestamp: DateTime(2026, 3, 21),
      adapterType: 'nostr',
    );

void main() {
  late InboxManager manager;

  setUp(() {
    manager = InboxManager.forTesting();
  });

  // ── routeMessage ───────────────────────────────────────────────────────────

  group('routeMessage', () {
    test('returns false when no sender is registered for provider', () async {
      final result = await manager.routeMessage(
        'Firebase', 'target_db', 'room1', _makeMessage(),
      );
      expect(result, isFalse);
    });

    test('returns false for unknown provider string', () async {
      final result = await manager.routeMessage(
        'UnknownProvider', 'target_db', 'room1', _makeMessage(),
      );
      expect(result, isFalse);
    });

    test('routes message to correct sender when registered', () async {
      final sender = MockMessageSender();
      await manager.addSenderPlugin('Nostr', sender, 'api_key');

      final msg = _makeMessage();
      final result = await manager.routeMessage(
        'Nostr', 'target_db', 'room1', msg,
      );
      expect(result, isTrue);
      expect(sender.sentMessages, hasLength(1));
      expect(sender.sentMessages.first.$1, equals('target_db'));
      expect(sender.sentMessages.first.$2, equals('room1'));
      expect(sender.sentMessages.first.$3.id, equals('msg1'));
    });

    test('returns false when sender.sendMessage fails', () async {
      final sender = MockMessageSender()..shouldFail = true;
      await manager.addSenderPlugin('Nostr', sender, 'api_key');

      final result = await manager.routeMessage(
        'Nostr', 'target_db', 'room1', _makeMessage(),
      );
      expect(result, isFalse);
    });

    test('routes to the correct sender among multiple registered', () async {
      final nostrSender = MockMessageSender();
      final fireSender = MockMessageSender();
      await manager.addSenderPlugin('Nostr', nostrSender, 'key1');
      await manager.addSenderPlugin('Firebase', fireSender, 'key2');

      await manager.routeMessage(
        'Firebase', 'target_db', 'room1', _makeMessage(),
      );
      expect(nostrSender.sentMessages, isEmpty);
      expect(fireSender.sentMessages, hasLength(1));
    });
  });

  // ── sendSystemMessage ──────────────────────────────────────────────────────

  group('sendSystemMessage', () {
    test('returns false when no sender registered', () async {
      final result = await manager.sendSystemMessage(
        'Nostr', 'target_db', 'room1', 'me', 'webrtc_offer', {'sdp': '...'},
      );
      expect(result, isFalse);
    });

    test('sends signal via registered sender', () async {
      final sender = MockMessageSender();
      await manager.addSenderPlugin('Nostr', sender, 'api_key');

      final payload = {'sdp': 'offer_data'};
      final result = await manager.sendSystemMessage(
        'Nostr', 'target_db', 'room1', 'sender_id', 'webrtc_offer', payload,
      );
      expect(result, isTrue);
      expect(sender.sentSignals, hasLength(1));
      expect(sender.sentSignals.first.$4, equals('webrtc_offer'));
      expect(sender.sentSignals.first.$5, equals(payload));
    });

    test('returns false when sender.sendSignal fails', () async {
      final sender = MockMessageSender()..shouldFail = true;
      await manager.addSenderPlugin('Nostr', sender, 'api_key');

      final result = await manager.sendSystemMessage(
        'Nostr', 'target_db', 'room1', 'me', 'type', {},
      );
      expect(result, isFalse);
    });
  });

  // ── addSenderPlugin ────────────────────────────────────────────────────────

  group('addSenderPlugin', () {
    test('initializes sender with the provided API key', () async {
      final sender = MockMessageSender();
      await manager.addSenderPlugin('Nostr', sender, 'my_secret_key');
      expect(sender.initialized, isTrue);
    });

    test('overwrites previous sender for same provider', () async {
      final sender1 = MockMessageSender();
      final sender2 = MockMessageSender();
      await manager.addSenderPlugin('Nostr', sender1, 'key1');
      await manager.addSenderPlugin('Nostr', sender2, 'key2');

      await manager.routeMessage(
        'Nostr', 'target', 'room', _makeMessage(),
      );
      // Only sender2 should have received the message
      expect(sender1.sentMessages, isEmpty);
      expect(sender2.sentMessages, hasLength(1));
    });
  });

  // ── senders map (read-only access) ─────────────────────────────────────────

  group('senders', () {
    test('senders map is initially empty', () {
      expect(manager.senders, isEmpty);
    });

    test('senders map reflects registered senders', () async {
      final sender = MockMessageSender();
      await manager.addSenderPlugin('Firebase', sender, 'key');
      expect(manager.senders, hasLength(1));
      expect(manager.senders.containsKey('Firebase'), isTrue);
    });

    test('senders map is unmodifiable', () {
      expect(
        () => manager.senders['test'] = MockMessageSender(),
        throwsUnsupportedError,
      );
    });
  });

  // ── reader ─────────────────────────────────────────────────────────────────

  group('reader', () {
    test('reader is initially null', () {
      expect(manager.reader, isNull);
    });
  });

  // ── setInstanceForTesting ──────────────────────────────────────────────────

  group('setInstanceForTesting', () {
    test('replaces the factory singleton', () async {
      final custom = InboxManager.forTesting();
      final sender = MockMessageSender();
      await custom.addSenderPlugin('Nostr', sender, 'key');

      InboxManager.setInstanceForTesting(custom);
      // The factory constructor should return our custom instance
      final result = await InboxManager().routeMessage(
        'Nostr', 'target', 'room', _makeMessage(),
      );
      expect(result, isTrue);
      expect(sender.sentMessages, hasLength(1));

      // Restore a clean instance
      InboxManager.setInstanceForTesting(InboxManager.forTesting());
    });
  });
}
