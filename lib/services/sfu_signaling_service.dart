import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../controllers/chat_controller.dart';
import '../models/contact.dart';
import 'call_transport.dart';

/// SFU signaling service — single PeerConnection to the Pulse server.
///
/// Send path: raw JSON over existing Pulse WS via [ChatController.sendRawPulseSignal].
/// Receive path: PulseInboxReader forwards SFU types as `{type: 'sfu', payload: ...}`
/// through signalStream.
class SfuSignalingService {
  final Contact group;
  final String myId;

  RTCPeerConnection? _pc;
  RTCPeerConnection? get peerConnection => _pc;
  MediaStream? localStream;
  /// The currently active video sender (camera or screen share). Kept so
  /// we can `removeTrack` it when switching sources — `replaceTrack` is
  /// broken in flutter_webrtc on Linux/GStreamer; remote never gets the
  /// new frames, so we do the remove+addTrack+renegotiate dance.
  RTCRtpSender? _videoSender;
  RTCRtpSender? get videoSender => _videoSender;
  String? _roomId;
  String? _roomToken;
  bool _disposed = false;

  // Callbacks
  Function(String pubkey, String trackId, String kind)? onTrackAvailable;
  Function(String pubkey)? onParticipantLeft;
  Function(List<String> activeSet, String? dominant)? onLastNUpdate;
  Function(List<String> speakers, String? dominant)? onSpeakerUpdate;
  Function(RTCTrackEvent event)? onRemoteTrack;
  Function(RTCIceConnectionState state)? onIceState;
  VoidCallback? onRoomReady;
  /// Fired when room_create / room_join exhausts retries — UI should pop
  /// the loading screen and show "couldn't reach SFU server" so the user
  /// isn't stranded.
  VoidCallback? onRoomCreateFailed;

  StreamSubscription? _signalSub;

  // Retry state for room_create / room_join — the Pulse WS sink silently
  // drops bytes if the underlying socket has half-closed (server EOF arrives
  // late on the read side), so a `sent=true` from sendRaw does NOT prove
  // the message reached the wire. If room_created/room_info doesn't come
  // back in time, resend; SfuCallScreen otherwise sits in `_buildLoading()`
  // forever.
  Timer? _roomCreateTimer;
  int _roomCreateAttempts = 0;
  static const _kMaxRoomCreateAttempts = 4;
  static const _kRoomCreateTimeout = Duration(seconds: 6);

  SfuSignalingService({required this.group, required this.myId});

  String? get roomId => _roomId;
  String? get roomToken => _roomToken;

  /// Create a new SFU room.
  Future<void> createRoom() async {
    _listenForSfuSignals();
    _roomCreateAttempts = 0;
    unawaited(_sendRoomCreateWithRetry());
  }

  Future<void> _sendRoomCreateWithRetry() async {
    if (_disposed || _roomId != null) return;
    _roomCreateAttempts++;
    debugPrint('[SFU] room_create attempt $_roomCreateAttempts/$_kMaxRoomCreateAttempts');
    // After 1st silent failure assume the underlying Pulse WS is dead
    // (Dart sink.add returns without error on a half-closed socket — the
    // bytes pile up in the OS buffer and never reach the wire). Force a
    // reconnect AND WAIT for it to finish auth before sending — otherwise
    // we race the new sender's wiring and fall through to "no
    // authenticated connection".
    if (_roomCreateAttempts > 1) {
      await ChatController().resetGroupPulseConnection(group.groupServerUrl);
    }
    if (_disposed || _roomId != null) return;
    _send({'type': 'room_create', 'max': 20, 'name': group.name, 'e2ee': true});
    _roomCreateTimer?.cancel();
    _roomCreateTimer = Timer(_kRoomCreateTimeout, () {
      if (_disposed || _roomId != null) return;
      if (_roomCreateAttempts < _kMaxRoomCreateAttempts) {
        debugPrint('[SFU] room_create timeout — retrying');
        unawaited(_sendRoomCreateWithRetry());
      } else {
        debugPrint('[SFU] room_create gave up after $_roomCreateAttempts attempts');
        onRoomCreateFailed?.call();
      }
    });
  }

