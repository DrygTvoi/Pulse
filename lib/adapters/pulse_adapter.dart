import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart' as hash_lib;
import 'package:flutter/foundation.dart';
import 'package:convert/convert.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cryptography/cryptography.dart' as crypto_lib;
import '../models/message.dart';
import '../services/tor_service.dart' as tor;
import '../services/utls_service.dart';
import 'inbox_manager.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Pulse Adapter — Signal Protocol over self-hosted Pulse relay
///
/// Wire protocol: JSON over WebSocket.
///
/// Address format:  ed25519_pubkey_hex@https://server-ip:port
///   (64-char hex public key @ https:// server URL)
///
/// Authentication: Ed25519 challenge-response.
///   1. Server sends auth_challenge {nonce, timestamp}
///   2. Client signs "pulse-auth-v1:{nonce}:{timestamp}" with Ed25519
///   3. Client sends auth_response {pubkey, signature, invite}
///   4. Server sends auth_ok {turn_url, turn_user, turn_pass}
///
/// Message types:
///   message  → Chat message (payload = Signal-encrypted)
///   signal   → WebRTC + system signals
///   stored   → Batch of stored messages (fetched on connect)
///   ack      → Delivery confirmation
///   keys     → Signal key bundle response
///   error    → Server error
/// ─────────────────────────────────────────────────────────────────────────────

// ── Ed25519 helpers ─────────────────────────────────────────────────────────

/// Derive Ed25519 public key hex string from a 32-byte seed.
Future<String> ed25519PubkeyFromSeed(Uint8List seed) async {
  final ed = crypto_lib.Ed25519();
  final kp = await ed.newKeyPairFromSeed(seed.toList());
  final pub = await kp.extractPublicKey();
  return hex.encode(pub.bytes);
}

/// Sign a UTF-8 message string with Ed25519 using a 32-byte seed.
/// Returns the signature as a hex string.
Future<String> _ed25519Sign(Uint8List seed, String message) async {
  final ed = crypto_lib.Ed25519();
  final kp = await ed.newKeyPairFromSeed(seed.toList());
  final msgBytes = utf8.encode(message);
  final sig = await ed.sign(msgBytes, keyPair: kp);
  return hex.encode(sig.bytes);
}

// ── Envelope helpers ─────────────────────────────────────────────────────────

/// Unwrap server envelope: {"type":"...","payload":{...}} → extract inner payload.
Map<String, dynamic> _envPayload(Map<String, dynamic> env) {
  final p = env['payload'];
  if (p is Map<String, dynamic>) return p;
  if (p is String) {
    try { return jsonDecode(p) as Map<String, dynamic>; } catch (_) {}
  }
  return env;
}

/// Create an envelope for sending to the server.
String _makeEnvelope(String type, Map<String, dynamic> payload) {
  return jsonEncode({'type': type, 'payload': payload});
}

// ── Obfuscation helpers ─────────────────────────────────────────────────────

/// Bucket sizes for outgoing message padding (bytes).
const _kBucketSizes = [256, 1024, 4096, 16384, 65536];

/// Maximum random send jitter in milliseconds (client-side traffic decorrelation).
const _kSendJitterMaxMs = 50;

final _secureRng = Random.secure();

/// Pad a JSON string to the next bucket boundary by injecting a `_pad` field.
/// The server and recipient silently ignore `_pad`.
String _bucketPad(String json) {
  final len = utf8.encode(json).length;
  int target = _kBucketSizes.last;
  for (final b in _kBucketSizes) {
    if (len <= b) {
      target = b;
      break;
    }
  }
  if (len >= target) return json;

  // `,"_pad":""}` = 10 bytes overhead + padLen content
  const overhead = 10;
  final padLen = target - len - overhead;
  if (padLen <= 0) return json;

  final padBytes =
      List<int>.generate((padLen + 1) ~/ 2, (_) => _secureRng.nextInt(256));
  final padStr = hex.encode(padBytes).substring(0, padLen);

  // Insert `,"_pad":"..."` before the closing brace
  return '${json.substring(0, json.length - 1)},"_pad":"$padStr"}';
}

/// Small random delay for send-timing decorrelation.
Future<void> _sendJitter() async {
  if (_kSendJitterMaxMs <= 0) return;
  final ms = _secureRng.nextInt(_kSendJitterMaxMs);
  if (ms > 0) await Future<void>.delayed(Duration(milliseconds: ms));
}

// ── Reconnect delay tiers (same as Nostr adapter) ───────────────────────────

Duration _reconnectDelay(int failures) {
  if (failures <= 1) return const Duration(seconds: 5);
  if (failures <= 5) return const Duration(seconds: 30);
  return const Duration(minutes: 5);
}

// ── uTLS proxy helper for Pulse ──────────────────────────────────────────────

/// Circuit breaker timestamp — shared across Pulse reader/sender.
DateTime? _pulseUtlsFailedUntil;

