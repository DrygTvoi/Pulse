import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../models/contact.dart';
import '../models/contact_repository.dart';
import '../services/group_signaling_service.dart';
import '../services/call_transport.dart';
import '../controllers/chat_controller.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import 'sfu_call_screen.dart';

/// Group call screen — camera off by default, can be toggled on.
/// ≤6 participants → WebRTC mesh (E2EE). 7+ → Jitsi fallback (NOT E2EE).
class GroupCallScreen extends StatefulWidget {
  final Contact group;
  final String myId;
  final bool isCaller;

  const GroupCallScreen({
    super.key,
    required this.group,
    required this.myId,
    this.isCaller = true,
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
  bool _isCameraOff = true;  // camera OFF by default
  bool _isScreenSharing = false;

  Timer? _audioLevelTimer;
  final Map<String, bool> _speakingPeers = {};

  StreamSubscription? _groupUpdateSub;

  CallTransportProfile _currentProfile = CallTransportProfile.auto;

  // Contact lookup cache — avoids O(N) scan per participant per rebuild
  Map<String, Contact>? _contactCache;
  Map<String, Contact> _getContactMap(BuildContext context) {
    return _contactCache ??= {
      for (final c in context.read<IContactRepository>().contacts) c.id: c
    };
  }

  // Jitsi fallback
  bool _isJitsi = false;
  String? _jitsiRoom;
  bool _jitsiBrowserOpened = false;

  Timer? _durationTimer;
  Timer? _turnFailedTimer;
  bool _turnFailed = false;
  Duration _callDuration = Duration.zero;
  bool _disposed = false;
  bool _ready = false; // true after _startCall() completes

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startCall());
  }