  /// Join an existing SFU room.
  Future<void> joinRoom(String roomId, String token) async {
    _roomId = roomId;
    _roomToken = token;
    _listenForSfuSignals();
    _roomCreateAttempts = 0;
    unawaited(_sendRoomJoinWithRetry());
  }

  Future<void> _sendRoomJoinWithRetry() async {
    if (_disposed) return;
    _roomCreateAttempts++;
    debugPrint('[SFU] room_join attempt $_roomCreateAttempts/$_kMaxRoomCreateAttempts');
    if (_roomCreateAttempts > 1) {
      await ChatController().resetGroupPulseConnection(group.groupServerUrl);
    }
    if (_disposed) return;
    _send({'type': 'room_join', 'room_id': _roomId, 'token': _roomToken});
    _roomCreateTimer?.cancel();
    _roomCreateTimer = Timer(_kRoomCreateTimeout, () {
      if (_disposed) return;
      if (_roomCreateAttempts < _kMaxRoomCreateAttempts) {
        debugPrint('[SFU] room_join timeout — retrying');
        unawaited(_sendRoomJoinWithRetry());
      } else {
        debugPrint('[SFU] room_join gave up after $_roomCreateAttempts attempts');
        onRoomCreateFailed?.call();
      }
    });
  }

  /// Set up PeerConnection with simulcast and send offer.
  Future<void> setupPeerConnection(MediaStream stream) async {
    localStream = stream;

    // Build ICE config that fits the user's stealth profile. Default for
    // SFU is "Restricted" — TURNS-only over the local PulseTurnProxy →
    // 443/TCP/TLS WebSocket tunnel — so the entire media plane (DTLS+SRTP)
    // rides inside the same uTLS+ECH connection that carries chat traffic.
    // GFW / Iranian / Russian DPI sees one TLS flow on 443, no STUN, no
    // exposed UDP, no separately-fingerprintable WebRTC handshake.
    //
    // Auto profile is only used if the user has a working direct path
    // (no Force-Tor, no Restricted toggle) — otherwise we always force
    // relay-only so the call never falls back to plain UDP.
    final pcConfig = await _buildPeerConfig();
    debugPrint('[SFU] PC config: iceTransportPolicy=${pcConfig['iceTransportPolicy']} '
        'bundlePolicy=${pcConfig['bundlePolicy']} iceServers=${pcConfig['iceServers']}');
    _pc = await createPeerConnection(pcConfig);

    _pc!.onIceCandidate = (c) {
      debugPrint('[SFU] onIceCandidate: ${c.candidate}');
      if (c.candidate != null && _roomId != null) {
        _send({
          'type': 'media_candidate',
          'room_id': _roomId,
          'candidate': c.candidate,
          'sdp_mid': c.sdpMid ?? '',
          'sdp_mline_index': c.sdpMLineIndex ?? 0,
        });
      }
    };

    _pc!.onIceConnectionState = (state) {
      debugPrint('[SFU] ICE state: $state');
      onIceState?.call(state);
    };
    _pc!.onIceGatheringState = (state) {
      debugPrint('[SFU] ICE gathering: $state');
    };
    _pc!.onTrack = (event) => onRemoteTrack?.call(event);

    // Add audio tracks
    for (final track in stream.getAudioTracks()) {
      debugPrint('[SFU] adding audio track: id=${track.id} '
          'enabled=${track.enabled} muted=${track.muted} kind=${track.kind} '
          'label=${track.label}');
      track.enabled = true;
      await _pc!.addTrack(track, stream);
    }

    // Add video tracks with simulcast (non-Linux)
    for (final track in stream.getVideoTracks()) {
      if (Platform.isLinux) {
        _videoSender = await _pc!.addTrack(track, stream);
      } else {
        final trans = await _pc!.addTransceiver(
          track: track,
          kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
          init: RTCRtpTransceiverInit(
            direction: TransceiverDirection.SendOnly,
            sendEncodings: [
              RTCRtpEncoding(rid: 'f', maxBitrate: 2500000, scaleResolutionDownBy: 1.0),
              RTCRtpEncoding(rid: 'h', maxBitrate: 600000, scaleResolutionDownBy: 2.0),
              RTCRtpEncoding(rid: 'q', maxBitrate: 150000, scaleResolutionDownBy: 4.0),
            ],
          ),
        );
        _videoSender = trans.sender;
      }
    }

    var offer = await _pc!.createOffer();
    offer = _applyDtx(offer);
    await _pc!.setLocalDescription(offer);

    final sdp = offer.sdp ?? '';
    final mLines = RegExp(r'^m=', multiLine: true).allMatches(sdp).length;
    final audio = RegExp(r'^m=audio', multiLine: true).allMatches(sdp).length;
    final video = RegExp(r'^m=video', multiLine: true).allMatches(sdp).length;
    debugPrint('[SFU] setupPeerConnection: media_offer mlines=$mLines '
        'audio=$audio video=$video');
    _send({'type': 'media_offer', 'room_id': _roomId, 'sdp': offer.sdp});
  }

