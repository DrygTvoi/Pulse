import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  final Contact contact;
  final String myId;
  final bool isCaller;

  StreamSubscription? _signalSubscription;
  Function(MediaStream stream)? onAddRemoteStream;
  Function(RTCIceConnectionState state)? onConnectionState;

  SignalingService({required this.contact, required this.myId, required this.isCaller});

  // ── Initialise ─────────────────────────────────────────────────────────────

  Future<void> init({CallTransportProfile profile = CallTransportProfile.auto}) async {
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

  Future<void> createOffer() async {
    if (peerConnection == null) return;
    final offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    await _sendSignalingData('offer', offer.toMap());
  }

  Future<void> createAnswer() async {
    if (peerConnection == null) return;
    final answer = await peerConnection!.createAnswer();
    await peerConnection!.setLocalDescription(answer);
    await _sendSignalingData('answer', answer.toMap());
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

        if (type == 'webrtc_offer' && !isCaller) {
          _handleOffer(payload);
        } else if (type == 'webrtc_answer' && isCaller) {
          _handleAnswer(payload);
        } else if (type == 'webrtc_candidate') {
          _handleCandidate(payload);
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
    await peerConnection?.setRemoteDescription(RTCSessionDescription(data['sdp'], data['type']));
    await createAnswer();
  }

  void _handleAnswer(Map<String, dynamic> data) async {
    await peerConnection?.setRemoteDescription(RTCSessionDescription(data['sdp'], data['type']));
  }

  void _handleCandidate(Map<String, dynamic> data) async {
    await peerConnection?.addCandidate(
      RTCIceCandidate(data['candidate'], data['sdpMid'], data['sdpMLineIndex']),
    );
  }

  Future<void> _sendSignalingData(String actionType, Map<String, dynamic> data) async {
    final typeMap = {'offer': 'webrtc_offer', 'answer': 'webrtc_answer', 'candidate': 'webrtc_candidate'};
    final type = typeMap[actionType] ?? 'webrtc_candidate';

    final prefs = await SharedPreferences.getInstance();
    final identityJson = prefs.getString('user_identity');
    if (identityJson != null) {
      final identityData = jsonDecode(identityJson);
      final adapterConfig = identityData['adapterConfig'] as Map<String, dynamic>;
      final ourApiKey = adapterConfig['token'] ?? '';

      if (contact.provider == 'Firebase') {
        InboxManager().addSenderPlugin('Firebase', FirebaseInboxSender(), ourApiKey);
      } else if (contact.provider == 'Nostr') {
        const storage = FlutterSecureStorage();
        final privkey = await storage.read(key: 'nostr_privkey') ?? '';
        final relay = prefs.getString('nostr_relay') ?? 'wss://relay.damus.io';
        InboxManager().addSenderPlugin('Nostr', NostrMessageSender(),
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
    } catch (e) {
      debugPrint('Error during hangUp: $e');
    }
  }
}
