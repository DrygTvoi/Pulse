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

class SignalingService {
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;

  // ── Secondary audio path (Tor relay backup) ────────────────────────────────
  RTCPeerConnection? _secondaryPc;
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

  // ── Reinitialise with a different transport profile ────────────────────────
  //
  // Called on ICE failure to switch from AutoProfile → RestrictedProfile.
  // Closes the old peer connection, creates a new one, re-adds local tracks.
  // Does NOT recreate the signal subscription (ChatController stream persists).

  Future<void> reinitPeerConnection(
      CallTransportProfile profile) async {
    _primaryRestricted = profile.isRestricted;
    await peerConnection?.close();
    final config = await profile.peerConfig();
    peerConnection = await createPeerConnection(config);
    _attachPeerCallbacks();

    // Re-add local tracks so media flows on the new connection
    if (localStream != null) {
      for (final track in localStream!.getTracks()) {
        await peerConnection!.addTrack(track, localStream!);
      }
    }
  }

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

  Future<void> startSecondaryAudio() async {
    if (contact.isGroup || _secondaryPc != null) return;
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
    await _sendSignalingData('offer', constrained.toMap());
  }

  Future<void> createAnswer() async {
    if (peerConnection == null) return;
    final answer = await peerConnection!.createAnswer();
    final constrained = _applyAudioConstraints(answer, restricted: _primaryRestricted);
    await peerConnection!.setLocalDescription(constrained);
    await _sendSignalingData('answer', constrained.toMap());
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
      if (sig['roomId'] != contact.id || sig['senderId'] != contact.databaseId) return;
      try {
        final type = sig['type'] as String?;
        if (type == null || type == 'sys_keys' || type == 'sys_kick') return;

        final rawPayload = sig['payload'];
        final payload = await _decryptPayload(rawPayload);
        if (payload == null) return;

        // Primary WebRTC signals
        if (type == 'webrtc_offer' && !isCaller) {
          _handleOffer(payload);
        } else if (type == 'webrtc_answer' && isCaller) {
          _handleAnswer(payload);
        } else if (type == 'webrtc_candidate') {
          _handleCandidate(payload);
        }
        // Secondary (Tor backup) WebRTC signals
        else if (type == 'webrtc2_offer' && !isCaller) {
          _handleSecondaryOffer(payload);
        } else if (type == 'webrtc2_answer' && isCaller) {
          _handleSecondaryAnswer(payload);
        } else if (type == 'webrtc2_candidate') {
          _handleSecondaryCandidate(payload);
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
      return raw;
    }
    return null;
  }

  void _handleOffer(Map<String, dynamic> data) async {
    try {
      await peerConnection?.setRemoteDescription(RTCSessionDescription(data['sdp'], data['type']));
      await createAnswer();
    } catch (e) {
      debugPrint('[Signaling] handleOffer error: $e');
    }
  }

  void _handleAnswer(Map<String, dynamic> data) async {
    try {
      await peerConnection?.setRemoteDescription(RTCSessionDescription(data['sdp'], data['type']));
    } catch (e) {
      debugPrint('[Signaling] handleAnswer error: $e');
    }
  }

  void _handleCandidate(Map<String, dynamic> data) async {
    try {
      await peerConnection?.addCandidate(
        RTCIceCandidate(data['candidate'], data['sdpMid'], data['sdpMLineIndex']),
      );
    } catch (e) {
      debugPrint('[Signaling] handleCandidate error: $e');
    }
  }

  // ── Secondary signal handlers ──────────────────────────────────────────────

  void _handleSecondaryOffer(Map<String, dynamic> data) async {
    try {
      // Lazily create secondary PC if startSecondaryAudio was not yet called
      if (_secondaryPc == null) {
        final config = await CallTransportProfile.torRelay.peerConfig();
        _secondaryPc = await createPeerConnection(config);
        _attachSecondaryCallbacks();
        if (localStream != null) {
          for (final track in localStream!.getAudioTracks()) {
            await _secondaryPc!.addTrack(track, localStream!);
          }
        }
      }
      await _secondaryPc!.setRemoteDescription(
          RTCSessionDescription(data['sdp'], data['type']));
      final answer = await _secondaryPc!.createAnswer();
      final constrained = _applyAudioConstraints(answer, restricted: true);
      await _secondaryPc!.setLocalDescription(constrained);
      await _sendSignalingData('answer', constrained.toMap(), prefix: 'webrtc2');
    } catch (e) {
      debugPrint('[Signaling] handleSecondaryOffer error: $e');
    }
  }

  void _handleSecondaryAnswer(Map<String, dynamic> data) async {
    try {
      await _secondaryPc?.setRemoteDescription(
          RTCSessionDescription(data['sdp'], data['type']));
    } catch (e) {
      debugPrint('[Signaling] handleSecondaryAnswer error: $e');
    }
  }

  void _handleSecondaryCandidate(Map<String, dynamic> data) async {
    try {
      await _secondaryPc?.addCandidate(
        RTCIceCandidate(data['candidate'], data['sdpMid'], data['sdpMLineIndex']),
      );
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
    final ptMatch = RegExp(r'a=rtpmap:(\d+) opus/48000/2').firstMatch(sdp);
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

    Map<String, dynamic> payload;
    try {
      final plaintext = jsonEncode(data);
      final envelope = await SignalService().encryptMessage(contact.databaseId, plaintext);
      payload = {'e2ee': envelope};
    } catch (_) {
      payload = data;
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
