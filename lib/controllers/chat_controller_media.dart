part of 'chat_controller.dart';

/// Smart media routing — file, voice, and video-note sending with a
/// 3-tier fallback pipeline: P2P DataChannel → Blossom HTTPS → relay
/// chunks. Extracted from ChatController so the main file doesn't
/// carry every media-transfer method inline.
///
/// State (`_pendingSends`, `_uuid`, `_inlineThreshold`, …) stays on
/// ChatController; the helper accesses it via `_c._field`.
class _MediaSender {
  final ChatController _c;
  _MediaSender(this._c);

  Future<void> sendFile(Contact contact, Uint8List bytes, String name,
      {String mediaType = 'file'}) async {
    if (_c._identity == null) return;

    // Tier 0: small files (<8KB) go inline as a single message.
    if (bytes.length < ChatController._inlineThreshold) {
      await _c.sendMessage(contact, MediaService.chunkPayloads(bytes, name, mediaType: mediaType).first);
      return;
    }

    // Tier 1: P2P DataChannel — direct transfer if already connected (1-on-1 only).
    if (!contact.isGroup && P2PTransportService.instance.isConnected(contact.id)) {
      final ok = await _sendViaP2PBinary(contact, bytes, name, mediaType);
      if (ok) return;
    }

    // Tier 2: Blossom — HTTPS upload, works behind any NAT (1-on-1 + groups).
    if (BlossomService.instance.isAvailable) {
      final ok = await _sendViaBlossom(contact, bytes, name, mediaType);
      if (ok) return;
    }

    // Tier 3: relay chunks — last resort (floods relay with binary events).
    await _sendViaRelayChunks(contact, bytes, name, mediaType: mediaType);
  }

