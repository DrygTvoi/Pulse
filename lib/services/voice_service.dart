import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'media_validator.dart';

// Number of amplitude samples stored in the waveform (shown as bars in the bubble).
const _waveformBars = 30;

/// Raw voice recording data returned by [VoiceService.stopRecordingRaw].
class VoiceRecording {
  final Uint8List wavBytes;
  final int durationSeconds;
  final List<double> amplitudes; // normalised 0..1

  const VoiceRecording({
    required this.wavBytes,
    required this.durationSeconds,
    required this.amplitudes,
  });
}

/// Handles voice message recording.
/// Playback is handled per-bubble via audioplayers (see message_bubble.dart).
class VoiceService {
  static VoiceService _instance = VoiceService._();
  factory VoiceService() => _instance;
  VoiceService._();

  /// Protected constructor for test subclasses.
  @visibleForTesting
  VoiceService.forTesting();

  /// Replace the singleton for testing.
  @visibleForTesting
  static void setInstanceForTesting(VoiceService inst) => _instance = inst;

  final AudioRecorder _recorder = AudioRecorder();
  String? _currentPath;
  DateTime? _startTime;
  Timer? _ampTimer;
  final List<double> _amplitudeSamples = [];

  bool get isRecording => _currentPath != null;

  /// Duration recorded so far (updated externally via timer in chat_screen).
  int get elapsedSeconds {
    if (_startTime == null) return 0;
    return DateTime.now().difference(_startTime!).inSeconds;
  }

