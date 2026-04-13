import 'dart:convert';
import 'dart:io' show gzip;
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';
import 'media_validator.dart';

// Top-level function so compute() can spawn it in an Isolate.
Uint8List _compressImageIsolate(Uint8List bytes) {
  try {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;

    img.Image resized = decoded;
    if (decoded.width > _maxImageDimension || decoded.height > _maxImageDimension) {
      resized = img.copyResize(
        decoded,
        width: decoded.width > decoded.height ? _maxImageDimension : -1,
        height: decoded.height >= decoded.width ? _maxImageDimension : -1,
        interpolation: img.Interpolation.linear,
      );
    }

    int quality = 85;
    Uint8List encoded = Uint8List.fromList(img.encodeJpg(resized, quality: quality));
    while (encoded.length > _targetImageBytes && quality > 30) {
      quality -= 15;
      encoded = Uint8List.fromList(img.encodeJpg(resized, quality: quality));
    }
    return encoded;
  } catch (_) {
    return bytes;
  }
}

const int _maxFileSizeBytes = 100 * 1024 * 1024; // 100 MB limit for large files
const int _targetImageBytes = 500 * 1024;         // ~500 KB after compression
const int _maxImageDimension = 1280;
// NIP-44 has a 65535-byte limit (2-byte length prefix). Gift Wrap uses
// double NIP-44 (seal + wrap). Expansion: raw → b64(×1.33) → chunk JSON(+300)
// → Signal(×1.33) → NIP-44 b64(×1.33) → seal JSON(+300) → NIP-44 b64(×1.33)
// → wrap JSON(+300). 8KB raw → ~36KB final — safely under 65535.
const int _chunkSizeBytes = 8 * 1024;             // 8 KB per chunk
const _uuid = Uuid();

class MediaService {
  static final MediaService _instance = MediaService._();
  factory MediaService() => _instance;
  MediaService._();

  /// Pick an image file and return the encoded message payload, or null if cancelled.
  /// Throws [MediaTooLargeException] if the file exceeds the size limit.
  /// Throws [MediaSecurityException] if the file fails security validation.
  Future<({String payload, String name, int size})?> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return null;

    final safeName = MediaValidator.sanitizeFilename(file.name);

    // Detect GIF — send as animated (no re-encoding)
    if (_isGifBytes(bytes)) {
      final gifCheck = MediaValidator.validateGif(bytes);
      if (!gifCheck.isValid) throw MediaSecurityException(gifCheck.reason!);
      final b64 = base64Encode(bytes);
      final payload = jsonEncode({'t': 'gif', 'd': b64, 'n': safeName, 'sz': bytes.length});
      return (payload: payload, name: safeName, size: bytes.length);
    }

    // Security: validate before any processing
    final check = MediaValidator.validateImage(bytes);
    if (!check.isValid) throw MediaSecurityException(check.reason!);