  Future<void> _startCall() async {
    final contactRepo = context.read<IContactRepository>();
    final chatCtrl = context.read<ChatController>();
    // Two-pass member resolution. Direct UUID match first, then fallback to
    // pubkey via group.memberPubkeys. The fallback is required for invite-
    // link joiners whose hidden routing contacts are keyed by pubkey rather
    // than the creator-side UUID stored in `group.members`.
    final byUuid = <String, Contact>{
      for (final c in contactRepo.contacts) c.id: c
    };
    final byPubkey = <String, Contact>{};
    for (final c in contactRepo.contacts) {
      if (c.isGroup) continue;
      for (final addrs in c.transportAddresses.values) {
        for (final addr in addrs) {
          final at = addr.indexOf('@');
          final pub = (at > 0 ? addr.substring(0, at) : addr).toLowerCase();
          if (pub.isNotEmpty) byPubkey[pub] = c;
        }
      }
    }
    final memberSet = <Contact>{};
    for (final uuid in widget.group.members) {
      final direct = byUuid[uuid];
      if (direct != null && !direct.isGroup) {
        memberSet.add(direct);
        continue;
      }
      final pub = widget.group.memberPubkeys[uuid]?.toLowerCase();
      if (pub != null) {
        final viaPub = byPubkey[pub];
        if (viaPub != null) memberSet.add(viaPub);
      }
    }
    final memberContacts = memberSet.toList();

    // total = other members + self
    final total = memberContacts.length + 1;

    // Route to SFU when Pulse relay is available & >2 participants
    if (chatCtrl.hasPulseRelay && total > 2 && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => SfuCallScreen(
          group: widget.group,
          myId: widget.myId,
          isCaller: widget.isCaller,
        ),
      ));
      return;
    }

    final meshLimit = 6;
    if (total > meshLimit) {
      // ── Jitsi fallback ──────────────────────────────────────────────────
      // Warn the user before opening Jitsi (not E2EE, opens external browser)
      if (mounted) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog.adaptive(
            title: Text(context.l10n.jitsiGroupWarningTitle),
            content: Text(context.l10n.jitsiGroupWarningBody),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.chatCancel)),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(context.l10n.jitsiContinueAnyway)),
            ],
          ),
        );
        if (confirmed != true) {
          if (mounted) Navigator.pop(context);
          return;
        }
      }

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
        _startAudioLevelPolling(); // idempotent — cancels previous timer
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
      'audio': {
        'noiseSuppression': true,
        'echoCancellation': true,
        'autoGainControl': true,
      },
      'video': false,  // camera off by default, toggled on via button
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

    // Subscribe to roster changes (kick/add during active call)
    _groupUpdateSub = chatCtrl.groupUpdates.listen((e) {
      if (!mounted || _disposed) return;
      if (e.groupId != widget.group.id) return;
      _handleRosterChange(e.members);
    });

    if (mounted) setState(() => _ready = true);
  }

  Future<void> _handleRosterChange(List<String> newMemberIds) async {
    if (_disposed || _groupSignaling == null) return;
    final allContacts = context.read<IContactRepository>().contacts;
    final oldIds = Set<String>.from(_remoteRenderers.keys);
    final newIds = newMemberIds.toSet()..remove(widget.myId);

    // Remove peers that left
    for (final removedId in oldIds.difference(newIds)) {
      await _groupSignaling!.removePeer(removedId);
      _remoteRenderers[removedId]?.dispose();
      if (mounted) setState(() => _remoteRenderers.remove(removedId));
    }

    // Add peers that joined
    for (final addedId in newIds.difference(oldIds)) {
      final contact = allContacts.cast<Contact?>()
          .firstWhere((c) => c?.id == addedId, orElse: () => null);
      if (contact == null) continue;
      final r = RTCVideoRenderer();
      await r.initialize();
      if (mounted) setState(() => _remoteRenderers[addedId] = r);
      await _groupSignaling!.addPeer(contact);
      if (widget.isCaller) await _groupSignaling!.createOfferTo(contact);
    }
  }

  void _startTurnFailedTimer() {
    _turnFailedTimer?.cancel();
    _turnFailedTimer = Timer(const Duration(seconds: 20), () {
      if (_disposed || !mounted) return;
      final allFailed = _peerStates.isNotEmpty &&
          _peerStates.values.every((s) =>
              s == RTCIceConnectionState.RTCIceConnectionStateFailed ||
              s == RTCIceConnectionState.RTCIceConnectionStateNew);
      if (allFailed && _currentProfile.isRestricted) {
        setState(() => _turnFailed = true);
      }
    });
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
    _startTurnFailedTimer();

    // Full teardown
    await _groupSignaling?.hangUp();
    _groupSignaling = null;
    _peerStates.clear();

    // Restart with restricted profile (callers re-send offers after init)
    if (!mounted) return;
    final memberContacts = context.read<IContactRepository>()
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

  void _startAudioLevelPolling() {
    _audioLevelTimer?.cancel();
    _audioLevelTimer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      if (_disposed || _groupSignaling == null) return;
      final levels = await _groupSignaling!.getAudioLevels();
      if (!mounted) return;
      setState(() {
        for (final id in _remoteRenderers.keys) {
          _speakingPeers[id] = (levels[id] ?? 0.0) > 0.01;
        }
      });
    });
  }

  Future<void> _toggleScreenShare() async {
    try {
      if (_isScreenSharing) {
        final camStream = await navigator.mediaDevices.getUserMedia({'audio': false, 'video': true});
        final track = camStream.getVideoTracks().first;
        await _groupSignaling?.replaceVideoTrack(track);
        await _localRenderer.initialize();
        _localRenderer.srcObject = camStream;
        _groupSignaling?.localStream = camStream;
        if (mounted) setState(() => _isScreenSharing = false);
      } else {
        MediaStream screen;
        if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
          // Desktop: must enumerate sources first, then pass source ID
          // Only enumerate Screen sources — Window enumeration crashes
          // on Wayland (libwebrtc X11 window capture segfaults).
          final sources = await desktopCapturer.getSources(
            types: [SourceType.Screen],
          );
          if (sources.isEmpty) {
            debugPrint('[GroupCall] No desktop sources found');
            return;
          }
          final screenSources = sources.where((s) => s.type == SourceType.Screen).toList();
          final screenSource = screenSources.isNotEmpty ? screenSources.first : sources.first;
          debugPrint('[GroupCall] Using desktop source: ${screenSource.name} (${screenSource.id})');
          screen = await navigator.mediaDevices.getDisplayMedia({
            'video': {
              'deviceId': {'exact': screenSource.id},
              'mandatory': {'frameRate': 30.0},
            },
            'audio': false,
          });
        } else {
          screen = await navigator.mediaDevices.getDisplayMedia({'video': true, 'audio': false});
        }
        final track = screen.getVideoTracks().first;
        await _groupSignaling?.replaceVideoTrack(track);
        _localRenderer.srcObject = screen;
        _groupSignaling?.localStream = screen;
        if (mounted) setState(() => _isScreenSharing = true);
      }
    } catch (e) {
      debugPrint('[GroupCall] Screen share error: $e');
    }
  }

  Future<void> _hangUp() async {
    if (_disposed) return;
    _disposed = true;
    _durationTimer?.cancel();
    _turnFailedTimer?.cancel();
    _audioLevelTimer?.cancel();
    _groupUpdateSub?.cancel();
    await _groupSignaling?.hangUp();
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
      _turnFailedTimer?.cancel();
      _audioLevelTimer?.cancel();
      _groupUpdateSub?.cancel();
      _groupSignaling?.hangUp();
      _disposeRenderers();
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
          Text(context.l10n.callStarting,
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
                    ? context.l10n.callGroupOpenedInBrowser
                    : context.l10n.callCouldNotOpenBrowser,
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
                    ? context.l10n.callInviteLinkSent
                    : context.l10n.callOpenLinkManually,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.lock_open_rounded, color: Colors.orangeAccent, size: 14),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      context.l10n.callJitsiNotE2ee,
                      style: GoogleFonts.inter(color: Colors.orangeAccent, fontSize: 12),
                    ),
                  ),
                ]),
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
                  label: Text(context.l10n.callRetryOpenBrowser,
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
                label: Text(context.l10n.callClose,
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

          // Restricted / TURN-failed banner
          if (_currentProfile.isRestricted)
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                color: _turnFailed
                    ? Colors.red.withValues(alpha: 0.85)
                    : Colors.blueGrey.withValues(alpha: 0.85),
                child: Row(children: [
                  Icon(
                    _turnFailed
                        ? Icons.warning_amber_rounded
                        : Icons.shield_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _turnFailed
                          ? context.l10n.callTurnUnreachable
                          : context.l10n.callRelayMode,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
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
          Text(context.l10n.callConnectingToGroup,
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 16)),
        ]),
      );
    }
    final count = entries.length;
    if (count == 1) {
      return _buildPeerTile(entries[0]);
    } else if (count == 2) {
      return Row(children: entries.map((e) => Expanded(child: _buildPeerTile(e))).toList());
    } else if (count == 3) {
      return Column(children: [
        Expanded(child: Row(children: [
          Expanded(child: _buildPeerTile(entries[0])),
          Expanded(child: _buildPeerTile(entries[1])),
        ])),
        Expanded(child: Center(child: AspectRatio(
          aspectRatio: 1.5,
          child: _buildPeerTile(entries[2]),
        ))),
      ]);
    } else {
      // 4+ peers: 2×2 grid
      return GridView.count(
        crossAxisCount: 2,
        physics: const NeverScrollableScrollPhysics(),
        children: entries.take(4).map(_buildPeerTile).toList(),
      );
    }
  }

  Widget _buildPeerTile(MapEntry<String, RTCVideoRenderer> entry) {
    final memberId = entry.key;
    final renderer = entry.value;
    final state = _peerStates[memberId];
    final connected = state == RTCIceConnectionState.RTCIceConnectionStateConnected ||
        state == RTCIceConnectionState.RTCIceConnectionStateCompleted;
    final memberContact = _getContactMap(context)[memberId];
    final isSpeaking = _speakingPeers[memberId] ?? false;

    return Stack(children: [
      Positioned.fill(
        child: connected && renderer.textureId != null
            ? RTCVideoView(renderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)
            : Container(
                color: const Color(0xFF1C1C1E),
                child: Center(child: _buildAvatar(memberContact?.name ?? '?', 64)),
              ),
      ),
      // Speaking ring
      if (isSpeaking)
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.greenAccent, width: 3),
              ),
            ),
          ),
        ),
      // Name label
      Positioned(
        left: 10, bottom: 10,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: Colors.black54, borderRadius: BorderRadius.circular(8)),
          child: Text(memberContact?.name ?? memberId,
              style: GoogleFonts.inter(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ),
      // Connection dot
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
      statusText = context.l10n.callConnecting;
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
            child: Text(context.l10n.callLive,
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
          label: _isMuted ? context.l10n.callUnmute : context.l10n.callMute,
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
        _controlBtn(
          icon: _isCameraOff
              ? Icons.videocam_off_rounded
              : Icons.videocam_rounded,
          label: _isCameraOff ? context.l10n.callCamOff : context.l10n.callCamOn,
          active: !_isCameraOff,
          onTap: () {
            setState(() => _isCameraOff = !_isCameraOff);
            _groupSignaling?.localStream
                ?.getVideoTracks()
                .forEach((t) => t.enabled = !_isCameraOff);
          },
        ),
        _controlBtn(
          icon: _isScreenSharing
              ? Icons.stop_screen_share_rounded
              : Icons.screen_share_rounded,
          label: _isScreenSharing
              ? context.l10n.callStopShare
              : context.l10n.callShareScreen,
          active: _isScreenSharing,
          onTap: _toggleScreenShare,
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
