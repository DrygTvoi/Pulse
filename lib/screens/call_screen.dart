import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../services/signaling_service.dart';
import '../services/sfu_signaling_service.dart';
import '../services/call_transport.dart';
import '../services/local_storage_service.dart';
import '../services/active_call_service.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/contact.dart';
import '../models/message.dart';
import '../l10n/l10n_ext.dart';
import '../controllers/chat_controller.dart';
import '../utils/platform_utils.dart';
import '../adapters/pulse_adapter.dart' show setPulseCallActive;

const _kScreenShareChannel = MethodChannel('im.pulse.messenger/screen_share');

class CallScreen extends StatefulWidget {
  final Contact contact;
  final String myId;
  final bool isCaller;
  /// When restoring a minimized call, pass the existing SignalingService so
  /// we skip re-initialisation and re-attach callbacks instead.
  final SignalingService? existingSignaling;
  /// Elapsed duration carried over from the minimized state.
  final Duration? resumedDuration;

  const CallScreen({
    super.key,
    required this.contact,
    required this.myId,
    this.isCaller = true,
    this.existingSignaling,
    this.resumedDuration,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();

  /// Public helper so home_screen can save a call record when the user
  /// hangs up from the minimized banner (outside of any CallScreen instance).
  static Future<void> saveCallRecord({
    required Contact contact,
    required String myId,
    required bool isCaller,
    required Duration duration,
  }) => _CallScreenState._saveCallRecordStatic(
        contact: contact,
        myId: myId,
        isCaller: isCaller,
        duration: duration,
      );
}

class _CallScreenState extends State<CallScreen> {
  SignalingService? _signaling;
  final RTCVideoRenderer _localRenderer  = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  bool _isMuted       = false;
  bool _isCameraOff     = true;  // camera OFF by default — user can enable anytime
  bool _isFrontCamera   = true;  // front camera by default; flipped by _flipCamera()
  bool _isScreenSharing = false;
  bool _screenShareToggling = false; // debounce guard for _toggleScreenShare
  bool _showControls  = true;

  RTCIceConnectionState _iceState =
      RTCIceConnectionState.RTCIceConnectionStateNew;

  // Transport profile state
  CallTransportProfile _currentProfile = CallTransportProfile.auto;
  bool _autoRetried = false;   // true after we've switched to restricted once
  bool _isRetrying  = false;   // guard against concurrent retries

  // Secondary (Tor relay) audio path
  bool _secondaryReady  = false;  // secondary PC connected and stream available
  bool _usingSecondary  = false;  // currently routing audio through secondary
  bool _ready           = false;  // true after _initWebRTC() completes
  String? _initError;            // non-null when _initWebRTC() failed

  Timer? _hideControlsTimer;
  Timer? _durationTimer;
  Timer? _mediaWatchdog;
  Timer? _disconnectTimer;   // fires if ICE stays Disconnected for >15 s
  Timer? _secondaryWatchdog; // monitors secondary path once active
  Duration _callDuration = Duration.zero;
  bool _disposed = false;

  // Primary media watchdog state
  int _lastPacketsReceived = -1; // -1 = not yet seen any RTP packets
  int _silentTicks = 0;

  // Secondary media watchdog state
  int _secondaryLastPkts = -1;
  int _secondarySilentTicks = 0;

  // SFU relay fallback (when P2P + TURN + Tor all fail)
  SfuSignalingService? _sfuService;
  bool _usingSfu = false;
  bool _sfuAttempted = false;
  bool _secondaryDegraded   = false; // true when secondary goes silent
  bool _secondaryRestarting = false; // restart in progress, prevent double-restart

  @override
  void initState() {
    super.initState();
    setPulseCallActive(true);
    if (widget.existingSignaling != null) {
      _restoreFromMinimized();
    } else {
      _initWebRTC();
    }
  }

  /// Restores a minimized call: re-attaches callbacks without creating a new PC.
  Future<void> _restoreFromMinimized() async {
    try {
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();
      _signaling = widget.existingSignaling!;
      _callDuration = widget.resumedDuration ?? Duration.zero;
      // Sync ICE state from the live PeerConnection so the UI reflects the
      // real connection state (Connected/Completed) instead of showing "Connecting…".
      final liveState = _signaling!.peerConnection?.iceConnectionState;
      if (liveState != null) _iceState = liveState;
      _reattachCallbacks();
      // If there is already a remote stream, show it immediately.
      if (_signaling!.remoteStream != null) {
        setState(() => _remoteRenderer.srcObject = _signaling!.remoteStream);
      }
      if (mounted) {
        setState(() => _ready = true);
        // Only start the duration timer if actually connected.
        if (_iceState == RTCIceConnectionState.RTCIceConnectionStateConnected ||
            _iceState == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
          _startDurationTimer();
        }
        _resetHideControlsTimer();
      }
    } catch (e) {
      debugPrint('[CallScreen] _restoreFromMinimized failed: $e');
      if (mounted) setState(() => _initError = 'Failed to restore call.');
    }
  }

  /// Re-attach all SignalingService callbacks after restoring from minimized.
  void _reattachCallbacks() {
    _signaling!.onAddRemoteStream = (stream) async {
      if (!mounted) return;
      if (stream.getVideoTracks().isNotEmpty &&
          _remoteRenderer.srcObject != null) {
        setState(() => _remoteRenderer.srcObject = null);
        await Future.delayed(const Duration(milliseconds: 80));
        if (mounted) setState(() => _remoteRenderer.srcObject = stream);
      } else {
        setState(() => _remoteRenderer.srcObject = stream);
      }
    };

    _signaling!.onConnectionState = _onIceState;

    _signaling!.onRemoteVideoStopped = () {
      if (!mounted) return;
      setState(() => _remoteRenderer.srcObject = null);
      debugPrint('[CallScreen] Remote video stopped — renderer cleared');
    };

    _signaling!.onRemoteHangUp = () {
      debugPrint('[CallScreen] Remote peer hung up');
      if (!_disposed && mounted) _hangUp(remoteInitiated: true);
    };

    _signaling!.onSecondaryRemoteStream = (stream) {
      if (!mounted) return;
      setState(() => _secondaryReady = true);
      if (_iceState == RTCIceConnectionState.RTCIceConnectionStateFailed &&
          !_usingSecondary) {
        _switchToSecondary();
      }
    };
    _signaling!.onSecondaryConnectionState = (state) {
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected ||
          state == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
        if (mounted) setState(() => _secondaryReady = true);
      }
    };

    _signaling!.onSfuRelayInvite = (roomId, token) {
      if (_usingSfu || _sfuAttempted || _disposed) return;
      _joinSfuRelay(roomId, token);
    };

    _ready = true;
  }

  /// Minimizes the call — hands off the SignalingService to [ActiveCallService]
  /// and pops the CallScreen without hanging up.
  void _minimize() {
    if (_disposed) return;
    // Mark disposed so dispose() doesn't call hangUp().
    _disposed = true;
    _durationTimer?.cancel();
    _hideControlsTimer?.cancel();
    _mediaWatchdog?.cancel();
    _disconnectTimer?.cancel();
    _secondaryWatchdog?.cancel();
    final sig = _signaling;
    _signaling = null; // prevent dispose() from calling hangUp() via null-check
    if (sig == null) {
      if (mounted) Navigator.pop(context);
      return;
    }
    final capturedDuration = _callDuration;
    final capturedContact = widget.contact;
    final capturedMyId = widget.myId;
    final capturedIsCaller = widget.isCaller;
    ActiveCallService.instance.minimize(
      sig: sig,
      contact: capturedContact,
      myId: capturedMyId,
      isCaller: capturedIsCaller,
      elapsed: capturedDuration,
      onRemoteHangUp: () {
        // Called by ActiveCallService when remote hangs up while minimized.
        _saveCallRecordStatic(
          contact: capturedContact,
          myId: capturedMyId,
          isCaller: capturedIsCaller,
          duration: ActiveCallService.instance.elapsed,
        );
      },
    );
    if (mounted) Navigator.pop(context);
  }

  /// Saves a call history record to local storage and in-memory room.
  Future<void> _saveCallRecord() async {
    await _saveCallRecordStatic(
      contact: widget.contact,
      myId: widget.myId,
      isCaller: widget.isCaller,
      duration: _callDuration,
    );
  }

  static Future<void> _saveCallRecordStatic({
    required Contact contact,
    required String myId,
    required bool isCaller,
    required Duration duration,
  }) async {
    try {
      final dur = duration.inSeconds;
      final payload = jsonEncode({
        't': 'call',
        'duration': dur,
        'outgoing': isCaller,
        'connected': dur > 0,
      });
      final msg = Message(
        id: const Uuid().v4(),
        senderId: isCaller ? myId : contact.databaseId,
        receiverId: isCaller ? contact.databaseId : myId,
        encryptedPayload: payload,
        timestamp: DateTime.now(),
        adapterType: contact.provider.toLowerCase(),
        isRead: true,
        status: '',
      );
      await LocalStorageService().saveMessage(contact.storageKey, msg.toJson());
      ChatController().addSystemMessage(contact, msg);
    } catch (e) {
      debugPrint('[CallScreen] _saveCallRecord failed: $e');
    }
  }

  // ── Initialise / reinitialise ──────────────────────────────────────────────

  Future<void> _initWebRTC({
    CallTransportProfile profile = CallTransportProfile.auto,
  }) async {
    bool renderersInitialized = false;
    try {
      debugPrint('[CallScreen] _initWebRTC start (isCaller=${widget.isCaller})');

      // Force-reconnect subscription if it appears dead (no data in 30s).
      // If subscription is alive, forceReconnect is a no-op — no disruptive close.
      // Dead subscription = lost signaling = call stuck on "Connecting".
      final didReconnect = ChatController().forceReconnectSubscription();
      if (didReconnect) {
        // Wait for the reconnection to establish before sending offers.
        await Future.delayed(const Duration(milliseconds: 1500));
      }

      await _localRenderer.initialize();
      await _remoteRenderer.initialize();
      renderersInitialized = true;
      debugPrint('[CallScreen] renderers initialized');

      _signaling = SignalingService(
        contact: widget.contact,
        myId:    widget.myId,
        isCaller: widget.isCaller,
      );

      _signaling!.onAddRemoteStream = (stream) async {
        if (!mounted) return;
        if (stream.getVideoTracks().isNotEmpty &&
            _remoteRenderer.srcObject != null) {
          // Force GStreamer/WebRTC renderer to reinitialize its pipeline when
          // video arrives mid-call (e.g. remote starts screen share).
          // Assigning the same stream object to srcObject is a no-op at the
          // native layer — briefly null-out to force a fresh pipeline.
          setState(() => _remoteRenderer.srcObject = null);
          await Future.delayed(const Duration(milliseconds: 80));
          if (mounted) setState(() => _remoteRenderer.srcObject = stream);
        } else {
          setState(() => _remoteRenderer.srcObject = stream);
        }
      };

      _signaling!.onConnectionState = _onIceState;

      _signaling!.onRemoteVideoStopped = () {
        // Remote stopped screen share — clear the renderer so it doesn't show
        // a frozen last frame.
        if (!mounted) return;
        setState(() => _remoteRenderer.srcObject = null);
        debugPrint('[CallScreen] Remote video stopped — renderer cleared');
      };

      _signaling!.onRemoteHangUp = () {
        debugPrint('[CallScreen] Remote peer hung up');
        if (!_disposed && mounted) _hangUp(remoteInitiated: true);
      };

      // Secondary path callbacks
      _signaling!.onSecondaryRemoteStream = (stream) {
        if (!mounted) return;
        setState(() => _secondaryReady = true);
        // If primary has already failed, switch to secondary immediately
        if (_iceState == RTCIceConnectionState.RTCIceConnectionStateFailed &&
            !_usingSecondary) {
          _switchToSecondary();
        }
      };
      _signaling!.onSecondaryConnectionState = (state) {
        if (state == RTCIceConnectionState.RTCIceConnectionStateConnected ||
            state == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
          if (mounted) setState(() => _secondaryReady = true);
        }
      };

      // SFU relay invite from peer (callee side — peer's P2P also failed)
      _signaling!.onSfuRelayInvite = (roomId, token) {
        if (_usingSfu || _sfuAttempted || _disposed) return;
        _joinSfuRelay(roomId, token);
      };

      debugPrint('[CallScreen] creating peer connection…');
      await _signaling!.init(profile: profile);
      if (_disposed) { unawaited(_signaling!.hangUp()); return; }
      debugPrint('[CallScreen] peer connection created');

      debugPrint('[CallScreen] opening user media…');
      await _openUserMedia();
      if (_disposed) { unawaited(_signaling!.hangUp()); return; }
      debugPrint('[CallScreen] user media opened');

      if (widget.isCaller) {
        // Start live signal listener (answer will arrive after offer is sent)
        _signaling!.startListening();
        debugPrint('[CallScreen] creating offer…');
        await _signaling!.createOffer();
        debugPrint('[CallScreen] offer sent');
      } else {
        // Callee: replay cached offer/candidates AFTER tracks are on the PC,
        // so the answer SDP includes our audio tracks.
        // Start live listener AFTER replay to avoid processing signals twice.
        debugPrint('[CallScreen] callee: replaying pending signals…');
        await _signaling!.replayPendingSignals();
        _signaling!.startListening();
        debugPrint('[CallScreen] callee: pending signals replayed, listening');
      }
      if (_disposed) { unawaited(_signaling!.hangUp()); return; }

      // Start secondary audio path in background — will be ready if primary fails.
      // On Linux, delay to avoid concurrent native WebRTC operations that crash.
      if (Platform.isLinux) {
        Future.delayed(const Duration(seconds: 3), () {
          if (_disposed || _signaling == null) return;
          _signaling!.startSecondaryAudio().catchError((e) {
            debugPrint('[CallScreen] startSecondaryAudio failed: $e');
          });
        });
      } else {
        unawaited(_signaling!.startSecondaryAudio().catchError((e) {
          debugPrint('[CallScreen] startSecondaryAudio failed: $e');
        }));
      }

      if (mounted) {
        setState(() => _ready = true);
        _resetHideControlsTimer();
      }
      debugPrint('[CallScreen] _initWebRTC complete');
    } catch (e) {
      debugPrint('[CallScreen] _initWebRTC failed: $e');
      _signaling?.hangUp();
      _signaling = null;
      if (renderersInitialized) {
        _disposeRenderers();
      }
      if (mounted) {
        setState(() {
          _ready = false;
          // FINDING-11: Never expose internal exception text to the UI
          _initError = 'Failed to start call. Please try again.';
        });
      }
    }
  }

  // ── ICE state handler with auto-retry ─────────────────────────────────────

  void _onIceState(RTCIceConnectionState state) {
    if (!mounted) return;
    setState(() => _iceState = state);

    if (state == RTCIceConnectionState.RTCIceConnectionStateConnected ||
        state == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
      _disconnectTimer?.cancel();
      _startDurationTimer();
      unawaited(_signaling?.applyBitrateLimit(
          restricted: _currentProfile.isRestricted));
      // Re-apply screen share bitrate after every renegotiation cycle —
      // setParameters values can be reset by renegotiation on some platforms.
      if (_isScreenSharing && _screenShareBitrate > 0) {
        unawaited(_signaling?.applyScreenShareBitrate(
            maxBitrate: _screenShareBitrate));
      }
      unawaited(ChatController().broadcastTurnToContact(widget.contact));
      _startMediaWatchdog();
    }

    if (state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
      _durationTimer?.cancel();
      if (!_usingSecondary && !_usingSfu) {
        if (_secondaryReady) {
          _switchToSecondary();
        } else if (!_autoRetried && !_isRetrying) {
          _retryRestricted();
        } else if (!_sfuAttempted && ChatController().hasPulseRelay) {
          // P2P + restricted + Tor all failed — try SFU server relay
          _sfuRelayFallback();
        } else {
          // All retries exhausted — auto-hangup after 15s
          _disconnectTimer?.cancel();
          _disconnectTimer = Timer(const Duration(seconds: 15), () {
            if (!_disposed && mounted) _hangUp();
          });
        }
      }
    }

    if (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
      _durationTimer?.cancel();
      // ICE sometimes recovers from Disconnected on its own.
      // Give it 15 s; if it hasn't reconnected by then, treat as Failed.
      _disconnectTimer?.cancel();
      _disconnectTimer = Timer(const Duration(seconds: 15), () {
        if (!_disposed &&
            mounted &&
            _iceState == RTCIceConnectionState.RTCIceConnectionStateDisconnected &&
            !_usingSecondary) {
          _onIceState(RTCIceConnectionState.RTCIceConnectionStateFailed);
        }
      });
    }
  }

  /// Restarts ICE with RestrictedProfile (relay-only, TLS/TCP 443) on failure.
  ///
  /// Uses iceRestart() which calls setConfiguration + createOffer({iceRestart})
  /// on the existing PC — no teardown, no timing coordination with callee.
  /// The callee receives the new offer via normal signaling and processes it.
  Future<void> _retryRestricted() async {
    if (_disposed || _autoRetried || _isRetrying) return;
    if (mounted) setState(() => _isRetrying = true);
    try {
      await _signaling?.iceRestart(CallTransportProfile.restricted);
      if (_disposed) return;
      if (mounted) {
        setState(() {
          _autoRetried    = true;
          _currentProfile = CallTransportProfile.restricted;
          _iceState       = RTCIceConnectionState.RTCIceConnectionStateChecking;
        });
      }
    } catch (e) {
      debugPrint('[CallScreen] _retryRestricted failed: $e');
      // ICE restart failed entirely — fall through to secondary on next Failed event
      if (mounted) setState(() => _autoRetried = true);
    } finally {
      if (!_disposed && mounted) setState(() => _isRetrying = false);
    }
  }

  /// Switch active audio output to the secondary (Tor relay) stream.
  void _switchToSecondary() {
    if (_disposed || _signaling?.secondaryRemoteStream == null) return;
    _mediaWatchdog?.cancel();
    _mediaWatchdog = null;
    setState(() {
      _usingSecondary    = true;
      _secondaryDegraded = false;
      _remoteRenderer.srcObject = _signaling!.secondaryRemoteStream;
    });
    _startDurationTimer();
    unawaited(_signaling!.applyBitrateLimit(restricted: true));
    _startSecondaryWatchdog();
    debugPrint('[CallScreen] Switched to secondary audio (Tor relay)');
  }

  // ── SFU relay fallback (server-mediated when P2P is blocked) ────────────────

  /// Caller side: create SFU room and invite peer.
  void _sfuRelayFallback() {
    if (_disposed || _sfuAttempted) return;
    _sfuAttempted = true;
    debugPrint('[CallScreen] P2P failed — attempting SFU relay fallback');

    // Cancel any pending auto-hangup
    _disconnectTimer?.cancel();

    final contact = widget.contact;
    _sfuService = SfuSignalingService(group: contact, myId: widget.myId);

    _sfuService!.onRoomReady = () async {
      if (_disposed || _sfuService == null) return;
      debugPrint('[CallScreen] SFU room ready, setting up PC');
      // Reuse the existing local stream
      final stream = _signaling?.localStream;
      if (stream == null) {
        debugPrint('[CallScreen] SFU fallback: no local stream');
        return;
      }
      await _sfuService!.setupPeerConnection(stream);
      // Send invite to peer so they join too
      final roomId = _sfuService!.roomId;
      final token = _sfuService!.roomToken;
      if (roomId != null && token != null) {
        _signaling?.sendSfuRelayInvite(roomId, token);
        debugPrint('[CallScreen] SFU invite sent to peer: room=$roomId');
      }
    };

    _sfuService!.onRemoteTrack = (event) {
      if (_disposed || !mounted) return;
      if (event.streams.isNotEmpty) {
        setState(() {
          _usingSfu = true;
          _remoteRenderer.srcObject = event.streams.first;
        });
        _startDurationTimer();
        debugPrint('[CallScreen] SFU relay connected — remote track received');
      }
    };

    _sfuService!.onIceState = (state) {
      if (_disposed || !mounted) return;
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected ||
          state == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
        if (!_usingSfu) {
          setState(() => _usingSfu = true);
          _startDurationTimer();
        }
      } else if (state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
        debugPrint('[CallScreen] SFU relay ICE also failed');
        // SFU also failed — auto-hangup
        _disconnectTimer?.cancel();
        _disconnectTimer = Timer(const Duration(seconds: 15), () {
          if (!_disposed && mounted) _hangUp();
        });
      }
    };

    _sfuService!.createRoom();
  }

