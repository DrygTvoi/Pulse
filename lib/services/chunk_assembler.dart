import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/foundation.dart';

/// Buffers incoming file chunks and assembles them when all parts arrive.
///
/// Limits:
/// - Max [maxPendingFiles] concurrent transfers (default 16)
/// - Max [maxTotalBytes] buffered across all transfers (default 50 MB)
/// - Stale transfers evicted after [staleTimeout] (default 5 min)
class ChunkAssembler {
  static const int maxPendingFiles = 16;
  static const int maxTotalBytes = 50 * 1024 * 1024; // 50 MB
  static const Duration staleTimeout = Duration(minutes: 5);

  // Chunk data buffers keyed by file ID
  final Map<String, Map<int, Uint8List>> _pendingChunks = {};
  final Map<String, ({String name, int total, int size, String mediaType})> _chunkMeta = {};
  final Map<String, DateTime> _chunkTimestamps = {};
  int _totalBufferedBytes = 0;

  /// Buffer an incoming chunk and return the assembled media payload once all
  /// chunks for a file ID have arrived, or null if more chunks are expected.
  String? handleChunk(String chunkPayload) {
    try {
      // Evict stale transfers before processing
      _evictStale();

      final map = jsonDecode(chunkPayload) as Map<String, dynamic>;
      final fid = map['fid'] as String;
      final idx = map['idx'] as int;
      final total = map['total'] as int;
      final data = map['d'] as String;

      // Reject unreasonable chunk counts
      if (total <= 0 || total > 2000) {
        debugPrint('[ChunkAssembler] Rejected: total=$total out of range');
        return null;
      }

      // Reject if too many pending files (evict oldest if at limit)
      if (!_pendingChunks.containsKey(fid) && _pendingChunks.length >= maxPendingFiles) {
        _evictOldest();
      }

      final chunkBytes = base64Decode(data);

      // Per-chunk SHA-256 integrity check — drop corrupt chunks early.
      final expectedHash = map['h'] as String?;
      if (expectedHash != null) {
        final actualHash = crypto.sha256.convert(chunkBytes).toString();
        if (actualHash != expectedHash) {
          debugPrint('[ChunkAssembler] Chunk $idx of $fid failed SHA-256 check — dropping');
          return null;
        }
      }

      // Reject if total buffered bytes would exceed limit
      if (_totalBufferedBytes + chunkBytes.length > maxTotalBytes) {
        debugPrint('[ChunkAssembler] Rejected: would exceed ${maxTotalBytes ~/ (1024 * 1024)}MB buffer limit');
        return null;
      }

      _pendingChunks[fid] ??= {};
      _pendingChunks[fid]![idx] = chunkBytes;
      _chunkTimestamps[fid] = DateTime.now();
      _totalBufferedBytes += chunkBytes.length;

      if (idx == 0) {
        _chunkMeta[fid] = (
          name: map['n'] as String? ?? 'file',
          total: total,
          size: (map['sz'] as num?)?.toInt() ?? 0,
          mediaType: map['mt'] as String? ?? 'file',
        );
      }

      if ((_pendingChunks[fid]?.length ?? 0) < total) return null;

      final meta = _chunkMeta[fid];
      if (meta == null) return null;

      final partsList = <Uint8List>[];
      for (int i = 0; i < total; i++) {
        final part = _pendingChunks[fid]![i];
        if (part == null) return null;
        partsList.add(part);
      }
      final totalSize = partsList.fold(0, (s, b) => s + b.length);
      final assembled = Uint8List(totalSize);
      int offset = 0;
      for (final part in partsList) {
        assembled.setRange(offset, offset + part.length, part);
        offset += part.length;
      }

      _removePending(fid);

      return jsonEncode({
        't': meta.mediaType,
        'd': base64Encode(assembled),
        'n': meta.name,
        'sz': assembled.length,
      });
    } catch (e) {
      debugPrint('[ChunkAssembler] Assembly error: $e');
      return null;
    }
  }

  // ── Resume support ────────────────────────────────────────────────────────

  /// IDs of all active (in-progress) transfers.
  List<String> get activeTransferIds => List.unmodifiable(_pendingChunks.keys);

  /// Returns the indices of chunks still missing for [fid], or null if [fid]
  /// is not an active transfer (unknown or already completed).
  List<int>? getMissingChunks(String fid) {
    final meta = _chunkMeta[fid];
    final chunks = _pendingChunks[fid];
    if (meta == null || chunks == null) return null;
    final missing = <int>[];
    for (int i = 0; i < meta.total; i++) {
      if (!chunks.containsKey(i)) missing.add(i);
    }
    return missing;
  }

  /// Returns the timestamp of the last received chunk for [fid], or null.
  DateTime? lastActivity(String fid) => _chunkTimestamps[fid];

  /// Returns true if [fid] is an active transfer that has not received any
  /// chunk for at least [stallDuration].
  bool isStalled(String fid, {Duration stallDuration = const Duration(seconds: 30)}) {
    final last = _chunkTimestamps[fid];
    if (last == null) return false;
    return DateTime.now().difference(last) >= stallDuration;
  }

  // ── Internal ─────────────────────────────────────────────────────────────

  /// Remove a pending transfer and update byte counter.
  void _removePending(String fid) {
    final chunks = _pendingChunks.remove(fid);
    _chunkMeta.remove(fid);
    _chunkTimestamps.remove(fid);
    if (chunks != null) {
      for (final c in chunks.values) {
        _totalBufferedBytes -= c.length;
      }
    }
  }

  /// Evict transfers older than [staleTimeout].
  void _evictStale() {
    final now = DateTime.now();
    final stale = <String>[];
    for (final entry in _chunkTimestamps.entries) {
      if (now.difference(entry.value) > staleTimeout) {
        stale.add(entry.key);
      }
    }
    for (final fid in stale) {
      debugPrint('[ChunkAssembler] Evicting stale transfer: $fid');
      _removePending(fid);
    }
  }

  /// Evict the oldest pending transfer.
  void _evictOldest() {
    if (_chunkTimestamps.isEmpty) return;
    String? oldest;
    DateTime? oldestTime;
    for (final entry in _chunkTimestamps.entries) {
      if (oldestTime == null || entry.value.isBefore(oldestTime)) {
        oldest = entry.key;
        oldestTime = entry.value;
      }
    }
    if (oldest != null) {
      debugPrint('[ChunkAssembler] Evicting oldest transfer: $oldest');
      _removePending(oldest);
    }
  }
}
