import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../adapters/inbox_manager.dart';
import '../adapters/firebase_adapter.dart';
import 'call_transport.dart';
import '../adapters/nostr_adapter.dart';
import '../controllers/chat_controller.dart';
import '../models/contact.dart';
import 'signal_service.dart';
import 'yggdrasil_service.dart';

class SignalingService {
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;

  // ── Secondary audio path (Tor relay backup) ────────────────────────────────
  RTCPeerConnection? _secondaryPc;
  bool _secondaryCreating = false; // guard against concurrent PC creation races
  MediaStream? secondaryRemoteStream;

  /// Fires when secondary remote stream arrives (secondary path ready).
  Function(MediaStream stream)? onSecondaryRemoteStream;

  /// Fires on secondary ICE state changes.
  Function(RTCIceConnectionState state)? onSecondaryConnectionState;

  final Contact contact;
  final String myId;
  final bool isCaller;

  // True when current primary transport profile forces relay-only.
  // Used to select the appropriate audio bitrate in SDP constraints.
  bool _primaryRestricted = false;
  // True after the first offer sets our profile — prevents peer from
  // forcing profile changes via re-offers/ICE restarts (MED-3).
  bool _profileLocked = false;

  // FINDING-7: ICE candidate flood protection — reset on each new offer/answer.
  int _candidatesReceived = 0;
  int _secondaryCandidatesReceived = 0; // F1-3: secondary path counter
  static const _kMaxCandidates = 200;

  // Remote peer's Yggdrasil ed25519 public key (base64), received in offer/answer.
  // Needed to construct outbound proxy routes through the overlay.
  String? _remoteYggPubkey;

  StreamSubscription? _signalSubscription;
  Function(MediaStream stream)? onAddRemoteStream;
  Function(RTCIceConnectionState state)? onConnectionState;

  SignalingService({required this.contact, required this.myId, required this.isCaller});

  // ── Initialise ─────────────────────────────────────────────────────────────

  Future<void> init({CallTransportProfile profile = CallTransportProfile.auto}) async {
    _primaryRestricted = profile.isRestricted;
    final config = await profile.peerConfig();
    peerConnection = await createPeerConnection(config);
    _attachPeerCallbacks();
    await _listenForSignalingData();
  }

  // ── ICE restart with a different transport profile ────────────────────────
  //
  // Replaces the old reinitPeerConnection approach.  Instead of tearing down
  // the PC (which required a 600 ms timing guess for the callee to reinit),
  // we use the standard WebRTC ICE restart mechanism:
  //
  //   Caller:  setConfiguration → createOffer({iceRestart:true}) → send offer.
  //   Callee:  setConfiguration → wait for offer → setRemoteDescription →
  //            createAnswer (handled by _handleOffer as usual).
  //
  // Advantages over reinit:
  //   • No PC teardown → no DTLS re-handshake, media state preserved.
  //   • Callee processes the offer normally — no timing coordination needed.
  //   • Works even when ICE is in Failed state (spec allows renegotiation).
  //   • 'profile' field in offer lets callee mirror the config change.

  Future<void> iceRestart(CallTransportProfile profile) async {
    try {
      _primaryRestricted = profile.isRestricted;
      final config = await profile.peerConfig();
      await peerConnection?.setConfiguration(config);

      if (!isCaller) return; // callee waits for caller's ICE-restart offer
      if (peerConnection == null) return;

      final offer       = await peerConnection!.createOffer({'iceRestart': true});
      final constrained = _applyAudioConstraints(offer, restricted: _primaryRestricted);
      await peerConnection!.setLocalDescription(constrained);

      final offerMap = constrained.toMap();
      offerMap['profile'] = profile.id; // callee reads this to mirror config
      if (YggdrasilService.instance.isReady) {
        offerMap['ygg_addr']   = YggdrasilService.instance.address;
        offerMap['ygg_pubkey'] = YggdrasilService.instance.pubkey;
      }
      await _sendSignalingData('offer', offerMap);
    } catch (e) {
      debugPrint('[Signaling] iceRestart failed: $e');
      rethrow; // let _retryRestricted handle and reset _isRetrying
    }
  }

