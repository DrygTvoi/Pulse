import 'dart:async';
import 'dart:convert';
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
  final List<Contact> members; // resolved Contact objects (not the group itself)

  static const _secureStorage = FlutterSecureStorage();

  // One peer connection per remote member
  final Map<String, RTCPeerConnection> _peers = {};
  final Map<String, MediaStream> _remoteStreams = {};

  MediaStream? localStream;

  Function(String memberId, MediaStream stream)? onRemoteStream;
  Function(String memberId, RTCIceConnectionState state)? onPeerState;

  StreamSubscription? _signalSub;

  late Map<String, dynamic> _peerConfig;

  GroupSignalingService({
    required this.group,
    required this.myId,
    required this.members,
  });

  Future<void> init({CallTransportProfile profile = CallTransportProfile.auto}) async {
    _peerConfig = await profile.peerConfig();
    // Create one peer connection per member
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

  /// Caller initiates: send offer to every member
  Future<void> createOffers() async {
    for (final member in members) {
      final pc = _peers[member.id];
      if (pc == null) continue;
      final offer = await pc.createOffer();
      await pc.setLocalDescription(offer);
      await _sendSignal(member, 'webrtc_offer', offer.toMap());
    }
  }

  void _listenForSignals() {
    _signalSub = ChatController().signalStream.listen((sig) async {
      try {
        final type = sig['type'] as String?;
        if (type == null) return;
        if (type != 'webrtc_offer' && type != 'webrtc_answer' && type != 'webrtc_candidate') return;

        // Group signals carry groupId UNENCRYPTED for routing without decryption
        final raw = sig['payload'];
        if (raw is! Map<String, dynamic>) return;

        // 1. Fast-path group check — no decryption needed
        if (raw['groupId'] != group.id) return;

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
          await pc.setRemoteDescription(RTCSessionDescription(data['sdp'], data['type']));
          final answer = await pc.createAnswer();
          await pc.setLocalDescription(answer);
          await _sendSignal(member, 'webrtc_answer', answer.toMap());
        } else if (type == 'webrtc_answer') {
          await pc.setRemoteDescription(RTCSessionDescription(data['sdp'], data['type']));
        } else if (type == 'webrtc_candidate') {
          await pc.addCandidate(RTCIceCandidate(data['candidate'], data['sdpMid'], data['sdpMLineIndex']));
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

    // Wrap payload with groupId for routing
    Map<String, dynamic> innerPayload = {'groupId': group.id, 'data': data};

    // Try to encrypt
    Map<String, dynamic> payload;
    try {
      final plain = jsonEncode(innerPayload);
      final envelope = await SignalService().encryptMessage(target.databaseId, plain);
      // groupId left unencrypted so receiver can route without decrypting
      payload = {'e2ee': envelope, 'groupId': group.id};
    } catch (_) {
      payload = innerPayload;
    }

    if (target.provider == 'Firebase') {
      await InboxManager().addSenderPlugin('Firebase', FirebaseInboxSender(), ourApiKey);
    } else if (target.provider == 'Nostr') {
      final privkey = await _secureStorage.read(key: 'nostr_privkey') ?? '';
      final relay = prefs.getString('nostr_relay') ?? kDefaultNostrRelay;
      await InboxManager().addSenderPlugin('Nostr', NostrMessageSender(),
          jsonEncode({'privkey': privkey, 'relay': relay}));
    }

    await InboxManager().sendSystemMessage(
      target.provider, target.databaseId, target.databaseId, myId, type, payload);
  }

  Future<void> hangUp() async {
    _signalSub?.cancel();
    localStream?.getTracks().forEach((t) => t.stop());
    await localStream?.dispose();
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
