import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../constants.dart';
import '../adapters/inbox_manager.dart';
import '../adapters/firebase_adapter.dart';
import 'call_transport.dart';
import '../adapters/nostr_adapter.dart';
import '../controllers/chat_controller.dart';
import '../models/contact.dart';
import 'signal_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// WebRTC mesh signaling for group calls (≤4 participants).
/// Each pair of participants maintains its own RTCPeerConnection.
/// Signal messages carry 'from' and 'to' fields for routing.
class GroupSignalingService {
  final Contact group;
  final String myId;
  List<Contact> members; // mutable — updated on roster changes

  static const _secureStorage = FlutterSecureStorage();
  static const _maxOfferRetries = 3;
  static const _offerRetryDelay = Duration(seconds: 30);

  // One peer connection per remote member
  final Map<String, RTCPeerConnection> _peers = {};
  final Map<String, MediaStream> _remoteStreams = {};

  // Offer retransmission state
  final Set<String> _answeredPeers = {};
  final Map<String, Timer> _offerRetryTimers = {};
  final Map<String, int> _offerRetryCount = {};

  MediaStream? localStream;

  Function(String memberId, MediaStream stream)? onRemoteStream;
  Function(String memberId, RTCIceConnectionState state)? onPeerState;

  StreamSubscription? _signalSub;

  late Map<String, dynamic> _peerConfig;

  GroupSignalingService({
    required this.group,
    required this.myId,
    required List<Contact> members,
  }) : members = List<Contact>.from(members);

  /// SHA-256(groupId) hex — used as routing token so relay can't see group UUID.
  static String _routingToken(String groupId) =>
      sha256.convert(utf8.encode(groupId)).toString();

  Future<void> init({CallTransportProfile profile = CallTransportProfile.auto}) async {
    _peerConfig = await profile.peerConfig();
    for (final member in members) {
      await _createPeer(member);
    }
    _listenForSignals();
  }

  Future<RTCPeerConnection> _createPeer(Contact member) async {
    final pc = await createPeerConnection(_peerConfig);

    pc.onIceCandidate = (candidate) {
      if (candidate.candidate != null) {
        _sendSignal(member, 'webrtc_candidate', candidate.toMap());
      }
    };

    pc.onIceConnectionState = (state) {
      onPeerState?.call(member.id, state);
    };

    pc.onAddStream = (stream) {
      _remoteStreams[member.id] = stream;
      onRemoteStream?.call(member.id, stream);
    };

    _peers[member.id] = pc;
    return pc;
  }

  /// Add local tracks to all peer connections
  void addLocalStream(MediaStream stream) {
    localStream = stream;
    for (final entry in _peers.entries) {
      stream.getTracks().forEach((t) => _peers[entry.key]?.addTrack(t, stream));
    }
  }

  // ── Offer retransmission ────────────────────────────────────────────────

  /// Inject `usedtx=1` into Opus fmtp so silence uses comfort noise (~400bps).
  static RTCSessionDescription _applyDtxToSdp(RTCSessionDescription desc) {
    var sdp = desc.sdp;
    if (sdp == null) return desc;
    final ptMatch = RegExp(r'a=rtpmap:(\d+) opus/\d+/2').firstMatch(sdp);
    if (ptMatch == null) return desc;
    final pt = ptMatch.group(1)!;
    final fmtpRe = RegExp('a=fmtp:$pt ([^\r\n]*)');
    final m = fmtpRe.firstMatch(sdp);
    if (m != null) {
      final params = m.group(1)!;
      if (!params.contains('usedtx=')) {
        sdp = sdp.replaceFirst(fmtpRe, 'a=fmtp:$pt $params;usedtx=1');
      }
    } else {
      sdp = sdp.replaceFirst(
        'a=rtpmap:$pt opus/48000/2',
        'a=rtpmap:$pt opus/48000/2\r\na=fmtp:$pt usedtx=1',
      );
    }
    return RTCSessionDescription(sdp, desc.type);
  }

  /// Send an offer to [member] and schedule retransmission if no answer arrives.
  Future<void> _sendOfferTo(Contact member) async {
    final pc = _peers[member.id];
    if (pc == null) return;
    var offer = await pc.createOffer();
    offer = _applyDtxToSdp(offer);
    await pc.setLocalDescription(offer);
    await _sendSignal(member, 'webrtc_offer', offer.toMap());
    _scheduleOfferRetry(member);
  }

  void _scheduleOfferRetry(Contact member) {
    _offerRetryTimers[member.id]?.cancel();
    final retries = _offerRetryCount[member.id] ?? 0;
    if (retries >= _maxOfferRetries) return;

    _offerRetryTimers[member.id] = Timer(_offerRetryDelay, () async {
      if (_answeredPeers.contains(member.id)) return;
      _offerRetryCount[member.id] = retries + 1;
      debugPrint('[GroupSignaling] Retrying offer to ${member.id} '
          '(attempt ${retries + 1}/$_maxOfferRetries)');
      await _sendOfferTo(member);
    });
  }

