import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pulse_messenger/services/local_storage_service.dart';

// Helper: build a minimal message map accepted by LocalStorageService.
Map<String, dynamic> _msg({
  required String id,
  required String roomId,
  String text = 'hello',
  DateTime? timestamp,
  String status = '',
  bool isRead = false,
}) {
  final ts = timestamp ?? DateTime(2024, 1, 1, 12, 0, 0);
  return {
    'id': id,
    'senderId': 'alice',
    'receiverId': roomId,
    'encryptedPayload': text,
    'timestamp': ts.millisecondsSinceEpoch,
    'adapterType': 'firebase',
    'isRead': isRead,
    'status': status,
  };
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await LocalStorageService().init();
  });

  // ── saveMessage / loadMessages ────────────────────────────────────────────

  group('saveMessage / loadMessages', () {
    test('saved message is retrieved with correct payload', () async {
      const room = 'r_save_basic';
      await LocalStorageService().clearHistory(room);

      await LocalStorageService().saveMessage(room, _msg(id: 'm1', roomId: room, text: 'Hello!'));

      final loaded = await LocalStorageService().loadMessages(room);
      expect(loaded.length, 1);
      expect(loaded.first['id'], 'm1');
      expect(loaded.first['encryptedPayload'], 'Hello!');
    });

    test('messages are returned in ascending timestamp order', () async {
      const room = 'r_order';
      await LocalStorageService().clearHistory(room);

      final base = DateTime(2024, 1, 1);
      // Insert out of order intentionally
      await LocalStorageService().saveMessage(room, _msg(id: 'c', roomId: room, timestamp: base.add(const Duration(seconds: 2))));
      await LocalStorageService().saveMessage(room, _msg(id: 'a', roomId: room, timestamp: base));
      await LocalStorageService().saveMessage(room, _msg(id: 'b', roomId: room, timestamp: base.add(const Duration(seconds: 1))));

      final loaded = await LocalStorageService().loadMessages(room);
      expect(loaded.map((m) => m['id']).toList(), ['a', 'b', 'c']);
    });

    test('upsert replaces existing message — count stays at 1', () async {
      const room = 'r_upsert';
      await LocalStorageService().clearHistory(room);

      final msg = _msg(id: 'dup', roomId: room, text: 'original', status: 'sending');
      await LocalStorageService().saveMessage(room, msg);
      await LocalStorageService().saveMessage(room, {...msg, 'status': 'sent', 'encryptedPayload': 'updated'});

      final loaded = await LocalStorageService().loadMessages(room);
      expect(loaded.length, 1);
      expect(loaded.first['status'], 'sent');
      expect(loaded.first['encryptedPayload'], 'updated');
    });

    test('different rooms are completely isolated', () async {
      const room1 = 'r_iso_a';
      const room2 = 'r_iso_b';
      await LocalStorageService().clearHistory(room1);
      await LocalStorageService().clearHistory(room2);

      await LocalStorageService().saveMessage(room1, _msg(id: 'x1', roomId: room1, text: 'in room1'));
      await LocalStorageService().saveMessage(room2, _msg(id: 'x2', roomId: room2, text: 'in room2'));

      final r1 = await LocalStorageService().loadMessages(room1);
      final r2 = await LocalStorageService().loadMessages(room2);

      expect(r1.length, 1);
      expect(r1.first['encryptedPayload'], 'in room1');
      expect(r2.length, 1);
      expect(r2.first['encryptedPayload'], 'in room2');
    });

    test('empty room returns empty list', () async {
      const room = 'r_empty_load';
      await LocalStorageService().clearHistory(room);
      expect(await LocalStorageService().loadMessages(room), isEmpty);
    });

    test('multiple messages all retrieved', () async {
      const room = 'r_multi';
      await LocalStorageService().clearHistory(room);

      final base = DateTime(2024, 3, 1);
      for (int i = 0; i < 10; i++) {
        await LocalStorageService().saveMessage(
          room,
          _msg(id: 'mm$i', roomId: room, timestamp: base.add(Duration(seconds: i))),
        );
      }

      final loaded = await LocalStorageService().loadMessages(room);
      expect(loaded.length, 10);
    });
  });

  // ── deleteMessage ─────────────────────────────────────────────────────────

  group('deleteMessage', () {
    test('removes the targeted message, leaves others untouched', () async {
      const room = 'r_del_basic';
      await LocalStorageService().clearHistory(room);

      await LocalStorageService().saveMessage(room, _msg(id: 'keep', roomId: room, text: 'keep me'));
      await LocalStorageService().saveMessage(room, _msg(id: 'gone', roomId: room, text: 'delete me'));

      await LocalStorageService().deleteMessage(room, 'gone');

      final loaded = await LocalStorageService().loadMessages(room);
      expect(loaded.length, 1);
      expect(loaded.first['id'], 'keep');
    });

    test('deleting non-existent id is a no-op', () async {
      const room = 'r_del_noop';
      await LocalStorageService().clearHistory(room);

      await LocalStorageService().saveMessage(room, _msg(id: 'existing', roomId: room));
      await LocalStorageService().deleteMessage(room, 'ghost_id');

      expect(await LocalStorageService().countMessages(room), 1);
    });

    test('delete is room-scoped: same id in different room stays intact', () async {
      const room1 = 'r_scope_del_1';
      const room2 = 'r_scope_del_2';
      await LocalStorageService().clearHistory(room1);
      await LocalStorageService().clearHistory(room2);

      const sharedId = 'shared_id';
      await LocalStorageService().saveMessage(room1, _msg(id: sharedId, roomId: room1));
      await LocalStorageService().saveMessage(room2, _msg(id: sharedId, roomId: room2));

      await LocalStorageService().deleteMessage(room1, sharedId);

      expect(await LocalStorageService().loadMessages(room1), isEmpty);
      expect(await LocalStorageService().loadMessages(room2), hasLength(1));
    });
  });

  // ── countMessages ─────────────────────────────────────────────────────────

  group('countMessages', () {
    test('returns 0 for empty room', () async {
      const room = 'r_count_empty';
      await LocalStorageService().clearHistory(room);
      expect(await LocalStorageService().countMessages(room), 0);
    });

    test('returns correct count after multiple inserts', () async {
      const room = 'r_count_n';
      await LocalStorageService().clearHistory(room);

      for (int i = 0; i < 5; i++) {
        await LocalStorageService().saveMessage(room, _msg(id: 'cnt$i', roomId: room));
      }
      expect(await LocalStorageService().countMessages(room), 5);
    });

    test('upsert does not increase count', () async {
      const room = 'r_count_upsert';
      await LocalStorageService().clearHistory(room);

      final msg = _msg(id: 'dup_cnt', roomId: room);
      await LocalStorageService().saveMessage(room, msg);
      await LocalStorageService().saveMessage(room, {...msg, 'status': 'sent'});

      expect(await LocalStorageService().countMessages(room), 1);
    });

    test('count decreases after delete', () async {
      const room = 'r_count_del';
      await LocalStorageService().clearHistory(room);

      await LocalStorageService().saveMessage(room, _msg(id: 'd1', roomId: room));
      await LocalStorageService().saveMessage(room, _msg(id: 'd2', roomId: room));
      await LocalStorageService().deleteMessage(room, 'd1');

      expect(await LocalStorageService().countMessages(room), 1);
    });
  });

  // ── loadMessagesPage ──────────────────────────────────────────────────────

  group('loadMessagesPage', () {
    test('returns most recent N messages in ascending order', () async {
      const room = 'r_page_basic';
      await LocalStorageService().clearHistory(room);

      final base = DateTime(2024, 1, 1);
      for (int i = 0; i < 5; i++) {
        await LocalStorageService().saveMessage(
          room,
          _msg(id: 'p$i', roomId: room, timestamp: base.add(Duration(seconds: i))),
        );
      }

      // pageSize=3, no cursor → last 3 (p2, p3, p4) in ascending order
      final page = await LocalStorageService().loadMessagesPage(room, pageSize: 3);
      expect(page.map((m) => m['id']).toList(), ['p2', 'p3', 'p4']);
    });

    test('cursor-based pagination returns older messages', () async {
      const room = 'r_page_cursor';
      await LocalStorageService().clearHistory(room);

      final base = DateTime(2024, 1, 1);
      for (int i = 0; i < 6; i++) {
        await LocalStorageService().saveMessage(
          room,
          _msg(id: 'o$i', roomId: room, timestamp: base.add(Duration(seconds: i))),
        );
      }

      // First load: last 3 → o3,o4,o5
      final page1 = await LocalStorageService().loadMessagesPage(room, pageSize: 3);
      expect(page1.map((m) => m['id']).toList(), ['o3', 'o4', 'o5']);

      // Second load: cursor = oldest timestamp from page1 (o3's timestamp)
      final cursor = page1.first['timestamp'] as int;
      final page2 = await LocalStorageService().loadMessagesPage(
        room, pageSize: 3, beforeTimestamp: cursor,
      );
      expect(page2.map((m) => m['id']).toList(), ['o0', 'o1', 'o2']);
    });

    test('returns all messages when total <= pageSize', () async {
      const room = 'r_page_small';
      await LocalStorageService().clearHistory(room);

      await LocalStorageService().saveMessage(room, _msg(id: 's1', roomId: room));
      await LocalStorageService().saveMessage(room, _msg(id: 's2', roomId: room));

      final page = await LocalStorageService().loadMessagesPage(room, pageSize: 50);
      expect(page.length, 2);
    });

    test('returns empty list for empty room', () async {
      const room = 'r_page_empty';
      await LocalStorageService().clearHistory(room);
      expect(await LocalStorageService().loadMessagesPage(room), isEmpty);
    });

    test('cursor before all messages returns empty list', () async {
      const room = 'r_page_overcursor';
      await LocalStorageService().clearHistory(room);

      await LocalStorageService().saveMessage(room, _msg(id: 'oo1', roomId: room));
      await LocalStorageService().saveMessage(room, _msg(id: 'oo2', roomId: room));

      // Use a cursor older than any stored message
      final page = await LocalStorageService().loadMessagesPage(
        room, pageSize: 10, beforeTimestamp: 0,
      );
      expect(page, isEmpty);
    });
  });

  // ── clearHistory ──────────────────────────────────────────────────────────

  group('clearHistory', () {
    test('removes all messages for the room', () async {
      const room = 'r_clear_all';
      await LocalStorageService().saveMessage(room, _msg(id: 'cl1', roomId: room));
      await LocalStorageService().saveMessage(room, _msg(id: 'cl2', roomId: room));

      await LocalStorageService().clearHistory(room);

      expect(await LocalStorageService().loadMessages(room), isEmpty);
      expect(await LocalStorageService().countMessages(room), 0);
    });

    test('clearHistory only affects the specified room', () async {
      const room1 = 'r_clear_iso_1';
      const room2 = 'r_clear_iso_2';
      await LocalStorageService().clearHistory(room1);
      await LocalStorageService().clearHistory(room2);

      await LocalStorageService().saveMessage(room1, _msg(id: 'keep1', roomId: room1));
      await LocalStorageService().saveMessage(room2, _msg(id: 'keep2', roomId: room2));

      await LocalStorageService().clearHistory(room1);

      expect(await LocalStorageService().loadMessages(room1), isEmpty);
      expect(await LocalStorageService().loadMessages(room2), hasLength(1));
    });

    test('clearing an already-empty room is a no-op', () async {
      const room = 'r_clear_noop';
      await LocalStorageService().clearHistory(room);
      await LocalStorageService().clearHistory(room); // second clear
      expect(await LocalStorageService().countMessages(room), 0);
    });
  });

  // ── Timestamp format handling ─────────────────────────────────────────────

  group('timestamp parsing', () {
    test('integer millisecond timestamp is preserved round-trip', () async {
      const room = 'r_ts_int';
      await LocalStorageService().clearHistory(room);

      final ts = DateTime(2024, 6, 15, 10, 30).millisecondsSinceEpoch;
      await LocalStorageService().saveMessage(room, {
        'id': 'ts_int',
        'senderId': 'a',
        'receiverId': 'b',
        'encryptedPayload': 'hi',
        'timestamp': ts,
        'adapterType': 'firebase',
        'isRead': false,
        'status': '',
      });

      final loaded = await LocalStorageService().loadMessages(room);
      expect(loaded.first['timestamp'], ts);
    });

    test('ISO-8601 string timestamp is accepted without crash', () async {
      const room = 'r_ts_iso';
      await LocalStorageService().clearHistory(room);

      final dt = DateTime(2024, 6, 15, 10, 30);
      await LocalStorageService().saveMessage(room, {
        'id': 'ts_iso',
        'senderId': 'a',
        'receiverId': 'b',
        'encryptedPayload': 'hi',
        'timestamp': dt.toIso8601String(),
        'adapterType': 'firebase',
        'isRead': false,
        'status': '',
      });

      final loaded = await LocalStorageService().loadMessages(room);
      expect(loaded.length, 1);
    });

    test('missing timestamp defaults to 0 without crash', () async {
      const room = 'r_ts_missing';
      await LocalStorageService().clearHistory(room);

      await LocalStorageService().saveMessage(room, {
        'id': 'ts_missing',
        'senderId': 'a',
        'receiverId': 'b',
        'encryptedPayload': 'hi',
        // no 'timestamp' key
        'adapterType': 'firebase',
        'isRead': false,
        'status': '',
      });

      final loaded = await LocalStorageService().loadMessages(room);
      expect(loaded.length, 1);
    });
  });

  // ── The original bug: storage key collision ───────────────────────────────

  group('room key isolation (regression — shared-key bug)', () {
    test('two rooms with different ids never share messages', () async {
      // This guards against the \$roomId → $roomId bug that caused all chats
      // to write to the same SharedPreferences key.
      const room1 = 'user_alice@https://project.firebaseio.com';
      const room2 = 'user_bob@https://project.firebaseio.com';
      await LocalStorageService().clearHistory(room1);
      await LocalStorageService().clearHistory(room2);

      await LocalStorageService().saveMessage(room1, _msg(id: 'alice_msg', roomId: room1, text: 'hi from alice'));
      await LocalStorageService().saveMessage(room2, _msg(id: 'bob_msg', roomId: room2, text: 'hi from bob'));

      final r1 = await LocalStorageService().loadMessages(room1);
      final r2 = await LocalStorageService().loadMessages(room2);

      expect(r1.length, 1);
      expect(r1.first['encryptedPayload'], 'hi from alice');
      expect(r2.length, 1);
      expect(r2.first['encryptedPayload'], 'hi from bob');
    });

    test('Nostr pubkey@relay room keys are isolated', () async {
      const room1 = 'aabbcc@wss://relay.damus.io';
      const room2 = 'ddeeff@wss://relay.damus.io';
      await LocalStorageService().clearHistory(room1);
      await LocalStorageService().clearHistory(room2);

      await LocalStorageService().saveMessage(room1, _msg(id: 'n1', roomId: room1, text: 'nostr alice'));
      await LocalStorageService().saveMessage(room2, _msg(id: 'n2', roomId: room2, text: 'nostr bob'));

      final r1 = await LocalStorageService().loadMessages(room1);
      final r2 = await LocalStorageService().loadMessages(room2);

      expect(r1.first['encryptedPayload'], 'nostr alice');
      expect(r2.first['encryptedPayload'], 'nostr bob');
    });
  });
}
