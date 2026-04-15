import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../l10n/l10n_ext.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../services/media_service.dart';
import '../services/media_crypto_service.dart';
import '../services/blossom_service.dart';
import '../services/video_service.dart';
import '../services/voice_service.dart';
import '../screens/image_viewer_screen.dart';

// ─── Voice bubble ─────────────────────────────────────────────────────────────

class VoiceBubble extends StatefulWidget {
  final MediaPayload media;
  final bool isMe;
  final Color bgColor;
  final BorderRadius radius;
  final Widget Function() buildTimestamp;

  const VoiceBubble({
    super.key,
    required this.media,
    required this.isMe,
    required this.bgColor,
    required this.radius,
    required this.buildTimestamp,
  });

  @override
  State<VoiceBubble> createState() => _VoiceBubbleState();
}

class _VoiceBubbleState extends State<VoiceBubble> {
  final AudioPlayer _player = AudioPlayer();
  late final List<StreamSubscription> _playerSubs;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _total = Duration.zero;
  String? _tmpPath;
  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    _total = Duration(seconds: widget.media.durationSeconds);
    _playerSubs = [
      _player.onPlayerStateChanged.listen((state) {
        if (!mounted) return;
        setState(() => _isPlaying = state == PlayerState.playing);
      }),
      _player.onPositionChanged.listen((pos) {
        if (!mounted) return;
        setState(() => _position = pos);
      }),
      _player.onDurationChanged.listen((dur) {
        if (!mounted) return;
        setState(() => _total = dur);
      }),
      _player.onPlayerComplete.listen((_) {
        if (!mounted) return;
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
        // Delete temp file after playback ends; it will be re-created on replay.
        if (_tmpPath != null) {
          File(_tmpPath!).delete().catchError((_) => File(_tmpPath!));
          _tmpPath = null;
        }
      }),
    ];
  }

  @override
  void dispose() {
    for (final s in _playerSubs) {
      s.cancel();
    }
    _player.dispose();
    if (_tmpPath != null) {
      File(_tmpPath!).delete().catchError((_) => File(_tmpPath!));
    }
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
      return;
    }
    _tmpPath ??= await VoiceService.writeTempAudio(widget.media.data);
    if (_tmpPath == null) return; // security rejection
    if (_position > Duration.zero) {
      await _player.resume();
    } else {
      await _player.play(DeviceFileSource(_tmpPath!));
    }
    // Only send a rate-change seek event when speed differs from the GStreamer
    // default (1.0). Calling setPlaybackRate(1.0) right after play() triggers
    // a pipeline flush before qtdemux finishes initialising M4A files, which
    // causes a premature EOS on the first play on Linux.
    if (_speed != 1.0) {
      await _player.setPlaybackRate(_speed);
    }
  }

  Future<void> _cycleSpeed() async {
    setState(() {
      _speed = _speed == 1.0 ? 1.5 : _speed == 1.5 ? 2.0 : 1.0;
    });
    if (_isPlaying) {
      await _player.setPlaybackRate(_speed);
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(1, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _total.inMilliseconds > 0
        ? (_position.inMilliseconds / _total.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;
    final durLabel = _isPlaying || _position > Duration.zero
        ? _fmt(_position)
        : _fmt(_total);

    return Container(
      decoration: BoxDecoration(color: widget.bgColor, borderRadius: widget.radius),
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing10, vertical: DesignTokens.chatBubblePaddingV),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              width: DesignTokens.avatarXs,
              height: DesignTokens.avatarXs,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: DesignTokens.iconMd,
              ),
            ),
          ),
          const SizedBox(width: DesignTokens.spacing8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Waveform progress bar
              SizedBox(
                width: 120,
                height: 28,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background bars
                    WaveformBars(progress: 0.0, color: Colors.white.withValues(alpha: 0.25),
                        amplitudes: widget.media.amplitudes),
                    // Foreground bars (played portion)
                    ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: WaveformBars(progress: 1.0, color: Colors.white.withValues(alpha: 0.9),
                            amplitudes: widget.media.amplitudes),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DesignTokens.spacing2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(durLabel,
                      style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: DesignTokens.fontXs)),
                  const SizedBox(width: DesignTokens.spacing6),
                  GestureDetector(
                    onTap: _cycleSpeed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: DesignTokens.spacing2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: DesignTokens.opacityLight),
                        borderRadius: BorderRadius.circular(DesignTokens.spacing4),
                      ),
                      child: Text(
                        _speed == 1.0 ? '1x' : _speed == 1.5 ? '1.5x' : '2x',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: DesignTokens.fontXxs,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spacing6),
                  widget.buildTimestamp(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Video note bubble (circular) ────────────────────────────────────────────

class VideoNoteBubble extends StatefulWidget {
  final MediaPayload media;
  final bool isMe;
  final Widget Function() buildTimestamp;
  final String status;
  final double? uploadProgress;

  const VideoNoteBubble({
    super.key,
    required this.media,
    required this.isMe,
    required this.buildTimestamp,
    this.status = '',
    this.uploadProgress,
  });

  @override
  State<VideoNoteBubble> createState() => _VideoNoteBubbleState();
}

class _VideoNoteBubbleState extends State<VideoNoteBubble> {
  VideoPlayerController? _controller;
  bool _playing = false;
  String? _tmpPath;

  @override
  void dispose() {
    _controller?.dispose();
    if (_tmpPath != null) {
      File(_tmpPath!).delete().catchError((_) => File(_tmpPath!));
    }
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_controller != null && _playing) {
      await _controller!.pause();
      if (mounted) setState(() => _playing = false);
      return;
    }
    if (_controller == null) {
      _tmpPath = await VideoService.writeTempVideo(widget.media.data);
      final ctrl = VideoPlayerController.file(File(_tmpPath!));
      await ctrl.initialize();
      ctrl.addListener(() {
        if (!mounted) return;
        if (ctrl.value.position >= ctrl.value.duration && ctrl.value.duration > Duration.zero) {
          setState(() => _playing = false);
          ctrl.seekTo(Duration.zero);
          ctrl.pause();
        }
      });
      _controller = ctrl;
    }
    await _controller!.play();
    if (mounted) setState(() => _playing = true);
  }

  @override
  Widget build(BuildContext context) {
    const size = 200.0;
    return Column(
      crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _togglePlay,
          child: ClipOval(
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Thumbnail or video
                  if (_controller != null && _controller!.value.isInitialized)
                    FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller!.value.size.width,
                        height: _controller!.value.size.height,
                        child: VideoPlayer(_controller!),
                      ),
                    )
                  else if (widget.media.thumbnailData != null)
                    Image.memory(widget.media.thumbnailData!, fit: BoxFit.cover,
                        gaplessPlayback: true)
                  else
                    Container(color: AppTheme.surfaceVariant,
                        child: const Icon(Icons.videocam_rounded, color: Colors.white54, size: DesignTokens.spacing48)),
                  // Upload progress overlay
                  if (widget.status == 'sending')
                    Center(
                      child: SizedBox(
                        width: DesignTokens.spacing48, height: DesignTokens.spacing48,
                        child: CircularProgressIndicator(
                          value: widget.uploadProgress,
                          strokeWidth: 3,
                          color: Colors.white,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                    )
                  // Play icon overlay
                  else if (!_playing)
                    Center(
                      child: Container(
                        width: DesignTokens.spacing48, height: DesignTokens.spacing48,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: DesignTokens.iconXl),
                      ),
                    ),
                  // Duration label
                  if (widget.media.durationSeconds > 0)
                    Positioned(
                      bottom: DesignTokens.spacing8, right: DesignTokens.spacing12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing6, vertical: DesignTokens.spacing2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: DesignTokens.opacityHeavy),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                        ),
                        child: Text(
                          '${widget.media.durationSeconds ~/ 60}:${(widget.media.durationSeconds % 60).toString().padLeft(2, '0')}',
                          style: GoogleFonts.inter(color: Colors.white, fontSize: DesignTokens.fontXs),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 3),
        widget.buildTimestamp(),
      ],
    );
  }
}

