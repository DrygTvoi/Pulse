import 'dart:collection';
import 'dart:typed_data';

/// Process-wide LRU of decrypted Blossom media bytes, keyed by content
/// hash. Each `_BlossomMediaWidgetState` used to hold its own decoded
/// `_decryptedBytes` — ListView.builder disposes that State on scroll-
/// out, so every scroll-back through the history re-read the temp file
/// AND re-ran AES-GCM decryption. Sharing the decoded bytes across
/// bubbles collapses that work.
///
/// Bounded by entry count rather than bytes — Blossom payloads are
/// ~1-15 MB each; 20 entries caps RAM at roughly 100-300 MB worst case,
/// typical case is much lower.
class BlossomImageCache {
  BlossomImageCache._();
  static final BlossomImageCache instance = BlossomImageCache._();

  static const _maxEntries = 20;
  final LinkedHashMap<String, Uint8List> _cache = LinkedHashMap();

  /// Returns cached bytes for [hash] or null. Recently-accessed entries
  /// move to the back of the LRU so they're evicted last.
  Uint8List? get(String hash) {
    final bytes = _cache.remove(hash);
    if (bytes == null) return null;
    _cache[hash] = bytes;
    return bytes;
  }

  /// Inserts or updates the entry for [hash]. Evicts the least-recently
  /// used entry once the cache exceeds `_maxEntries`.
  void put(String hash, Uint8List bytes) {
    _cache.remove(hash);
    _cache[hash] = bytes;
    while (_cache.length > _maxEntries) {
      _cache.remove(_cache.keys.first);
    }
  }

  void invalidate(String hash) => _cache.remove(hash);
  void clear() => _cache.clear();
  int get size => _cache.length;
}
