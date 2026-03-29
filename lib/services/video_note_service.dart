import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:path_provider/path_provider.dart';

const int _maxDurationSeconds = 30;

/// Raw video note recording data.
class VideoNoteRecording {
  final Uint8List mp4Bytes;
  final int durationSeconds;
  final Uint8List? thumbnailJpeg;

  const VideoNoteRecording({
    required this.mp4Bytes,
    required this.durationSeconds,
    this.thumbnailJpeg,
  });
}

/// Records circular video notes using flutter_webrtc camera + MediaRecorder.
/// Falls back to file picker on unsupported platforms (Linux/Windows).
class VideoNoteService {
  static final VideoNoteService _instance = VideoNoteService._();
  factory VideoNoteService() => _instance;
  VideoNoteService._();

  MediaStream? _localStream;
  MediaRecorder? _recorder;
  String? _outputPath;
  DateTime? _startTime;
  bool _recording = false;

  bool get isRecording => _recording;
  int get maxDuration => _maxDurationSeconds;

  int get elapsedSeconds {
    if (_startTime == null) return 0;
    return DateTime.now().difference(_startTime!).inSeconds;
  }

  /// Whether camera recording is supported on this platform.
  static bool get isSupported => true;

  /// Initialise the front camera and return the local stream for preview.
  /// Returns null if camera permission is denied or unavailable.
  Future<MediaStream?> initCamera() async {
    try {
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {
          'width': 360,
          'height': 360,
          'frameRate': 30,
          'facingMode': 'user',
        },
      });
      return _localStream;
    } catch (e) {
      debugPrint('[VideoNote] getUserMedia error: $e');
      return null;
    }
  }

  /// Start recording to a temp mp4 file.
  Future<bool> startRecording() async {
    if (_recording || _localStream == null) return false;
    try {
      final dir = await getTemporaryDirectory();
      _outputPath = '${dir.path}/vn_${DateTime.now().millisecondsSinceEpoch}.mp4';
      _recorder = MediaRecorder();
      final videoTrack = _localStream!.getVideoTracks().first;
      await _recorder!.start(
        _outputPath!,
        videoTrack: videoTrack,
        audioChannel: RecorderAudioChannel.INPUT,
      );
      _startTime = DateTime.now();
      _recording = true;
      return true;
    } catch (e) {
      debugPrint('[VideoNote] startRecording error: $e');
      return false;
    }
  }

  /// Stop recording and return the result.
  Future<VideoNoteRecording?> stopRecording() async {
    if (!_recording || _recorder == null) return null;
    _recording = false;
    final duration = elapsedSeconds;
    try {
      await _recorder!.stop();
      _recorder = null;
      _startTime = null;

      if (_outputPath == null) return null;
      final file = File(_outputPath!);
      if (!await file.exists()) return null;
      final bytes = await file.readAsBytes();
      await file.delete().catchError((_) => file);
      _outputPath = null;

      if (bytes.isEmpty) return null;

      // Capture thumbnail from the still-active stream before disposing
      Uint8List? thumbnail;
      try {
        thumbnail = await _captureThumbnail();
      } catch (e) {
        debugPrint('[VideoNote] thumbnail capture failed: $e');
      }

      return VideoNoteRecording(
        mp4Bytes: Uint8List.fromList(bytes),
        durationSeconds: duration,
        thumbnailJpeg: thumbnail,
      );
    } catch (e) {
      debugPrint('[VideoNote] stopRecording error: $e');
      return null;
    }
  }

  /// Capture a frame from the video track as a JPEG thumbnail.
  Future<Uint8List?> _captureThumbnail() async {
    final tracks = _localStream?.getVideoTracks();
    if (tracks == null || tracks.isEmpty) return null;
    try {
      // flutter_webrtc captureFrame returns a ByteBuffer (RGBA/ARGB)
      // On mobile, we can get a frame — but format varies.
      // For now, return null and let the receiver show the videocam icon
      // until we have the first frame from playback.
      return null;
    } catch (e) {
      debugPrint('[VideoNote] captureFrame error: $e');
      return null;
    }
  }

  /// Cancel recording without returning data.
  Future<void> cancelRecording() async {
    _recording = false;
    try {
      await _recorder?.stop();
    } catch (_) {}
    _recorder = null;
    _startTime = null;
    if (_outputPath != null) {
      await File(_outputPath!).delete().catchError((_) => File(_outputPath!));
      _outputPath = null;
    }
  }

  /// Switch between front and back camera.
  Future<void> switchCamera() async {
    final tracks = _localStream?.getVideoTracks();
    if (tracks == null || tracks.isEmpty) return;
    try {
      await Helper.switchCamera(tracks.first);
    } catch (e) {
      debugPrint('[VideoNote] switchCamera error: $e');
    }
  }

  /// Release camera resources.
  Future<void> dispose() async {
    await cancelRecording();
    if (_localStream != null) {
      for (final track in _localStream!.getTracks()) {
        await track.stop();
      }
      await _localStream!.dispose();
      _localStream = null;
    }
  }
}