  /// Send a voice message using a 3-tier routing strategy:
  /// 1. Inline (single NIP-44 event) for short clips — full waveform preserved.
  /// 2. P2P DataChannel if connected (1-on-1 only).
  /// 3. Blossom HTTPS upload (works behind any NAT, 1-on-1 + groups).
  /// 4. Relay chunks as last resort (8 KB each, well within NIP-44 limit).
  ///
  /// OPUS inline threshold: 34 KB JSON (≈ 8–10 s at 24 kbps) — safely fits
  /// through double NIP-44 Gift Wrap (max ~36 KB raw before hitting 65535).
  /// WAV inline threshold: 6 KB (gzip-compressed short clips only).
  Future<bool> sendVoice(Contact contact, Uint8List audioBytes, int durationSeconds,
      List<double> amplitudes) async {
    if (_c._identity == null) return false;

    // Detect format from magic bytes.
    // OggS (4F 67 67 53) = OPUS; ftyp at offset 4 (66 74 79 70) = AAC/M4A; else WAV.
    final bool isCompressed;
    final String encField;
    final String fileExt;
    if (audioBytes.length >= 4 &&
        audioBytes[0] == 0x4F && audioBytes[1] == 0x67 &&
        audioBytes[2] == 0x67 && audioBytes[3] == 0x53) {
      isCompressed = true; encField = 'opus'; fileExt = 'opus';
    } else if (audioBytes.length >= 8 &&
        audioBytes[4] == 0x66 && audioBytes[5] == 0x74 &&
        audioBytes[6] == 0x79 && audioBytes[7] == 0x70) {
      isCompressed = true; encField = 'aac'; fileExt = 'm4a';
    } else {
      isCompressed = false; encField = 'wav'; fileExt = 'wav';
    }

    final ampInt = amplitudes.map((v) => (v * 100).round()).toList();
    final String payload;
    if (isCompressed) {
      final b64 = base64Encode(audioBytes);
      payload = jsonEncode({
        't': 'voice', 'd': b64, 'dur': durationSeconds,
        'sz': audioBytes.length, 'amp': ampInt, 'enc': encField,
      });
    } else {
      final compressed = gzip.encode(audioBytes);
      final b64 = base64Encode(compressed);
      payload = jsonEncode({
        't': 'voice', 'd': b64, 'dur': durationSeconds,
        'sz': audioBytes.length, 'amp': ampInt, 'z': true,
      });
    }

    final payloadBytes = utf8.encode(payload).length;
    // Inline threshold: NIP-44 double gift-wrap expands payload ~2.7×; nos.lol
    // hard-rejects events > 65535 bytes. 20 KB payload → ~55 KB final event (safe).
    // Larger messages go via Blossom (single HTTP upload, no size limit).
    final inlineLimit = isCompressed ? 20000 : 6000;
    if (payloadBytes <= inlineLimit) {
      await _c.sendMessage(contact, payload);
      return true;
    }

    // Large voice — show locally as a full voice bubble, then route via tiers.
    final isGroup = contact.isGroup;
    final room = _c._repo.getOrCreateRoom(contact);
    final msgId = ChatController._uuid.v4();
    final localMsg = Message(
      id: msgId,
      senderId: _c._identity!.id,
      receiverId: contact.id,
      encryptedPayload: payload,
      timestamp: DateTime.now(),
      adapterType: isGroup ? 'group' : (contact.provider == 'Nostr' ? 'nostr' : 'firebase'),
      isRead: true,
      status: 'sending',
    );
    room.messages.add(localMsg);
    _c._repo.trackMessageId(contact.id, localMsg.id);
    final localTtl = _c._repo.getChatTtlCached(contact.id);
    if (localTtl > 0) _c._repo.scheduleTtlDelete(contact, localMsg, localTtl,
        onDeleted: () { if (!_c._disposed) _c._scheduleNotify(); });
    _c._scheduleNotify();

    final voiceName = 'voice_${durationSeconds}s.$fileExt';

    // Tier 1: Blossom HTTPS upload.
    if (BlossomService.instance.isAvailable) {
      room.messages.removeWhere((m) => m.id == msgId);
      _c._scheduleNotify();
      final ok = await _sendViaBlossom(contact, audioBytes, voiceName, 'voice');
      if (ok) return true;
      // Re-add local placeholder for relay chunk fallback.
      room.messages.add(localMsg);
      _c._scheduleNotify();
    }

    // Tier 3: relay chunks (8 KB each — always fits NIP-44).
    bool allSent = true;
    try {
      _c._repo.setUploadProgress(msgId, 0.0);
      final chunks = MediaService.chunkPayloads(audioBytes, voiceName, mediaType: 'voice');
      int i = 0;
      for (final chunk in chunks) {
        final bool ok;
        if (isGroup) {
          ok = await _sendGroupChunk(contact, chunk);
        } else {
          ok = await _c._sendToContact(contact, chunk);
        }
        if (!ok) { allSent = false; break; }
        i++;
        _c._repo.setUploadProgress(msgId, i / chunks.length);
        _c._scheduleNotify();
      }
    } catch (e) {
      debugPrint('[Voice] sendVoice chunk loop error: $e');
      allSent = false;
    } finally {
      _c._repo.clearUploadProgress(msgId);
    }

    final idx = _c._repo.messageIndexById(contact.id, msgId);
    final finalMsg = localMsg.copyWith(status: allSent ? 'sent' : 'failed');
    if (idx >= 0) room.messages[idx] = finalMsg;
    unawaited(LocalStorageService().saveMessage(contact.id, finalMsg.toJson()));
    _c._scheduleNotify();
    return allSent;
  }