/// Connect a WebSocket through the uTLS HTTP CONNECT proxy (Pulse variant).
/// Same bridge pattern as nostr_adapter but with [Pulse] log prefix and
/// separate circuit breaker so Nostr and Pulse don't cross-trip.
Future<WebSocketChannel> _connectPulseWebSocketViaUtls(
    String url, int proxyPort, {String? upstreamSocks5}) async {
  if (upstreamSocks5 == null &&
      _pulseUtlsFailedUntil != null &&
      DateTime.now().isBefore(_pulseUtlsFailedUntil!)) {
    throw StateError('Pulse uTLS circuit breaker open');
  }
  final uri = Uri.parse(url);
  final targetHost = uri.host;
  final targetPort =
      uri.hasPort ? uri.port : (uri.scheme == 'wss' ? 443 : 80);

  // Bind throw-away local bridge.
  final server = await ServerSocket.bind(
      InternetAddress.loopbackIPv4, 0,
      shared: false);
  final bridgePort = server.port;

  // Handle one inbound → tunnel through uTLS proxy.
  unawaited(server.first.then((client) async {
    unawaited(server.close());
    Socket? proxy;
    try {
      proxy = await Socket.connect(
          InternetAddress.loopbackIPv4, proxyPort,
          timeout: const Duration(seconds: 15));
      proxy.setOption(SocketOption.tcpNoDelay, true);
      client.setOption(SocketOption.tcpNoDelay, true);

      final rxBuf = <int>[];
      final clientBuf = <List<int>>[];
      final waiters = <Completer<void>>[];
      bool tunnelReady = false;

      proxy.listen(
        (data) {
          if (!tunnelReady) {
            rxBuf.addAll(data);
            for (final w in [...waiters]) {
              if (!w.isCompleted) w.complete();
            }
            waiters.removeWhere((c) => c.isCompleted);
          } else {
            try { client.add(data); } catch (_) {}
          }
        },
        onDone: () { try { client.close(); } catch (_) {} },
        onError: (Object _) { client.destroy(); proxy?.destroy(); },
        cancelOnError: true,
      );

      client.listen(
        (data) {
          if (!tunnelReady) {
            clientBuf.add(data);
          } else {
            try { proxy!.add(data); } catch (_) {}
          }
        },
        onDone: () { try { proxy?.close(); } catch (_) {} },
        onError: (Object _) { client.destroy(); proxy?.destroy(); },
        cancelOnError: true,
      );

      final socksHeader = upstreamSocks5 != null
          ? 'X-Upstream-Socks5: $upstreamSocks5\r\n'
          : '';
      proxy.write(
          'CONNECT $targetHost:$targetPort HTTP/1.1\r\n'
          'Host: $targetHost:$targetPort\r\n'
          '$socksHeader\r\n');
      await proxy.flush();

      final headerTimeout = upstreamSocks5 != null ? 45 : 10;
      Future<bool> readUntilEndOfHeaders() async {
        while (true) {
          for (int i = 0; i <= rxBuf.length - 4; i++) {
            if (rxBuf[i] == 13 && rxBuf[i + 1] == 10 &&
                rxBuf[i + 2] == 13 && rxBuf[i + 3] == 10) {
              final header = String.fromCharCodes(rxBuf.sublist(0, i));
              final ok = header.contains(' 200 ');
              rxBuf.removeRange(0, i + 4);
              return ok;
            }
          }
          final c = Completer<void>();
          waiters.add(c);
          await c.future;
        }
      }

      final ok = await readUntilEndOfHeaders()
          .timeout(Duration(seconds: headerTimeout), onTimeout: () => false);
      if (!ok) {
        debugPrint('[Pulse] uTLS CONNECT to $targetHost:$targetPort refused');
        if (upstreamSocks5 == null) {
          _pulseUtlsFailedUntil =
              DateTime.now().add(const Duration(minutes: 5));
        }
        client.destroy();
        proxy.destroy();
        return;
      }

      tunnelReady = true;
      if (rxBuf.isNotEmpty) {
        try { client.add(Uint8List.fromList(rxBuf)); } catch (_) {}
        rxBuf.clear();
      }
      for (final d in clientBuf) {
        try { proxy.add(d); } catch (_) {}
      }
    } catch (e) {
      debugPrint('[Pulse] uTLS bridge error: $e');
      _pulseUtlsFailedUntil = DateTime.now().add(const Duration(minutes: 5));
      client.destroy();
      proxy?.destroy();
    }
  }).catchError((_) {}));

  final httpClient = HttpClient();
  httpClient.connectionFactory = (uri2, proxyHost2, proxyPort2) async {
    final s = await Socket.connect(
        InternetAddress.loopbackIPv4, bridgePort,
        timeout: const Duration(seconds: 60));
    return ConnectionTask.fromSocket(Future.value(s), () => s.destroy());
  };

  final wsUri = Uri.parse(url);
  final normalizedUrl = (!wsUri.hasPort || wsUri.port == 0)
      ? '${wsUri.scheme}://${wsUri.host}:${wsUri.scheme == 'wss' ? 443 : 80}${wsUri.path}'
      : url;
  try {
    final ws = await WebSocket.connect(normalizedUrl, customClient: httpClient);
    ws.pingInterval = const Duration(seconds: 30);
    _pulseUtlsFailedUntil = null;
    return IOWebSocketChannel(ws);
  } catch (e) {
    _pulseUtlsFailedUntil = DateTime.now().add(const Duration(minutes: 5));
    httpClient.close(force: true);
    try { await server.close(); } catch (_) {}
    rethrow;
  }
}

/// Shared authenticated WebSocket so reader and sender don't fight.
/// The reader (long-lived loop) owns the connection; the sender borrows it.
class _PulseSharedWs {
  static WebSocketChannel? channel;
  static bool authenticated = false;
  static int protoVersion = 1;
  /// Shared keys completers — reader resolves, sender registers.
  static final pendingKeysCompleters = <String, Completer<Map<String, dynamic>?>>{};
}

// ── PulseInboxReader ────────────────────────────────────────────────────────

class PulseInboxReader implements InboxReader {
  Uint8List _seed = Uint8List(0);
  String _pubkeyHex = '';
  String _serverUrl = '';
  String _wsUrl = '';
  String _wsUrlV2 = '';
  String _invite = '';

  /// Protocol version negotiated with the server (1 or 2).
  int _protoVersion = 1;

  /// TLS cert SHA-256 fingerprint parsed from `#suffix` in serverUrl.
  String _certFingerprint = '';

  WebSocketChannel? _ws;
  final StreamController<List<Message>> _msgCtrl =
      StreamController<List<Message>>.broadcast();
  final StreamController<List<Map<String, dynamic>>> _sigCtrl =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final StreamController<bool> _healthCtrl =
      StreamController<bool>.broadcast();

  final Set<String> _seenIds = {};

  bool _loopStarted = false;
  bool _running = false;
  bool _isHealthy = true;
  int _consecutiveFailures = 0;
  static const _failureThreshold = 3;
  static const _maxConsecutiveFailures = 30;

  bool get circuitBroken => _circuitBroken;
  bool _circuitBroken = false;

  // Tor settings — loaded once in initializeReader
  bool _torEnabled = false;
  String _torHost = '127.0.0.1';
  int _torPort = 9050;

  // CF Worker relay proxy
  String _cfWorkerRelay = '';

  // Force-Tor mode: route all Pulse traffic through uTLS+Tor chain
  bool _forcePulseTor = false;

  @override
  Stream<bool> get healthChanges => _healthCtrl.stream;

  @override
  Future<void> initializeReader(String apiKey, String databaseId) async {
    // Parse apiKey JSON: {"privkey":"hex","serverUrl":"https://...","invite":"code"}
    try {
      final decoded = jsonDecode(apiKey) as Map<String, dynamic>;
      final privkeyHex = (decoded['privkey'] as String? ?? '').trim();
      _serverUrl = (decoded['serverUrl'] as String? ?? '').trim();
      _invite = (decoded['invite'] as String? ?? '').trim();

      if (privkeyHex.isNotEmpty) {
        _seed = Uint8List.fromList(hex.decode(privkeyHex));
        _pubkeyHex = await ed25519PubkeyFromSeed(_seed);
      }
    } catch (e) {
      debugPrint('[Pulse] Failed to parse apiKey JSON: $e');
      return;
    }

    // Parse cert fingerprint from URL fragment: https://host:port#sha256hex
    if (_serverUrl.contains('#')) {
      final parts = _serverUrl.split('#');
      _serverUrl = parts[0];
      _certFingerprint = parts[1].toLowerCase();
    }

    // Convert https:// → wss:// for WebSocket. Reject plaintext http://.
    if (_serverUrl.startsWith('https://')) {
      final hostPort = _serverUrl.substring('https://'.length);
      _wsUrl = 'wss://$hostPort/ws';
      _wsUrlV2 = 'wss://$hostPort/v2';
    } else {
      debugPrint('[Pulse] Rejected insecure or invalid server URL: $_serverUrl');
      return;
    }

    debugPrint('[Pulse] Initialized: pubkey=${_pubkeyHex.isNotEmpty ? '${_pubkeyHex.substring(0, 8)}...' : 'EMPTY'}, '
        'seed=${_seed.length}B, wsUrl=$_wsUrl, fp=${_certFingerprint.isNotEmpty ? '${_certFingerprint.substring(0, 8)}...' : 'none'}');

    // Load Tor + CF Worker + Force-Tor settings
    final prefs = await SharedPreferences.getInstance();
    _torEnabled = prefs.getBool('tor_enabled') ?? false;
    _torHost = prefs.getString('tor_host') ?? '127.0.0.1';
    _torPort = prefs.getInt('tor_port') ?? 9050;
    _cfWorkerRelay = prefs.getString('cf_worker_relay') ?? '';
    _forcePulseTor = prefs.getBool('pulse_force_tor') ?? false;
  }

