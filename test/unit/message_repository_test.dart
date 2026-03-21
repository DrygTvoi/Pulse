import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/models/contact.dart';
import 'package:pulse_messenger/services/message_repository.dart';

Contact _makeContact({
  required String id,
  String name = 'Alice',
  String provider = 'Nostr',
  bool isGroup = false,
  List<String> members = const [],
}) =>
    Contact(
      id: id,
      name: name,
      provider: provider,
      databaseId: isGroup ? '' : '$id@wss://relay.test',
      publicKey: '',
      isGroup: isGroup,
      members: members,
    );


void main() {
  group('MessageRepository — rooms', () {
    test('getOrCreateRoom creates a new room', () {
      final repo = MessageRepository();
      final c = _makeContact(id: 'c1');
      expect(repo.getRoomForContact('c1'), isNull);
      final room = repo.getOrCreateRoom(c);
      expect(room, isNotNull);
      expect(room.contact, equals(c));
      expect(room.messages, isEmpty);
    });

    test('getOrCreateRoom returns existing room on second call', () {
      final repo = MessageRepository();
      final c = _makeContact(id: 'c2');
      final r1 = repo.getOrCreateRoom(c);
      final r2 = repo.getOrCreateRoom(c);
      expect(identical(r1, r2), isTrue);
    });

    test('containsRoom returns false before creation', () {
      final repo = MessageRepository();
      expect(repo.containsRoom('ghost'), isFalse);
    });

    test('containsRoom returns true after creation', () {
      final repo = MessageRepository();
      final c = _makeContact(id: 'x');
      repo.getOrCreateRoom(c);
      expect(repo.containsRoom('x'), isTrue);
    });

    test('rooms iterable includes all created rooms', () {
      final repo = MessageRepository();
      repo.getOrCreateRoom(_makeContact(id: 'a'));
      repo.getOrCreateRoom(_makeContact(id: 'b'));
      expect(repo.rooms.length, equals(2));
    });

    test('getOrCreateRoomWithId uses supplied id', () {
      final repo = MessageRepository();
      final c = _makeContact(id: 'c3');
      final room = repo.getOrCreateRoomWithId(c, 'custom-id', 'firebase');
      expect(room.id, equals('custom-id'));
      expect(room.adapterType, equals('firebase'));
    });
  });

  group('MessageRepository — reactions', () {
    test('applyReactionLocally adds a reaction key', () {
      final repo = MessageRepository();
      repo.applyReactionLocally('room1', 'msg1', '❤_alice', true);
      final r = repo.getReactions('room1', 'msg1');
      expect(r['❤'], contains('alice'));
    });

    test('applyReactionLocally removes a reaction key', () {
      final repo = MessageRepository();
      repo.applyReactionLocally('room1', 'msg1', '❤_alice', true);
      repo.applyReactionLocally('room1', 'msg1', '❤_alice', false);
      final r = repo.getReactions('room1', 'msg1');
      expect(r['❤'] ?? [], isEmpty);
    });

    test('applyRemoteReaction adds incoming reaction', () {
      final repo = MessageRepository();
      repo.applyRemoteReaction('room2', 'msg2', '👍_bob', false);
      final r = repo.getReactions('room2', 'msg2');
      expect(r['👍'], contains('bob'));
    });

    test('applyRemoteReaction removes incoming reaction', () {
      final repo = MessageRepository();
      repo.applyRemoteReaction('room2', 'msg2', '👍_bob', false);
      repo.applyRemoteReaction('room2', 'msg2', '👍_bob', true);
      final r = repo.getReactions('room2', 'msg2');
      expect(r['👍'] ?? [], isEmpty);
    });

    test('getReactions returns empty map for unknown room', () {
      final repo = MessageRepository();
      expect(repo.getReactions('no-room', 'no-msg'), isEmpty);
    });
  });

  group('MessageRepository — TTL', () {
    test('getChatTtlCached returns 0 by default', () {
      final repo = MessageRepository();
      expect(repo.getChatTtlCached('any'), equals(0));
    });

    test('setChatTtl stores and retrieves value', () {
      final repo = MessageRepository();
      repo.setChatTtl('c5', 60);
      expect(repo.getChatTtlCached('c5'), equals(60));
    });

    test('cancelTtlTimer silently handles missing timer', () {
      final repo = MessageRepository();
      expect(() => repo.cancelTtlTimer('nonexistent'), returnsNormally);
    });
  });

  group('MessageRepository — pagination flags', () {
    test('hasMoreHistory is true by default', () {
      final repo = MessageRepository();
      expect(repo.hasMoreHistory('room'), isTrue);
    });

    test('isLoadingMoreHistory is false by default', () {
      final repo = MessageRepository();
      expect(repo.isLoadingMoreHistory('room'), isFalse);
    });
  });

  group('MessageRepository — upload progress', () {
    test('setUploadProgress and getUploadProgress round-trip', () {
      final repo = MessageRepository();
      expect(repo.getUploadProgress('m1'), isNull);
      repo.setUploadProgress('m1', 0.5);
      expect(repo.getUploadProgress('m1'), closeTo(0.5, 0.001));
    });

    test('clearUploadProgress removes entry', () {
      final repo = MessageRepository();
      repo.setUploadProgress('m2', 1.0);
      repo.clearUploadProgress('m2');
      expect(repo.getUploadProgress('m2'), isNull);
    });
  });

  group('MessageRepository — dispose', () {
    test('dispose can be called without error', () {
      final repo = MessageRepository();
      expect(() => repo.dispose(), returnsNormally);
    });
  });
}
