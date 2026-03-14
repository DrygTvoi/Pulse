import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  Database? _db;

  Future<void> init() async {
    final String path;
    if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      final dbDir = await databaseFactoryFfi.getDatabasesPath();
      path = '$dbDir/messages.db';
    } else {
      // Android / iOS: sqflite plugin sets databaseFactory natively.
      final dbDir = await databaseFactory.getDatabasesPath();
      path = '$dbDir/messages.db';
    }

    _db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
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
        },
      ),
    );

    await _migrateFromPrefs();
  }

  /// One-time migration: moves all chat_messages_* blobs from SharedPreferences
  /// into SQLite and removes the keys so it only runs once.
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
        batch.insert(
          'messages',
          {
            'msg_id': msg['id'] as String? ?? '',
            'room_id': roomId,
            'timestamp': _tsOf(msg),
            'data': jsonEncode(msg),
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
    assert(_db != null, 'LocalStorageService.init() must be called before use');
    return _db!;
  }

  /// Upsert a message (insert or replace if same msg_id+room_id).
  Future<void> saveMessage(String roomId, Map<String, dynamic> message) async {
    await _database.insert(
      'messages',
      {
        'msg_id': message['id'] as String? ?? '',
        'room_id': roomId,
        'timestamp': _tsOf(message),
        'data': jsonEncode(message),
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
    return rows
        .map((r) => jsonDecode(r['data'] as String) as Map<String, dynamic>)
        .toList();
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
    return rows.reversed
        .map((r) => jsonDecode(r['data'] as String) as Map<String, dynamic>)
        .toList();
  }

  /// Delete all messages for a room.
  Future<void> clearHistory(String roomId) async {
    await _database.delete(
      'messages',
      where: 'room_id = ?',
      whereArgs: [roomId],
    );
  }

  /// Wipe the entire messages table (used by panic key / self-destruct).
  Future<void> clearAll() async {
    if (_db == null) return;
    await _database.delete('messages');
  }
}
