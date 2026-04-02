import 'dart:typed_data';

/// Static security checks applied to ALL incoming media before processing.
///
/// Defence-in-depth against malformed-media 0-days (cf. FORCEDENTRY, BLASTPASS):
/// 1. Magic byte validation — rejects files whose content doesn't match their
///    declared type (e.g. a JPEG that is actually a PDF or executable).
/// 2. Hard size caps per content type — prevents memory-bomb DoS.
/// 3. Dimension pre-check on raw JPEG/PNG headers — rejects giant canvases
///    before the decoder even touches the pixel data.
/// 4. Filename sanitisation — strips path traversal sequences.
/// 5. WAV header check — rejects malformed audio before playback.
/// 6. JSON depth / size guard — prevents billion-laughs style attacks.
class MediaValidator {
  MediaValidator._();

  // ── Size limits ────────────────────────────────────────────────────────────
  static const int maxImageBytes = 20 * 1024 * 1024;   //  20 MB raw
  static const int maxFileBytes  = 100 * 1024 * 1024;  // 100 MB
  static const int maxVoiceBytes = 10 * 1024 * 1024;   //  10 MB
  static const int maxVideoNoteBytes = 15 * 1024 * 1024; // 15 MB
  static const int maxGifBytes   = 10 * 1024 * 1024;   //  10 MB
  static const int maxImageDimension = 4096;            //  px per axis
  static const int maxJsonBytes  = 512 * 1024;          // 512 KB JSON payload
  static const int maxJsonDepth  = 8;                   // nesting depth

  // ── Image ─────────────────────────────────────────────────────────────────

  /// Validates raw image bytes. Returns a [MediaValidationResult].
  static MediaValidationResult validateImage(Uint8List bytes) {
    if (bytes.length > maxImageBytes) {
      return MediaValidationResult.reject('Image exceeds ${maxImageBytes ~/ 1024 ~/ 1024} MB limit');
    }
    if (!_hasImageMagic(bytes)) {
      return MediaValidationResult.reject('File is not a recognised image format');
    }
    final dims = _readImageDimensions(bytes);
    if (dims != null) {
      if (dims.$1 > maxImageDimension || dims.$2 > maxImageDimension) {
        return MediaValidationResult.reject(
            'Image dimensions ${dims.$1}×${dims.$2} exceed ${maxImageDimension}px limit');
      }
    }
    return MediaValidationResult.ok;
  }

  /// Returns true if [bytes] start with a known image magic sequence.
  static bool _hasImageMagic(Uint8List b) {
    if (b.length < 4) return false;
    // JPEG: FF D8 FF
    if (b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF) return true;
    // PNG:  89 50 4E 47 (‌PNG)
    if (b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47) return true;
    // GIF:  47 49 46 38 (GIF8)
    if (b[0] == 0x47 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x38) return true;
    // WEBP: 52 49 46 46 ... 57 45 42 50
    if (b.length >= 12 &&
        b[0] == 0x52 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x46 &&
        b[8] == 0x57 && b[9] == 0x45 && b[10] == 0x42 && b[11] == 0x50) {
      return true;
    }
    // BMP:  42 4D (BM)
    if (b[0] == 0x42 && b[1] == 0x4D) return true;
    return false;
  }

  /// Reads image dimensions from raw bytes without full decode.
  /// Returns (width, height) or null if format unknown / header too short.
  static (int, int)? _readImageDimensions(Uint8List b) {
    if (b.length < 24) return null;
    // PNG: width at offset 16, height at 20 (big-endian uint32)
    if (b[0] == 0x89 && b[1] == 0x50) {
      final w = _u32be(b, 16);
      final h = _u32be(b, 20);
      return (w, h);
    }
    // JPEG: scan for SOF marker (FF C0 / FF C2)
    if (b[0] == 0xFF && b[1] == 0xD8) {
      return _readJpegDimensions(b);
    }
    return null;
  }

  static (int, int)? _readJpegDimensions(Uint8List b) {
    int i = 2;
    while (i + 8 < b.length) {
      if (b[i] != 0xFF) break;
      final marker = b[i + 1];
      // SOF0 (C0), SOF2 (C2) — baseline & progressive
      if (marker == 0xC0 || marker == 0xC2) {
        if (i + 8 >= b.length) return null;
        final h = _u16be(b, i + 5);
        final w = _u16be(b, i + 7);
        return (w, h);
      }
      final segLen = _u16be(b, i + 2);
      i += 2 + segLen;
    }
    return null;
  }

