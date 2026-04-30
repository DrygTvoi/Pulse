part of 'chat_controller.dart';

/// P2P (WebRTC DataChannel) message + binary file delivery. The receive
/// side feeds back into ChatController._handleIncomingMessages so the
/// rest of the pipeline (decrypt, persist, notify) is unchanged.
class _P2PReceiver {
  final ChatController _c;
  // Active P2P file transfers: fid → header + accumulated frames
  final Map<String, _P2PFileTransfer> _transfers = {};

  _P2PReceiver(this._c);

  /// Inbound DataChannel text message. We treat the peer's DataChannel
  /// id as the contact id; the encrypted payload then goes through the
  /// normal incoming-message pipeline (which handles dedup, decrypt,
  /// persistence, notify).
  void handleText(String contactId, String encryptedPayload) {
    final contact = _c._contacts.findById(contactId);
    if (contact == null) return;

    // SHA-256 of the full encrypted payload as the dedup ID. Truncating
    // to first-32-bytes used to allow two distinct ciphertexts with
    // identical first 32 bytes to collide and be deduplicated incorrectly.
    final msgId = hash_lib.sha256.convert(utf8.encode(encryptedPayload)).toString();

    _c._handleIncomingMessages([
      Message(
        id: msgId,
        senderId: contact.databaseId,
        receiverId: _c._selfId,
        encryptedPayload: encryptedPayload,
        timestamp: DateTime.now(),
        adapterType: 'p2p',
      ),
    ]);
  }

  /// Inbound DataChannel binary frame for the most-recent open transfer
  /// from this contact. We don't multiplex multiple concurrent transfers
  /// per peer — the receiver picks the first transfer that's still
  /// expecting more frames.
  void handleBinaryFrame(String contactId, Uint8List data) {
    _P2PFileTransfer? transfer;
    for (final t in _transfers.values) {
      if (t.contactId == contactId && t.framesReceived < t.total) {
        transfer = t;
        break;
      }
    }
    if (transfer == null) {
      debugPrint('[P2P] Binary frame from $contactId but no active transfer');
      return;
    }
    transfer.frames.add(data);
    transfer.framesReceived++;

    if (transfer.framesReceived >= transfer.total) {
      // Assemble the file
      final assembled = BytesBuilder(copy: false);
      for (final f in transfer.frames) {
        assembled.add(f);
      }
      final fileBytes = assembled.toBytes();
      final fileHash = hash_lib.sha256.convert(fileBytes).toString();
      _transfers.remove(transfer.fid);

      if (fileHash != transfer.fileHash) {
        debugPrint(
            '[P2P] File hash mismatch for ${transfer.name}: expected ${transfer.fileHash}, got $fileHash');
        return;
      }

      // Deliver as media payload
      final payload = jsonEncode({
        't': transfer.mediaType,
        'd': base64Encode(fileBytes),
        'n': transfer.name,
        'sz': fileBytes.length,
      });

      final contact = _c._contacts.findById(contactId);
      if (contact == null) return;

      _c._handleIncomingMessages([
        Message(
          id: ChatController._uuid.v4(),
          senderId: contact.databaseId,
          receiverId: _c._selfId,
          encryptedPayload: payload,
          timestamp: DateTime.now(),
          adapterType: 'p2p',
        ),
      ]);
      debugPrint(
          '[P2P] File received: ${transfer.name} (${fileBytes.length}B)');
    }
  }

  /// Called when a P2P text message contains a `p2p_file` header — opens
  /// a fresh in-memory transfer ready to accept binary frames.
  void handleFileHeader(String contactId, Map<String, dynamic> header) {
    final fid = header['fid'] as String? ?? '';
    final name = header['n'] as String? ?? 'file';
    final total = header['total'] as int? ?? 0;
    final fh = header['fh'] as String? ?? '';
    final mt = header['mt'] as String? ?? 'file';
    if (fid.isEmpty || total <= 0 || fh.isEmpty) return;
    if (_transfers.length > 10) return; // limit concurrent transfers
    _transfers[fid] = _P2PFileTransfer(
      fid: fid,
      contactId: contactId,
      name: name,
      total: total,
      fileHash: fh,
      mediaType: mt,
    );
    debugPrint(
        '[P2P] File transfer started: $name ($total frames) from $contactId');
  }
}
