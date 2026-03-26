import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contact.dart';
import '../models/message.dart';
import '../models/chat_room.dart';
import 'local_storage_service.dart';

/// Holds all in-memory chat state: rooms, pagination cursors, reactions,
/// per-chat TTL settings, and TTL deletion timers.
///
/// NOT a ChangeNotifier — callers supply an [onChanged] callback so that
/// [ChatController] calls [notifyListeners()] at the right time.
class MessageRepository {
  final Map<String, ChatRoom> _chatRooms = {};
  final Map<String, Map<String, Set<String>>> _reactions = {};

  // O(1) message-ID lookup per room (keyed by contact.id)
  final Map<String, Set<String>> _messageIds = {};

  /// Returns true if this message ID already exists in the room.
  bool roomHasMessage(String contactId, String msgId) =>
      _messageIds[contactId]?.contains(msgId) ?? false;

  /// Track a message ID after adding it to a room.
  void trackMessageId(String contactId, String msgId) =>
      (_messageIds[contactId] ??= {}).add(msgId);

  /// Remove a message ID from tracking.
  void untrackMessageId(String contactId, String msgId) =>
      _messageIds[contactId]?.remove(msgId);

  /// Clear all tracked message IDs for a room.
  void clearMessageIds(String contactId) =>
      _messageIds[contactId]?.clear();

  // Pagination state
  static const int historyPageSize = 50;
  final Map<String, int> _historyLoaded = {};
  final Map<String, int?> _oldestTimestamp = {};
  final Map<String, bool> _historyFull = {};
  final Map<String, bool> _loadingMoreHistory = {};

  // Upload progress: msgId → 0.0..1.0
  final Map<String, double> _uploadProgress = {};

  // Per-room TTL cache (seconds, 0 = off)
  final Map<String, int> _chatTtls = {};

  // TTL deletion timers keyed by message ID
  final Map<String, Timer> _ttlTimers = {};

  // ── Accessors ───────────────────────────────────────────────────────────

  ChatRoom? getRoomForContact(String contactId) => _chatRooms[contactId];

  bool containsRoom(String contactId) => _chatRooms.containsKey(contactId);

  Iterable<ChatRoom> get rooms => _chatRooms.values;

  bool hasMoreHistory(String contactId) => _historyFull[contactId] != true;

  bool isLoadingMoreHistory(String contactId) =>
      _loadingMoreHistory[contactId] == true;

  int getChatTtlCached(String contactId) => _chatTtls[contactId] ?? 0;

  double? getUploadProgress(String msgId) => _uploadProgress[msgId];

  void setUploadProgress(String msgId, double progress) =>
      _uploadProgress[msgId] = progress;

  void clearUploadProgress(String msgId) => _uploadProgress.remove(msgId);

  /// Returns an existing room or creates a new empty one.
  ChatRoom getOrCreateRoom(Contact contact) {
    if (!_chatRooms.containsKey(contact.id)) {
      _chatRooms[contact.id] = ChatRoom(
        id: contact.isGroup ? contact.id : contact.databaseId,
        contact: contact,
        messages: [],
        adapterType: contact.isGroup ? 'group' : contact.provider,
        adapterConfig: {},
        updatedAt: DateTime.now(),
      );
    }
    return _chatRooms[contact.id]!;
  }

  /// Creates a room with an explicit id/adapterType (e.g. incoming message).
  ChatRoom getOrCreateRoomWithId(
      Contact contact, String id, String adapterType) {
    if (!_chatRooms.containsKey(contact.id)) {
      _chatRooms[contact.id] = ChatRoom(
        id: id,
        contact: contact,
        messages: [],
        adapterType: adapterType,
        adapterConfig: {},
        updatedAt: DateTime.now(),
      );
    }
    return _chatRooms[contact.id]!;
  }

  // ── History loading ──────────────────────────────────────────────────────

