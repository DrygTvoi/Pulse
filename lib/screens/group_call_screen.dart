import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../models/contact.dart';
import '../services/group_signaling_service.dart';
import '../services/call_transport.dart';
import '../controllers/chat_controller.dart';
import '../theme/app_theme.dart';

/// Group video/audio call screen.
/// ≤4 total participants (members + self) → WebRTC mesh via GroupSignalingService.
/// 5+ total participants → Jitsi fallback: send meet.jit.si link, open browser.
class GroupCallScreen extends StatefulWidget {
  final Contact group;
  final String myId;
  final bool isCaller;
  final bool isVideoCall;

  const GroupCallScreen({
    super.key,
    required this.group,
    required this.myId,
    this.isCaller = true,
    this.isVideoCall = true,
  });

  @override
  State<GroupCallScreen> createState() => _GroupCallScreenState();
}

class _GroupCallScreenState extends State<GroupCallScreen> {
  // Mesh call
  GroupSignalingService? _groupSignaling;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final Map<String, RTCVideoRenderer> _remoteRenderers = {};
  final Map<String, RTCIceConnectionState> _peerStates = {};

  bool _isMuted = false;
  bool _isCameraOff = false;

  CallTransportProfile _currentProfile = CallTransportProfile.auto;

  // Jitsi fallback
  bool _isJitsi = false;
  String? _jitsiRoom;
  bool _jitsiBrowserOpened = false;