    final processed = await compute(_compressImageIsolate, bytes);
    final b64 = base64Encode(processed);
    final payload = jsonEncode({'t': 'img', 'd': b64, 'n': safeName, 'sz': processed.length});
    return (payload: payload, name: safeName, size: processed.length);
  }

  /// Pick any file (non-image) and return encoded payload, or null if cancelled.
  /// For files > 512 KB use [pickFileRaw] + [chunkPayloads].
  /// Throws [MediaTooLargeException] or [MediaSecurityException] on violations.
  Future<({String payload, String name, int size})?> pickFile() async {
    final raw = await pickFileRaw();
    if (raw == null) return null;
    if (raw.bytes.length > _chunkSizeBytes) {
      throw FileTooLargeForSinglePayload();
    }
    final b64 = base64Encode(raw.bytes);
    final payload = jsonEncode({'t': 'file', 'd': b64, 'n': raw.name, 'sz': raw.bytes.length});
    return (payload: payload, name: raw.name, size: raw.bytes.length);
  }

  /// Pick any file and return raw bytes + sanitized name. Up to 100 MB.
  Future<({Uint8List bytes, String name})?> pickFileRaw() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any, withData: true);
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return null;

    // Security: validate before returning
    final safeName = MediaValidator.sanitizeFilename(file.name);
    final check = MediaValidator.validateFile(bytes, safeName);
    if (!check.isValid) throw MediaSecurityException(check.reason!);

    if (bytes.length > _maxFileSizeBytes) throw MediaTooLargeException();
    return (bytes: bytes, name: safeName);
  }

  /// Split [bytes] into ≤512 KB chunks and return a list of JSON payload strings.
  static List<String> chunkPayloads(Uint8List bytes, String name,
      {String mediaType = 'file'}) =>
      chunkIterable(bytes, name, mediaType: mediaType).toList();

  /// Lazily yields chunk payloads one at a time to avoid pre-allocating the
  /// entire encoded chunk list in memory.  Use this in send loops instead of
  /// [chunkPayloads] when sending large files to reduce peak RAM usage.
  static Iterable<String> chunkIterable(Uint8List bytes, String name,
      {String mediaType = 'file'}) sync* {
    final safeName = MediaValidator.sanitizeFilename(name);
    if (bytes.length <= _chunkSizeBytes) {
      yield jsonEncode({'t': mediaType, 'd': base64Encode(bytes), 'n': safeName, 'sz': bytes.length});
      return;
    }
    final fileId = _uuid.v4();
    final total = (bytes.length / _chunkSizeBytes).ceil();
    // Final file hash sent in chunk 0 so receiver can verify the assembled file.
    final finalHash = crypto.sha256.convert(bytes).toString();
    for (int i = 0; i < total; i++) {
      final start = i * _chunkSizeBytes;
      final end = (start + _chunkSizeBytes).clamp(0, bytes.length);
      final chunk = bytes.sublist(start, end);
      // Per-chunk SHA-256 so receiver can detect bit-flips early.
      final hash = crypto.sha256.convert(chunk).toString();
      final map = <String, dynamic>{
        't': 'chunk',
        'fid': fileId,
        'idx': i,
        'total': total,
        'd': base64Encode(chunk),
        'h': hash,
      };
      if (i == 0) {
        map['n'] = safeName;
        map['sz'] = bytes.length;
        map['mt'] = mediaType;
        map['fh'] = finalHash; // whole-file SHA-256 for post-assembly verification
      }
      yield jsonEncode(map);
    }
  }

  /// Returns true if the payload is a chunk (not yet assembled).
  static bool isChunkPayload(String text) {
    if (!text.startsWith('{')) return false;
    try {
      final m = jsonDecode(text) as Map<String, dynamic>;
      return m['t'] == 'chunk';
    } catch (_) {
      return false;
    }
  }

  /// Returns true if the string is a media payload JSON.
  static bool isMediaPayload(String text) {
    if (!text.startsWith('{')) return false;
    // Size guard: reject oversized payloads before JSON decode
    if (text.length > MediaValidator.maxJsonBytes * 4) return false; // base64 overhead
    try {
      final map = jsonDecode(text) as Map<String, dynamic>;
      return map.containsKey('t') && map.containsKey('d');
    } catch (_) {
      return false;
    }
  }

  /// Lightweight type+name extraction without base64 decoding the data field.
  /// Returns `({String type, String name})` or null for non-media payloads.
  /// Use this instead of [parse] when you only need the media type/name
  /// (e.g. reply previews) to avoid expensive base64 decode + validation.
  static ({String type, String name})? parseType(String text) {
    if (!text.startsWith('{')) return null;
    if (text.length > MediaValidator.maxJsonBytes * 4) return null;
    try {
      final map = jsonDecode(text) as Map<String, dynamic>;
      final type = map['t'];
      if (type is! String || type.isEmpty) return null;
      if (!map.containsKey('d')) return null;
      final name = MediaValidator.sanitizeFilename(map['n'] as String? ?? 'file');
      return (type: type, name: name);
    } catch (_) {
      return null;
    }
  }

  /// Parse a media payload securely. Returns null for non-media or invalid content.
  static MediaPayload? parse(String text) {
    if (!isMediaPayload(text)) return null;
    try {
      // JSON depth guard — size is already checked by isMediaPayload() (≤2MB)
      // and by the per-type estimatedBytes limit below.  The 512 KB
      // validateJsonPayload limit would incorrectly drop assembled voice
      // payloads for recordings longer than ~12 s.
      final depthCheck = MediaValidator.validateJsonDepth(text);
      if (!depthCheck.isValid) {
        debugPrint('[MediaService] Rejected payload: ${depthCheck.reason}');
        return null;
      }

      final map = jsonDecode(text) as Map<String, dynamic>;

      // Strict type checks — reject if fields are wrong types.
      final type = map['t'];
      if (type is! String || type.isEmpty) return null;

      final b64Field = map['d'];
      if (b64Field is! String) return null;

      // Pre-decode size guard: estimate decoded bytes from base64 length before
      // actually allocating a potentially huge buffer.
      final estimatedBytes = (b64Field.length * 3 / 4).ceil();
      final sizeLimit = type == 'img'        ? 20 * 1024 * 1024   // 20 MB
                      : type == 'voice'      ? 10 * 1024 * 1024   // 10 MB
                      : type == 'video_note' ? 15 * 1024 * 1024   // 15 MB
                      : type == 'gif'        ? 10 * 1024 * 1024   // 10 MB
                      : _maxFileSizeBytes;                         // 100 MB
      if (estimatedBytes > sizeLimit) {
        debugPrint('[MediaService] Rejected: estimated size $estimatedBytes > $sizeLimit');
        return null;
      }

      Uint8List rawData = base64Decode(b64Field);

      // Decompress gzip if the sender set the 'z' flag (voice messages).
      if (map['z'] == true) {
        try {
          // F8: Guard against gzip bombs. The compressed size is already checked
          // above, but compressed data can expand massively. We use a streaming
          // decoder with a running byte count to abort before allocating the
          // full decompressed buffer.
          final decompressed = BytesBuilder(copy: false);
          int decompressedTotal = 0;
          bool tooLarge = false;

          final outSink = _LimitedSink(
            onChunk: (chunk) {
              decompressedTotal += chunk.length;
              if (decompressedTotal > sizeLimit) {
                tooLarge = true;
              } else {
                decompressed.add(chunk);
              }
            },
          );
          final inSink = gzip.decoder.startChunkedConversion(outSink);
          inSink.add(rawData);
          inSink.close();

          if (tooLarge) {
            debugPrint('[MediaService] Rejected gzip bomb: decompressed > $sizeLimit');
            return null;
          }
          rawData = decompressed.toBytes();
        } catch (e) {
          debugPrint('[MediaService] gzip.decode failed: $e');
          return null;
        }
      }

      // Per-type security validation on decoded bytes
      if (type == 'img') {
        final check = MediaValidator.validateImage(rawData);
        if (!check.isValid) {
          debugPrint('[MediaService] Rejected image: ${check.reason}');
          return null;
        }
      } else if (type == 'voice') {
        // Skip validation for empty data (local sending-state placeholder).
        if (rawData.isEmpty) return null;
        final check = MediaValidator.validateAudio(rawData);
        if (!check.isValid) {
          // Log once per parse, not on every UI rebuild.
          return null;
        }
      } else if (type == 'video_note') {
        final check = MediaValidator.validateVideo(rawData);
        if (!check.isValid) {
          debugPrint('[MediaService] Rejected video: ${check.reason}');
          return null;
        }
      } else if (type == 'gif') {
        final check = MediaValidator.validateGif(rawData);
        if (!check.isValid) {
          debugPrint('[MediaService] Rejected gif: ${check.reason}');
          return null;
        }
      } else if (type == 'file') {
        final name = MediaValidator.sanitizeFilename(map['n'] as String? ?? 'file');
        final check = MediaValidator.validateFile(rawData, name);
        if (!check.isValid) {
          debugPrint('[MediaService] Rejected file: ${check.reason}');
          return null;
        }
      }

      List<double>? amplitudes;
      if (map['amp'] is List) {
        amplitudes = (map['amp'] as List)
            .whereType<num>()
            .map((v) => (v.toDouble() / 100.0).clamp(0.0, 1.0))
            .toList();
      }

      final safeName = MediaValidator.sanitizeFilename(map['n'] as String? ?? 'file');

      Uint8List? thumbData;
      if (type == 'video_note' && map['thumb'] is String) {
        try {
          // FINDING-4 fix: cap thumbnail size to prevent OOM via oversized thumb.
          final thumbStr = map['thumb'] as String;
          if (thumbStr.length <= 700000) { // ~512 KB base64
            final decoded = base64Decode(thumbStr);
            if (decoded.length <= 512 * 1024) thumbData = decoded;
          }
        } catch (_) {}
      }

      return MediaPayload(
        type: type,
        data: rawData,
        name: safeName,
        size: (map['sz'] as num?)?.toInt() ?? rawData.length,
        // Duration priority: explicit 'dur' field > filename (voice_Ns.opus/wav) >
        // WAV byte-count estimate (16kHz/16-bit/mono = 32000 bytes/s).
        durationSeconds: (map['dur'] as num?)?.toInt() ??
            _parseDurFromName(map['n'] as String?) ??
            (type == 'voice' && rawData.length > 44 ? (rawData.length - 44) ~/ 32000 : 0),
        amplitudes: amplitudes,
        thumbnailData: thumbData,
      );
    } catch (e) {
      debugPrint('[MediaService] Parse error: $e');
      return null;
    }
  }

  static bool _isGifBytes(Uint8List b) =>
      b.length >= 6 &&
      b[0] == 0x47 && b[1] == 0x49 && b[2] == 0x46 &&
      b[3] == 0x38 && (b[4] == 0x37 || b[4] == 0x39) && b[5] == 0x61;
}

