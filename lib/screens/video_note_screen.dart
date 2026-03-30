import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../services/video_note_service.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../l10n/l10n_ext.dart';

/// Full-screen dark modal with circular camera preview for recording video notes.
/// Returns [VideoNoteRecording?] via Navigator.pop.
class VideoNoteScreen extends StatefulWidget {
  const VideoNoteScreen({super.key});

  @override
  State<VideoNoteScreen> createState() => _VideoNoteScreenState();
}

class _VideoNoteScreenState extends State<VideoNoteScreen> {
  final RTCVideoRenderer _renderer = RTCVideoRenderer();
  final VideoNoteService _service = VideoNoteService();
  bool _cameraReady = false;
  bool _recording = false;
  int _seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    await _renderer.initialize();
    final stream = await _service.initCamera();
    if (stream == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.videoNoteCameraPermission)),
        );
        Navigator.pop(context);
      }
      return;
    }
    _renderer.srcObject = stream;
    if (mounted) setState(() => _cameraReady = true);
  }

  Future<void> _toggleRecording() async {
    if (_recording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    HapticFeedback.mediumImpact();
    final started = await _service.startRecording();
    if (!started) return;
    setState(() {
      _recording = true;
      _seconds = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _seconds++);
      if (_seconds >= _service.maxDuration) {
        _stopRecording();
      }
    });
  }

  Future<void> _stopRecording() async {
    HapticFeedback.lightImpact();
    _timer?.cancel();
    _timer = null;
    final result = await _service.stopRecording();
    if (mounted) {
      setState(() => _recording = false);
      Navigator.pop(context, result);
    }
  }

  Future<void> _close() async {
    _timer?.cancel();
    _timer = null;
    if (_recording) {
      await _service.cancelRecording();
    }
    await _service.dispose();
    try {
      _renderer.srcObject = null;
    } catch (_) {}
    try {
      await _renderer.dispose();
    } catch (_) {}
    if (mounted) Navigator.pop(context);
  }

  String _formatTime(int s) =>
      '${(s ~/ 60).toString().padLeft(1, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _timer?.cancel();
    _service.dispose();
    try {
      _renderer.srcObject = null;
    } catch (_) {}
    try {
      _renderer.dispose();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const previewSize = 280.0;
    final progress = _seconds / _service.maxDuration;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Centered circular preview
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Timer
                  if (_recording)
                    Padding(
                      padding: const EdgeInsets.only(bottom: DesignTokens.spacing14),
                      child: Text(
                        _formatTime(_seconds),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  // Camera preview circle with progress ring
                  SizedBox(
                    width: previewSize + 8,
                    height: previewSize + 8,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Progress ring (behind preview)
                        if (_recording)
                          SizedBox(
                            width: previewSize + 8,
                            height: previewSize + 8,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 4,
                              color: Colors.red,
                              backgroundColor: Colors.white24,
                            ),
                          ),
                        // Camera preview
                        ClipOval(
                          child: SizedBox(
                            width: previewSize,
                            height: previewSize,
                            child: _cameraReady
                                ? RTCVideoView(
                                    _renderer,
                                    mirror: true,
                                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                                  )
                                : Container(
                                    color: AppTheme.surfaceVariant,
                                    child: const Center(
                                      child: CircularProgressIndicator(color: Colors.white54),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Record button
                  GestureDetector(
                    onTap: _cameraReady ? _toggleRecording : null,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: _recording ? 28 : 60,
                          height: _recording ? 28 : 60,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(_recording ? 6 : 30),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _recording
                        ? context.l10n.videoNoteTapToStop
                        : context.l10n.videoNoteTapToRecord,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            // Close button (top-left)
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                onPressed: _close,
              ),
            ),
            // Flip camera (top-right)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white, size: 28),
                onPressed: _service.switchCamera,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