  /// Start recording. Returns false if mic permission denied.
  ///
  /// Encoder selection:
  /// - Android: AAC-LC (.m4a) — MediaRecorder OPUS is unreliable on Android
  ///   (hardware-dependent, fails silently in Waydroid and some devices).
  ///   AAC-LC works on every Android version since API 21.
  /// - Linux/macOS/Windows: OPUS (.opus) — native GStreamer support, best compression.
  /// - Fallback on all platforms: WAV (lossless, always works).
  Future<bool> startRecording() async {
    if (isRecording) return false;
    if (!await _recorder.hasPermission()) return false;
    final dir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    _amplitudeSamples.clear();

    final isAndroid = !kIsWeb && Platform.isAndroid;
    bool started = false;

    if (isAndroid) {
      // Android: AAC-LC in M4A container — universally supported, ~4× smaller than WAV.
      try {
        _currentPath = '${dir.path}/vm_$ts.m4a';
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            sampleRate: 44100,
            numChannels: 1,
            bitRate: 16000,
          ),
          path: _currentPath!,
        );
        started = true;
      } catch (_) {}
    } else {
      // Desktop (Linux/macOS/Windows): OPUS — best compression, GStreamer built-in.
      try {
        _currentPath = '${dir.path}/vm_$ts.opus';
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.opus,
            sampleRate: 24000,
            numChannels: 1,
            bitRate: 24000,
          ),
          path: _currentPath!,
        );
        started = true;
      } catch (_) {}
    }

    // Universal fallback: WAV.
    if (!started) {
      _currentPath = '${dir.path}/vm_$ts.wav';
      try {
        await _recorder.start(
          const RecordConfig(encoder: AudioEncoder.wav, sampleRate: 16000, numChannels: 1),
          path: _currentPath!,
        );
        started = true;
      } catch (e) {
        debugPrint('[Voice] All encoders failed: $e');
        _currentPath = null;
        return false;
      }
    }
    if (!started) return false;

    _startTime = DateTime.now();
    // Sample amplitude every 150 ms → up to _waveformBars samples per recording
    _ampTimer = Timer.periodic(const Duration(milliseconds: 150), (_) async {
      try {
        final amp = await _recorder.getAmplitude();
        // dBFS range: ~-60 (silence) to 0 (max). Normalise to 0..1
        final norm = ((amp.current + 60.0) / 60.0).clamp(0.0, 1.0);
        _amplitudeSamples.add(norm);
      } catch (e) {
        debugPrint('[Voice] Amplitude sampling error: $e');
      }
    });
    return true;
  }

  /// Stop recording and return the encoded voice message payload, or null on error.
  Future<String?> stopRecording() async {
    final raw = await stopRecordingRaw();
    if (raw == null) return null;
    try {
      final ampInt = raw.amplitudes.map((v) => (v * 100).round()).toList();
      final enc = _detectAudioFormat(raw.wavBytes);
      if (enc == 'opus' || enc == 'aac') {
        // Already compressed — no gzip.
        final b64 = base64Encode(raw.wavBytes);
        return jsonEncode({
          't': 'voice', 'd': b64,
          'dur': raw.durationSeconds, 'sz': raw.wavBytes.length,
          'amp': ampInt, 'enc': enc,
        });
      } else {
        // WAV: gzip-compress before base64.
        final compressed = gzip.encode(raw.wavBytes);
        final b64 = base64Encode(compressed);
        return jsonEncode({
          't': 'voice', 'd': b64,
          'dur': raw.durationSeconds, 'sz': raw.wavBytes.length,
          'amp': ampInt, 'z': true,
        });
      }
    } catch (e) {
      debugPrint('[VoiceService] stopRecording error: $e');
      return null;
    }
  }

  /// Stop recording and return raw WAV bytes + metadata.
  /// Used by chat_screen to decide inline vs sendFile routing.
  Future<VoiceRecording?> stopRecordingRaw() async {
    if (!isRecording) return null;
    _ampTimer?.cancel();
    _ampTimer = null;
    final duration = elapsedSeconds;
    final path = await _recorder.stop();
    _currentPath = null;
    _startTime = null;
    if (path == null) return null;
    try {
      final bytes = await File(path).readAsBytes();
      await File(path).delete().catchError((_) => File(path));
      if (bytes.isEmpty) return null;
      final amp = _resample(_amplitudeSamples, _waveformBars);
      // Only normalize raw PCM WAV — compressed formats have their own AGC.
      final enc = _detectAudioFormat(Uint8List.fromList(bytes));
      final audioBytes = enc == 'wav'
          ? _normalizeWavVolume(Uint8List.fromList(bytes))
          : Uint8List.fromList(bytes);
      return VoiceRecording(
        wavBytes: audioBytes,
        durationSeconds: duration,
        amplitudes: amp,
      );
    } catch (e) {
      debugPrint('[VoiceService] stopRecordingRaw error: $e');
      return null;
    }
  }

  /// Normalize 16-bit PCM samples in a WAV to ~90% of full scale.
  ///
  /// Parses the RIFF chunk structure to find where PCM data actually starts —
  /// the `record` plugin on Android may insert a `fact` chunk between `fmt`
  /// and `data`, making the data offset 56 bytes instead of the standard 44.
  /// The previous implementation assumed 44 and corrupted the `data` marker.
  static Uint8List _normalizeWavVolume(Uint8List wav) {
    final dataOffset = _findWavDataOffset(wav);
    if (dataOffset < 0 || wav.length <= dataOffset + 2) return wav;

    // Find peak absolute int16 LE sample value.
    int peak = 0;
    for (int i = dataOffset; i + 1 < wav.length; i += 2) {
      int s = wav[i] | (wav[i + 1] << 8);
      if (s >= 32768) s -= 65536;
      final a = s.abs();
      if (a > peak) peak = a;
    }

    if (peak == 0) return wav; // silence
    const target = 29491; // ~90% of 32767
    if (peak >= target) return wav; // already loud enough

    // Cap at 8× so we don't massively amplify room noise.
    final gain = (target / peak).clamp(1.0, 8.0);

    final out = Uint8List.fromList(wav);
    for (int i = dataOffset; i + 1 < out.length; i += 2) {
      int s = out[i] | (out[i + 1] << 8);
      if (s >= 32768) s -= 65536;
      s = (s * gain).round().clamp(-32767, 32767);
      out[i]     = s & 0xFF;
      out[i + 1] = (s >> 8) & 0xFF;
    }
    return out;
  }

  /// Walk RIFF chunks to find the byte offset where PCM audio data starts.
  /// Returns -1 if the file is not a valid RIFF WAVE or has no `data` chunk.
  static int _findWavDataOffset(Uint8List wav) {
    if (wav.length < 12) return -1;
    if (wav[0] != 0x52 || wav[1] != 0x49 || wav[2] != 0x46 || wav[3] != 0x46) return -1; // RIFF
    if (wav[8] != 0x57 || wav[9] != 0x41 || wav[10] != 0x56 || wav[11] != 0x45) return -1; // WAVE
    int pos = 12;
    while (pos + 8 <= wav.length) {
      final id = String.fromCharCodes([wav[pos], wav[pos+1], wav[pos+2], wav[pos+3]]);
      final size = wav[pos+4] | (wav[pos+5] << 8) | (wav[pos+6] << 16) | (wav[pos+7] << 24);
      if (id == 'data') return pos + 8;
      // Advance to next chunk; RIFF chunks are word-aligned (pad if odd size).
      final advance = 8 + size + (size & 1);
      if (advance <= 0) return -1; // malformed
      pos += advance;
    }
    return -1;
  }

  /// Resample [src] to [targetLen] values using linear interpolation.
  static List<double> _resample(List<double> src, int targetLen) {
    if (src.isEmpty) return List.filled(targetLen, 0.1);
    if (src.length == targetLen) return src;
    final out = <double>[];
    for (int i = 0; i < targetLen; i++) {
      final pos = i * (src.length - 1) / (targetLen - 1);
      final lo = pos.floor().clamp(0, src.length - 1);
      final hi = pos.ceil().clamp(0, src.length - 1);
      final frac = pos - lo;
      out.add(src[lo] * (1 - frac) + src[hi] * frac);
    }
    return out;
  }

  /// Cancel recording without sending.
  Future<void> cancelRecording() async {
    _ampTimer?.cancel();
    _ampTimer = null;
    _amplitudeSamples.clear();
    await _recorder.cancel();
    if (_currentPath != null) {
      await File(_currentPath!).delete().catchError((_) => File(_currentPath!));
    }
    _currentPath = null;
    _startTime = null;
  }

  Future<void> dispose() async {
    await _recorder.dispose();
  }

  /// Write voice bytes to a temp file and return its path (for playback).
  /// Accepts WAV, OGG/OPUS, and AAC/M4A.
  /// Returns null if the audio fails security validation.
  static Future<String?> writeTempAudio(Uint8List bytes) async {
    final check = MediaValidator.validateAudio(bytes);
    if (!check.isValid) {
      debugPrint('[VoiceService] Rejected audio: ${check.reason}');
      return null;
    }
    final enc = _detectAudioFormat(bytes);
    final ext = enc == 'opus' ? 'opus' : enc == 'aac' ? 'm4a' : 'wav';
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/pb_${DateTime.now().millisecondsSinceEpoch}.$ext';
    await File(path).writeAsBytes(bytes);
    return path;
  }

  /// Detect audio format from magic bytes.
  /// Returns 'opus' (OGG), 'aac' (M4A/MP4), or 'wav'.
  static String _detectAudioFormat(Uint8List b) {
    // OGG/OPUS: OggS = 4F 67 67 53
    if (b.length >= 4 &&
        b[0] == 0x4F && b[1] == 0x67 && b[2] == 0x67 && b[3] == 0x53) {
      return 'opus';
    }
    // M4A/AAC: 'ftyp' box at offset 4 (66 74 79 70)
    if (b.length >= 8 &&
        b[4] == 0x66 && b[5] == 0x74 && b[6] == 0x79 && b[7] == 0x70) {
      return 'aac';
    }
    return 'wav';
  }
}