// ─── GIF bubble ──────────────────────────────────────────────────────────────

class GifBubble extends StatelessWidget {
  final MediaPayload media;
  final bool isMe;
  final BorderRadius radius;
  final Widget Function() buildTimestamp;

  const GifBubble({
    super.key,
    required this.media,
    required this.isMe,
    required this.radius,
    required this.buildTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260, maxHeight: 260),
                child: Image.memory(
                  media.data,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder: (context, error, stack) => Container(
                    width: 260, height: 120,
                    color: Colors.black26,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image_rounded, color: Colors.white54, size: DesignTokens.iconXl),
                  ),
                ),
              ),
              // GIF badge
              Positioned(
                top: DesignTokens.spacing8, left: DesignTokens.spacing8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing6, vertical: DesignTokens.spacing2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: DesignTokens.opacityHeavy),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(context.l10n.gifLabel,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: DesignTokens.fontXs,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
          // Timestamp bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing8, vertical: DesignTokens.spacing4),
            color: Colors.black.withValues(alpha: 0.35),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [buildTimestamp()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Waveform bars. Uses real amplitude data when available, static pattern otherwise.
class WaveformBars extends StatelessWidget {
  final double progress;
  final Color color;
  final List<double>? amplitudes;

  const WaveformBars({super.key, required this.progress, required this.color, this.amplitudes});

  static const _static = [6.0, 10.0, 16.0, 12.0, 20.0, 14.0, 8.0, 18.0,
    22.0, 12.0, 16.0, 8.0, 20.0, 14.0, 10.0, 18.0, 6.0, 14.0, 22.0, 10.0,
    16.0, 8.0, 20.0, 12.0, 18.0, 6.0, 14.0, 22.0, 10.0, 16.0];

  @override
  Widget build(BuildContext context) {
    final heights = amplitudes != null
        // Map 0..1 amplitude to 4..24 px height
        ? amplitudes!.map((v) => 4.0 + v * 20.0).toList()
        : _static;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: heights.map((h) => Container(
        width: 3,
        height: h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(DesignTokens.radiusXs),
        ),
      )).toList(),
    );
  }
}