  // ── Audio ─────────────────────────────────────────────────────────────────

  /// Validates WAV, OGG/OPUS, or AAC/M4A audio bytes. Returns a [MediaValidationResult].
  static MediaValidationResult validateAudio(Uint8List bytes) {
    if (bytes.length > maxVoiceBytes) {
      return MediaValidationResult.reject('Voice message exceeds ${maxVoiceBytes ~/ 1024 ~/ 1024} MB limit');
    }
    if (!_hasWavMagic(bytes) && !_hasOggMagic(bytes) && !_hasM4aMagic(bytes)) {
      return MediaValidationResult.reject('Audio is not a valid WAV, OGG/OPUS, or AAC/M4A file');
    }
    return MediaValidationResult.ok;
  }

  /// RIFF....WAVE magic check.
  static bool _hasWavMagic(Uint8List b) {
    if (b.length < 12) return false;
    return b[0] == 0x52 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x46 && // RIFF
           b[8] == 0x57 && b[9] == 0x41 && b[10] == 0x56 && b[11] == 0x45;  // WAVE
  }

  /// OGG sync word magic check (OggS = 0x4F 0x67 0x67 0x53).
  /// OGG/Opus files always start with this 4-byte capture pattern.
  static bool _hasOggMagic(Uint8List b) {
    if (b.length < 4) return false;
    return b[0] == 0x4F && b[1] == 0x67 && b[2] == 0x67 && b[3] == 0x53;
  }

  /// M4A/AAC magic: 'ftyp' box (66 74 79 70) at offset 4.
  /// MP4/M4A containers always have this 4-byte marker at bytes 4–7.
  static bool _hasM4aMagic(Uint8List b) {
    if (b.length < 8) return false;
    return b[4] == 0x66 && b[5] == 0x74 && b[6] == 0x79 && b[7] == 0x70;
  }

  // ── Video ─────────────────────────────────────────────────────────────────

  /// Validates video bytes (MP4 / WebM). Returns a [MediaValidationResult].
  static MediaValidationResult validateVideo(Uint8List bytes) {
    if (bytes.length > maxVideoNoteBytes) {
      return MediaValidationResult.reject('Video exceeds ${maxVideoNoteBytes ~/ 1024 ~/ 1024} MB limit');
    }
    if (!_hasVideoMagic(bytes)) {
      return MediaValidationResult.reject('File is not a recognised video format');
    }
    return MediaValidationResult.ok;
  }

  /// Returns true if [bytes] start with MP4 (ftyp at offset 4) or WebM (0x1A45DFA3).
  static bool _hasVideoMagic(Uint8List b) {
    if (b.length < 8) return false;
    // MP4: "ftyp" at offset 4
    if (b[4] == 0x66 && b[5] == 0x74 && b[6] == 0x79 && b[7] == 0x70) return true;
    // WebM: EBML header 0x1A45DFA3
    if (b[0] == 0x1A && b[1] == 0x45 && b[2] == 0xDF && b[3] == 0xA3) return true;
    return false;
  }

  // ── GIF ──────────────────────────────────────────────────────────────────

  /// Validates GIF bytes. Returns a [MediaValidationResult].
  static MediaValidationResult validateGif(Uint8List bytes) {
    if (bytes.length > maxGifBytes) {
      return MediaValidationResult.reject('GIF exceeds ${maxGifBytes ~/ 1024 ~/ 1024} MB limit');
    }
    if (!_hasGifMagic(bytes)) {
      return MediaValidationResult.reject('File is not a valid GIF');
    }
    return MediaValidationResult.ok;
  }

  /// GIF87a or GIF89a magic bytes.
  static bool _hasGifMagic(Uint8List b) {
    if (b.length < 6) return false;
    // GIF87a: 47 49 46 38 37 61
    // GIF89a: 47 49 46 38 39 61
    return b[0] == 0x47 && b[1] == 0x49 && b[2] == 0x46 &&
           b[3] == 0x38 && (b[4] == 0x37 || b[4] == 0x39) && b[5] == 0x61;
  }

  // ── File ──────────────────────────────────────────────────────────────────

