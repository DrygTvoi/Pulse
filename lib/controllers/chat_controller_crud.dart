part of 'chat_controller.dart';

/// Message CRUD + retry + ack / read-receipt handling. Extracted from
/// ChatController so the main file isn't a 6000+ line god class.
///
/// All methods that touch `_repo` rooms, `_retryTimers`, per-message
/// status transitions, and remote-delete/read-receipt delivery live
/// here. The helper holds a private ChatController reference so it can
/// access `_repo`, `_contacts`, `_broadcaster`, `_getContactIndex()`, etc.
class _MessageCrud {
  final ChatController _c;
  _MessageCrud(this._c);

  Future<void> deleteLocalMessage(Contact contact, String messageId) async {
    _c._retryTimers[messageId]?.cancel();
    _c._retryTimers.remove(messageId);
    await _c._repo.deleteMessageFromRoom(contact, messageId);
    _c._scheduleNotify();
  }

  Future<void> deleteMessage(Contact contact, Message message) async {
    debugPrint('[Chat] deleteMessage: msgId=${message.id} senderId=${message.senderId} selfId=${_c._selfId} isGroup=${contact.isGroup}');
    await deleteLocalMessage(contact, message.id);
    // senderId may be identity.id (UUID) or _selfId (pubkey@relay) depending
    // on when the message was created. Accept either.
    final selfBare = _c._selfId.contains('@') ? _c._selfId.split('@').first : _c._selfId;
    final isMine = message.senderId == _c._selfId ||
        message.senderId == _c._identity!.id ||
        message.senderId == selfBare;
    if (!isMine) {
      debugPrint('[Chat] deleteMessage: NOT my message — skip remote delete (senderId=${message.senderId} selfId=${_c._selfId} identityId=${_c._identity!.id})');
      return;
    }
    if (contact.isGroup) {
      unawaited(_c._broadcaster.broadcastGroupDelete(
          contact, message.id, _c._contacts.contacts));
    } else {
      debugPrint('[Chat] deleteMessage: sending 1:1 delete to ${contact.name} (${contact.databaseId})');
      unawaited(_c._broadcaster.sendDeleteSignal(contact, message.id));
    }
  }

  void handleRemoteDelete(String fromId, String msgId, {String? groupId}) {
    debugPrint('[Chat] _handleRemoteDelete: fromId=$fromId msgId=$msgId groupId=$groupId');
    if (groupId != null) {
      final room = _c._repo.getRoomForContact(groupId);
      if (room == null) return;
      final idx = _c._repo.messageIndexById(groupId, msgId);
      if (idx == -1) return;
      Contact? sender;
      for (final c in _c._contacts.contacts) {
        if (c.databaseId == fromId || c.databaseId.split('@').first == fromId.split('@').first) {
          sender = c;
          break;
        }
      }
      final senderId = sender?.id ?? fromId;
      if (room.messages[idx].senderId != senderId) return;
      room.messages.removeAt(idx);
      _c._repo.untrackMessageId(groupId, msgId);
      _c._repo.rebuildPositionIndex(groupId);
      unawaited(LocalStorageService().deleteMessage(room.contact.storageKey, msgId));
      _c._scheduleNotify();
    } else {
      debugPrint('[Chat] _handleRemoteDelete 1:1: scanning ${_c._repo.rooms.length} rooms for fromId=$fromId');
      // Resolve sender via the contact index, which is keyed by every
      // known transport address AND every bare pubkey. This matches even
      // when the delete arrives through a different transport than the
      // one the original message used (contact's databaseId may be Nostr
      // but the delete came via Pulse with an Ed25519 address — the
      // naive string/prefix compare we had before never matched that).
      final idx = _c._getContactIndex();
      final fromBare = fromId.contains('@') ? fromId.split('@').first : fromId;
      final senderContact = idx[fromId]
          ?? idx[fromBare]
          ?? _c._contacts.findByAddress(fromId)
          ?? _c._contacts.findByAddress(fromBare);
      if (senderContact == null) {
        debugPrint('[Chat] _handleRemoteDelete: no contact matches fromId=$fromId');
        return;
      }
      final room = _c._repo.getRoomForContact(senderContact.id);
      if (room == null) {
        debugPrint('[Chat] _handleRemoteDelete: no room for contact ${senderContact.name}');
        return;
      }
      final msgIdx = _c._repo.messageIndexById(senderContact.id, msgId);
      if (msgIdx == -1) {
        debugPrint('[Chat] _handleRemoteDelete: msgId=$msgId NOT found in room (${room.messages.length} msgs)');
        return;
      }
      // Ownership: the delete must come from the same identity that sent
      // the message. Match by any address known to the sender contact —
      // the original msg.senderId may be on a different transport than
      // fromId but both belong to the same Contact record.
      final msg = room.messages[msgIdx];
      final msgBare = msg.senderId.contains('@')
          ? msg.senderId.split('@').first
          : msg.senderId;
      final ownerContact = idx[msg.senderId]
          ?? idx[msgBare]
          ?? _c._contacts.findByAddress(msg.senderId)
          ?? _c._contacts.findByAddress(msgBare);
      if (ownerContact == null || ownerContact.id != senderContact.id) {
        debugPrint('[Chat] _handleRemoteDelete: ownership mismatch — '
            'message owned by ${ownerContact?.name ?? msg.senderId}, '
            'delete came from ${senderContact.name}');
        return;
      }
      room.messages.removeAt(msgIdx);
      _c._repo.untrackMessageId(senderContact.id, msgId);
      _c._repo.rebuildPositionIndex(senderContact.id);
      unawaited(LocalStorageService().deleteMessage(room.contact.storageKey, msgId));
      _c._scheduleNotify();
      debugPrint('[Chat] _handleRemoteDelete: SUCCESS — removed msgId=$msgId from ${senderContact.name}');
    }
  }