  /// Exposes the secondary peer connection for stats monitoring.
  RTCPeerConnection? get secondaryPc => _secondaryPc;

  // ── Secondary audio path ───────────────────────────────────────────────────
  //
  // Starts a second RTCPeerConnection routed exclusively through TorTurnProxy.
  // Audio-only; only local audio tracks are added so video bandwidth is not
  // wasted on the secondary path.
  //
  // For the caller side: creates and sends a webrtc2_offer.
  // For the callee side: creates the PC and waits for webrtc2_offer from peer
  //   (handled lazily in _handleSecondaryOffer).
  //
  // If TorTurnProxy is not running the secondary will fail silently — the
  // primary path remains unaffected.

  /// Restart the secondary (Tor) path — closes the old PC and starts fresh.
  /// Called by CallScreen's secondary watchdog when Tor circuit is degraded.
  Future<void> restartSecondaryAudio() async {
    if (contact.isGroup) return;
    // Clear _secondaryPc BEFORE the await so a concurrent _handleSecondaryOffer
    // that fires during the close() suspension cannot have its freshly-created
    // PC silently nullified by the assignment below.
    final old = _secondaryPc;
    _secondaryPc = null;
    await old?.close();
    await startSecondaryAudio();
  }

  Future<void> startSecondaryAudio() async {
    if (contact.isGroup || _secondaryPc != null || _secondaryCreating) return;
    _secondaryCreating = true;
    try {
      debugPrint('[Secondary] Starting secondary audio path (Tor relay)');

      final config = await CallTransportProfile.torRelay.peerConfig();
      _secondaryPc = await createPeerConnection(config);
      _attachSecondaryCallbacks();

      // Add local audio tracks only (secondary is audio-only backup)
      if (localStream != null) {
        for (final track in localStream!.getAudioTracks()) {
          await _secondaryPc!.addTrack(track, localStream!);
        }
      }

      if (isCaller) {
        final offer = await _secondaryPc!.createOffer();
        final constrained = _applyAudioConstraints(offer, restricted: true);
        await _secondaryPc!.setLocalDescription(constrained);
        await _sendSignalingData('offer', constrained.toMap(), prefix: 'webrtc2');
      }
    } finally {
      _secondaryCreating = false;
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  void _attachPeerCallbacks() {
    peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      if (candidate.candidate != null) {
        _sendSignalingData('candidate', candidate.toMap());
      }
    };

    peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
      debugPrint('ICE state: $state');
      onConnectionState?.call(state);
    };

    peerConnection!.onAddStream = (MediaStream stream) {
      remoteStream = stream;
      onAddRemoteStream?.call(stream);
    };
  }

  void _attachSecondaryCallbacks() {
    _secondaryPc!.onIceCandidate = (RTCIceCandidate candidate) {
      if (candidate.candidate != null) {
        _sendSignalingData('candidate', candidate.toMap(), prefix: 'webrtc2');
      }
    };
    _secondaryPc!.onIceConnectionState = (RTCIceConnectionState state) {
      debugPrint('[Secondary] ICE: $state');
      onSecondaryConnectionState?.call(state);
    };
    _secondaryPc!.onAddStream = (MediaStream stream) {
      secondaryRemoteStream = stream;
      onSecondaryRemoteStream?.call(stream);
    };
  }

  Future<void> createOffer() async {
    if (peerConnection == null) return;
    final offer = await peerConnection!.createOffer();
    final constrained = _applyAudioConstraints(offer, restricted: _primaryRestricted);
    await peerConnection!.setLocalDescription(constrained);
    final offerMap = constrained.toMap();
    // Include Yggdrasil address + pubkey so the peer can route back to us
    if (YggdrasilService.instance.isReady) {
      offerMap['ygg_addr']   = YggdrasilService.instance.address;
      offerMap['ygg_pubkey'] = YggdrasilService.instance.pubkey;
    }
    await _sendSignalingData('offer', offerMap);
  }