  /// Send a video note (circle). Small recordings go inline; larger ones
  /// route through the 3-tier media pipeline (P2P → Blossom → relay chunks).
  Future<void> sendVideoNote(Contact contact, Uint8List mp4Bytes,
      int durationSeconds, Uint8List? thumbnailJpeg) async {
    if (_c._identity == null) return;
    final thumbB64 = thumbnailJpeg != null ? base64Encode(thumbnailJpeg) : null;
    final b64 = base64Encode(mp4Bytes);
    final payload = jsonEncode({
      't': 'video_note',
      'd': b64,
      'dur': durationSeconds,
      'sz': mp4Bytes.length,
      'n': 'video_note.mp4',
      if (thumbB64 != null) 'thumb': thumbB64,
    });
    final payloadBytes = utf8.encode(payload).length;
    // Small video notes: send inline (under NIP-44 limit after Gift Wrap)
    if (payloadBytes <= 6000) {
      await _c.sendMessage(contact, payload);
      return;
    }
    // Large video notes: show locally with full payload, send via media pipeline
    final isGroup = contact.isGroup;
    final room = _c._repo.getOrCreateRoom(contact);
    final msgId = ChatController._uuid.v4();
    final localMsg = Message(
      id: msgId,
      senderId: _c._identity!.id,
      receiverId: contact.id,
      encryptedPayload: payload,
      timestamp: DateTime.now(),
      adapterType: isGroup ? 'group' : (contact.provider == 'Nostr' ? 'nostr' : 'firebase'),
      isRead: true,
      status: 'sending',
    );
    room.messages.add(localMsg);
    _c._repo.trackMessageId(contact.id, localMsg.id);
    final localTtl = _c._repo.getChatTtlCached(contact.id);
    if (localTtl > 0) _c._repo.scheduleTtlDelete(contact, localMsg, localTtl,
        onDeleted: () { if (!_c._disposed) _c._scheduleNotify(); });
    _c._scheduleNotify();

    // Route through sendFile's 3-tier pipeline (P2P → Blossom → relay chunks)
    // We mark the local message first, then delegate the actual send.
    _c._repo.setUploadProgress(msgId, 0.0);
    bool sent = false;

    // Tier 1: P2P
    if (!isGroup && P2PTransportService.instance.isConnected(contact.id)) {
      sent = await _sendViaP2PBinary(contact, mp4Bytes, 'video_note.mp4', 'video_note');
    }

    // Tier 2: Blossom
    if (!sent && BlossomService.instance.isAvailable) {
      // Remove the local placeholder (Blossom creates its own)
      room.messages.removeWhere((m) => m.id == msgId);
      _c._scheduleNotify();
      sent = await _sendViaBlossom(contact, mp4Bytes, 'video_note.mp4', 'video_note');
      if (sent) {
        _c._repo.clearUploadProgress(msgId);
        return;
      }
      // Re-add local placeholder for relay chunk fallback
      room.messages.add(localMsg);
      _c._scheduleNotify();
    }

    // Tier 3: relay chunks
    if (!sent) {
      final chunks = MediaService.chunkPayloads(mp4Bytes, 'video_note.mp4',
          mediaType: 'video_note');
      int i = 0;
      bool allSent = true;
      for (final chunk in chunks) {
        final bool ok;
        if (isGroup) {
          ok = await _sendGroupChunk(contact, chunk);
        } else {
          ok = await _c._sendToContact(contact, chunk);
        }
        if (!ok) { allSent = false; break; }
        i++;
        _c._repo.setUploadProgress(msgId, i / chunks.length);
        _c._scheduleNotify();
      }
      sent = allSent;
    }

    _c._repo.clearUploadProgress(msgId);
    final idx = _c._repo.messageIndexById(contact.id, msgId);
    final finalMsg = localMsg.copyWith(status: sent ? 'sent' : 'failed');
    if (idx >= 0) room.messages[idx] = finalMsg;
    final storageKey = isGroup ? contact.id : contact.storageKey;
    unawaited(LocalStorageService().saveMessage(storageKey, finalMsg.toJson()));
    _c._scheduleNotify();
  }