  /// Swap the current outgoing video source (camera → screen, screen →
  /// camera, or none → camera) and renegotiate with the SFU. Passing
  /// `null` removes the sender entirely (video off for remote peers).
  ///
  /// Uses `removeTrack` + `addTrack` rather than `replaceTrack` because
  /// the latter is broken in flutter_webrtc on Linux/GStreamer — remote
  /// never sees the new frames.
  Future<void> replaceVideoSource(MediaStream? newStream,
      {int maxBitrate = 2500000}) async {
    if (_disposed || _pc == null) {
      debugPrint('[SFU] replaceVideoSource: skipped (disposed=$_disposed pc=${_pc != null})');
      return;
    }
    final pc = _pc!;
    debugPrint('[SFU] replaceVideoSource: enter (newStream=${newStream?.id ?? "null"} '
        'oldSender=${_videoSender != null})');
    // Tear down the current video sender if we had one.
    if (_videoSender != null) {
      try {
        await pc.removeTrack(_videoSender!);
        debugPrint('[SFU] replaceVideoSource: removed old video sender');
      } catch (e) {
        debugPrint('[SFU] replaceVideoSource: removeTrack failed: $e');
      }
      _videoSender = null;
    }
    // Add the new track if provided.
    if (newStream != null) {
      final tracks = newStream.getVideoTracks();
      debugPrint('[SFU] replaceVideoSource: newStream has ${tracks.length} video track(s)');
      if (tracks.isNotEmpty) {
        try {
          // Pass the original audio MediaStream as the addTrack stream
          // arg so the SDP `a=msid:<streamId> <trackId>` lines for both
          // audio AND video share the same streamId. With different
          // msids the SFU re-classifies the audio as a NEW publication
          // on every renegotiation — that's why other participants
          // briefly stopped hearing the screen-sharer.
          final stream = localStream ?? newStream;
          _videoSender = await pc.addTrack(tracks.first, stream);
          debugPrint('[SFU] replaceVideoSource: added new video sender (track=${tracks.first.id})');
          // Default sender bitrate is ~250 kbps — way too low for
          // screen share or full-frame camera. Caller passes the
          // chosen quality (5/12/20 Mbps for 720/1080/1440p).
          if (maxBitrate > 0) {
            try {
              final params = _videoSender!.parameters;
              params.encodings ??= [RTCRtpEncoding()];
              for (final enc in params.encodings!) {
                enc.maxBitrate = maxBitrate;
                enc.active = true;
              }
              // For screen share / camera at user-picked quality:
              // prefer to drop FPS over resolution. Without this the
              // VP8 encoder defaults to maintain-framerate, which
              // dumps the chosen 1440p down to 360p the instant the
              // network blips — text becomes unreadable.
              params.degradationPreference =
                  RTCDegradationPreference.MAINTAIN_RESOLUTION;
              await _videoSender!.setParameters(params);
            } catch (e) {
              debugPrint('[SFU] replaceVideoSource: setParameters failed: $e');
            }
          }
        } catch (e) {
          debugPrint('[SFU] replaceVideoSource: addTrack failed: $e');
        }
      }
    }
    // Renegotiate so the server learns about the change.
    try {
      var offer = await pc.createOffer();
      offer = _applyDtx(offer);
      // Inject `b=AS:<kbps>` into the video m-line so the GStreamer
      // encoder sees the bandwidth target up-front. Without this, the
      // VP8 encoder stays at its default ~250 kbps cap and the
      // receiver gets a smeared low-resolution picture even when
      // setParameters() was called with a 20 Mbps maxBitrate cap.
      if (maxBitrate > 0) {
        final patched = _injectVideoBitrate(offer.sdp ?? '', maxBitrate ~/ 1000);
        offer = RTCSessionDescription(patched, offer.type);
      }
      await pc.setLocalDescription(offer);
      final sdp = offer.sdp ?? '';
      final mLines = RegExp(r'^m=', multiLine: true).allMatches(sdp).length;
      final videoLines = RegExp(r'^m=video', multiLine: true).allMatches(sdp).length;
      final hasAS = RegExp(r'^b=AS:', multiLine: true).hasMatch(sdp);
      debugPrint('[SFU] replaceVideoSource: sending media_offer '
          '(mlines=$mLines video=$videoLines b=AS=$hasAS)');
      _send({'type': 'media_offer', 'room_id': _roomId, 'sdp': offer.sdp});
    } catch (e) {
      debugPrint('[SFU] replaceVideoSource: renegotiation failed: $e');
    }
  }

