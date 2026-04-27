import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodChannel;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/contact.dart';
import '../models/contact_repository.dart';
import '../services/sfu_signaling_service.dart';
import '../services/pulse_turn_proxy.dart';
import '../controllers/chat_controller.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../utils/platform_utils.dart';
import '../l10n/l10n_ext.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shares the same Android foreground service as the 1-on-1 call path —
/// Android 14+ requires the service to be running with
/// FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION before `getDisplayMedia` is
/// called, otherwise the app crashes with SecurityException.
const _kSfuScreenShareChannel = MethodChannel('im.pulse.messenger/screen_share');

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
  /// Pubkey currently rendered fullscreen (Teams/Meet-style "expand").
  /// Tap any tile in the grid to enter; tap close button or back to exit.
  String? _expandedPubkey;

  /// Last participant who advertised a track of each kind. Used as a
  /// fallback owner when `onRemoteTrack` fires with no usable trackId
  /// or streamId — the SFU sometimes hands us a UUID streamId for
  /// video (especially for screen shares) instead of the
  /// `sfu_<pubkey>_<kind>` label, leaving the receiver with no way to
  /// route the track to a participant tile. The most-recent
  /// `track_available` of the matching kind is the best guess.
  String? _lastVideoOwner;
  String? _lastAudioOwner;

  /// Tracks that arrived before we knew their owner — queued here, then
  /// drained the moment a matching `track_available` lands. Without
  /// this the very first onRemoteTrack of a new screen-share session
  /// (which typically races ahead of track_available) is dropped and
  /// the receiver tile stays blank until the sender re-publishes.
  final List<({MediaStreamTrack track, MediaStream stream})> _orphanTracks = [];

  Timer? _durationTimer;
  Timer? _inviteRebroadcastTimer;
  Duration _callDuration = Duration.zero;
  bool _disposed = false;
  bool _ready = false;
  RTCIceConnectionState? _iceState;


  // Contact lookup cache — avoids O(N) scan per participant per rebuild.
  // SFU participants are identified by their Pulse pubkey (64-hex) so we
  // build an index keyed on the pubkey prefix of every Pulse transport
  // address we know about. Previously `_findContact` indexed by the full
  // databaseId (`pubkey@https://server`) which never matches the bare
  // pubkey the SFU hands us → participants showed up as their 8-char
  // pubkey prefix instead of their real name.
  Map<String, Contact>? _contactByAddress;
  Contact? _findContact(BuildContext context, String pubkey) {
    // Rebuild every call: contacts get updated as sfu_invite arrives
    // with new members, and caching defeats that freshness. N is small
    // (dozens of contacts, handful of participants per frame).
    final lc = pubkey.toLowerCase();
    final contacts = context.read<IContactRepository>().contacts;
    // Step 1: Pulse → Nostr sender mapping learned from sfu_invite.
    final nostrSender = ChatController().nostrSenderForPulsePk(lc);
    // Step 2: scan all contacts, matching either the learned Nostr
    // senderId or any transport-address pubkey prefix directly.
    for (final c in contacts) {
      if (c.databaseId.toLowerCase() == lc) return c;
      for (final addrs in c.transportAddresses.values) {
        for (final addr in addrs) {
          final at = addr.indexOf('@');
          final pk = (at > 0 ? addr.substring(0, at) : addr).toLowerCase();
          if (pk.isEmpty) continue;
          if (pk == lc) return c;
          if (nostrSender != null && pk == nostrSender.toLowerCase()) return c;
        }
      }
    }
    return null;
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
        'name="${widget.group.name}" mode=${widget.group.effectiveGroupTransportMode} '
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

    // Throttle rapid hangup→call cycles. Pion's participant-cleanup is
    // async, so a `room_create` issued shortly after the previous
    // `room_leave` lands while the prior PC is still being torn down
    // server-side AND the libwebrtc-side TURN allocation hasn't been
    // released — server skips opening a fresh `[turn-ws] new session`,
    // and the new participant ends up unable to publish audio.
    final since = ChatController().sinceLastSfuExit(widget.group.id);
    if (since != null && since < const Duration(seconds: 4)) {
      final wait = const Duration(seconds: 4) - since;
      debugPrint('[SfuCall] last exit was ${since.inMilliseconds}ms ago — '
          'waiting ${wait.inMilliseconds}ms for server cleanup');
      await Future<void>.delayed(wait);
      if (_disposed || !mounted) return;
    }

    _sfu = SfuSignalingService(group: widget.group, myId: widget.myId);
    debugPrint('[SfuCall] SfuSignalingService instantiated; wiring callbacks');

    _sfu!.onTrackAvailable = (pubkey, trackId, kind) {
      if (_disposed) return;
      debugPrint('[SfuCall] onTrackAvailable: pubkey=${pubkey.substring(0, 8)}… '
          'kind=$kind trackId=$trackId');
      _trackOwners[trackId] = pubkey;
      if (kind == 'video' || kind == 'screen') _lastVideoOwner = pubkey;
      if (kind == 'audio') _lastAudioOwner = pubkey;
      _participantTracks.putIfAbsent(pubkey, () => []);
      _participantTracks[pubkey]!.add(_TrackMeta(trackId, kind));

      // Drain orphan VIDEO tracks ONLY when streamId matches the SFU's
      // `sfu_<pubkey>_video` labelling. Phantom UUID-streamId tracks
      // (Pion's recv-only m-line placeholder, never carries frames)
      // used to be drained by the bare-kind heuristic and would
      // pollute the renderer ahead of the real video → on flutter_webrtc
      // Android the texture got stuck at 0×0 → user sees only avatar.
      // Audio orphans aren't drained because audio plays from the
      // MediaStream automatically (no renderer needed).
      if (kind == 'video' || kind == 'screen') {
        final expectedStreamId = 'sfu_${pubkey}_video';
        ({MediaStreamTrack track, MediaStream stream})? matchedOrphan;
        for (final o in _orphanTracks) {
          if (o.stream.id == expectedStreamId) {
            matchedOrphan = o;
            break;
          }
        }
        if (matchedOrphan != null) {
          _orphanTracks.remove(matchedOrphan);
          final orphan = matchedOrphan;
          debugPrint('[SfuCall] draining orphan ${orphan.track.kind} track for ${pubkey.substring(0, 8)}');
          _ensureRenderer(pubkey).then((r) {
            try { r.srcObject = orphan.stream; } catch (_) {}
            if (mounted) setState(() {});
          });
        }
      }

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

      // Resolve participant. Three-tier lookup:
      //   1. _trackOwners[track.id] — populated from track_available.
      //      Almost never matches because flutter_webrtc generates a
      //      local UUID for `track.id`, NOT the server's track id.
      //   2. Stream id `sfu_<pubkey>_<kind>` — Pulse SFU labels its
      //      streams this way. Reliable when present.
      //   3. Fallback: first participant who advertised any track of
      //      this kind. Breaks down once two people share video
      //      simultaneously, but covers the common 1-publisher case.
      String? ownerPubkey = _trackOwners[track.id];
      if (ownerPubkey == null) {
        final sid = stream.id;
        if (sid.startsWith('sfu_')) {
          final rest = sid.substring(4);
          final underscore = rest.lastIndexOf('_');
          if (underscore > 0) {
            final candidate = rest.substring(0, underscore);
            // Pulse pubkeys are 64 hex chars.
            if (candidate.length == 64 &&
                RegExp(r'^[0-9a-f]+$').hasMatch(candidate)) {
              ownerPubkey = candidate;
            }
          }
        }
      }
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
      // Last-resort: the SFU forwarded a track but never sent us a
      // matching `track_available` (or it arrived with no resolvable
      // streamId pattern). Use the most-recent track_available for
      // the same kind as the owner — accurate when one publisher at a
      // time, slightly wrong if two simultaneous publishers race.
      ownerPubkey ??= track.kind == 'audio' ? _lastAudioOwner : _lastVideoOwner;
      if (ownerPubkey == null) {
        // Park as orphan — matching track_available may still arrive.
        debugPrint('[SfuCall] onRemoteTrack: parking orphan kind=${track.kind} '
            'stream=${stream.id}');
        _orphanTracks.add((track: track, stream: stream));
        // Cap the queue so we don't leak on a runaway server.
        while (_orphanTracks.length > 6) {
          _orphanTracks.removeAt(0);
        }
        return;
      }

      // Attach VIDEO ONLY to the renderer. Audio plays from the
      // MediaStream automatically (PeerConnection holds it alive).
      // CRITICAL: setting srcObject=audioStream first latches the
      // native renderer's first-frame texture binding to audio →
      // when video arrives later, srcObject swap doesn't re-arm
      // the texture on Android → RTCVideoView paints nothing.
      // Skipping audio leaves the renderer pristine for video.
      final resolvedOwner = ownerPubkey;
      if (track.kind == 'audio') {
        debugPrint('[SfuCall] audio for ${resolvedOwner.substring(0, 8)} — '
            'plays from MediaStream, no renderer attach');
        if (mounted) setState(() {});
        return;
      }
      debugPrint('[SfuCall] resolved owner=${resolvedOwner.substring(0, 8)} '
          '— calling _ensureRenderer');
      _ensureRenderer(resolvedOwner).then((r) {
        try {
          r.srcObject = stream;
          debugPrint('[SfuCall] attached stream for '
              '${resolvedOwner.substring(0, 8)} kind=${track.kind} '
              'textureId=${r.textureId}');
        } catch (e, st) {
          debugPrint('[SfuCall] srcObject assign failed: $e\n$st');
        }
        if (mounted) setState(() {});
      }).catchError((e, st) {
        debugPrint('[SfuCall] _ensureRenderer failed: $e\n$st');
      });
    };

    _sfu!.onIceState = (state) {
      if (_disposed) return;
      setState(() => _iceState = state);
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
        _startDurationTimer();
        ChatController().enterSfuCall(widget.group.id);
      }
      // Transient drop → pop back to chat. The "ongoing call" banner
      // there (driven by sfu_invite rebroadcasts from other members)
      // gives a one-tap rejoin path. Auto-rejoin in-place was tried
      // and caused `invalid signaling state transition` errors because
      // the server kept stale participant state from the old PC; manual
      // rejoin via the banner takes a clean new path each time.
      if (state == RTCIceConnectionState.RTCIceConnectionStateFailed ||
          state == RTCIceConnectionState.RTCIceConnectionStateClosed) {
        debugPrint('[SfuCall] ICE $state — popping back to chat');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(context.l10n.callEnded),
            backgroundColor: AppTheme.error,
          ));
          Navigator.of(context).pop();
        }
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
      // Start audio-only. Camera / screen share join the PC later via
      // `_toggleCamera` / `_toggleScreenShare` → `replaceVideoSource`
      // (removeTrack+addTrack+renegotiate). Having video present at
      // setup time as a disabled track doesn't help: the SFU doesn't
      // forward disabled tracks, so remote peers would never see the
      // video even after `track.enabled = true`. Lazy-adding also
      // avoids the crash on Waydroid/headless boxes where the camera
      // open fails, and lets Android request MediaProjection only when
      // the user actually taps screen-share.
      if (_disposed) { localStream.getTracks().forEach((t) => t.stop()); return; }
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
    // CRITICAL: cancel the invite rebroadcast timer here. `dispose()`
    // below is gated on `!_disposed`, which is now true, so without this
    // line the timer keeps firing every 20s for the rest of the process
    // lifetime — spamming `sfu_invite` to every group member and keeping
    // the "ongoing call" banner alive on their screens long after this
    // user hung up.
    _inviteRebroadcastTimer?.cancel();
    ChatController().exitSfuCall(widget.group.id);
    for (final s in [_cameraStream, _screenShareStream]) {
      if (s == null) continue;
      for (final t in s.getTracks()) {
        try { await t.stop(); } catch (_) {}
      }
    }
    _cameraStream = null;
    _screenShareStream = null;
    if (Platform.isAndroid && _isScreenSharing) {
      try { await _kSfuScreenShareChannel.invokeMethod('stopService'); } catch (_) {}
    }
    await _sfu?.hangUp();
    _disposeRenderers();
    // Drop the local TURN-over-WS bridge clients so call #2's PC gets
    // a clean slot — flutter_webrtc on Linux/GStreamer leaks the prior
    // allocation's TCP socket otherwise, and `_TurnWSBridge` then
    // fans WS frames to BOTH the leaked socket and the new one, which
    // routed call #2's outbound audio to a dead TURN session and
    // silently dropped it.
    PulseTurnProxy.instance.resetClients();
    // Force the Pulse WS for this group's SFU to reconnect — pion
    // doesn't release the TURN-over-WS allocation cleanly when the
    // local PC closes; a full reset gives the next call a clean
    // server-side state too.
    final serverUrl = widget.group.groupServerUrl;
    if (serverUrl.isNotEmpty) {
      unawaited(ChatController().resetGroupPulseConnection(serverUrl));
    }
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
      ChatController().exitSfuCall(widget.group.id);
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

  MediaStream? _screenShareStream;
  MediaStream? _cameraStream;
  bool _videoToggling = false;

  /// Turn camera on/off. "On" = get fresh camera stream, install as the
  /// peer connection's video sender, renegotiate with SFU. "Off" = tear
  /// down sender, renegotiate so remote peers stop seeing anything.
  /// Screen share is treated as a separate mode and always wins — the
  /// camera button becomes no-op while screen sharing.
  Future<void> _toggleCamera() async {
    if (_videoToggling || _disposed) return;
    if (_isScreenSharing) return;
    _videoToggling = true;
    try {
      if (_isCameraOff) {
        MediaStream cam;
        try {
          cam = await navigator.mediaDevices.getUserMedia({'audio': false, 'video': true});
        } catch (e) {
          debugPrint('[SfuCall] _toggleCamera: getUserMedia failed: $e');
          return;
        }
        _cameraStream = cam;
        _localRenderer.srcObject = cam;
        // Camera doesn't need 12 Mbps — 1.5 Mbps gives crisp 720p.
        await _sfu?.replaceVideoSource(cam, maxBitrate: 1500000);
        if (mounted) setState(() => _isCameraOff = false);
      } else {
        // Stop the capture locally so LEDs turn off immediately.
        if (_cameraStream != null) {
          for (final t in _cameraStream!.getTracks()) {
            try { await t.stop(); } catch (_) {}
          }
          _cameraStream = null;
        }
        _localRenderer.srcObject = null;
        await _sfu?.replaceVideoSource(null);
        if (mounted) setState(() => _isCameraOff = true);
      }
    } finally {
      _videoToggling = false;
    }
  }

  /// Start/stop screen sharing. Screen share replaces the camera as the
  /// outgoing video source; when you stop, video turns off entirely
  /// (tap the camera button to go back to camera).
  Future<void> _toggleScreenShare() async {
    if (_videoToggling || _disposed) return;
    _videoToggling = true;
    try {
      if (_isScreenSharing) {
        if (_screenShareStream != null) {
          for (final t in _screenShareStream!.getTracks()) {
            try { await t.stop(); } catch (_) {}
          }
          _screenShareStream = null;
        }
        _localRenderer.srcObject = null;
        await _sfu?.replaceVideoSource(null);
        if (Platform.isAndroid) {
          try { await _kSfuScreenShareChannel.invokeMethod('stopService'); } catch (_) {}
        }
        if (mounted) setState(() { _isScreenSharing = false; _isCameraOff = true; });
        return;
      }

      // Quality picker first — saved choice persists across calls.
      final prefs = await SharedPreferences.getInstance();
      int fps = prefs.getInt('sfu_screen_share_fps') ?? 30;
      int resWidth = prefs.getInt('sfu_screen_share_res') ?? 1920;
      if (mounted) {
        final picked = await _showScreenShareQualityDialog(fps, resWidth);
        if (picked == null) return;
        fps = picked.$1;
        resWidth = picked.$2;
        await prefs.setInt('sfu_screen_share_fps', fps);
        await prefs.setInt('sfu_screen_share_res', resWidth);
      }

      // Android 14+ requires a foreground service with
      // FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION before getDisplayMedia.
      if (Platform.isAndroid) {
        try {
          await _kSfuScreenShareChannel.invokeMethod('startService');
          await Future.delayed(const Duration(milliseconds: 300));
        } catch (e) {
          debugPrint('[SfuCall] startService failed: $e');
        }
      }

      final Map<String, dynamic> mandatory = {
        'maxFrameRate': fps.toDouble(),
        if (resWidth > 0) ...{
          'maxWidth': resWidth,
          'maxHeight': resWidth * 9 ~/ 16,
        },
      };

      MediaStream screen;
      try {
        if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
          // Desktop: enumerate sources first; the xdg-desktop-portal /
          // CGGetDisplay / Win32 Capture picker fires here. Passing
          // `deviceId` to getDisplayMedia reuses that selection so
          // the user only sees one picker. Without this step the
          // capture either fails silently or starts on a wrong
          // monitor with no UI to choose.
          final sources = await desktopCapturer.getSources(types: [SourceType.Screen]);
          if (sources.isEmpty) return;
          screen = await navigator.mediaDevices.getDisplayMedia({
            'video': {
              'deviceId': {'exact': sources.first.id},
              'mandatory': mandatory,
            },
            'audio': false,
          });
        } else {
          // Mobile: getDisplayMedia triggers the system picker directly.
          screen = await navigator.mediaDevices.getDisplayMedia({
            'video': {'mandatory': mandatory},
            'audio': false,
          });
        }
      } catch (e) {
        debugPrint('[SfuCall] getDisplayMedia failed: $e');
        if (Platform.isAndroid) {
          try { await _kSfuScreenShareChannel.invokeMethod('stopService'); } catch (_) {}
        }
        return;
      }
      // If camera was already on, stop its tracks — one video sender at a time.
      if (_cameraStream != null) {
        for (final t in _cameraStream!.getTracks()) {
          try { await t.stop(); } catch (_) {}
        }
        _cameraStream = null;
      }
      _screenShareStream = screen;
      _localRenderer.srcObject = screen;
      final screenTracks = screen.getVideoTracks();
      if (screenTracks.isNotEmpty) {
        // (flutter_webrtc doesn't expose `contentHint` on
        // MediaStreamTrack — would have liked to set 'detail' here so
        // the VP8 encoder optimises for sharpness over framerate.
        // Quality boost comes from the resolution+bitrate picker
        // instead.)
        screenTracks.first.onEnded = () {
          if (!_disposed && mounted && _isScreenSharing) {
            _toggleScreenShare();
          }
        };
      }
      final maxBitrate = _resWidthToBitrate(resWidth);
      await _sfu?.replaceVideoSource(screen, maxBitrate: maxBitrate);
      if (mounted) setState(() { _isScreenSharing = true; _isCameraOff = true; });
    } catch (e) {
      debugPrint('[SfuCall] Screen share error: $e');
    } finally {
      _videoToggling = false;
    }
  }

  /// Resolution width → max bitrate for the SFU video sender. Higher
  /// numbers = sharper picture for the same content but more upload BW.
  static int _resWidthToBitrate(int width) {
    if (width <= 0) return 0;            // Auto — let WebRTC decide
    if (width <= 1280) return 5000000;   // 720p   → 5 Mbps
    if (width <= 1920) return 12000000;  // 1080p  → 12 Mbps
    return 20000000;                     // 1440p+ → 20 Mbps
  }

  Future<(int fps, int resWidth)?> _showScreenShareQualityDialog(
      int currentFps, int currentResWidth) async {
    int selFps = currentFps;
    int selResWidth = currentResWidth;
    Widget body(BuildContext ctx, StateSetter setS) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.callScreenShareQuality,
              style: GoogleFonts.inter(color: AppTheme.textPrimary,
                  fontSize: DesignTokens.fontXl, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Text(context.l10n.callFrameRate,
              style: GoogleFonts.inter(color: AppTheme.textSecondary,
                  fontSize: DesignTokens.fontBody)),
          const SizedBox(height: 8),
          _qualityChips(
              const [15, 30, 60], const ['15 fps', '30 fps', '60 fps'],
              selFps, (v) => setS(() => selFps = v)),
          const SizedBox(height: 16),
          Text(context.l10n.callResolution,
              style: GoogleFonts.inter(color: AppTheme.textSecondary,
                  fontSize: DesignTokens.fontBody)),
          const SizedBox(height: 8),
          _qualityChips(
              const [1280, 1920, 2560, 0],
              const ['720p', '1080p', '1440p', 'Auto'],
              selResWidth, (v) => setS(() => selResWidth = v)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => Navigator.pop(ctx, (selFps, selResWidth)),
              child: Text(context.l10n.callStartSharing,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
    if (PlatformUtils.isDesktop) {
      return showDialog<(int, int)>(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: AppTheme.surface,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: StatefulBuilder(builder: body),
          ),
        ),
      );
    }
    return showModalBottomSheet<(int, int)>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(builder: body),
    );
  }

  Widget _qualityChips(List<int> options, List<String> labels,
      int selected, ValueChanged<int> onSelect) {
    return Wrap(
      spacing: 8,
      children: List.generate(options.length, (i) {
        final active = options[i] == selected;
        return GestureDetector(
          onTap: () => onSelect(options[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: active ? AppTheme.primary : AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(labels[i],
                style: GoogleFonts.inter(
                    color: active ? Colors.white : AppTheme.textSecondary,
                    fontSize: DesignTokens.fontMd,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
          ),
        );
      }),
    );
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
    final expanded = _expandedPubkey != null && participants.contains(_expandedPubkey);
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(child: Stack(children: [
        if (expanded)
          Positioned.fill(child: _buildExpanded(_expandedPubkey!, participants))
        else
          Positioned.fill(child: _buildGrid(participants)),
        Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),
        Positioned(bottom: 0, left: 0, right: 0, child: _buildControls()),
      ])),
    );
  }

  /// Fullscreen view of [pubkey] (Meet-style). Close button in the
  /// top-right corner; tapping the tile body itself does NOT collapse
  /// (avoids accidental dismissal during long screen-share sessions).
  Widget _buildExpanded(String pubkey, List<String> _) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 80, 8, 110),
      child: Stack(children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: _tile(pubkey),
          ),
        ),
        Positioned(
          top: 8, right: 8,
          child: Material(
            color: Colors.black54,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => setState(() => _expandedPubkey = null),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.fullscreen_exit_rounded, color: Colors.white, size: 22),
              ),
            ),
          ),
        ),
      ]),
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
                child: GestureDetector(
                  onTap: () => setState(() => _expandedPubkey = p),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: _tile(p),
                  ),
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
    // Show video iff THIS participant actually has a published video
    // track. Don't gate on `_activeSet` — that's the server's
    // last-N speaker subscription budget, NOT a per-participant
    // "is publishing video" signal. With activeSet gating, a non-
    // speaking participant who's screen-sharing was hidden behind
    // their avatar even though their video stream was flowing.
    final hasVideo = isSelf
        ? (!_isCameraOff || _isScreenSharing)
        : (_participantTracks[pubkey]?.any(
                (m) => m.kind == 'video' || m.kind == 'screen') ??
            false);
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
        // Mount RTCVideoView ONLY when this participant has active video.
        // Previous wrapper Visibility(maintainState:true) kept it always
        // mounted but on flutter_webrtc Android the visibility flip
        // after a srcObject swap doesn't re-arm the native first-frame
        // callback → stays at 0×0. Audio plays via MediaStream
        // regardless. ValueKey on (pubkey, textureId) makes Flutter
        // instantiate a fresh widget on transition.
        if (renderer != null && renderer.textureId != null && hasVideo)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: RTCVideoView(renderer,
                  key: ValueKey('rtcv_${pubkey}_${renderer.textureId}'),
                  mirror: isSelf && !_isScreenSharing,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
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
        highlight: !_isCameraOff,
        onTap: _toggleCamera,
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