  /// Reset connection: close WS, reload prefs, restart loop.
  Future<void> resetConnection() async {
    _running = false;
    _loopStarted = false;
    try { _ws?.sink.close(); } catch (_) {}
    _ws = null;
    final prefs = await SharedPreferences.getInstance();
    _torEnabled = prefs.getBool('tor_enabled') ?? false;
    _torHost = prefs.getString('tor_host') ?? '127.0.0.1';
    _torPort = prefs.getInt('tor_port') ?? 9050;
    _cfWorkerRelay = prefs.getString('cf_worker_relay') ?? '';
    _forcePulseTor = prefs.getBool('pulse_force_tor') ?? false;
    _consecutiveFailures = 0;
    _circuitBroken = false;
    _ensureLoop();
  }

  void _trackSeenId(String id) {
    if (_seenIds.length > 2000) {
      final evict = _seenIds.toList().sublist(0, 1000);
      _seenIds.removeAll(evict);
    }
    _seenIds.add(id);
  }

  void _ensureLoop() {
    if (_loopStarted) return;
    if (_seed.isEmpty || _wsUrl.isEmpty) {
      debugPrint('[Pulse] _ensureLoop aborted: seed=${_seed.length}B, wsUrl=${_wsUrl.isEmpty ? 'EMPTY' : _wsUrl}');
      return;
    }
    debugPrint('[Pulse] Starting connection loop → $_wsUrl');
    _loopStarted = true;
    _running = true;
    unawaited(_runLoop());
  }