  /// Inserts `b=AS:<kbps>` directly under the video m= line. Targeting
  /// only the video m-line keeps audio bitrate untouched (Opus picks
  /// its own.)
  String _injectVideoBitrate(String sdp, int kbps) {
    return sdp.replaceFirstMapped(
      RegExp(r'(m=video [^\r\n]*\r?\n)((?:i=[^\r\n]*\r?\n)?(?:c=[^\r\n]*\r?\n)?)'),
      (m) => '${m.group(1)!}${m.group(2)!}b=AS:$kbps\r\n',
    );
  }

  /// Pending subscriptions queued before the local PC was ready.
  /// `room_info` arrives in ~50ms after `room_join`, but `setupPeerConnection`
  /// takes ~1s (getUserMedia → SDP → media_offer round-trip). The server
  /// rejects `track_subscribe` with "no PeerConnection" if it lands first,
  /// so the audio fan-out is silently lost. Buffer here and flush from
  /// `media_answer` (which is the moment the server-side PC is ready).
  final List<({String trackId, String layer})> _pendingSubscriptions = [];
  /// All tracks we ever subscribed to. Replayed after each
  /// client-driven renegotiation because the SFU drops the recv
  /// subscriptions when we send it a fresh media_offer that doesn't
  /// list them in our SDP.
  final Map<String, ({String trackId, String layer})> _knownSubscriptions = {};
  bool _pcReadyForSubscribes = false;

  void subscribeTrack(String trackId, {String layer = 'h'}) {
    if (_roomId == null) return;
    _knownSubscriptions[trackId] = (trackId: trackId, layer: layer);
    if (!_pcReadyForSubscribes) {
      _pendingSubscriptions.add((trackId: trackId, layer: layer));
      return;
    }
    _send({'type': 'track_subscribe', 'room_id': _roomId, 'track_id': trackId, 'layer': layer});
  }

  void _flushPendingSubscriptions() {
    if (_pendingSubscriptions.isEmpty) return;
    debugPrint('[SFU] flushing ${_pendingSubscriptions.length} queued track_subscribe(s)');
    for (final s in _pendingSubscriptions) {
      _send({'type': 'track_subscribe', 'room_id': _roomId, 'track_id': s.trackId, 'layer': s.layer});
    }
    _pendingSubscriptions.clear();
  }

  /// Builds the PeerConnection config:
  ///   - Restricted (TURNS-only, relay policy) when Force-Tor or the
  ///     "Restricted" toggle is on, OR when no direct STUN candidates are
  ///     reachable (default for SFU which always wants to ride the WS
  ///     tunnel rather than expose a separate UDP/DTLS plane).
  ///   - Auto (full ICE) only when the user explicitly opts out of stealth.
  ///
  /// Linux + Windows have a flutter_webrtc bug where >10 ICE servers in
  /// CreateIceServers segfault native code (__libc_free). Trim to a safe
  /// top-N (3 STUN + 7 TURN) on those platforms — same pattern as
  /// signaling_service.dart and group_signaling_service.dart.
  Future<Map<String, dynamic>> _buildPeerConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final forceRelay = prefs.getBool('dev_force_relay') ?? false;
    final forceTor   = prefs.getBool('force_tor_enabled') ?? false;
    final restricted = prefs.getBool('restricted_network') ?? false;
    // Default SFU behavior is restricted — keeps every byte inside the
    // existing uTLS+ECH WS tunnel rather than opening a fresh DTLS UDP
    // plane that GFW/Iran would fingerprint within seconds.
    final useRestricted = forceRelay || forceTor || restricted || _kSfuStealthDefault;

