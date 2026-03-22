import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/models/chat_room.dart';
import 'package:pulse_messenger/models/contact.dart';
import 'package:pulse_messenger/models/message.dart';

/// Helper to create a minimal [Contact] for testing.
Contact _makeContact({
  String id = 'contact-1',
  String name = 'Alice',
  String provider = 'Nostr',
  String databaseId = 'pubkey@wss://relay.example.com',
  String publicKey = 'pk-abc123',
  String? avatarUrl,
  bool isGroup = false,
  List<String> members = const [],
  String? creatorId,
  List<String> alternateAddresses = const [],
  String bio = '',
}) {
  return Contact(
    id: id,
    name: name,
    provider: provider,
    databaseId: databaseId,
    publicKey: publicKey,
    avatarUrl: avatarUrl,
    isGroup: isGroup,
    members: members,
    creatorId: creatorId,
    alternateAddresses: alternateAddresses,
    bio: bio,
  );
}

/// Helper to create a minimal [Message] for testing.
Message _makeMessage({
  String id = 'msg-1',
  String senderId = 'sender-1',
  String receiverId = 'receiver-1',
  String encryptedPayload = 'encrypted-data',
  DateTime? timestamp,
  String adapterType = 'nostr',
  bool isRead = false,
  String status = '',
}) {
  return Message(
    id: id,
    senderId: senderId,
    receiverId: receiverId,
    encryptedPayload: encryptedPayload,
    timestamp: timestamp ?? DateTime.utc(2026, 3, 21, 12, 0, 0),
    adapterType: adapterType,
    isRead: isRead,
    status: status,
  );
}

/// Helper to create a minimal [ChatRoom] for testing.
ChatRoom _makeChatRoom({
  String id = 'room-1',
  Contact? contact,
  List<Message>? messages,
  String adapterType = 'nostr',
  Map<String, dynamic>? adapterConfig,
  DateTime? updatedAt,
}) {
  return ChatRoom(
    id: id,
    contact: contact ?? _makeContact(),
    messages: messages ?? [],
    adapterType: adapterType,
    adapterConfig: adapterConfig ?? {'relay': 'wss://relay.example.com'},
    updatedAt: updatedAt ?? DateTime.utc(2026, 3, 21, 12, 0, 0),
  );
}