  /// Caller initiates: send offer to every member
  Future<void> createOffers() async {
    for (final member in members) {
      if (_peers.containsKey(member.id)) {
        await _sendOfferTo(member);
      }
    }
  }

  /// Send an offer to a single member (for late joiners or roster updates).
  Future<void> createOfferTo(Contact member) async {
    await _sendOfferTo(member);
  }

  // ── Dynamic roster management ───────────────────────────────────────────

  /// Add a peer connection for a newly joined member.
  Future<void> addPeer(Contact member) async {
    if (_peers.containsKey(member.id)) return;
    members.add(member);
    final pc = await _createPeer(member);
    if (localStream != null) {
      localStream!.getTracks().forEach((t) => pc.addTrack(t, localStream!));
    }
    debugPrint('[GroupSignaling] Added peer: ${member.name}');
  }

  /// Remove the peer connection for a member who left the group.
  Future<void> removePeer(String memberId) async {
    _offerRetryTimers[memberId]?.cancel();
    _offerRetryTimers.remove(memberId);
    _offerRetryCount.remove(memberId);
    _answeredPeers.remove(memberId);
    await _peers[memberId]?.close();
    _peers.remove(memberId);
    _remoteStreams[memberId]?.getTracks().forEach((t) => t.stop());
    await _remoteStreams[memberId]?.dispose();
    _remoteStreams.remove(memberId);
    members.removeWhere((m) => m.id == memberId);
    debugPrint('[GroupSignaling] Removed peer: $memberId');
  }

  // ── Signal listener ─────────────────────────────────────────────────────

  void _listenForSignals() {
    _signalSub?.cancel();
    _signalSub = ChatController().signalStream.listen((sig) async {
      try {
        final type = sig['type'] as String?;
        if (type == null) return;
        if (type != 'webrtc_offer' && type != 'webrtc_answer' && type != 'webrtc_candidate') return;

        // Group signals carry SHA-256(groupId) as routing token (never raw UUID)
        final raw = sig['payload'];
        if (raw is! Map<String, dynamic>) return;

        // 1. Fast-path group check via hashed token — no decryption needed
        final token = raw['_g'] as String?;
        if (token != _routingToken(group.id)) return;

        // 2. Identify sender — needed to pick the correct Signal session
        final fromId = sig['senderId'] as String? ?? '';
        final Contact? member = members.cast<Contact?>().firstWhere(
          (m) => m?.databaseId == fromId || m?.databaseId.split('@').first == fromId,
          orElse: () => null,
        );
        if (member == null) return;

        // 3. Decrypt with the member's databaseId (Signal session key)
        Map<String, dynamic> payload;
        try {
          final encrypted = raw['e2ee'] as String?;
          if (encrypted != null) {
            final plain = await SignalService().decryptMessage(member.databaseId, encrypted);
            payload = jsonDecode(plain) as Map<String, dynamic>;
          } else {
            payload = raw;
          }
        } catch (_) {
          return;
        }

        final pc = _peers[member.id];
        if (pc == null) return;

        final data = payload['data'] as Map<String, dynamic>? ?? {};

        if (type == 'webrtc_offer') {
          final sdp = data['sdp'] as String? ?? '';
          if (!sdp.contains('a=fingerprint:')) {
            debugPrint('[GroupSignaling] Rejected offer without a=fingerprint: (DTLS bypass)');
            return;
          }
          await pc.setRemoteDescription(RTCSessionDescription(sdp, data['type'] as String? ?? 'offer'));
          var answer = await pc.createAnswer();
          answer = _applyDtxToSdp(answer);
          await pc.setLocalDescription(answer);
          await _sendSignal(member, 'webrtc_answer', answer.toMap());
        } else if (type == 'webrtc_answer') {
          final sdp = data['sdp'] as String? ?? '';
          if (!sdp.contains('a=fingerprint:')) {
            debugPrint('[GroupSignaling] Rejected answer without a=fingerprint: (DTLS bypass)');
            return;
          }
          await pc.setRemoteDescription(RTCSessionDescription(sdp, data['type'] as String? ?? 'answer'));
          // Mark answered and cancel retry timer
          _answeredPeers.add(member.id);
          _offerRetryTimers[member.id]?.cancel();
          _offerRetryTimers.remove(member.id);
        } else if (type == 'webrtc_candidate') {
          await pc.addCandidate(RTCIceCandidate(
              data['candidate'] as String?, data['sdpMid'] as String?, data['sdpMLineIndex'] as int?));
        }
      } catch (e) {
        debugPrint('[GroupSignaling] Signal handler error: $e');
      }
    });
  }

