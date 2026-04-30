part of 'chat_controller.dart';

/// Small auxiliary actions that hung off ChatController as one-method
/// sections. None of them touch a lot of state, so they group cleanly
/// here — pure file split, no behaviour change. ChatController exposes
/// thin delegates so existing call sites are untouched.
class _MessageActions {
  final ChatController _c;
  _MessageActions(this._c);

  Future<void> toggleReaction(Contact contact, String msgId, String emoji) async {
    if (_c._identity == null || _c._selfId.isEmpty) return;
    final storageKey = contact.storageKey;
    final compositeKey = '${emoji}_${_c._selfId}';
    final currentSet = _c._repo.getReactions(storageKey, msgId);
    final senderIds = currentSet[emoji] ?? [];
    final alreadyReacted = senderIds.contains(_c._selfId);

    _c._repo.applyReactionLocally(
        storageKey, msgId, compositeKey, !alreadyReacted);
    if (alreadyReacted) {
      unawaited(LocalStorageService()
          .removeReaction(storageKey, msgId, emoji, _c._selfId)
          .catchError(
              (Object e) => debugPrint('[Chat] removeReaction DB failed: $e')));
    } else {
      unawaited(LocalStorageService()
          .addReaction(storageKey, msgId, emoji, _c._selfId)
          .catchError(
              (Object e) => debugPrint('[Chat] addReaction DB failed: $e')));
    }
    _c._reactionVersions[storageKey] =
        (_c._reactionVersions[storageKey] ?? 0) + 1;
    _c._scheduleNotify();

    if (contact.isGroup) {
      for (final memberId in contact.members) {
        final memberContact = _c._contacts.findById(memberId);
        if (memberContact == null) continue;
        unawaited(_c._broadcaster.sendReactionSignal(
            memberContact, msgId, emoji, _c._selfId,
            remove: alreadyReacted, groupId: contact.id, group: contact));
      }
    } else {
      unawaited(_c._broadcaster.sendReactionSignal(
          contact, msgId, emoji, _c._selfId, remove: alreadyReacted));
    }
  }

  Future<void> editMessage(Contact contact, String msgId, String newText) async {
    if (_c._identity == null) return;
    final storageKey = contact.storageKey;
    final room = _c._repo.getRoomForContact(contact.id);
    if (room == null) return;
    final idx = _c._repo.messageIndexById(contact.id, msgId);
    if (idx == -1) return;
    if (room.messages[idx].senderId != _c._identity!.id) return;
    final updated =
        room.messages[idx].copyWith(encryptedPayload: newText, isEdited: true);
    room.messages[idx] = updated;
    await LocalStorageService().saveMessage(storageKey, updated.toJson());
    _c._editVersions[storageKey] = (_c._editVersions[storageKey] ?? 0) + 1;
    _c._scheduleNotify();
    if (contact.isGroup) {
      unawaited(_c._broadcaster.sendGroupEditSignal(
          contact, msgId, newText, _c._contacts.contacts));
    } else {
      unawaited(_c._broadcaster.sendEditSignal(contact, msgId, newText));
    }
  }

  Future<String?> exportHistory(Contact contact) async {
    final storageKey = contact.storageKey;
    final all = await LocalStorageService().loadMessages(storageKey);
    final myId = _c._identity?.id ?? '';
    final buf = StringBuffer('=== Chat with ${contact.name} ===\n\n');
    for (final m in all) {
      final msg = Message.tryFromJson(m);
      if (msg == null) continue;
      final who = msg.senderId == myId ? 'You' : contact.name;
      final ts = '${msg.timestamp.year}-${msg.timestamp.month.toString().padLeft(2, '0')}-'
          '${msg.timestamp.day.toString().padLeft(2, '0')} '
          '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}';
      final text = MediaService.isMediaPayload(msg.encryptedPayload)
          ? '[Media: ${MediaService.parse(msg.encryptedPayload)?.name ?? 'file'}]'
          : msg.encryptedPayload;
      buf.writeln('[$ts] $who: $text');
    }
    try {
      // Write to app-private documents directory, not world-accessible Downloads.
      final dir = await getApplicationDocumentsDirectory();
      final date = DateTime.now().toIso8601String().substring(0, 10);
      final safeName = contact.name.replaceAll(RegExp(r'[^\w\-. ]'), '_');
      final file = File('${dir.path}/chat_${safeName}_$date.txt');
      await file.writeAsString(buf.toString());
      return file.path;
    } catch (e) {
      debugPrint('[ChatController] exportChatHistory failed: $e');
      return null;
    }
  }
}

/// Peer-to-peer relay URL exchange. Stateless storage — peers gossip
/// learned-good Nostr relays via signal, we cache the union in
/// SharedPreferences for our own pool to use later. Untrusted-peer input
/// so the validation list (no ws://, no loopback, no private IPs, no
/// embedded creds, length cap) is load-bearing.
class _PeerRelayStore {
  static const _prefsKey = 'peer_relays_v1';

  static Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_prefsKey) ?? [];
  }

  static Future<void> save(List<String> relays) async {
    if (relays.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final existing = Set<String>.from(prefs.getStringList(_prefsKey) ?? []);
    const maxUrlLen = 256;
    const maxRelays = 50; // cap total stored peer relays
    final before = existing.length;
    for (final r in relays) {
      if (existing.length >= maxRelays) break;
      // Validate relay URLs received from untrusted peers
      if (r.length > maxUrlLen) continue;
      final uri = Uri.tryParse(r);
      if (uri == null || uri.host.isEmpty) continue;
      if (uri.scheme != 'wss') continue;          // no ws:// cleartext
      if (uri.userInfo.isNotEmpty) continue;       // no embedded credentials
      // Reject loopback and private IP ranges to prevent LAN port-scanning
      final h = uri.host.toLowerCase();
      if (h == 'localhost' || h == '127.0.0.1' || h == '::1') continue;
      if (h.startsWith('10.') ||
          h.startsWith('192.168.') ||
          h.startsWith('169.254.') ||
          RegExp(r'^172\.(1[6-9]|2[0-9]|3[01])\.').hasMatch(h)) {
        continue;
      }
      // 100.64.0.0/10 — Carrier-Grade NAT (RFC 6598)
      if (h.startsWith('100.')) {
        final second = int.tryParse(h.split('.').elementAtOrNull(1) ?? '');
        if (second != null && second >= 64 && second <= 127) continue;
      }
      existing.add(r);
    }
    if (existing.length > before) {
      await prefs.setStringList(_prefsKey, existing.toList());
      debugPrint(
          '[P2P] Learned ${existing.length - before} new relay(s) from peer');
    }
  }
}