  /// Tier 2: Encrypt, upload to Blossom, send metadata message.
  /// Works for both 1-on-1 and group chats. For groups: upload once,
  /// send E2EE blossom payload (with AES key) to each member individually.
  Future<bool> _sendViaBlossom(Contact contact, Uint8List bytes, String name,
      String mediaType) async {
    final isGroup = contact.isGroup;
    final room = _c._repo.getOrCreateRoom(contact);
    final msgId = ChatController._uuid.v4();

    // Generate thumbnail for images/gifs
    String? thumbnail;
    if (mediaType == 'img' || mediaType == 'gif') {
      try {
        thumbnail = await compute(_generateThumbnailIsolate, bytes);
      } catch (e) {
        debugPrint('[Blossom] Thumbnail generation failed: $e');
      }
    }

    // Show sending state immediately
    final displayPayload = BlossomPayloadHelpers.buildBlossomPayload(
      hash: '', server: '', key: '', iv: '',
      name: name, size: bytes.length, mediaType: mediaType, thumbnail: thumbnail,
    );
    final localMsg = Message(
      id: msgId,
      senderId: _c._identity!.id,
      receiverId: contact.id,
      encryptedPayload: displayPayload,
      timestamp: DateTime.now(),
      adapterType: isGroup ? 'group' : (contact.provider == 'Nostr' ? 'nostr' : 'firebase'),
      isRead: true,
      status: 'sending',
    );
    room.messages.add(localMsg);
    _c._repo.trackMessageId(contact.id, localMsg.id);
    _c._repo.setUploadProgress(msgId, 0.1);
    _c._scheduleNotify();

    try {
      // Encrypt
      final enc = MediaCryptoService.encrypt(bytes);
      _c._repo.setUploadProgress(msgId, 0.3);
      _c._scheduleNotify();

      // Upload
      final result = await BlossomService.instance.upload(enc.ciphertext);
      if (result == null) {
        _c._repo.clearUploadProgress(msgId);
        // Remove sending placeholder — will fall back to relay chunks
        room.messages.removeWhere((m) => m.id == msgId);
        _c._scheduleNotify();
        return false;
      }
      _c._repo.setUploadProgress(msgId, 0.8);
      _c._scheduleNotify();

      // Build payload with key material
      final payload = BlossomPayloadHelpers.buildBlossomPayload(
        hash: result.hash,
        server: result.server,
        key: base64Encode(enc.key),
        iv: base64Encode(enc.iv),
        name: name,
        size: bytes.length,
        mediaType: mediaType,
        thumbnail: thumbnail,
      );

      // Send via E2EE — group: wrap in _group and send to each member
      bool sent = false;
      if (isGroup) {
        final groupPayload = jsonEncode({'_group': contact.id, 'text': payload});
        final isPulseRouted =
            contact.isPulseGroup && contact.groupServerUrl.isNotEmpty;
        if (isPulseRouted) {
          await _c.ensureGroupPulseConnection(contact.groupServerUrl);
        }
        int membersSent = 0;
        for (final memberId in contact.members) {
          final memberContact = _c._contacts.findById(memberId);
          if (memberContact == null) continue;
          final ok = isPulseRouted
              ? await _c._sendToContactViaPulseServer(
                  memberContact, groupPayload, contact.groupServerUrl)
              : await _c._sendToContact(memberContact, groupPayload);
          if (ok) membersSent++;
        }
        sent = membersSent > 0;
      } else {
        sent = await _c._sendToContact(contact, payload);
      }

      final idx = _c._repo.messageIndexById(contact.id, msgId);
      final finalMsg = localMsg.copyWith(
        encryptedPayload: payload,
        status: sent ? 'sent' : 'failed',
      );
      if (idx != -1) room.messages[idx] = finalMsg;
      final storageKey = isGroup ? contact.id : contact.storageKey;
      await LocalStorageService().saveMessage(storageKey, finalMsg.toJson());
      _c._repo.clearUploadProgress(msgId);
      final localTtl = _c._repo.getChatTtlCached(contact.id);
      if (localTtl > 0) _c._repo.scheduleTtlDelete(contact, finalMsg, localTtl, onDeleted: () { if (!_c._disposed) _c._scheduleNotify(); });
      _c._scheduleNotify();
      return sent;
    } catch (e) {
      debugPrint('[Blossom] _sendViaBlossom error: $e');
      _c._repo.clearUploadProgress(msgId);
      room.messages.removeWhere((m) => m.id == msgId);
      _c._scheduleNotify();
      return false;
    }
  }

