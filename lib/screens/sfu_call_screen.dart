import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/contact.dart';
import '../models/contact_repository.dart';
import '../services/sfu_signaling_service.dart';
import '../controllers/chat_controller.dart';
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
  bool _speakerphoneOn = true;

  Set<String> _activeSet = {};
  String? _dominant;
  Set<String> _speakers = {};
  String? _pinnedPubkey;

  Timer? _durationTimer;
  Timer? _inviteRebroadcastTimer;
  Duration _callDuration = Duration.zero;
  bool _disposed = false;
  bool _ready = false;
  RTCIceConnectionState? _iceState;

  // Contact lookup cache — avoids O(N) findByAddress scan per participant per rebuild
  Map<String, Contact>? _contactByAddress;
  Contact? _findContact(BuildContext context, String address) {
    _contactByAddress ??= {
      for (final c in context.read<IContactRepository>().contacts) c.databaseId: c
    };
    return _contactByAddress![address];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startCall());
  }

  Future<void> _startCall() async {
    await _localRenderer.initialize();

    // Make sure we have a live Pulse WebSocket pointed at this group's
    // SFU server. Without this an SFU group on a foreign server (or a
    // user whose primary identity isn't Pulse at all) hangs forever on
    // a black "Connecting…" screen because every SFU control message
    // (`room_create`, `room_join`, `media_offer`, …) was silently
    // dropped by `sendRawPulseSignal` due to a null `_cachedPulseSender`.
    debugPrint('[SfuCall] _startCall begin for group=${widget.group.id.substring(0, 8)} '
        'name="${widget.group.name}" mode=${widget.group.effectiveGroupCallMode} '
        'serverUrl="${widget.group.groupServerUrl}" '
        'existingRoom=${widget.existingRoomId != null}');
    final serverUrl = widget.group.groupServerUrl;
    if (serverUrl.isNotEmpty) {
      debugPrint('[SfuCall] calling ensureGroupPulseConnection($serverUrl)');
      final ok = await ChatController().ensureGroupPulseConnection(serverUrl);
      debugPrint('[SfuCall] ensureGroupPulseConnection returned $ok');
      if (!ok) {
        debugPrint('[SfuCall] FATAL: could not open Pulse connection to '
            '$serverUrl — call will not start');
        if (mounted) Navigator.pop(context);
        return;
      }
    } else {
      debugPrint('[SfuCall] no serverUrl set — skipping ensureGroupPulseConnection');
    }

    _sfu = SfuSignalingService(group: widget.group, myId: widget.myId);
    debugPrint('[SfuCall] SfuSignalingService instantiated; wiring callbacks');

    _sfu!.onTrackAvailable = (pubkey, trackId, kind) {
      if (_disposed) return;
      debugPrint('[SfuCall] onTrackAvailable: pubkey=${pubkey.substring(0, 8)}… '
          'kind=$kind trackId=$trackId');
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
      debugPrint('[SfuCall] onRemoteTrack: kind=${track.kind} id=${track.id} '
          'streams=${streams.length} streamId=${streams.isEmpty ? "-" : streams.first.id} '
          'enabled=${track.enabled} muted=${track.muted}');
      if (streams.isEmpty) return;
      final stream = streams.first;
      // Force-enable the track in case the server muted it on the way in.
      track.enabled = true;

      // Resolve participant. First by trackId via the _trackOwners map
      // populated from `track_available` SFU notifications. Fall back to
      // matching the track's KIND against a participant who advertised a
      // track of that kind (works while no two participants of the same
      // kind have arrived simultaneously — good enough for 3-4 person
      // calls until the SFU server starts labelling streams by pubkey).
      String? ownerPubkey = _trackOwners[track.id];
      if (ownerPubkey == null) {
        for (final entry in _participantTracks.entries) {
          for (final meta in entry.value) {
            final wantsThisKind = (track.kind == 'video' &&
                    (meta.kind == 'video' || meta.kind == 'screen')) ||
                (track.kind == 'audio' && meta.kind == 'audio');
            if (wantsThisKind) {
              ownerPubkey = entry.key;
              break;
            }
          }
          if (ownerPubkey != null) break;
        }
      }
      if (ownerPubkey == null) return;

      // Attach the stream to the participant's renderer for BOTH audio
      // and video. flutter_webrtc plays the audio through the stream as
      // long as the renderer is mounted in the widget tree — that's why
      // _tile() always rendres an RTCVideoView (zero-size when there's
      // no active video to display) so audio for camera-off members
      // still reaches the speakers.
      _ensureRenderer(ownerPubkey).then((r) {
        r.srcObject = stream;
        if (mounted) setState(() {});
      });
    };

    _sfu!.onIceState = (state) {
      if (_disposed) return;
      setState(() => _iceState = state);
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
        _startDurationTimer();
      }
    };

    _sfu!.onRoomCreateFailed = () {
      if (_disposed || !mounted) return;
      debugPrint('[SfuCall] room_create gave up — popping back to chat');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.callConnectionFailed),
        backgroundColor: AppTheme.error,
      ));
      Navigator.of(context).pop();
    };

    _sfu!.onRoomReady = () async {
      if (_disposed) return;
      // Caller side: now that the SFU room exists with a token, fan-out an
      // sfu_invite signal to every group member so their incoming-call UI
      // pops with this room's id+token. Receivers tap "Accept" → join the
      // same room. Without this step the caller is talking to themselves.
      if (widget.isCaller && _sfu?.roomId != null && _sfu?.roomToken != null) {
        final ctrl = context.read<ChatController>();
        unawaited(ctrl.broadcastSfuCallInvite(
            widget.group, _sfu!.roomId!, _sfu!.roomToken!));
      }
      // Conference re-broadcast: every participant (caller AND joiners)
      // periodically re-sends the invite so members who were offline at
      // call-start, declined the popup, or just installed the app on a
      // second device discover the ongoing room. The signal is tiny
      // (~150B), the dispatcher dedups by `_sid`, and the receiver-side
      // ChatController.activeGroupCall map only adds the entry once.
      _inviteRebroadcastTimer?.cancel();
      final rid = _sfu?.roomId;
      final tok = _sfu?.roomToken;
      if (rid != null && tok != null) {
        final ctrl = context.read<ChatController>();
        _inviteRebroadcastTimer = Timer.periodic(
          const Duration(seconds: 20),
          (_) {
            if (_disposed) return;
            unawaited(ctrl.broadcastSfuCallInvite(widget.group, rid, tok));
          },
        );
      }
      // Room joined — set up PC and send media.
      //
      // Audio and video MUST be requested separately: combined
      // getUserMedia({audio, video}) on Linux/Windows libwebrtc returns an
      // audio track that captures silence (clock-domain mismatch between
      // the V4L2 video device and the ALSA/PipeWire audio source). The
      // legacy 1-on-1 call already discovered this — see call_screen.dart
      // _openUserMedia which deliberately splits them. SFU did the same
      // mistake; that's why only Android (which uses MediaRecorder, single
      // clock) had a working mic, while Linux + Windows transmitted dead
      // air.
      MediaStream? localStream;
      try {
        // Plain `audio: true` mirrors the 1-on-1 call flow that's known to
        // produce a working mic on Linux/Windows. Constraint objects with
        // noise suppression flags pass through libwebrtc and silently
        // bind to a NullSource on desktop when WebRTC's audio APM doesn't
        // recognise the device — capture succeeds but the track sends
        // pure silence (server's forwardRTP times out after 30s).
        localStream = await navigator.mediaDevices.getUserMedia({
          'audio': true,
          'video': false,
        });
      } catch (e) {
        debugPrint('[SfuCall] getUserMedia(audio) failed: $e — '
            'joining as receive-only listener');
        try {
          localStream = await createLocalMediaStream(
              'sfu_listener_${DateTime.now().millisecondsSinceEpoch}');
        } catch (e3) {
          debugPrint('[SfuCall] FATAL: cannot even create empty stream: $e3');
          if (mounted) Navigator.pop(context);
          return;
        }
      }
      // Try to attach a video track too — separately, so audio capture
      // already running keeps its clock domain. Skip silently on devices
      // without a camera (Waydroid, headless box) — those joined as
      // audio-only above; we'll still send their voice.
      try {
        final videoStream = await navigator.mediaDevices.getUserMedia({
          'audio': false,
          'video': true,
        });
        for (final t in videoStream.getVideoTracks()) {
          localStream.addTrack(t);
        }
      } catch (e) {
        debugPrint('[SfuCall] getUserMedia(video) skipped: $e — audio-only');
      }
      if (_disposed) { localStream.getTracks().forEach((t) => t.stop()); return; }

      // Camera off by default
      for (final t in localStream.getVideoTracks()) { t.enabled = false; }
      _localRenderer.srcObject = localStream;

      // Route audio to the loudspeaker, not the earpiece. Without this on
      // Android (and even some Linux setups), remote audio is silently
      // playing into the phone's tiny earpiece speaker — looks like "no
      // sound" because at arm's length you can't hear it.
      if (Platform.isAndroid || Platform.isIOS) {
        try {
          await Helper.setSpeakerphoneOn(true);
        } catch (e) {
          debugPrint('[SfuCall] setSpeakerphoneOn failed: $e');
        }
      }

      await _sfu!.setupPeerConnection(localStream);
      if (mounted) setState(() => _ready = true);
    };

    if (widget.existingRoomId != null && widget.existingToken != null) {
      debugPrint('[SfuCall] joinRoom(${widget.existingRoomId}) — caller=false');
      await _sfu!.joinRoom(widget.existingRoomId!, widget.existingToken!);
    } else {
      debugPrint('[SfuCall] createRoom() — caller=true');
      await _sfu!.createRoom();
    }
    debugPrint('[SfuCall] _startCall finished kicking off room flow');
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
      _inviteRebroadcastTimer?.cancel();
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
    backgroundColor: AppTheme.background,
    body: SafeArea(
      child: Stack(children: [
        Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 88, height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary.withValues(alpha: 0.12),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4), width: 2),
            ),
            child: Center(
              child: Icon(Icons.group_rounded, color: AppTheme.primary, size: 38),
            ),
          ),
          const SizedBox(height: 28),
          Text(widget.group.name,
              style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(context.l10n.callStarting,
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14)),
          const SizedBox(height: 24),
          SizedBox(
            width: 120,
            child: LinearProgressIndicator(
              backgroundColor: AppTheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation(AppTheme.primary),
              minHeight: 3,
            ),
          ),
          const SizedBox(height: 36),
          // Cancel/hangup — always available, even mid-connect. Without
          // this the loading screen had no escape hatch and a stuck SFU
          // bring-up locked the user inside until they killed the app.
          GestureDetector(
            onTap: _hangUp,
            child: Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: AppTheme.error,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.error.withValues(alpha: 0.4),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 26),
            ),
          ),
          const SizedBox(height: 8),
          Text(context.l10n.cancel,
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondary, fontSize: 12)),
        ])),
        // Top-left back button as a second exit — works even if the user
        // doesn't notice the central hangup.
        Positioned(
          top: 8, left: 8,
          child: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textSecondary),
            onPressed: _hangUp,
            tooltip: context.l10n.cancel,
          ),
        ),
      ]),
    ),
  );

  /// Sentinel for the local user inside the participants list. Sorts to
  /// position 0 so "you" is always the leftmost tile in the grid.
  static const _selfKey = '__self__';

  Widget _buildCall() {
    final participants = <String>[
      _selfKey,
      ..._participantTracks.keys,
    ];
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(child: Stack(children: [
        Positioned.fill(child: _buildGrid(participants)),
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
    // Discord/Telegram-style equal grid: every participant gets the same
    // tile size, separated by gaps + rounded corners so the layout is
    // visually parsable even when everybody has video off.
    int cols, rows;
    if (c == 1)        { cols = 1; rows = 1; }
    else if (c == 2)   { cols = 2; rows = 1; }
    else if (c <= 4)   { cols = 2; rows = 2; }
    else if (c <= 6)   { cols = 3; rows = 2; }
    else if (c <= 9)   { cols = 3; rows = 3; }
    else               { cols = 4; rows = ((c + 3) ~/ 4); }
    final shown = participants.take(cols * rows).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 80, 8, 110), // top-bar + controls
      child: LayoutBuilder(builder: (_, constraints) {
        const gap = 6.0;
        final tileW = (constraints.maxWidth - gap * (cols - 1)) / cols;
        final tileH = (constraints.maxHeight - gap * (rows - 1)) / rows;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          alignment: WrapAlignment.center,
          children: [
            for (final p in shown)
              SizedBox(
                width: tileW,
                height: tileH,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: _tile(p),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _tile(String pubkey) {
    final isSelf = pubkey == _selfKey;
    final renderer = isSelf ? _localRenderer : _remoteRenderers[pubkey];
    // Self always shows video when camera is on; remotes follow the SFU's
    // active-set so quality stays inside our subscription budget.
    final hasVideo = isSelf
        ? !_isCameraOff
        : (_activeSet.isEmpty || _activeSet.contains(pubkey));
    final isSpeaking = !isSelf && _speakers.contains(pubkey);
    final isDominant = !isSelf && pubkey == _dominant;
    final isPinned = !isSelf && pubkey == _pinnedPubkey;

    final String name;
    if (isSelf) {
      name = context.l10n.systemActorYou;
    } else {
      final contact = _findContact(context, pubkey);
      name = contact?.name ?? (pubkey.length > 8 ? pubkey.substring(0, 8) : pubkey);
    }

    return GestureDetector(
      onDoubleTap: isSelf ? null : () => _togglePin(pubkey),
      child: Stack(children: [
        // Card background — uses theme surface, soft border so tiles read
        // as separate cards on the dark background.
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSpeaking
                    ? (isDominant ? AppTheme.primary : AppTheme.primary.withValues(alpha: 0.6))
                    : AppTheme.surfaceVariant,
                width: isSpeaking ? 2 : 1,
              ),
            ),
            child: Center(child: _avatar(name, _avatarSizeFor(participantsCount: _participantTracks.length + 1))),
          ),
        ),
        // RTCVideoView lives in the tree even when video is muted so the
        // audio sink stays attached and we keep hearing camera-off
        // participants. Hidden behind the avatar via Offstage when there's
        // no active video.
        if (renderer != null && renderer.textureId != null)
          Positioned.fill(
            child: Offstage(
              offstage: !hasVideo,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: RTCVideoView(renderer,
                    mirror: isSelf && !_isScreenSharing,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
              ),
            ),
          ),
        if (isPinned) Positioned(
          right: 10, top: 10,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.push_pin_rounded, color: Colors.white, size: 12),
          ),
        ),
        if (!hasVideo) Positioned(
          left: 10, top: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.background.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.mic_rounded, size: 10, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text('audio',
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: 10)),
            ]),
          ),
        ),
        Positioned(left: 10, bottom: 10, right: 10, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              color: AppTheme.background.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(10)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (isSpeaking) ...[
              Icon(Icons.graphic_eq_rounded,
                  color: isDominant ? AppTheme.primary : AppTheme.primary.withValues(alpha: 0.7),
                  size: 12),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(name,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                      color: AppTheme.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
        )),
      ]),
    );
  }

  /// Picks an avatar size that reads well at the current grid density.
  /// 1-2 participants → big avatar, 5+ → smaller so it fits.
  double _avatarSizeFor({required int participantsCount}) {
    if (participantsCount <= 2) return 96;
    if (participantsCount <= 4) return 76;
    if (participantsCount <= 9) return 56;
    return 44;
  }

  Widget _avatar(String name, double size) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary.withValues(alpha: 0.55),
            AppTheme.primary.withValues(alpha: 0.18),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.18),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(initial,
            style: GoogleFonts.inter(
                color: AppTheme.onPrimary,
                fontSize: size * 0.42,
                fontWeight: FontWeight.w700)),
      ),
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.background.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primary.withValues(alpha: 0.15),
          ),
          child: Icon(Icons.group_rounded, color: AppTheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.group.name,
                style: GoogleFonts.inter(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Row(children: [
              Container(
                width: 6, height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: connected ? Colors.greenAccent : Colors.orange,
                ),
              ),
              const SizedBox(width: 6),
              Text(status,
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: 12)),
              Text('  ·  ',
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: 12)),
              Text(context.l10n.sfuParticipants(_participantTracks.length + 1),
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: 12)),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _buildControls() => Container(
    padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      boxShadow: [
        BoxShadow(
          color: AppTheme.background.withValues(alpha: 0.4),
          blurRadius: 12,
          offset: const Offset(0, -2),
        ),
      ],
    ),
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
      _ctrl(
        icon: _isCameraOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
        label: _isCameraOff ? context.l10n.callCamOff : context.l10n.callCamOn,
        active: !_isCameraOff,
        // Toggling camera = the visual on/off, NOT mute. Use neutral
        // surface color when off (camera-off is the default, not an
        // alarming state) and primary highlight when on.
        highlight: !_isCameraOff,
        onTap: () {
          setState(() => _isCameraOff = !_isCameraOff);
          _sfu?.localStream?.getVideoTracks().forEach((t) => t.enabled = !_isCameraOff);
        },
      ),
      GestureDetector(onTap: _hangUp, child: Container(
        width: 60, height: 60,
        decoration: BoxDecoration(
          color: AppTheme.error,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.error.withValues(alpha: 0.4),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 26),
      )),
      _ctrl(
        icon: _isScreenSharing ? Icons.stop_screen_share_rounded : Icons.screen_share_rounded,
        label: _isScreenSharing ? context.l10n.callStopShare : context.l10n.callShareScreen,
        active: _isScreenSharing,
        highlight: _isScreenSharing,
        onTap: _toggleScreenShare,
      ),
      // Speakerphone toggle (mobile only — desktop routes through OS).
      if (Platform.isAndroid || Platform.isIOS)
        _ctrl(
          icon: _speakerphoneOn ? Icons.volume_up_rounded : Icons.volume_down_rounded,
          label: _speakerphoneOn ? 'Speaker' : 'Earpiece',
          active: false,
          highlight: _speakerphoneOn,
          onTap: () async {
            final next = !_speakerphoneOn;
            try { await Helper.setSpeakerphoneOn(next); } catch (_) {}
            if (mounted) setState(() => _speakerphoneOn = next);
          },
        ),
    ]),
  );

  Widget _ctrl({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
    bool highlight = false,
  }) {
    // Three visual states:
    //   active   = "this is the muted/off state" — uses error color
    //   highlight = "this is the on/active state" — uses primary
    //   neutral   = idle — uses surface variant
    final Color bg;
    final Color iconColor;
    if (active) {
      bg = AppTheme.error.withValues(alpha: 0.18);
      iconColor = AppTheme.error;
    } else if (highlight) {
      bg = AppTheme.primary.withValues(alpha: 0.22);
      iconColor = AppTheme.primary;
    } else {
      bg = AppTheme.surfaceVariant;
      iconColor = AppTheme.textPrimary;
    }
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: GoogleFonts.inter(
                color: AppTheme.textSecondary, fontSize: 11)),
      ]),
    );
  }
}

class _TrackMeta {
  final String trackId;
  final String kind;
  _TrackMeta(this.trackId, this.kind);
}
