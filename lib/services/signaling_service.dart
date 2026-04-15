import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../adapters/inbox_manager.dart';
import '../adapters/firebase_adapter.dart';
import '../adapters/pulse_adapter.dart';
import '../adapters/session_adapter.dart';
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
  /// The user's transport-level address (pubkey@server).  Used as senderId in
  /// signal payloads so the receiver can resolve the sender contact.
  /// Falls back to [myId] (UUID) when not provided (legacy callers).
  final String selfDatabaseId;
  final bool isCaller;

  // True when current primary transport profile forces relay-only.
  // Used to select the appropriate audio bitrate in SDP constraints.
  bool _primaryRestricted = false;
  // True after the first offer sets our profile — prevents peer from
  // forcing profile changes via re-offers/ICE restarts.
  bool _profileLocked = false;

  // ICE candidate flood protection — reset on each new offer/answer.
  int _candidatesReceived = 0;
  int _secondaryCandidatesReceived = 0; // F1-3: secondary path counter
  static const _kMaxCandidates = 200;

  // Buffer for ICE candidates that arrive before remote description is set.
  final List<Map<String, dynamic>> _pendingCandidates = [];
  bool _remoteDescriptionSet = false;

  // Remote peer's Yggdrasil ed25519 public key (base64), received in offer/answer.
  // Needed to construct outbound proxy routes through the overlay.
  String? _remoteYggPubkey;

  StreamSubscription? _signalSubscription;
  Function(MediaStream stream)? onAddRemoteStream;
  Function(RTCIceConnectionState state)? onConnectionState;
  /// Fires when the remote peer sends a hangup signal.
  VoidCallback? onRemoteHangUp;
  /// Fires when a reoffer arrives with no active video (remote stopped screen share).
  VoidCallback? onRemoteVideoStopped;
  /// Fires when the remote peer sends an SFU relay invite (P2P failed, fallback to server).
  Function(String roomId, String token)? onSfuRelayInvite;

  // ── Glare resolution state ─────────────────────────────────────────────────
  // When we send a reoffer and are waiting for a reanswer, _renegotiating=true.
  // Any incoming reoffer during this window is queued and processed after
  // our reanswer arrives — avoids "wrong state: have-local-offer" errors.
  bool _renegotiating = false;
  Map<String, dynamic>? _pendingReoffer;
  int _lastVideoKbps = 0;   // remembered for auto-retry after stale reanswer
  int _renegotiateRetries = 0; // guard: max 2 auto-retries per renegotiation cycle
  // If renegotiate() is called while one is already in progress, defer it.
  bool _pendingRenegotiate = false;
  int _pendingRenegotiateKbps = 0;
  // Generation counter: each renegotiate() call increments this so old
  // 15-second timeout timers can detect they belong to a stale session
  // and skip the rollback.
  int _renegotiateGen = 0;

  SignalingService({required this.contact, required this.myId, required this.isCaller, String? selfDatabaseId})
      : selfDatabaseId = selfDatabaseId ?? myId;

  // ── Initialise ─────────────────────────────────────────────────────────────

  Future<void> init({CallTransportProfile profile = CallTransportProfile.auto}) async {
    _remoteDescriptionSet = false;
    _pendingCandidates.clear();
    _primaryRestricted = profile.isRestricted;
    final config = await profile.peerConfig();
    final servers = config['iceServers'] as List? ?? [];
    debugPrint('[Signaling] init: ${servers.length} ICE servers, policy=${config['iceTransportPolicy']}');

    final isRelay = config['iceTransportPolicy'] == 'relay';
    if (Platform.isLinux && servers.length > 10) {
      // Linux native libwebrtc segfaults with many ICE servers (>30).
      // Create PC with a small safe set, then add the rest via setConfiguration.
      final stunServers = isRelay ? <dynamic>[] : servers.where((s) {
        final u = (s as Map)['urls']?.toString() ?? '';
        return u.startsWith('stun:');
      }).take(3).toList();
      final turnServers = servers.where((s) {
        final u = (s as Map)['urls']?.toString() ?? '';
        return u.startsWith('turn:') || u.startsWith('turns:');
      }).toList();
      // Safe initial set: STUN (if not relay) + first 2 TURN
      final safeServers = [...stunServers, ...turnServers.take(2)];
      config['iceServers'] = safeServers;
      debugPrint('[Signaling] Linux: creating PC with ${safeServers.length} safe servers, ${servers.length} total');
      peerConnection = await createPeerConnection(config);
      // Add remaining TURN servers via setConfiguration
      if (turnServers.length > 2) {
        try {
          final fullConfig = <String, dynamic>{
            'iceServers': [...stunServers, ...turnServers],
            'iceTransportPolicy': config['iceTransportPolicy'] ?? 'all',
            if (config.containsKey('bundlePolicy')) 'bundlePolicy': config['bundlePolicy'],
          };
          await peerConnection!.setConfiguration(fullConfig);
          debugPrint('[Signaling] Linux: setConfiguration OK with ${stunServers.length + turnServers.length} servers');
        } catch (e) {
          debugPrint('[Signaling] Linux: setConfiguration failed (non-fatal, using ${safeServers.length} servers): $e');
        }
      }
    } else {
      // For relay mode, strip STUN servers — they're useless and slow down PC creation
      if (isRelay) {
        config['iceServers'] = servers.where((s) {
          final u = (s as Map)['urls']?.toString() ?? '';
          return u.startsWith('turn:') || u.startsWith('turns:');
        }).toList();
      }
      peerConnection = await createPeerConnection(config);
    }

    _attachPeerCallbacks();
    // NOTE: _listenForSignalingData is NOT called here.
    // CallScreen must call startListening() AFTER _openUserMedia + replayPendingSignals
    // so the answer SDP includes audio tracks and cached signals aren't processed twice.
  }

  /// Start listening for live signaling data on ChatController.signalStream.
  /// Must be called AFTER local media tracks are added to the PC and after
  /// replayPendingSignals() for the callee, so that:
  ///   1. The answer SDP includes audio tracks.
  ///   2. Cached signals are not processed twice (once live, once replayed).
  void startListening() {
    _listenForSignalingData();
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
      final servers = config['iceServers'] as List? ?? [];
      if (servers.isEmpty) {
        debugPrint('[Secondary] No Tor TURN proxies available — skipping');
        return;
      }
      _secondaryPc = await createPeerConnection(config);
      _attachSecondaryCallbacks();

      // Add local audio tracks only (secondary is audio-only backup)
      if (localStream == null) {
        debugPrint('[Secondary] No local stream — skipping secondary');
        await _secondaryPc!.close();
        _secondaryPc = null;
        return;
      }
      for (final track in localStream!.getAudioTracks()) {
        await _secondaryPc!.addTrack(track, localStream!);
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
      debugPrint('[ICE] candidate: ${candidate.candidate}');
      if (candidate.candidate != null) {
        _sendSignalingData('candidate', candidate.toMap());
      }
    };

    peerConnection!.onIceGatheringState = (RTCIceGatheringState state) {
      debugPrint('[ICE] gathering state: $state');
    };

    peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
      debugPrint('ICE state: $state');
      onConnectionState?.call(state);
    };

    peerConnection!.onAddStream = (MediaStream stream) {
      remoteStream = stream;
      onAddRemoteStream?.call(stream);
    };

    // onTrack fires for each new remote track, including after mid-call
    // renegotiation (screen share). onAddStream alone is not reliably
    // re-triggered after removeTrack+addTrack renegotiation on some platforms.
    peerConnection!.onTrack = (RTCTrackEvent event) async {
      if (event.streams.isNotEmpty) {
        remoteStream = event.streams.first;
        onAddRemoteStream?.call(event.streams.first);
      } else if (event.track != null) {
        // GStreamer (Linux): onTrack fires with empty streams.
        // Create a fresh MediaStream if remoteStream is null or disposed.
        try {
          if (remoteStream == null) {
            remoteStream = await createLocalMediaStream('remote_${DateTime.now().millisecondsSinceEpoch}');
          }
          await remoteStream!.addTrack(event.track!);
          onAddRemoteStream?.call(remoteStream!);
        } catch (e) {
          // Native stream may be disposed — create a new one
          try {
            remoteStream = await createLocalMediaStream('remote_${DateTime.now().millisecondsSinceEpoch}');
            await remoteStream!.addTrack(event.track!);
            onAddRemoteStream?.call(remoteStream!);
          } catch (_) {}
        }
      }
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

  /// Sets video sender to [maxBitrate] bps for screen share.
  /// Call after renegotiate() when screen share starts.
  Future<void> applyScreenShareBitrate({required int maxBitrate}) async {
    // setParameters crashes native WebRTC (rtp_sender.cc CHECK) when called
    // while the PC is not in stable state (e.g. during or after a rolled-back
    // renegotiation).  Guard here to prevent the SIGABRT.
    if (peerConnection?.signalingState !=
        RTCSignalingState.RTCSignalingStateStable) {
      debugPrint('[RTP] applyScreenShareBitrate: skipped (PC not stable)');
      return;
    }
    try {
      final senders = await peerConnection?.getSenders() ?? [];
      for (final sender in senders) {
        if (sender.track?.kind == 'video') {
          final params = sender.parameters;
          final encodings = params.encodings;
          if (encodings == null || encodings.isEmpty) continue;
          encodings.first.maxBitrate = maxBitrate;
          await sender.setParameters(params);
          debugPrint('[RTP] screen share maxBitrate set to $maxBitrate bps');
        }
      }
    } catch (e) {
      debugPrint('[RTP] applyScreenShareBitrate failed (non-fatal): $e');
    }
  }

  Future<void> _listenForSignalingData() async {
    if (contact.isGroup) return;

    final expectedBase = contact.databaseId.contains('@')
        ? contact.databaseId.split('@').first
        : contact.databaseId;

    _signalSubscription = ChatController().signalStream.listen((sig) async {
      await _processSignal(sig, expectedBase);
    });
  }

  /// Replay any pending signals cached before we subscribed.
  /// Must be called AFTER local media tracks are added to the PC,
  /// otherwise the answer SDP will have no audio tracks (one-way audio).
  Future<void> replayPendingSignals() async {
    if (contact.isGroup) return;
    final expectedBase = contact.databaseId.contains('@')
        ? contact.databaseId.split('@').first
        : contact.databaseId;
    final pending = ChatController().consumePendingCallSignals(expectedBase);
    if (pending.isNotEmpty) {
      debugPrint('[Signaling] Replaying ${pending.length} cached signals from $expectedBase');
      for (final sig in pending) {
        await _processSignal(sig, expectedBase);
      }
    }
  }

  Future<void> _processSignal(Map<String, dynamic> sig, String expectedBase) async {
    // F1-9: strip @relay suffix before comparing senderId (different transport formats)
    final rawSender = sig['senderId'] as String? ?? '';
    final senderBase = rawSender.contains('@') ? rawSender.split('@').first : rawSender;
    // Match on sender identity only — roomId uses caller's local UUID which
    // differs from callee's local UUID, so it can never match.
    if (senderBase != expectedBase) return;
    try {
      final type = sig['type'] as String?;
      if (type == null || !type.startsWith('webrtc')) return;
      debugPrint('[Signaling] _processSignal: type=$type from=$senderBase (expected=$expectedBase, isCaller=$isCaller)');

      // Hangup signal — no encrypted payload needed
      if (type == 'webrtc_hangup') {
        debugPrint('[Signaling] Remote hangup received');
        onRemoteHangUp?.call();
        return;
      }

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
      // Mid-call renegotiation (screen share etc.) — uses separate signal types
      // so SignalDispatcher doesn't trigger incoming call notification.
      // Either side can send a reoffer.
      else if (type == 'webrtc_reoffer') {
        await _handleReoffer(payload);
      } else if (type == 'webrtc_reanswer') {
        await _handleReanswer(payload);
      }
      // SFU relay invite (P2P failed, peer asks us to join SFU room)
      else if (type == 'webrtc_sfu_invite') {
        final roomId = payload['room_id'] as String?;
        final token = payload['token'] as String?;
        if (roomId != null && token != null) {
          onSfuRelayInvite?.call(roomId, token);
        }
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
      // Require a=fingerprint: in SDP — prevents DTLS-bypass attack
      final sdp = data['sdp'] as String? ?? '';
      if (!sdp.contains('a=fingerprint:')) {
        debugPrint('[Signaling] Rejected offer SDP without a=fingerprint: (DTLS bypass attempt)');
        return;
      }
      // Reset candidate counter for new session
      _candidatesReceived = 0;
      // First-offer profile hint: mirror the caller's iceTransportPolicy so
      // both sides match on initial setup. Ignored on re-offers/ICE-restarts
      // to prevent a compromised peer from forcing relay-only mode mid-call.
      // Skip setConfiguration if profile already matches — redundant call
      // disrupts GStreamer media pipeline on Linux and triggers extra TURN allocations.
      final profileId = data['profile'] as String?;
      if (profileId != null && peerConnection != null && !_profileLocked) {
        final profile = profileId == 'restricted'
            ? CallTransportProfile.restricted
            : CallTransportProfile.auto;
        if (profile.isRestricted != _primaryRestricted) {
          _primaryRestricted = profile.isRestricted;
          await peerConnection!.setConfiguration(await profile.peerConfig());
        }
        _profileLocked = true;
      }
      await peerConnection?.setRemoteDescription(RTCSessionDescription(sdp, data['type'] as String? ?? 'offer'));
      _remoteDescriptionSet = true;
      await _flushPendingCandidates();
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
      // Require a=fingerprint: in SDP — prevents DTLS-bypass attack
      final sdp = data['sdp'] as String? ?? '';
      if (!sdp.contains('a=fingerprint:')) {
        debugPrint('[Signaling] Rejected answer SDP without a=fingerprint: (DTLS bypass attempt)');
        return;
      }
      // Reset candidate counter for new session
      _candidatesReceived = 0;
      await peerConnection?.setRemoteDescription(RTCSessionDescription(sdp, data['type'] as String? ?? 'answer'));
      _remoteDescriptionSet = true;
      await _flushPendingCandidates();
    } catch (e) {
      debugPrint('[Signaling] handleAnswer error: $e');
    }
  }

  /// Mid-call renegotiation: handle a re-offer from either peer.
  /// Used after replaceTrack (screen share) to update remote SDP.
  Future<void> _handleReoffer(Map<String, dynamic> data) async {
    try {
      final sdp = data['sdp'] as String? ?? '';
      if (!sdp.contains('a=fingerprint:')) {
        debugPrint('[Signaling] Rejected reoffer SDP without fingerprint');
        return;
      }
      // Glare resolution: if we sent a reoffer and are waiting for a reanswer,
      // we're in "have-local-offer" state — setRemoteDescription would fail.
      // Queue the incoming reoffer and process it once our reanswer arrives.
      if (_renegotiating) {
        debugPrint('[Signaling] Glare: queuing remote reoffer (waiting for our reanswer)');
        _pendingReoffer = data;
        return;
      }
      // Detect whether the incoming reoffer has an active video m-line.
      // Used to notify the renderer to clear when remote stops screen share.
      final hasActiveVideo = _sdpHasActiveVideo(sdp);
      // Attempt setRemoteDescription; if PC is stuck in have-local-offer
      // (e.g. our own reoffer timed out without a reanswer) try a rollback
      // first to return to stable state.
      bool set = false;
      try {
        await peerConnection?.setRemoteDescription(
            RTCSessionDescription(sdp, 'offer'));
        set = true;
      } catch (e) {
        final msg = e.toString();
        if (msg.contains('have-local-offer') || msg.contains('wrong state')) {
          debugPrint('[Signaling] Glare (state mismatch) — attempting rollback');
          try {
            await peerConnection
                ?.setLocalDescription(RTCSessionDescription('', 'rollback'));
            await peerConnection?.setRemoteDescription(
                RTCSessionDescription(sdp, 'offer'));
            set = true;
            debugPrint('[Signaling] Glare resolved via rollback');
          } catch (e2) {
            debugPrint('[Signaling] rollback + retry failed: $e2');
          }
        } else {
          rethrow;
        }
      }
      if (!set) return;
      // Create and send reanswer
      final answer = await peerConnection!.createAnswer();
      final constrained = _applyAudioConstraints(answer, restricted: _primaryRestricted);
      await peerConnection!.setLocalDescription(constrained);
      await _sendSignalingData('reanswer', constrained.toMap());
      debugPrint('[Signaling] reoffer handled, reanswer sent');
      // GStreamer: onTrack may fire asynchronously AFTER setRemoteDescription returns.
      // Give it a microtask to dispatch, then re-notify the renderer with current stream.
      await Future.microtask(() {
        if (remoteStream != null) onAddRemoteStream?.call(remoteStream!);
        if (!hasActiveVideo) onRemoteVideoStopped?.call();
      });
    } catch (e) {
      debugPrint('[Signaling] handleReoffer error: $e');
    }
  }

  /// Mid-call renegotiation: handle a re-answer from the peer.
  Future<void> _handleReanswer(Map<String, dynamic> data) async {
    try {
      final sdp = data['sdp'] as String? ?? '';
      if (!sdp.contains('a=fingerprint:')) {
        debugPrint('[Signaling] Rejected reanswer SDP without fingerprint');
        return;
      }
      await peerConnection?.setRemoteDescription(
          RTCSessionDescription(sdp, 'answer'));
      _renegotiating = false;
      _renegotiateRetries = 0;
      _renegotiateGen++; // invalidate any pending timeout timer for this cycle
      debugPrint('[Signaling] reanswer handled');
      // Process any reoffer that was queued during glare (we were in have-local-offer).
      final pending = _pendingReoffer;
      if (pending != null) {
        _pendingReoffer = null;
        debugPrint('[Signaling] processing queued reoffer after reanswer');
        await _handleReoffer(pending);
      }
      // If a renegotiate() call was deferred while we were negotiating, run it now.
      if (_pendingRenegotiate && _pendingReoffer == null) {
        _pendingRenegotiate = false;
        final kbps = _pendingRenegotiateKbps;
        debugPrint('[Signaling] running deferred renegotiate (kbps=$kbps)');
        await renegotiate(videoBitrateKbps: kbps);
      }
    } catch (e) {
      _renegotiating = false;
      final msg = e.toString();
      // After the 8-second timeout rolls back the local offer, the PC returns to
      // "stable".  If the reanswer arrives after that, setRemoteDescription(answer)
      // throws "Called in wrong state: stable".  This is not a fatal error — the
      // reoffer will be re-sent automatically by the next renegotiate() call.
      if (msg.contains('wrong state') || msg.contains('Called in wrong state')) {
        _renegotiateRetries++;
        if (_renegotiateRetries <= 2) {
          debugPrint('[Signaling] handleReanswer: stale reanswer — retrying renegotiate ($_renegotiateRetries/2)');
          // PC was rolled back by timeout but reanswer confirms remote is alive.
          // Retry so the pending SDP change (camera/screen share) reaches remote.
          Future.delayed(const Duration(milliseconds: 500), () {
            if (peerConnection != null && !_renegotiating) {
              renegotiate(videoBitrateKbps: _lastVideoKbps, isRetry: true);
            }
          });
        } else {
          debugPrint('[Signaling] handleReanswer: stale reanswer — retry limit reached, giving up');
          _renegotiateRetries = 0;
        }
        return;
      }
      debugPrint('[Signaling] handleReanswer error: $e');
    }
  }

  /// Trigger mid-call SDP renegotiation (e.g. after screen share replaceTrack).
  /// Uses webrtc_reoffer/reanswer to avoid triggering incoming call notification.
  /// [videoBitrateKbps] — if >0, injects b=AS: into the video m-line so the
  /// remote encoder knows the target bandwidth from the start.
  Future<void> renegotiate({int videoBitrateKbps = 0, bool isRetry = false}) async {
    if (peerConnection == null) return;
    // Guard: don't start a new renegotiation if one is already in progress.
    // Concurrent renegotiations cause m-line mismatch errors.
    if (_renegotiating && !isRetry) {
      debugPrint('[Signaling] renegotiate: already in progress — deferred (kbps=$videoBitrateKbps)');
      _pendingRenegotiate = true;
      _pendingRenegotiateKbps = videoBitrateKbps;
      return;
    }
    _pendingRenegotiate = false;
    final callerFrames = StackTrace.current.toString().split('\n').skip(1).take(5).join(' | ');
    debugPrint('[Signaling] renegotiate: starting (isRetry=$isRetry) caller=$callerFrames');
    if (!isRetry) _renegotiateRetries = 0; // fresh call resets counter
    _renegotiating = true;
    _lastVideoKbps = videoBitrateKbps;
    // Increment generation so old timeout timers can detect they're stale.
    final myGen = ++_renegotiateGen;
    // Safety timeout: reset flag if reanswer never arrives.
    // ALSO roll back the local offer so the PC returns to stable state.
    // Without rollback, subsequent incoming reoffers fail with
    // "wrong state: have-local-offer" even after the flag is cleared.
    Future.delayed(const Duration(seconds: 15), () {
      // Skip if this timer belongs to a stale renegotiation cycle.
      if (_renegotiateGen != myGen) return;
      if (_renegotiating) {
        debugPrint('[Signaling] renegotiation timeout — rolling back local offer');
        _renegotiating = false;
        // Attempt spec-compliant rollback. GStreamer may not support it;
        // if it throws we still cleared the flag which is the minimum fix.
        peerConnection
            ?.setLocalDescription(RTCSessionDescription('', 'rollback'))
            .then((_) =>
                debugPrint('[Signaling] timeout: local offer rolled back OK'))
            .catchError((e) =>
                debugPrint('[Signaling] timeout rollback failed (non-fatal): $e'));
        final pending = _pendingReoffer;
        if (pending != null) {
          _pendingReoffer = null;
          // Give rollback a moment to apply before processing the pending reoffer.
          Future.delayed(const Duration(milliseconds: 200),
              () => _handleReoffer(pending));
        } else if (_pendingRenegotiate) {
          _pendingRenegotiate = false;
          final kbps = _pendingRenegotiateKbps;
          Future.delayed(const Duration(milliseconds: 300),
              () => renegotiate(videoBitrateKbps: kbps));
        }
      }
    });
    final offer = await peerConnection!.createOffer();
    var constrained = _applyAudioConstraints(offer, restricted: _primaryRestricted);

    // Apply b=AS: BEFORE setLocalDescription so the GStreamer encoder sees
    // the target bitrate from the start.  Without this, GStreamer encodes at
    // its own default (often very low) bitrate regardless of what we later
    // inject into the remote-bound SDP.
    if (videoBitrateKbps > 0) {
      final sdpWithBitrate =
          _applyVideoSdpBitrate(constrained.sdp ?? '', videoBitrateKbps);
      constrained = RTCSessionDescription(sdpWithBitrate, constrained.type);
    }

    await peerConnection!.setLocalDescription(constrained);
    // Strip ICE candidates from reoffer — ICE is already established during
    // mid-call renegotiation. Candidates can be 20-50KB and push the event
    // past relay limits (nos.lol rejects events > 65535 bytes).
    // b=AS: is already present in constrained.sdp and preserved by pruning.
    final prunedSdp = _pruneReoferSdp(constrained.sdp ?? '');
    final prunedDesc = RTCSessionDescription(prunedSdp, constrained.type);
    await _sendSignalingData('reoffer', prunedDesc.toMap());
    debugPrint('[Signaling] renegotiation offer sent (${prunedSdp.length} bytes raw)');
  }

  Future<void> _handleCandidate(Map<String, dynamic> data) async {
    try {
      // Reject excess candidates — prevents CPU/memory flood
      if (++_candidatesReceived > _kMaxCandidates) {
        debugPrint('[Signaling] ICE candidate limit reached, dropping');
        return;
      }
      final pc = peerConnection;
      if (pc == null) return;
      // Buffer candidates until remote description is set.
      // Adding candidates without remote description crashes native WebRTC
      // on some Android builds (SIGABRT in nativeAddIceCandidate).
      if (!_remoteDescriptionSet) {
        _pendingCandidates.add(data);
        return;
      }
      final candidateStr = data['candidate'] as String?;
      if (candidateStr == null || candidateStr.isEmpty) return;
      final raw = RTCIceCandidate(
          candidateStr, data['sdpMid'] as String?, data['sdpMLineIndex'] as int?);
      final candidate = await _interceptYggCandidate(raw);
      await pc.addCandidate(candidate);
    } catch (e) {
      debugPrint('[Signaling] handleCandidate error: $e');
    }
  }

  Future<void> _flushPendingCandidates() async {
    final pending = List<Map<String, dynamic>>.from(_pendingCandidates);
    _pendingCandidates.clear();
    for (final c in pending) {
      await _handleCandidate(c);
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
    // Yggdrasil-looking IP should not be proxied (non-relay bypass).
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

  // ── SDP helpers ────────────────────────────────────────────────────────────

  /// Strips ICE candidates AND prunes the video codec list in a reoffer SDP.
  ///
  /// Problem: GStreamer (Linux) advertises 30+ video codecs (VP8/VP9/H264/H265/
  /// AV1 with RTX/FEC variants) × ~4 SDP lines each = tens of kilobytes.
  /// Combined with ICE candidates this pushes the Nostr event past 65 KB.
  ///
  /// Solution:
  ///   1. Strip all `a=candidate:` lines (ICE already established mid-call).
  ///   2. Keep only the first 4 video payload types (primary + RTX pair = 2,
  ///      or two codecs + RTX = 4); drop all others.  This reduces the video
  ///      m-section from ~35 KB to under 2 KB while preserving negotiability.
  String _pruneReoferSdp(String sdp) {
    final allLines = sdp.split(RegExp(r'\r?\n'));

    // ── Pre-pass: find VP9 payload type and its RTX partner ──────────────────
    // GStreamer advertises VP8 before VP9, but VP9 gives ~50% better quality
    // at the same bitrate.  Promote VP9 + RTX to the front so it wins
    // negotiation even after we prune to 4 payload types.
    String? vp9Pt;
    String? vp9RtxPt;
    for (final line in allLines) {
      final m = RegExp(r'^a=rtpmap:(\d+) VP9/').firstMatch(line);
      if (m != null) { vp9Pt = m.group(1); break; }
    }
    if (vp9Pt != null) {
      for (final line in allLines) {
        final m = RegExp(r'^a=fmtp:(\d+) apt=$vp9Pt\b').firstMatch(line);
        if (m != null) { vp9RtxPt = m.group(1); break; }
      }
    }

    // ── Pass 1: find video m-line and pick first 4 payload types ─────────────
    Set<String> keptVideoPts = {};
    String? reducedVideoMLine;
    for (final line in allLines) {
      if (line.startsWith('m=video ')) {
        final parts = line.split(' ');
        if (parts.length > 3) {
          var pts = parts.sublist(3);
          // Promote VP9 (+ its RTX) to the front before taking the first 4.
          if (vp9Pt != null && pts.contains(vp9Pt)) {
            pts = [
              vp9Pt!,
              if (vp9RtxPt != null && pts.contains(vp9RtxPt)) vp9RtxPt!,
              ...pts.where((p) => p != vp9Pt && p != vp9RtxPt),
            ];
          }
          // Keep first 4 payload types (covers primary codec + RTX at minimum).
          final kept = pts.length > 4 ? pts.sublist(0, 4) : pts;
          keptVideoPts = kept.toSet();
          reducedVideoMLine =
              '${parts.sublist(0, 3).join(' ')} ${kept.join(' ')}';
        }
        break;
      }
    }

    // ── Pass 2: emit pruned SDP ───────────────────────────────────────────────
    bool inVideo = false;
    final result = <String>[];
    for (final line in allLines) {
      // 1. Strip ICE candidates — not needed once ICE is connected.
      if (line.startsWith('a=candidate:') ||
          line.startsWith('a=end-of-candidates')) {
        continue;
      }
      // 2. Replace video m-line with the reduced payload-type list.
      if (line.startsWith('m=video ') && reducedVideoMLine != null) {
        result.add(reducedVideoMLine!);
        inVideo = true;
        continue;
      }
      // 3. Track section boundaries.
      if (line.startsWith('m=')) inVideo = line.startsWith('m=video');
      // 4. In video section, drop rtpmap/fmtp/rtcp-fb for pruned payload types.
      if (inVideo && keptVideoPts.isNotEmpty) {
        final m =
            RegExp(r'^a=(?:rtpmap|fmtp|rtcp-fb):(\d+)').firstMatch(line);
        if (m != null && !keptVideoPts.contains(m.group(1))) continue;
      }
      result.add(line);
    }
    return result.join('\r\n');
  }

  /// Injects `b=AS:<kbps>` into the video m= section of [sdp].
  /// This hints to the remote encoder what bandwidth to target for video.
  String _applyVideoSdpBitrate(String sdp, int maxKbps) {
    return sdp.replaceFirstMapped(
      RegExp(r'(m=video [^\r\n]*\r?\n)((?:i=[^\r\n]*\r?\n)?(?:c=[^\r\n]*\r?\n)?)'),
      (m) => '${m.group(1)!}${m.group(2)!}b=AS:$maxKbps\r\n',
    );
  }

  /// Returns true if [sdp] contains at least one video m-line with a non-zero port.
  /// A port of 0 means the m-line is inactive (track removed / stream stopped).
  bool _sdpHasActiveVideo(String sdp) {
    for (final line in sdp.split(RegExp(r'\r?\n'))) {
      if (line.startsWith('m=video ')) {
        final parts = line.split(' ');
        final port = int.tryParse(parts.elementAtOrNull(1) ?? '0') ?? 0;
        if (port > 0) return true;
      }
    }
    return false;
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
        'a=fmtp:$pt minptime=10;useinbandfec=1;usedtx=1;maxaveragebitrate=$maxBitrate';
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
    // Same guard as applyScreenShareBitrate — setParameters crashes native code
    // when PC is not in stable state.
    if (pc.signalingState != RTCSignalingState.RTCSignalingStateStable) return;
    try {
      final senders = await pc.getSenders();
      for (final sender in senders) {
        final kind = sender.track?.kind;
        final int maxBitrate;
        if (kind == 'audio') {
          maxBitrate = restricted ? 48000 : 64000;
        } else if (kind == 'video' && restricted) {
          // For restricted (TURN/Tor relay) cap video to save relay bandwidth.
          maxBitrate = 1000000; // 1 Mbps
        } else {
          // P2P direct: no video bitrate cap — let WebRTC congestion control decide.
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
      'offer':      '${prefix}_offer',
      'answer':     '${prefix}_answer',
      'candidate':  '${prefix}_candidate',
      'hangup':     '${prefix}_hangup',
      'sfu_invite': '${prefix}_sfu_invite',
      'reoffer':   '${prefix}_reoffer',
      'reanswer':  '${prefix}_reanswer',
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
        const relay = kDefaultNostrRelay;
        await InboxManager().addSenderPlugin('Nostr', NostrMessageSender(),
            jsonEncode({'privkey': privkey, 'relay': relay}));
      } else if (contact.provider == 'Pulse') {
        const storage = FlutterSecureStorage();
        final privkey = await storage.read(key: 'pulse_privkey') ?? '';
        var serverUrl = prefs.getString('pulse_server_url') ?? '';
        final atIdx = contact.databaseId.indexOf('@');
        if (atIdx != -1) {
          final contactServer = contact.databaseId.substring(atIdx + 1);
          if (contactServer.startsWith('https://') || contactServer.startsWith('http://')) {
            serverUrl = contactServer;
          }
        }
        await InboxManager().addSenderPlugin('Pulse', PulseMessageSender(),
            jsonEncode({'privkey': privkey, 'serverUrl': serverUrl}));
      } else if (contact.provider == 'Session') {
        final nodeUrl = prefs.getString('session_node_url') ?? prefs.getString('oxen_node_url') ?? '';
        await InboxManager().addSenderPlugin('Session', SessionMessageSender(), nodeUrl);
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

    // HMAC-sign offer/answer on non-Nostr transports to prevent relay operators
    // from forging fake "Incoming call" events on Oxen. ICE candidates are
    // excluded — high-volume and already inside the encrypted SDP session.
    var sendPayload = payload;
    final isOfferOrAnswer = type.endsWith('_offer') || type.endsWith('_answer');
    if (isOfferOrAnswer && contact.provider != 'Nostr') {
      try {
        const ss = FlutterSecureStorage();
        final privkey = await ss.read(key: 'nostr_privkey') ?? '';
        if (privkey.isNotEmpty) {
          final recipientPub = _extractContactPubkey();
          if (recipientPub != null) {
            final senderPub = deriveNostrPubkeyHex(privkey);
            final canonical = jsonEncode({'t': type, 'p': payload});
            final hmac = signSignalPayload(privkey, recipientPub, canonical);
            sendPayload = {...payload, '_sig': hmac, '_spk': senderPub};
          }
        }
      } catch (e) {
        debugPrint('[Signaling] HMAC sign failed: $e');
      }
    }

    final sent = await InboxManager().sendSystemMessage(
      contact.provider,
      contact.databaseId,
      contact.id,
      selfDatabaseId,
      type,
      sendPayload,
    );
  }

  /// Extract recipient's Nostr pubkey from contact addresses (for HMAC signing).
  String? _extractContactPubkey() {
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

  /// Send SFU relay invite to peer (caller side — when P2P failed).
  Future<void> sendSfuRelayInvite(String roomId, String token) async {
    await _sendSignalingData('sfu_invite', {'room_id': roomId, 'token': token});
  }

  Future<void> hangUp({bool notify = true}) async {
    // Each step is wrapped individually so a failure in one (e.g. native
    // "stream not found") never skips the remaining cleanup — especially
    // peerConnection.close() which must always run to release audio resources.
    if (notify && peerConnection != null) {
      try { await _sendSignalingData('hangup', {'reason': 'user'}); } catch (_) {}
    }
    _signalSubscription?.cancel();
    // Stop all tracks first
    try { localStream?.getTracks().forEach((t) => t.stop()); } catch (e) {
      debugPrint('Error stopping localStream tracks: $e');
    }
    try { remoteStream?.getTracks().forEach((t) => t.stop()); } catch (e) {
      debugPrint('Error stopping remoteStream tracks: $e');
    }
    // Remove all senders/receivers from PC BEFORE close — forces GStreamer to
    // tear down audio source/sink pipelines immediately, releasing PulseAudio
    // devices. Without this, close() runs async GStreamer teardown that can
    // leave the audio device locked for the next call.
    if (peerConnection != null) {
      try {
        final senders = await peerConnection!.getSenders();
        for (final s in senders) {
          try { await peerConnection!.removeTrack(s); } catch (_) {}
        }
      } catch (_) {}
    }
    try { await localStream?.dispose(); } catch (e) {
      debugPrint('Error disposing localStream: $e');
    }
    try { await remoteStream?.dispose(); } catch (e) {
      debugPrint('Error disposing remoteStream: $e');
    }
    // dispose() does close() + releases native GStreamer resources fully.
    // plain close() only shuts down ICE/DTLS but leaves native objects alive.
    try { await peerConnection?.dispose(); } catch (e) {
      debugPrint('Error disposing peerConnection: $e');
    }
    try { await _secondaryPc?.dispose(); } catch (e) {
      debugPrint('Error disposing secondaryPc: $e');
    }
    // Null out references so GC can collect native resources
    localStream = null;
    remoteStream = null;
    peerConnection = null;
    _secondaryPc = null;
  }
}