  /// Load persisted message history for a contact's room (latest page).
  Future<void> loadRoomHistory(Contact contact,
      {VoidCallback? onChanged}) async {
    final storageKey = contact.isGroup ? contact.id : contact.databaseId;
    final total = await LocalStorageService().countMessages(storageKey);
    final stored = await LocalStorageService().loadMessagesPage(
      storageKey,
      pageSize: historyPageSize,
    );
    _historyLoaded[contact.id] = stored.length;
    _historyFull[contact.id] = stored.length >= total;
    if (stored.isNotEmpty) {
      final firstTs = stored.first['timestamp'];
      if (firstTs is int) {
        _oldestTimestamp[contact.id] = firstTs;
      } else if (firstTs is String) {
        _oldestTimestamp[contact.id] =
            DateTime.tryParse(firstTs)?.millisecondsSinceEpoch;
      }
    }
    if (stored.isEmpty) return;

    if (!_chatRooms.containsKey(contact.id)) {
      _chatRooms[contact.id] = ChatRoom(
        id: storageKey,
        contact: contact,
        messages: [],
        adapterType: contact.isGroup ? 'group' : contact.provider,
        adapterConfig: {},
        updatedAt: DateTime.now(),
      );
    }
    final room = _chatRooms[contact.id]!;
    for (final m in stored) {
      final msg = Message.tryFromJson(m);
      if (msg == null) continue;
      if (!roomHasMessage(contact.id, msg.id)) {
        room.messages.add(msg);
        trackMessageId(contact.id, msg.id);
      }
    }
    room.messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Fix messages stuck in 'sending' from a crashed session
    bool hadStuck = false;
    for (int i = 0; i < room.messages.length; i++) {
      if (room.messages[i].status == 'sending') {
        room.messages[i] = room.messages[i].copyWith(status: 'failed');
        unawaited(LocalStorageService()
            .saveMessage(storageKey, room.messages[i].toJson()));
        hadStuck = true;
      }
    }
    if (hadStuck) onChanged?.call();

    await loadReactions(storageKey);

    // Load TTL setting and purge expired messages
    final prefs = await SharedPreferences.getInstance();
    final ttlSeconds = prefs.getInt('chat_ttl_${contact.id}') ?? 0;
    _chatTtls[contact.id] = ttlSeconds;
    if (ttlSeconds > 0) {
      final now = DateTime.now();
      room.messages.removeWhere((m) {
        if (m.timestamp.add(Duration(seconds: ttlSeconds)).isBefore(now)) {
          untrackMessageId(contact.id, m.id);
          unawaited(LocalStorageService().deleteMessage(storageKey, m.id));
          return true;
        }
        return false;
      });
    }

    onChanged?.call();
  }

  /// Load the next page of older messages (cursor-based pagination).
  Future<void> loadMoreHistory(Contact contact,
      {VoidCallback? onChanged}) async {
    if (_historyFull[contact.id] == true) return;
    if (_loadingMoreHistory[contact.id] == true) return;

    _loadingMoreHistory[contact.id] = true;
    onChanged?.call();

    try {
      final storageKey = contact.isGroup ? contact.id : contact.databaseId;
      final cursor = _oldestTimestamp[contact.id];
      final older = await LocalStorageService().loadMessagesPage(
        storageKey,
        pageSize: historyPageSize,
        beforeTimestamp: cursor,
      );

      final room = _chatRooms[contact.id];
      if (room != null && older.isNotEmpty) {
        final toInsert = older
            .map((m) => Message.tryFromJson(m))
            .whereType<Message>()
            .where((m) => !roomHasMessage(contact.id, m.id))
            .toList();
        for (final m in toInsert) {
          trackMessageId(contact.id, m.id);
        }
        room.messages.insertAll(0, toInsert);
        _historyLoaded[contact.id] =
            (_historyLoaded[contact.id] ?? 0) + older.length;
        final firstTs = older.first['timestamp'];
        if (firstTs is int) {
          _oldestTimestamp[contact.id] = firstTs;
        } else if (firstTs is String) {
          _oldestTimestamp[contact.id] =
              DateTime.tryParse(firstTs)?.millisecondsSinceEpoch;
        }
      }
      _historyFull[contact.id] = older.length < historyPageSize;
    } finally {
      _loadingMoreHistory[contact.id] = false;
      onChanged?.call();
    }
  }

  Future<void> clearRoomHistory(Contact contact,
      {VoidCallback? onChanged}) async {
    final room = _chatRooms[contact.id];
    if (room == null) return;
    final storageKey = contact.isGroup ? contact.id : contact.databaseId;
    await LocalStorageService().clearHistory(storageKey);
    room.messages.clear();
    clearMessageIds(contact.id);
    onChanged?.call();
  }

  // ── Message CRUD ─────────────────────────────────────────────────────────

  /// Fully delete a message from memory + storage + cancel its TTL timer.
  Future<void> deleteMessageFromRoom(Contact contact, String msgId) async {
    _ttlTimers[msgId]?.cancel();
    _ttlTimers.remove(msgId);
    final room = _chatRooms[contact.id];
    if (room != null) {
      room.messages.removeWhere((m) => m.id == msgId);
      untrackMessageId(contact.id, msgId);
    }
    await LocalStorageService().deleteMessage(contact.storageKey, msgId);
    await LocalStorageService().deleteTtlExpiry(contact.storageKey, msgId);
  }

  /// Cancel only the in-memory TTL timer (does NOT delete from storage).
  void cancelTtlTimer(String msgId) {
    _ttlTimers[msgId]?.cancel();
    _ttlTimers.remove(msgId);
  }

  // ── Reactions ────────────────────────────────────────────────────────────

  /// Returns {emoji: [senderIds]} for a message.
  Map<String, List<String>> getReactions(String storageKey, String msgId) {
    final room = _reactions[storageKey];
    if (room == null) return {};
    final msgReacts = room[msgId];
    if (msgReacts == null) return {};
    final result = <String, List<String>>{};
    for (final key in msgReacts) {
      final idx = key.indexOf('_');
      if (idx == -1) continue;
      final emoji = key.substring(0, idx);
      final senderId = key.substring(idx + 1);
      result[emoji] ??= [];
      result[emoji]!.add(senderId);
    }
    return result;
  }