  Future<void> markRoomAsRead(Contact contact) async {
    final room = _c._repo.getRoomForContact(contact.id);
    if (room == null) return;
    final updated = <Map<String, dynamic>>[];
    for (int i = 0; i < room.messages.length; i++) {
      final m = room.messages[i];
      if (!m.isRead) {
        room.messages[i] = m.copyWith(isRead: true);
        updated.add(room.messages[i].toJson());
      }
    }
    if (updated.isNotEmpty) {
      unawaited(LocalStorageService().saveMessagesBatch(contact.storageKey, updated));
      _c._scheduleNotify();
      // 1-on-1 only: a group "contact" has no transport addresses of its own
      // (it's a routing aggregate), so sendReadReceipt(group) ends up calling
      // _sendSignalTo with the group's UUID as recipient pubkey — which then
      // fails on every transport ("msg_read to <gid> failed on all
      // transports") and uselessly retries on every relay. Per-message read
      // receipts for groups are sent via sendGroupReadReceipt from
      // _markGroupHistoryRead → handles each sender individually.
      if (!contact.isGroup) {
        unawaited(_c._broadcaster.sendReadReceipt(contact));
      }
    }
    // Reset incremental unread count
    if (_c._unreadCounts.containsKey(contact.id)) {
      _c._unreadCounts[contact.id] = 0;
      if (!_c._unreadChangedCtrl.isClosed) _c._unreadChangedCtrl.add(contact.id);
    }
  }

  Future<void> clearRoomHistory(Contact contact) =>
      _c._repo.clearRoomHistory(contact, onChanged: () { if (!_c._disposed) _c.notifyListeners(); });

  Future<void> retryMessage(Contact contact, Message message) async {
    if (message.status != 'failed') return;
    final room = _c._repo.getRoomForContact(contact.id);
    if (room == null) return;
    room.messages.removeWhere((m) => m.id == message.id);
    _c._repo.untrackMessageId(contact.id, message.id);
    await LocalStorageService().deleteMessage(contact.storageKey, message.id);
    _c._scheduleNotify();
    await _c.sendMessage(contact, message.encryptedPayload, noAutoRetry: true);
  }

  /// Evicts the oldest 100 entries when the map exceeds 500, preventing
  /// unbounded growth if messages are created faster than resolved.
  void pruneRetryTimers() {
    if (_c._retryTimers.length > 500) {
      final keysToRemove = _c._retryTimers.keys.take(100).toList();
      for (final key in keysToRemove) {
        _c._retryTimers[key]?.cancel();
        _c._retryTimers.remove(key);
      }
      debugPrint('[ChatController] Pruned 100 oldest retry timers (was ${_c._retryTimers.length + 100})');
    }
  }

