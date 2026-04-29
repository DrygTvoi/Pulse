part of 'chat_controller.dart';

/// File-transfer resume support. Periodic stall scanner that checks
/// every active chunked transfer; if `ChunkAssembler` reports stalled
/// chunks for one, we ping the original sender with a `chunk_req`
/// listing the missing indices. Outbound side replies via
/// [_FileResume.resendMissing] (driven by the dispatcher).
class _FileResume {
  final ChatController _c;
  _FileResume(this._c);

  /// Arms the periodic scanner if it isn't already running. Idempotent.
  /// Self-cancels when there's nothing left to watch (no active
  /// transfers AND no pending sends).
  void startStallCheckTimer() {
    if (_c._stallCheckTimer?.isActive == true) return;
    _c._stallCheckTimer =
        Timer.periodic(const Duration(seconds: 30), (_) {
      // Prune _chunkSenderIds entries for transfers that ChunkAssembler
      // has already evicted (stale timeout / capacity). Prevents
      // unbounded growth.
      final activeIds = _c._chunkAssembler.activeTransferIds.toSet();
      _c._chunkSenderIds.removeWhere((fid, _) => !activeIds.contains(fid));

      for (final fid in _c._chunkAssembler.activeTransferIds) {
        if (!_c._chunkAssembler.isStalled(fid)) continue;
        final missing = _c._chunkAssembler.getMissingChunks(fid);
        if (missing == null || missing.isEmpty) continue;
        // Send chunk_req only to the contact who started this transfer.
        // Broadcasting to all contacts leaks file IDs and lets
        // unrelated contacts inject fake chunks.
        final senderId = _c._chunkSenderIds[fid];
        final senderContact =
            senderId != null ? _c._contacts.findById(senderId) : null;
        if (senderContact != null) {
          unawaited(_c._sendSignalTo(senderContact, 'chunk_req', {
            'fid': fid,
            'missing': missing,
          }));
        }
        debugPrint(
            '[Resume] Sent chunk_req for $fid — missing ${missing.length} chunks');
      }
      if (_c._chunkAssembler.activeTransferIds.isEmpty &&
          _c._pendingSends.isEmpty) {
        _c._stallCheckTimer?.cancel();
        _c._stallCheckTimer = null;
      }
    });
  }

  /// Re-emit the requested chunks for a file we sent earlier. Cap +
  /// dedup the indices to prevent an amplification attack where the
  /// peer chunks-requests thousands of duplicates.
  Future<void> resendMissing(
      String fileId, List<int> missingIndices, String recipientId) async {
    final pending = _c._pendingSends[fileId];
    if (pending == null) {
      debugPrint(
          '[Resume] chunk_req for $fileId but not in pending sends — ignoring');
      return;
    }
    final uniqueIndices = missingIndices.toSet().take(50).toList();
    debugPrint(
        '[Resume] Re-sending ${uniqueIndices.length} chunks for $fileId to $recipientId');
    final allChunks =
        MediaService.chunkIterable(pending.bytes, pending.name).toList();
    for (final idx in uniqueIndices) {
      if (idx < 0 || idx >= allChunks.length) continue;
      await _c._sendToContact(pending.contact, allChunks[idx]);
    }
  }
}
