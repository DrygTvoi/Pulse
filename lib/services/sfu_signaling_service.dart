import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../controllers/chat_controller.dart';
import '../models/contact.dart';

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

    _pc = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    });

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