  void scheduleAutoRetry(Contact contact, Message failedMsg) {
    pruneRetryTimers();
    _c._retryTimers[failedMsg.id]?.cancel();
    _c._retryTimers[failedMsg.id] = Timer(const Duration(seconds: 30), () async {
      _c._retryTimers.remove(failedMsg.id);
      try {
        final room = _c._repo.getRoomForContact(contact.id);
        if (room == null) return;
        final idx = _c._repo.messageIndexById(contact.id, failedMsg.id);
        if (idx != -1 && room.messages[idx].status == 'failed') {
          await retryMessage(contact, room.messages[idx]);
        }
      } catch (e) {
        debugPrint('[ChatController] Auto-retry failed for ${failedMsg.id}: $e');
      }
    });
  }

  Future<void> flushFailedMessages() async {
    int count = 0;
    for (final room in _c._repo.rooms) {
      final failed = room.messages.where((m) => m.status == 'failed').toList();
      if (failed.isEmpty) continue;
      for (final msg in failed) {
        if (_c._retryTimers.containsKey(msg.id)) continue;
        count++;
        unawaited(retryMessage(room.contact, msg));
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
    if (count > 0) debugPrint('[Chat] Flushing $count failed message(s) after network change');
  }

  void handleServerAck(String msgId) {
    for (final room in _c._repo.rooms) {
      for (int i = 0; i < room.messages.length; i++) {
        final m = room.messages[i];
        if (m.id != msgId) continue;
        if (m.status == 'sending') {
          room.messages[i] = m.copyWith(status: 'sent');
          unawaited(LocalStorageService().saveMessage(
              room.contact.storageKey, room.messages[i].toJson()));
          debugPrint('[Chat] Server ACK: $msgId → sent');
          _c._scheduleNotify();
        }
        return;
      }
    }
  }

  void handleReadReceipt(String fromId) {
    // O(1) contact lookup via indexed map, then O(1) room lookup.
    final contactIndex = _c._getContactIndex();
    final contact = contactIndex[fromId] ?? contactIndex[fromId.split('@').first];
    if (contact == null) return;
    final room = _c._repo.getRoomForContact(contact.id);
    if (room == null) return;

    final updated = <Map<String, dynamic>>[];
    // Scan newest→oldest: once we hit an already-read message, all older ones
    // should be read too, so we can stop early.
    for (int i = room.messages.length - 1; i >= 0; i--) {
      final m = room.messages[i];
      if (m.status == 'sending' || m.status == 'sent' || m.status == 'delivered') {
        room.messages[i] = m.copyWith(status: 'read');
        updated.add(room.messages[i].toJson());
      } else if (m.status == 'read' && m.senderId == (_c._identity?.id ?? '')) {
        break; // All older outgoing messages should already be read.
      }
    }
    if (updated.isNotEmpty) {
      unawaited(LocalStorageService().saveMessagesBatch(
          room.contact.storageKey, updated));
      _c._scheduleNotify();
    }
  }

  void handleDeliveryAck(String fromId, String msgId, {String? groupId}) {
    bool changed = false;
    final roomsToSearch = groupId != null
        ? [if (_c._repo.getRoomForContact(groupId) != null) _c._repo.getRoomForContact(groupId)!]
        : _c._repo.rooms.where((r) {
            final cId = r.contact.databaseId;
            return cId == fromId || cId.split('@').first == fromId.split('@').first;
          }).toList();

    String resolvedId = fromId;
    if (groupId != null) {
      for (final c in _c._contacts.contacts) {
        if (c.databaseId == fromId || c.databaseId.split('@').first == fromId.split('@').first) {
          resolvedId = c.id;
          break;
        }
      }
    }

    for (final room in roomsToSearch) {
      for (int i = 0; i < room.messages.length; i++) {
        final m = room.messages[i];
        if (m.id != msgId) continue;
        if (groupId != null && !m.deliveredTo.contains(resolvedId)) {
          final newDeliveredTo = [...m.deliveredTo, resolvedId];
          final newStatus = (m.status == 'sending' || m.status == 'sent') ? 'delivered' : m.status;
          room.messages[i] = m.copyWith(status: newStatus, deliveredTo: newDeliveredTo);
          unawaited(LocalStorageService().saveMessage(
              room.contact.storageKey, room.messages[i].toJson()));
          changed = true;
          break;
        }
        if (m.status == 'sending' || m.status == 'sent') {
          room.messages[i] = m.copyWith(status: 'delivered');
          unawaited(LocalStorageService().saveMessage(
              room.contact.storageKey, room.messages[i].toJson()));
          changed = true;
          break;
        }
      }
      if (changed) break;
    }
    if (changed) _c._scheduleNotify();
  }
}