  /// Tier 1: Send file directly via P2P DataChannel binary frames.
  Future<bool> _sendViaP2PBinary(Contact contact, Uint8List bytes,
      String name, String mediaType) async {
    const chunkSize = 64 * 1024; // 64KB P2P frames
    final total = (bytes.length / chunkSize).ceil();
    final fid = ChatController._uuid.v4();
    final fh = hash_lib.sha256.convert(bytes).toString();

    // Send header as text message
    final header = jsonEncode({
      'p2p_file': true,
      'fid': fid,
      'n': name,
      'sz': bytes.length,
      'mt': mediaType,
      'total': total,
      'fh': fh,
    });
    if (!P2PTransportService.instance.send(contact.id, header)) return false;

    final room = _c._repo.getOrCreateRoom(contact);
    final msgId = ChatController._uuid.v4();
    final displayPayload = jsonEncode({'t': mediaType, 'n': name, 'sz': bytes.length, 'd': ''});
    final localMsg = Message(
      id: msgId,
      senderId: _c._identity!.id,
      receiverId: contact.id,
      encryptedPayload: displayPayload,
      timestamp: DateTime.now(),
      adapterType: 'p2p',
      isRead: true,
      status: 'sending',
    );
    room.messages.add(localMsg);
    _c._repo.trackMessageId(contact.id, localMsg.id);
    _c._repo.setUploadProgress(msgId, 0.0);
    _c._scheduleNotify();

    bool allSent = true;
    try {
      for (int i = 0; i < total; i++) {
        final start = i * chunkSize;
        final end = (start + chunkSize).clamp(0, bytes.length);
        final chunk = bytes.sublist(start, end);
        if (!P2PTransportService.instance.sendBinary(contact.id, chunk)) {
          allSent = false;
          break;
        }
        _c._repo.setUploadProgress(msgId, (i + 1) / total);
        _c._scheduleNotify();
        // Yield to event loop periodically to avoid blocking UI
        if (i % 4 == 3) await Future.delayed(Duration.zero);
      }
    } finally {
      _c._repo.clearUploadProgress(msgId);
    }

    final idx = _c._repo.messageIndexById(contact.id, msgId);
    final finalMsg = localMsg.copyWith(status: allSent ? 'sent' : 'failed');
    if (idx != -1) room.messages[idx] = finalMsg;
    await LocalStorageService().saveMessage(contact.storageKey, finalMsg.toJson());
    final localTtl = _c._repo.getChatTtlCached(contact.id);
    if (localTtl > 0) _c._repo.scheduleTtlDelete(contact, finalMsg, localTtl, onDeleted: () { if (!_c._disposed) _c._scheduleNotify(); });
    _c._scheduleNotify();
    return allSent;
  }

