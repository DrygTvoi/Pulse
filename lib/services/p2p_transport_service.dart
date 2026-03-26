import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'ice_server_config.dart';

// ── Connection state ──────────────────────────────────────────────────────────

enum _P2PState { idle, connecting, connected, failed }

class _P2PConn {
  _P2PState state = _P2PState.idle;
  RTCPeerConnection? pc;
  RTCDataChannel? dc;
  final bool isCaller;
  _P2PConn({required this.isCaller});
}

// ── P2PTransportService ───────────────────────────────────────────────────────

/// Manages persistent WebRTC DataChannel connections (one per contact).
///
/// Message flow (fully P2P — no server infrastructure after handshake):
///   1. [connect] → sends p2p_offer via [onSendSignal]
///   2. Peer calls [handleSignal] on p2p_offer → sends p2p_answer
///   3. ICE candidates exchanged via p2p_ice signals
///   4. DataChannel opens — [isConnected] returns true
///   5. [send] delivers Signal-encrypted payload directly; [messageStream] surfaces received ones
///
/// Signaling messages travel over the contact's normal transport (Firebase/Nostr/Oxen)
/// only during the ≤2-second handshake.  Subsequent messages bypass all servers.
class P2PTransportService {
  P2PTransportService._();
  static final instance = P2PTransportService._();

  /// Called whenever a signaling message must be sent to a contact.
  /// Set by ChatController after initialisation.
  void Function(
    String contactId,
    String type,
    Map<String, dynamic> payload,
  )? onSendSignal;

  final _msgCtrl =
      StreamController<({String contactId, String payload})>.broadcast();

  /// Stream of received (contactId, encryptedPayload) pairs.
  /// ChatController feeds these into [_handleIncomingMessages].
  Stream<({String contactId, String payload})> get messageStream =>
      _msgCtrl.stream;

  final Map<String, _P2PConn> _conns = {};

  // FINDING-7 fix: rate-limit p2p_offer per contact — rapid offers tear down
  // the existing DataChannel and prevent the connection from stabilising.
  final Map<String, DateTime> _lastOfferTime = {};
  static const _kMinOfferIntervalSec = 10;

  // ── Public API ──────────────────────────────────────────────────────────────

  /// True when the DataChannel to [contactId] is open and ready.
  bool isConnected(String contactId) {
    final c = _conns[contactId];
    return c != null &&
        c.state == _P2PState.connected &&
        c.dc?.state == RTCDataChannelState.RTCDataChannelOpen;
  }

  /// Deliver a Signal-encrypted [payload] over DataChannel.
  /// Returns false if no open channel — caller should fall back to normal adapter.
  bool send(String contactId, String payload) {
    if (!isConnected(contactId)) return false;
    try {
      _conns[contactId]!.dc!.send(RTCDataChannelMessage(payload));
      return true;
    } catch (e) {
      debugPrint('[P2P] Send error to $contactId: $e');
      _conns[contactId]?.state = _P2PState.failed;
      return false;
    }
  }

  /// Initiate a DataChannel connection (caller side).
  /// No-op if already connected or connecting.
  Future<void> connect(String contactId) async {
    if (isConnected(contactId)) return;
    if (_conns[contactId]?.state == _P2PState.connecting) return;

    await _closeConn(contactId);
    final conn = _P2PConn(isCaller: true);
    _conns[contactId] = conn;
    conn.state = _P2PState.connecting;

    try {
      final iceServers = await IceServerConfig.load();
      conn.pc = await createPeerConnection({'iceServers': iceServers});
      _setupPcCallbacks(contactId, conn);

      // Caller always creates the DataChannel
      conn.dc = await conn.pc!.createDataChannel(
        'pulse_msg',
        RTCDataChannelInit()..ordered = true,
      );
      _setupDcCallbacks(contactId, conn);

      final offer = await conn.pc!.createOffer();
      await conn.pc!.setLocalDescription(offer);
      onSendSignal?.call(contactId, 'p2p_offer', offer.toMap());
      debugPrint('[P2P] Offer sent to $contactId');
    } catch (e) {
      debugPrint('[P2P] Connect error for $contactId: $e');
      conn.state = _P2PState.failed;
    }
  }

  /// Process an incoming signaling message from a contact.
  Future<void> handleSignal(
    String contactId,
    String type,
    Map<String, dynamic> payload,
  ) async {
    switch (type) {
      case 'p2p_offer':
        await _handleOffer(contactId, payload);
      case 'p2p_answer':
        await _handleAnswer(contactId, payload);
      case 'p2p_ice':
        await _handleIce(contactId, payload);
    }
  }

