import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Handles voice message recording.
/// Playback is handled per-bubble via audioplayers (see message_bubble.dart).
class VoiceService {
  static final VoiceService _instance = VoiceService._();
  factory VoiceService() => _instance;
  VoiceService._();

  final AudioRecorder _recorder = AudioRecorder();
  String? _currentPath;
  DateTime? _startTime;

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
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: _currentPath!,
    );
    _startTime = DateTime.now();
    return true;
  }

  /// Stop recording and return the encoded voice message payload, or null on error.
  Future<String?> stopRecording() async {
    if (!isRecording) return null;
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
      return jsonEncode({
        't': 'voice',
        'd': b64,
        'dur': duration,
        'sz': bytes.length,
      });
    } catch (e) {
      debugPrint('[VoiceService] stopRecording error: $e');
      return null;
    }
  }

  /// Cancel recording without sending.
  Future<void> cancelRecording() async {
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
  static Future<String> writeTempAudio(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/pb_${DateTime.now().millisecondsSinceEpoch}.wav';
    await File(path).writeAsBytes(bytes);
    return path;
  }
}