  /// Validates generic file bytes and name.
  static MediaValidationResult validateFile(Uint8List bytes, String name) {
    if (bytes.length > maxFileBytes) {
      return MediaValidationResult.reject('File exceeds ${maxFileBytes ~/ 1024 ~/ 1024} MB limit');
    }
    if (_isExecutable(bytes)) {
      return MediaValidationResult.reject('Executable files are not allowed');
    }
    return MediaValidationResult.ok;
  }

  /// Rejects known executable magic bytes (ELF, PE, Mach-O, shell scripts).
  static bool _isExecutable(Uint8List b) {
    if (b.length < 4) return false;
    // ELF: 7F 45 4C 46
    if (b[0] == 0x7F && b[1] == 0x45 && b[2] == 0x4C && b[3] == 0x46) return true;
    // PE (Windows): 4D 5A (MZ)
    if (b[0] == 0x4D && b[1] == 0x5A) return true;
    // Mach-O: CE FA ED FE / CF FA ED FE (32/64-bit)
    if ((b[0] == 0xCE || b[0] == 0xCF) && b[1] == 0xFA && b[2] == 0xED && b[3] == 0xFE) return true;
    // Shell script: #!
    if (b[0] == 0x23 && b[1] == 0x21) return true;
    return false;
  }

  // ── Filename ──────────────────────────────────────────────────────────────

  /// Strips path traversal, null bytes, and control characters from filenames.
  static String sanitizeFilename(String name) {
    // Remove all ASCII control characters (0x00-0x1F, 0x7F) including
    // null, tab, newline, carriage return — these can corrupt logs and
    // cause issues when filenames appear in shell commands or UI.
    var s = name.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
    // Strip any directory components
    s = s.split('/').last.split('\\').last;
    // Remove leading dots (hidden files on Unix)
    while (s.startsWith('.')) {
      s = s.substring(1);
    }
    // Limit length
    if (s.length > 255) s = s.substring(0, 255);
    // Fallback
    if (s.isEmpty) s = 'file';
    return s;
  }

  // ── JSON ──────────────────────────────────────────────────────────────────

  /// Guards against deeply-nested / oversized JSON payloads.
  static MediaValidationResult validateJsonPayload(String text) {
    if (text.length > maxJsonBytes) {
      return MediaValidationResult.reject('Payload too large');
    }
    if (_jsonDepth(text) > maxJsonDepth) {
      return MediaValidationResult.reject('Payload nesting too deep');
    }
    return MediaValidationResult.ok;
  }

  /// Guards against only deeply-nested JSON (no size check).
  /// Use this for media payloads which are size-checked per type.
  static MediaValidationResult validateJsonDepth(String text) {
    if (_jsonDepth(text) > maxJsonDepth) {
      return MediaValidationResult.reject('Payload nesting too deep');
    }
    return MediaValidationResult.ok;
  }

  /// Counts brace / bracket nesting depth without full decode.
  static int _jsonDepth(String s) {
    int depth = 0;
    int max = 0;
    bool inString = false;
    for (int i = 0; i < s.length; i++) {
      final c = s[i];
      if (c == '"') {
        // Count consecutive preceding backslashes to determine if this quote
        // is escaped. An even number means the quote is real (e.g., `\\"`).
        int backslashes = 0;
        int j = i - 1;
        while (j >= 0 && s[j] == '\\') { backslashes++; j--; }
        if (backslashes % 2 == 0) inString = !inString;
      }
      if (!inString) {
        if (c == '{' || c == '[') {
          depth++;
          if (depth > max) max = depth;
        } else if (c == '}' || c == ']') {
          depth--;
        }
      }
    }
    return max;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static int _u32be(Uint8List b, int offset) =>
      (b[offset] << 24) | (b[offset + 1] << 16) | (b[offset + 2] << 8) | b[offset + 3];

  static int _u16be(Uint8List b, int offset) => (b[offset] << 8) | b[offset + 1];
}

class MediaValidationResult {
  final bool isValid;
  final String? reason;

  const MediaValidationResult._({required this.isValid, this.reason});

  static const MediaValidationResult ok = MediaValidationResult._(isValid: true);

  factory MediaValidationResult.reject(String reason) =>
      MediaValidationResult._(isValid: false, reason: reason);

  @override
  String toString() => isValid ? 'ok' : 'rejected: $reason';
}