class MediaTooLargeException implements Exception {
  @override
  String toString() => 'File exceeds the 100 MB size limit.';
}

class FileTooLargeForSinglePayload implements Exception {}

class MediaSecurityException implements Exception {
  final String reason;
  const MediaSecurityException(this.reason);
  @override
  String toString() => 'Media blocked: $reason';
}

class MediaPayload {
  final String type; // 'img', 'file', 'voice', 'video_note', 'gif'
  final Uint8List data;
  final String name;
  final int size;
  final int durationSeconds; // for voice messages
  final List<double>? amplitudes; // normalised 0..1, length == _waveformBars
  final Uint8List? thumbnailData; // for video_note

  const MediaPayload({
    required this.type,
    required this.data,
    required this.name,
    required this.size,
    this.durationSeconds = 0,
    this.amplitudes,
    this.thumbnailData,
  });

  bool get isImage => type == 'img';
  bool get isVoice => type == 'voice';
  bool get isVideoNote => type == 'video_note';
  bool get isGif => type == 'gif';

  String get sizeLabel {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / 1024 / 1024).toStringAsFixed(1)}MB';
  }
}

// ── Blossom payload ─────────────────────────────────────────────────────────

/// Metadata sent inside a Signal-encrypted message pointing to a Blossom blob.
class BlossomPayload {
  final String hash;   // SHA-256 hex of the encrypted blob
  final String server; // origin server URL
  final String key;    // AES-256 key, base64
  final String iv;     // GCM nonce, base64
  final String name;   // original filename
  final int size;      // original plaintext size in bytes
  final String mediaType; // 'img', 'gif', 'file', 'voice', 'video_note'
  final String? thumbnail; // tiny base64 JPEG (≤64px, quality 40)

