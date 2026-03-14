import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'media_validator.dart';

// Number of amplitude samples stored in the waveform (shown as bars in the bubble).
const _waveformBars = 30;

/// Handles voice message recording.
/// Playback is handled per-bubble via audioplayers (see message_bubble.dart).
class VoiceService {
  static final VoiceService _instance = VoiceService._();
  factory VoiceService() => _instance;
  VoiceService._();

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
  Future<bool> startRecording() async {
    if (isRecording) return false;
    if (!await _recorder.hasPermission()) return false;
    final dir = await getTemporaryDirectory();
    _currentPath = '${dir.path}/vm_${DateTime.now().millisecondsSinceEpoch}.wav';
    _amplitudeSamples.clear();
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: _currentPath!,
    );
    _startTime = DateTime.now();
    // Sample amplitude every 150 ms → up to _waveformBars samples per recording
    _ampTimer = Timer.periodic(const Duration(milliseconds: 150), (_) async {
      try {
        final amp = await _recorder.getAmplitude();
        // dBFS range: ~-60 (silence) to 0 (max). Normalise to 0..1
        final norm = ((amp.current + 60.0) / 60.0).clamp(0.0, 1.0);
        _amplitudeSamples.add(norm);
      } catch (_) {}
    });
    return true;
  }

  /// Stop recording and return the encoded voice message payload, or null on error.
  Future<String?> stopRecording() async {
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
      final b64 = base64Encode(bytes);
      // Downsample / upsample to exactly _waveformBars values
      final amp = _resample(_amplitudeSamples, _waveformBars);
      // Encode as integers 0-100 to keep JSON small
      final ampInt = amp.map((v) => (v * 100).round()).toList();
      return jsonEncode({
        't': 'voice',
        'd': b64,
        'dur': duration,
        'sz': bytes.length,
        'amp': ampInt,
      });
    } catch (e) {
      debugPrint('[VoiceService] stopRecording error: $e');
      return null;
    }
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
  /// Returns null if the audio fails security validation.
  static Future<String?> writeTempAudio(Uint8List bytes) async {
    final check = MediaValidator.validateAudio(bytes);
    if (!check.isValid) {
      debugPrint('[VoiceService] Rejected audio: ${check.reason}');
      return null;
    }
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/pb_${DateTime.now().millisecondsSinceEpoch}.wav';
    await File(path).writeAsBytes(bytes);
    return path;
  }
}
