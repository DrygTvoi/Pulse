import 'dart:convert';
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
const int _chunkSizeBytes = 512 * 1024;           // 512 KB per chunk
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

    // Security: validate before any processing
    final check = MediaValidator.validateImage(bytes);
    if (!check.isValid) throw MediaSecurityException(check.reason!);

    final safeName = MediaValidator.sanitizeFilename(file.name);
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
      {String mediaType = 'file'}) {
    final safeName = MediaValidator.sanitizeFilename(name);
    if (bytes.length <= _chunkSizeBytes) {
      return [
        jsonEncode({'t': mediaType, 'd': base64Encode(bytes), 'n': safeName, 'sz': bytes.length})
      ];
    }
    final fileId = _uuid.v4();
    final total = (bytes.length / _chunkSizeBytes).ceil();
    final chunks = <String>[];
    for (int i = 0; i < total; i++) {
      final start = i * _chunkSizeBytes;
      final end = (start + _chunkSizeBytes).clamp(0, bytes.length);
      final chunk = bytes.sublist(start, end);
      final map = <String, dynamic>{
        't': 'chunk',
        'fid': fileId,
        'idx': i,
        'total': total,
        'd': base64Encode(chunk),
      };
      if (i == 0) {
        map['n'] = safeName;
        map['sz'] = bytes.length;
        map['mt'] = mediaType;
      }
      chunks.add(jsonEncode(map));
    }
    return chunks;
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

  /// Parse a media payload securely. Returns null for non-media or invalid content.
  static MediaPayload? parse(String text) {
    if (!isMediaPayload(text)) return null;
    try {
      // JSON depth guard
      final depthCheck = MediaValidator.validateJsonPayload(text);
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
      final sizeLimit = type == 'img'   ? 20 * 1024 * 1024   // 20 MB
                      : type == 'voice' ? 10 * 1024 * 1024   // 10 MB
                      : _maxFileSizeBytes;                    // 100 MB
      if (estimatedBytes > sizeLimit) {
        debugPrint('[MediaService] Rejected: estimated size $estimatedBytes > $sizeLimit');
        return null;
      }

      final rawData = base64Decode(b64Field);

      // Per-type security validation on decoded bytes
      if (type == 'img') {
        final check = MediaValidator.validateImage(rawData);
        if (!check.isValid) {
          debugPrint('[MediaService] Rejected image: ${check.reason}');
          return null;
        }
      } else if (type == 'voice') {
        final check = MediaValidator.validateAudio(rawData);
        if (!check.isValid) {
          debugPrint('[MediaService] Rejected audio: ${check.reason}');
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

      return MediaPayload(
        type: type,
        data: rawData,
        name: safeName,
        size: (map['sz'] as num?)?.toInt() ?? rawData.length,
        durationSeconds: (map['dur'] as num?)?.toInt() ?? 0,
        amplitudes: amplitudes,
      );
    } catch (e) {
      debugPrint('[MediaService] Parse error: $e');
      return null;
    }
  }

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
  final String type; // 'img', 'file', or 'voice'
  final Uint8List data;
  final String name;
  final int size;
  final int durationSeconds; // for voice messages
  final List<double>? amplitudes; // normalised 0..1, length == _waveformBars

  const MediaPayload({
    required this.type,
    required this.data,
    required this.name,
    required this.size,
    this.durationSeconds = 0,
    this.amplitudes,
  });

  bool get isImage => type == 'img';
  bool get isVoice => type == 'voice';

  String get sizeLabel {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / 1024 / 1024).toStringAsFixed(1)}MB';
  }
}
