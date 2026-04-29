part of 'chat_controller.dart';

/// Disappearing-messages settings + the system-message inserter that
/// surfaces TTL changes (and a few other notices) as in-chat bubbles.
/// `insertSystemMessage` is intentionally public to its caller —
/// non-disappearing call sites in incoming-messages and broadcast
/// delegation reach it via [ChatController._insertSystemMessage].
class _Disappearing {
  final ChatController _c;
  _Disappearing(this._c);

  /// Telegram-style semantics: disappearing messages apply to messages
  /// sent FROM NOW ON — never retroactively. The repository uses the
  /// `chat_ttl_set_at_<id>` timestamp to skip scheduling TTL timers on
  /// pre-existing history.
  Future<void> setChatTtlSeconds(Contact contact, int seconds,
      {bool sendSignal = true, String? changedBy}) async {
    _c._repo.setChatTtl(contact.id, seconds);
    final prefs = await _c._getPrefs();
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    if (seconds == 0) {
      await prefs.remove('chat_ttl_${contact.id}');
    } else {
      await prefs.setInt('chat_ttl_${contact.id}', seconds);
    }
    await prefs.setInt('chat_ttl_set_at_${contact.id}', nowMs);
    _c._repo.setChatTtlSetAt(contact.id, nowMs);
    if (sendSignal) {
      if (contact.isGroup) {
        unawaited(_c._broadcaster
            .broadcastGroupTtl(contact, seconds, _c._contacts.contacts));
      } else {
        unawaited(_c._broadcaster.sendTtlSignal(contact, seconds));
      }
    }
    // Insert a Telegram-style in-chat notice. The local user changing
    // the TTL is `changedBy = null → 'self'`; an inbound ttl_update
    // signal sets `changedBy = peerContactId` so the bubble reads
    // "<peer name> enabled disappearing messages: 1 hour".
    await insertSystemMessage(contact, {
      '_sys': 'ttl_changed',
      'seconds': seconds,
      'by': changedBy ?? 'self',
    });
    _c._scheduleNotify();
  }

  /// Insert a system (informational) message into the room. Persisted
  /// locally so it survives restarts; never sent over the wire — both
  /// sides generate their own copy from the corresponding signal.
  Future<void> insertSystemMessage(
      Contact contact, Map<String, dynamic> sysPayload) async {
    final room = _c._repo.getRoomForContact(contact.id);
    if (room == null) return;
    final selfId = _c._identity?.id ?? '';
    final msg = Message(
      id: ChatController._uuid.v4(),
      senderId: selfId,
      receiverId: contact.id,
      encryptedPayload: jsonEncode(sysPayload),
      timestamp: DateTime.now(),
      adapterType: 'system',
      isRead: true,
      kind: 'system',
    );
    room.messages.add(msg);
    _c._repo.trackMessageId(contact.id, msg.id);
    await LocalStorageService().saveMessage(contact.storageKey, msg.toJson());
  }
}