  /// Toggle reaction in-memory (does NOT persist — caller persists via LocalStorageService).
  bool applyReactionLocally(
      String storageKey, String msgId, String compositeKey, bool add) {
    _reactions[storageKey] ??= {};
    _reactions[storageKey]![msgId] ??= {};
    final set = _reactions[storageKey]![msgId]!;
    if (add) {
      set.add(compositeKey);
      return true;
    } else {
      set.remove(compositeKey);
      return false;
    }
  }

  /// Apply a remotely received reaction (used by SignalDispatcher events).
  void applyRemoteReaction(
      String storageKey, String msgId, String key, bool remove) {
    _reactions[storageKey] ??= {};
    _reactions[storageKey]![msgId] ??= {};
    if (remove) {
      _reactions[storageKey]![msgId]!.remove(key);
    } else {
      _reactions[storageKey]![msgId]!.add(key);
    }
  }

  /// Load reactions from DB into memory.
  Future<void> loadReactions(String storageKey) async {
    try {
      final data = await LocalStorageService().loadReactions(storageKey);
      if (data.isNotEmpty) {
        _reactions[storageKey] ??= {};
        _reactions[storageKey]!.addAll(data);
      }
    } catch (e) {
      debugPrint('[MessageRepository] Failed to load reactions for $storageKey: $e');
    }
  }

  // ── TTL ──────────────────────────────────────────────────────────────────

  void setChatTtl(String contactId, int seconds) =>
      _chatTtls[contactId] = seconds;

  /// Schedule automatic deletion of [msg] after its TTL expires.
  /// [onDeleted] is called after deletion so the caller can call notifyListeners().
  void scheduleTtlDelete(
    Contact contact,
    Message msg,
    int ttlSeconds, {
    required VoidCallback onDeleted,
  }) {
    if (ttlSeconds <= 0) return;
    // Add 0-10% random jitter to TTL to prevent timing analysis
    final jitter = Duration(
        seconds: Random.secure().nextInt((ttlSeconds * 0.1).ceil().clamp(1, 600)));
    // Clamp message timestamp to now: a sender can set a far-future timestamp
    // (e.g. year 2050) to make TTL fire 25+ years later, effectively bypassing
    // the per-room disappearing-message policy. Use now() as a ceiling so the
    // TTL countdown always starts from when we received the message at the latest.
    final effectiveTs = msg.timestamp.isAfter(DateTime.now())
        ? DateTime.now()
        : msg.timestamp;
    final expiresAt = effectiveTs.add(Duration(seconds: ttlSeconds) + jitter);
    final remaining = expiresAt.difference(DateTime.now());
    _ttlTimers[msg.id]?.cancel();
    if (remaining.isNegative) {
      unawaited(deleteMessageFromRoom(contact, msg.id).then((_) => onDeleted()));
      return;
    }
    unawaited(LocalStorageService().saveTtlExpiry(
        contact.storageKey, msg.id, expiresAt.millisecondsSinceEpoch));
    _ttlTimers[msg.id] = Timer(remaining, () {
      _ttlTimers.remove(msg.id);
      unawaited(deleteMessageFromRoom(contact, msg.id).then((_) => onDeleted()));
    });
  }

  /// Restore TTL timers from DB after app restart.
  Future<void> restoreScheduledTtls({required VoidCallback onDeleted}) async {
    final pending = await LocalStorageService().loadAllTtlPending();
    for (final item in pending) {
      final remaining = item.expiresAt.difference(DateTime.now());
      if (remaining.isNegative) {
        await LocalStorageService().deleteMessage(item.roomId, item.msgId);
        await LocalStorageService().deleteTtlExpiry(item.roomId, item.msgId);
        // Remove from in-memory room if already loaded.
        for (final room in _chatRooms.values) {
          if (room.contact.storageKey == item.roomId ||
              room.contact.id == item.roomId) {
            room.messages.removeWhere((m) => m.id == item.msgId);
            untrackMessageId(room.contact.id, item.msgId);
            break;
          }
        }
      } else {
        final roomId = item.roomId;
        final msgId = item.msgId;
        _ttlTimers[msgId]?.cancel();
        _ttlTimers[msgId] = Timer(remaining, () async {
          _ttlTimers.remove(msgId);
          await LocalStorageService().deleteMessage(roomId, msgId);
          await LocalStorageService().deleteTtlExpiry(roomId, msgId);
          for (final room in _chatRooms.values) {
            if (room.contact.storageKey == roomId ||
                room.contact.id == roomId) {
              room.messages.removeWhere((m) => m.id == msgId);
              untrackMessageId(room.contact.id, msgId);
              onDeleted();
              break;
            }
          }
        });
      }
    }
  }

  void dispose() {
    for (final t in _ttlTimers.values) {
      t.cancel();
    }
    _ttlTimers.clear();
  }
}