    final profile = useRestricted
        ? CallTransportProfile.restricted
        : CallTransportProfile.auto;
    var cfg = await profile.peerConfig();

    var servers = (cfg['iceServers'] as List?)?.cast<Map<String, dynamic>>()
        ?? const <Map<String, dynamic>>[];

    // Race: when ensureGroupPulseConnection just opened an adhoc reader to
    // the group's server, TURN credentials are written to secure storage
    // asynchronously after auth_ok. profile.peerConfig() reads them back
    // through IceServerConfig.loadRelay() — if we get here a few hundred
    // ms after auth, the secure-storage write may still be in flight and
    // loadRelay returns empty, leaving the SFU PC with no TURN server at
    // all and the call silently failing.
    //
    // Retry the load a few times before giving up: each iteration is
    // cheap (one secure-storage read), gives the auth side time to land
    // its credentials, and recovers without involving the user.
    if (useRestricted && servers.isEmpty) {
      for (var attempt = 0; attempt < 10 && servers.isEmpty; attempt++) {
        await Future<void>.delayed(const Duration(milliseconds: 150));
        cfg = await profile.peerConfig();
        servers = (cfg['iceServers'] as List?)?.cast<Map<String, dynamic>>()
            ?? const <Map<String, dynamic>>[];
      }
    }

    if (useRestricted && servers.isEmpty) {
      // Last-resort fallback: synthesize a TURNS entry from the group's
      // own Pulse server URL. Pulse servers always expose TURNS on
      // port 8080 (see server's auth_ok response). Without this, a
      // first-time SFU call on a fresh client wedges with "no TURNS
      // available" before secure storage has caught up.
      final fallback = await _synthesizeGroupTurns();
      if (fallback != null) {
        servers = [fallback];
        debugPrint('[SFU] Using synthesized fallback TURNS '
            '(${fallback['urls']}) — secure storage credentials not yet '
            'persisted by the adhoc Pulse reader.');
      } else {
        debugPrint('[SFU] WARNING: restricted profile but no TURNS servers '
            'available. SFU connection will fail. Configure a TURN server '
            'or disable Force-Tor / Restricted Network.');
      }
    }

