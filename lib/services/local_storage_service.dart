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
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite3/open.dart' as sqlite3_open;
import '../models/channel.dart';
import '../models/channel_post.dart';

/// Top-level ffiInit for Android — called inside the DB isolate.
void _androidFfiInit() {
  sqlite3_open.open.overrideForAll(
      () => DynamicLibrary.open('libsqlcipher.so'));
}

class LocalStorageService {
  static LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  /// Protected constructor for test subclasses.
  @visibleForTesting
  LocalStorageService.forTesting();

  /// Replace the singleton for testing.
  @visibleForTesting
  static void setInstanceForTesting(LocalStorageService instance) =>
      _instance = instance;

  Database? _db;
  SecretKey? _encKey;

  /// Whether FTS5 is available in this SQLite build.
  bool _fts5Available = false;

  /// SQLCipher is always available — bundled via sqlcipher_flutter_libs.
  bool get isSqlcipherAvailable => true;

  static const _kAesKeyPref = 'local_db_aes_key_v1';
  static const _kDbKeyPref = 'local_db_cipher_key_v1';
  static const _kDbKeyTsPref = 'local_db_cipher_key_created_at';
  static const _kDbKeyRotationDays = 365;
  static final _aesGcm = AesGcm.with256bits();

  /// Returns the correct database path for the current platform.
  ///
  /// On Linux/desktop: uses getApplicationSupportDirectory() (~/.local/share/im.pulse.messenger/).
  /// Using getDatabasesPath() stores the DB in .dart_tool/ which flutter clean deletes.
  Future<String> _resolveDbPath() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final appDir = await getApplicationDocumentsDirectory();
      return '${appDir.path}/messages.db';
    } else {
      // Desktop: proper per-app data directory, survives flutter clean and binary moves.
      final appDir = await getApplicationSupportDirectory();
      return '${appDir.path}/messages.db';
    }
  }

  Future<void> init() async {
    // Init encryption key before opening DB (needed for migration).
    _encKey = await _getOrCreateEncKey();

    // Load SQLCipher on all platforms.
    // Android: isolate-safe ffiInit passes libsqlcipher.so override into DB isolate.
    // Linux: SONAME-patched libsqlite3.so.0 in bundle; standard sqfliteFfiInit.
    await _loadSqlcipher();
    if (Platform.isAndroid) {
      databaseFactory = createDatabaseFactoryFfi(ffiInit: _androidFfiInit);
    } else {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final path = await _resolveDbPath();

    // Migrate existing plaintext DB → encrypted DB (first-run only).
    await _migratePlaintextToEncrypted(path);

    final dbKey = await _getOrCreateDbKey();

    _db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 10,
        onConfigure: (db) async {
          await db.rawQuery("PRAGMA KEY=\"x'$dbKey'\"");
          await db.execute('PRAGMA journal_mode=WAL');
          await db.execute('PRAGMA synchronous=NORMAL');
          await db.execute('PRAGMA secure_delete=ON');
          debugPrint('[LocalStorage] SQLCipher: full-DB encryption active (WAL mode)');
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
          await _createFtsTable(db);
          await _createNonceCacheTable(db);
          await _createChannelsTable(db);
          await _createChannelPostsTable(db);
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
          if (oldVersion < 7) {
            await _createFtsTable(db);
          }
          if (oldVersion < 8) {
            await _createNonceCacheTable(db, ifNotExists: true);
          }
          if (oldVersion < 9) {
            await _createChannelsTable(db, ifNotExists: true);
          }
          if (oldVersion < 10) {
            await _createChannelPostsTable(db, ifNotExists: true);
          }
        },
      ),
    );

    // Detect FTS5 availability.
    _fts5Available = await _checkFts5Available();

    // Strip per-row AES-GCM encryption (lazy migration to plaintext within SQLCipher).
    await _migrateToPlaintext();
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

  /// Create the FTS5 virtual table for full-text message search.
  /// Silently skipped if FTS5 is not compiled into this SQLite build.
  static Future<void> _createFtsTable(Database db) async {
    try {
      await db.execute('''
        CREATE VIRTUAL TABLE IF NOT EXISTS messages_fts USING fts5(
          msg_id UNINDEXED,
          room_id UNINDEXED,
          content,
          tokenize='unicode61'
        )
      ''');
      debugPrint('[LocalStorage] FTS5 messages_fts table created');
    } catch (e) {
      // FTS5 extension not available in this SQLite build — search will
      // fall back to SQL LIKE.
      debugPrint('[LocalStorage] FTS5 not available: $e');
    }
  }

  /// Check if FTS5 is available by probing the messages_fts table.
  Future<bool> _checkFts5Available() async {
    try {
      final db = _db;
      if (db == null) return false;
      // If the table exists and is queryable, FTS5 is available.
      await db.rawQuery(
        "SELECT msg_id FROM messages_fts WHERE messages_fts MATCH 'test' LIMIT 1",
      );
      return true;
    } catch (_) {
      return false;
    }
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
  ///
  /// Recovery: if a staging key is present from a previous rotation that
  /// crashed between phases 1 and 3, complete the promotion atomically so
  /// the DB (already re-encrypted with the staging key) remains accessible.
  Future<String> _getOrCreateDbKey() async {
    const ss = FlutterSecureStorage();

    // Recovery: check for an abandoned staging key from a crashed rotation.
    const stagingKey = 'local_db_cipher_key_pending_v1';
    final pendingKey = await ss.read(key: stagingKey);
    if (pendingKey != null) {
      // Crashed during rotation — complete the promotion.
      // Guard: validate hex before interpolating into PRAGMA KEY rawQuery.
      if (!_isValidHex64(pendingKey)) {
        debugPrint('[LocalStorage] Staging key corrupt/invalid — discarding');
        await ss.delete(key: stagingKey);
      } else {
        debugPrint('[LocalStorage] Completing interrupted key rotation from staging key');
        await ss.write(key: _kDbKeyPref, value: pendingKey);
        await ss.delete(key: stagingKey);
        return pendingKey;
      }
    }

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
  ///
  /// Two-phase crash-safe rotation:
  ///   Phase 1 — persist new key to staging slot BEFORE rekeying.
  ///   Phase 2 — re-encrypt the database.
  ///   Phase 3 — promote staging key to primary, clear staging slot.
  /// On recovery, _getOrCreateDbKey() detects an abandoned staging key and
  /// completes the promotion without data loss.
  Future<void> _rotateDbKeyIfNeeded() async {
    try {
      // Guard: abort immediately if DB was closed concurrently (panic wipe).
      final db = _db;
      if (db == null) return;

      const ss = FlutterSecureStorage();
      final tsStr = await ss.read(key: _kDbKeyTsPref);
      // F3-3: If no timestamp recorded, skip rotation — timestamp is written
      // atomically with the key in _getOrCreateDbKey. Missing timestamp means
      // first-launch key generation is incomplete; rotating here would
      // overwrite the key on every subsequent launch.
      if (tsStr == null) return;
      final tsParsed = int.tryParse(tsStr);
      if (tsParsed == null) return; // corrupt timestamp — skip rotation
      final created = DateTime.fromMillisecondsSinceEpoch(tsParsed);
      final age = DateTime.now().difference(created).inDays;
      if (age < _kDbKeyRotationDays) return;
      // Generate new key.
      final rng = Random.secure();
      final newBytes = List.generate(32, (_) => rng.nextInt(256));
      final newKey = newBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

      const stagingKey = 'local_db_cipher_key_pending_v1';
      // Phase 1: persist new key to staging slot BEFORE rekeying.
      await ss.write(key: stagingKey, value: newKey);

      // Phase 2: re-encrypt the database.
      // Guard: abort if DB was closed between phase 1 and now (panic wipe).
      if (_db == null) {
        debugPrint('[LocalStorage] DB closed during key rotation — aborting');
        return;
      }
      // F3-2: Checkpoint WAL before rekeying. SQLCipher encrypts WAL frames
      // with the current key; frames written before the rekey but not yet
      // checkpointed would be encrypted with the old key, causing read
      // inconsistency when opened with the new key.
      await db.rawQuery('PRAGMA wal_checkpoint(TRUNCATE)');
      await db.rawQuery("PRAGMA rekey=\"x'$newKey'\"");
      // Checkpoint again after rekey to ensure new WAL frames use new key.
      await db.rawQuery('PRAGMA wal_checkpoint(TRUNCATE)');

      // Phase 3: promote staging → primary, clear staging.
      await ss.write(key: _kDbKeyPref, value: newKey);
      await ss.delete(key: stagingKey);
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
    final existingKey = await ss.read(key: _kDbKeyPref);
    final hasKey = existingKey != null && _isValidHex64(existingKey);
    if (hasKey) {
      // Verify the key actually opens the DB (guard against crash mid-migration
      // where the key was written but the DB was not yet re-encrypted).
      try {
        final testDb = await databaseFactory.openDatabase(
          path,
          options: OpenDatabaseOptions(
            onConfigure: (db) async {
              await db.rawQuery("PRAGMA KEY=\"x'$existingKey'\"");
            },
            onOpen: (db) async {
              await db.rawQuery('SELECT count(*) FROM sqlite_master');
            },
          ),
        );
        await testDb.close();
        return; // DB opens fine with the key — migration already complete
      } catch (_) {
        // Key present but DB not openable with it — fall through to re-migrate.
        debugPrint('[LocalStorage] Migration sentinel present but DB unreadable — re-migrating');
      }
    }

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
            version: 7,
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
              await _createFtsTable(db);
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
      final bak = File('$path.plaintext.bak');
      if (bak.existsSync() && !file.existsSync()) {
        // Encrypted DB was never created — restore the plaintext backup.
        await bak.rename(path);
      } else if (bak.existsSync()) {
        // Encrypted DB exists (partial/failed migration) but plaintext backup
        // is no longer needed.  Delete it — never leave plaintext data on disk.
        try { await bak.delete(); } catch (_) {}
      }
      // Also clean up any side-file backups.
      for (final suffix in ['-journal', '-wal', '-shm']) {
        final sf = File('$path$suffix.bak');
        try { if (sf.existsSync()) await sf.delete(); } catch (_) {}
      }
      // Remove the cipher key so next run doesn't try to use it on a plaintext DB.
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

  // Keep for backward compat — may be needed for backup re-encryption.
  // ignore: unused_element
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

  /// Read stored data with backward compatibility: tries plaintext JSON first,
  /// falls back to AES-GCM decryption for legacy `ENC:` rows.
  Future<String> _readData(String stored) async {
    if (!stored.startsWith('ENC:')) return stored; // plaintext (new format)
    return _decrypt(stored); // legacy AES-GCM encrypted row
  }

  /// Strips per-row AES-GCM encryption from all rows, storing plaintext JSON
  /// directly (SQLCipher provides file-level encryption). Also populates the
  /// FTS5 index for migrated rows.
  Future<void> _migrateToPlaintext() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('fts_migration_done') == true) return;
    final db = _db!;
    final rows = await db.query('messages', columns: ['msg_id', 'room_id', 'data']);
    int migrated = 0;
    final batch = db.batch();
    final ftsBatch = db.batch();
    bool hasFtsBatch = false;
    for (final row in rows) {
      final data = row['data'] as String;
      if (data.startsWith('ENC:')) {
        try {
          final plain = await _decrypt(data);
          batch.update(
            'messages',
            {'data': plain},
            where: 'msg_id = ? AND room_id = ?',
            whereArgs: [row['msg_id'], row['room_id']],
          );
          // Populate FTS index for this row.
          if (_fts5Available) {
            final content = _extractSearchContent(plain);
            if (content.isNotEmpty) {
              ftsBatch.insert('messages_fts', {
                'msg_id': row['msg_id'],
                'room_id': row['room_id'],
                'content': content,
              }, conflictAlgorithm: ConflictAlgorithm.replace);
              hasFtsBatch = true;
            }
          }
          migrated++;
        } catch (e) {
          debugPrint('[LocalStorage] Failed to decrypt row ${row['msg_id']} during migration: $e');
        }
      } else {
        // Already plaintext — ensure it's in the FTS index.
        if (_fts5Available) {
          final content = _extractSearchContent(data);
          if (content.isNotEmpty) {
            ftsBatch.insert('messages_fts', {
              'msg_id': row['msg_id'],
              'room_id': row['room_id'],
              'content': content,
            }, conflictAlgorithm: ConflictAlgorithm.replace);
            hasFtsBatch = true;
          }
        }
      }
    }
    if (migrated > 0) {
      await batch.commit(noResult: true);
      debugPrint('[LocalStorage] Stripped AES-GCM from $migrated row(s) (SQLCipher handles encryption)');
    }
    if (hasFtsBatch) {
      try {
        await ftsBatch.commit(noResult: true);
        debugPrint('[LocalStorage] Populated FTS index for ${rows.length} row(s)');
      } catch (e) {
        debugPrint('[LocalStorage] FTS population failed: $e');
      }
    }
    await prefs.setBool('fts_migration_done', true);
  }

  /// Extract searchable text content from a message JSON string.
  /// Returns empty string for media/file payloads.
  static String _extractSearchContent(String jsonStr) {
    try {
      final msg = jsonDecode(jsonStr) as Map<String, dynamic>;
      final payload = msg['encryptedPayload'] as String? ?? '';
      if (payload.isEmpty || payload.startsWith('E2EE||')) return '';
      return payload;
    } catch (_) {
      return '';
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

  /// Batch-delete all expired TTL messages in a single transaction.
  /// Returns the list of (roomId, msgId) that were deleted so callers can
  /// remove them from in-memory structures.
  Future<List<({String roomId, String msgId})>> deleteExpiredTtlMessages() async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final expired = await _database.query(
      'ttl_pending',
      columns: ['msg_id', 'room_id'],
      where: 'expires_at <= ?',
      whereArgs: [nowMs],
    );
    if (expired.isEmpty) return [];

    final deleted = <({String roomId, String msgId})>[];
    await _database.transaction((txn) async {
      for (final row in expired) {
        final roomId = row['room_id'] as String;
        final msgId = row['msg_id'] as String;
        await txn.delete('messages',
            where: 'room_id = ? AND msg_id = ?', whereArgs: [roomId, msgId]);
        await txn.delete('ttl_pending',
            where: 'room_id = ? AND msg_id = ?', whereArgs: [roomId, msgId]);
        if (_fts5Available) {
          try {
            await txn.delete('messages_fts',
                where: 'room_id = ? AND msg_id = ?', whereArgs: [roomId, msgId]);
          } catch (_) {}
        }
        deleted.add((roomId: roomId, msgId: msgId));
      }
    });
    if (deleted.isNotEmpty) {
      debugPrint('[LocalStorage] Batch-deleted ${deleted.length} expired TTL message(s)');
    }
    return deleted;
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
        final plainJson = jsonEncode(msg);
        batch.insert(
          'messages',
          {
            'msg_id': msg['id'] as String? ?? '',
            'room_id': roomId,
            'timestamp': _tsOf(msg),
            'data': plainJson,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        // Populate FTS index.
        if (_fts5Available) {
          final content = _extractSearchContent(plainJson);
          if (content.isNotEmpty) {
            batch.insert('messages_fts', {
              'msg_id': msg['id'] as String? ?? '',
              'room_id': roomId,
              'content': content,
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
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
  /// Data is stored as plaintext JSON — SQLCipher provides file-level encryption.
  Future<void> saveMessage(String roomId, Map<String, dynamic> message) async {
    final plainJson = jsonEncode(message);
    final msgId = message['id'] as String? ?? '';
    await _database.insert(
      'messages',
      {
        'msg_id': msgId,
        'room_id': roomId,
        'timestamp': _tsOf(message),
        'data': plainJson,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // Update FTS index.
    if (_fts5Available) {
      final content = _extractSearchContent(plainJson);
      if (content.isNotEmpty) {
        try {
          await _database.insert('messages_fts', {
            'msg_id': msgId,
            'room_id': roomId,
            'content': content,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        } catch (e) {
          debugPrint('[LocalStorage] FTS insert failed: $e');
        }
      }
    }
  }

  /// Batch upsert multiple messages in a single transaction.
  /// Significantly faster than calling [saveMessage] in a loop (e.g. marking
  /// all messages as read).
  Future<void> saveMessagesBatch(
      String roomId, List<Map<String, dynamic>> messages) async {
    if (messages.isEmpty) return;
    await _database.transaction((txn) async {
      final batch = txn.batch();
      for (final message in messages) {
        final plainJson = jsonEncode(message);
        final msgId = message['id'] as String? ?? '';
        batch.insert(
          'messages',
          {
            'msg_id': msgId,
            'room_id': roomId,
            'timestamp': _tsOf(message),
            'data': plainJson,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        // Update FTS index.
        if (_fts5Available) {
          final content = _extractSearchContent(plainJson);
          if (content.isNotEmpty) {
            batch.insert('messages_fts', {
              'msg_id': msgId,
              'room_id': roomId,
              'content': content,
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
      }
      await batch.commit(noResult: true);
    });
  }

  /// Delete a single message by id.
  Future<void> deleteMessage(String roomId, String messageId) async {
    await _database.delete(
      'messages',
      where: 'room_id = ? AND msg_id = ?',
      whereArgs: [roomId, messageId],
    );
    // Remove from FTS index.
    if (_fts5Available) {
      try {
        await _database.delete(
          'messages_fts',
          where: 'room_id = ? AND msg_id = ?',
          whereArgs: [roomId, messageId],
        );
      } catch (e) {
        debugPrint('[LocalStorage] FTS delete failed: $e');
      }
    }
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
        final plain = await _readData(r['data'] as String);
        result.add(jsonDecode(plain) as Map<String, dynamic>);
      } catch (e) {
        debugPrint('[LocalStorage] Failed to read row: $e');
      }
    }
    return result;
  }

  /// Re-key all messages from [oldRoomId] to [newRoomId].
  ///
  /// Used by SmartRouter address promotion: when a contact's primary address
  /// changes, message history must follow (room_id = contact.storageKey).
  Future<void> migrateRoomId(String oldRoomId, String newRoomId) async {
    final count = await _database.rawUpdate(
      'UPDATE messages SET room_id = ? WHERE room_id = ?',
      [newRoomId, oldRoomId],
    );
    if (_fts5Available) {
      try {
        await _database.rawUpdate(
          'UPDATE messages_fts SET room_id = ? WHERE room_id = ?',
          [newRoomId, oldRoomId],
        );
      } catch (_) {}
    }
    debugPrint('[LocalStorage] Migrated $count messages: $oldRoomId → $newRoomId');
  }

  /// Efficient row count without loading message data.
  Future<int> countMessages(String roomId) async {
    final result = await _database.rawQuery(
      'SELECT COUNT(*) AS cnt FROM messages WHERE room_id = ?',
      [roomId],
    );
    return result.isEmpty ? 0 : (result.first['cnt'] as int?) ?? 0;
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
        final plain = await _readData(r['data'] as String);
        result.add(jsonDecode(plain) as Map<String, dynamic>);
      } catch (e) {
        debugPrint('[LocalStorage] Failed to read row: $e');
      }
    }
    return result;
  }

  // ── Full-text search ───────────────────────────────────────────────────────

  /// Search messages across all rooms or within a specific [roomId].
  ///
  /// Strategy (in priority order):
  /// 1. **FTS5 MATCH** — O(log N), uses the messages_fts virtual table.
  /// 2. **SQL LIKE** — linear scan but done in-engine (no Dart-side decrypt).
  /// 3. **Decrypt-then-filter** — fallback for any remaining AES-GCM rows.
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
    final db = _database;

    // ── Strategy 1: FTS5 MATCH (fastest) ──
    if (_fts5Available) {
      try {
        final results = await _searchViaFts(db, query, roomId: roomId, limit: limit);
        if (onProgress != null) onProgress(results.length, results.length);
        return results;
      } catch (e) {
        debugPrint('[Search] FTS5 search failed, falling back: $e');
      }
    }

    // ── Strategy 2: SQL LIKE on plaintext data column ──
    // This works for all rows already migrated to plaintext.
    // Legacy ENC: rows won't match LIKE and are handled in strategy 3.
    final results = <({String roomId, Map<String, dynamic> message})>[];
    final escapedQuery = query.replaceAll('%', r'\%').replaceAll('_', r'\_');
    final likePattern = '%"encryptedPayload":"%$escapedQuery%';

    final List<Map<String, dynamic>> likeRows;
    if (roomId != null) {
      likeRows = await db.rawQuery(
        'SELECT room_id, data FROM messages '
        "WHERE room_id = ? AND data NOT LIKE 'ENC:%' AND data LIKE ? ESCAPE '\\' "
        'ORDER BY timestamp DESC LIMIT ?',
        [roomId, likePattern, limit],
      );
    } else {
      likeRows = await db.rawQuery(
        'SELECT room_id, data FROM messages '
        "WHERE data NOT LIKE 'ENC:%' AND data LIKE ? ESCAPE '\\' "
        'ORDER BY timestamp DESC LIMIT ?',
        [likePattern, limit],
      );
    }

    for (final row in likeRows) {
      try {
        final msg = jsonDecode(row['data'] as String) as Map<String, dynamic>;
        final payload = msg['encryptedPayload'] as String? ?? '';
        if (payload.isEmpty || payload.startsWith('E2EE||')) continue;
        // Verify case-insensitive match (SQL LIKE is case-insensitive for ASCII
        // but we want full Unicode support).
        if (payload.toLowerCase().contains(query.toLowerCase())) {
          results.add((roomId: row['room_id'] as String, message: msg));
          if (results.length >= limit) break;
        }
      } catch (e) {
        debugPrint('[Search] Failed to parse plaintext row: $e');
      }
    }

    if (results.length >= limit) {
      if (onProgress != null) onProgress(limit, limit);
      return results;
    }

    // ── Strategy 3: Decrypt-then-filter for any remaining legacy ENC: rows ──
    final queryLower = query.toLowerCase();
    final countResult = roomId != null
        ? await db.rawQuery(
            "SELECT COUNT(*) AS cnt FROM messages WHERE room_id = ? AND data LIKE 'ENC:%'",
            [roomId])
        : await db.rawQuery(
            "SELECT COUNT(*) AS cnt FROM messages WHERE data LIKE 'ENC:%'");
    final encryptedCount = countResult.isEmpty ? 0 : (countResult.first['cnt'] as int?) ?? 0;

    if (encryptedCount > 0) {
      const batchSize = 200;
      int scanned = 0;
      for (int offset = 0; offset < encryptedCount && results.length < limit; offset += batchSize) {
        final List<Map<String, dynamic>> rows;
        if (roomId != null) {
          rows = await db.rawQuery(
            "SELECT room_id, data FROM messages "
            "WHERE room_id = ? AND data LIKE 'ENC:%' "
            'ORDER BY timestamp DESC LIMIT ? OFFSET ?',
            [roomId, batchSize, offset],
          );
        } else {
          rows = await db.rawQuery(
            "SELECT room_id, data FROM messages "
            "WHERE data LIKE 'ENC:%' "
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
            if (payload.isEmpty || payload.startsWith('E2EE||')) continue;
            if (payload.toLowerCase().contains(queryLower)) {
              results.add((roomId: row['room_id'] as String, message: msg));
              if (results.length >= limit) break;
            }
          } catch (e) {
            debugPrint('[Search] Failed to decrypt/parse row: $e');
          }
          if (onProgress != null && (scanned % 100 == 0)) {
            onProgress(scanned, encryptedCount);
          }
        }
      }
    }

    if (onProgress != null) onProgress(results.length, results.length);
    return results;
  }

  /// FTS5-based search. Joins messages_fts with messages to get full data.
  Future<List<({String roomId, Map<String, dynamic> message})>> _searchViaFts(
    Database db,
    String query, {
    String? roomId,
    int limit = 50,
  }) async {
    // Escape FTS5 special characters and wrap each term in double quotes for
    // a phrase-like search.
    final sanitized = query
        .replaceAll('"', '""')
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .map((t) => '"$t"')
        .join(' ');
    if (sanitized.isEmpty) return [];

    final List<Map<String, dynamic>> rows;
    if (roomId != null) {
      rows = await db.rawQuery(
        'SELECT m.room_id, m.data FROM messages_fts f '
        'JOIN messages m ON m.msg_id = f.msg_id AND m.room_id = f.room_id '
        'WHERE f.messages_fts MATCH ? AND f.room_id = ? '
        'ORDER BY m.timestamp DESC LIMIT ?',
        [sanitized, roomId, limit],
      );
    } else {
      rows = await db.rawQuery(
        'SELECT m.room_id, m.data FROM messages_fts f '
        'JOIN messages m ON m.msg_id = f.msg_id AND m.room_id = f.room_id '
        'WHERE f.messages_fts MATCH ? '
        'ORDER BY m.timestamp DESC LIMIT ?',
        [sanitized, limit],
      );
    }

    final results = <({String roomId, Map<String, dynamic> message})>[];
    for (final row in rows) {
      try {
        final plain = await _readData(row['data'] as String);
        final msg = jsonDecode(plain) as Map<String, dynamic>;
        results.add((roomId: row['room_id'] as String, message: msg));
      } catch (e) {
        debugPrint('[Search] FTS result parse failed: $e');
      }
    }
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

  /// Upsert the base64-encoded avatar for [contactId]. Validates that the
  /// payload is real base64 and that the decoded image is at most 512 KiB
  /// — a malicious peer that sent a 32 KiB string of garbage (passing the
  /// dispatcher's wire-size cap) would otherwise pollute the DB and crash
  /// every subsequent base64Decode in the UI.
  Future<void> saveAvatar(String contactId, String base64Data) async {
    if (base64Data.isEmpty) return;
    try {
      final decoded = base64Decode(base64Data);
      if (decoded.length > 512 * 1024) {
        debugPrint('[Storage] Reject avatar: decoded ${decoded.length}B > 512 KiB');
        return;
      }
    } catch (e) {
      debugPrint('[Storage] Reject avatar: not valid base64 ($e)');
      return;
    }
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
    await _database.transaction((txn) async {
      await txn.delete('messages', where: 'room_id = ?', whereArgs: [roomId]);
      await txn.delete('ttl_pending', where: 'room_id = ?', whereArgs: [roomId]);
      await txn.delete('reactions', where: 'room_id = ?', whereArgs: [roomId]);
      if (_fts5Available) {
        try {
          await txn.delete('messages_fts', where: 'room_id = ?', whereArgs: [roomId]);
        } catch (e) {
          debugPrint('[LocalStorage] FTS clear failed: $e');
        }
      }
    });
  }

  /// Close and delete the SQLCipher database file (used by panic key wipe).
  ///
  /// More complete than [clearAll]: removes the file so no ciphertext remains
  /// on disk even if an attacker previously extracted the cipher key from
  /// FlutterSecureStorage (e.g. via ADB backup on an unencrypted device).
  /// Falls back to table-clearing if file deletion fails.
  Future<void> deleteAndClose() async {
    final path = await _resolveDbPath();
    try {
      if (_db != null) {
        await _database.close();
        _db = null;
      }
      final f = File(path);
      if (await f.exists()) await f.delete();
      // Also remove SQLite WAL/SHM side-files left on disk.
      for (final suffix in ['-wal', '-shm']) {
        final side = File('$path$suffix');
        if (await side.exists()) await side.delete();
      }
      debugPrint('[LocalStorage] Database file deleted');
    } catch (e) {
      debugPrint('[LocalStorage] File delete failed, falling back to clearAll: $e');
      await clearAll();
    }
  }

  /// Wipe the entire messages table (used by panic key / self-destruct).
  Future<void> clearAll() async {
    if (_db == null) return;
    await _database.transaction((txn) async {
      await txn.delete('messages');
      await txn.delete('ttl_pending');
      await txn.delete('reactions');
      await txn.delete('contacts');
      await txn.delete('avatars');
      await txn.delete('drafts');
      try {
        await txn.delete('channels');
      } catch (e) {
        debugPrint('[LocalStorage] clearAll: channels delete failed: $e');
      }
      try {
        await txn.delete('channel_posts');
      } catch (e) {
        debugPrint('[LocalStorage] clearAll: channel_posts delete failed: $e');
      }
      // nonce_cache must be wiped so stale nonces don't cause false-positive
      // replay drops after brain-wallet restore with the same Nostr key.
      try {
        await txn.delete('nonce_cache');
      } catch (e) {
        debugPrint('[LocalStorage] clearAll: nonce_cache delete failed: $e');
      }
      if (_fts5Available) {
        try {
          await txn.delete('messages_fts');
        } catch (e) {
          debugPrint('[LocalStorage] FTS clear failed: $e');
        }
      }
    });
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
          final plainJson = await _readData(row['data'] as String);
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
      // Zero plaintext and key material from memory.
      jsonBytes.fillRange(0, jsonBytes.length, 0);
      keyBytes.fillRange(0, keyBytes.length, 0);

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
  /// Returns a record with the number of imported (new) messages and the number
  /// of failed (malformed/skipped) entries. Returns `imported: -1` on total failure.
  /// [onProgress] is called with (processed, total) for UI feedback.
  Future<({int imported, int failed})> importBackup(
    Uint8List data,
    String password, {
    void Function(int processed, int total)? onProgress,
  }) async {
    try {
      // ── Validate header ──
      const maxBackupBytes = 500 * 1024 * 1024; // 500 MB hard cap
      if (data.length > maxBackupBytes) {
        debugPrint('[Backup] File too large (${data.length} bytes > $maxBackupBytes)');
        return (imported: -1, failed: 0);
      }
      if (data.length < _kHeaderLen + 16) {
        debugPrint('[Backup] File too small (${data.length} bytes)');
        return (imported: -1, failed: 0);
      }
      // Check magic
      for (int i = 0; i < 4; i++) {
        if (data[i] != _kBackupMagic[i]) {
          debugPrint('[Backup] Invalid magic bytes');
          return (imported: -1, failed: 0);
        }
      }
      // Check version (accept v1 and v2)
      final version = data[4] | (data[5] << 8);
      if (version != 1 && version != 2) {
        debugPrint('[Backup] Unsupported backup version: $version');
        return (imported: -1, failed: 0);
      }

      // ── Extract fields ──
      final salt = Uint8List.sublistView(data, 6, 6 + _kSaltLen);
      final iv = Uint8List.sublistView(data, 6 + _kSaltLen, _kHeaderLen);
      final encryptedPayload = Uint8List.sublistView(data, _kHeaderLen);

      // The encrypted payload is ciphertext + 16-byte GCM tag at the end
      if (encryptedPayload.length < 16) {
        debugPrint('[Backup] Encrypted payload too small');
        return (imported: -1, failed: 0);
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
        keyBytes.fillRange(0, keyBytes.length, 0);
        return (imported: -1, failed: 0);
      }
      keyBytes.fillRange(0, keyBytes.length, 0);

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
          return (imported: -1, failed: 0);
        }
      } catch (e) {
        debugPrint('[Backup] JSON parse failed: $e');
        return (imported: -1, failed: 0);
      }

      // ── Insert messages with dedup ──
      final db = _database;
      int imported = 0;
      int failedCount = 0;
      final total = messages.length;

      // Batch-insert messages with dedup (use transaction for performance).
      // ConflictAlgorithm.ignore handles duplicate msg_id+room_id at the DB level —
      // no need to pre-fetch all existing IDs into RAM (O(N) heap allocation).
      final importBatch = db.batch();

      for (int i = 0; i < messages.length; i++) {
        try {
          final entry = messages[i] as Map<String, dynamic>;
          final msgId = entry['msg_id'] as String? ?? '';
          final entryRoomId = entry['room_id'] as String? ?? '';
          final timestamp = entry['timestamp'] as int? ?? 0;
          final plainData = entry['data'] as String? ?? '{}';

          if (msgId.isEmpty || entryRoomId.isEmpty) {
            failedCount++;
            debugPrint('[Backup] Skipping entry $i: missing msg_id or room_id');
            continue;
          }

          // Store plaintext — SQLCipher handles file encryption.
          importBatch.insert(
            'messages',
            {
              'msg_id': msgId,
              'room_id': entryRoomId,
              'timestamp': timestamp,
              'data': plainData,
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
          // Populate FTS index.
          if (_fts5Available) {
            final content = _extractSearchContent(plainData);
            if (content.isNotEmpty) {
              importBatch.insert('messages_fts', {
                'msg_id': msgId,
                'room_id': entryRoomId,
                'content': content,
              }, conflictAlgorithm: ConflictAlgorithm.replace);
            }
          }
          imported++;
        } catch (e) {
          failedCount++;
          debugPrint('[Backup] Skipping malformed entry $i: $e');
        }

        if (onProgress != null && (i % 100 == 0 || i == total - 1)) {
          onProgress(i + 1, total);
        }
      }
      await importBatch.commit(noResult: true);

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
          ' ($failedCount failed)'
          '${contactsPayload != null ? ", ${contactsPayload.length} contact(s)" : ""}'
          '${avatarsPayload != null ? ", ${avatarsPayload.length} avatar(s)" : ""}');
      return (imported: imported, failed: failedCount);
    } catch (e, st) {
      debugPrint('[Backup] Import failed: $e\n$st');
      return (imported: -1, failed: 0);
    }
  }

  // ── Channels ─────────────────────────────────────────────────────────────

  static Future<void> _createChannelsTable(Database db,
      {bool ifNotExists = false}) async {
    final q = ifNotExists ? 'IF NOT EXISTS ' : '';
    await db.execute('''
      CREATE TABLE ${q}channels (
        id   TEXT NOT NULL PRIMARY KEY,
        data TEXT NOT NULL
      )
    ''');
  }

  Future<void> saveChannel(Channel channel) async {
    await _database.insert(
      'channels',
      {'id': channel.id, 'data': jsonEncode(channel.toMap())},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Channel>> loadChannels() async {
    final rows = await _database.query('channels');
    final result = <Channel>[];
    for (final row in rows) {
      try {
        final map = jsonDecode(row['data'] as String) as Map<String, dynamic>;
        result.add(Channel.fromMap(map));
      } catch (e) {
        debugPrint('[LocalStorage] Skipping malformed channel row: $e');
      }
    }
    return result;
  }

  Future<void> removeChannel(String id) async {
    await _database.transaction((txn) async {
      await txn.delete('channels', where: 'id = ?', whereArgs: [id]);
      try {
        await txn.delete('channel_posts', where: 'channel_id = ?', whereArgs: [id]);
      } catch (_) {}
    });
  }

  // ── Channel Posts ───────────────────────────────────────────────────────

  static Future<void> _createChannelPostsTable(Database db,
      {bool ifNotExists = false}) async {
    final q = ifNotExists ? 'IF NOT EXISTS ' : '';
    await db.execute('''
      CREATE TABLE ${q}channel_posts (
        id         TEXT NOT NULL,
        channel_id TEXT NOT NULL,
        data       TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        PRIMARY KEY (id, channel_id)
      )
    ''');
    await db.execute(
      'CREATE INDEX ${q}idx_channel_posts_ts ON channel_posts(channel_id, created_at DESC)',
    );
  }

  Future<void> saveChannelPosts(String channelId, List<ChannelPost> posts) async {
    if (posts.isEmpty) return;
    await _database.transaction((txn) async {
      final batch = txn.batch();
      for (final post in posts) {
        batch.insert(
          'channel_posts',
          {
            'id': post.id,
            'channel_id': channelId,
            'data': jsonEncode(post.toJson()),
            'created_at': post.createdAt.millisecondsSinceEpoch ~/ 1000,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<List<ChannelPost>> loadChannelPosts(String channelId, {int limit = 50}) async {
    final rows = await _database.query(
      'channel_posts',
      columns: ['data'],
      where: 'channel_id = ?',
      whereArgs: [channelId],
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return rows.map((r) {
      try {
        return ChannelPost.fromJson(jsonDecode(r['data'] as String));
      } catch (_) {
        return null;
      }
    }).whereType<ChannelPost>().toList();
  }

  Future<void> upsertChannelPost(String channelId, ChannelPost post) async {
    await _database.insert(
      'channel_posts',
      {
        'id': post.id,
        'channel_id': channelId,
        'data': jsonEncode(post.toJson()),
        'created_at': post.createdAt.millisecondsSinceEpoch ~/ 1000,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeChannelPost(String channelId, String postId) async {
    await _database.delete(
      'channel_posts',
      where: 'id = ? AND channel_id = ?',
      whereArgs: [postId, channelId],
    );
  }

  Future<void> deleteChannelPosts(String channelId) async {
    await _database.delete(
      'channel_posts',
      where: 'channel_id = ?',
      whereArgs: [channelId],
    );
  }

  // ── NIP-44 nonce cache ────────────────────────────────────────────────────
  //
  // Persists seen NIP-44 nonces so replay detection survives app restarts.
  // TTL: 2 days — sufficient to cover offline/delayed message delivery while
  // keeping the table small (~few thousand rows for typical usage).

  /// Create the nonce_cache table (and its index) inside [db].
  static Future<void> _createNonceCacheTable(Database db,
      {bool ifNotExists = false}) async {
    final q = ifNotExists ? 'IF NOT EXISTS ' : '';
    await db.execute('''
      CREATE TABLE ${q}nonce_cache (
        conv_key TEXT NOT NULL,
        nonce    TEXT NOT NULL,
        seen_at  INTEGER NOT NULL,
        PRIMARY KEY (conv_key, nonce)
      )
    ''');
    await db.execute(
      'CREATE INDEX ${q}idx_nonce_cache_seen_at ON nonce_cache(seen_at)',
    );
  }

  /// Persist a newly seen NIP-44 nonce. Safe to call fire-and-forget.
  /// Errors are logged and swallowed — replay protection is still provided
  /// by the in-memory cache for the current session.
  Future<void> saveNonce(String convKey, String nonceHex) async {
    final db = _db;
    if (db == null) return;
    try {
      await db.rawInsert(
        'INSERT OR IGNORE INTO nonce_cache(conv_key, nonce, seen_at) VALUES(?,?,?)',
        [convKey, nonceHex, DateTime.now().millisecondsSinceEpoch],
      );
    } catch (e) {
      debugPrint('[LocalStorage] saveNonce error: $e');
    }
  }

  /// Persist a batch of NIP-44 nonces in a single transaction.
  /// Much more efficient than individual [saveNonce] calls when processing
  /// many offline messages at once (e.g. 50 messages → 1 transaction).
  Future<void> saveNonces(List<(String, String)> nonces) async {
    final db = _db;
    if (db == null || nonces.isEmpty) return;
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.transaction((txn) async {
        for (final (convKey, nonceHex) in nonces) {
          await txn.rawInsert(
            'INSERT OR IGNORE INTO nonce_cache(conv_key, nonce, seen_at) VALUES(?,?,?)',
            [convKey, nonceHex, now],
          );
        }
      });
    } catch (e) {
      debugPrint('[LocalStorage] saveNonces batch error: $e');
    }
  }

  /// Load nonces seen within [maxAgeDays] days.
  /// Called on startup to pre-populate the in-memory replay-detection cache.
  Future<List<(String, String)>> loadRecentNonces({int maxAgeDays = 2}) async {
    final db = _db;
    if (db == null) return [];
    try {
      final cutoff = DateTime.now()
          .subtract(Duration(days: maxAgeDays))
          .millisecondsSinceEpoch;
      final rows = await db.rawQuery(
        'SELECT conv_key, nonce FROM nonce_cache WHERE seen_at >= ?',
        [cutoff],
      );
      return rows
          .map((r) => (r['conv_key'] as String, r['nonce'] as String))
          .toList();
    } catch (e) {
      debugPrint('[LocalStorage] loadRecentNonces error: $e');
      return [];
    }
  }

  /// Delete nonces older than [maxAgeDays] days.
  /// Pass maxAgeDays = 0 to delete all nonces (e.g. after security reset).
  Future<void> purgeOldNonces({int maxAgeDays = 2}) async {
    final db = _db;
    if (db == null) return;
    try {
      final int deleted;
      if (maxAgeDays <= 0) {
        deleted = await db.delete('nonce_cache');
      } else {
        final cutoff = DateTime.now()
            .subtract(Duration(days: maxAgeDays))
            .millisecondsSinceEpoch;
        deleted = await db.delete(
          'nonce_cache',
          where: 'seen_at < ?',
          whereArgs: [cutoff],
        );
      }
      if (deleted > 0) debugPrint('[LocalStorage] Purged $deleted old nonces');
    } catch (e) {
      debugPrint('[LocalStorage] purgeOldNonces error: $e');
    }
  }
}