  Future<void> createAnswer() async {
    if (peerConnection == null) return;
    final answer = await peerConnection!.createAnswer();
    final constrained = _applyAudioConstraints(answer, restricted: _primaryRestricted);
    await peerConnection!.setLocalDescription(constrained);
    final answerMap = constrained.toMap();
    // Include Yggdrasil address + pubkey so the caller can route back to us
    if (YggdrasilService.instance.isReady) {
      answerMap['ygg_addr']   = YggdrasilService.instance.address;
      answerMap['ygg_pubkey'] = YggdrasilService.instance.pubkey;
    }
    await _sendSignalingData('answer', answerMap);
  }

  // ── Apply bitrate limits after ICE connects ────────────────────────────────
  //
  // Call this once ICE state = connected.
  // RTCRtpSender.setParameters is more reliable than SDP alone for enforcement.

  Future<void> applyBitrateLimit({bool restricted = false}) async {
    await _limitSenderBitrate(peerConnection, restricted: restricted);
  }

  Future<void> _listenForSignalingData() async {
    if (contact.isGroup) return;

    _signalSubscription = ChatController().signalStream.listen((sig) async {
      // F1-9: strip @relay suffix before comparing senderId (different transport formats)
      final rawSender = sig['senderId'] as String? ?? '';
      final senderBase = rawSender.contains('@') ? rawSender.split('@').first : rawSender;
      final expectedBase = contact.databaseId.contains('@')
          ? contact.databaseId.split('@').first
          : contact.databaseId;
      if (sig['roomId'] != contact.id || senderBase != expectedBase) return;
      try {
        final type = sig['type'] as String?;
        if (type == null || type == 'sys_keys' || type == 'sys_kick') return;

        final rawPayload = sig['payload'];
        final payload = await _decryptPayload(rawPayload);
        if (payload == null) return;

        // Primary WebRTC signals
        if (type == 'webrtc_offer' && !isCaller) {
          await _handleOffer(payload);
        } else if (type == 'webrtc_answer' && isCaller) {
          await _handleAnswer(payload);
        } else if (type == 'webrtc_candidate') {
          await _handleCandidate(payload);
        }
        // Secondary (Tor backup) WebRTC signals
        else if (type == 'webrtc2_offer' && !isCaller) {
          await _handleSecondaryOffer(payload);
        } else if (type == 'webrtc2_answer' && isCaller) {
          await _handleSecondaryAnswer(payload);
        } else if (type == 'webrtc2_candidate') {
          await _handleSecondaryCandidate(payload);
        }
      } catch (e) {
        debugPrint('Error processing signal: $e');
      }
    });
  }

  Future<Map<String, dynamic>?> _decryptPayload(dynamic raw) async {
    if (raw is Map<String, dynamic>) {
      final encrypted = raw['e2ee'] as String?;
      if (encrypted != null) {
        try {
          final plain = await SignalService().decryptMessage(contact.databaseId, encrypted);
          return jsonDecode(plain) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('Signal decrypt failed: $e');
          return null;
        }
      }
      // No e2ee field — reject. Sender always encrypts via Signal Protocol;
      // an unencrypted payload means a relay injected it without the session key.
      debugPrint('[Signaling] Rejected unauthenticated signal (no e2ee field)');
      return null;
    }
    return null;
  }

