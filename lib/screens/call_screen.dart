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
import '../models/contact.dart';
import '../models/message.dart';
import '../l10n/l10n_ext.dart';
import '../controllers/chat_controller.dart';
import '../utils/platform_utils.dart';
import '../adapters/pulse_adapter.dart' show setPulseCallActive;
import '../widgets/call/call_action_button.dart';
import '../widgets/call/call_background.dart';
import '../widgets/call/call_local_pip.dart';
import '../widgets/call/call_phase.dart';
import '../widgets/call/call_status_overlay.dart';
import '../widgets/call/call_top_bar.dart';

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
  /// Previous call's cleanup future — new calls wait for this before init.
  static Future<void>? _pendingCleanup;

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

  // Avatar bytes for the contact, loaded asynchronously from local storage.
  // Used by CallBackground (blurred wash) and CallStatusOverlay (160dp).
  Uint8List? _avatarBytes;

  // Set true when _hangUp() begins; the Scaffold fades to black before pop().
  bool _endedFade = false;

  @override
  void initState() {
    super.initState();
    setPulseCallActive(true);
    _loadAvatar();
    if (widget.existingSignaling != null) {
      _restoreFromMinimized();
    } else {
      _initWebRTC();
    }
  }

  Future<void> _loadAvatar() async {
    try {
      final raw = await LocalStorageService().loadAvatar(widget.contact.id);
      if (raw == null || raw.isEmpty) return;
      final bytes = base64Decode(raw);
      if (mounted) setState(() => _avatarBytes = bytes);
    } catch (e) {
      debugPrint('[CallScreen] _loadAvatar failed: $e');
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
    };

    _signaling!.onRemoteHangUp = () {
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
      // Wait for previous call's cleanup to finish (PC close, stream dispose).
      // Without this, GStreamer pipeline teardown from the old call blocks
      // the event loop during the new call's setup → freeze + broken audio.
      if (_pendingCleanup != null) {
        await _pendingCleanup!.timeout(const Duration(seconds: 5),
            onTimeout: () {});
        _pendingCleanup = null;
        // Extra delay for GStreamer to fully release audio/video pipelines
        // after peerConnection.close() returns — close() completes before
        // native teardown finishes on Linux.
        await Future.delayed(const Duration(seconds: 2));
      }

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

      _signaling = SignalingService(
        contact: widget.contact,
        myId:    widget.myId,
        isCaller: widget.isCaller,
        selfDatabaseId: ChatController().selfId,
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
      };

      _signaling!.onRemoteHangUp = () {
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

      await _signaling!.init(profile: profile);
      if (_disposed) { unawaited(_signaling!.hangUp()); return; }

      await _openUserMedia();
      if (_disposed) { unawaited(_signaling!.hangUp()); return; }

      if (widget.isCaller) {
        // Start live signal listener (answer will arrive after offer is sent)
        _signaling!.startListening();
        await _signaling!.createOffer();
      } else {
        // Callee: replay cached offer/candidates AFTER tracks are on the PC,
        // so the answer SDP includes our audio tracks.
        // Start live listener AFTER replay to avoid processing signals twice.
        await _signaling!.replayPendingSignals();
        _signaling!.startListening();
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
          // Never expose internal exception text to the UI
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
  }

  // ── SFU relay fallback (server-mediated when P2P is blocked) ────────────────

  /// Caller side: create SFU room and invite peer.
  void _sfuRelayFallback() {
    if (_disposed || _sfuAttempted) return;
    _sfuAttempted = true;
    // Cancel any pending auto-hangup
    _disconnectTimer?.cancel();

    final contact = widget.contact;
    _sfuService = SfuSignalingService(group: contact, myId: widget.myId);

    _sfuService!.onRoomReady = () async {
      if (_disposed || _sfuService == null) return;
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
            if (_silentTicks >= 2 && _secondaryReady && !_usingSecondary) {
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
            if (_secondarySilentTicks >= 2 && mounted && !_secondaryRestarting) {
              if (!_secondaryDegraded) setState(() => _secondaryDegraded = true);
              // Attempt to restart the Tor secondary path (new Tor circuit).
              // Reset counters so we can detect recovery or a second failure.
              _secondarySilentTicks = 0;
              _secondaryLastPkts    = -1;
              _secondaryRestarting  = true;
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
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(context.l10n.callNoScreenSources),
                duration: const Duration(seconds: 2),
              ));
            }
            return;
          }
          final screenSources = sources.where((s) => s.type == SourceType.Screen).toList();
          final screenSource = screenSources.isNotEmpty ? screenSources.first : sources.first;
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
              ? context.l10n.callScreenShareRequiresPermission
              : context.l10n.callScreenShareUnavailable),
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
          Text(context.l10n.callScreenShareQuality,
            style: GoogleFonts.inter(color: AppTheme.textPrimary,
              fontSize: DesignTokens.fontXl, fontWeight: FontWeight.w700)),
          SizedBox(height: DesignTokens.spacing16),
          Text(context.l10n.callFrameRate, style: GoogleFonts.inter(
            color: AppTheme.textSecondary, fontSize: DesignTokens.fontBody)),
          SizedBox(height: DesignTokens.spacing8),
          _buildQualityChips(
            options: const [15, 30, 60],
            labels: const ['15 fps', '30 fps', '60 fps'],
            selected: selFps,
            onSelect: (v) => setS(() => selFps = v),
          ),
          SizedBox(height: DesignTokens.spacing16),
          Text(context.l10n.callResolution, style: GoogleFonts.inter(
            color: AppTheme.textSecondary, fontSize: DesignTokens.fontBody)),
          SizedBox(height: DesignTokens.spacing8),
          _buildQualityChips(
            options: const [1280, 1920, 2560, 0],
            labels: const ['720p', '1080p', '1440p', 'Auto'],
            selected: selResWidth,
            onSelect: (v) => setS(() => selResWidth = v),
          ),
          SizedBox(height: DesignTokens.spacing6),
          Text(context.l10n.callAutoResolution,
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
              child: Text(context.l10n.callStartSharing,
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
              content: Text(context.l10n.callCameraUnavailable),
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
    // Fade-to-background animation before pop, so the user sees a smooth
    // dismissal rather than the screen vanishing instantly.
    if (mounted && !_endedFade) setState(() => _endedFade = true);

    _disposed = true;
    setPulseCallActive(false);
    _durationTimer?.cancel();
    _hideControlsTimer?.cancel();
    _mediaWatchdog?.cancel();
    _disconnectTimer?.cancel();
    _secondaryWatchdog?.cancel();
    // Store cleanup future so next call can wait for it.
    // hangUp() closes PC + disposes streams — can take seconds on GStreamer.
    final sig = _signaling;
    _signaling = null;
    if (sig != null) {
      _pendingCleanup = sig.hangUp(notify: !remoteInitiated);
    }
    _sfuService?.hangUp();
    ActiveCallService.instance.endCall();
    unawaited(_saveCallRecord());
    _disposeRenderers();
    // Defer pop so the AnimatedOpacity has time to fade.
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) Navigator.pop(context);
    });
  }

  void _disposeRenderers() {
    try { _localRenderer.srcObject = null; } catch (_) {}
    try { _remoteRenderer.srcObject = null; } catch (_) {}
    // dispose() returns Future — try/catch won't catch async errors.
    // Use .catchError to prevent [FATAL] Unhandled exceptions.
    _localRenderer.dispose().catchError((_) {});
    _remoteRenderer.dispose().catchError((_) {});
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
      // CRITICAL: only auto-hide controls during fullscreen video.
      // The previous condition checked `_remoteRenderer.srcObject != null`,
      // which is true for audio-only streams too — that hid the action bar
      // mid-call, leaving the user staring at a blank gradient.
      if (mounted && _phase == CallPhase.connectedVideo) {
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
      final sig = _signaling;
      _signaling = null;
      if (sig != null) {
        _pendingCleanup = sig.hangUp();
      }
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

  /// Whether the *remote* stream is actually sending us live video right
  /// now. Checking `getVideoTracks().isNotEmpty` alone is wrong on
  /// Android: flutter_webrtc creates recv-only `MediaStreamTrack`
  /// placeholders for every transceiver direction, so an audio-only call
  /// reports a video track that is `enabled == false` and never carries
  /// a frame. Counting it as "video mode" hides the avatar/name/timer
  /// overlay and leaves the user staring at a gradient — exact symptom
  /// the user reported on Android while Linux (which doesn't fabricate
  /// such placeholders) renders the overlay correctly.
  bool get _hasRemoteVideo {
    final src = _remoteRenderer.srcObject;
    if (src == null) return false;
    for (final t in src.getVideoTracks()) {
      if (t.enabled) return true;
    }
    return false;
  }

  /// Whether we have a usable local video track to show in the PiP.
  /// (Camera off + no screen share means nothing to render — track
  /// may exist but be disabled, in which case srcObject is null.)
  bool get _hasLocalVideo => _localRenderer.srcObject != null;

  /// Computed call lifecycle phase used by the new UI widgets.
  CallPhase get _phase {
    if (_endedFade ||
        _iceState == RTCIceConnectionState.RTCIceConnectionStateClosed) {
      return CallPhase.ended;
    }
    if (_isConnected) {
      return _hasRemoteVideo
          ? CallPhase.connectedVideo
          : CallPhase.connectedAudio;
    }
    // Reconnecting: ICE was up at some point (we have a non-zero duration)
    // but went Disconnected/Failed.
    if (_callDuration > Duration.zero &&
        (_iceState ==
                RTCIceConnectionState.RTCIceConnectionStateDisconnected ||
            _iceState == RTCIceConnectionState.RTCIceConnectionStateFailed ||
            _isRetrying ||
            (_sfuAttempted && !_usingSfu))) {
      return CallPhase.reconnecting;
    }
    if (_iceState == RTCIceConnectionState.RTCIceConnectionStateChecking) {
      return CallPhase.connecting;
    }
    // Initial state: New / pre-Checking → caller is dialing, callee is ringing.
    return widget.isCaller ? CallPhase.dialing : CallPhase.ringing;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  Widget _buildLoading() => Scaffold(
    backgroundColor: AppTheme.background,
    body: Builder(builder: (context) => Center(
      child: _initError != null
        ? Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.error_outline_rounded, color: AppTheme.destructive, size: DesignTokens.spacing48),
            SizedBox(height: DesignTokens.spacing16),
            Text(context.l10n.callConnectionFailed,
              style: GoogleFonts.inter(color: AppTheme.destructive, fontSize: DesignTokens.fontInput, fontWeight: FontWeight.w600)),
            SizedBox(height: DesignTokens.spacing8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacing32),
              child: Text(_initError!,
                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontBody),
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
                  backgroundColor: AppTheme.destructive,
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
            CircularProgressIndicator(color: AppTheme.primary, strokeWidth: DesignTokens.spacing2),
            SizedBox(height: DesignTokens.spacing16),
            Text(context.l10n.callInitializing,
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd)),
          ]),
    )),
  );

  @override
  Widget build(BuildContext context) {
    if (!_ready) return _buildLoading();

    final phase = _phase;
    final hasRemoteVideo = phase == CallPhase.connectedVideo;
    final hasLocalVideo  = _hasLocalVideo;
    // Controls always shown unless we're in fullscreen video and the user has
    // been idle for >4s. Action bar must NEVER auto-hide on audio calls.
    final controlsVisible = _showControls || phase != CallPhase.connectedVideo;
    final showRestrictedBanner = _currentProfile.isRestricted ||
        _isRetrying ||
        _usingSecondary ||
        _usingSfu ||
        _sfuAttempted ||
        (_autoRetried &&
            _iceState == RTCIceConnectionState.RTCIceConnectionStateFailed);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _minimize();
      },
      child: AnimatedOpacity(
        opacity: _endedFade ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 220),
        child: Scaffold(
          backgroundColor: AppTheme.background,
          body: SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                // Tapping is meaningful only when we have a fullscreen video
                // to reveal/hide chrome over.
                if (hasRemoteVideo) _resetHideControlsTimer();
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Background ─ blurred avatar wash OR full RTCVideoView.
                  CallBackground(
                    contact: widget.contact,
                    phase: phase,
                    remoteRenderer: _remoteRenderer,
                    avatarBytes: _avatarBytes,
                  ),

                  // 2. Local PiP — floating draggable.
                  CallLocalPiP(
                    renderer: _localRenderer,
                    visible: hasLocalVideo,
                    mirror: !_isScreenSharing,
                    borderColor: _isScreenSharing
                        ? AppTheme.info
                        : AppTheme.primary,
                  ),

                  // 3. Status overlay (avatar + name + status). Only shown
                  //    when not in fullscreen video.
                  if (!hasRemoteVideo)
                    Positioned.fill(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: showRestrictedBanner ? 80 : 60,
                          bottom: 220,
                        ),
                        child: CallStatusOverlay(
                          contact: widget.contact,
                          phase: phase,
                          statusLabel: _statusLabel(context),
                          avatarBytes: _avatarBytes,
                        ),
                      ),
                    ),

                  // 4. Top bar (minimize + name + status pill).
                  Positioned(
                    top: showRestrictedBanner ? 28 : 0,
                    left: 0,
                    right: 0,
                    child: AnimatedOpacity(
                      opacity: controlsVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 180),
                      child: CallTopBar(
                        contact: widget.contact,
                        phase: phase,
                        statusLabel: _statusLabel(context),
                        onMinimize: _minimize,
                      ),
                    ),
                  ),

                  // 5. Bottom action bar.
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedOpacity(
                      opacity: controlsVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 180),
                      child: _buildActionBar(),
                    ),
                  ),

                  // 6. Restricted-mode / Tor / SFU banner — keep on top so
                  //    the user always sees transport changes.
                  if (showRestrictedBanner)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: AnimatedOpacity(
                        opacity: controlsVisible ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 180),
                        child: _buildRestrictedBanner(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Bottom action bar (new, replaces _buildControlBar) ────────────────────

  Widget _buildActionBar() {
    final l = context.l10n;
    final canFlip = !_isCameraOff && !_isScreenSharing;

    return Container(
      padding: EdgeInsets.fromLTRB(
        DesignTokens.spacing16,
        DesignTokens.spacing24,
        DesignTokens.spacing16,
        DesignTokens.spacing32,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            AppTheme.background.withValues(alpha: 0.85),
            AppTheme.background.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CallActionButton(
              icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
              label: _isMuted ? l.callUnmute : l.callMute,
              active: _isMuted,
              activeColor: AppTheme.warning,
              onTap: _toggleMute,
            ),
            CallActionButton(
              icon: _isCameraOff
                  ? Icons.videocam_off_rounded
                  : Icons.videocam_rounded,
              label: _isCameraOff ? l.callCameraOff : l.callCameraOn,
              active: !_isCameraOff,
              onTap: _isScreenSharing ? null : _toggleCamera,
            ),
            CallActionButton(
              icon: Icons.call_end_rounded,
              label: l.callEnd,
              endCall: true,
              size: 64,
              onTap: _hangUp,
            ),
            CallActionButton(
              icon: _isScreenSharing
                  ? Icons.stop_screen_share_rounded
                  : Icons.screen_share_rounded,
              label: _isScreenSharing ? l.callStopShare : l.callShareScreen,
              active: _isScreenSharing,
              activeColor: AppTheme.info,
              onTap: _toggleScreenShare,
            ),
            CallActionButton(
              icon: Icons.flip_camera_ios_rounded,
              label: _isFrontCamera ? 'Flip' : 'Front',
              onTap: canFlip ? _flipCamera : null,
            ),
          ],
        ),
      ),
    );
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

}