// ── Blossom lazy-download media widget ────────────────────────────────────

class BlossomMediaWidget extends StatefulWidget {
  final BlossomPayload payload;
  final BorderRadius radius;
  final bool isMe;

  const BlossomMediaWidget({
    super.key,
    required this.payload,
    required this.radius,
    required this.isMe,
  });

  @override
  State<BlossomMediaWidget> createState() => _BlossomMediaWidgetState();
}

class _BlossomMediaWidgetState extends State<BlossomMediaWidget> {
  Uint8List? _decryptedBytes;
  bool _loading = false;
  double _progress = 0;
  String? _error;
  Uint8List? _thumbnailBytes;

  @override
  void initState() {
    super.initState();
    _decodeThumbnail();
    _checkCache();
  }

  @override
  void didUpdateWidget(BlossomMediaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.payload.thumbnail != widget.payload.thumbnail) {
      _decodeThumbnail();
    }
  }

  void _decodeThumbnail() {
    final t = widget.payload.thumbnail;
    _thumbnailBytes = (t != null && t.isNotEmpty) ? base64Decode(t) : null;
  }

  Future<void> _checkCache() async {
    try {
      final dir = await getTemporaryDirectory();
      final ext = _extensionFromName(widget.payload.name);
      final file = File('${dir.path}/blossom_${widget.payload.hash}$ext');
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        if (mounted) {
          setState(() {
            _decryptedBytes = bytes;
            // cached on disk
          });
        }
      } else if (widget.payload.mediaType == 'img' || widget.payload.mediaType == 'gif') {
        // Auto-download images
        _download();
      }
    } catch (_) {}
  }

  Future<void> _download() async {
    if (_loading) return;
    if (widget.payload.hash.isEmpty || widget.payload.key.isEmpty) {
      setState(() => _error = context.l10n.mediaMissingData);
      return;
    }
    setState(() { _loading = true; _progress = 0.1; _error = null; });

    try {
      final encrypted = await BlossomService.instance.download(
        widget.payload.hash,
        preferredServers: [widget.payload.server],
      );
      if (encrypted == null) {
        if (mounted) setState(() { _loading = false; _error = context.l10n.mediaDownloadFailed; });
        return;
      }
      if (mounted) setState(() => _progress = 0.7);

      final key = base64Decode(widget.payload.key);
      final iv = base64Decode(widget.payload.iv);
      final decrypted = MediaCryptoService.decrypt(encrypted, Uint8List.fromList(key), Uint8List.fromList(iv));
      if (mounted) setState(() => _progress = 0.9);

      // Cache to disk
      final dir = await getTemporaryDirectory();
      final ext = _extensionFromName(widget.payload.name);
      final file = File('${dir.path}/blossom_${widget.payload.hash}$ext');
      await file.writeAsBytes(decrypted);

      if (mounted) {
        setState(() {
          _decryptedBytes = decrypted;
          _loading = false;
          _progress = 1.0;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = context.l10n.mediaDecryptFailed; });
    }
  }

  String _extensionFromName(String name) {
    final dot = name.lastIndexOf('.');
    if (dot == -1) return '';
    return name.substring(dot);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.payload;
    final isImage = p.mediaType == 'img' || p.mediaType == 'gif';

    // Already downloaded — show content
    if (_decryptedBytes != null) {
      if (isImage) {
        return ClipRRect(
          borderRadius: widget.radius,
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ImageViewerScreen(imageData: _decryptedBytes!, name: p.name))),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260, maxHeight: 320),
              child: Image.memory(_decryptedBytes!, fit: BoxFit.cover),
            ),
          ),
        );
      }
      // Non-image file — show download card with "saved" state
      return _buildFileCard(context, downloaded: true);
    }

    // Thumbnail preview (if available) or placeholder
    if (isImage && _thumbnailBytes != null) {
      return ClipRRect(
        borderRadius: widget.radius,
        child: GestureDetector(
          onTap: _loading ? null : _download,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260, maxHeight: 320),
                child: Opacity(
                  opacity: 0.5,
                  child: Image.memory(
                    _thumbnailBytes!,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
                ),
              ),
              if (_loading)
                SizedBox(
                  width: DesignTokens.spacing48, height: DesignTokens.spacing48,
                  child: CircularProgressIndicator(
                    value: _progress > 0 ? _progress : null,
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                )
              else if (_error != null)
                const Icon(Icons.error_outline, color: Colors.red, size: 36)
              else
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
                  ),
                  padding: const EdgeInsets.all(DesignTokens.spacing10),
                  child: const Icon(Icons.download, color: Colors.white, size: 28),
                ),
            ],
          ),
        ),
      );
    }

    // Generic file card (non-image or no thumbnail)
    return _buildFileCard(context, downloaded: false);
  }

  Widget _buildFileCard(BuildContext context, {required bool downloaded}) {
    final p = widget.payload;
    return GestureDetector(
      onTap: downloaded ? null : (_loading ? null : _download),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing12, vertical: DesignTokens.spacing10),
        constraints: const BoxConstraints(maxWidth: 260),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              downloaded ? Icons.insert_drive_file : (_loading ? Icons.hourglass_top : Icons.cloud_download),
              color: Colors.white70,
              size: DesignTokens.iconMd,
            ),
            const SizedBox(width: DesignTokens.spacing8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    p.name,
                    style: GoogleFonts.inter(fontSize: DesignTokens.fontSm, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: DesignTokens.spacing2),
                  Text(
                    _error ?? p.sizeLabel,
                    style: GoogleFonts.inter(fontSize: DesignTokens.fontXs, color: _error != null ? Colors.red[300] : Colors.white54),
                  ),
                  if (_loading)
                    Padding(
                      padding: const EdgeInsets.only(top: DesignTokens.spacing4),
                      child: LinearProgressIndicator(
                        value: _progress > 0 ? _progress : null,
                        minHeight: DesignTokens.spacing2,
                        backgroundColor: Colors.white12,
                        color: AppTheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