  /// Build an HttpClient with cert-pinning if a fingerprint is configured.
  HttpClient _buildHttpClient() {
    final client = HttpClient();
    if (_certFingerprint.isNotEmpty) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        final der = cert.der;
        final fpBytes = hash_lib.sha256.convert(der).bytes;
        final fp = hex.encode(fpBytes);
        return fp == _certFingerprint;
      };
    } else {
      client.badCertificateCallback = (cert, host, port) => true;
    }
    return client;
  }

  Future<WebSocketChannel> _connectWs() async {
    final utlsPort = UTLSService.instance.proxyPort;
    final torActive = _torEnabled && tor.TorService.instance.isBootstrapped;

    // 1. Force-Tor+uTLS (if pulse_force_tor enabled)
    if (_forcePulseTor && torActive && utlsPort != null) {
      try {
        debugPrint('[Pulse] Force-Tor: uTLS+Tor chain to $_wsUrlV2');
        final ch = await _connectPulseWebSocketViaUtls(
            _wsUrlV2, utlsPort,
            upstreamSocks5: '$_torHost:$_torPort')
            .timeout(const Duration(seconds: 20));
        _protoVersion = 2;
        return ch;
      } catch (e) {
        debugPrint('[Pulse] Force-Tor uTLS+Tor failed ($e) — trying plain Tor');
      }
      // Fallback: plain Tor SOCKS5
      try {
        final ch = await tor.connectWebSocket(_wsUrlV2,
            torHost: _torHost, torPort: _torPort,
            socks5Timeout: const Duration(seconds: 8));
        _protoVersion = 2;
        return ch;
      } catch (_) {}
      try {
        final ch = await tor.connectWebSocket(_wsUrl,
            torHost: _torHost, torPort: _torPort,
            socks5Timeout: const Duration(seconds: 8));
        _protoVersion = 1;
        return ch;
      } catch (e) {
        debugPrint('[Pulse] Force-Tor plain Tor also failed ($e) — trying next');
      }
    }

    // 2. uTLS+ECH (if UTLSService available, not force-tor)
    if (utlsPort != null && !_forcePulseTor) {
      try {
        debugPrint('[Pulse] uTLS+ECH to $_wsUrlV2');
        final ch = await _connectPulseWebSocketViaUtls(_wsUrlV2, utlsPort)
            .timeout(const Duration(seconds: 8));
        _protoVersion = 2;
        return ch;
      } catch (e) {
        debugPrint('[Pulse] uTLS+ECH failed ($e) — trying next');
      }
    }

    // 3. Tor SOCKS5 (if enabled, not already tried via force-tor)
    if (torActive && !_forcePulseTor) {
      try {
        try {
          final ch = await tor.connectWebSocket(_wsUrlV2,
              torHost: _torHost, torPort: _torPort,
              socks5Timeout: const Duration(seconds: 8));
          _protoVersion = 2;
          return ch;
        } catch (_) {}
        final ch = await tor.connectWebSocket(_wsUrl,
            torHost: _torHost, torPort: _torPort,
            socks5Timeout: const Duration(seconds: 8));
        _protoVersion = 1;
        return ch;
      } catch (e) {
        debugPrint('[Pulse] Tor WS connect failed ($e) — trying next');
      }
    }

    // 4. CF Worker relay proxy (if configured)
    if (_cfWorkerRelay.isNotEmpty) {
      try {
        var workerStr = _cfWorkerRelay;
        if (!workerStr.startsWith('wss://') && !workerStr.startsWith('ws://')) {
          workerStr = 'wss://$workerStr';
        }
        final workerUri = Uri.parse(workerStr);
        if (workerUri.host.isEmpty) throw FormatException('CF Worker: empty host');
        final targetUrl = _wsUrlV2;
        final workerUrl = workerUri.replace(queryParameters: {'r': targetUrl}).toString();
        debugPrint('[Pulse] Trying CF Worker: $workerUrl');
        final inner = _buildHttpClient();
        final ws = await WebSocket.connect(workerUrl, customClient: inner,
                protocols: ['pulse.v2.auth'])
            .timeout(const Duration(seconds: 12));
        _protoVersion = 2;
        return IOWebSocketChannel(ws);
      } catch (e) {
        debugPrint('[Pulse] CF Worker connect failed ($e) — falling back to plain');
      }
    }

    // 5. Direct v1 (try first — v2 requires protocol negotiation)
    try {
      final inner = _buildHttpClient();
      final ws = await WebSocket.connect(
        _wsUrl,
        customClient: inner,
      ).timeout(const Duration(seconds: 10));
      _protoVersion = 1;
      return IOWebSocketChannel(ws);
    } catch (e) {
      debugPrint('[Pulse] v1 connect failed ($e) — trying v2');
    }

    // 6. Direct v2
    final inner = _buildHttpClient();
    final ws = await WebSocket.connect(
      _wsUrlV2,
      customClient: inner,
      protocols: ['pulse.v2.auth'],
    ).timeout(const Duration(seconds: 10));
    _protoVersion = 2;
    return IOWebSocketChannel(ws);
  }

  Future<void> _saveTurnCreds(Map<String, dynamic> data) async {
    try {
      const ss = FlutterSecureStorage();
      final turnUrl  = data['turn_url']  as String? ?? '';
      final turnUser = data['turn_user'] as String? ?? '';
      final turnPass = data['turn_pass'] as String? ?? '';
      if (turnUrl.isNotEmpty) {
        await ss.write(key: 'pulse_turn_url',  value: turnUrl);
        await ss.write(key: 'pulse_turn_user', value: turnUser);
        await ss.write(key: 'pulse_turn_pass', value: turnPass);
      }
    } catch (e) {
      debugPrint('[Pulse] Failed to save TURN creds: $e');
    }
  }

  /// Save TURN credentials from v2 auth_ok (structured `turn` object) or v1 flat fields.
  Future<void> _saveTurnCredsV2(Map<String, dynamic> data) async {
    try {
      const ss = FlutterSecureStorage();
      // V2: structured turn object: {"urls":["turn:..."],"username":"...","credential":"...","ttl":N}
      final turnObj = data['turn'];
      if (turnObj is Map<String, dynamic>) {
        final urls = turnObj['urls'];
        String turnUrl = '';
        if (urls is List && urls.isNotEmpty) {
          turnUrl = urls.first.toString();
        }
        final turnUser = turnObj['username'] as String? ?? '';
        final turnPass = turnObj['credential'] as String? ?? '';
        if (turnUrl.isNotEmpty) {
          await ss.write(key: 'pulse_turn_url',  value: turnUrl);
          await ss.write(key: 'pulse_turn_user', value: turnUser);
          await ss.write(key: 'pulse_turn_pass', value: turnPass);
        }
        return;
      }
      // V1 fallback: flat fields
      await _saveTurnCreds(data);
      // Save cert fingerprint from auth_ok if provided
      final certFp = data['cert_fp'] as String? ?? '';
      if (certFp.isNotEmpty && _certFingerprint.isEmpty) {
        _certFingerprint = certFp.toLowerCase();
      }
    } catch (e) {
      debugPrint('[Pulse] Failed to save TURN creds v2: $e');
    }
  }

  Future<int> _getLastFetchTs() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getInt('pulse_last_fetch_ts') ?? 0;
    final thirtyDaysAgo =
        DateTime.now().millisecondsSinceEpoch ~/ 1000 - 30 * 86400;
    return stored > thirtyDaysAgo ? stored - 60 : thirtyDaysAgo;
  }

  Future<void> _updateLastFetchTs(int unixSeconds) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('pulse_last_fetch_ts') ?? 0;
    if (unixSeconds > current) {
      await prefs.setInt('pulse_last_fetch_ts', unixSeconds);
    }
  }

  Future<void> _runLoop() async {
    while (_running) {
      WebSocketChannel? channel;
      bool cycleSuccess = false;
      Timer? cbrTimer;
      if (!_running) break;

      try {
        channel = await _connectWs();
        // Don't set _ws here — wait until auth succeeds to avoid
        // overwriting a sender's active connection before we're ready.
        await channel.ready;
        debugPrint('[Pulse] Connected (v$_protoVersion) to ${_protoVersion == 2 ? _wsUrlV2 : _wsUrl}');

        // Single stream listener — handles auth then messages
        bool authenticated = false;
        try {
          await for (final raw in channel.stream) {
            try {
              // ── Binary frame handling (padding, file chunks, etc.) ──
              if (raw is List<int>) {
                // 0xFF = server CBR/burst padding frame → silently discard
                // Other binary types (file, media, tunnel) not handled by reader
                continue;
              }

              final data = jsonDecode(raw as String) as Map<String, dynamic>;
              final type = data['type'] as String? ?? '';

              // ── Chaff filtering — server sends decoy messages with _chaff:true ──
              if (data['_chaff'] == true) continue;

              // ── Auth phase ──
              if (!authenticated) {
                if (type == 'auth_challenge') {
                  // v2 challenges have "v":2 and use "ts" field; v1 uses "timestamp" in payload
                  final p = _protoVersion == 2 ? data : _envPayload(data);
                  final nonce = p['nonce'] as String? ?? '';
                  final challengeVersion = p['v'] as int? ?? 1;
                  final tsKey = challengeVersion >= 2 ? 'ts' : 'timestamp';
                  final timestamp = p[tsKey]?.toString() ?? '';
                  if (nonce.isEmpty || nonce.length > 256) {
                    debugPrint('[Pulse] Auth challenge: invalid nonce (${nonce.length})');
                    break;
                  }
                  final tsVal = int.tryParse(timestamp) ?? 0;
                  final serverTime = DateTime.fromMillisecondsSinceEpoch(tsVal * 1000);
                  if (DateTime.now().difference(serverTime).abs() > const Duration(minutes: 5)) {
                    debugPrint('[Pulse] Auth challenge timestamp out of range');
                    break;
                  }
                  // Sign with appropriate prefix
                  final prefix = challengeVersion >= 2 ? 'pulse-v2-auth' : 'pulse-auth-v1';
                  final message = '$prefix:$nonce:$timestamp';
                  final signature = await _ed25519Sign(_seed, message);

                  if (_protoVersion == 2) {
                    // V2: flat JSON (no envelope wrapper)
                    channel.sink.add(jsonEncode({
                      'type': 'auth_response',
                      'pubkey': _pubkeyHex,
                      'signature': signature,
                      'nonce': nonce,
                      'timestamp': tsVal,
                      'invite': _invite,
                    }));
                  } else {
                    channel.sink.add(_makeEnvelope('auth_response', {
                      'pubkey': _pubkeyHex,
                      'signature': signature,
                      'nonce': nonce,
                      'timestamp': tsVal,
                      'invite': _invite,
                    }));
                  }
                } else if (type == 'auth_ok') {
                  final okData = _protoVersion == 2 ? data : _envPayload(data);
                  _saveTurnCredsV2(okData);
                  authenticated = true;
                  final pendingCount = okData['pending_count'] ?? 0;
                  final serverName = okData['server'] as String? ?? '';
                  debugPrint('[Pulse] Authenticated as ${_pubkeyHex.substring(0, 8)}... '
                      '(v$_protoVersion, pending=$pendingCount${serverName.isNotEmpty ? ', server=$serverName' : ''})');

                  // Start upstream CBR padding if server advertises it
                  final privacy = okData['privacy'];
                  if (privacy is Map<String, dynamic> &&
                      privacy['padding'] == 'cbr') {
                    final rateKbps = (privacy['rate_kbps'] as num?)?.toInt() ?? 0;
                    if (rateKbps > 0) {
                      final bytesPerFrame = rateKbps * 1000 ~/ 8 ~/ 10;
                      debugPrint('[Pulse] CBR padding: ${rateKbps}kbps → ${bytesPerFrame}B/100ms');
                      cbrTimer?.cancel();
                      cbrTimer = Timer.periodic(
                          const Duration(milliseconds: 100), (_) {
                        try {
                          final frame = Uint8List(1 + bytesPerFrame);
                          frame[0] = 0xFF; // padding marker
                          for (int i = 1; i < frame.length; i++) {
                            frame[i] = _secureRng.nextInt(256);
                          }
                          channel?.sink.add(frame);
                        } catch (_) {}
                      });
                    }
                  }

                  // Request stored messages
                  final since = await _getLastFetchTs();
                  if (_protoVersion == 2) {
                    channel.sink.add(jsonEncode({
                      'type': 'fetch',
                      'since': since,
                      'limit': 100,
                    }));
                  } else {
                    channel.sink.add(_makeEnvelope('fetch', {
                      'since': since,
                      'limit': 100,
                    }));
                  }

                  cycleSuccess = true;
                  _ws = channel;
                  // Publish to shared pool so PulseMessageSender reuses
                  // this connection instead of opening a competing one.
                  _PulseSharedWs.channel = channel;
                  _PulseSharedWs.authenticated = true;
                  _PulseSharedWs.protoVersion = _protoVersion;
                  if (!_isHealthy && !_healthCtrl.isClosed) {
                    _isHealthy = true;
                    _healthCtrl.add(true);
                  }
                  _consecutiveFailures = 0;
                } else if (type == 'error') {
                  final ep = _protoVersion == 2 ? data : _envPayload(data);
                  debugPrint('[Pulse] Auth error: ${ep['message'] ?? data}');
                  break;
                }
                continue;
              }

              // ── Message phase ──
              switch (type) {
                case 'message':
                  _dispatchMessage(data);
                case 'signal':
                  _dispatchSignal(data);
                case 'stored':
                  _dispatchStored(data, channel);
                case 'ack':
                  final ap = _envPayload(data);
                  debugPrint('[Pulse] ACK: ${ap['id'] ?? ''}');
                case 'keys':
                  // Complete pending keys completer (for fetchContactKeys)
                  final kp = _envPayload(data);
                  final kPub = kp['pubkey'] as String? ?? '';
                  if (kPub.isNotEmpty) {
                    final kc = _PulseSharedWs.pendingKeysCompleters.remove(kPub);
                    if (kc != null && !kc.isCompleted) {
                      final bundle = kp['bundle'];
                      Map<String, dynamic>? bundleMap;
                      if (bundle is Map<String, dynamic>) {
                        bundleMap = bundle;
                      } else if (bundle is String) {
                        try { bundleMap = jsonDecode(bundle) as Map<String, dynamic>; } catch (_) {}
                      }
                      kc.complete(bundleMap);
                    }
                  }
                  _dispatchKeys(data);
                case 'error':
                  final ep = _envPayload(data);
                  debugPrint('[Pulse] Server error: ${ep['message'] ?? data}');
                // SFU message types — forward through signal stream
                case 'room_created':
                case 'room_info':
                case 'room_left':
                case 'media_answer':
                case 'media_candidate':
                case 'track_published':
                case 'track_available':
                case 'track_removed':
                case 'track_subscribed':
                case 'speaker_update':
                case 'last_n_update':
                  if (!_sigCtrl.isClosed) {
                    _sigCtrl.add([{'type': 'sfu', 'payload': data}]);
                  }
                default:
                  debugPrint('[Pulse] Unknown message type: $type');
              }
            } catch (e) {
              debugPrint('[Pulse] Message parse error: $e');
            }
          }
        } catch (e) {
          debugPrint('[Pulse] Stream error: $e');
        }
      } catch (e) {
        debugPrint('[Pulse] Connection error: $e');
      } finally {
        cbrTimer?.cancel();
        cbrTimer = null;
        // Only clear shared pool if WE own it (sender may have taken over)
        if (_PulseSharedWs.channel == channel) {
          _PulseSharedWs.channel = null;
          _PulseSharedWs.authenticated = false;
        }
        _ws = null;
        try { channel?.sink.close(); } catch (_) {}
      }

      if (!_running) break;

      _consecutiveFailures++;
      if (_consecutiveFailures >= _maxConsecutiveFailures) {
        debugPrint('[Pulse] Circuit breaker: $_consecutiveFailures failures');
        _circuitBroken = true;
        _running = false;
        _loopStarted = false;
        break;
      }

      if (_consecutiveFailures >= _failureThreshold &&
          _isHealthy && !_healthCtrl.isClosed) {
        _isHealthy = false;
        _healthCtrl.add(false);
      }

      // Reconnect: fast on success cycle, tiered on failure
      final delay = cycleSuccess
          ? const Duration(seconds: 2)
          : _reconnectDelay(_consecutiveFailures);
      await Future<void>.delayed(delay);
    }
  }

  void _dispatchMessage(Map<String, dynamic> data) {
    final payload = data['payload'] as Map<String, dynamic>? ?? data;
    final id = payload['id'] as String? ?? '';
    if (id.isEmpty || _seenIds.contains(id)) return;
    _trackSeenId(id);

    final rawTs = payload['timestamp'] as int? ??
        (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    unawaited(_updateLastFetchTs(rawTs));

    // Clamp timestamp to ±7 days of local clock to prevent ordering attacks.
    final now = DateTime.now();
    final claimed = DateTime.fromMillisecondsSinceEpoch(rawTs * 1000, isUtc: true);
    final msgTs = claimed.difference(now).abs() <= const Duration(days: 7) ? claimed : now;

    final msg = Message(
      id: id,
      senderId: payload['from'] as String? ?? '',
      receiverId: _pubkeyHex,
      encryptedPayload: payload['payload'] as String? ?? '',
      timestamp: msgTs,
      adapterType: 'pulse',
    );
    if (!_msgCtrl.isClosed) _msgCtrl.add([msg]);

    // Send ACK
    _sendAck(id);
  }

  void _dispatchSignal(Map<String, dynamic> data) {
    final payload = data['payload'] as Map<String, dynamic>? ?? data;
    final id = payload['id'] as String? ?? '';
    if (id.isNotEmpty && _seenIds.contains(id)) return;
    if (id.isNotEmpty) _trackSeenId(id);

    try {
      Map<String, dynamic> signalData;
      final payloadContent = payload['payload'];
      if (payloadContent is String) {
        signalData = jsonDecode(payloadContent) as Map<String, dynamic>;
      } else if (payloadContent is Map) {
        signalData = Map<String, dynamic>.from(payloadContent);
      } else {
        signalData = payload;
      }
      // Security: override adapterType so a compromised/MITM Pulse server
      // cannot inject adapterType='nostr' and bypass HMAC verification.
      signalData['adapterType'] = 'pulse';
      if (!_sigCtrl.isClosed) _sigCtrl.add([signalData]);
    } catch (e) {
      debugPrint('[Pulse] Signal dispatch error: $e');
    }

    if (id.isNotEmpty) _sendAck(id);
  }

  void _dispatchStored(Map<String, dynamic> data, WebSocketChannel channel) {
    final p = _envPayload(data);
    final messages = p['messages'] as List? ?? [];
    for (final m in messages) {
      if (m is! Map) continue;
      final entry = Map<String, dynamic>.from(m);
      final msgType = entry['msg_type'] as String? ?? 'message';
      if (msgType == 'signal') {
        _dispatchSignal(entry);
      } else {
        _dispatchMessage(entry);
      }
    }
  }

  void _dispatchKeys(Map<String, dynamic> data) {
    final payload = data['payload'] as Map<String, dynamic>?;
    if (payload != null && !_sigCtrl.isClosed) {
      _sigCtrl.add([{
        'type': 'sys_keys',
        'payload': payload,
        'senderId': data['from'] as String? ?? '',
      }]);
    }
  }

  void _sendAck(String messageId) {
    try {
      if (_protoVersion == 2) {
        _ws?.sink.add(jsonEncode({'type': 'ack', 'id': messageId}));
      } else {
        _ws?.sink.add(_makeEnvelope('ack', {'id': messageId}));
      }
    } catch (e) {
      debugPrint('[Pulse] Failed to send ACK: $e');
    }
  }

  @override
  Stream<List<Message>> listenForMessages() {
    _ensureLoop();
    return _msgCtrl.stream;
  }

  @override
  Stream<List<Map<String, dynamic>>> listenForSignals() {
    _ensureLoop();
    return _sigCtrl.stream;
  }

  @override
  Future<String?> provisionGroup(String groupName) async =>
      '$_pubkeyHex@$_serverUrl';

  @override
  Future<Map<String, dynamic>?> fetchPublicKeys() async {
    if (_pubkeyHex.isEmpty || _wsUrl.isEmpty) return null;

    WebSocketChannel? channel;
    try {
      channel = await _connectWs();
      await channel.ready;

      final completer = Completer<Map<String, dynamic>?>();
      Timer(const Duration(seconds: 15), () {
        if (!completer.isCompleted) completer.complete(null);
      });

      bool authenticated = false;
      final sub = channel.stream.listen((raw) {
        try {
          if (raw is List<int>) return; // binary padding → ignore
          final data = jsonDecode(raw as String) as Map<String, dynamic>;
          if (data['_chaff'] == true) return; // chaff → discard
          final type = data['type'] as String? ?? '';
          if (!authenticated) {
            if (type == 'auth_challenge') {
              final p = _envPayload(data);
              final nonce = p['nonce'] as String? ?? '';
              final tsVal = int.tryParse(p['timestamp']?.toString() ?? '') ?? 0;
              if (nonce.isEmpty) {
                if (!completer.isCompleted) completer.complete(null);
                return;
              }
              final msg = 'pulse-auth-v1:$nonce:$tsVal';
              _ed25519Sign(_seed, msg).then((sig) {
                channel!.sink.add(_makeEnvelope('auth_response', {
                  'pubkey': _pubkeyHex,
                  'signature': sig,
                  'nonce': nonce,
                  'timestamp': tsVal,
                  'invite': _invite,
                }));
              });
            } else if (type == 'auth_ok') {
              authenticated = true;
              channel!.sink.add(_makeEnvelope('keys_get', {'pubkey': _pubkeyHex}));
            } else if (type == 'error') {
              if (!completer.isCompleted) completer.complete(null);
            }
          } else if (type == 'keys') {
            final p = _envPayload(data);
            final bundle = p['bundle'];
            Map<String, dynamic>? bundleMap;
            if (bundle is Map<String, dynamic>) bundleMap = bundle;
            if (!completer.isCompleted) completer.complete(bundleMap);
          }
        } catch (e) {
          debugPrint('[Pulse] fetchPublicKeys parse error: $e');
        }
      }, onError: (_) {
        if (!completer.isCompleted) completer.complete(null);
      });

      final result = await completer.future;
      await sub.cancel();
      return result;
    } catch (e) {
      debugPrint('[Pulse] fetchPublicKeys error: $e');
      return null;
    } finally {
      channel?.sink.close();
    }
  }

  /// Stop the event loop and close the active WebSocket.
  void close() {
    _running = false;
    _loopStarted = false;
    try { _ws?.sink.close(); } catch (_) {}
    _ws = null;
  }

  /// Stop event loop and clear private key material from memory.
  void zeroize() {
    close();
    for (int i = 0; i < _seed.length; i++) {
      _seed[i] = 0;
    }
    _seed = Uint8List(0);
    _pubkeyHex = '';
  }
}

