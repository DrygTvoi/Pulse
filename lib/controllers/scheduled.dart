part of 'chat_controller.dart';

/// Scheduled message timer + persistence. Pulled out of ChatController
/// (which is 6900+ lines) so the file isn't quite as much of a god
/// class. Lives as a `part of` rather than a separate library so it can
/// touch ChatController's private state (`_identity`, `_repo`,
/// `_retryTimers`, …) without a parallel public surface area.
class _ScheduledMessages {
  final ChatController _c;
  _ScheduledMessages(this._c);

  /// Schedules [text] to be sent to [contact] at [scheduledAt].
  ///
  /// Creates a placeholder [Message] with status `'scheduled'` shown in
  /// the chat UI immediately. The message and its timer are persisted
  /// to SharedPreferences so they survive app restarts (see [restore]).
  Future<void> schedule(Contact contact, String text, DateTime scheduledAt) async {
    if (_c._identity == null) return;
    final room = _c._repo.getOrCreateRoom(contact);
    final msgId = ChatController._uuid.v4();
    final placeholder = Message(
      id: msgId,
      senderId: _c._identity!.id,
      receiverId: contact.id,
      encryptedPayload: text,
      timestamp: DateTime.now(),
      adapterType: contact.isGroup
          ? 'group'
          : contact.provider == 'Nostr'
              ? 'nostr'
              : contact.provider == 'Session'
                  ? 'session'
                  : 'firebase',
      isRead: true,
      status: 'scheduled',
      scheduledAt: scheduledAt,
    );
    room.messages.add(placeholder);
    _c._repo.trackMessageId(contact.id, placeholder.id);
    _c._scheduleNotify();

    final prefs = await _c._getPrefs();
    final storageKey = 'scheduled_${contact.id}';
    List existing;
    try {
      existing = jsonDecode(prefs.getString(storageKey) ?? '[]') as List;
    } catch (e) {
      debugPrint('[Scheduled] Corrupt scheduled list for ${contact.id}: $e');
      existing = [];
    }
    existing.add(placeholder.toJson());
    await prefs.setString(storageKey, jsonEncode(existing));
    _armTimer(contact, placeholder);
  }

  /// Cancels a pending scheduled message identified by [msgId]. Stops
  /// its timer, removes the placeholder from the room, and deletes the
  /// entry from SharedPreferences so it isn't restored on next launch.
  Future<void> cancel(Contact contact, String msgId) async {
    _c._retryTimers[msgId]?.cancel();
    _c._retryTimers.remove(msgId);
    final room = _c._repo.getRoomForContact(contact.id);
    if (room != null) {
      room.messages.removeWhere((m) => m.id == msgId);
      _c._repo.untrackMessageId(contact.id, msgId);
    }
    _c._scheduleNotify();
    final prefs = await _c._getPrefs();
    final storageKey = 'scheduled_${contact.id}';
    List list;
    try {
      list = (jsonDecode(prefs.getString(storageKey) ?? '[]') as List)
          .where((m) => m is Map && m['id'] != msgId)
          .toList();
    } catch (e) {
      debugPrint('[Scheduled] Corrupt scheduled list on cancel for ${contact.id}: $e');
      list = [];
    }
    if (list.isEmpty) {
      await prefs.remove(storageKey);
    } else {
      await prefs.setString(storageKey, jsonEncode(list));
    }
  }

  /// Restores all persisted scheduled messages on init. For each
  /// contact, deserialises the `scheduled_<contactId>` list, adds the
  /// placeholder messages back into their rooms, and re-arms timers.
  Future<void> restore() async {
    final prefs = await _c._getPrefs();
    for (final contact in _c._contacts.contacts) {
      final storageKey = 'scheduled_${contact.id}';
      final raw = prefs.getString(storageKey);
      if (raw == null) continue;
      try {
        final list = jsonDecode(raw) as List;
        for (final item in list) {
          if (item is! Map<String, dynamic>) continue;
          final msg = Message.tryFromJson(item);
          if (msg == null || msg.scheduledAt == null) continue;
          final room = _c._repo.getOrCreateRoom(contact);
          room.messages.add(msg);
          _c._repo.trackMessageId(contact.id, msg.id);
          _armTimer(contact, msg);
        }
      } catch (e) {
        debugPrint('[Scheduled] Restore error for ${contact.id}: $e');
      }
    }
  }

  /// Arms a [Timer] that fires [_fire] when [msg.scheduledAt] arrives.
  /// If the scheduled time is already past (e.g. restored after a long
  /// offline period), the message is fired immediately.
  void _armTimer(Contact contact, Message msg) {
    final delay = msg.scheduledAt!.difference(DateTime.now());
    if (delay.isNegative) {
      unawaited(_fire(contact, msg));
      return;
    }
    _c._pruneRetryTimers();
    _c._retryTimers[msg.id] =
        Timer(delay, () => unawaited(_fire(contact, msg)));
  }

  /// Sends the previously-scheduled [msg] via [sendMessage], removes
  /// the placeholder from the chat room, and cleans up SharedPreferences.
  Future<void> _fire(Contact contact, Message msg) async {
    _c._retryTimers.remove(msg.id);
    final room = _c._repo.getRoomForContact(contact.id);
    if (room != null) {
      room.messages.removeWhere((m) => m.id == msg.id);
      _c._repo.untrackMessageId(contact.id, msg.id);
    }
    final prefs = await _c._getPrefs();
    final storageKey = 'scheduled_${contact.id}';
    List list;
    try {
      list = (jsonDecode(prefs.getString(storageKey) ?? '[]') as List)
          .where((m) => m is Map && m['id'] != msg.id)
          .toList();
    } catch (e) {
      debugPrint('[Scheduled] Corrupt scheduled list on fire for ${contact.id}: $e');
      list = [];
    }
    if (list.isEmpty) {
      await prefs.remove(storageKey);
    } else {
      await prefs.setString(storageKey, jsonEncode(list));
    }
    await _c.sendMessage(contact, msg.encryptedPayload);
  }
}