  Timer? _durationTimer;
  Duration _callDuration = Duration.zero;
  bool _disposed = false;
  bool _ready = false; // true after _startCall() completes

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startCall());
  }

  Future<void> _startCall() async {
    final memberContacts = ContactManager()
        .contacts
        .where((c) => widget.group.members.contains(c.id))
        .toList();

    // total = other members + self
    final total = memberContacts.length + 1;

    if (total > 4) {
      // ── Jitsi fallback ──────────────────────────────────────────────────
      final roomId =
          const Uuid().v4().replaceAll('-', '').substring(0, 12);
      if (!mounted) return;
      setState(() {
        _isJitsi = true;
        _jitsiRoom = roomId;
        _ready = true;
      });

      // Send invite link via group chat
      final chatCtrl = context.read<ChatController>();
      await chatCtrl.sendMessage(
        widget.group,
        '📹 Group video call started — join here:\nhttps://meet.jit.si/$roomId',
      );

      // Open browser
      final uri = Uri.parse('https://meet.jit.si/$roomId');
      final launched =
          await canLaunchUrl(uri) &&
          await launchUrl(uri, mode: LaunchMode.externalApplication).then((_) => true, onError: (_) => false);
      if (mounted) setState(() => _jitsiBrowserOpened = launched);
      return;
    }

    // ── WebRTC mesh ────────────────────────────────────────────────────────
    await _localRenderer.initialize();
    for (final m in memberContacts) {
      final r = RTCVideoRenderer();
      await r.initialize();
      _remoteRenderers[m.id] = r;
    }

    _groupSignaling = GroupSignalingService(
      group: widget.group,
      myId: widget.myId,
      members: memberContacts,
    );

    _groupSignaling!.onRemoteStream = (memberId, stream) {
      if (!mounted) return;
      setState(() => _remoteRenderers[memberId]?.srcObject = stream);
    };

    _groupSignaling!.onPeerState = (memberId, state) {
      if (!mounted) return;
      setState(() => _peerStates[memberId] = state);
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
        _startDurationTimer();
      }
      // If all peers failed on auto → switch to restricted profile
      if (state == RTCIceConnectionState.RTCIceConnectionStateFailed &&
          !_currentProfile.isRestricted) {
        final allFailed = _peerStates.values.every(
          (s) => s == RTCIceConnectionState.RTCIceConnectionStateFailed,
        );
        if (allFailed) _switchToRestrictedProfile();
      }
    };

    await _groupSignaling!.init(profile: _currentProfile);
    if (_disposed) return;

    final localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': widget.isVideoCall,
    });
    if (_disposed) {
      localStream.getTracks().forEach((t) => t.stop());
      return;
    }
    _localRenderer.srcObject = localStream;
    _groupSignaling!.addLocalStream(localStream);

    if (widget.isCaller) {
      await _groupSignaling!.createOffers();
    }

    if (mounted) setState(() => _ready = true);
  }

  void _startDurationTimer() {
    if (_durationTimer != null) return;
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _callDuration += const Duration(seconds: 1));
    });
  }

  /// Called when all peers fail on AutoProfile — restarts the call with
  /// RestrictedProfile (relay-only, TLS/TCP 443).
  Future<void> _switchToRestrictedProfile() async {
    if (_disposed || _currentProfile.isRestricted) return;
    if (mounted) setState(() => _currentProfile = CallTransportProfile.restricted);

    // Full teardown
    await _groupSignaling?.hangUp();
    _groupSignaling = null;
    _peerStates.clear();

    // Restart with restricted profile (callers re-send offers after init)
    final memberContacts = ContactManager()
        .contacts
        .where((c) => widget.group.members.contains(c.id))
        .toList();

    _groupSignaling = GroupSignalingService(
      group:   widget.group,
      myId:    widget.myId,
      members: memberContacts,
    );

    _groupSignaling!.onRemoteStream = (memberId, stream) {
      if (!mounted) return;
      setState(() => _remoteRenderers[memberId]?.srcObject = stream);
    };

    _groupSignaling!.onPeerState = (memberId, state) {
      if (!mounted) return;
      setState(() => _peerStates[memberId] = state);
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
        _startDurationTimer();
      }
    };

    await _groupSignaling!.init(profile: _currentProfile);
    if (_disposed) return;

    final localStream = _groupSignaling!.localStream;
    if (localStream != null) {
      _groupSignaling!.addLocalStream(localStream);
    }

    if (widget.isCaller) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!_disposed) await _groupSignaling!.createOffers();
    }
  }

  Future<void> _hangUp() async {
    if (_disposed) return;
    _disposed = true;
    _durationTimer?.cancel();
    await _groupSignaling?.hangUp();
    _localRenderer.dispose();
    for (final r in _remoteRenderers.values) {
      r.dispose();
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    if (!_disposed) {
      _disposed = true;
      _durationTimer?.cancel();
      _groupSignaling?.hangUp();
      _localRenderer.dispose();
      for (final r in _remoteRenderers.values) {
        r.dispose();
      }
    }
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isJitsi) return _buildJitsiFallback();
    if (!_ready) return _buildLoading();
    return _buildMeshCall();
  }

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const CircularProgressIndicator(color: Colors.white54),
          const SizedBox(height: 20),
          Text('Starting call…',
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 15)),
        ]),
      ),
    );
  }

  Future<void> _reopenJitsiBrowser() async {
    final roomId = _jitsiRoom;
    if (roomId == null) return;
    final uri = Uri.parse('https://meet.jit.si/$roomId');
    final launched =
        await canLaunchUrl(uri) &&
        await launchUrl(uri, mode: LaunchMode.externalApplication).then((_) => true, onError: (_) => false);
    if (mounted) setState(() => _jitsiBrowserOpened = launched);
  }

  Widget _buildJitsiFallback() {
    final meetUrl = 'https://meet.jit.si/${_jitsiRoom ?? '…'}';
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 88, height: 88,
                decoration: BoxDecoration(
                  color: _jitsiBrowserOpened
                      ? AppTheme.primary.withValues(alpha: 0.15)
                      : Colors.orange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _jitsiBrowserOpened
                      ? Icons.video_call_rounded
                      : Icons.warning_amber_rounded,
                  size: 48,
                  color: _jitsiBrowserOpened ? AppTheme.primary : Colors.orange,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                _jitsiBrowserOpened
                    ? 'Group call opened in browser'
                    : 'Could not open browser',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              // Tappable link — always shown so user can copy it
              GestureDetector(
                onTap: _reopenJitsiBrowser,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    meetUrl,
                    style: GoogleFonts.inter(
                        color: _jitsiBrowserOpened ? Colors.white70 : Colors.orangeAccent,
                        fontSize: 13,
                        decoration: TextDecoration.underline),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _jitsiBrowserOpened
                    ? 'Invite link sent to all group members.'
                    : 'Open the link above manually or tap to retry.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
              ),
              const SizedBox(height: 20),
              if (!_jitsiBrowserOpened)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                  label: Text('Retry open browser',
                      style: GoogleFonts.inter(fontSize: 14)),
                  onPressed: _reopenJitsiBrowser,
                ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: const StadiumBorder(),
                ),
                icon: const Icon(Icons.call_end_rounded, color: Colors.white),
                label: Text('Close',
                    style: GoogleFonts.inter(
                        color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                onPressed: () => Navigator.pop(context),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildMeshCall() {
    final rendererList = _remoteRenderers.entries.toList();
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(children: [
          // Remote video grid (full screen)
          Positioned.fill(child: _buildRemoteGrid(rendererList)),

          // Local PiP (top-right)
          if (_localRenderer.textureId != null)
            Positioned(
              right: 12,
              top: 72,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 110,
                  height: 150,
                  child: RTCVideoView(
                    _localRenderer,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),
            ),

          // Restricted-mode banner
          if (_currentProfile.isRestricted)
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                color: Colors.blueGrey.withValues(alpha: 0.85),
                child: Row(children: [
                  const Icon(Icons.shield_rounded, color: Colors.white, size: 13),
                  const SizedBox(width: 6),
                  Text(
                    'Relay mode active (restricted network)',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ]),
              ),
            ),

          // Top gradient + info bar
          Positioned(
            top: _currentProfile.isRestricted ? 26 : 0,
            left: 0, right: 0,
            child: _buildTopBar(),
          ),

          // Bottom controls
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildControls(),
          ),
        ]),
      ),
    );
  }

  Widget _buildRemoteGrid(List<MapEntry<String, RTCVideoRenderer>> entries) {
    if (entries.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.group_rounded, size: 64, color: AppTheme.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('Connecting to group…',
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 16)),
        ]),
      );
    }
    return GridView.count(
      crossAxisCount: entries.length == 1 ? 1 : 2,
      physics: const NeverScrollableScrollPhysics(),
      children: entries.map((entry) {
        final memberId = entry.key;
        final renderer = entry.value;
        final state = _peerStates[memberId];
        final connected = state == RTCIceConnectionState.RTCIceConnectionStateConnected ||
            state == RTCIceConnectionState.RTCIceConnectionStateCompleted;
        final memberContact = ContactManager()
            .contacts
            .cast<Contact?>()
            .firstWhere((c) => c?.id == memberId, orElse: () => null);

        return Stack(children: [
          Positioned.fill(
            child: connected && renderer.textureId != null
                ? RTCVideoView(
                    renderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  )
                : Container(
                    color: const Color(0xFF1C1C1E),
                    child: Center(
                      child: _buildAvatar(memberContact?.name ?? '?', 64),
                    ),
                  ),
          ),
          // Name label
          Positioned(
            left: 10, bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                memberContact?.name ?? memberId,
                style: GoogleFonts.inter(
                    color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          // Connection status dot
          Positioned(
            right: 10, bottom: 12,
            child: Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                color: connected ? Colors.greenAccent : Colors.orangeAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ]);
      }).toList(),
    );
  }

  Widget _buildAvatar(String name, double size) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: size, height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF2C2C2E)),
      child: Center(
        child: Text(initial,
            style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: size * 0.4,
                fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildTopBar() {
    final anyConnected = _peerStates.values.any((s) =>
        s == RTCIceConnectionState.RTCIceConnectionStateConnected ||
        s == RTCIceConnectionState.RTCIceConnectionStateCompleted);

    final String statusText;
    if (anyConnected) {
      final h = _callDuration.inHours;
      final m = _callDuration.inMinutes.remainder(60).toString().padLeft(2, '0');
      final s = _callDuration.inSeconds.remainder(60).toString().padLeft(2, '0');
      statusText = h > 0 ? '$h:$m:$s' : '$m:$s';
    } else {
      statusText = 'Connecting…';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.group.name,
                style: GoogleFonts.inter(
                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(statusText,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
          ]),
        ),
        if (anyConnected)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('Live',
                style: GoogleFonts.inter(
                    color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
      ]),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _controlBtn(
          icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
          label: _isMuted ? 'Unmute' : 'Mute',
          active: _isMuted,
          onTap: () {
            setState(() => _isMuted = !_isMuted);
            _groupSignaling?.localStream
                ?.getAudioTracks()
                .forEach((t) => t.enabled = !_isMuted);
          },
        ),
        // Hang-up button
        GestureDetector(
          onTap: _hangUp,
          child: Container(
            width: 64, height: 64,
            decoration: const BoxDecoration(
                color: Colors.redAccent, shape: BoxShape.circle),
            child: const Icon(Icons.call_end_rounded,
                color: Colors.white, size: 28),
          ),
        ),
        if (widget.isVideoCall)
          _controlBtn(
            icon: _isCameraOff
                ? Icons.videocam_off_rounded
                : Icons.videocam_rounded,
            label: _isCameraOff ? 'Cam off' : 'Cam on',
            active: _isCameraOff,
            onTap: () {
              setState(() => _isCameraOff = !_isCameraOff);
              _groupSignaling?.localStream
                  ?.getVideoTracks()
                  .forEach((t) => t.enabled = !_isCameraOff);
            },
          )
        else
          _controlBtn(
            icon: Icons.speaker_phone_rounded,
            label: 'Speaker',
            active: false,
            onTap: () {},
          ),
      ]),
    );
  }

  Widget _controlBtn({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: active
                ? Colors.redAccent.withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 11)),
      ]),
    );
  }
}