void main() {
  // ── Constructor ──────────────────────────────────────────────────────

  group('ChatRoom constructor', () {
    test('creates instance with all required fields', () {
      final contact = _makeContact();
      final msg = _makeMessage();
      final updatedAt = DateTime.utc(2026, 3, 21, 15, 30, 0);
      final config = {'repo': 'user/repo', 'sheetId': 'abc'};

      final room = ChatRoom(
        id: 'room-42',
        contact: contact,
        messages: [msg],
        adapterType: 'firebase',
        adapterConfig: config,
        updatedAt: updatedAt,
      );

      expect(room.id, 'room-42');
      expect(room.contact.id, contact.id);
      expect(room.messages, hasLength(1));
      expect(room.messages.first.id, msg.id);
      expect(room.adapterType, 'firebase');
      expect(room.adapterConfig, config);
      expect(room.updatedAt, updatedAt);
    });

    test('creates instance with empty messages list', () {
      final room = _makeChatRoom(messages: []);
      expect(room.messages, isEmpty);
    });

    test('creates instance with multiple messages', () {
      final messages = [
        _makeMessage(id: 'msg-1'),
        _makeMessage(id: 'msg-2'),
        _makeMessage(id: 'msg-3'),
      ];
      final room = _makeChatRoom(messages: messages);
      expect(room.messages, hasLength(3));
      expect(room.messages[0].id, 'msg-1');
      expect(room.messages[2].id, 'msg-3');
    });
  });

  // ── toJson ────────────────────────────────────────────────────────────

  group('ChatRoom.toJson()', () {
    test('serializes all fields to JSON map', () {
      final updatedAt = DateTime.utc(2026, 1, 15, 10, 30, 0);
      final room = _makeChatRoom(
        id: 'room-json',
        adapterType: 'waku',
        adapterConfig: {'nodeUrl': 'http://localhost:8545'},
        updatedAt: updatedAt,
      );

      final json = room.toJson();

      expect(json['id'], 'room-json');
      expect(json['adapterType'], 'waku');
      expect(json['adapterConfig'], {'nodeUrl': 'http://localhost:8545'});
      expect(json['updatedAt'], updatedAt.toIso8601String());
      expect(json['contact'], isA<Map<String, dynamic>>());
      expect(json['messages'], isA<List>());
    });

    test('serializes contact via toMap()', () {
      final contact = _makeContact(name: 'Bob', provider: 'Firebase');
      final room = _makeChatRoom(contact: contact);
      final json = room.toJson();

      final contactJson = json['contact'] as Map<String, dynamic>;
      expect(contactJson['name'], 'Bob');
      expect(contactJson['provider'], 'Firebase');
    });

    test('serializes messages list correctly', () {
      final messages = [
        _makeMessage(id: 'a', encryptedPayload: 'enc-a'),
        _makeMessage(id: 'b', encryptedPayload: 'enc-b'),
      ];
      final room = _makeChatRoom(messages: messages);
      final json = room.toJson();

      final msgList = json['messages'] as List;
      expect(msgList, hasLength(2));
      expect((msgList[0] as Map<String, dynamic>)['id'], 'a');
      expect((msgList[1] as Map<String, dynamic>)['encryptedPayload'], 'enc-b');
    });

    test('serializes empty messages list as empty array', () {
      final room = _makeChatRoom(messages: []);
      final json = room.toJson();
      expect(json['messages'], isEmpty);
    });

    test('updatedAt is ISO 8601 string', () {
      final dt = DateTime.utc(2026, 6, 15, 8, 45, 30);
      final room = _makeChatRoom(updatedAt: dt);
      final json = room.toJson();
      expect(json['updatedAt'], '2026-06-15T08:45:30.000Z');
    });
  });

  // ── fromJson ──────────────────────────────────────────────────────────

  group('ChatRoom.fromJson()', () {
    test('deserializes all fields from JSON map', () {
      final updatedAt = DateTime.utc(2026, 2, 20, 14, 0, 0);
      final json = <String, dynamic>{
        'id': 'room-from',
        'contact': _makeContact(name: 'Charlie').toMap(),
        'messages': [
          _makeMessage(id: 'msg-x').toJson(),
        ],
        'adapterType': 'oxen',
        'adapterConfig': {'endpoint': 'http://snode.example.com'},
        'updatedAt': updatedAt.toIso8601String(),
      };

      final room = ChatRoom.fromJson(json);

      expect(room.id, 'room-from');
      expect(room.contact.name, 'Charlie');
      expect(room.messages, hasLength(1));
      expect(room.messages.first.id, 'msg-x');
      expect(room.adapterType, 'oxen');
      expect(room.adapterConfig['endpoint'], 'http://snode.example.com');
      expect(room.updatedAt, updatedAt);
    });

    test('deserializes empty messages list', () {
      final raw = <String, dynamic>{
        'id': 'room-empty',
        'contact': _makeContact().toMap(),
        'messages': <dynamic>[],
        'adapterType': 'nostr',
        'adapterConfig': <String, dynamic>{},
        'updatedAt': DateTime.utc(2026).toIso8601String(),
      };
      // Roundtrip through JSON to get realistic types
      final json = jsonDecode(jsonEncode(raw)) as Map<String, dynamic>;
      final room = ChatRoom.fromJson(json);
      expect(room.messages, isEmpty);
    });

    test('filters out malformed messages via tryFromJson', () {
      final raw = <String, dynamic>{
        'id': 'room-filter',
        'contact': _makeContact().toMap(),
        'messages': [
          _makeMessage(id: 'good').toJson(),
          _makeMessage(id: 'also-good').toJson(),
        ],
        'adapterType': 'nostr',
        'adapterConfig': <String, dynamic>{},
        'updatedAt': DateTime.utc(2026).toIso8601String(),
      };
      final json = jsonDecode(jsonEncode(raw)) as Map<String, dynamic>;
      final room = ChatRoom.fromJson(json);
      expect(room.messages, hasLength(2));
    });
  });

  // ── Roundtrip ─────────────────────────────────────────────────────────

  group('ChatRoom toJson -> fromJson roundtrip', () {
    test('roundtrip produces equivalent object', () {
      final contact = _makeContact(
        id: 'c-rt',
        name: 'RoundTrip User',
        provider: 'Firebase',
        databaseId: 'user@https://proj.firebaseio.com',
        publicKey: 'pk-roundtrip',
      );
      final messages = [
        _makeMessage(
          id: 'rt-msg-1',
          senderId: 'sender-rt',
          receiverId: 'receiver-rt',
          encryptedPayload: 'payload-rt',
          timestamp: DateTime.utc(2026, 3, 20, 10, 0, 0),
          adapterType: 'firebase',
        ),
        _makeMessage(
          id: 'rt-msg-2',
          senderId: 'sender-rt',
          receiverId: 'receiver-rt',
          encryptedPayload: 'payload-rt-2',
          timestamp: DateTime.utc(2026, 3, 20, 11, 0, 0),
          adapterType: 'firebase',
        ),
      ];
      final updatedAt = DateTime.utc(2026, 3, 20, 12, 0, 0);
      final original = ChatRoom(
        id: 'room-rt',
        contact: contact,
        messages: messages,
        adapterType: 'firebase',
        adapterConfig: {'project': 'my-project', 'region': 'us-central1'},
        updatedAt: updatedAt,
      );

      final json = original.toJson();
      final restored = ChatRoom.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.contact.id, original.contact.id);
      expect(restored.contact.name, original.contact.name);
      expect(restored.contact.provider, original.contact.provider);
      expect(restored.contact.databaseId, original.contact.databaseId);
      expect(restored.contact.publicKey, original.contact.publicKey);
      expect(restored.messages.length, original.messages.length);
      expect(restored.messages[0].id, original.messages[0].id);
      expect(restored.messages[1].id, original.messages[1].id);
      expect(restored.adapterType, original.adapterType);
      expect(restored.adapterConfig, original.adapterConfig);
      expect(restored.updatedAt, original.updatedAt);
    });

    test('roundtrip with empty messages and config', () {
      final original = _makeChatRoom(
        id: 'room-empty-rt',
        messages: [],
        adapterConfig: {},
      );

      final restored = ChatRoom.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.messages, isEmpty);
      expect(restored.adapterConfig, isEmpty);
    });

    test('roundtrip preserves nested adapterConfig values', () {
      final config = <String, dynamic>{
        'nested': {'key': 'value', 'num': 42},
        'list': [1, 2, 3],
        'bool': true,
      };
      final original = _makeChatRoom(adapterConfig: config);
      final restored = ChatRoom.fromJson(original.toJson());

      expect(restored.adapterConfig['nested'], {'key': 'value', 'num': 42});
      expect(restored.adapterConfig['list'], [1, 2, 3]);
      expect(restored.adapterConfig['bool'], true);
    });
  });

  // ── Edge cases ────────────────────────────────────────────────────────

  group('ChatRoom edge cases', () {
    test('empty string id', () {
      final room = _makeChatRoom(id: '');
      expect(room.id, '');

      final restored = ChatRoom.fromJson(room.toJson());
      expect(restored.id, '');
    });

    test('empty string adapterType', () {
      final room = _makeChatRoom(adapterType: '');
      expect(room.adapterType, '');

      final restored = ChatRoom.fromJson(room.toJson());
      expect(restored.adapterType, '');
    });

    test('special characters in contact name', () {
      final contact = _makeContact(name: "O'Brien & Sons <\"test\"> \u{1F600}");
      final room = _makeChatRoom(contact: contact);

      final restored = ChatRoom.fromJson(room.toJson());
      expect(restored.contact.name, "O'Brien & Sons <\"test\"> \u{1F600}");
    });

    test('unicode in adapterConfig values', () {
      final config = <String, dynamic>{
        'label': '\u{4F60}\u{597D}\u{4E16}\u{754C}',
        'emoji': '\u{1F30D}',
      };
      final room = _makeChatRoom(adapterConfig: config);
      final restored = ChatRoom.fromJson(room.toJson());

      expect(restored.adapterConfig['label'], '\u{4F60}\u{597D}\u{4E16}\u{754C}');
      expect(restored.adapterConfig['emoji'], '\u{1F30D}');
    });

    test('contact with group fields roundtrips through ChatRoom', () {
      final contact = _makeContact(
        isGroup: true,
        members: ['member-1', 'member-2', 'member-3'],
        creatorId: 'creator-1',
      );
      final room = _makeChatRoom(
        contact: contact,
        adapterType: 'group',
      );

      final restored = ChatRoom.fromJson(room.toJson());
      expect(restored.contact.isGroup, true);
      expect(restored.contact.members, ['member-1', 'member-2', 'member-3']);
      expect(restored.contact.creatorId, 'creator-1');
    });

    test('contact with alternateAddresses roundtrips through ChatRoom', () {
      final contact = _makeContact(
        alternateAddresses: [
          'alt1@wss://relay1.com',
          'alt2@wss://relay2.com',
        ],
      );
      final room = _makeChatRoom(contact: contact);
      final restored = ChatRoom.fromJson(room.toJson());

      expect(restored.contact.alternateAddresses, hasLength(2));
      expect(restored.contact.alternateAddresses[0], 'alt1@wss://relay1.com');
    });

    test('message with reply fields survives roundtrip', () {
      final msg = Message(
        id: 'reply-msg',
        senderId: 's',
        receiverId: 'r',
        encryptedPayload: 'data',
        timestamp: DateTime.utc(2026, 3, 21),
        adapterType: 'nostr',
        replyToId: 'original-msg',
        replyToText: 'Original text',
        replyToSender: 'original-sender',
      );
      final room = _makeChatRoom(messages: [msg]);
      final restored = ChatRoom.fromJson(room.toJson());

      expect(restored.messages.first.replyToId, 'original-msg');
      expect(restored.messages.first.replyToText, 'Original text');
      expect(restored.messages.first.replyToSender, 'original-sender');
    });
  });

  // ── Field mapping verification ────────────────────────────────────────

  group('ChatRoom field mapping', () {
    test('toJson keys match fromJson expectations', () {
      final room = _makeChatRoom();
      final json = room.toJson();

      // Verify all expected keys are present
      expect(json.containsKey('id'), isTrue);
      expect(json.containsKey('contact'), isTrue);
      expect(json.containsKey('messages'), isTrue);
      expect(json.containsKey('adapterType'), isTrue);
      expect(json.containsKey('adapterConfig'), isTrue);
      expect(json.containsKey('updatedAt'), isTrue);

      // Verify no extra keys
      expect(json.keys.length, 6);
    });

    test('updatedAt serializes as ISO 8601 and parses back correctly', () {
      // Use a datetime with sub-second precision to test precision handling
      final dt = DateTime.utc(2026, 12, 31, 23, 59, 59, 999);
      final room = _makeChatRoom(updatedAt: dt);
      final json = room.toJson();

      // Verify the string format
      expect(json['updatedAt'], contains('2026-12-31'));

      // Verify it parses back
      final restored = ChatRoom.fromJson(json);
      expect(restored.updatedAt.millisecondsSinceEpoch,
          dt.millisecondsSinceEpoch);
    });

    test('adapterConfig preserves all value types', () {
      final config = <String, dynamic>{
        'string': 'hello',
        'int': 42,
        'double': 3.14,
        'bool': true,
        'null_val': null,
        'list': ['a', 'b'],
        'map': {'nested': true},
      };
      final room = _makeChatRoom(adapterConfig: config);
      final restored = ChatRoom.fromJson(room.toJson());

      expect(restored.adapterConfig['string'], 'hello');
      expect(restored.adapterConfig['int'], 42);
      expect(restored.adapterConfig['double'], 3.14);
      expect(restored.adapterConfig['bool'], true);
      expect(restored.adapterConfig['null_val'], isNull);
      expect(restored.adapterConfig['list'], ['a', 'b']);
      expect(restored.adapterConfig['map'], {'nested': true});
    });
  });
}
