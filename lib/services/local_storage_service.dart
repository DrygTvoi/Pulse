import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite3/open.dart' as sqlite3_open;

class LocalStorageService {
  static LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  /// Replace the singleton for testing.
  @visibleForTesting
  static void setInstanceForTesting(LocalStorageService instance) =>
      _instance = instance;

  Database? _db;
  SecretKey? _encKey;

  /// SQLCipher is always available — bundled via sqlcipher_flutter_libs.
  bool get isSqlcipherAvailable => true;

  static const _kAesKeyPref = 'local_db_aes_key_v1';
  static const _kDbKeyPref = 'local_db_cipher_key_v1';
  static const _kDbKeyTsPref = 'local_db_cipher_key_created_at';
  static const _kDbKeyRotationDays = 365;
  static final _aesGcm = AesGcm.with256bits();

  Future<void> init() async {
    // Init encryption key before opening DB (needed for migration).
    _encKey = await _getOrCreateEncKey();

    // Load SQLCipher on all platforms (bundled via sqlcipher_flutter_libs).
    await _loadSqlcipher();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dbDir = await databaseFactoryFfi.getDatabasesPath();
    final path = '$dbDir/messages.db';

    // Migrate existing plaintext DB → encrypted DB (first-run only).
    await _migratePlaintextToEncrypted(path);

    final dbKey = await _getOrCreateDbKey();

    _db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 6,
        onConfigure: (db) async {
          await db.rawQuery("PRAGMA KEY=\"x'$dbKey'\"");
          debugPrint('[LocalStorage] SQLCipher: full-DB encryption active');
        },
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
          await _createReactionsTable(db);
          await _createContactsTable(db);
          await _createAvatarsTable(db);
          await _createDraftsTable(db);
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
          if (oldVersion < 3) {
            await _createReactionsTable(db, ifNotExists: true);
          }
          if (oldVersion < 4) {
            await _createContactsTable(db, ifNotExists: true);
          }
          if (oldVersion < 5) {
            await _createAvatarsTable(db, ifNotExists: true);
          }
          if (oldVersion < 6) {
            await _createDraftsTable(db, ifNotExists: true);
          }
        },
      ),
    );

    await _migrateEncryption();
    await _migrateFromPrefs();
    await migrateReactionsFromPrefs();
    await _migrateContactsFromPrefs();
    await _migrateAvatarsFromPrefs();

    // Rotate DB encryption key if overdue.
    unawaited(_rotateDbKeyIfNeeded());
  }

  /// Create the reactions table (and its index) inside [db].
  /// Pass [ifNotExists] = true for upgrade/migration paths that must be idempotent.
  static Future<void> _createReactionsTable(Database db,
      {bool ifNotExists = false}) async {
    final q = ifNotExists ? 'IF NOT EXISTS ' : '';
    await db.execute('''
      CREATE TABLE ${q}reactions (
        room_id   TEXT NOT NULL,
        msg_id    TEXT NOT NULL,
        emoji     TEXT NOT NULL,
        sender_id TEXT NOT NULL,
        PRIMARY KEY (room_id, msg_id, emoji, sender_id)
      )
    ''');
    await db.execute(
      'CREATE INDEX ${q}idx_reactions_room_msg ON reactions(room_id, msg_id)',
    );
  }

  /// Create the contacts table inside [db].
  /// Pass [ifNotExists] = true for upgrade/migration paths that must be idempotent.
  static Future<void> _createContactsTable(Database db,
      {bool ifNotExists = false}) async {
    final q = ifNotExists ? 'IF NOT EXISTS ' : '';
    await db.execute('''
      CREATE TABLE ${q}contacts (
        id   TEXT NOT NULL PRIMARY KEY,
        data TEXT NOT NULL
      )
    ''');
  }

  /// Create the avatars table inside [db].
  /// Pass [ifNotExists] = true for upgrade/migration paths that must be idempotent.
  static Future<void> _createAvatarsTable(Database db,
      {bool ifNotExists = false}) async {
    final q = ifNotExists ? 'IF NOT EXISTS ' : '';
    await db.execute('''
      CREATE TABLE ${q}avatars (
        contact_id TEXT NOT NULL PRIMARY KEY,
        data       TEXT NOT NULL
      )
    ''');
  }

  /// Create the drafts table inside [db].
  /// Pass [ifNotExists] = true for upgrade/migration paths that must be idempotent.
  static Future<void> _createDraftsTable(Database db,
      {bool ifNotExists = false}) async {
    final q = ifNotExists ? 'IF NOT EXISTS ' : '';
    await db.execute('''
      CREATE TABLE ${q}drafts (
        contact_id TEXT NOT NULL PRIMARY KEY,
        text       TEXT NOT NULL
      )
    ''');
  }

  /// Load the SQLCipher shared library and override the sqlite3 open hook.
  ///
  /// Android: libsqlcipher.so is bundled in the APK via the Gradle dependency
  ///   `net.zetetic:android-database-sqlcipher` — DynamicLibrary.open finds it
  ///   automatically (minSdk 24+, no extra workaround needed).
  /// iOS: SQLCipher is statically linked via CocoaPods `pod 'SQLCipher'`;
  ///   DynamicLibrary.process() exposes its symbols.
  /// Linux/macOS/Windows: system-installed or app-bundled shared library.
  static Future<void> _loadSqlcipher() async {
    if (kIsWeb) return;
    if (Platform.isIOS) {
      sqlite3_open.open.overrideFor(
          sqlite3_open.OperatingSystem.iOS, DynamicLibrary.process);
    } else if (Platform.isMacOS) {
      sqlite3_open.open.overrideFor(
          sqlite3_open.OperatingSystem.macOS,
          () => DynamicLibrary.open('libsqlcipher.dylib'));
    } else if (Platform.isWindows) {
      sqlite3_open.open.overrideFor(
          sqlite3_open.OperatingSystem.windows,
          () => DynamicLibrary.open('sqlcipher.dll'));
    } else {
      // Android (libsqlcipher.so bundled in APK) and Linux (system package).
      sqlite3_open.open.overrideForAll(
          () => DynamicLibrary.open('libsqlcipher.so'));
    }
    debugPrint('[LocalStorage] SQLCipher loaded');
  }

  /// Validates that [s] is exactly 64 lowercase hex characters.
  /// Iterates all characters without short-circuiting to avoid timing variance
  /// on the format check (not a secret comparison, but good hygiene).
  static bool _isValidHex64(String s) {
    if (s.length != 64) return false;
    int invalid = 0;
    for (int i = 0; i < s.length; i++) {
      final c = s.codeUnitAt(i);
      // '0'-'9' = 48-57, 'a'-'f' = 97-102
      final isDigit = (c >= 48 && c <= 57) ? 0 : 1;
      final isLowerHex = (c >= 97 && c <= 102) ? 0 : 1;
      invalid |= isDigit & isLowerHex;
    }
    return invalid == 0;
  }

  /// Get or create a hex key for SQLCipher PRAGMA KEY.
  Future<String> _getOrCreateDbKey() async {
    const ss = FlutterSecureStorage();
    final existing = await ss.read(key: _kDbKeyPref);
    if (existing != null && _isValidHex64(existing)) {
      return existing;
    }

    // Generate a random 32-byte (256-bit) key as hex.
    final rng = Random.secure();
    final bytes = List.generate(32, (_) => rng.nextInt(256));
    final hexKey = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    await ss.write(key: _kDbKeyPref, value: hexKey);
    await ss.write(
        key: _kDbKeyTsPref,
        value: DateTime.now().millisecondsSinceEpoch.toString());
    return hexKey;
  }

  /// Rotate the SQLCipher encryption key if it's older than [_kDbKeyRotationDays].
  /// Uses PRAGMA rekey to atomically re-encrypt the database file.
  Future<void> _rotateDbKeyIfNeeded() async {
    try {
      const ss = FlutterSecureStorage();
      final tsStr = await ss.read(key: _kDbKeyTsPref);
      if (tsStr != null) {
        final tsParsed = int.tryParse(tsStr);
        if (tsParsed == null) return; // corrupt timestamp — skip rotation
        final created = DateTime.fromMillisecondsSinceEpoch(tsParsed);
        final age = DateTime.now().difference(created).inDays;
        if (age < _kDbKeyRotationDays) return;
      }
      // Generate new key.
      final rng = Random.secure();
      final newBytes = List.generate(32, (_) => rng.nextInt(256));
      final newKey = newBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      // Apply PRAGMA rekey (SQLCipher atomically re-encrypts the database).
      final db = _db;
      if (db == null) return;
      await db.rawQuery("PRAGMA rekey=\"x'$newKey'\"");
      // Persist the new key and timestamp.
      await ss.write(key: _kDbKeyPref, value: newKey);
      await ss.write(
          key: _kDbKeyTsPref,
          value: DateTime.now().millisecondsSinceEpoch.toString());
      debugPrint('[LocalStorage] SQLCipher key rotated successfully');
    } catch (e) {
      // Non-fatal — keep using existing key.
      debugPrint('[LocalStorage] DB key rotation failed: $e');
    }
  }

  /// Migrate an existing plaintext DB to an encrypted one.
  ///
  /// Strategy: open the old DB without a key, read all data, close it,
  /// rename it to .bak, and let init() create a fresh encrypted DB which
  /// will be populated via _migrateEncryption() and _migrateFromPrefs().
  Future<void> _migratePlaintextToEncrypted(String path) async {
    final file = File(path);
    if (!file.existsSync()) return; // no existing DB to migrate

    // Check if already encrypted — try opening with key
    const ss = FlutterSecureStorage();
    final hasKey = await ss.read(key: _kDbKeyPref) != null;
    if (hasKey) return; // already encrypted or fresh install

    // Read all data from the plaintext DB
    debugPrint('[LocalStorage] Migrating plaintext DB to SQLCipher...');
    try {
      final plainDb = await databaseFactory.openDatabase(path,
          options: OpenDatabaseOptions(readOnly: true));
      final messages = await plainDb.query('messages');

      List<Map<String, dynamic>> ttlRows = [];
      try {
        ttlRows = await plainDb.query('ttl_pending');
      } catch (_) {
        // ttl_pending may not exist in very old DBs
      }

      await plainDb.close();

      // Rename old DB
      final bak = File('$path.plaintext.bak');
      await file.rename(bak.path);
      // Also rename journal/wal files if present
      for (final suffix in ['-journal', '-wal', '-shm']) {
        final f = File('$path$suffix');
        if (f.existsSync()) await f.rename('$path$suffix.bak');
      }

      // Create the encryption key now (before the new DB is opened)
      await _getOrCreateDbKey();
      final dbKey = await ss.read(key: _kDbKeyPref);

      // Create encrypted DB
      final encDb = await databaseFactory.openDatabase(path,
          options: OpenDatabaseOptions(
            version: 6,
            onConfigure: (db) async {
              if (dbKey != null) {
                await db.rawQuery("PRAGMA KEY=\"x'$dbKey'\"");
              }
            },
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
              await _createReactionsTable(db);
              await _createContactsTable(db);
              await _createAvatarsTable(db);
              await _createDraftsTable(db);
            },
          ));

      // Restore data
      if (messages.isNotEmpty) {
        final batch = encDb.batch();
        for (final row in messages) {
          batch.insert('messages', Map<String, dynamic>.from(row),
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
        await batch.commit(noResult: true);
      }

      if (ttlRows.isNotEmpty) {
        final batch = encDb.batch();
        for (final row in ttlRows) {
          batch.insert('ttl_pending', Map<String, dynamic>.from(row),
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
        await batch.commit(noResult: true);
      }

      await encDb.close();

      // Clean up backup
      if (bak.existsSync()) await bak.delete();
      for (final suffix in ['-journal', '-wal', '-shm']) {
        final f = File('$path$suffix.bak');
        if (f.existsSync()) await f.delete();
      }

      debugPrint('[LocalStorage] Migration complete: ${messages.length} messages '
          'moved to encrypted DB');
    } catch (e) {
      debugPrint('[LocalStorage] Migration failed: $e — continuing with plaintext DB');
      // Restore backup if migration failed
      final bak = File('$path.plaintext.bak');
      if (bak.existsSync() && !file.existsSync()) {
        await bak.rename(path);
      }
      // Remove the cipher key so next run doesn't try to use it on a plaintext DB
      await ss.delete(key: _kDbKeyPref);
    }
  }

  // ── Encryption ─────────────────────────────────────────────────────────────

  Future<SecretKey> _getOrCreateEncKey() async {
    const ss = FlutterSecureStorage();

    // 1. Try secure storage first (normal path for new + already-migrated users).
    final stored = await ss.read(key: _kAesKeyPref);
    if (stored != null) {
      return SecretKey(base64Decode(stored));
    }

    // 2. Migration: check SharedPreferences for a legacy key.
    final prefs = await SharedPreferences.getInstance();
    final legacyKey = prefs.getString(_kAesKeyPref);
    if (legacyKey != null) {
      await ss.write(key: _kAesKeyPref, value: legacyKey);
      await prefs.remove(_kAesKeyPref);
      debugPrint('[LocalStorage] Migrated AES key to secure storage');
      return SecretKey(base64Decode(legacyKey));
    }

    // 3. First launch: generate a brand-new key.
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
    final Uint8List bytes;
    try {
      bytes = base64Decode(stored.substring(4));
    } catch (e) {
      debugPrint('[LocalStorage] Invalid base64 in encrypted row: $e');
      return stored; // treat as unencrypted
    }
    const nonceLen = 12, macLen = 16;
    if (bytes.length < nonceLen + macLen) {
      debugPrint('[LocalStorage] Encrypted row too short (${bytes.length} bytes)');
      return stored;
    }
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

  /// Load a page of messages using cursor-based pagination (O(log N) via index).
  ///
  /// [beforeTimestamp] — if non-null, only returns messages with
  /// `timestamp < beforeTimestamp` (cursor-based, avoids OFFSET scan).
  /// If null, returns the most-recent [pageSize] messages.
  ///
  /// Returns messages in ascending (oldest→newest) order within the page.
  Future<List<Map<String, dynamic>>> loadMessagesPage(
    String roomId, {
    int pageSize = 50,
    int? beforeTimestamp,
  }) async {
    final List<Map<String, dynamic>> rows;
    if (beforeTimestamp != null) {
      // Cursor-based: fetch [pageSize] messages older than the cursor.
      // Uses the idx_messages_room_ts index (room_id, timestamp) — O(log N).
      rows = await _database.rawQuery(
        'SELECT data FROM messages '
        'WHERE room_id = ? AND timestamp < ? '
        'ORDER BY timestamp DESC LIMIT ?',
        [roomId, beforeTimestamp, pageSize],
      );
    } else {
      // First page: most recent [pageSize] messages.
      rows = await _database.rawQuery(
        'SELECT data FROM messages '
        'WHERE room_id = ? '
        'ORDER BY timestamp DESC LIMIT ?',
        [roomId, pageSize],
      );
    }
    // Reverse so the caller gets oldest→newest within the page.
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

  // ── Full-text search (decrypt-then-filter) ─────────────────────────────────

  /// Search messages across all rooms or within a specific [roomId].
  ///
  /// Because messages are AES-256-GCM encrypted at rest, SQL LIKE/FTS cannot
  /// be used. Instead, this method loads rows in batches (newest first),
  /// decrypts each, and performs a case-insensitive substring match on the
  /// message text (the `encryptedPayload` field after decryption).
  ///
  /// Messages whose payload starts with `E2EE||` (media/file blobs) are
  /// skipped since they are not human-readable text.
  ///
  /// [onProgress] is called with (scanned, total) so the UI can show a
  /// progress indicator for large histories.
  ///
  /// Returns at most [limit] results sorted by timestamp descending.
  Future<List<({String roomId, Map<String, dynamic> message})>> searchMessages(
    String query, {
    String? roomId,
    int limit = 50,
    void Function(int scanned, int total)? onProgress,
  }) async {
    if (query.isEmpty) return [];
    final queryLower = query.toLowerCase();
    final db = _database;

    // Get total count for progress reporting.
    final countResult = roomId != null
        ? await db.rawQuery(
            'SELECT COUNT(*) AS cnt FROM messages WHERE room_id = ?',
            [roomId])
        : await db.rawQuery('SELECT COUNT(*) AS cnt FROM messages');
    final total = (countResult.first['cnt'] as int?) ?? 0;
    if (total == 0) return [];

    final results = <({String roomId, Map<String, dynamic> message})>[];
    const batchSize = 200;
    int scanned = 0;

    // Stream through messages in batches (newest first) using OFFSET pagination.
    for (int offset = 0; offset < total && results.length < limit; offset += batchSize) {
      final List<Map<String, dynamic>> rows;
      if (roomId != null) {
        rows = await db.rawQuery(
          'SELECT room_id, data FROM messages '
          'WHERE room_id = ? '
          'ORDER BY timestamp DESC LIMIT ? OFFSET ?',
          [roomId, batchSize, offset],
        );
      } else {
        rows = await db.rawQuery(
          'SELECT room_id, data FROM messages '
          'ORDER BY timestamp DESC LIMIT ? OFFSET ?',
          [batchSize, offset],
        );
      }

      if (rows.isEmpty) break;

      for (final row in rows) {
        scanned++;
        try {
          final plain = await _decrypt(row['data'] as String);
          final msg = jsonDecode(plain) as Map<String, dynamic>;
          final payload = msg['encryptedPayload'] as String? ?? '';

          // Skip media/file payloads and empty messages.
          if (payload.isEmpty || payload.startsWith('E2EE||')) continue;

          if (payload.toLowerCase().contains(queryLower)) {
            results.add((
              roomId: row['room_id'] as String,
              message: msg,
            ));
            if (results.length >= limit) break;
          }
        } catch (e) {
          debugPrint('[Search] Failed to decrypt/parse row: $e');
        }

        // Report progress every 100 rows.
        if (onProgress != null && (scanned % 100 == 0)) {
          onProgress(scanned, total);
        }
      }
    }

    // Final progress callback.
    if (onProgress != null) onProgress(total, total);

    return results;
  }

  // ── Reactions ──────────────────────────────────────────────────────────────

  /// Load all reactions for a room as {msgId: {emoji_senderId, ...}}.
  Future<Map<String, Set<String>>> loadReactions(String roomId) async {
    final rows = await _database.query(
      'reactions',
      columns: ['msg_id', 'emoji', 'sender_id'],
      where: 'room_id = ?',
      whereArgs: [roomId],
    );
    final result = <String, Set<String>>{};
    for (final r in rows) {
      final msgId = r['msg_id'] as String;
      final emoji = r['emoji'] as String;
      final senderId = r['sender_id'] as String;
      result[msgId] ??= {};
      result[msgId]!.add('${emoji}_$senderId');
    }
    return result;
  }

  /// Add a single reaction.
  Future<void> addReaction(String roomId, String msgId, String emoji, String senderId) async {
    await _database.insert(
      'reactions',
      {'room_id': roomId, 'msg_id': msgId, 'emoji': emoji, 'sender_id': senderId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Remove a single reaction.
  Future<void> removeReaction(String roomId, String msgId, String emoji, String senderId) async {
    await _database.delete(
      'reactions',
      where: 'room_id = ? AND msg_id = ? AND emoji = ? AND sender_id = ?',
      whereArgs: [roomId, msgId, emoji, senderId],
    );
  }

  /// Migrate reactions from SharedPreferences to SQLite (one-time on upgrade to v3).
  Future<void> migrateReactionsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('reactions_')).toList();
    if (keys.isEmpty) return;

    final db = _database;
    for (final key in keys) {
      final raw = prefs.getString(key);
      if (raw == null) continue;
      final roomId = key.substring('reactions_'.length);
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final batch = db.batch();
        for (final entry in decoded.entries) {
          final msgId = entry.key;
          final items = (entry.value as List).cast<String>();
          for (final item in items) {
            final underscoreIdx = item.indexOf('_');
            if (underscoreIdx == -1) continue;
            final emoji = item.substring(0, underscoreIdx);
            final senderId = item.substring(underscoreIdx + 1);
            batch.insert(
              'reactions',
              {'room_id': roomId, 'msg_id': msgId, 'emoji': emoji, 'sender_id': senderId},
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
          }
        }
        await batch.commit(noResult: true);
        await prefs.remove(key);
      } catch (e) {
        debugPrint('[LocalStorage] Failed to migrate reactions for $key: $e');
      }
    }
    debugPrint('[LocalStorage] Migrated reactions from ${keys.length} room(s) to SQLite');
  }

  /// Migrate contacts from SharedPreferences to SQLite (one-time on upgrade to v4).
  Future<void> _migrateContactsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('contacts');
    if (raw == null) return;

    List<dynamic> decoded;
    try {
      decoded = jsonDecode(raw) as List<dynamic>;
    } catch (e) {
      debugPrint('[LocalStorage] Failed to parse contacts for migration: $e');
      await prefs.remove('contacts');
      return;
    }

    final db = _database;
    final batch = db.batch();
    for (final item in decoded) {
      try {
        final map = item as Map<String, dynamic>;
        final id = map['id'] as String? ?? '';
        if (id.isEmpty) continue;
        batch.insert(
          'contacts',
          {'id': id, 'data': jsonEncode(map)},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } catch (e) {
        debugPrint('[LocalStorage] Skipping malformed contact during migration: $e');
      }
    }
    await batch.commit(noResult: true);
    await prefs.remove('contacts');
    debugPrint('[LocalStorage] Migrated ${decoded.length} contact(s) from SharedPrefs to SQLite');
  }

  // ── Contacts public CRUD ────────────────────────────────────────────────────

  /// Load all contacts from the database.
  Future<List<Map<String, dynamic>>> loadContacts() async {
    final rows = await _database.query('contacts');
    final result = <Map<String, dynamic>>[];
    for (final row in rows) {
      try {
        final map = jsonDecode(row['data'] as String) as Map<String, dynamic>;
        result.add(map);
      } catch (e) {
        debugPrint('[LocalStorage] Skipping malformed contact row: $e');
      }
    }
    return result;
  }

  /// Upsert (insert or replace) a single contact by its [id].
  Future<void> saveContact(String id, Map<String, dynamic> data) async {
    await _database.insert(
      'contacts',
      {'id': id, 'data': jsonEncode(data)},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Delete a single contact by [id].
  Future<void> deleteContact(String id) async {
    await _database.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Replace all contacts atomically (used on full re-sync or restore).
  Future<void> saveAllContacts(List<Map<String, dynamic>> contacts) async {
    final db = _database;
    await db.transaction((txn) async {
      await txn.delete('contacts');
      final batch = txn.batch();
      for (final map in contacts) {
        final id = map['id'] as String? ?? '';
        if (id.isEmpty) continue;
        batch.insert(
          'contacts',
          {'id': id, 'data': jsonEncode(map)},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  /// Migrate contact avatars from SharedPreferences to SQLite (one-time on upgrade to v5).
  Future<void> _migrateAvatarsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys()
        .where((k) => k.startsWith('contact_avatar_'))
        .toList();
    if (keys.isEmpty) return;

    final db = _database;
    final batch = db.batch();
    for (final key in keys) {
      final data = prefs.getString(key);
      if (data == null || data.isEmpty) continue;
      final contactId = key.substring('contact_avatar_'.length);
      batch.insert(
        'avatars',
        {'contact_id': contactId, 'data': data},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
    for (final key in keys) {
      await prefs.remove(key);
    }
    debugPrint('[LocalStorage] Migrated ${keys.length} avatar(s) from SharedPrefs to SQLite');
  }

  // ── Avatars public CRUD ─────────────────────────────────────────────────────

  /// Load the base64-encoded avatar for [contactId], or null if not stored.
  Future<String?> loadAvatar(String contactId) async {
    final rows = await _database.query(
      'avatars',
      columns: ['data'],
      where: 'contact_id = ?',
      whereArgs: [contactId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['data'] as String?;
  }

  /// Upsert the base64-encoded avatar for [contactId].
  Future<void> saveAvatar(String contactId, String base64Data) async {
    await _database.insert(
      'avatars',
      {'contact_id': contactId, 'data': base64Data},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Delete the stored avatar for [contactId].
  Future<void> deleteAvatar(String contactId) async {
    await _database.delete(
      'avatars',
      where: 'contact_id = ?',
      whereArgs: [contactId],
    );
  }

  // ── Drafts public CRUD ──────────────────────────────────────────────────────

  /// Load the saved draft for [contactId], or null if none.
  Future<String?> loadDraft(String contactId) async {
    final rows = await _database.query(
      'drafts',
      columns: ['text'],
      where: 'contact_id = ?',
      whereArgs: [contactId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['text'] as String?;
  }

  /// Upsert a draft for [contactId].
  Future<void> saveDraft(String contactId, String text) async {
    await _database.insert(
      'drafts',
      {'contact_id': contactId, 'text': text},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Delete the draft for [contactId].
  Future<void> deleteDraft(String contactId) async {
    await _database.delete(
      'drafts',
      where: 'contact_id = ?',
      whereArgs: [contactId],
    );
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
    await _database.delete(
      'reactions',
      where: 'room_id = ?',
      whereArgs: [roomId],
    );
  }

  /// Wipe the entire messages table (used by panic key / self-destruct).
  Future<void> clearAll() async {
    if (_db == null) return;
    await _database.delete('messages');
    await _database.delete('ttl_pending');
    await _database.delete('reactions');
    await _database.delete('contacts');
    await _database.delete('avatars');
    await _database.delete('drafts');
  }

  // ── Encrypted Backup / Restore ──────────────────────────────────────────────
  //
  // File format (v1 / v2):
  //   [4 bytes magic "PLBK"]
  //   [2 bytes version  LE uint16]
  //   [16 bytes PBKDF2 salt]
  //   [12 bytes AES-GCM IV]
  //   [remaining: AES-256-GCM ciphertext including 16-byte auth tag appended by
  //    the cryptography package]
  //
  // v1 plaintext: UTF-8 JSON array of message objects (messages only).
  // v2 plaintext: UTF-8 JSON object:
  //   {"messages": [...], "contacts": [...], "avatars": [...]}
  //   Messages are decrypted from the device AES key before export, and
  //   re-encrypted under the user's backup password.

  static const _kBackupMagic = [0x50, 0x4C, 0x42, 0x4B]; // "PLBK"
  static const _kBackupVersion = 2;
  static const _kPbkdf2Iterations = 200000; // OWASP 2023
  static const _kPbkdf2KeyLen = 32; // 256-bit
  static const _kSaltLen = 16;
  static const _kIvLen = 12;
  static const _kHeaderLen = 4 + 2 + _kSaltLen + _kIvLen; // 34 bytes

  /// Derive a 256-bit AES key from [password] and [salt] using
  /// PBKDF2-HMAC-SHA256 in an isolate (non-blocking).
  static Future<Uint8List> _deriveBackupKey(String password, Uint8List salt) {
    return compute(_pbkdf2Isolate, {
      'password': password,
      'salt': salt,
    });
  }

  /// Isolate entry point for PBKDF2.
  static Uint8List _pbkdf2Isolate(Map<String, dynamic> params) {
    final password = params['password'] as String;
    final salt = params['salt'] as Uint8List;
    final derivator = pc.PBKDF2KeyDerivator(pc.HMac(pc.SHA256Digest(), 64));
    derivator.init(pc.Pbkdf2Parameters(salt, _kPbkdf2Iterations, _kPbkdf2KeyLen));
    return derivator.process(Uint8List.fromList(utf8.encode(password)));
  }

  /// Export all messages as an AES-256-GCM encrypted backup file.
  ///
  /// Messages are decrypted from the local DB encryption, serialised to JSON,
  /// then re-encrypted under the user-supplied [password].
  /// Returns the encrypted bytes (ready to write to a file), or null on failure.
  /// [onProgress] is called with (processed, total) for UI feedback.
  Future<Uint8List?> exportBackup(
    String password, {
    void Function(int processed, int total)? onProgress,
  }) async {
    try {
      final db = _database;
      final rows = await db.query(
        'messages',
        columns: ['msg_id', 'room_id', 'timestamp', 'data'],
        orderBy: 'room_id, timestamp ASC',
      );

      final total = rows.length;
      final messages = <Map<String, dynamic>>[];

      for (int i = 0; i < rows.length; i++) {
        final row = rows[i];
        try {
          final plainJson = await _decrypt(row['data'] as String);
          messages.add({
            'msg_id': row['msg_id'],
            'room_id': row['room_id'],
            'timestamp': row['timestamp'],
            'data': plainJson,
          });
        } catch (e) {
          debugPrint('[Backup] Skipping corrupt row: $e');
        }
        if (onProgress != null && (i % 100 == 0 || i == total - 1)) {
          onProgress(i + 1, total);
        }
      }

      // Collect contacts and avatars for v2 format
      final contactRows = await db.query('contacts');
      final contacts = contactRows.map((r) {
        try {
          return jsonDecode(r['data'] as String) as Map<String, dynamic>;
        } catch (_) {
          return null;
        }
      }).whereType<Map<String, dynamic>>().toList();

      final avatarRows = await db.query('avatars');
      final avatars = avatarRows.map((r) => <String, dynamic>{
        'contact_id': r['contact_id'],
        'data': r['data'],
      }).toList();

      // Serialise to JSON (v2: object with messages + contacts + avatars)
      final jsonBytes = utf8.encode(jsonEncode({
        'messages': messages,
        'contacts': contacts,
        'avatars': avatars,
      }));

      // Generate salt + IV
      final rng = Random.secure();
      final salt = Uint8List.fromList(
          List.generate(_kSaltLen, (_) => rng.nextInt(256)));
      final iv = Uint8List.fromList(
          List.generate(_kIvLen, (_) => rng.nextInt(256)));

      // Derive key
      final keyBytes = await _deriveBackupKey(password, salt);
      final secretKey = SecretKey(keyBytes);

      // Encrypt with AES-256-GCM
      final secretBox = await _aesGcm.encrypt(
        jsonBytes,
        secretKey: secretKey,
        nonce: iv,
      );

      // Assemble file: magic + version + salt + iv + ciphertext + mac
      final cipherWithMac = [
        ...secretBox.cipherText,
        ...secretBox.mac.bytes,
      ];

      final output = BytesBuilder(copy: false);
      output.add(_kBackupMagic);
      // Version as LE uint16
      output.add([_kBackupVersion & 0xFF, (_kBackupVersion >> 8) & 0xFF]);
      output.add(salt);
      output.add(iv);
      output.add(cipherWithMac);

      return output.toBytes();
    } catch (e, st) {
      debugPrint('[Backup] Export failed: $e\n$st');
      return null;
    }
  }

  /// Import messages from an encrypted backup file.
  ///
  /// Returns the number of imported (new) messages, or -1 on error.
  /// [onProgress] is called with (processed, total) for UI feedback.
  Future<int> importBackup(
    Uint8List data,
    String password, {
    void Function(int processed, int total)? onProgress,
  }) async {
    try {
      // ── Validate header ──
      if (data.length < _kHeaderLen + 16) {
        debugPrint('[Backup] File too small (${data.length} bytes)');
        return -1;
      }
      // Check magic
      for (int i = 0; i < 4; i++) {
        if (data[i] != _kBackupMagic[i]) {
          debugPrint('[Backup] Invalid magic bytes');
          return -1;
        }
      }
      // Check version (accept v1 and v2)
      final version = data[4] | (data[5] << 8);
      if (version != 1 && version != 2) {
        debugPrint('[Backup] Unsupported backup version: $version');
        return -1;
      }

      // ── Extract fields ──
      final salt = Uint8List.sublistView(data, 6, 6 + _kSaltLen);
      final iv = Uint8List.sublistView(data, 6 + _kSaltLen, _kHeaderLen);
      final encryptedPayload = Uint8List.sublistView(data, _kHeaderLen);

      // The encrypted payload is ciphertext + 16-byte GCM tag at the end
      if (encryptedPayload.length < 16) {
        debugPrint('[Backup] Encrypted payload too small');
        return -1;
      }
      final cipherText = Uint8List.sublistView(
          encryptedPayload, 0, encryptedPayload.length - 16);
      final macBytes = Uint8List.sublistView(
          encryptedPayload, encryptedPayload.length - 16);

      // ── Derive key ──
      final keyBytes = await _deriveBackupKey(password, salt);
      final secretKey = SecretKey(keyBytes);

      // ── Decrypt ──
      final secretBox = SecretBox(
        cipherText,
        nonce: iv,
        mac: Mac(macBytes),
      );

      final List<int> plainBytes;
      try {
        plainBytes = await _aesGcm.decrypt(secretBox, secretKey: secretKey);
      } catch (e) {
        debugPrint('[Backup] Decryption failed (wrong password?): $e');
        return -1;
      }

      // ── Parse JSON ──
      // v1: plain array of messages
      // v2: {messages: [...], contacts: [...], avatars: [...]}
      final List<dynamic> messages;
      List<dynamic>? contactsPayload;
      List<dynamic>? avatarsPayload;
      try {
        final decoded = jsonDecode(utf8.decode(plainBytes));
        if (decoded is List) {
          // v1 backup — messages only
          messages = decoded;
        } else if (decoded is Map) {
          // v2 backup
          messages = (decoded['messages'] as List?) ?? [];
          contactsPayload = decoded['contacts'] as List?;
          avatarsPayload = decoded['avatars'] as List?;
        } else {
          debugPrint('[Backup] Unknown payload structure');
          return -1;
        }
      } catch (e) {
        debugPrint('[Backup] JSON parse failed: $e');
        return -1;
      }

      // ── Insert messages with dedup ──
      final db = _database;
      int imported = 0;
      final total = messages.length;

      for (int i = 0; i < messages.length; i++) {
        final entry = messages[i] as Map<String, dynamic>;
        final msgId = entry['msg_id'] as String? ?? '';
        final roomId = entry['room_id'] as String? ?? '';
        final timestamp = entry['timestamp'] as int? ?? 0;
        final plainData = entry['data'] as String? ?? '{}';

        // Check if message already exists (dedup by primary key)
        final existing = await db.query(
          'messages',
          columns: ['msg_id'],
          where: 'msg_id = ? AND room_id = ?',
          whereArgs: [msgId, roomId],
          limit: 1,
        );

        if (existing.isEmpty) {
          // Re-encrypt with the device's DB AES key
          final encrypted = await _encrypt(plainData);
          await db.insert(
            'messages',
            {
              'msg_id': msgId,
              'room_id': roomId,
              'timestamp': timestamp,
              'data': encrypted,
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
          imported++;
        }

        if (onProgress != null && (i % 100 == 0 || i == total - 1)) {
          onProgress(i + 1, total);
        }
      }

      // ── Restore contacts (v2 only, no-clobber) ──
      if (contactsPayload != null) {
        for (final raw in contactsPayload) {
          try {
            final map = raw as Map<String, dynamic>;
            final id = map['id'] as String? ?? '';
            if (id.isEmpty) continue;
            // Only insert if not already present (don't overwrite local edits)
            await db.insert(
              'contacts',
              {'id': id, 'data': jsonEncode(map)},
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
          } catch (e) {
            debugPrint('[Backup] Skipping malformed contact: $e');
          }
        }
      }

      // ── Restore avatars (v2 only, no-clobber) ──
      if (avatarsPayload != null) {
        for (final raw in avatarsPayload) {
          try {
            final entry = raw as Map<String, dynamic>;
            final contactId = entry['contact_id'] as String? ?? '';
            final avatarData = entry['data'] as String? ?? '';
            if (contactId.isEmpty || avatarData.isEmpty) continue;
            await db.insert(
              'avatars',
              {'contact_id': contactId, 'data': avatarData},
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
          } catch (e) {
            debugPrint('[Backup] Skipping malformed avatar: $e');
          }
        }
      }

      debugPrint('[Backup] Imported $imported new messages out of $total total'
          '${contactsPayload != null ? ", ${contactsPayload.length} contact(s)" : ""}'
          '${avatarsPayload != null ? ", ${avatarsPayload.length} avatar(s)" : ""}');
      return imported;
    } catch (e, st) {
      debugPrint('[Backup] Import failed: $e\n$st');
      return -1;
    }
  }
}
