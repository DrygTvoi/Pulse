import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/signaling_service.dart';
import '../services/call_transport.dart';
import '../theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/contact.dart';

class CallScreen extends StatefulWidget {
  final Contact contact;
  final String myId;
  final bool isVideoCall;
  final bool isCaller;

  const CallScreen({
    super.key,
    required this.contact,
    required this.myId,
    required this.isVideoCall,
    this.isCaller = true,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  SignalingService? _signaling;
  final RTCVideoRenderer _localRenderer  = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  bool _isMuted       = false;
  bool _isCameraOff   = false;
  bool _isScreenSharing = false;
  bool _showControls  = true;

  RTCIceConnectionState _iceState =
      RTCIceConnectionState.RTCIceConnectionStateNew;

  // Transport profile state
  CallTransportProfile _currentProfile = CallTransportProfile.auto;
  bool _autoRetried = false;   // true after we've switched to restricted once
  bool _isRetrying  = false;   // guard against concurrent retries

  Timer? _hideControlsTimer;
  Timer? _durationTimer;
  Duration _callDuration = Duration.zero;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _initWebRTC();
  }

  // ── Initialise / reinitialise ──────────────────────────────────────────────

  Future<void> _initWebRTC({
    CallTransportProfile profile = CallTransportProfile.auto,
  }) async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    _signaling = SignalingService(
      contact: widget.contact,
      myId:    widget.myId,
      isCaller: widget.isCaller,
    );

    _signaling!.onAddRemoteStream = (stream) {
      if (mounted) setState(() => _remoteRenderer.srcObject = stream);
    };

    _signaling!.onConnectionState = _onIceState;

    await _signaling!.init(profile: profile);
    if (_disposed) return;

    await _openUserMedia();
    if (_disposed) return;

    if (widget.isCaller) await _signaling!.createOffer();
    if (mounted) _resetHideControlsTimer();
  }

  // ── ICE state handler with auto-retry ─────────────────────────────────────

  void _onIceState(RTCIceConnectionState state) {
    if (!mounted) return;
    setState(() => _iceState = state);

    if (state == RTCIceConnectionState.RTCIceConnectionStateConnected ||
        state == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
      _startDurationTimer();
    }

    if (state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
      _durationTimer?.cancel();
      if (!_autoRetried && !_isRetrying) {
        _retryRestricted();
      }
    }

    if (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
      _durationTimer?.cancel();
    }
  }

  /// Switches to RestrictedProfile (relay-only, TLS/TCP 443) on ICE failure.
  /// Closes the old peer connection, creates a new one, re-sends offer if caller.
  /// The callee also detects ICE failure independently and reinits its side,
  /// so it will be ready to receive the new offer.
  Future<void> _retryRestricted() async {
    if (_disposed || _autoRetried || _isRetrying) return;
    if (mounted) setState(() => _isRetrying = true);

    await _signaling?.reinitPeerConnection(CallTransportProfile.restricted);
    if (_disposed) return;

    if (mounted) {
      setState(() {
        _autoRetried    = true;
        _isRetrying     = false;
        _currentProfile = CallTransportProfile.restricted;
        _iceState       = RTCIceConnectionState.RTCIceConnectionStateChecking;
      });
    }

    if (widget.isCaller) {
      // Give callee ~600 ms to reinit its peer connection
      await Future.delayed(const Duration(milliseconds: 600));
      if (_disposed) return;
      await _signaling?.createOffer();
    }
  }

  // ── Media ──────────────────────────────────────────────────────────────────

  Future<void> _openUserMedia() async {
    final constraints = <String, dynamic>{
      'audio': true,
      'video': widget.isVideoCall
          ? {
              'mandatory': {
                'minWidth':     '640',
                'minHeight':    '480',
                'minFrameRate': '30',
              },
              'facingMode': 'user',
              'optional': [],
            }
          : false,
    };
    try {
      final stream = await navigator.mediaDevices.getUserMedia(constraints);
      _localRenderer.srcObject = stream;
      _signaling?.localStream = stream;
      stream.getTracks().forEach((t) => _signaling?.peerConnection?.addTrack(t, stream));
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('getUserMedia error: $e');
    }
  }

  Future<void> _toggleScreenShare() async {
    if (!widget.isVideoCall) return;
    try {
      if (_isScreenSharing) {
        final stream = await navigator.mediaDevices.getUserMedia({'audio': false, 'video': true});
        await _replaceVideoTrack(stream);
        setState(() => _isScreenSharing = false);
      } else {
        final stream = await navigator.mediaDevices.getDisplayMedia({'video': true, 'audio': false});
        await _replaceVideoTrack(stream);
        setState(() => _isScreenSharing = true);
      }
    } catch (e) {
      debugPrint('Screen share error: $e');
    }
  }