  Future<void> _handleOffer(Map<String, dynamic> data) async {
    try {
      final yggPub = data['ygg_pubkey'] as String?;
      // Validate base64 pubkey format (ed25519 = 44 chars base64 with optional padding)
      // Accept both standard (+/) and URL-safe base64 (-_) encodings since
      // the remote Go binary may use either base64.StdEncoding or URLEncoding.
      if (yggPub != null && RegExp(r'^[A-Za-z0-9+/\-_]{43}={0,1}$').hasMatch(yggPub)) {
        _remoteYggPubkey = yggPub;
      } else {
        _remoteYggPubkey = null;
      }
      // FINDING-9: Require a=fingerprint: in SDP — prevents DTLS-bypass attack
      final sdp = data['sdp'] as String? ?? '';
      if (!sdp.contains('a=fingerprint:')) {
        debugPrint('[Signaling] Rejected offer SDP without a=fingerprint: (DTLS bypass attempt)');
        return;
      }
      // FINDING-7: Reset candidate counter for new session
      _candidatesReceived = 0;
      // First-offer profile hint: mirror the caller's iceTransportPolicy so
      // both sides match on initial setup. Ignored on re-offers/ICE-restarts
      // to prevent a compromised peer from forcing relay-only mode mid-call.
      final profileId = data['profile'] as String?;
      if (profileId != null && peerConnection != null && !_profileLocked) {
        final profile = profileId == 'restricted'
            ? CallTransportProfile.restricted
            : CallTransportProfile.auto;
        _primaryRestricted = profile.isRestricted;
        await peerConnection!.setConfiguration(await profile.peerConfig());
        _profileLocked = true;
      }
      await peerConnection?.setRemoteDescription(RTCSessionDescription(sdp, data['type'] as String? ?? 'offer'));
      await createAnswer();
    } catch (e) {
      debugPrint('[Signaling] handleOffer error: $e');
    }
  }

  Future<void> _handleAnswer(Map<String, dynamic> data) async {
    try {
      final yggPub = data['ygg_pubkey'] as String?;
      // Accept both standard (+/) and URL-safe base64 (-_) encodings since
      // the remote Go binary may use either base64.StdEncoding or URLEncoding.
      if (yggPub != null && RegExp(r'^[A-Za-z0-9+/\-_]{43}={0,1}$').hasMatch(yggPub)) {
        _remoteYggPubkey = yggPub;
      } else if (yggPub != null) {
        _remoteYggPubkey = null; // reject malformed pubkey
      }
      // FINDING-9: Require a=fingerprint: in SDP — prevents DTLS-bypass attack
      final sdp = data['sdp'] as String? ?? '';
      if (!sdp.contains('a=fingerprint:')) {
        debugPrint('[Signaling] Rejected answer SDP without a=fingerprint: (DTLS bypass attempt)');
        return;
      }
      // FINDING-7: Reset candidate counter for new session
      _candidatesReceived = 0;
      await peerConnection?.setRemoteDescription(RTCSessionDescription(sdp, data['type'] as String? ?? 'answer'));
    } catch (e) {
      debugPrint('[Signaling] handleAnswer error: $e');
    }
  }

  Future<void> _handleCandidate(Map<String, dynamic> data) async {
    try {
      // FINDING-7: Reject excess candidates — prevents CPU/memory flood
      if (++_candidatesReceived > _kMaxCandidates) {
        debugPrint('[Signaling] ICE candidate limit reached, dropping');
        return;
      }
      final raw = RTCIceCandidate(
          data['candidate'] as String?, data['sdpMid'] as String?, data['sdpMLineIndex'] as int?);
      final candidate = await _interceptYggCandidate(raw);
      await peerConnection?.addCandidate(candidate);
    } catch (e) {
      debugPrint('[Signaling] handleCandidate error: $e');
    }
  }