// ── PulseMessageSender ──────────────────────────────────────────────────────

class PulseMessageSender implements MessageSender {
  Uint8List _seed = Uint8List(0);
  String _pubkeyHex = '';
  String _serverUrl = '';
  String _wsUrl = '';
  String _wsUrlV2 = '';

  /// Protocol version negotiated with the server (1 or 2).
  int _protoVersion = 1;

  /// TLS cert SHA-256 fingerprint parsed from `#suffix` in serverUrl.
  String _certFingerprint = '';

  // Tor settings
  bool _torEnabled = false;
  String _torHost = '127.0.0.1';
  int _torPort = 9050;

  // CF Worker relay proxy
  String _cfWorkerRelay = '';

  // Force-Tor mode
  bool _forcePulseTor = false;

  // Persistent WS connection
  WebSocketChannel? _ws;
  bool _authenticated = false;

  @override
  Future<void> initializeSender(String apiKey) async {
    try {
      final decoded = jsonDecode(apiKey) as Map<String, dynamic>;
      final privkeyHex = (decoded['privkey'] as String? ?? '').trim();
      _serverUrl = (decoded['serverUrl'] as String? ?? '').trim();

      if (privkeyHex.isNotEmpty) {
        _seed = Uint8List.fromList(hex.decode(privkeyHex));
        _pubkeyHex = await ed25519PubkeyFromSeed(_seed);
      }
    } catch (e) {
      debugPrint('[Pulse] Sender failed to parse apiKey JSON: $e');
      return;
    }

    // Parse cert fingerprint from URL fragment
    if (_serverUrl.contains('#')) {
      final parts = _serverUrl.split('#');
      _serverUrl = parts[0];
      _certFingerprint = parts[1].toLowerCase();
    }

    if (_serverUrl.startsWith('https://')) {
      final hostPort = _serverUrl.substring('https://'.length);
      _wsUrl = 'wss://$hostPort/ws';
      _wsUrlV2 = 'wss://$hostPort/v2';
    } else if (_serverUrl.startsWith('http://')) {
      debugPrint('[Pulse] Sender rejected http:// server URL — use https://');
      _wsUrl = '';
      _wsUrlV2 = '';
    }

    // Load Tor + CF Worker + Force-Tor settings
    final prefs = await SharedPreferences.getInstance();
    _torEnabled = prefs.getBool('tor_enabled') ?? false;
    _torHost = prefs.getString('tor_host') ?? '127.0.0.1';
    _torPort = prefs.getInt('tor_port') ?? 9050;
    _cfWorkerRelay = prefs.getString('cf_worker_relay') ?? '';
    _forcePulseTor = prefs.getBool('pulse_force_tor') ?? false;
  }

