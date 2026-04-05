import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/contact.dart';
import '../models/contact_repository.dart';
import '../services/sfu_signaling_service.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';

/// SFU group call screen — single PeerConnection to Pulse server.
/// Also used as media relay fallback for 1-on-1 calls when P2P fails.
class SfuCallScreen extends StatefulWidget {
  final Contact group;
  final String myId;
  final bool isCaller;
  final String? existingRoomId;
  final String? existingToken;

  const SfuCallScreen({
    super.key,
    required this.group,
    required this.myId,
    this.isCaller = true,
    this.existingRoomId,
    this.existingToken,
  });

  @override
  State<SfuCallScreen> createState() => _SfuCallScreenState();
}

class _SfuCallScreenState extends State<SfuCallScreen> {
  SfuSignalingService? _sfu;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final Map<String, RTCVideoRenderer> _remoteRenderers = {};
  final Map<String, List<_TrackMeta>> _participantTracks = {};
  final Map<String, String> _trackOwners = {};

  bool _isMuted = false;
  bool _isCameraOff = true;
  bool _isScreenSharing = false;

  Set<String> _activeSet = {};
  String? _dominant;
  Set<String> _speakers = {};
  String? _pinnedPubkey;

  Timer? _durationTimer;
  Duration _callDuration = Duration.zero;
  bool _disposed = false;
  bool _ready = false;
  RTCIceConnectionState? _iceState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startCall());
  }

  Future<void> _startCall() async {
    await _localRenderer.initialize();

    _sfu = SfuSignalingService(group: widget.group, myId: widget.myId);

    _sfu!.onTrackAvailable = (pubkey, trackId, kind) {
      if (_disposed) return;
      _trackOwners[trackId] = pubkey;
      _participantTracks.putIfAbsent(pubkey, () => []);
      _participantTracks[pubkey]!.add(_TrackMeta(trackId, kind));

      if (kind == 'audio') {
        _sfu!.subscribeTrack(trackId);
      } else {
        final layer = _activeSet.isEmpty || _activeSet.contains(pubkey) ? 'h' : 'q';
        _sfu!.subscribeTrack(trackId, layer: layer);
      }
      if (mounted) setState(() {});
    };

    _sfu!.onParticipantLeft = (pubkey) {
      if (_disposed) return;
      _participantTracks.remove(pubkey);
      _trackOwners.removeWhere((_, v) => v == pubkey);
      _remoteRenderers[pubkey]?.srcObject = null;
      _remoteRenderers[pubkey]?.dispose();
      _remoteRenderers.remove(pubkey);
      if (mounted) setState(() {});
    };

    _sfu!.onLastNUpdate = (activeSet, dominant) {
      if (_disposed) return;
      setState(() { _activeSet = activeSet.toSet(); _dominant = dominant; });
    };

    _sfu!.onSpeakerUpdate = (speakers, dominant) {
      if (_disposed) return;
      setState(() { _speakers = speakers.toSet(); _dominant = dominant; });
    };

    _sfu!.onRemoteTrack = (event) {
      if (_disposed) return;
      final track = event.track;
      final streams = event.streams;
      if (streams.isEmpty) return;
      final stream = streams.first;

      // Match remote track to a participant by scanning track metadata
      String? ownerPubkey;
      for (final entry in _participantTracks.entries) {
        for (final meta in entry.value) {
          if (track.kind == 'video' && (meta.kind == 'video' || meta.kind == 'screen')) {
            ownerPubkey = entry.key;
            break;
          }
        }
        if (ownerPubkey != null) break;
      }

      if (ownerPubkey != null && track.kind == 'video') {
        _ensureRenderer(ownerPubkey).then((r) {
          r.srcObject = stream;
          if (mounted) setState(() {});
        });
      }
    };

    _sfu!.onIceState = (state) {
      if (_disposed) return;
      setState(() => _iceState = state);
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
        _startDurationTimer();
      }
    };

    _sfu!.onRoomReady = () async {
      if (_disposed) return;
      // Room joined — set up PC and send media
      final localStream = await navigator.mediaDevices.getUserMedia({
        'audio': {'noiseSuppression': true, 'echoCancellation': true, 'autoGainControl': true},
        'video': true,
      });
      if (_disposed) { localStream.getTracks().forEach((t) => t.stop()); return; }

      // Camera off by default
      for (final t in localStream.getVideoTracks()) { t.enabled = false; }
      _localRenderer.srcObject = localStream;

      await _sfu!.setupPeerConnection(localStream);
      if (mounted) setState(() => _ready = true);
    };

    if (widget.existingRoomId != null && widget.existingToken != null) {
      await _sfu!.joinRoom(widget.existingRoomId!, widget.existingToken!);
    } else {
      await _sfu!.createRoom();
    }
  }

  Future<RTCVideoRenderer> _ensureRenderer(String pubkey) async {
    if (!_remoteRenderers.containsKey(pubkey)) {
      final r = RTCVideoRenderer();
      await r.initialize();
      _remoteRenderers[pubkey] = r;
    }
    return _remoteRenderers[pubkey]!;
  }

  void _startDurationTimer() {
    if (_durationTimer != null) return;
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _callDuration += const Duration(seconds: 1));
    });
  }

  Future<void> _hangUp() async {
    if (_disposed) return;
    _disposed = true;
    _durationTimer?.cancel();
    await _sfu?.hangUp();
    _disposeRenderers();
    if (mounted) Navigator.pop(context);
  }

  void _disposeRenderers() {
    try { _localRenderer.srcObject = null; } catch (_) {}
    try { _localRenderer.dispose(); } catch (_) {}
    for (final r in _remoteRenderers.values) {
      try { r.srcObject = null; } catch (_) {}
      try { r.dispose(); } catch (_) {}
    }
  }

  @override
  void dispose() {
    if (!_disposed) {
      _disposed = true;
      _durationTimer?.cancel();
      _sfu?.hangUp();
      _disposeRenderers();
    }
    super.dispose();
  }

  void _togglePin(String pubkey) {
    setState(() {
      if (_pinnedPubkey == pubkey) {
        _pinnedPubkey = null;
        for (final meta in _participantTracks[pubkey] ?? []) {
          if (meta.kind == 'video' || meta.kind == 'screen') {
            _sfu?.preferQuality(meta.trackId, 'h');
          }
        }
      } else {
        if (_pinnedPubkey != null) {
          for (final meta in _participantTracks[_pinnedPubkey!] ?? []) {
            if (meta.kind == 'video' || meta.kind == 'screen') {
              _sfu?.preferQuality(meta.trackId, 'h');
            }
          }
        }
        _pinnedPubkey = pubkey;
        for (final meta in _participantTracks[pubkey] ?? []) {
          if (meta.kind == 'video' || meta.kind == 'screen') {
            _sfu?.preferQuality(meta.trackId, 'f');
          }
        }
      }
    });
  }

  Future<void> _toggleScreenShare() async {
    try {
      if (_isScreenSharing) {
        final camStream = await navigator.mediaDevices.getUserMedia({'audio': false, 'video': true});
        _localRenderer.srcObject = camStream;
        if (mounted) setState(() => _isScreenSharing = false);
      } else {
        MediaStream screen;
        if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
          final sources = await desktopCapturer.getSources(types: [SourceType.Screen]);
          if (sources.isEmpty) return;
          screen = await navigator.mediaDevices.getDisplayMedia({
            'video': {'deviceId': {'exact': sources.first.id}, 'mandatory': {'frameRate': 30.0}},
            'audio': false,
          });
        } else {
          screen = await navigator.mediaDevices.getDisplayMedia({'video': true, 'audio': false});
        }
        _localRenderer.srcObject = screen;
        if (mounted) setState(() => _isScreenSharing = true);
      }
    } catch (e) {
      debugPrint('[SfuCall] Screen share error: $e');
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) => !_ready ? _buildLoading() : _buildCall();

  Widget _buildLoading() => Scaffold(
    backgroundColor: Colors.black,
    body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const CircularProgressIndicator(color: Colors.white54),
      const SizedBox(height: 20),
      Text(context.l10n.callStarting, style: GoogleFonts.inter(color: Colors.white54, fontSize: 15)),
    ])),
  );

  Widget _buildCall() {
    final participants = _participantTracks.keys.toList();
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: Stack(children: [
        Positioned.fill(child: _buildGrid(participants)),
        if (_localRenderer.textureId != null)
          Positioned(right: 12, top: 72, child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(width: 110, height: 150, child: RTCVideoView(
              _localRenderer, mirror: !_isScreenSharing,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            )),
          )),
        Positioned(top: 4, left: 12, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(8)),
          child: Text('SFU', style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
        )),
        Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),
        Positioned(bottom: 0, left: 0, right: 0, child: _buildControls()),
      ])),
    );
  }

  Widget _buildGrid(List<String> participants) {
    if (participants.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.group_rounded, size: 64, color: AppTheme.primary.withValues(alpha: 0.5)),
        const SizedBox(height: 16),
        Text(context.l10n.callConnectingToGroup, style: GoogleFonts.inter(color: Colors.white54, fontSize: 16)),
      ]));
    }
    final c = participants.length;
    if (c == 1) return _tile(participants[0]);
    if (c == 2) return Row(children: participants.map((p) => Expanded(child: _tile(p))).toList());
    if (c == 3) return Column(children: [
      Expanded(child: Row(children: [Expanded(child: _tile(participants[0])), Expanded(child: _tile(participants[1]))])),
      Expanded(child: Center(child: AspectRatio(aspectRatio: 1.5, child: _tile(participants[2])))),
    ]);
    return GridView.count(
      crossAxisCount: 2, physics: const NeverScrollableScrollPhysics(),
      children: participants.take(6).map(_tile).toList(),
    );
  }

  Widget _tile(String pubkey) {
    final renderer = _remoteRenderers[pubkey];
    final hasVideo = _activeSet.isEmpty || _activeSet.contains(pubkey);
    final isSpeaking = _speakers.contains(pubkey);
    final isDominant = pubkey == _dominant;
    final isPinned = pubkey == _pinnedPubkey;

    final contact = context.read<IContactRepository>().contacts
        .cast<Contact?>().firstWhere((c) => c?.databaseId == pubkey, orElse: () => null);
    final name = contact?.name ?? (pubkey.length > 8 ? pubkey.substring(0, 8) : pubkey);

    return GestureDetector(
      onDoubleTap: () => _togglePin(pubkey),
      child: Stack(children: [
        Positioned.fill(
          child: hasVideo && renderer != null && renderer.textureId != null
              ? RTCVideoView(renderer, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)
              : Container(color: const Color(0xFF1C1C1E), child: Center(child: _avatar(name, 64))),
        ),
        if (isSpeaking) Positioned.fill(child: IgnorePointer(child: Container(
          decoration: BoxDecoration(border: Border.all(color: isDominant ? Colors.greenAccent : Colors.green, width: isDominant ? 3 : 2)),
        ))),
        if (isPinned) const Positioned(right: 8, top: 8, child: Icon(Icons.push_pin_rounded, color: Colors.white, size: 16)),
        if (!hasVideo && _activeSet.isNotEmpty) Positioned(left: 8, top: 8, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
          child: Text('Audio only', style: GoogleFonts.inter(color: Colors.white54, fontSize: 10)),
        )),
        Positioned(left: 10, bottom: 10, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
          child: Text(name, style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        )),
      ]),
    );
  }

  Widget _avatar(String name, double size) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: size, height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF2C2C2E)),
      child: Center(child: Text(initial, style: GoogleFonts.inter(
        color: Colors.white70, fontSize: size * 0.4, fontWeight: FontWeight.w700,
      ))),
    );
  }

  Widget _buildTopBar() {
    final connected = _iceState == RTCIceConnectionState.RTCIceConnectionStateConnected ||
        _iceState == RTCIceConnectionState.RTCIceConnectionStateCompleted;
    final String status;
    if (connected) {
      final h = _callDuration.inHours;
      final m = _callDuration.inMinutes.remainder(60).toString().padLeft(2, '0');
      final s = _callDuration.inSeconds.remainder(60).toString().padLeft(2, '0');
      status = h > 0 ? '$h:$m:$s' : '$m:$s';
    } else {
      status = context.l10n.callConnecting;
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: BoxDecoration(gradient: LinearGradient(
        colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
      )),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.group.name, style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text('$status  ${_participantTracks.length + 1} participants',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
        ])),
        if (connected) Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10)),
          child: Text(context.l10n.callLive, style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }

  Widget _buildControls() => Container(
    padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
    decoration: BoxDecoration(gradient: LinearGradient(
      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
    )),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _ctrl(
        icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
        label: _isMuted ? context.l10n.callUnmute : context.l10n.callMute,
        active: _isMuted,
        onTap: () {
          setState(() => _isMuted = !_isMuted);
          _sfu?.localStream?.getAudioTracks().forEach((t) => t.enabled = !_isMuted);
        },
      ),
      GestureDetector(onTap: _hangUp, child: Container(
        width: 64, height: 64,
        decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
        child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 28),
      )),
      _ctrl(
        icon: _isCameraOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
        label: _isCameraOff ? context.l10n.callCamOff : context.l10n.callCamOn,
        active: !_isCameraOff,
        onTap: () {
          setState(() => _isCameraOff = !_isCameraOff);
          _sfu?.localStream?.getVideoTracks().forEach((t) => t.enabled = !_isCameraOff);
        },
      ),
      _ctrl(
        icon: _isScreenSharing ? Icons.stop_screen_share_rounded : Icons.screen_share_rounded,
        label: _isScreenSharing ? context.l10n.callStopShare : context.l10n.callShareScreen,
        active: _isScreenSharing,
        onTap: _toggleScreenShare,
      ),
    ]),
  );

  Widget _ctrl({required IconData icon, required String label, required bool active, required VoidCallback onTap}) {
    return GestureDetector(onTap: onTap, child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          color: active ? Colors.redAccent.withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
      const SizedBox(height: 6),
      Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 11)),
    ]));
  }
}

class _TrackMeta {
  final String trackId;
  final String kind;
  _TrackMeta(this.trackId, this.kind);
}