  Future<void> _replaceVideoTrack(MediaStream newStream) async {
    final newTrack = newStream.getVideoTracks().first;
    final senders = await _signaling?.peerConnection?.getSenders();
    final videoSender = senders?.cast<RTCRtpSender?>().firstWhere(
      (s) => s?.track?.kind == 'video',
      orElse: () => null,
    );
    await videoSender?.replaceTrack(newTrack);
    _localRenderer.srcObject = newStream;
    _signaling?.localStream?.getVideoTracks().forEach((t) => t.stop());
    _signaling?.localStream = newStream;
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    _signaling?.localStream?.getAudioTracks().forEach((t) => t.enabled = !_isMuted);
  }

  void _toggleCamera() {
    if (!widget.isVideoCall || _isScreenSharing) return;
    setState(() => _isCameraOff = !_isCameraOff);
    _signaling?.localStream?.getVideoTracks().forEach((t) => t.enabled = !_isCameraOff);
  }

  void _hangUp() {
    if (_disposed) return;
    _disposed = true;
    _durationTimer?.cancel();
    _hideControlsTimer?.cancel();
    _signaling?.hangUp();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    if (mounted) Navigator.pop(context);
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _callDuration += const Duration(seconds: 1));
    });
  }

  void _resetHideControlsTimer() {
    _hideControlsTimer?.cancel();
    if (!_showControls) setState(() => _showControls = true);
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && widget.isVideoCall && _remoteRenderer.srcObject != null) {
        setState(() => _showControls = false);
      }
    });
  }

  @override
  void dispose() {
    if (!_disposed) {
      _disposed = true;
      _durationTimer?.cancel();
      _hideControlsTimer?.cancel();
      _signaling?.hangUp();
      _localRenderer.dispose();
      _remoteRenderer.dispose();
    }
    super.dispose();
  }

  // ── Status helpers ─────────────────────────────────────────────────────────

  String get _statusLabel {
    if (_isRetrying) return 'Switching to relay mode…';
    switch (_iceState) {
      case RTCIceConnectionState.RTCIceConnectionStateNew:
      case RTCIceConnectionState.RTCIceConnectionStateChecking:
        return _currentProfile.isRestricted ? 'Connecting (relay)…' : 'Connecting…';
      case RTCIceConnectionState.RTCIceConnectionStateConnected:
      case RTCIceConnectionState.RTCIceConnectionStateCompleted:
        return _formatDuration(_callDuration);
      case RTCIceConnectionState.RTCIceConnectionStateFailed:
        return _autoRetried ? 'Connection failed (relay also failed)' : 'Connection failed';
      case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
        return 'Reconnecting…';
      case RTCIceConnectionState.RTCIceConnectionStateClosed:
        return 'Call ended';
      default:
        return 'Connecting…';
    }
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  bool get _isConnected =>
      _iceState == RTCIceConnectionState.RTCIceConnectionStateConnected ||
      _iceState == RTCIceConnectionState.RTCIceConnectionStateCompleted;

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final hasRemoteVideo = widget.isVideoCall && _remoteRenderer.srcObject != null;
    final hasLocalVideo  = widget.isVideoCall && _localRenderer.srcObject != null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTap: hasRemoteVideo ? _resetHideControlsTimer : null,
          child: Stack(
            children: [
              // ── Background / Remote ──────────────────────────────────────
              hasRemoteVideo
                  ? Positioned.fill(
                      child: RTCVideoView(
                        _remoteRenderer,
                        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                    )
                  : _buildAudioBackground(),

              // ── Local video (PiP) ────────────────────────────────────────
              if (hasLocalVideo)
                Positioned(
                  right: 16,
                  top: 60,
                  child: Container(
                    width: 110,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _isScreenSharing ? Colors.blueAccent : AppTheme.primary,
                        width: 2,
                      ),
                      boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10)],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: RTCVideoView(
                        _localRenderer,
                        mirror: !_isScreenSharing,
                        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                    ),
                  ).animate().scale(delay: 300.ms),
                ),

              // ── Restricted-mode banner ───────────────────────────────────
              if (_currentProfile.isRestricted || _isRetrying)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildRestrictedBanner(),
                ),

              // ── Top bar ──────────────────────────────────────────────────
              AnimatedOpacity(
                opacity: _showControls || !hasRemoteVideo ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Positioned(
                  top: (_currentProfile.isRestricted || _isRetrying) ? 28 : 0,
                  left: 0,
                  right: 0,
                  child: _buildTopBar(),
                ),
              ),

              // ── Bottom controls ──────────────────────────────────────────
              AnimatedOpacity(
                opacity: _showControls || !hasRemoteVideo ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: _buildControlBar(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Restricted-mode banner ─────────────────────────────────────────────────

  Widget _buildRestrictedBanner() {
    final isRetrying = _isRetrying;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      color: isRetrying
          ? Colors.orange.withValues(alpha: 0.85)
          : Colors.blueGrey.withValues(alpha: 0.85),
      child: Row(children: [
        Icon(
          isRetrying ? Icons.sync_rounded : Icons.shield_rounded,
          color: Colors.white,
          size: 14,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            isRetrying
                ? 'Direct connection failed — switching to relay mode…'
                : 'Relay mode active (restricted network)',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ]),
    );
  }

  // ── Audio background ───────────────────────────────────────────────────────

  Widget _buildAudioBackground() {
    final name    = widget.contact.name;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final hue     = (name.codeUnitAt(0) * 17 + name.length * 31) % 360;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            HSLColor.fromAHSL(1, hue.toDouble(), 0.4, 0.2).toColor(),
            Colors.black,
          ],
        ),
      ),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Stack(alignment: Alignment.center, children: [
            if (!_isConnected)
              Container(
                width: 140, height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: HSLColor.fromAHSL(1, hue.toDouble(), 0.5, 0.3)
                      .toColor()
                      .withValues(alpha: 0.3),
                ),
              ).animate(onPlay: (c) => c.repeat()).scale(
                begin: const Offset(1, 1),
                end:   const Offset(1.3, 1.3),
                duration: 1200.ms,
                curve: Curves.easeInOut,
              ),
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    HSLColor.fromAHSL(1, hue.toDouble(), 0.55, 0.42).toColor(),
                    HSLColor.fromAHSL(1, hue.toDouble(), 0.50, 0.30).toColor(),
                  ],
                  begin: Alignment.topLeft,
                  end:   Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          Text(
            name,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _statusLabel,
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 15),
          ).animate(onPlay: (c) {
            if (!_isConnected) c.repeat(reverse: true);
          }).fade(duration: 900.ms, begin: 0.5),
        ]),
      ),
    );
  }

  // ── Top bar ────────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end:   Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
        ),
      ),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              widget.contact.name,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              _statusLabel,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
          ]),
        ),
        if (_isConnected)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color:  Colors.green.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 7, height: 7,
                decoration: const BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'Live',
                style: GoogleFonts.inter(
                  color: Colors.greenAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ]),
          ),
      ]),
    );
  }

  // ── Control bar ────────────────────────────────────────────────────────────

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end:   Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.75), Colors.transparent],
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (widget.isVideoCall)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _buildSmallButton(
                icon:        _isScreenSharing ? Icons.stop_screen_share_rounded : Icons.screen_share_rounded,
                label:       _isScreenSharing ? 'Stop Share' : 'Share Screen',
                active:      _isScreenSharing,
                activeColor: Colors.blueAccent,
                onTap:       _toggleScreenShare,
              ),
              const SizedBox(width: 24),
              _buildSmallButton(
                icon:  _isCameraOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                label: _isCameraOff ? 'Camera Off' : 'Camera On',
                active: _isCameraOff,
                onTap:  _toggleCamera,
              ),
            ]),
          ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _buildControlButton(
            icon:      _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
            label:     _isMuted ? 'Unmute' : 'Mute',
            color:     _isMuted ? Colors.white : Colors.white24,
            iconColor: _isMuted ? Colors.black : Colors.white,
            onPressed: _toggleMute,
          ),
          GestureDetector(
            onTap: _hangUp,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 68, height: 68,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withValues(alpha: 0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 30),
              ).animate().scale(),
              const SizedBox(height: 6),
              Text('End', style: GoogleFonts.inter(color: Colors.white70, fontSize: 11)),
            ]),
          ),
          _buildControlButton(
            icon:      Icons.volume_up_rounded,
            label:     'Speaker',
            color:     Colors.white24,
            iconColor: Colors.white,
            onPressed: () {},
          ),
        ]),
      ]),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 24),
        ).animate().scale(),
        const SizedBox(height: 6),
        Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 11)),
      ]),
    );
  }

  Widget _buildSmallButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = false,
    Color activeColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: active ? activeColor.withValues(alpha: 0.2) : Colors.white12,
            shape: BoxShape.circle,
            border: active ? Border.all(color: activeColor, width: 1.5) : null,
          ),
          child: Icon(icon, color: active ? activeColor : Colors.white, size: 20),
        ),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(color: Colors.white60, fontSize: 10)),
      ]),
    );
  }
}
