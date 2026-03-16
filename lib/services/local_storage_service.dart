import 'dart:convert';
import 'dart:io';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  Database? _db;
  SecretKey? _encKey;

  static const _kAesKeyPref = 'local_db_aes_key_v1';
  static final _aesGcm = AesGcm.with256bits();

  Future<void> init() async {
    // Init encryption key before opening DB (needed for migration).
    _encKey = await _getOrCreateEncKey();

    final String path;
    if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      final dbDir = await databaseFactoryFfi.getDatabasesPath();
      path = '$dbDir/messages.db';
    } else {
      final dbDir = await databaseFactory.getDatabasesPath();
      path = '$dbDir/messages.db';
    }

    _db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (db, _) async {
          await db.execute('''
            CREATE TABLE messages (
              msg_id    TEXT NOT NULL,
              room_id   TEXT NOT NULL,
              timestamp INTEGER NOT NULL,
              data      TEXT NOT NULL,
              PRIMARY KEY (msg_id, room_id)
            )
          ''');
          await db.execute(
            'CREATE INDEX idx_messages_room_ts ON messages(room_id, timestamp)',
          );
          await db.execute('''
            CREATE TABLE ttl_pending (
              msg_id     TEXT NOT NULL,
              room_id    TEXT NOT NULL,
              expires_at INTEGER NOT NULL,
              PRIMARY KEY (msg_id, room_id)
            )
          ''');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS ttl_pending (
                msg_id     TEXT NOT NULL,
                room_id    TEXT NOT NULL,
                expires_at INTEGER NOT NULL,
                PRIMARY KEY (msg_id, room_id)
              )
            ''');
          }
        },
      ),
    );

    await _migrateEncryption();
    await _migrateFromPrefs();
  }

  // ── Encryption ─────────────────────────────────────────────────────────────

  Future<SecretKey> _getOrCreateEncKey() async {
    const ss = FlutterSecureStorage();
    final stored = await ss.read(key: _kAesKeyPref);
    if (stored != null) {
      return SecretKey(base64Decode(stored));
    }
    final key = await _aesGcm.newSecretKey();
    final bytes = await key.extractBytes();
    await ss.write(
        key: _kAesKeyPref,
        value: base64Encode(Uint8List.fromList(bytes)));
    return key;
  }

  Future<String> _encrypt(String plain) async {
    final plainBytes = utf8.encode(plain);
    final secretBox = await _aesGcm.encrypt(plainBytes, secretKey: _encKey!);
    // Layout: nonce(12) || mac(16) || ciphertext
    final combined = [
      ...secretBox.nonce,
      ...secretBox.mac.bytes,
      ...secretBox.cipherText,
    ];
    return 'ENC:${base64Encode(combined)}';
  }

  Future<String> _decrypt(String stored) async {
    if (!stored.startsWith('ENC:')) return stored; // legacy plaintext
    final bytes = base64Decode(stored.substring(4));
    const nonceLen = 12, macLen = 16;
    final nonce = bytes.sublist(0, nonceLen);
    final mac = Mac(bytes.sublist(nonceLen, nonceLen + macLen));
    final cipherText = bytes.sublist(nonceLen + macLen);
    final secretBox = SecretBox(cipherText, nonce: nonce, mac: mac);
    final decryptedBytes = await _aesGcm.decrypt(secretBox, secretKey: _encKey!);
    return utf8.decode(decryptedBytes);
  }

  /// Re-encrypts any legacy plaintext rows left from v1 schema.
  Future<void> _migrateEncryption() async {
    final db = _db!;
    final rows = await db.query('messages', columns: ['msg_id', 'room_id', 'data']);
    int migrated = 0;
    for (final row in rows) {
      final data = row['data'] as String;
      if (!data.startsWith('ENC:')) {
        final encrypted = await _encrypt(data);
        await db.update(
          'messages',
          {'data': encrypted},
          where: 'msg_id = ? AND room_id = ?',
          whereArgs: [row['msg_id'], row['room_id']],
        );
        migrated++;
      }
    }
    if (migrated > 0) {
      debugPrint('[LocalStorage] Re-encrypted $migrated legacy plaintext row(s)');
    }
  }

  // ── TTL pending ─────────────────────────────────────────────────────────────

  Future<void> saveTtlExpiry(
      String roomId, String msgId, int expiresAtMs) async {
    await _database.insert(
      'ttl_pending',
      {'msg_id': msgId, 'room_id': roomId, 'expires_at': expiresAtMs},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteTtlExpiry(String roomId, String msgId) async {
    await _database.delete(
      'ttl_pending',
      where: 'room_id = ? AND msg_id = ?',
      whereArgs: [roomId, msgId],
    );
  }

  Future<List<({String roomId, String msgId, DateTime expiresAt})>>
      loadAllTtlPending() async {
    final rows = await _database
        .query('ttl_pending', columns: ['msg_id', 'room_id', 'expires_at']);
    return rows.map((r) {
      return (
        roomId: r['room_id'] as String,
        msgId: r['msg_id'] as String,
        expiresAt: DateTime.fromMillisecondsSinceEpoch(r['expires_at'] as int),
      );
    }).toList();
  }

  // ── Migration from SharedPreferences (v1 → SQLite) ─────────────────────────

  Future<void> _migrateFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final keys =
        prefs.getKeys().where((k) => k.startsWith('chat_messages_')).toList();
    if (keys.isEmpty) return;

    final db = _db!;
    for (final key in keys) {
      final jsonStr = prefs.getString(key);
      if (jsonStr == null) continue;
      final roomId = key.substring('chat_messages_'.length);
      List<dynamic> msgs;
      try {
        msgs = jsonDecode(jsonStr) as List;
      } catch (_) {
        continue;
      }
      final batch = db.batch();
      for (final raw in msgs) {
        final msg = raw as Map<String, dynamic>;
        final encrypted = await _encrypt(jsonEncode(msg));
        batch.insert(
          'messages',
          {
            'msg_id': msg['id'] as String? ?? '',
            'room_id': roomId,
            'timestamp': _tsOf(msg),
            'data': encrypted,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
      await prefs.remove(key);
    }
  }

  static int _tsOf(Map<String, dynamic> msg) {
    final ts = msg['timestamp'];
    if (ts is int) return ts;
    if (ts is String) return DateTime.tryParse(ts)?.millisecondsSinceEpoch ?? 0;
    return 0;
  }

  Database get _database {
    if (_db == null) {
      throw StateError('LocalStorageService.init() must be called before use');
    }
    return _db!;
  }

  // ── Public CRUD ─────────────────────────────────────────────────────────────

  /// Upsert a message (insert or replace if same msg_id+room_id).
  Future<void> saveMessage(String roomId, Map<String, dynamic> message) async {
    final encrypted = await _encrypt(jsonEncode(message));
    await _database.insert(
      'messages',
      {
        'msg_id': message['id'] as String? ?? '',
        'room_id': roomId,
        'timestamp': _tsOf(message),
        'data': encrypted,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Delete a single message by id.
  Future<void> deleteMessage(String roomId, String messageId) async {
    await _database.delete(
      'messages',
      where: 'room_id = ? AND msg_id = ?',
      whereArgs: [roomId, messageId],
    );
  }

  /// Load all messages for a room in ascending timestamp order.
  Future<List<Map<String, dynamic>>> loadMessages(String roomId) async {
    final rows = await _database.query(
      'messages',
      columns: ['data'],
      where: 'room_id = ?',
      whereArgs: [roomId],
      orderBy: 'timestamp ASC',
    );
    final result = <Map<String, dynamic>>[];
    for (final r in rows) {
      try {
        final plain = await _decrypt(r['data'] as String);
        result.add(jsonDecode(plain) as Map<String, dynamic>);
      } catch (e) {
        debugPrint('[LocalStorage] Failed to decrypt row: $e');
      }
    }
    return result;
  }

  /// Efficient row count without loading message data.
  Future<int> countMessages(String roomId) async {
    final result = await _database.rawQuery(
      'SELECT COUNT(*) AS cnt FROM messages WHERE room_id = ?',
      [roomId],
    );
    return (result.first['cnt'] as int?) ?? 0;
  }

  /// Load a page of messages, most-recent first then reversed to ascending.
  /// [offset] = how many messages from the end to skip (0 = most recent page).
  Future<List<Map<String, dynamic>>> loadMessagesPage(
    String roomId, {
    int pageSize = 50,
    int offset = 0,
  }) async {
    final rows = await _database.query(
      'messages',
      columns: ['data'],
      where: 'room_id = ?',
      whereArgs: [roomId],
      orderBy: 'timestamp DESC',
      limit: pageSize,
      offset: offset,
    );
    // Reverse so the caller gets oldest→newest within the page
    final reversed = rows.reversed.toList();
    final result = <Map<String, dynamic>>[];
    for (final r in reversed) {
      try {
        final plain = await _decrypt(r['data'] as String);
        result.add(jsonDecode(plain) as Map<String, dynamic>);
      } catch (e) {
        debugPrint('[LocalStorage] Failed to decrypt row: $e');
      }
    }
    return result;
  }

  /// Delete all messages for a room.
  Future<void> clearHistory(String roomId) async {
    await _database.delete(
      'messages',
      where: 'room_id = ?',
      whereArgs: [roomId],
    );
    await _database.delete(
      'ttl_pending',
      where: 'room_id = ?',
      whereArgs: [roomId],
    );
  }

  /// Wipe the entire messages table (used by panic key / self-destruct).
  Future<void> clearAll() async {
    if (_db == null) return;
    await _database.delete('messages');
    await _database.delete('ttl_pending');
  }
}