  /// Callee side: join SFU room invited by peer.
  void _joinSfuRelay(String roomId, String token) {
    if (_disposed || _sfuAttempted) return;
    _sfuAttempted = true;
    _disconnectTimer?.cancel();
    debugPrint('[CallScreen] Received SFU invite — joining room $roomId');

    final contact = widget.contact;
    _sfuService = SfuSignalingService(group: contact, myId: widget.myId);

    _sfuService!.onRoomReady = () async {
      if (_disposed || _sfuService == null) return;
      final stream = _signaling?.localStream;
      if (stream == null) return;
      await _sfuService!.setupPeerConnection(stream);
    };

    _sfuService!.onRemoteTrack = (event) {
      if (_disposed || !mounted) return;
      if (event.streams.isNotEmpty) {
        setState(() {
          _usingSfu = true;
          _remoteRenderer.srcObject = event.streams.first;
        });
        _startDurationTimer();
        debugPrint('[CallScreen] SFU relay connected (callee)');
      }
    };

    _sfuService!.onIceState = (state) {
      if (_disposed || !mounted) return;
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected ||
          state == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
        if (!_usingSfu) {
          setState(() => _usingSfu = true);
          _startDurationTimer();
        }
      }
    };

    _sfuService!.joinRoom(roomId, token);
  }

  // ── Media watchdog ─────────────────────────────────────────────────────────
  //
  // Polls WebRTC inbound-rtp stats every 10 seconds.  If inbound audio packet
  // count stops incrementing for 20 seconds (2 consecutive silent ticks) and
  // the Tor secondary path is ready, switches to secondary automatically.
  //
  // This covers the Yggdrasil-relay-died scenario where the local pion/turn
  // server keeps ICE alive (STUN keepalives to 127.0.0.1 succeed) but the
  // Yggdrasil overlay path to the remote is broken — ICE never goes "Failed".
  //
  // False-positive guard: only starts counting silence after at least one
  // non-zero packet count is observed, so connection setup time is ignored.

  void _startMediaWatchdog() {
    _mediaWatchdog?.cancel();
    _lastPacketsReceived = -1;
    _silentTicks = 0;
    _mediaWatchdog = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (!mounted || _usingSecondary || _disposed) return;
      final pc = _signaling?.peerConnection;
      if (pc == null) return;
      try {
        final stats = await pc.getStats()
            .timeout(const Duration(seconds: 5), onTimeout: () => []);
        for (final report in stats) {
          if (report.type != 'inbound-rtp') continue;
          final kind = report.values['kind'] as String?;
          if (kind != 'audio') continue;
          final packets =
              (report.values['packetsReceived'] as num?)?.toInt() ?? 0;
          if (_lastPacketsReceived < 0) {
            // First observation — just record baseline, don't count silence yet
            if (packets > 0) _lastPacketsReceived = packets;
          } else if (packets > _lastPacketsReceived) {
            _silentTicks = 0;
            _lastPacketsReceived = packets;
          } else {
            _silentTicks++;
            debugPrint('[Watchdog] silent tick $_silentTicks '
                '(pkts=$packets last=$_lastPacketsReceived)');
            if (_silentTicks >= 2 && _secondaryReady && !_usingSecondary) {
              debugPrint('[Watchdog] relay silent >20 s — switching to Tor secondary');
              _switchToSecondary();
            }
          }
          break; // only need first audio inbound-rtp entry
        }
      } catch (e) {
        debugPrint('[Watchdog] getStats error (non-fatal): $e');
      }
    });
  }

  // ── Secondary media watchdog ───────────────────────────────────────────────
  //
  // Same logic as the primary watchdog but for the Tor secondary path.
  // When the secondary goes silent for 20 s (2 ticks), shows an amber
  // "degraded" indicator on the banner — there is no third path to switch to,
  // but the user is informed and can choose to hang up and retry.

  void _startSecondaryWatchdog() {
    _secondaryWatchdog?.cancel();
    _secondaryLastPkts = -1;
    _secondarySilentTicks = 0;
    _secondaryWatchdog = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (!mounted || !_usingSecondary || _disposed) return;
      final pc = _signaling?.secondaryPc;
      if (pc == null) return;
      try {
        final stats = await pc.getStats()
            .timeout(const Duration(seconds: 5), onTimeout: () => []);
        for (final report in stats) {
          if (report.type != 'inbound-rtp') continue;
          final kind = report.values['kind'] as String?;
          if (kind != 'audio') continue;
          final packets =
              (report.values['packetsReceived'] as num?)?.toInt() ?? 0;
          if (_secondaryLastPkts < 0) {
            if (packets > 0) _secondaryLastPkts = packets;
          } else if (packets > _secondaryLastPkts) {
            _secondarySilentTicks = 0;
            _secondaryLastPkts = packets;
            if (_secondaryDegraded && mounted) {
              setState(() => _secondaryDegraded = false);
            }
          } else {
            _secondarySilentTicks++;
            debugPrint('[SecWatchdog] silent tick $_secondarySilentTicks');
            if (_secondarySilentTicks >= 2 && mounted && !_secondaryRestarting) {
              if (!_secondaryDegraded) setState(() => _secondaryDegraded = true);
              // Attempt to restart the Tor secondary path (new Tor circuit).
              // Reset counters so we can detect recovery or a second failure.
              _secondarySilentTicks = 0;
              _secondaryLastPkts    = -1;
              _secondaryRestarting  = true;
              debugPrint('[SecWatchdog] restarting secondary (Tor circuit refresh)');
              try {
                await _signaling?.restartSecondaryAudio();
              } catch (e) {
                debugPrint('[SecWatchdog] restart failed: $e');
              } finally {
                if (!_disposed) _secondaryRestarting = false;
              }
            }
          }
          break;
        }
      } catch (e) {
        debugPrint('[SecWatchdog] getStats error (non-fatal): $e');
      }
    });
  }

  // ── Media ──────────────────────────────────────────────────────────────────

  // The video sender — kept to allow replaceTrack for camera/screen toggle.
  RTCRtpSender? _videoSender;

  // Active screen share stream — kept to stop its tracks on share end.
  MediaStream? _screenShareStream;
  MediaStream? _cameraStream; // kept for local preview and disposal

  // Bitrate cap for current screen share (bps). 0 = auto.
  // Stored so it can be re-applied after each renegotiation cycle.
  int _screenShareBitrate = 0;

  // Desktop sources cache — populated on first getSources call to avoid
  // double PipeWire portal dialog when screen sharing again.
  List<DesktopCapturerSource>? _cachedDesktopSources;

  Future<void> _openUserMedia() async {
    // Get audio SEPARATELY from video to avoid clock contamination
    // (mixed audio+video getUserMedia can cause audio speed issues on some platforms).
    final audioStream = await navigator.mediaDevices.getUserMedia({
      'audio': true, 'video': false,
    }).timeout(const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('getUserMedia(audio) timed out'));
    _signaling?.localStream = audioStream;

    final pc = _signaling?.peerConnection;
    if (pc == null) return;

    // Add audio tracks
    for (final t in audioStream.getAudioTracks()) {
      await pc.addTrack(t, audioStream);
    }

    // Try to get a video track (camera) — disabled immediately.
    // Having a video sender from the start lets replaceTrack work for camera/screen toggle.
    try {
      final videoStream = await navigator.mediaDevices.getUserMedia({
        'audio': false,
        'video': {'facingMode': _isFrontCamera ? 'user' : 'environment'},
      }).timeout(const Duration(seconds: 5),
          onTimeout: () => throw TimeoutException('getUserMedia(video) timed out'));
      _cameraStream = videoStream;
      final videoTrack = videoStream.getVideoTracks().first;
      videoTrack.enabled = false; // camera off by default
      _videoSender = await pc.addTrack(videoTrack, videoStream);
    } catch (e) {
      // No camera available — create an empty video transceiver so
      // replaceTrack works later for camera toggle and screen sharing.
      debugPrint('[CallScreen] No camera, creating video transceiver: $e');
      try {
        final transceiver = await pc.addTransceiver(
          kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
          init: RTCRtpTransceiverInit(direction: TransceiverDirection.SendRecv),
        );
        _videoSender = transceiver.sender;
      } catch (e2) {
        debugPrint('[CallScreen] addTransceiver failed: $e2');
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _toggleScreenShare() async {
    // Debounce: prevent double-invocation (two picker windows on rapid tap)
    if (_screenShareToggling) return;
    _screenShareToggling = true;
    try {
      if (_isScreenSharing) {
        // Explicitly stop all tracks in the screen share stream.
        // Without this, PipeWire/MediaProjection keeps capturing after share ends,
        // causing conflicts on subsequent start cycles.
        if (_screenShareStream != null) {
          for (final t in _screenShareStream!.getTracks()) {
            try { await t.stop(); } catch (_) {}
          }
          _screenShareStream = null;
        }
        // Remove sender so remote sees video stop.
        final pc = _signaling?.peerConnection;
        if (pc != null && _videoSender != null) {
          try {
            await pc.removeTrack(_videoSender!);
          } catch (e) {
            debugPrint('[CallScreen] removeTrack on stop: $e');
          }
          _videoSender = null;
        }
        // Clear desktop source cache so next start gets a fresh capture session.
        _cachedDesktopSources = null;
        _screenShareBitrate = 0;
        _localRenderer.srcObject = null;
        setState(() {
          _isScreenSharing = false;
          _isCameraOff = true;
        });
        // Renegotiate so remote knows video is gone.
        try {
          await _signaling?.renegotiate();
        } catch (e) {
          debugPrint('[CallScreen] renegotiate after stop share: $e');
        }
        // Stop Android foreground service (not needed once capture is done).
        if (Platform.isAndroid) {
          try { await _kScreenShareChannel.invokeMethod('stopService'); } catch (_) {}
        }
      } else {
        // Start screen share
        // Android 14+ requires a foreground service with FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION
        // to be running BEFORE getMediaProjection() is called inside getDisplayMedia().
        if (Platform.isAndroid) {
          try { await _kScreenShareChannel.invokeMethod('startService'); } catch (e) {
            debugPrint('[CallScreen] ScreenShareService start failed: $e');
          }
          // Give the service time to call startForeground() before we request capture.
          await Future.delayed(const Duration(milliseconds: 300));
        }

        // Show quality picker and read FPS/resolution settings.
        final prefs = await SharedPreferences.getInstance();
        int savedFps = prefs.getInt('screen_share_fps') ?? 30;
        // Default to 1080p (1920) — gives good quality without excessive SDP size.
        int savedResWidth = prefs.getInt('screen_share_res') ?? 1920;
        if (mounted) {
          final picked = await _showScreenShareQualityDialog(savedFps, savedResWidth);
          if (picked == null) return; // user cancelled
          savedFps = picked.$1;
          savedResWidth = picked.$2;
          await prefs.setInt('screen_share_fps', savedFps);
          await prefs.setInt('screen_share_res', savedResWidth);
        }
        final fps = savedFps.toDouble();
        final resWidth = savedResWidth;
        final resHeight = resWidth > 0 ? (resWidth * 9 ~/ 16) : 0;
        final bitratePreset = _resWidthToBitrate(resWidth);

        final Map<String, dynamic> videoConstraints = {
          'mandatory': <String, dynamic>{
            'maxFrameRate': fps,
            if (resWidth > 0) ...{
              'maxWidth': resWidth,
              'maxHeight': resHeight,
            },
          },
        };

        MediaStream stream;
        if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
          // Desktop: enumerate sources via desktopCapturer, then pass the
          // selected deviceId to getDisplayMedia.
          // Sources are cached after the first call so getSources() (and its
          // portal dialog on Linux/PipeWire) only fires once per call session.
          var sources = _cachedDesktopSources;
          if (sources == null || sources.isEmpty) {
            sources = await desktopCapturer.getSources(types: [SourceType.Screen]);
            _cachedDesktopSources = sources;
          }
          if (sources.isEmpty) {
            debugPrint('[CallScreen] No desktop sources found');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('No screen sources available'),
                duration: Duration(seconds: 2),
              ));
            }
            return;
          }
          final screenSources = sources.where((s) => s.type == SourceType.Screen).toList();
          final screenSource = screenSources.isNotEmpty ? screenSources.first : sources.first;
          debugPrint('[CallScreen] Using desktop source: ${screenSource.name} (${screenSource.id})');
          stream = await navigator.mediaDevices.getDisplayMedia({
            'video': {'deviceId': {'exact': screenSource.id}, ...videoConstraints},
            'audio': false,
          });
        } else {
          // Mobile: getDisplayMedia works directly.
          stream = await navigator.mediaDevices.getDisplayMedia({
            'video': videoConstraints,
            'audio': false,
          });
        }
        final screenTracks = stream.getVideoTracks();
        if (screenTracks.isEmpty) return;
        final screenTrack = screenTracks.first;
        screenTrack.enabled = true;

        final pc = _signaling?.peerConnection;
        if (pc == null) return;

        // replaceTrack() is broken in flutter_webrtc on Linux/GStreamer — it does
        // not update the RTP pipeline so the remote never receives screen frames.
        // Use removeTrack() + addTrack() instead: this creates a new m-line in
        // the reoffer SDP, which triggers onTrack/onAddStream on the remote side
        // and properly delivers the screen video.
        if (_videoSender != null) {
          try {
            await pc.removeTrack(_videoSender!);
          } catch (e) {
            debugPrint('[CallScreen] removeTrack before screen share: $e');
          }
          _videoSender = null;
        }
        _videoSender = await pc.addTrack(screenTrack, stream);
        debugPrint('[CallScreen] addTrack for screen share');

        // Ensure video transceiver direction is sendrecv
        try {
          final transceivers = await pc.getTransceivers();
          for (final t in transceivers) {
            if (t.sender.track?.kind == 'video') {
              await t.setDirection(TransceiverDirection.SendRecv);
              break;
            }
          }
        } catch (e) {
          debugPrint('[CallScreen] transceiver direction check: $e');
        }

        // Force sender to be active by re-setting parameters with active encoding
        try {
          final params = _videoSender!.parameters;
          if (params.encodings != null && params.encodings!.isNotEmpty) {
            for (final enc in params.encodings!) {
              enc.active = true;
            }
            await _videoSender!.setParameters(params);
            debugPrint('[CallScreen] sender params set active');
          }
        } catch (e) {
          debugPrint('[CallScreen] setParameters: $e');
        }

        _screenShareStream = stream;
        _screenShareBitrate = bitratePreset; // remember for re-apply on ICE reconnect
        _localRenderer.srcObject = stream;
        screenTrack.onEnded = () {
          if (!_disposed && mounted && _isScreenSharing) {
            _toggleScreenShare();
          }
        };
        setState(() {
          _isScreenSharing = true;
          _isCameraOff = true;
        });

        // Send reoffer so remote gets updated SDP with active video track.
        // Pass videoBitrateKbps so b=AS: is injected into the video m-line —
        // this gives the remote encoder a bandwidth target from the first packet.
        try {
          await _signaling?.renegotiate(
              videoBitrateKbps: bitratePreset > 0 ? bitratePreset ~/ 1000 : 0);
        } catch (e) {
          debugPrint('[CallScreen] renegotiate after screen share: $e');
        }
        // Also apply via setParameters (belt-and-suspenders: SDP hint + RTP cap).
        if (bitratePreset > 0) {
          try {
            await _signaling?.applyScreenShareBitrate(maxBitrate: bitratePreset);
          } catch (e) {
            debugPrint('[CallScreen] applyScreenShareBitrate: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('[CallScreen] Screen share error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(Platform.isAndroid
              ? 'Screen sharing requires permission'
              : 'Screen sharing unavailable'),
          duration: const Duration(seconds: 2),
        ));
      }
    } finally {
      _screenShareToggling = false;
    }
  }

  /// Shows a bottom sheet to pick screen share FPS and resolution.
  /// Returns (fps, resWidth) or null if cancelled.
  /// resWidth: 0=Auto (native), 1280=720p, 1920=1080p, 2560=1440p.
  Future<(int fps, int resWidth)?> _showScreenShareQualityDialog(
      int currentFps, int currentResWidth) async {
    int selFps = currentFps;
    int selResWidth = currentResWidth;
    Widget sheetContent(BuildContext ctx, StateSetter setS) => Padding(
      padding: EdgeInsets.fromLTRB(DesignTokens.spacing20, DesignTokens.spacing16, DesignTokens.spacing20, DesignTokens.spacing32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!PlatformUtils.isDesktop)
            Center(child: Container(width: 36, height: DesignTokens.spacing4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withValues(alpha: DesignTokens.opacityMedium),
                borderRadius: BorderRadius.circular(DesignTokens.radiusXs)))),
          if (!PlatformUtils.isDesktop) SizedBox(height: DesignTokens.spacing16),
          Text('Screen Share Quality',
            style: GoogleFonts.inter(color: AppTheme.textPrimary,
              fontSize: DesignTokens.fontXl, fontWeight: FontWeight.w700)),
          SizedBox(height: DesignTokens.spacing16),
          Text('Frame rate', style: GoogleFonts.inter(
            color: AppTheme.textSecondary, fontSize: DesignTokens.fontBody)),
          SizedBox(height: DesignTokens.spacing8),
          _buildQualityChips(
            options: const [15, 30, 60],
            labels: const ['15 fps', '30 fps', '60 fps'],
            selected: selFps,
            onSelect: (v) => setS(() => selFps = v),
          ),
          SizedBox(height: DesignTokens.spacing16),
          Text('Resolution', style: GoogleFonts.inter(
            color: AppTheme.textSecondary, fontSize: DesignTokens.fontBody)),
          SizedBox(height: DesignTokens.spacing8),
          _buildQualityChips(
            options: const [1280, 1920, 2560, 0],
            labels: const ['720p', '1080p', '1440p', 'Auto'],
            selected: selResWidth,
            onSelect: (v) => setS(() => selResWidth = v),
          ),
          SizedBox(height: DesignTokens.spacing6),
          Text('Auto = native screen resolution',
            style: GoogleFonts.inter(color: AppTheme.textSecondary,
              fontSize: DesignTokens.fontSm)),
          SizedBox(height: DesignTokens.spacing20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMedium)),
                padding: EdgeInsets.symmetric(vertical: DesignTokens.spacing14)),
              onPressed: () => Navigator.pop(ctx, (selFps, selResWidth)),
              child: Text('Start sharing',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );

    final (int, int)? result;
    if (PlatformUtils.isDesktop) {
      result = await showDialog<(int, int)>(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.buttonRadius),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: StatefulBuilder(
              builder: (ctx, setS) => sheetContent(ctx, setS),
            ),
          ),
        ),
      );
    } else {
      result = await showModalBottomSheet<(int, int)>(
        context: context,
        backgroundColor: AppTheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusXl)),
        ),
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setS) => sheetContent(ctx, setS),
        ),
      );
    }
    return result;
  }

  /// Maps resolution width to a bitrate cap for the video sender.
  static int _resWidthToBitrate(int width) {
    if (width <= 0) return 0;        // Auto — let WebRTC congestion control decide
    if (width <= 1280) return 5000000;  // 720p  → 5 Mbps
    if (width <= 1920) return 12000000; // 1080p → 12 Mbps
    return 20000000;                    // 1440p → 20 Mbps
  }

  Widget _buildQualityChips({
    required List<int> options,
    required List<String> labels,
    required int selected,
    required ValueChanged<int> onSelect,
  }) {
    return Wrap(
      spacing: DesignTokens.spacing8,
      children: List.generate(options.length, (i) {
        final active = options[i] == selected;
        return GestureDetector(
          onTap: () => onSelect(options[i]),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacing14, vertical: DesignTokens.spacing8),
            decoration: BoxDecoration(
              color: active ? AppTheme.primary : AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
            ),
            child: Text(labels[i],
              style: GoogleFonts.inter(
                color: active ? Colors.white : AppTheme.textSecondary,
                fontSize: DesignTokens.fontMd,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
          ),
        );
      }),
    );
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    _signaling?.localStream?.getAudioTracks().forEach((t) => t.enabled = !_isMuted);
  }

  Future<void> _toggleCamera() async {
    if (_isScreenSharing) return;

    if (_isCameraOff) {
      // Turn camera ON
      if (_videoSender?.track != null && _videoSender!.track!.kind == 'video') {
        // Existing video track — just enable it
        _videoSender!.track!.enabled = true;
        _localRenderer.srcObject = _cameraStream;
        setState(() => _isCameraOff = false);
        // Renegotiate so the remote side activates its video receiver
        unawaited(_signaling?.renegotiate());
      } else {
        // No video track (transceiver or audio-only) — get camera via getUserMedia
        try {
          final videoStream = await navigator.mediaDevices.getUserMedia({
            'audio': false,
            'video': {'facingMode': _isFrontCamera ? 'user' : 'environment'},
          });
          final videoTracks = videoStream.getVideoTracks();
          if (videoTracks.isEmpty) {
            debugPrint('[CallScreen] getUserMedia returned no video tracks');
            return;
          }
          final videoTrack = videoTracks.first;
          if (_videoSender != null) {
            await _videoSender!.replaceTrack(videoTrack);
          } else {
            final pc = _signaling?.peerConnection;
            if (pc == null) return;
            _videoSender = await pc.addTrack(videoTrack, videoStream);
          }
          _cameraStream = videoStream;
          _localRenderer.srcObject = videoStream;
          setState(() => _isCameraOff = false);
          unawaited(_signaling?.renegotiate());
        } catch (e) {
          debugPrint('[CallScreen] Failed to enable camera: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('Camera unavailable — may be in use by another app'),
              backgroundColor: Colors.red.shade700,
              duration: const Duration(seconds: 3),
            ));
          }
        }
      }
    } else {
      // Turn camera OFF
      if (_videoSender?.track != null) {
        _videoSender!.track!.enabled = false;
      }
      _localRenderer.srcObject = null;
      setState(() => _isCameraOff = true);
      unawaited(_signaling?.renegotiate());
    }
  }

  Future<void> _flipCamera() async {
    final track = _videoSender?.track;
    if (track == null || track.kind != 'video') return;
    try {
      await Helper.switchCamera(track);
      setState(() => _isFrontCamera = !_isFrontCamera);
    } catch (e) {
      debugPrint('[CallScreen] switchCamera failed: $e');
    }
  }

  void _hangUp({bool remoteInitiated = false}) {
    if (_disposed) return;
    _disposed = true;
    setPulseCallActive(false);
    _durationTimer?.cancel();
    _hideControlsTimer?.cancel();
    _mediaWatchdog?.cancel();
    _disconnectTimer?.cancel();
    _secondaryWatchdog?.cancel();
    _signaling?.hangUp(notify: !remoteInitiated);
    _sfuService?.hangUp();
    ActiveCallService.instance.endCall();
    unawaited(_saveCallRecord());
    _disposeRenderers();
    if (mounted) Navigator.pop(context);
  }

  void _disposeRenderers() {
    try { _localRenderer.srcObject = null; } catch (_) {}
    try { _remoteRenderer.srcObject = null; } catch (_) {}
    try { _localRenderer.dispose(); } catch (_) {}
    try { _remoteRenderer.dispose(); } catch (_) {}
    // Release camera stream (separate from localStream/screenShareStream)
    final cs = _cameraStream;
    _cameraStream = null;
    if (cs != null) {
      for (final t in cs.getTracks()) { try { t.stop(); } catch (_) {} }
      cs.dispose().catchError((_) {});
    }
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _callDuration += const Duration(seconds: 1));
    });
  }

  void _resetHideControlsTimer() {
    _hideControlsTimer?.cancel();
    if (!_showControls) setState(() => _showControls = true);
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _remoteRenderer.srcObject != null) {
        setState(() => _showControls = false);
      }
    });
  }

  @override
  void dispose() {
    if (!_disposed) {
      _disposed = true;
      setPulseCallActive(false);
      _durationTimer?.cancel();
      _hideControlsTimer?.cancel();
      _mediaWatchdog?.cancel();
      _disconnectTimer?.cancel();
      _secondaryWatchdog?.cancel();
      _signaling?.hangUp();
      _sfuService?.hangUp();
    }
    // Always dispose renderers — even when minimized (_disposed=true) the
    // Flutter platform-channel renderers must be released to avoid leaks.
    _disposeRenderers();
    super.dispose();
  }

  // ── Status helpers ─────────────────────────────────────────────────────────

  String _statusLabel(BuildContext context) {
    final l = context.l10n;
    if (_usingSfu) {
      return 'Server relay ${_formatDuration(_callDuration)}';
    }
    if (_usingSecondary) {
      return l.callTorBackup(_formatDuration(_callDuration));
    }
    if (_sfuAttempted && !_usingSfu) return 'Connecting via server...';
    if (_isRetrying) return l.callSwitchingRelay;
    switch (_iceState) {
      case RTCIceConnectionState.RTCIceConnectionStateNew:
      case RTCIceConnectionState.RTCIceConnectionStateChecking:
        return _currentProfile.isRestricted ? l.callConnectingRelay : l.callConnecting;
      case RTCIceConnectionState.RTCIceConnectionStateConnected:
      case RTCIceConnectionState.RTCIceConnectionStateCompleted:
        return _formatDuration(_callDuration);
      case RTCIceConnectionState.RTCIceConnectionStateFailed:
        return l.callConnectionFailed;
      case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
        return l.callReconnecting;
      case RTCIceConnectionState.RTCIceConnectionStateClosed:
        return l.callEnded;
      default:
        return l.callConnecting;
    }
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  bool get _isConnected =>
      _usingSfu ||
      _usingSecondary ||
      _iceState == RTCIceConnectionState.RTCIceConnectionStateConnected ||
      _iceState == RTCIceConnectionState.RTCIceConnectionStateCompleted;

  // ── Build ──────────────────────────────────────────────────────────────────

  Widget _buildLoading() => Scaffold(
    backgroundColor: Colors.black,
    body: Builder(builder: (context) => Center(
      child: _initError != null
        ? Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: DesignTokens.spacing48),
            SizedBox(height: DesignTokens.spacing16),
            Text(context.l10n.callConnectionFailed,
              style: GoogleFonts.inter(color: Colors.redAccent, fontSize: DesignTokens.fontInput, fontWeight: FontWeight.w600)),
            SizedBox(height: DesignTokens.spacing8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacing32),
              child: Text(_initError!,
                style: GoogleFonts.inter(color: Colors.white38, fontSize: DesignTokens.fontBody),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
            ),
            SizedBox(height: DesignTokens.spacing24),
            Semantics(
              label: context.l10n.callClose,
              button: true,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: const StadiumBorder(),
                ),
                icon: const Icon(Icons.call_end_rounded, color: Colors.white, size: 18),
                label: Text(context.l10n.callClose,
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ])
        : Column(mainAxisSize: MainAxisSize.min, children: [
            CircularProgressIndicator(color: Colors.white54, strokeWidth: DesignTokens.spacing2),
            SizedBox(height: DesignTokens.spacing16),
            Text(context.l10n.callInitializing,
              style: GoogleFonts.inter(color: Colors.white54, fontSize: DesignTokens.fontMd)),
          ]),
    )),
  );

  @override
  Widget build(BuildContext context) {
    if (!_ready) return _buildLoading();

    final hasRemoteVideo = _remoteRenderer.srcObject != null &&
        (_remoteRenderer.srcObject!.getVideoTracks().isNotEmpty);
    final hasLocalVideo  = _localRenderer.srcObject != null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _minimize();
      },
      child: Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
            children: [
              // ── Background / Remote ──────────────────────────────────────
              hasRemoteVideo
                  ? Positioned.fill(
                      child: Container(
                        color: Colors.black,
                        child: RTCVideoView(
                          _remoteRenderer,
                          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                        ),
                      ),
                    )
                  : _buildAudioBackground(),
              // Transparent overlay so taps on RTCVideoView (PlatformView)
              // still reach our controls-reveal handler on Android.
              if (hasRemoteVideo)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _resetHideControlsTimer,
                    child: const SizedBox.expand(),
                  ),
                ),

              // ── Local video (PiP) ────────────────────────────────────────
              if (hasLocalVideo)
                Positioned(
                  right: DesignTokens.spacing16,
                  top: 60,
                  child: Container(
                    width: 110,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                      border: Border.all(
                        color: _isScreenSharing ? Colors.blueAccent : AppTheme.primary,
                        width: DesignTokens.spacing2,
                      ),
                      boxShadow: [BoxShadow(color: Colors.black38, blurRadius: DesignTokens.spacing10)],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                      child: RTCVideoView(
                        _localRenderer,
                        mirror: !_isScreenSharing,
                        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                    ),
                  ).animate().scale(delay: 300.ms),
                ),

              // ── Restricted-mode banner ───────────────────────────────────
              if (_currentProfile.isRestricted || _isRetrying || _usingSecondary || _usingSfu || _sfuAttempted ||
                  (_autoRetried && _iceState == RTCIceConnectionState.RTCIceConnectionStateFailed))
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildRestrictedBanner(),
                ),

              // ── Top bar ──────────────────────────────────────────────────
              Positioned(
                top: (_currentProfile.isRestricted || _isRetrying || _usingSecondary || _usingSfu || _sfuAttempted) ? 28 : 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _showControls || !hasRemoteVideo ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  child: _buildTopBar(),
                ),
              ),

              // ── Bottom controls ──────────────────────────────────────────
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: AnimatedOpacity(
                  opacity: _showControls || !hasRemoteVideo ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  child: _buildControlBar(),
                ),
              ),
            ],
          ),
        ),
    )); // Scaffold + PopScope
  }

  // ── Restricted-mode banner ─────────────────────────────────────────────────

  Widget _buildRestrictedBanner() {
    final IconData bannerIcon;
    final Color bannerColor;
    final String bannerText;

    final l = context.l10n;
    if (_usingSfu) {
      bannerIcon  = Icons.dns_rounded;
      bannerColor = Colors.teal.withValues(alpha: DesignTokens.opacityFull);
      bannerText  = 'Server relay active';
    } else if (_sfuAttempted && !_usingSfu) {
      bannerIcon  = Icons.dns_rounded;
      bannerColor = Colors.orange.withValues(alpha: DesignTokens.opacityFull);
      bannerText  = 'Connecting via server...';
    } else if (_usingSecondary) {
      bannerIcon  = Icons.security_rounded;
      bannerColor = _secondaryDegraded
          ? Colors.orange.withValues(alpha: DesignTokens.opacityFull)
          : Colors.teal.withValues(alpha: DesignTokens.opacityFull);
      bannerText  = l.callTorBackupBanner;
    } else if (_isRetrying) {
      bannerIcon  = Icons.sync_rounded;
      bannerColor = Colors.orange.withValues(alpha: DesignTokens.opacityFull);
      bannerText  = l.callDirectFailed;
    } else if (_autoRetried &&
        _iceState == RTCIceConnectionState.RTCIceConnectionStateFailed) {
      bannerIcon  = Icons.warning_amber_rounded;
      bannerColor = AppTheme.destructive.withValues(alpha: DesignTokens.opacityFull);
      bannerText  = l.callTurnUnreachable;
    } else {
      bannerIcon  = Icons.shield_rounded;
      bannerColor = Colors.blueGrey.withValues(alpha: DesignTokens.opacityFull);
      bannerText  = l.callRelayMode;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacing12, vertical: 5),
      color: bannerColor,
      child: Row(children: [
        Icon(bannerIcon, color: Colors.white, size: 14),
        SizedBox(width: DesignTokens.spacing6),
        Expanded(
          child: Text(
            bannerText,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: DesignTokens.fontSm,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ]),
    );
  }

  // ── Audio background ───────────────────────────────────────────────────────

  Widget _buildAudioBackground() {
    final name    = widget.contact.name;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final hue     = (name.codeUnitAt(0) * 17 + name.length * 31) % 360;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            HSLColor.fromAHSL(1, hue.toDouble(), 0.4, 0.2).toColor(),
            Colors.black,
          ],
        ),
      ),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Stack(alignment: Alignment.center, children: [
            if (!_isConnected)
              Container(
                width: 140, height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: HSLColor.fromAHSL(1, hue.toDouble(), 0.5, 0.3)
                      .toColor()
                      .withValues(alpha: DesignTokens.opacityMedium),
                ),
              ).animate(onPlay: (c) => c.repeat()).scale(
                begin: const Offset(1, 1),
                end:   const Offset(1.3, 1.3),
                duration: 1200.ms,
                curve: Curves.easeInOut,
              ),
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    HSLColor.fromAHSL(1, hue.toDouble(), 0.55, 0.42).toColor(),
                    HSLColor.fromAHSL(1, hue.toDouble(), 0.50, 0.30).toColor(),
                  ],
                  begin: Alignment.topLeft,
                  end:   Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ]),
          SizedBox(height: DesignTokens.spacing24),
          Text(
            name,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: DesignTokens.fontDisplayLg,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing8),
          Text(
            _statusLabel(context),
            style: GoogleFonts.inter(color: Colors.white70, fontSize: DesignTokens.fontInput),
          ).animate(onPlay: (c) {
            if (!_isConnected) c.repeat(reverse: true);
          }).fade(duration: 900.ms, begin: 0.5),
        ]),
      ),
    );
  }

  // ── Top bar ────────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(DesignTokens.spacing8, DesignTokens.spacing8, DesignTokens.spacing16, DesignTokens.spacing8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end:   Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: DesignTokens.opacityHeavy), Colors.transparent],
        ),
      ),
      child: Row(children: [
        Semantics(
          label: context.l10n.back,
          button: true,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            tooltip: context.l10n.back,
            onPressed: _minimize,
          ),
        ),
        SizedBox(width: DesignTokens.spacing4),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              widget.contact.name,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: DesignTokens.fontTitle,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              _statusLabel(context),
              style: GoogleFonts.inter(color: Colors.white70, fontSize: DesignTokens.fontMd),
            ),
          ]),
        ),
        if (_isConnected)
          Container(
            padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacing10, vertical: DesignTokens.spacing4),
            decoration: BoxDecoration(
              color:  Colors.green.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 7, height: 7,
                decoration: const BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                context.l10n.callLive,
                style: GoogleFonts.inter(
                  color: Colors.greenAccent,
                  fontSize: DesignTokens.fontBody,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ]),
          ),
      ]),
    );
  }

  // ── Control bar ────────────────────────────────────────────────────────────

  Widget _buildControlBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(DesignTokens.spacing16, DesignTokens.spacing20, DesignTokens.spacing16, DesignTokens.spacing32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end:   Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.75), Colors.transparent],
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: EdgeInsets.only(bottom: DesignTokens.spacing16),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _buildSmallButton(
              icon:        _isScreenSharing ? Icons.stop_screen_share_rounded : Icons.screen_share_rounded,
              label:       _isScreenSharing ? context.l10n.callStopShare : context.l10n.callShareScreen,
              active:      _isScreenSharing,
              activeColor: Colors.blueAccent,
              onTap:       _toggleScreenShare,
            ),
            SizedBox(width: DesignTokens.spacing24),
            _buildSmallButton(
              icon:  _isCameraOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
              label: _isCameraOff ? context.l10n.callCameraOff : context.l10n.callCameraOn,
              active: !_isCameraOff,
              onTap:  _toggleCamera,
            ),
            if (!_isCameraOff) ...[
              SizedBox(width: DesignTokens.spacing24),
              _buildSmallButton(
                icon:  Icons.flip_camera_ios_rounded,
                label: _isFrontCamera ? 'Flip' : 'Front',
                onTap: _flipCamera,
              ),
            ],
          ]),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _buildControlButton(
            icon:      _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
            label:     _isMuted ? context.l10n.callUnmute : context.l10n.callMute,
            color:     _isMuted ? Colors.white : Colors.white24,
            iconColor: _isMuted ? Colors.black : Colors.white,
            onPressed: _toggleMute,
          ),
          Semantics(
            label: context.l10n.callEndCall,
            button: true,
            child: GestureDetector(
              onTap: _hangUp,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 68, height: 68,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withValues(alpha: 0.5),
                        blurRadius: DesignTokens.spacing16,
                        offset: Offset(0, DesignTokens.spacing4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 30),
                ).animate().scale(),
                SizedBox(height: DesignTokens.spacing6),
                Text(context.l10n.callEnd, style: GoogleFonts.inter(color: Colors.white70, fontSize: DesignTokens.fontSm)),
              ]),
            ),
          ),
          _buildControlButton(
            icon:      Icons.volume_up_rounded,
            label:     context.l10n.callSpeaker,
            color:     Colors.white24,
            iconColor: Colors.white,
            onPressed: () {},
          ),
        ]),
      ]),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: onPressed,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: DesignTokens.iconLg),
          ).animate().scale(),
          SizedBox(height: DesignTokens.spacing6),
          Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: DesignTokens.fontSm)),
        ]),
      ),
    );
  }

  Widget _buildSmallButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = false,
    Color activeColor = Colors.white,
  }) {
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: active ? activeColor.withValues(alpha: 0.2) : Colors.white12,
              shape: BoxShape.circle,
              border: active ? Border.all(color: activeColor, width: 1.5) : null,
            ),
            child: Icon(icon, color: active ? activeColor : Colors.white, size: DesignTokens.iconMd),
          ),
          SizedBox(height: DesignTokens.spacing4),
          Text(label, style: GoogleFonts.inter(color: Colors.white60, fontSize: DesignTokens.fontXs)),
        ]),
      ),
    );
  }
}