  /// Intercepts ICE relay candidates with Yggdrasil 200::/7 addresses and
  /// rewrites them to a local UDP proxy port.
  ///
  /// When the remote peer's TURN server allocated a relay address on the
  /// Yggdrasil overlay (e.g. [200:aaa::1]:50000), our WebRTC cannot connect
  /// to that address directly.  We create a local UDP↔Yggdrasil-TCP bridge
  /// via the Go binary and inject the loopback address instead.
  Future<RTCIceCandidate> _interceptYggCandidate(RTCIceCandidate c) async {
    if (!YggdrasilService.instance.isReady) return c;
    final remotePubkey = _remoteYggPubkey;
    if (remotePubkey == null) return c; // no pubkey from remote → can't route
    final line = c.candidate ?? '';
    // Only intercept relay-type candidates — host/srflx candidates with a
    // Yggdrasil-looking IP should not be proxied (MED-1: non-relay bypass).
    if (!line.contains('typ relay')) return c;
    // Match Yggdrasil node addresses. Prefix 0x02 + 7-bit count = first hextet
    // 0x0200–0x027f, displayed as "200:"–"27f:". Pattern: 2[0-7][0-9a-fA-F]
    final match = RegExp(r'\b(2[0-7][0-9a-fA-F]:[0-9a-fA-F:]+)\s+(\d+)\b')
        .firstMatch(line);
    if (match == null) return c;

    final yggIp   = match.group(1)!;
    final yggPort = match.group(2)!;
    // Validate port is a real TCP/UDP port before creating proxy.
    final portNum = int.tryParse(yggPort) ?? 0;
    if (portNum < 1 || portNum > 65535) return c;
    final yggAddr  = '[$yggIp]:$yggPort';
    final localPort = await YggdrasilService.instance.proxyRemote(yggAddr, remotePubkey);
    if (localPort == null) return c; // proxy setup failed — pass through

    // Replace the Yggdrasil address with the loopback proxy
    final modified = line.replaceFirst(
        '$yggIp $yggPort', '127.0.0.1 $localPort');
    debugPrint('[Signaling] Yggdrasil candidate intercepted: '
        '$yggAddr → 127.0.0.1:$localPort');
    return RTCIceCandidate(modified, c.sdpMid, c.sdpMLineIndex);
  }

  // ── Secondary signal handlers ──────────────────────────────────────────────

  Future<void> _handleSecondaryOffer(Map<String, dynamic> data) async {
    try {
      // F1-1: Require a=fingerprint: in secondary SDP — same check as primary
      final sdp = data['sdp'] as String? ?? '';
      if (!sdp.contains('a=fingerprint:')) {
        debugPrint('[Signaling] Rejected secondary offer SDP without a=fingerprint:');
        return;
      }
      // F1-3: Reset secondary candidate counter for new session
      _secondaryCandidatesReceived = 0;
      // Lazily create secondary PC if startSecondaryAudio was not yet called
      if (_secondaryPc == null && !_secondaryCreating) {
        _secondaryCreating = true;
        try {
          final config = await CallTransportProfile.torRelay.peerConfig();
          _secondaryPc = await createPeerConnection(config);
          _attachSecondaryCallbacks();
          if (localStream != null) {
            for (final track in localStream!.getAudioTracks()) {
              await _secondaryPc!.addTrack(track, localStream!);
            }
          }
        } finally {
          _secondaryCreating = false;
        }
      }
      // F1-8: Guard against null PC (creation may have failed above)
      if (_secondaryPc == null) {
        debugPrint('[Signaling] Secondary PC creation failed, skipping offer');
        return;
      }
      await _secondaryPc!.setRemoteDescription(RTCSessionDescription(sdp, data['type'] as String? ?? 'offer'));
      final answer = await _secondaryPc!.createAnswer();
      final constrained = _applyAudioConstraints(answer, restricted: true);
      await _secondaryPc!.setLocalDescription(constrained);
      await _sendSignalingData('answer', constrained.toMap(), prefix: 'webrtc2');
    } catch (e) {
      debugPrint('[Signaling] handleSecondaryOffer error: $e');
    }
  }

  Future<void> _handleSecondaryAnswer(Map<String, dynamic> data) async {
    try {
      // F1-2: Require a=fingerprint: in secondary answer SDP
      final sdp = data['sdp'] as String? ?? '';
      if (!sdp.contains('a=fingerprint:')) {
        debugPrint('[Signaling] Rejected secondary answer SDP without a=fingerprint:');
        return;
      }
      await _secondaryPc?.setRemoteDescription(RTCSessionDescription(sdp, data['type'] as String? ?? 'answer'));
    } catch (e) {
      debugPrint('[Signaling] handleSecondaryAnswer error: $e');
    }
  }

