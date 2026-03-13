import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';

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
  /// Throws [MediaTooLargeException] if the selected file exceeds the size limit.
  Future<({String payload, String name, int size})?> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return null;

    if (bytes.length > _maxFileSizeBytes) throw MediaTooLargeException();

    final processed = _compressImage(bytes);
    final b64 = base64Encode(processed);
    final payload = jsonEncode({'t': 'img', 'd': b64, 'n': file.name, 'sz': processed.length});
    return (payload: payload, name: file.name, size: processed.length);
  }

  /// Pick any file (non-image) and return encoded payload, or null if cancelled.
  /// For files ≤ 512 KB returns a single payload; larger files must use [pickFileRaw].
  /// Throws [MediaTooLargeException] if the selected file exceeds 100 MB.
  Future<({String payload, String name, int size})?> pickFile() async {
    final raw = await pickFileRaw();
    if (raw == null) return null;
    if (raw.bytes.length > _chunkSizeBytes) {
      // Caller should use pickFileRaw + chunkPayloads for large files.
      throw FileTooLargeForSinglePayload();
    }
    final b64 = base64Encode(raw.bytes);
    final payload = jsonEncode({'t': 'file', 'd': b64, 'n': raw.name, 'sz': raw.bytes.length});
    return (payload: payload, name: raw.name, size: raw.bytes.length);
  }

  /// Pick any file and return raw bytes + name (no encoding). Up to 100 MB.
  Future<({Uint8List bytes, String name})?> pickFileRaw() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any, withData: true);
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return null;
    if (bytes.length > _maxFileSizeBytes) throw MediaTooLargeException();
    return (bytes: bytes, name: file.name);
  }

  /// Split [bytes] into ≤512 KB chunks and return a list of JSON payload strings.
  /// Single-chunk files return a normal `{"t":"file",...}` payload.
  /// Multi-chunk files return `{"t":"chunk",...}` payloads.
  static List<String> chunkPayloads(Uint8List bytes, String name,
      {String mediaType = 'file'}) {
    if (bytes.length <= _chunkSizeBytes) {
      return [
        jsonEncode({'t': mediaType, 'd': base64Encode(bytes), 'n': name, 'sz': bytes.length})
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
        map['n'] = name;
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
    try {
      final map = jsonDecode(text) as Map<String, dynamic>;
      return map.containsKey('t') && map.containsKey('d');
    } catch (_) {
      return false;
    }
  }

  /// Parse a media payload. Returns null for non-media text.
  static MediaPayload? parse(String text) {
    if (!isMediaPayload(text)) return null;
    try {
      final map = jsonDecode(text) as Map<String, dynamic>;
      return MediaPayload(
        type: map['t'] as String,
        data: base64Decode(map['d'] as String),
        name: map['n'] as String? ?? 'file',
        size: (map['sz'] as num?)?.toInt() ?? 0,
        durationSeconds: (map['dur'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      return null;
    }
  }

  Uint8List _compressImage(Uint8List bytes) {
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return bytes;

      // Resize if too large
      img.Image resized = decoded;
      if (decoded.width > _maxImageDimension || decoded.height > _maxImageDimension) {
        resized = img.copyResize(
          decoded,
          width: decoded.width > decoded.height ? _maxImageDimension : -1,
          height: decoded.height >= decoded.width ? _maxImageDimension : -1,
          interpolation: img.Interpolation.linear,
        );
      }

      // Compress as JPEG, reduce quality until under target
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
}

class MediaTooLargeException implements Exception {
  @override
  String toString() => 'File exceeds the 100 MB size limit.';
}

class FileTooLargeForSinglePayload implements Exception {}

class MediaPayload {
  final String type; // 'img', 'file', or 'voice'
  final Uint8List data;
  final String name;
  final int size;
  final int durationSeconds; // for voice messages

  const MediaPayload({
    required this.type,
    required this.data,
    required this.name,
    required this.size,
    this.durationSeconds = 0,
  });

  bool get isImage => type == 'img';
  bool get isVoice => type == 'voice';

  String get sizeLabel {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / 1024 / 1024).toStringAsFixed(1)}MB';
  }
}