  const BlossomPayload({
    required this.hash,
    required this.server,
    required this.key,
    required this.iv,
    required this.name,
    required this.size,
    required this.mediaType,
    this.thumbnail,
  });

  String get sizeLabel {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / 1024 / 1024).toStringAsFixed(1)}MB';
  }

  /// Deserialise from JSON map. Returns null on invalid data.
  static BlossomPayload? fromMap(Map<String, dynamic> m) {
    final h = m['h'] as String?;
    final s = m['s'] as String?;
    final k = m['k'] as String?;
    final iv = m['iv'] as String?;
    final n = m['n'] as String?;
    if (h == null || s == null || k == null || iv == null || n == null) {
      return null;
    }
    return BlossomPayload(
      hash: h,
      server: s,
      key: k,
      iv: iv,
      name: MediaValidator.sanitizeFilename(n),
      size: (m['sz'] as num?)?.toInt() ?? 0,
      mediaType: m['mt'] as String? ?? 'file',
      thumbnail: m['thumb'] as String?,
    );
  }
}

extension BlossomPayloadHelpers on MediaService {
  /// Build a Blossom payload JSON string to send as a message body.
  static String buildBlossomPayload({
    required String hash,
    required String server,
    required String key,
    required String iv,
    required String name,
    required int size,
    required String mediaType,
    String? thumbnail,
  }) {
    final m = <String, dynamic>{
      't': 'blossom',
      'h': hash,
      's': server,
      'k': key,
      'iv': iv,
      'n': MediaValidator.sanitizeFilename(name),
      'sz': size,
      'mt': mediaType,
    };
    if (thumbnail != null && thumbnail.isNotEmpty) m['thumb'] = thumbnail;
    return jsonEncode(m);
  }

  /// Returns true if [text] is a Blossom payload JSON.
  static bool isBlossomPayload(String text) {
    if (!text.startsWith('{')) return false;
    if (text.length > 500000) return false; // thumbnail + metadata cap
    try {
      final m = jsonDecode(text) as Map<String, dynamic>;
      return m['t'] == 'blossom' && m['h'] is String && m['s'] is String;
    } catch (_) {
      return false;
    }
  }

  /// Parse a Blossom payload. Returns null for non-Blossom or invalid content.
  static BlossomPayload? parseBlossomPayload(String text) {
    if (!isBlossomPayload(text)) return null;
    try {
      final m = jsonDecode(text) as Map<String, dynamic>;
      return BlossomPayload.fromMap(m);
    } catch (_) {
      return null;
    }
  }
}

/// Extract duration seconds from filenames like "voice_15s.wav" or "voice_60s.opus".
int? _parseDurFromName(String? name) {
  if (name == null) return null;
  final m = RegExp(r'voice_(\d+)s\.').firstMatch(name);
  return m != null ? int.tryParse(m.group(1)!) : null;
}

/// Streaming sink used for gzip decompression bomb guard.
/// Calls [onChunk] for each decoded chunk; caller decides whether to abort.
class _LimitedSink implements Sink<List<int>> {
  final void Function(List<int> chunk) onChunk;
  _LimitedSink({required this.onChunk});

  @override
  void add(List<int> chunk) => onChunk(chunk);

  @override
  void close() {}
}