  Future<void> _handleSecondaryCandidate(Map<String, dynamic> data) async {
    try {
      // F1-3: Reject excess secondary candidates — same protection as primary
      if (++_secondaryCandidatesReceived > _kMaxCandidates) {
        debugPrint('[Signaling] Secondary ICE candidate limit reached, dropping');
        return;
      }
      final raw = RTCIceCandidate(
          data['candidate'] as String?, data['sdpMid'] as String?, data['sdpMLineIndex'] as int?);
      final candidate = await _interceptYggCandidate(raw);
      await _secondaryPc?.addCandidate(candidate);
    } catch (e) {
      debugPrint('[Signaling] handleSecondaryCandidate error: $e');
    }
  }

  // ── Audio quality constraints ──────────────────────────────────────────────
  //
  // Two complementary mechanisms:
  //
  // 1. SDP modification (applied before setLocalDescription):
  //    • Adds  useinbandfec=1  — Opus inband FEC, recovers from packet loss
  //      without retransmission. Critical on Tor paths (2-5 % loss typical).
  //    • Sets  maxaveragebitrate — limits encoder output:
  //        restricted=false → 64 000 bps  (normal quality, ~WhatsApp default)
  //        restricted=true  → 48 000 bps  (good quality on Tor circuit)
  //    • Adds  b=AS:<kbps>   — signals bandwidth to the remote peer.
  //
  // 2. RTCRtpSender.setParameters (applied after ICE connects):
  //    • Enforces maxBitrate at the SRTP layer regardless of SDP renegotiation.
  //    • Called by CallScreen via applyBitrateLimit() once connected.

  /// Injects Opus bitrate + FEC constraints into [desc]'s SDP.
  RTCSessionDescription _applyAudioConstraints(
    RTCSessionDescription desc, {
    required bool restricted,
  }) {
    var sdp = desc.sdp ?? '';
    final maxBitrate  = restricted ? 48000 : 64000;
    final asKbps      = restricted ? 48 : 64;

    // Find the Opus dynamic payload type (almost always 111, but parse to be safe)
    final ptMatch = RegExp(r'a=rtpmap:(\d+) opus/\d+/2').firstMatch(sdp);
    if (ptMatch == null) return desc; // No audio section — return unchanged

    final pt = ptMatch.group(1)!;

    // Build the fmtp line we want
    final fmtpLine =
        'a=fmtp:$pt minptime=10;useinbandfec=1;maxaveragebitrate=$maxBitrate';
    final fmtpRe = RegExp('a=fmtp:$pt [^\r\n]*');

    if (fmtpRe.hasMatch(sdp)) {
      sdp = sdp.replaceFirst(fmtpRe, fmtpLine);
    } else {
      // No existing fmtp — insert right after the rtpmap line
      sdp = sdp.replaceFirst(
        'a=rtpmap:$pt opus/48000/2',
        'a=rtpmap:$pt opus/48000/2\r\n$fmtpLine',
      );
    }

    // Add b=AS:<kbps> to the audio m= section.
    // Must appear after the c= line and before the first a= attribute.
    sdp = sdp.replaceFirstMapped(
      RegExp(r'(m=audio [^\r\n]*\r?\n)((?:i=[^\r\n]*\r?\n)?(?:c=[^\r\n]*\r?\n)?)'),
      (m) => '${m.group(1)!}${m.group(2)!}b=AS:$asKbps\r\n',
    );

    debugPrint('[SDP] audio constraints applied: '
        '${restricted ? "restricted" : "normal"} '
        '($maxBitrate bps, FEC on)');
    return RTCSessionDescription(sdp, desc.type);
  }