  /// Tier 3 / group fallback: relay-based 32KB chunks (original behavior).
  Future<void> _sendViaRelayChunks(Contact contact, Uint8List bytes, String name,
      {String mediaType = 'file'}) async {
    final totalChunks = (bytes.length / (8 * 1024)).ceil();
    final isGroup = contact.isGroup;
    final room = _c._repo.getOrCreateRoom(contact);
    final msgId = ChatController._uuid.v4();

    final displayPayload = jsonEncode({'t': mediaType, 'n': name, 'sz': bytes.length, 'd': ''});
    final localMsg = Message(
      id: msgId,
      senderId: _c._identity!.id,
      receiverId: contact.id,
      encryptedPayload: displayPayload,
      timestamp: DateTime.now(),
      adapterType: isGroup ? 'group' : (contact.provider == 'Nostr' ? 'nostr' : 'firebase'),
      isRead: true,
      status: 'sending',
    );
    room.messages.add(localMsg);
    _c._repo.trackMessageId(contact.id, localMsg.id);
    final localTtl = _c._repo.getChatTtlCached(contact.id);
    if (localTtl > 0) _c._repo.scheduleTtlDelete(contact, localMsg, localTtl, onDeleted: () { if (!_c._disposed) _c._scheduleNotify(); });
    _c._scheduleNotify();

    bool allSent = true;
    _c._repo.setUploadProgress(msgId, 0.0);
    int i = 0;
    String? fileId;
    try {
      for (final chunk in MediaService.chunkIterable(bytes, name, mediaType: mediaType)) {
        if (fileId == null) {
          try {
            final m = jsonDecode(chunk) as Map<String, dynamic>;
            fileId = m['fid'] as String?;
          } catch (e) { debugPrint('[Chat] Could not extract fileId from chunk: $e'); }
        }
        final bool ok;
        if (isGroup) {
          ok = await _sendGroupChunk(contact, chunk);
        } else {
          ok = await _c._sendToContact(contact, chunk);
        }
        if (!ok) { allSent = false; break; }
        i++;
        _c._repo.setUploadProgress(msgId, i / totalChunks);
        _c._scheduleNotify();
      }
      if (fileId != null) {
        _c._pendingSends[fileId] = (contact: contact, bytes: bytes, name: name);
        Future.delayed(const Duration(minutes: 10), () => _c._pendingSends.remove(fileId));
        _c._startStallCheckTimer();
      }
    } finally {
      _c._repo.clearUploadProgress(msgId);
    }

    final idx = _c._repo.messageIndexById(contact.id, msgId);
    final finalMsg = localMsg.copyWith(status: allSent ? 'sent' : 'failed');
    if (idx != -1) room.messages[idx] = finalMsg;
    final storageKey = isGroup ? contact.id : contact.storageKey;
    await LocalStorageService().saveMessage(storageKey, finalMsg.toJson());
    _c._scheduleNotify();
  }

  /// Send a chunk payload to every member of a group. Used by relay-chunk
  /// tier and inline voice/video group fallback.
  Future<bool> _sendGroupChunk(Contact group, String chunkPayload) async {
    final groupPayload = jsonEncode({'_group': group.id, 'text': chunkPayload});
    final myUuid = _c._identity?.id ?? '';
    final selfId = _c._selfId;
    final ownPubAt = selfId.indexOf('@');
    final ownPub =
        (ownPubAt > 0 ? selfId.substring(0, ownPubAt) : selfId).toLowerCase();
    final isPulseRouted =
        group.isPulseGroup && group.groupServerUrl.isNotEmpty;
    if (isPulseRouted) {
      await _c.ensureGroupPulseConnection(group.groupServerUrl);
    }
    int sent = 0;
    final seen = <String>{};
    final memberIds = <String>[
      if (group.creatorId != null && group.creatorId!.isNotEmpty) group.creatorId!,
      ...group.members,
    ];
    for (final memberId in memberIds) {
      if (memberId == myUuid) continue;
      Contact? memberContact = _c._contacts.findById(memberId);
      if (memberContact == null) {
        final pub = group.memberPubkeys[memberId];
        if (pub != null && pub.isNotEmpty) {
          if (pub.toLowerCase() == ownPub) continue;
          memberContact = _c._contacts.findByPubkey(pub);
        }
      }
      if (memberContact == null) continue;
      if (!seen.add(memberContact.id)) continue;
      final ok = isPulseRouted
          ? await _c._sendToContactViaPulseServer(
              memberContact, groupPayload, group.groupServerUrl)
          : await _c._sendToContact(memberContact, groupPayload);
      if (ok) sent++;
    }
    return sent > 0;
  }
}
