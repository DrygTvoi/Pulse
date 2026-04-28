import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// SQLite schema DDL for LocalStorageService. Pulled out of
// local_storage_service.dart so the service file isn't 2000+ lines of
// mixed schema + CRUD + migrations + key management. These are pure
// functions: each takes a [Database] and emits CREATE TABLE / CREATE
// INDEX statements. The `ifNotExists` flag lets the same helper serve
// both `onCreate` (no IF NOT EXISTS — surface bugs immediately) and
// `onUpgrade` paths (idempotent so re-running an upgrade can't fail).

Future<void> createReactionsTable(Database db,
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

Future<void> createContactsTable(Database db,
    {bool ifNotExists = false}) async {
  final q = ifNotExists ? 'IF NOT EXISTS ' : '';
  await db.execute('''
    CREATE TABLE ${q}contacts (
      id   TEXT NOT NULL PRIMARY KEY,
      data TEXT NOT NULL
    )
  ''');
}

Future<void> createAvatarsTable(Database db,
    {bool ifNotExists = false}) async {
  final q = ifNotExists ? 'IF NOT EXISTS ' : '';
  await db.execute('''
    CREATE TABLE ${q}avatars (
      contact_id TEXT NOT NULL PRIMARY KEY,
      data       TEXT NOT NULL
    )
  ''');
}

Future<void> createDraftsTable(Database db,
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
Future<void> createFtsTable(Database db) async {
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

Future<void> createChannelsTable(Database db,
    {bool ifNotExists = false}) async {
  final q = ifNotExists ? 'IF NOT EXISTS ' : '';
  await db.execute('''
    CREATE TABLE ${q}channels (
      id   TEXT NOT NULL PRIMARY KEY,
      data TEXT NOT NULL
    )
  ''');
}

Future<void> createChannelPostsTable(Database db,
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

/// Create the nonce_cache table (and its index) inside [db]. Persists seen
/// NIP-44 nonces so replay detection survives app restarts.
Future<void> createNonceCacheTable(Database db,
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

/// Initial schema for a fresh DB (`onCreate`). Mirrors what `onUpgrade`
/// would build incrementally for a v0→v10 migration. Keep this in sync
/// when adding new tables.
Future<void> createInitialSchema(Database db) async {
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
  await createReactionsTable(db);
  await createContactsTable(db);
  await createAvatarsTable(db);
  await createDraftsTable(db);
  await createFtsTable(db);
  await createNonceCacheTable(db);
  await createChannelsTable(db);
  await createChannelPostsTable(db);
}

/// Stepwise migrations from v1 → current. Each step is idempotent
/// (`ifNotExists`) so a DB at v3 upgrading to v10 runs steps 4..10 cleanly
/// and skips 1..3 even though the helpers are technically defensive.
Future<void> runSchemaUpgrades(Database db, int oldVersion) async {
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
  if (oldVersion < 3) await createReactionsTable(db, ifNotExists: true);
  if (oldVersion < 4) await createContactsTable(db, ifNotExists: true);
  if (oldVersion < 5) await createAvatarsTable(db, ifNotExists: true);
  if (oldVersion < 6) await createDraftsTable(db, ifNotExists: true);
  if (oldVersion < 7) await createFtsTable(db);
  if (oldVersion < 8) await createNonceCacheTable(db, ifNotExists: true);
  if (oldVersion < 9) await createChannelsTable(db, ifNotExists: true);
  if (oldVersion < 10) await createChannelPostsTable(db, ifNotExists: true);
}