  /// Enforces maxBitrate on all audio senders via RTCRtpSender.setParameters.
  /// Called after ICE connects for reliable enforcement.
  Future<void> _limitSenderBitrate(
    RTCPeerConnection? pc, {
    required bool restricted,
  }) async {
    if (pc == null) return;
    try {
      final senders = await pc.getSenders();
      for (final sender in senders) {
        final kind = sender.track?.kind;
        final int maxBitrate;
        if (kind == 'audio') {
          maxBitrate = restricted ? 48000 : 64000;
        } else if (kind == 'video') {
          maxBitrate = restricted ? 100000 : 500000;
        } else {
          continue;
        }
        final params = sender.parameters; // sync getter
        final encodings = params.encodings;
        if (encodings == null || encodings.isEmpty) continue;
        // Only update if limit differs to avoid unnecessary renegotiation
        if (encodings.first.maxBitrate == maxBitrate) continue;
        encodings.first.maxBitrate = maxBitrate;
        await sender.setParameters(params);
        debugPrint('[RTP] $kind maxBitrate set to $maxBitrate bps');
      }
    } catch (e) {
      debugPrint('[RTP] setParameters failed (non-fatal): $e');
    }
  }

  // ── Signaling transport ────────────────────────────────────────────────────

  Future<void> _sendSignalingData(
    String actionType,
    Map<String, dynamic> data, {
    String prefix = 'webrtc',
  }) async {
    final typeMap = {
      'offer':     '${prefix}_offer',
      'answer':    '${prefix}_answer',
      'candidate': '${prefix}_candidate',
    };
    final type = typeMap[actionType] ?? '${prefix}_candidate';

    final prefs = await SharedPreferences.getInstance();
    final identityJson = prefs.getString('user_identity');
    if (identityJson != null) {
      final dynamic identityData;
      try {
        identityData = jsonDecode(identityJson);
      } catch (e) {
        debugPrint('[Signaling] Failed to parse identity: $e');
        return;
      }
      final adapterConfig = (identityData is Map<String, dynamic>
          ? identityData['adapterConfig'] as Map<String, dynamic>?
          : null) ?? {};
      final ourApiKey = adapterConfig['token'] ?? '';

      if (contact.provider == 'Firebase') {
        await InboxManager().addSenderPlugin('Firebase', FirebaseInboxSender(), ourApiKey);
      } else if (contact.provider == 'Nostr') {
        const storage = FlutterSecureStorage();
        final privkey = await storage.read(key: 'nostr_privkey') ?? '';
        final relay = prefs.getString('nostr_relay') ?? kDefaultNostrRelay;
        await InboxManager().addSenderPlugin('Nostr', NostrMessageSender(),
            jsonEncode({'privkey': privkey, 'relay': relay}));
      }
    }

    // WebRTC signaling MUST be encrypted — sending SDP/candidates in cleartext
    // would expose TURN credentials and ICE candidates to the transport layer
    // (Nostr relay, Firebase, etc.).  If encryption fails, abort the send.
    final Map<String, dynamic> payload;
    try {
      final plaintext = jsonEncode(data);
      final envelope = await SignalService().encryptMessage(contact.databaseId, plaintext);
      payload = {'e2ee': envelope};
    } catch (e) {
      debugPrint('[Signaling] encryption failed — dropping signal (never send plaintext): $e');
      return;
    }

    await InboxManager().sendSystemMessage(
      contact.provider,
      contact.databaseId,
      contact.id,
      myId,
      type,
      payload,
    );
  }

  Future<void> hangUp() async {
    try {
      _signalSubscription?.cancel();
      localStream?.getTracks().forEach((t) => t.stop());
      await localStream?.dispose();
      remoteStream?.getTracks().forEach((t) => t.stop());
      await remoteStream?.dispose();
      await peerConnection?.close();
      await _secondaryPc?.close();
    } catch (e) {
      debugPrint('Error during hangUp: $e');
    }
  }
}