  Future<void> _sendSignal(Contact target, String type, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final identityJson = prefs.getString('user_identity');
    if (identityJson == null) return;

    final dynamic identityData;
    try {
      identityData = jsonDecode(identityJson);
    } catch (e) {
      debugPrint('[GroupSignaling] Failed to parse identity: $e');
      return;
    }
    final adapterConfig = (identityData is Map<String, dynamic>
        ? identityData['adapterConfig'] as Map<String, dynamic>?
        : null) ?? {};
    final ourApiKey = adapterConfig['token'] as String? ?? '';

    // Wrap payload — use SHA-256(groupId) as routing token, never raw UUID
    final token = _routingToken(group.id);
    Map<String, dynamic> innerPayload = {'groupId': group.id, 'data': data};

    // Try to encrypt; outer wrapper uses hashed token so relay can't see group UUID.
    // groupId is included in clear so receivers can show incoming-call UI
    // before decryption (the relay already knows the sender/receiver pair anyway).
    Map<String, dynamic> payload;
    try {
      final plain = jsonEncode(innerPayload);
      final envelope = await SignalService().encryptMessage(target.databaseId, plain);
      payload = {
        'e2ee': envelope, '_g': token,
        'groupId': group.id,
      };
    } catch (e) {
      // F12: Abort instead of falling back to cleartext SDP.
      // Cleartext SDP leaks ICE candidates (real IP) to the relay operator,
      // defeating Tor/Psiphon anonymization for call participants.
      debugPrint('[GroupSignaling] Encryption failed, aborting signal: $e');
      return;
    }

    if (target.provider == 'Firebase') {
      await InboxManager().addSenderPlugin('Firebase', FirebaseInboxSender(), ourApiKey);
    } else if (target.provider == 'Nostr') {
      final privkey = await _secureStorage.read(key: 'nostr_privkey') ?? '';
      final relay = prefs.getString('nostr_relay') ?? kDefaultNostrRelay;
      await InboxManager().addSenderPlugin('Nostr', NostrMessageSender(),
          jsonEncode({'privkey': privkey, 'relay': relay}));
    }

    // HMAC-sign offer/answer on non-Nostr transports to prevent relay forgery.
    if ((type.endsWith('_offer') || type.endsWith('_answer')) &&
        target.provider != 'Nostr') {
      try {
        final privkey = await _secureStorage.read(key: 'nostr_privkey') ?? '';
        if (privkey.isNotEmpty) {
          final recipientPub = _extractPubkeyFor(target);
          if (recipientPub != null) {
            final senderPub = deriveNostrPubkeyHex(privkey);
            final canonical = jsonEncode({'t': type, 'p': payload});
            final hmac = signSignalPayload(privkey, recipientPub, canonical);
            payload = {...payload, '_sig': hmac, '_spk': senderPub};
          }
        }
      } catch (e) {
        debugPrint('[GroupSignaling] HMAC sign failed: $e');
      }
    }

    await InboxManager().sendSystemMessage(
      target.provider, target.databaseId, target.databaseId, myId, type, payload);
  }

  /// Extract Nostr pubkey from a contact's addresses for HMAC signing.
  static String? _extractPubkeyFor(Contact contact) {
    for (final addr in [contact.databaseId, ...contact.alternateAddresses]) {
      final atWss = addr.indexOf('@wss://');
      final atWs  = addr.indexOf('@ws://');
      final atIdx = atWss != -1 ? atWss : (atWs != -1 ? atWs : -1);
      if (atIdx != -1) {
        final pub = addr.substring(0, atIdx);
        if (RegExp(r'^[0-9a-f]{64}$').hasMatch(pub)) return pub;
      }
      if (RegExp(r'^[0-9a-f]{64}$').hasMatch(addr)) return addr;
    }
    return null;
  }

  /// Replace the video track in all peer connections (for screen share toggle).
  Future<void> replaceVideoTrack(MediaStreamTrack newTrack) async {
    for (final pc in _peers.values) {
      try {
        final senders = await pc.getSenders();
        final videoSender = senders.cast<RTCRtpSender?>()
            .firstWhere((s) => s?.track?.kind == 'video', orElse: () => null);
        await videoSender?.replaceTrack(newTrack);
      } catch (e) {
        debugPrint('[GroupSignaling] replaceVideoTrack error: $e');
      }
    }
  }

  /// Returns audio level (0.0–1.0) per peer memberId from WebRTC stats.
  Future<Map<String, double>> getAudioLevels() async {
    final levels = <String, double>{};
    for (final entry in _peers.entries) {
      try {
        final stats = await entry.value.getStats();
        for (final report in stats) {
          if (report.type == 'inbound-rtp') {
            final level = (report.values['audioLevel'] as num?)?.toDouble();
            if (level != null) levels[entry.key] = level;
          }
        }
      } catch (_) {}
    }
    return levels;
  }

  Future<void> hangUp() async {
    _signalSub?.cancel();
    _signalSub = null;
    for (final t in _offerRetryTimers.values) {
      t.cancel();
    }
    _offerRetryTimers.clear();
    _answeredPeers.clear();
    _offerRetryCount.clear();
    localStream?.getTracks().forEach((t) => t.stop());
    await localStream?.dispose();
    localStream = null;
    for (final entry in _remoteStreams.entries) {
      entry.value.getTracks().forEach((t) => t.stop());
      await entry.value.dispose();
    }
    for (final pc in _peers.values) {
      await pc.close();
    }
    _peers.clear();
    _remoteStreams.clear();
  }

  Map<String, MediaStream> get remoteStreams => Map.unmodifiable(_remoteStreams);
}
