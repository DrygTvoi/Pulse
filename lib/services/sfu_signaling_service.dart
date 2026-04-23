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
  MediaStream? localStream;
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

  StreamSubscription? _signalSub;

  SfuSignalingService({required this.group, required this.myId});

  String? get roomId => _roomId;
  String? get roomToken => _roomToken;

  /// Create a new SFU room.
  Future<void> createRoom() async {
    _listenForSfuSignals();
    _send({'type': 'room_create', 'max': 20, 'name': group.name, 'e2ee': true});
  }

  /// Join an existing SFU room.
  Future<void> joinRoom(String roomId, String token) async {
    _roomId = roomId;
    _roomToken = token;
    _listenForSfuSignals();
    _send({'type': 'room_join', 'room_id': roomId, 'token': token});
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
    _pc = await createPeerConnection(pcConfig);

    _pc!.onIceCandidate = (c) {
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

    _pc!.onIceConnectionState = (state) => onIceState?.call(state);
    _pc!.onTrack = (event) => onRemoteTrack?.call(event);

    // Add audio tracks
    for (final track in stream.getAudioTracks()) {
      await _pc!.addTrack(track, stream);
    }

    // Add video tracks with simulcast (non-Linux)
    for (final track in stream.getVideoTracks()) {
      if (Platform.isLinux) {
        await _pc!.addTrack(track, stream);
      } else {
        await _pc!.addTransceiver(
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
      }
    }

    var offer = await _pc!.createOffer();
    offer = _applyDtx(offer);
    await _pc!.setLocalDescription(offer);

    _send({'type': 'media_offer', 'room_id': _roomId, 'sdp': offer.sdp});
  }

  void subscribeTrack(String trackId, {String layer = 'h'}) {
    if (_roomId == null) return;
    _send({'type': 'track_subscribe', 'room_id': _roomId, 'track_id': trackId, 'layer': layer});
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
    if (_roomId != null) _send({'type': 'room_leave', 'room_id': _roomId});
    _signalSub?.cancel();
    localStream?.getTracks().forEach((t) => t.stop());
    await localStream?.dispose();
    localStream = null;
    await _pc?.close();
    _pc = null;
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

    switch (type) {
      case 'room_created':
        _roomId = data['room_id'] as String?;
        _roomToken = data['token'] as String?;
        debugPrint('[SFU] Room created: $_roomId');
        // Auto-join the room we just created
        if (_roomId != null && _roomToken != null) {
          _send({'type': 'room_join', 'room_id': _roomId, 'token': _roomToken});
        }

      case 'room_info':
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
          _pc!.setRemoteDescription(RTCSessionDescription(sdp, 'answer'));
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
    }
  }

  // ── Send path ─────────────────────────────────────────────────────────

  void _send(Map<String, dynamic> msg) {
    final url = group.groupServerUrl;
    if (url.isNotEmpty) {
      // Per-group server: route through the dedicated pool entry instead
      // of the user's primary Pulse sender. Otherwise multi-server users
      // (own Pulse on server-A, joined SFU group on server-B) would send
      // SFU control messages to the WRONG server.
      if (ChatController().sendRawPulseSignalToServer(url, jsonEncode(msg))) {
        return;
      }
    }
    // Fallback: legacy single-server path. Used when the group has no
    // explicit server URL set (legacy groups created before
    // groupServerUrl existed) OR when the per-server sender hasn't been
    // initialized yet (caller forgot to await ensureGroupPulseConnection).
    ChatController().sendRawPulseSignal(jsonEncode(msg));
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
