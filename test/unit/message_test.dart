import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/models/message.dart';

void main() {
  final baseTime = DateTime.utc(2026, 3, 7, 12, 0, 0);

  Message makeMsg({
    String id = 'msg-1',
    String senderId = 'alice',
    String receiverId = 'bob',
    String payload = 'hello',
    String adapterType = 'firebase',
    bool isRead = false,
    String status = '',
  }) =>
      Message(
        id: id,
        senderId: senderId,
        receiverId: receiverId,
        encryptedPayload: payload,
        timestamp: baseTime,
        adapterType: adapterType,
        isRead: isRead,
        status: status,
      );

  group('Message.toJson()', () {
    test('includes all fields with correct types', () {
      final msg = makeMsg();
      final json = msg.toJson();
      expect(json['id'], equals('msg-1'));
      expect(json['senderId'], equals('alice'));
      expect(json['receiverId'], equals('bob'));
      expect(json['encryptedPayload'], equals('hello'));
      expect(json['timestamp'], equals(baseTime.toIso8601String()));
      expect(json['adapterType'], equals('firebase'));
      expect(json['isRead'], isFalse);
      expect(json['status'], equals(''));
    });

    test('serializes status correctly', () {
      final json = makeMsg(status: 'sent').toJson();
      expect(json['status'], equals('sent'));
    });

    test('serializes isRead correctly', () {
      final json = makeMsg(isRead: true).toJson();
      expect(json['isRead'], isTrue);
    });
  });

  group('Message.fromJson()', () {
    test('reconstructs all fields', () {
      final original = makeMsg(
          id: 'x', senderId: 's', receiverId: 'r',
          payload: 'p', adapterType: 'nostr', isRead: true, status: 'read');
      final json = original.toJson();
      final restored = Message.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.senderId, equals(original.senderId));
      expect(restored.receiverId, equals(original.receiverId));
      expect(restored.encryptedPayload, equals(original.encryptedPayload));
      expect(restored.timestamp, equals(original.timestamp));
      expect(restored.adapterType, equals(original.adapterType));
      expect(restored.isRead, equals(original.isRead));
      expect(restored.status, equals(original.status));
    });

    test('defaults isRead to false when missing', () {
      final json = makeMsg().toJson()..remove('isRead');
      expect(Message.fromJson(json).isRead, isFalse);
    });

    test('defaults status to empty string when missing', () {
      final json = makeMsg().toJson()..remove('status');
      expect(Message.fromJson(json).status, equals(''));
    });

    test('round-trip toJson → fromJson is lossless', () {
      final msg = makeMsg(
          id: 'abc', senderId: 'u1', receiverId: 'u2',
          payload: 'E2EE||3||abc123==', adapterType: 'group',
          isRead: true, status: 'read');
      final restored = Message.fromJson(msg.toJson());
      expect(restored.toJson(), equals(msg.toJson()));
    });
  });

  group('Message.copyWith()', () {
    test('changes only status', () {
      final msg = makeMsg(status: 'sending');
      final updated = msg.copyWith(status: 'sent');
      expect(updated.status, equals('sent'));
      expect(updated.id, equals(msg.id));
      expect(updated.encryptedPayload, equals(msg.encryptedPayload));
      expect(updated.isRead, equals(msg.isRead));
    });

    test('changes only encryptedPayload', () {
      final msg = makeMsg(payload: 'old');
      final updated = msg.copyWith(encryptedPayload: 'new');
      expect(updated.encryptedPayload, equals('new'));
      expect(updated.status, equals(msg.status));
      expect(updated.id, equals(msg.id));
    });

    test('changes only isRead', () {
      final msg = makeMsg(isRead: false);
      final updated = msg.copyWith(isRead: true);
      expect(updated.isRead, isTrue);
      expect(updated.status, equals(msg.status));
    });

    test('with no args preserves all values', () {
      final msg = makeMsg(status: 'sent', isRead: true, payload: 'content');
      final copy = msg.copyWith();
      expect(copy.status, equals(msg.status));
      expect(copy.isRead, equals(msg.isRead));
      expect(copy.encryptedPayload, equals(msg.encryptedPayload));
    });
  });
}