  void dispose() {
    for (final id in List.of(_conns.keys)) {
      _closeConn(id);
    }
    if (!_msgCtrl.isClosed) _msgCtrl.close();
  }

  // ── Private ─────────────────────────────────────────────────────────────────

  Future<void> _handleOffer(
    String contactId,
    Map<String, dynamic> sdp,
  ) async {
    final now = DateTime.now();
    final last = _lastOfferTime[contactId];
    if (last != null &&
        now.difference(last).inSeconds < _kMinOfferIntervalSec) {
      debugPrint('[P2P] Offer rate-limited for $contactId');
      return;
    }
    _lastOfferTime[contactId] = now;
    await _closeConn(contactId);
    final conn = _P2PConn(isCaller: false);
    _conns[contactId] = conn;
    conn.state = _P2PState.connecting;

    try {
      final iceServers = await IceServerConfig.load();
      conn.pc = await createPeerConnection({'iceServers': iceServers});
      _setupPcCallbacks(contactId, conn);

      // Callee receives DataChannel created by caller
      conn.pc!.onDataChannel = (RTCDataChannel channel) {
        conn.dc = channel;
        _setupDcCallbacks(contactId, conn);
      };

      final offerSdp = sdp['sdp'] as String? ?? '';
      if (!offerSdp.contains('a=fingerprint:')) {
        debugPrint('[P2P] Rejected offer without a=fingerprint: (DTLS bypass attempt)');
        conn.state = _P2PState.failed;
        return;
      }
      await conn.pc!.setRemoteDescription(
        RTCSessionDescription(offerSdp, sdp['type'] as String? ?? 'offer'),
      );
      final answer = await conn.pc!.createAnswer();
      await conn.pc!.setLocalDescription(answer);
      onSendSignal?.call(contactId, 'p2p_answer', answer.toMap());
      debugPrint('[P2P] Answer sent to $contactId');
    } catch (e) {
      debugPrint('[P2P] Offer handle error for $contactId: $e');
      conn.state = _P2PState.failed;
    }
  }

  Future<void> _handleAnswer(
    String contactId,
    Map<String, dynamic> sdp,
  ) async {
    final conn = _conns[contactId];
    if (conn?.pc == null) return;
    try {
      final answerSdp = sdp['sdp'] as String? ?? '';
      if (!answerSdp.contains('a=fingerprint:')) {
        debugPrint('[P2P] Rejected answer without a=fingerprint: (DTLS bypass attempt)');
        return;
      }
      await conn!.pc!.setRemoteDescription(
        RTCSessionDescription(answerSdp, sdp['type'] as String? ?? 'answer'),
      );
    } catch (e) {
      debugPrint('[P2P] Answer handle error for $contactId: $e');
    }
  }

  Future<void> _handleIce(
    String contactId,
    Map<String, dynamic> ice,
  ) async {
    final conn = _conns[contactId];
    if (conn?.pc == null) return;
    try {
      await conn!.pc!.addCandidate(RTCIceCandidate(
        ice['candidate'] as String?,
        ice['sdpMid'] as String?,
        ice['sdpMLineIndex'] as int?,
      ));
    } catch (e) {
      debugPrint('[P2P] ICE handle error for $contactId: $e');
    }
  }

  void _setupPcCallbacks(String contactId, _P2PConn conn) {
    conn.pc?.onIceCandidate = (RTCIceCandidate candidate) {
      if (candidate.candidate != null) {
        onSendSignal?.call(contactId, 'p2p_ice', candidate.toMap());
      }
    };
    conn.pc?.onIceConnectionState = (RTCIceConnectionState state) {
      debugPrint('[P2P] ICE $contactId: $state');
      if (state == RTCIceConnectionState.RTCIceConnectionStateFailed ||
          state == RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
        conn.state = _P2PState.failed;
      }
    };
  }

  void _setupDcCallbacks(String contactId, _P2PConn conn) {
    conn.dc?.onDataChannelState = (RTCDataChannelState state) {
      debugPrint('[P2P] DataChannel $contactId: $state');
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        conn.state = _P2PState.connected;
        debugPrint('[P2P] Channel open with $contactId — direct delivery ready');
      } else if (state == RTCDataChannelState.RTCDataChannelClosed) {
        conn.state = _P2PState.failed;
      }
    };
    conn.dc?.onMessage = (RTCDataChannelMessage msg) {
      if (msg.isBinary) return;
      _msgCtrl.add((contactId: contactId, payload: msg.text));
    };
  }

  Future<void> _closeConn(String contactId) async {
    final conn = _conns.remove(contactId);
    if (conn == null) return;
    try {
      await conn.dc?.close();
      await conn.pc?.close();
    } catch (_) {}
  }
}