  /// Reset connection: close WS, reload prefs.
  Future<void> resetConnection() async {
    try { _ws?.sink.close(); } catch (_) {}
    _ws = null;
    _authenticated = false;
    final prefs = await SharedPreferences.getInstance();
    _torEnabled = prefs.getBool('tor_enabled') ?? false;
    _torHost = prefs.getString('tor_host') ?? '127.0.0.1';
    _torPort = prefs.getInt('tor_port') ?? 9050;
    _cfWorkerRelay = prefs.getString('cf_worker_relay') ?? '';
    _forcePulseTor = prefs.getBool('pulse_force_tor') ?? false;
  }

  /// Build an HttpClient with cert-pinning if a fingerprint is configured.
  HttpClient _buildHttpClient() {
    final client = HttpClient();
    if (_certFingerprint.isNotEmpty) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        final der = cert.der;
        final fpBytes = hash_lib.sha256.convert(der).bytes;
        final fp = hex.encode(fpBytes);
        return fp == _certFingerprint;
      };
    } else {
      client.badCertificateCallback = (cert, host, port) => true;
    }
    return client;
  }

  Future<WebSocketChannel> _connectWs() async {
    final utlsPort = UTLSService.instance.proxyPort;
    final torActive = _torEnabled && tor.TorService.instance.isBootstrapped;

    // 1. Force-Tor+uTLS
    if (_forcePulseTor && torActive && utlsPort != null) {
      try {
        debugPrint('[Pulse/Sender] Force-Tor: uTLS+Tor chain to $_wsUrlV2');
        final ch = await _connectPulseWebSocketViaUtls(
            _wsUrlV2, utlsPort,
            upstreamSocks5: '$_torHost:$_torPort')
            .timeout(const Duration(seconds: 20));
        _protoVersion = 2;
        return ch;
      } catch (e) {
        debugPrint('[Pulse/Sender] Force-Tor uTLS+Tor failed ($e) — plain Tor');
      }
      try {
        final ch = await tor.connectWebSocket(_wsUrlV2,
            torHost: _torHost, torPort: _torPort,
            socks5Timeout: const Duration(seconds: 8));
        _protoVersion = 2;
        return ch;
      } catch (_) {}
      try {
        final ch = await tor.connectWebSocket(_wsUrl,
            torHost: _torHost, torPort: _torPort,
            socks5Timeout: const Duration(seconds: 8));
        _protoVersion = 1;
        return ch;
      } catch (e) {
        debugPrint('[Pulse/Sender] Force-Tor plain Tor failed ($e) — next');
      }
    }

    // 2. uTLS+ECH
    if (utlsPort != null && !_forcePulseTor) {
      try {
        final ch = await _connectPulseWebSocketViaUtls(_wsUrlV2, utlsPort)
            .timeout(const Duration(seconds: 8));
        _protoVersion = 2;
        return ch;
      } catch (e) {
        debugPrint('[Pulse/Sender] uTLS+ECH failed ($e) — next');
      }
    }

    // 3. Tor SOCKS5
    if (torActive && !_forcePulseTor) {
      try {
        try {
          final ch = await tor.connectWebSocket(_wsUrlV2,
              torHost: _torHost, torPort: _torPort,
              socks5Timeout: const Duration(seconds: 8));
          _protoVersion = 2;
          return ch;
        } catch (_) {}
        final ch = await tor.connectWebSocket(_wsUrl,
            torHost: _torHost, torPort: _torPort,
            socks5Timeout: const Duration(seconds: 8));
        _protoVersion = 1;
        return ch;
      } catch (e) {
        debugPrint('[Pulse/Sender] Tor failed ($e) — next');
      }
    }

    // 4. CF Worker
    if (_cfWorkerRelay.isNotEmpty) {
      try {
        var workerStr = _cfWorkerRelay;
        if (!workerStr.startsWith('wss://') && !workerStr.startsWith('ws://')) {
          workerStr = 'wss://$workerStr';
        }
        final workerUri = Uri.parse(workerStr);
        if (workerUri.host.isEmpty) throw FormatException('CF Worker: empty host');
        final workerUrl = workerUri.replace(queryParameters: {'r': _wsUrlV2}).toString();
        debugPrint('[Pulse/Sender] Trying CF Worker: $workerUrl');
        final inner = _buildHttpClient();
        final ws = await WebSocket.connect(workerUrl, customClient: inner,
                protocols: ['pulse.v2.auth'])
            .timeout(const Duration(seconds: 12));
        _protoVersion = 2;
        return IOWebSocketChannel(ws);
      } catch (e) {
        debugPrint('[Pulse/Sender] CF Worker failed ($e) — plain');
      }
    }

    // 5. Direct v1
    try {
      final inner = _buildHttpClient();
      final ws = await WebSocket.connect(
        _wsUrl,
        customClient: inner,
      ).timeout(const Duration(seconds: 10));
      _protoVersion = 1;
      return IOWebSocketChannel(ws);
    } catch (e) {
      debugPrint('[Pulse/Sender] v1 failed ($e) — trying v2');
    }

    // 6. Direct v2
    final inner = _buildHttpClient();
    final ws = await WebSocket.connect(
      _wsUrlV2,
      customClient: inner,
      protocols: ['pulse.v2.auth'],
    ).timeout(const Duration(seconds: 10));
    _protoVersion = 2;
    return IOWebSocketChannel(ws);
  }

  /// Get an authenticated WS connection, reusing if available.
  /// Prefers the reader's shared connection to avoid server kicking it.
  Future<WebSocketChannel?> _getConnection() async {
    // 1. Reuse own cached connection
    final ws = _ws;
    if (ws != null && _authenticated) return ws;

    // 2. Borrow the reader's long-lived connection (avoids duplicate auth)
    final shared = _PulseSharedWs.channel;
    if (shared != null && _PulseSharedWs.authenticated) {
      _protoVersion = _PulseSharedWs.protoVersion;
      return shared;
    }

    // 3. No reader connection — create own (rare: reader not started yet)
    try {
      final channel = await _connectWs();
      await channel.ready;

      // Authenticate — single stream listener handles both auth and runtime.
      final completer = Completer<bool>();
      channel.stream.listen((raw) async {
        try {
          if (raw is List<int>) return; // binary padding → ignore
          final data = jsonDecode(raw as String) as Map<String, dynamic>;
          if (data['_chaff'] == true) return; // chaff → discard
          final type = data['type'] as String? ?? '';

          // ── Auth phase ──
          if (!completer.isCompleted) {
            if (type == 'auth_challenge') {
              final p = _protoVersion == 2 ? data : _envPayload(data);
              final nonce = p['nonce'] as String? ?? '';
              final challengeVersion = p['v'] as int? ?? 1;
              final tsKey = challengeVersion >= 2 ? 'ts' : 'timestamp';
              final timestamp = p[tsKey]?.toString() ?? '';
              final tsVal = int.tryParse(timestamp) ?? 0;
              final serverTime = DateTime.fromMillisecondsSinceEpoch(tsVal * 1000);
              if (nonce.isEmpty || nonce.length > 256 ||
                  DateTime.now().difference(serverTime).abs() > const Duration(minutes: 5)) {
                debugPrint('[Pulse/Sender] Auth challenge invalid — nonce or timestamp rejected');
                completer.complete(false);
                return;
              }
              final prefix = challengeVersion >= 2 ? 'pulse-v2-auth' : 'pulse-auth-v1';
              final message = '$prefix:$nonce:$timestamp';
              final signature = await _ed25519Sign(_seed, message);
              if (_protoVersion == 2) {
                channel.sink.add(jsonEncode({
                  'type': 'auth_response',
                  'pubkey': _pubkeyHex,
                  'signature': signature,
                  'nonce': nonce,
                  'timestamp': tsVal,
                  'invite': '',
                }));
              } else {
                channel.sink.add(_makeEnvelope('auth_response', {
                  'pubkey': _pubkeyHex,
                  'signature': signature,
                  'nonce': nonce,
                  'timestamp': tsVal,
                  'invite': '',
                }));
              }
            } else if (type == 'auth_ok') {
              final okData = _protoVersion == 2 ? data : _envPayload(data);
              final certFp = okData['cert_fp'] as String? ?? '';
              if (certFp.isNotEmpty && _certFingerprint.isEmpty) {
                _certFingerprint = certFp.toLowerCase();
              }
              completer.complete(true);
            } else if (type == 'error') {
              completer.complete(false);
            }
            return;
          }

          // ── Runtime phase (post-auth) ──
          if (type == 'keys') {
            final p = _envPayload(data);
            final pubkey = p['pubkey'] as String? ?? '';
            final bundle = p['bundle'];
            Map<String, dynamic>? bundleMap;
            if (bundle is Map<String, dynamic>) {
              bundleMap = bundle;
            } else if (bundle is String) {
              try { bundleMap = jsonDecode(bundle) as Map<String, dynamic>; } catch (_) {}
            }
            final keysCompleter = _PulseSharedWs.pendingKeysCompleters.remove(pubkey);
            if (keysCompleter != null && !keysCompleter.isCompleted) {
              keysCompleter.complete(bundleMap);
            }
          }
        } catch (e) {
          debugPrint('[Pulse] Sender parse error: $e');
        }
      }, onError: (Object e) {
        if (!completer.isCompleted) completer.complete(false);
        _ws = null;
        _authenticated = false;
        for (final c in _PulseSharedWs.pendingKeysCompleters.values) {
          if (!c.isCompleted) c.complete(null);
        }
        _PulseSharedWs.pendingKeysCompleters.clear();
      }, onDone: () {
        if (!completer.isCompleted) completer.complete(false);
        _ws = null;
        _authenticated = false;
        for (final c in _PulseSharedWs.pendingKeysCompleters.values) {
          if (!c.isCompleted) c.complete(null);
        }
        _PulseSharedWs.pendingKeysCompleters.clear();
      },
        cancelOnError: false,
      );

      final ok = await completer.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () => false,
      );

      if (!ok) {
        channel.sink.close();
        return null;
      }

      _ws = channel;
      _authenticated = true;

      return channel;
    } catch (e) {
      debugPrint('[Pulse] Sender connection error: $e');
      _ws = null;
      _authenticated = false;
      return null;
    }
  }

  @override
  Future<bool> sendMessage(String targetDatabaseId, String roomId,
      Message message) async {
    if (_seed.isEmpty || _wsUrl.isEmpty) return false;

    // Extract target pubkey from address (part before @)
    final atIdx = targetDatabaseId.indexOf('@');
    final targetPubkey =
        atIdx != -1 ? targetDatabaseId.substring(0, atIdx) : targetDatabaseId;

    try {
      final channel = await _getConnection();
      if (channel == null) return false;

      // Append random suffix so rapid-fire messages within the same millisecond
      // get distinct IDs and are not deduplicated/dropped by the relay.
      final msgId = message.id.isNotEmpty
          ? message.id
          : '${DateTime.now().millisecondsSinceEpoch}_${Random.secure().nextInt(0xFFFFFF).toRadixString(16)}';

      // Client-side send jitter for traffic decorrelation
      await _sendJitter();

      if (_protoVersion == 2) {
        channel.sink.add(_bucketPad(jsonEncode({
          'type': 'send',
          'id': msgId,
          'to': targetPubkey,
          'body': message.encryptedPayload,
        })));
      } else {
        channel.sink.add(_bucketPad(jsonEncode({
          'type': 'send',
          'payload': {
            'id': msgId,
            'to': targetPubkey,
            'payload': message.encryptedPayload,
          },
        })));
      }
      return true;
    } catch (e) {
      debugPrint('[Pulse] sendMessage error: $e');
      _ws = null;
      _authenticated = false;
      return false;
    }
  }

  @override
  Future<bool> sendSignal(String targetDatabaseId, String roomId,
      String senderId, String type, Map<String, dynamic> payload) async {
    if (_seed.isEmpty || _wsUrl.isEmpty) return false;

    final atIdx = targetDatabaseId.indexOf('@');
    final targetPubkey =
        atIdx != -1 ? targetDatabaseId.substring(0, atIdx) : targetDatabaseId;

    // Key bundle publish — special handling
    if (type == 'sys_keys') {
      return _publishKeys(payload);
    }

    try {
      final channel = await _getConnection();
      if (channel == null) return false;

      final signalPayload = jsonEncode({
        'type': type,
        'roomId': roomId,
        'senderId': senderId,
        'payload': payload,
      });

      if (_protoVersion == 2) {
        channel.sink.add(_bucketPad(jsonEncode({
          'type': 'signal',
          'to': targetPubkey,
          'payload': signalPayload,
        })));
      } else {
        channel.sink.add(_bucketPad(jsonEncode({
          'type': 'signal',
          'payload': {
            'id': '${DateTime.now().millisecondsSinceEpoch}_${Random.secure().nextInt(0xFFFFFF).toRadixString(16)}',
            'to': targetPubkey,
            'payload': signalPayload,
          },
        })));
      }
      return true;
    } catch (e) {
      debugPrint('[Pulse] sendSignal error: $e');
      _ws = null;
      _authenticated = false;
      return false;
    }
  }

  /// Publish Signal key bundle to the server for storage.
  Future<bool> _publishKeys(Map<String, dynamic> bundle) async {
    try {
      final channel = await _getConnection();
      if (channel == null) return false;

      if (_protoVersion == 2) {
        channel.sink.add(jsonEncode({'type': 'keys_put', 'bundle': bundle}));
      } else {
        channel.sink.add(_makeEnvelope('keys_put', {'bundle': bundle}));
      }
      return true;
    } catch (e) {
      debugPrint('[Pulse] keys_put error: $e');
      return false;
    }
  }

  /// Fetch a contact's Signal key bundle from the server.
  Future<Map<String, dynamic>?> fetchContactKeys(String pubkey) async {
    try {
      final channel = await _getConnection();
      if (channel == null) return null;

      // Register a completer that will be resolved by the shared stream listener
      // when the server sends the keys response for this pubkey.
      final completer = _PulseSharedWs.pendingKeysCompleters.putIfAbsent(
          pubkey, () => Completer<Map<String, dynamic>?>());

      if (_protoVersion == 2) {
        channel.sink.add(jsonEncode({'type': 'keys_get', 'pubkey': pubkey}));
      } else {
        channel.sink.add(_makeEnvelope('keys_get', {'pubkey': pubkey}));
      }

      Timer(const Duration(seconds: 10), () {
        final c = _PulseSharedWs.pendingKeysCompleters.remove(pubkey);
        if (c != null && !c.isCompleted) c.complete(null);
      });

      return await completer.future;
    } catch (e) {
      debugPrint('[Pulse] fetchContactKeys error: $e');
      return null;
    }
  }

  /// Send a raw JSON string over the existing WebSocket (for SFU signaling).
  void sendRaw(String jsonMsg) {
    final ws = _ws;
    if (ws != null && _authenticated) {
      ws.sink.add(jsonMsg);
    } else {
      // Fall back to shared reader connection
      final shared = _PulseSharedWs.channel;
      if (shared != null && _PulseSharedWs.authenticated) {
        shared.sink.add(jsonMsg);
      } else {
        debugPrint('[Pulse] sendRaw: no authenticated connection');
      }
    }
  }

  /// Clear private key from memory and close connection.
  void zeroize() {
    for (final c in _PulseSharedWs.pendingKeysCompleters.values) {
      if (!c.isCompleted) c.complete(null);
    }
    _PulseSharedWs.pendingKeysCompleters.clear();
    for (int i = 0; i < _seed.length; i++) {
      _seed[i] = 0;
    }
    _seed = Uint8List(0);
    _pubkeyHex = '';
    try { _ws?.sink.close(); } catch (_) {}
    _ws = null;
    _authenticated = false;
  }
}