    final trimmed = _safeIceServers(servers);
    return {
      ...cfg,
      'iceServers': trimmed,
      'bundlePolicy': 'max-bundle',
    };
  }

  // SFU defaults to TURNS-only (stealth). Set to false to allow direct
  // STUN/UDP plane — generally undesirable since it opens a fingerprintable
  // surface that GFW will pick up even when chat traffic is hidden.
  static const bool _kSfuStealthDefault = true;

  /// Synthesizes a TURNS entry that points at the same Pulse server that
  /// hosts this group's SFU room. Used when IceServerConfig.loadRelay()
  /// returned empty (cold start, secure storage write race) — Pulse
  /// servers always expose TURNS on port 8080, and the same Ed25519
  /// pubkey/seed authenticates against TURN as against the WS endpoint,
  /// so we already have what we need without waiting for the adhoc
  /// reader to flush its credentials.
  Future<Map<String, dynamic>?> _synthesizeGroupTurns() async {
    final url = group.groupServerUrl;
    if (url.isEmpty) return null;
    // Strip scheme and any path. Server URLs are stored as
    // `https://host:port[/...]` — we want just `host:port`.
    var hostPort = url;
    if (hostPort.startsWith('https://')) {
      hostPort = hostPort.substring('https://'.length);
    } else if (hostPort.startsWith('http://')) {
      hostPort = hostPort.substring('http://'.length);
    }
    final slash = hostPort.indexOf('/');
    if (slash != -1) hostPort = hostPort.substring(0, slash);
    final hash = hostPort.indexOf('#');
    if (hash != -1) hostPort = hostPort.substring(0, hash);
    // Drop the original :port — TURNS lives on its own well-known port.
    final colon = hostPort.lastIndexOf(':');
    final host = colon != -1 ? hostPort.substring(0, colon) : hostPort;
    if (host.isEmpty) return null;

    const ss = FlutterSecureStorage();
    final user = await ss.read(key: 'pulse_turn_user') ?? '';
    final pass = await ss.read(key: 'pulse_turn_pass') ?? '';
    return {
      'urls': 'turns:$host:8080?transport=tcp',
      if (user.isNotEmpty) 'username': user,
      if (pass.isNotEmpty) 'credential': pass,
    };
  }

  static List<Map<String, dynamic>> _safeIceServers(List<Map<String, dynamic>> servers) {
    if (!(Platform.isLinux || Platform.isWindows) || servers.length <= 10) {
      return servers;
    }
    // 3 STUN + 7 TURN keeps us well under the segfault threshold while
    // still giving ICE several candidates to try.
    final stun = <Map<String, dynamic>>[];
    final turn = <Map<String, dynamic>>[];
    for (final s in servers) {
      final urls = s['urls'];
      final str = urls is String ? urls : (urls is List && urls.isNotEmpty ? urls.first.toString() : '');
      if (str.startsWith('stun:')) {
        if (stun.length < 3) stun.add(s);
      } else if (str.startsWith('turn:') || str.startsWith('turns:')) {
        if (turn.length < 7) turn.add(s);
      }
      if (stun.length >= 3 && turn.length >= 7) break;
    }
    final result = [...stun, ...turn];
    debugPrint('[SFU] desktop ICE-server safe-set: ${servers.length} → ${result.length}');
    return result;
  }

  void preferQuality(String trackId, String layer) {
    if (_roomId == null) return;
    _send({'type': 'quality_prefer', 'room_id': _roomId, 'track_id': trackId, 'layer': layer});
  }

  Future<void> hangUp() async {
    if (_disposed) return;
    _disposed = true;
    _roomCreateTimer?.cancel();
    _roomCreateTimer = null;
    _pendingSubscriptions.clear();
    _pcReadyForSubscribes = false;
    if (_roomId != null) _send({'type': 'room_leave', 'room_id': _roomId});
    _signalSub?.cancel();
    localStream?.getTracks().forEach((t) => t.stop());
    await localStream?.dispose();
    localStream = null;
    // CRITICAL: dispose() not close() — flutter_webrtc on Linux/GStreamer
    // (and Windows) leaks the underlying TURN TCP socket on plain close,
    // so the next call's PC can't open a fresh allocation: pion's
    // TURN-over-WS bridge keeps fanning packets to the stale socket and
    // outbound RTP for call #2 never reaches the new room's PC. Same
    // workaround is documented for the 1-on-1 CallScreen.
    await _pc?.dispose();
    _pc = null;
  }

  /// Tear down the current peer connection and re-join the same room.
  /// Used to recover from an ICE failure caused by a transient WS drop
  /// (nginx 24h timeout isn't the issue; `close 1006` from Waydroid-ish
  /// networks is). Requires that the caller has already ensured the
  /// underlying Pulse WS is authenticated again — otherwise
  /// `_sendRoomJoinWithRetry` will fail immediately. Returns false if
  /// the service has been permanently disposed (hangUp already called)
  /// or we never had a room to rejoin.
  Future<bool> rejoin() async {
    if (_disposed) return false;
    final roomId = _roomId;
    final token = _roomToken;
    if (roomId == null || token == null) return false;
    debugPrint('[SFU] rejoin(): tearing down old PC and re-sending room_join');
    _pendingSubscriptions.clear();
    _pcReadyForSubscribes = false;
    _roomCreateTimer?.cancel();
    _roomCreateTimer = null;
    _roomCreateAttempts = 0;
    // Stop old media tracks and PC. We don't dispose localStream since
    // the UI layer owns it and will pass a fresh copy back through
    // setupPeerConnection() after onRoomReady fires.
    final oldPc = _pc;
    _pc = null;
    try { await oldPc?.close(); } catch (_) {}
    unawaited(_sendRoomJoinWithRetry());
    return true;
  }

  // ── Receive path ──────────────────────────────────────────────────────

  void _listenForSfuSignals() {
    _signalSub?.cancel();
    _signalSub = ChatController().signalStream.listen((sig) {
      if (sig['type'] != 'sfu') return;
      final data = sig['payload'] as Map<String, dynamic>? ?? {};
      _handleSfuMessage(data);
    });
  }

  void _handleSfuMessage(Map<String, dynamic> data) {
    if (_disposed) return;
    final type = data['type'] as String? ?? '';

    // Multiple SfuSignalingService instances over a session share the
    // same `signalStream` from ChatController. Without a room_id guard,
    // a stale media_answer / media_renegotiate from the previous call
    // would land here and apply to the FRESH PC of the new call,
    // poisoning its SDP state and silently killing the audio publish.
    // `room_created` arrives BEFORE we know our own _roomId so it must
    // bypass the check; same for non-room messages.
    if (type != 'room_created') {
      final msgRoom = data['room_id'] as String?;
      if (msgRoom != null && _roomId != null && msgRoom != _roomId) {
        debugPrint('[SFU] dropping stale $type for room $msgRoom (current=$_roomId)');
        return;
      }
    }

    switch (type) {
      case 'room_created':
        _roomCreateTimer?.cancel();
        _roomCreateTimer = null;
        _roomId = data['room_id'] as String?;
        _roomToken = data['token'] as String?;
        debugPrint('[SFU] Room created: $_roomId');
        // Auto-join the room we just created
        if (_roomId != null && _roomToken != null) {
          _roomCreateAttempts = 0;
          unawaited(_sendRoomJoinWithRetry());
        }

      case 'room_info':
        _roomCreateTimer?.cancel();
        _roomCreateTimer = null;
        final participants = data['participants'] as List<dynamic>? ?? [];
        for (final p in participants) {
          if (p is! Map<String, dynamic>) continue;
          final pubkey = p['pubkey'] as String? ?? '';
          if (pubkey == myId) continue; // skip self
          for (final t in (p['tracks'] as List<dynamic>? ?? [])) {
            if (t is! Map<String, dynamic>) continue;
            onTrackAvailable?.call(pubkey, t['id'] as String? ?? '', t['kind'] as String? ?? '');
          }
        }
        onRoomReady?.call();

      case 'media_answer':
        final sdp = data['sdp'] as String?;
        if (sdp != null && _pc != null) {
          final wasReady = _pcReadyForSubscribes;
          _pc!.setRemoteDescription(RTCSessionDescription(sdp, 'answer'));
          _pcReadyForSubscribes = true;
          _flushPendingSubscriptions();
          // Subsequent media_answer (after replaceVideoSource): the
          // server drops our previously-subscribed RECV tracks because
          // our fresh local offer doesn't list them. Re-send the
          // track_subscribe for every track we already know about so
          // the screen-sharer keeps hearing the other participants.
          if (wasReady && _knownSubscriptions.isNotEmpty) {
            for (final s in _knownSubscriptions.values) {
              _send({
                'type': 'track_subscribe',
                'room_id': _roomId,
                'track_id': s.trackId,
                'layer': s.layer,
              });
            }
            debugPrint('[SFU] Re-subscribed to ${_knownSubscriptions.length} '
                'tracks after renegotiation');
          }
        }

      case 'media_renegotiate':
        // Server-driven renegotiation: a track was added to our PC on the
        // server side (e.g. after track_subscribe). Apply the new offer,
        // generate an answer, and ship it back. Without this round-trip
        // the new transceiver never lights up on our side and the audio
        // stays silent.
        final sdp = data['sdp'] as String?;
        if (sdp == null || _pc == null) break;
        () async {
          try {
            await _pc!.setRemoteDescription(RTCSessionDescription(sdp, 'offer'));
            final answer = await _pc!.createAnswer();
            await _pc!.setLocalDescription(answer);
            _send({
              'type': 'media_renegotiate_answer',
              'room_id': _roomId,
              'sdp': answer.sdp,
            });
          } catch (e) {
            debugPrint('[SFU] renegotiate failed: $e');
          }
        }();

      case 'media_candidate':
        if (_pc != null) {
          _pc!.addCandidate(RTCIceCandidate(
            data['candidate'] as String?,
            data['sdp_mid'] as String?,
            data['sdp_mline_index'] as int?,
          ));
        }

      case 'track_available':
        final pubkey = data['pubkey'] as String? ?? '';
        if (pubkey != myId) {
          onTrackAvailable?.call(pubkey, data['track_id'] as String? ?? '', data['kind'] as String? ?? '');
        }

      case 'track_removed':
      case 'room_left':
        final pubkey = data['pubkey'] as String? ?? '';
        if (pubkey.isNotEmpty && pubkey != myId) onParticipantLeft?.call(pubkey);

      case 'speaker_update':
        final speakers = (data['speakers'] as List<dynamic>?)?.cast<String>() ?? [];
        onSpeakerUpdate?.call(speakers, data['dominant'] as String?);

      case 'last_n_update':
        final activeSet = (data['active_set'] as List<dynamic>?)?.cast<String>() ?? [];
        onLastNUpdate?.call(activeSet, data['dominant'] as String?);

      case 'error':
        // Server rejected something we sent. The cases that strand the
        // user UI are room_join failures (room garbage-collected after
        // 5min idle, or the call host explicitly ended it) — clear the
        // local "ongoing call" entry so the chat banner disappears and
        // the next call button creates a fresh room. Other errors are
        // just logged.
        final code = data['code'] as String? ?? '';
        final msg = data['message'] as String? ?? '';
        debugPrint('[SFU] server error: $code — $msg');
        if (code == 'not_found' || code == 'join_failed' ||
            msg.contains('room not found') || msg.contains('join_failed')) {
          _roomCreateTimer?.cancel();
          _roomCreateTimer = null;
          final dead = _roomId;
          if (dead != null && dead.isNotEmpty) {
            // Remember this roomId is gone so future sfu_invite replays
            // (other members still rebroadcasting, their local timer
            // hasn't caught up with server-side GC) don't re-pop the join
            // dialog and re-trigger the same failure.
            ChatController().markRoomDead(dead);
          }
          ChatController().clearActiveGroupCall(group.id);
          onRoomCreateFailed?.call();
        }
    }
  }

  // ── Send path ─────────────────────────────────────────────────────────

  void _send(Map<String, dynamic> msg) {
    final url = group.groupServerUrl;
    final json = jsonEncode(msg);
    final type = msg['type'];
    if (url.isNotEmpty) {
      final sent = ChatController().sendRawPulseSignalToServer(url, json);
      debugPrint('[SFU._send] type=$type url=$url via=server-pool sent=$sent');
      if (sent) return;
    }
    // Fallback: legacy single-server path. Used when the group has no
    // explicit server URL set (legacy groups created before
    // groupServerUrl existed) OR when the per-server sender hasn't been
    // initialized yet (caller forgot to await ensureGroupPulseConnection).
    debugPrint('[SFU._send] type=$type url="$url" via=legacy-cached-sender');
    ChatController().sendRawPulseSignal(json);
  }

  // ── DTX helper ────────────────────────────────────────────────────────

  static RTCSessionDescription _applyDtx(RTCSessionDescription desc) {
    var sdp = desc.sdp;
    if (sdp == null) return desc;
    final ptMatch = RegExp(r'a=rtpmap:(\d+) opus/\d+/2').firstMatch(sdp);
    if (ptMatch == null) return desc;
    final pt = ptMatch.group(1)!;
    final re = RegExp('a=fmtp:$pt ([^\r\n]*)');
    final m = re.firstMatch(sdp);
    if (m != null) {
      if (!m.group(1)!.contains('usedtx=')) {
        sdp = sdp.replaceFirst(re, 'a=fmtp:$pt ${m.group(1)!};usedtx=1');
      }
    } else {
      sdp = sdp.replaceFirst(
        'a=rtpmap:$pt opus/48000/2',
        'a=rtpmap:$pt opus/48000/2\r\na=fmtp:$pt usedtx=1',
      );
    }
    return RTCSessionDescription(sdp, desc.type);
  }
}
