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
import '../services/pulse_turn_proxy.dart';
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
///   1. Server sends auth_challenge {nonce, ts}
///   2. Client signs "pulse-auth:{nonce}:{ts}" with Ed25519
///   3. Client sends auth_response {pubkey, signature, nonce, timestamp, invite}
///   4. Server sends auth_ok {turn, cert_fp, pending_count, ...}
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

// ── PoW (Proof of Work) solver ───────────────────────────────────────────────

/// Solve PoW in a background isolate: find nonce where
/// SHA256(seed_string_bytes || nonce_u64_be) has [difficulty] leading zero bits.
Future<int> _solvePoW(String seed, int difficulty) =>
    compute(_powWorker, (seed, difficulty));

int _powWorker((String, int) args) {
  final (seed, difficulty) = args;
  final seedBytes = utf8.encode(seed);
  final buf = Uint8List(seedBytes.length + 8);
  buf.setRange(0, seedBytes.length, seedBytes);
  final bd = ByteData.sublistView(buf, seedBytes.length);
  for (int nonce = 0; ; nonce++) {
    bd.setUint64(0, nonce, Endian.big);
    final hash = hash_lib.sha256.convert(buf);
    if (_hasLeadingZeroBits(hash.bytes, difficulty)) return nonce;
  }
}

bool _hasLeadingZeroBits(List<int> hash, int bits) {
  final fullBytes = bits ~/ 8;
  final remainBits = bits % 8;
  for (int i = 0; i < fullBytes && i < hash.length; i++) {
    if (hash[i] != 0) return false;
  }
  if (remainBits > 0 && fullBytes < hash.length) {
    if (hash[fullBytes] & (0xFF << (8 - remainBits)) != 0) return false;
  }
  return true;
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

// ── Jittered WS ping interval (anti-fingerprint) ────────────────────────────

/// Random ping interval in [30s, 70s) — avoids fixed-interval DPI fingerprint.
Duration _randomPingInterval() =>
    Duration(seconds: 30 + _secureRng.nextInt(40));

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
    String url, int proxyPort, {String? upstreamSocks5,
    List<String>? protocols}) async {
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
    final ws = await WebSocket.connect(normalizedUrl, customClient: httpClient,
        protocols: protocols);
    ws.pingInterval = _randomPingInterval();
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
///
/// **Multi-server pool** — was a global singleton; now keyed by `serverUrl`
/// so a client connected to multiple Pulse servers (e.g. primary on
/// server-A, joined an SFU group whose `groupServerUrl` points at
/// server-B) keeps independent state for each. Reader/sender pick the
/// right pool entry via `_PulseSharedWs.forUrl(serverUrl)`.
class _PulseSharedWs {
  WebSocketChannel? channel;
  bool authenticated = false;
  /// Set to true when reader's _runLoop starts, so sender knows to wait.
  bool readerActive = false;
  /// Reader-maintained health flag. True on auth_ok, false when the reader's
  /// connection cycle ends without success (server unreachable, auth rejected,
  /// dropped connection). Sender consults this to skip Pulse instantly and
  /// fall back to Nostr/Session without a per-send timeout. Defaults true so a
  /// fresh boot still gives the reader a chance to connect before skipping.
  bool serverHealthy = true;
  /// Shared keys completers — reader resolves, sender registers.
  final pendingKeysCompleters = <String, Completer<Map<String, dynamic>?>>{};
  /// Sealed sender delivery certificates (single-use, from auth_ok).
  final sealedCerts = <({String token, int expires})>[];
  /// Server-confirmed message storage ACKs (message ID when server stored it).
  final serverAckCtrl = StreamController<String>.broadcast();

  /// Active-call flag — global across all servers. Suppresses connection
  /// rotation on every pool entry so a call can stay up.
  static bool _callActive = false;
  static bool get callActive => _callActive;
  static set callActive(bool v) => _callActive = v;

  /// Pool of per-server shared state. Keyed by canonicalized server URL
  /// (`https://host:port`, no trailing slash, no fragment).
  static final Map<String, _PulseSharedWs> _pool = {};

  /// Optional callback fired when a brand-new pool entry is created. Used
  /// by `pulseServerAcks` so its multiplexed stream picks up acks from
  /// servers that come online after the first listener subscribed.
  static void Function(_PulseSharedWs)? _onNewPoolEntry;

  /// Lookup-or-create a pool entry for [serverUrl]. The empty key serves
  /// as a backwards-compat fallback for callers that don't yet pass a
  /// URL — they all share one anonymous entry.
  static _PulseSharedWs forUrl(String serverUrl) {
    final key = _canonicalize(serverUrl);
    final existing = _pool[key];
    if (existing != null) return existing;
    final created = _PulseSharedWs();
    _pool[key] = created;
    _onNewPoolEntry?.call(created);
    return created;
  }

  /// Returns true if ANY pool entry has an active call. Used by the
  /// connection-rotation timer which doesn't know per-call URLs.
  static bool anyChannelHealthy() {
    for (final s in _pool.values) {
      if (s.serverHealthy && s.channel != null) return true;
    }
    return false;
  }

  static String _canonicalize(String serverUrl) {
    if (serverUrl.isEmpty) return '';
    var s = serverUrl.trim();
    final hash = s.indexOf('#');
    if (hash != -1) s = s.substring(0, hash);
    if (s.endsWith('/')) s = s.substring(0, s.length - 1);
    return s.toLowerCase();
  }
}

/// Public API: suppress Pulse connection rotation during active calls.
void setPulseCallActive(bool active) => _PulseSharedWs.callActive = active;

/// Public API: poll the per-server pool entry for [serverUrl] until its
/// reader has finished the auth handshake (PoW + auth_ok), or [timeout]
/// elapses. Returns true if authentication completed in time.
///
/// Needed by callers that just opened an adhoc reader and want to send
/// SFU control messages on the same connection — the reader's run loop
/// completes auth asynchronously, so without an explicit wait
/// `sendRaw` races and lands on a half-open channel ("no authenticated
/// connection").
Future<bool> waitForPulseAuth(String serverUrl,
    {Duration timeout = const Duration(seconds: 15)}) async {
  final shared = _PulseSharedWs.forUrl(serverUrl);
  if (shared.authenticated && shared.channel != null) return true;
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (shared.authenticated && shared.channel != null) return true;
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  return shared.authenticated && shared.channel != null;
}

// ── PulseInboxReader ────────────────────────────────────────────────────────

class PulseInboxReader implements InboxReader {
  Uint8List _seed = Uint8List(0);
  String _pubkeyHex = '';
  String _serverUrl = '';
  String _wsUrl = '';
  String _invite = '';

  /// TLS cert SHA-256 fingerprint parsed from `#suffix` in serverUrl.
  String _certFingerprint = '';

  /// Per-server shared state — connection, auth, pending key fetches.
  /// Lookup is keyed by `_serverUrl` so multiple readers (one per Pulse
  /// server the client is participating in) don't clobber each other.
  _PulseSharedWs get _shared => _PulseSharedWs.forUrl(_serverUrl);

  WebSocketChannel? _ws;
  StreamController<List<Message>> _msgCtrl =
      StreamController<List<Message>>.broadcast();
  StreamController<List<Map<String, dynamic>>> _sigCtrl =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  StreamController<bool> _healthCtrl =
      StreamController<bool>.broadcast();

  final Set<String> _seenIds = {};

  SharedPreferences? _prefs;
  Future<SharedPreferences> _getPrefs() async =>
      _prefs ??= await SharedPreferences.getInstance();

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

  /// Re-create stream controllers if they were closed (e.g. after close()/zeroize()).
  void _ensureControllers() {
    if (_msgCtrl.isClosed) _msgCtrl = StreamController<List<Message>>.broadcast();
    if (_sigCtrl.isClosed) _sigCtrl = StreamController<List<Map<String, dynamic>>>.broadcast();
    if (_healthCtrl.isClosed) _healthCtrl = StreamController<bool>.broadcast();
  }

  @override
  Future<void> initializeReader(String apiKey, String databaseId) async {
    _ensureControllers();
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
    } else {
      debugPrint('[Pulse] Rejected insecure or invalid server URL: $_serverUrl');
      return;
    }

    debugPrint('[Pulse] Initialized: pubkey=${_pubkeyHex.isNotEmpty ? '${_pubkeyHex.substring(0, 8)}...' : 'EMPTY'}, '
        'seed=<redacted>, wsUrl=$_wsUrl, fp=${_certFingerprint.isNotEmpty ? '${_certFingerprint.substring(0, 8)}...' : 'none'}');

    // Load Tor + CF Worker + Force-Tor settings
    final prefs = await _getPrefs();
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
    final prefs = await _getPrefs();
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
      debugPrint('[Pulse] _ensureLoop aborted: seed=<redacted>, wsUrl=${_wsUrl.isEmpty ? 'EMPTY' : _wsUrl}');
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
        debugPrint('[Pulse] Force-Tor: uTLS+Tor chain to $_wsUrl');
        final ch = await _connectPulseWebSocketViaUtls(
            _wsUrl, utlsPort,
            upstreamSocks5: '$_torHost:$_torPort',
            protocols: ['mqtt'])
            .timeout(const Duration(seconds: 20));
        return ch;
      } catch (e) {
        debugPrint('[Pulse] Force-Tor uTLS+Tor failed ($e) — trying plain Tor');
      }
      // Fallback: plain Tor SOCKS5
      try {
        final ch = await tor.connectWebSocket(_wsUrl,
            torHost: _torHost, torPort: _torPort,
            socks5Timeout: const Duration(seconds: 8),
            protocols: ['mqtt']);
        return ch;
      } catch (e) {
        debugPrint('[Pulse] Force-Tor plain Tor also failed ($e) — trying next');
      }
    }

    // 2. uTLS+ECH (if UTLSService available, not force-tor)
    if (utlsPort != null && !_forcePulseTor) {
      try {
        debugPrint('[Pulse] uTLS+ECH to $_wsUrl');
        final ch = await _connectPulseWebSocketViaUtls(_wsUrl, utlsPort,
                protocols: ['mqtt'])
            .timeout(const Duration(seconds: 8));
        return ch;
      } catch (e) {
        debugPrint('[Pulse] uTLS+ECH failed ($e) — trying next');
      }
    }

    // 3. Tor SOCKS5 (if enabled, not already tried via force-tor)
    if (torActive && !_forcePulseTor) {
      try {
        final ch = await tor.connectWebSocket(_wsUrl,
            torHost: _torHost, torPort: _torPort,
            socks5Timeout: const Duration(seconds: 8),
            protocols: ['mqtt']);
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
        final workerUrl = workerUri.replace(queryParameters: {'r': _wsUrl}).toString();
        debugPrint('[Pulse] Trying CF Worker: $workerUrl');
        final inner = _buildHttpClient();
        final ws = await WebSocket.connect(workerUrl, customClient: inner,
                protocols: ['mqtt'])
            .timeout(const Duration(seconds: 12));
        ws.pingInterval = _randomPingInterval();
        return IOWebSocketChannel(ws);
      } catch (e) {
        debugPrint('[Pulse] CF Worker connect failed ($e) — falling back to plain');
      }
    }

    // 5. Direct
    final inner = _buildHttpClient();
    final ws = await WebSocket.connect(
      _wsUrl,
      customClient: inner,
      protocols: ['mqtt'],
    ).timeout(const Duration(seconds: 10));
    ws.pingInterval = _randomPingInterval();
    return IOWebSocketChannel(ws);
  }

  /// Extract hostname from _serverUrl (e.g. "https://duck.azxc.site:443" → "duck.azxc.site").
  String _extractServerHost() {
    try {
      var s = _serverUrl;
      if (s.startsWith('https://')) s = s.substring(8);
      if (s.startsWith('http://')) s = s.substring(7);
      s = s.split('/').first; // remove path
      s = s.split(':').first; // remove port
      return s;
    } catch (_) {
      return '';
    }
  }

  /// Save TURN credentials from auth_ok (structured `turn` object).
  /// Saves ALL URIs (udp, tcp, turns) so loadRelay() can pick turns: for relay mode.
  /// Fixes hostname if server sends realm instead of real hostname.
  Future<void> _saveTurnCreds(Map<String, dynamic> data) async {
    try {
      const ss = FlutterSecureStorage();
      final turnObj = data['turn'];
      if (turnObj is Map<String, dynamic>) {
        var urls = turnObj['urls'];
        final turnUser = turnObj['username'] as String? ?? '';
        final turnPass = turnObj['credential'] as String? ?? '';
        if (urls is List && urls.isNotEmpty) {
          // Fix TURN hostnames: if server sends realm (no dots = not a hostname),
          // replace with actual server hostname extracted from _serverUrl.
          final serverHost = _extractServerHost();
          if (serverHost.isNotEmpty) {
            urls = urls.map((u) {
              final s = u.toString();
              // Extract hostname from turn:HOST:port or turns:HOST:port
              final m = RegExp(r'^(turns?:)([^:/?]+)(.*)$').firstMatch(s);
              if (m != null) {
                final host = m.group(2)!;
                if (!host.contains('.') && !host.contains(':')) {
                  // Not a real hostname (e.g. "pulse"), replace with server host
                  return '${m.group(1)}$serverHost${m.group(3)}';
                }
              }
              return s;
            }).toList();
          }
          // Save all URLs as JSON array for IceServerConfig to load
          await ss.write(key: 'pulse_turn_urls', value: jsonEncode(urls));
          // Keep legacy single-URL key for backward compat
          await ss.write(key: 'pulse_turn_url',  value: urls.first.toString());
          await ss.write(key: 'pulse_turn_user', value: turnUser);
          await ss.write(key: 'pulse_turn_pass', value: turnPass);
          debugPrint('[Pulse] TURN creds saved: $urls');

          // Start local TLS-terminating proxy for TURNS URLs.
          // Linux: BoringSSL lacks ISRG Root X1 (Let's Encrypt)
          // Android/Waydroid: native WebRTC TLS TURN broken in container
          if (Platform.isLinux || Platform.isAndroid) {
            for (final u in urls) {
              final s = u.toString();
              if (s.startsWith('turns:')) {
                final m = RegExp(r'^turns:([^:/?]+):?(\d+)?').firstMatch(s);
                if (m != null) {
                  final host = m.group(1)!;
                  final port = int.tryParse(m.group(2) ?? '') ?? 443;
                  final ok = await PulseTurnProxy.instance.start(host, port);
                  if (ok) debugPrint('[Pulse] TurnProxy started → ${PulseTurnProxy.instance.localTurnUrl}');
                }
                break; // one proxy is enough
              }
            }
          }
        }
      }
      // Save cert fingerprint from auth_ok if provided
      final certFp = data['cert_fp'] as String? ?? '';
      if (certFp.isNotEmpty && _certFingerprint.isEmpty) {
        _certFingerprint = certFp.toLowerCase();
      }
    } catch (e) {
      debugPrint('[Pulse] Failed to save TURN creds: $e');
    }
  }

  Future<int> _getLastFetchTs() async {
    final prefs = await _getPrefs();
    final stored = prefs.getInt('pulse_last_fetch_ts') ?? 0;
    final thirtyDaysAgo =
        DateTime.now().millisecondsSinceEpoch ~/ 1000 - 30 * 86400;
    return stored > thirtyDaysAgo ? stored - 60 : thirtyDaysAgo;
  }

  Future<void> _updateLastFetchTs(int unixSeconds) async {
    final prefs = await _getPrefs();
    final current = prefs.getInt('pulse_last_fetch_ts') ?? 0;
    if (unixSeconds > current) {
      await prefs.setInt('pulse_last_fetch_ts', unixSeconds);
    }
  }

  Future<void> _runLoop() async {
    _shared.readerActive = true;
    while (_running) {
      WebSocketChannel? channel;
      bool cycleSuccess = false;
      Timer? cbrTimer;
      Timer? rotationTimer;
      if (!_running) break;

      try {
        channel = await _connectWs();
        await channel.ready;
        debugPrint('[Pulse] Connected to $_wsUrl');
        // Track current channel so close() can tear it down even before auth
        // completes — otherwise a concurrent reader restart (e.g. from
        // reconnectInbox) leaves the old pre-auth connection competing with
        // the new one and the server kicks back and forth between them.
        _ws = channel;
        if (!_running) {
          try { channel.sink.close(); } catch (_) {}
          break;
        }

        // Send hello — server waits for this before sending auth_challenge
        // (probe resistance: server is silent until client proves protocol knowledge)
        channel.sink.add(jsonEncode({'type': 'hello'}));

        // Single stream listener — handles auth then messages
        bool authenticated = false;
        try {
          await for (final raw in channel.stream) {
            try {
              // ── Binary frame handling (padding, TURN-over-WS, etc.) ──
              if (raw is List<int>) {
                if (raw.isNotEmpty && raw[0] == 0x30 && raw.length > 1) {
                  // TURN-over-WebSocket: forward STUN data to local PulseTurnProxy
                  PulseTurnProxy.onTurnBinaryFrame(raw.sublist(1));
                }
                // 0xFF = server CBR/burst padding frame → silently discard
                // Other binary types (file, media, tunnel) not handled by reader
                continue;
              }

              final data = jsonDecode(raw as String) as Map<String, dynamic>;
              final type = data['type'] as String? ?? '';

              // Server chaff: messages from unknown senders are silently
              // dropped downstream (no Signal session → decrypt fails).

              // ── Auth phase ──
              if (!authenticated) {
                if (type == 'auth_challenge') {
                  final nonce = data['nonce'] as String? ?? '';
                  final timestamp = (data['ts'] ?? data['timestamp'])?.toString() ?? '';
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
                  debugPrint('[Pulse] Auth challenge received (nonce=${nonce.substring(0, nonce.length < 8 ? nonce.length : 8)}...)');

                  // Solve PoW if server requires it
                  final powSeed = data['pow_seed'] as String? ?? '';
                  final powDifficulty = data['pow_difficulty'] as int? ?? 0;
                  int powNonce = 0;
                  if (powSeed.isNotEmpty && powDifficulty > 0) {
                    debugPrint('[Pulse] Solving PoW (difficulty=$powDifficulty)...');
                    powNonce = await _solvePoW(powSeed, powDifficulty);
                    debugPrint('[Pulse] PoW solved (nonce=$powNonce)');
                  }

                  final message = 'pulse-auth:$nonce:$timestamp';
                  final signature = await _ed25519Sign(_seed, message);
                  debugPrint('[Pulse] Auth response sent');

                  channel.sink.add(jsonEncode({
                    'type': 'auth_response',
                    'pubkey': _pubkeyHex,
                    'signature': signature,
                    'nonce': nonce,
                    'timestamp': tsVal,
                    'invite': _invite,
                    if (powSeed.isNotEmpty) 'pow_seed': powSeed,
                    if (powSeed.isNotEmpty) 'pow_nonce': powNonce,
                  }));
                } else if (type == 'auth_ok') {
                  _saveTurnCreds(data);

                  // Store sealed sender delivery certificates
                  final sealedCerts = data['sealed_certs'];
                  if (sealedCerts is List) {
                    _shared.sealedCerts.clear();
                    for (final c in sealedCerts) {
                      if (c is Map<String, dynamic>) {
                        _shared.sealedCerts.add((
                          token: c['token'] as String? ?? '',
                          expires: c['expires'] as int? ?? 0,
                        ));
                      }
                    }
                    if (_shared.sealedCerts.isNotEmpty) {
                      debugPrint('[Pulse] Received ${_shared.sealedCerts.length} sealed certs');
                    }
                  }

                  authenticated = true;
                  final pendingCount = data['pending_count'] ?? 0;
                  final serverName = data['server'] as String? ?? '';
                  debugPrint('[Pulse] Authenticated as ${_pubkeyHex.substring(0, 8)}... '
                      '(pending=$pendingCount${serverName.isNotEmpty ? ', server=$serverName' : ''})');

                  // Start upstream CBR padding if server advertises it
                  final privacy = data['privacy'];
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
                  channel.sink.add(jsonEncode({
                    'type': 'fetch',
                    'since': since,
                    'limit': 100,
                  }));

                  cycleSuccess = true;
                  _ws = channel;
                  // Publish to shared pool so PulseMessageSender reuses
                  // this connection instead of opening a competing one.
                  _shared.channel = channel;
                  _shared.authenticated = true;
                  _shared.serverHealthy = true;
                  // Set WS channel for TURN-over-WebSocket (single connection)
                  PulseTurnProxy.setWebSocketChannel(channel);
                  if (!_isHealthy && !_healthCtrl.isClosed) {
                    _isHealthy = true;
                    _healthCtrl.add(true);
                  }
                  _consecutiveFailures = 0;

                  // Connection rotation: reconnect after 10-30 min
                  // to mimic normal browsing. Skip during calls.
                  final rotateMin = 10 + _secureRng.nextInt(21); // 10-30
                  rotationTimer?.cancel();
                  rotationTimer = Timer(Duration(minutes: rotateMin), () {
                    if (!_PulseSharedWs.callActive) {
                      debugPrint('[Pulse] Connection rotation (${rotateMin}m)');
                      try { channel?.sink.close(); } catch (_) {}
                    }
                  });
                } else if (type == 'error') {
                  debugPrint('[Pulse] Auth error: ${data['message'] ?? data}');
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
                  final storedId = data['id'] as String?;
                  if (storedId != null && storedId.isNotEmpty) {
                    _shared.serverAckCtrl.add(storedId);
                  }
                  _dispatchStored(data, channel);
                case 'ack':
                  debugPrint('[Pulse] ACK: ${data['id'] ?? ''}');
                case 'keys':
                  // Complete pending keys completer (for fetchContactKeys)
                  final kPub = data['pubkey'] as String? ?? '';
                  if (kPub.isNotEmpty) {
                    final kc = _shared.pendingKeysCompleters.remove(kPub);
                    if (kc != null && !kc.isCompleted) {
                      final bundle = data['bundle'];
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
                  debugPrint('[Pulse] Server error: ${data['message'] ?? data}');
                // SFU message types — forward through signal stream
                case 'room_created':
                case 'room_info':
                case 'room_left':
                case 'media_answer':
                case 'media_renegotiate':
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
                case 'signal_fail':
                  // Recipient offline for ephemeral signal (typing/heartbeat) — expected, ignore.
                  debugPrint('[Pulse] signal_fail to=${data['to']} reason=${data['reason']}');
                  break;
                case 'error':
                  debugPrint('[Pulse] server error code=${data['code']} msg=${data['message']}');
                  break;
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
        rotationTimer?.cancel();
        rotationTimer = null;
        // Only clear shared pool if WE own it (sender may have taken over)
        if (_shared.channel == channel) {
          _shared.channel = null;
          _shared.authenticated = false;
          PulseTurnProxy.setWebSocketChannel(null);
        }
        // Flag unhealthy only on post-auth disconnect (a reader that was
        // authenticated and lost its connection = real server issue). Skip
        // pre-auth closes since they usually happen when the reader is
        // replaced during reconnect (Nostr probe etc.) and the new reader
        // is about to auth — flagging in that case causes the sender to
        // spuriously fall back to Session for a few seconds.
        if (cycleSuccess) _shared.serverHealthy = false;
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
    // Server sends flat: {type, id, from, payload, created} or {type, id, from, body, ts}
    // Handle both: payload may be a nested Map (legacy) or the fields are at top level.
    final rawPayload = data['payload'];
    final payload = (rawPayload is Map<String, dynamic>) ? rawPayload : data;
    final id = payload['id'] as String? ?? '';
    if (id.isEmpty || _seenIds.contains(id)) return;
    _trackSeenId(id);

    final rawTs = payload['timestamp'] as int? ??
        payload['ts'] as int? ??
        payload['created'] as int? ??
        (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    unawaited(_updateLastFetchTs(rawTs));

    // Clamp timestamp to ±7 days of local clock to prevent ordering attacks.
    final now = DateTime.now();
    final claimed = DateTime.fromMillisecondsSinceEpoch(rawTs * 1000, isUtc: true);
    final msgTs = claimed.difference(now).abs() <= const Duration(days: 7) ? claimed : now;

    // Encrypted body: try 'payload' (string), then 'body'
    var encBody = (rawPayload is String) ? rawPayload
        : payload['body'] as String? ?? payload['payload'] as String? ?? '';
    // Defensive: strip surrounding quotes from double-encoded body
    if (encBody.length >= 2 && encBody.startsWith('"') && encBody.endsWith('"')) {
      encBody = encBody.substring(1, encBody.length - 1);
    }

    final msg = Message(
      id: id,
      senderId: payload['from'] as String? ?? '',
      receiverId: _pubkeyHex,
      encryptedPayload: encBody,
      timestamp: msgTs,
      adapterType: 'pulse',
    );
    if (!_msgCtrl.isClosed) _msgCtrl.add([msg]);

    // Send ACK
    _sendAck(id);
  }

  void _dispatchSignal(Map<String, dynamic> data) {
    debugPrint('[Pulse] _dispatchSignal from=${data['from']} keys=${data.keys.toList()}');
    final rawPayload = data['payload'];
    final payload = (rawPayload is Map<String, dynamic>) ? rawPayload : data;
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
      // Inject senderId from server's 'from' field if not present
      if (data['from'] is String && (signalData['senderId'] as String? ?? '').isEmpty) {
        signalData['senderId'] = data['from'];
      }
      // Security: override adapterType so a compromised/MITM Pulse server
      // cannot inject adapterType='nostr' and bypass HMAC verification.
      signalData['adapterType'] = 'pulse';
      debugPrint('[Pulse] signal → stream type=${signalData['type']} senderId=${signalData['senderId']}');
      if (!_sigCtrl.isClosed) _sigCtrl.add([signalData]);
    } catch (e, st) {
      debugPrint('[Pulse] Signal dispatch error: $e\n$st');
    }

    if (id.isNotEmpty) _sendAck(id);
  }

  void _dispatchStored(Map<String, dynamic> data, WebSocketChannel channel) {
    final messages = data['messages'] as List? ?? [];
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
    final rawP = data['payload'];
    final payload = (rawP is Map<String, dynamic>) ? rawP : null;
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
      _ws?.sink.add(jsonEncode({'type': 'ack', 'id': messageId}));
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

      // Send hello — server waits for this before sending auth_challenge
      channel.sink.add(jsonEncode({'type': 'hello'}));

      final completer = Completer<Map<String, dynamic>?>();
      Timer(const Duration(seconds: 15), () {
        if (!completer.isCompleted) completer.complete(null);
      });

      bool authenticated = false;
      final sub = channel.stream.listen((raw) {
        try {
          if (raw is List<int>) return; // binary padding → ignore
          final data = jsonDecode(raw as String) as Map<String, dynamic>;
          // Server chaff: unknown sender → decrypt fails → silently dropped.
          final type = data['type'] as String? ?? '';
          if (!authenticated) {
            if (type == 'auth_challenge') {
              final nonce = data['nonce'] as String? ?? '';
              final tsVal = int.tryParse((data['ts'] ?? data['timestamp'])?.toString() ?? '') ?? 0;
              if (nonce.isEmpty) {
                if (!completer.isCompleted) completer.complete(null);
                return;
              }
              // Solve PoW + sign in async chain
              final powSeed = data['pow_seed'] as String? ?? '';
              final powDifficulty = data['pow_difficulty'] as int? ?? 0;
              () async {
                int powNonce = 0;
                if (powSeed.isNotEmpty && powDifficulty > 0) {
                  powNonce = await _solvePoW(powSeed, powDifficulty);
                }
                final msg = 'pulse-auth:$nonce:$tsVal';
                final sig = await _ed25519Sign(_seed, msg);
                channel!.sink.add(jsonEncode({
                  'type': 'auth_response',
                  'pubkey': _pubkeyHex,
                  'signature': sig,
                  'nonce': nonce,
                  'timestamp': tsVal,
                  'invite': _invite,
                  if (powSeed.isNotEmpty) 'pow_seed': powSeed,
                  if (powSeed.isNotEmpty) 'pow_nonce': powNonce,
                }));
              }();
            } else if (type == 'auth_ok') {
              authenticated = true;
              channel!.sink.add(jsonEncode({'type': 'keys_get', 'pubkey': _pubkeyHex}));
            } else if (type == 'error') {
              if (!completer.isCompleted) completer.complete(null);
            }
          } else if (type == 'keys') {
            final bundle = data['bundle'];
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
    _msgCtrl.close();
    _sigCtrl.close();
    _healthCtrl.close();
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

  /// TLS cert SHA-256 fingerprint parsed from `#suffix` in serverUrl.
  String _certFingerprint = '';

  /// Per-server shared state. Each Pulse server the client touches has
  /// its own pool entry; the sender always borrows from the entry that
  /// matches its `_serverUrl` so a sender configured for server-A never
  /// reads/writes the server-B channel.
  _PulseSharedWs get _shared => _PulseSharedWs.forUrl(_serverUrl);

  // Tor settings
  bool _torEnabled = false;
  String _torHost = '127.0.0.1';
  int _torPort = 9050;

  // CF Worker relay proxy
  String _cfWorkerRelay = '';

  // Force-Tor mode
  bool _forcePulseTor = false;

  SharedPreferences? _prefs;
  Future<SharedPreferences> _getPrefs() async =>
      _prefs ??= await SharedPreferences.getInstance();

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
    } else if (_serverUrl.startsWith('http://')) {
      debugPrint('[Pulse] Sender rejected http:// server URL — use https://');
      _wsUrl = '';
    }

    // Load Tor + CF Worker + Force-Tor settings
    final prefs = await _getPrefs();
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
    final prefs = await _getPrefs();
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
        debugPrint('[Pulse/Sender] Force-Tor: uTLS+Tor chain to $_wsUrl');
        final ch = await _connectPulseWebSocketViaUtls(
            _wsUrl, utlsPort,
            upstreamSocks5: '$_torHost:$_torPort',
            protocols: ['mqtt'])
            .timeout(const Duration(seconds: 20));
        return ch;
      } catch (e) {
        debugPrint('[Pulse/Sender] Force-Tor uTLS+Tor failed ($e) — plain Tor');
      }
      try {
        final ch = await tor.connectWebSocket(_wsUrl,
            torHost: _torHost, torPort: _torPort,
            socks5Timeout: const Duration(seconds: 8),
            protocols: ['mqtt']);
        return ch;
      } catch (e) {
        debugPrint('[Pulse/Sender] Force-Tor plain Tor failed ($e) — next');
      }
    }

    // 2. uTLS+ECH
    if (utlsPort != null && !_forcePulseTor) {
      try {
        final ch = await _connectPulseWebSocketViaUtls(_wsUrl, utlsPort,
                protocols: ['mqtt'])
            .timeout(const Duration(seconds: 8));
        return ch;
      } catch (e) {
        debugPrint('[Pulse/Sender] uTLS+ECH failed ($e) — next');
      }
    }

    // 3. Tor SOCKS5
    if (torActive && !_forcePulseTor) {
      try {
        final ch = await tor.connectWebSocket(_wsUrl,
            torHost: _torHost, torPort: _torPort,
            socks5Timeout: const Duration(seconds: 8),
            protocols: ['mqtt']);
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
        final workerUrl = workerUri.replace(queryParameters: {'r': _wsUrl}).toString();
        debugPrint('[Pulse/Sender] Trying CF Worker: $workerUrl');
        final inner = _buildHttpClient();
        final ws = await WebSocket.connect(workerUrl, customClient: inner,
                protocols: ['mqtt'])
            .timeout(const Duration(seconds: 12));
        ws.pingInterval = _randomPingInterval();
        return IOWebSocketChannel(ws);
      } catch (e) {
        debugPrint('[Pulse/Sender] CF Worker failed ($e) — plain');
      }
    }

    // 5. Direct
    final inner = _buildHttpClient();
    final ws = await WebSocket.connect(
      _wsUrl,
      customClient: inner,
      protocols: ['mqtt'],
    ).timeout(const Duration(seconds: 10));
    ws.pingInterval = _randomPingInterval();
    return IOWebSocketChannel(ws);
  }

  /// Get an authenticated WS connection, reusing if available.
  /// Prefers the reader's shared connection to avoid server kicking it.
  /// Server only allows 1 connection per pubkey — sender MUST NOT create
  /// a duplicate connection when the reader is active.
  Future<WebSocketChannel?> _getConnection() async {
    // 1. Reuse own cached connection
    final ws = _ws;
    if (ws != null && _authenticated) return ws;

    // 2. Borrow the reader's long-lived connection (avoids duplicate auth)
    if (_shared.channel != null && _shared.authenticated) {
      return _shared.channel;
    }

    // 2b. Reader is active — wait for it to connect+authenticate.
    //     Creating a duplicate connection would kick the reader from the hub.
    //     If the reader has already signalled the server is down, skip
    //     entirely so the caller falls back to Nostr/Session without delay.
    if (_shared.readerActive) {
      if (!_shared.serverHealthy) {
        debugPrint('[Pulse/Sender] Reader reports server unhealthy — skipping Pulse');
        return null;
      }
      debugPrint('[Pulse/Sender] Waiting for reader to authenticate...');
      for (int i = 0; i < 30; i++) { // up to 3 seconds
        await Future.delayed(const Duration(milliseconds: 100));
        if (_shared.authenticated && _shared.channel != null) {
          debugPrint('[Pulse/Sender] Reader authenticated, borrowing connection');
          return _shared.channel;
        }
        // Reader marked server dead mid-wait — bail early.
        if (!_shared.serverHealthy) {
          debugPrint('[Pulse/Sender] Server marked unhealthy mid-wait — skipping');
          return null;
        }
      }
      debugPrint('[Pulse/Sender] Reader auth wait timed out (3s)');
      return null; // don't create duplicate — let caller handle failure
    }

    // 3. No reader at all — create own (rare: reader not started yet)
    try {
      final channel = await _connectWs();
      await channel.ready;

      // Send hello — server waits for this before sending auth_challenge
      channel.sink.add(jsonEncode({'type': 'hello'}));

      // Authenticate — single stream listener handles both auth and runtime.
      final completer = Completer<bool>();
      channel.stream.listen((raw) async {
        try {
          if (raw is List<int>) return; // binary padding → ignore
          final data = jsonDecode(raw as String) as Map<String, dynamic>;
          // Server chaff: unknown sender → decrypt fails → silently dropped.
          final type = data['type'] as String? ?? '';

          // ── Auth phase ──
          if (!completer.isCompleted) {
            if (type == 'auth_challenge') {
              final nonce = data['nonce'] as String? ?? '';
              final timestamp = (data['ts'] ?? data['timestamp'])?.toString() ?? '';
              final tsVal = int.tryParse(timestamp) ?? 0;
              final serverTime = DateTime.fromMillisecondsSinceEpoch(tsVal * 1000);
              if (nonce.isEmpty || nonce.length > 256 ||
                  DateTime.now().difference(serverTime).abs() > const Duration(minutes: 5)) {
                debugPrint('[Pulse/Sender] Auth challenge invalid — nonce or timestamp rejected');
                completer.complete(false);
                return;
              }
              // Solve PoW if required
              final powSeed = data['pow_seed'] as String? ?? '';
              final powDifficulty = data['pow_difficulty'] as int? ?? 0;
              int powNonce = 0;
              if (powSeed.isNotEmpty && powDifficulty > 0) {
                debugPrint('[Pulse/Sender] Solving PoW (difficulty=$powDifficulty)...');
                powNonce = await _solvePoW(powSeed, powDifficulty);
                debugPrint('[Pulse/Sender] PoW solved (nonce=$powNonce)');
              }
              final message = 'pulse-auth:$nonce:$timestamp';
              final signature = await _ed25519Sign(_seed, message);
              channel.sink.add(jsonEncode({
                'type': 'auth_response',
                'pubkey': _pubkeyHex,
                'signature': signature,
                'nonce': nonce,
                'timestamp': tsVal,
                'invite': '',
                if (powSeed.isNotEmpty) 'pow_seed': powSeed,
                if (powSeed.isNotEmpty) 'pow_nonce': powNonce,
              }));
            } else if (type == 'auth_ok') {
              final certFp = data['cert_fp'] as String? ?? '';
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
            final pubkey = data['pubkey'] as String? ?? '';
            final bundle = data['bundle'];
            Map<String, dynamic>? bundleMap;
            if (bundle is Map<String, dynamic>) {
              bundleMap = bundle;
            } else if (bundle is String) {
              try { bundleMap = jsonDecode(bundle) as Map<String, dynamic>; } catch (_) {}
            }
            final keysCompleter = _shared.pendingKeysCompleters.remove(pubkey);
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
        for (final c in _shared.pendingKeysCompleters.values) {
          if (!c.isCompleted) c.complete(null);
        }
        _shared.pendingKeysCompleters.clear();
      }, onDone: () {
        if (!completer.isCompleted) completer.complete(false);
        _ws = null;
        _authenticated = false;
        for (final c in _shared.pendingKeysCompleters.values) {
          if (!c.isCompleted) c.complete(null);
        }
        _shared.pendingKeysCompleters.clear();
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

  /// Pop a valid (non-expired) sealed cert, or null if none available.
  ({String token, int expires})? _popSealedCert() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    while (_shared.sealedCerts.isNotEmpty) {
      final cert = _shared.sealedCerts.removeLast();
      if (cert.expires > now && cert.token.isNotEmpty) return cert;
    }
    return null;
  }

  /// Send a message via the sealed sender endpoint (one-shot anonymous WS).
  Future<bool> _sendSealed(String cert, String targetPubkey, String body) async {
    final sealedUrl = _wsUrl.replaceFirst('/ws', '/sealed');
    WebSocketChannel? ch;
    try {
      final inner = _buildHttpClient();
      final ws = await WebSocket.connect(sealedUrl,
              customClient: inner, protocols: ['mqtt'])
          .timeout(const Duration(seconds: 10));
      ch = IOWebSocketChannel(ws);
      await ch.ready;

      ch.sink.add(jsonEncode({
        'type': 'sealed_send',
        'cert': cert,
        'to': targetPubkey,
        'body': body,
      }));

      // Wait for single response
      final resp = await ch.stream.first.timeout(const Duration(seconds: 10));
      if (resp is String) {
        final data = jsonDecode(resp) as Map<String, dynamic>;
        if (data['status'] == 'ok' || data['type'] == 'sealed_ack') return true;
      }
      return false;
    } catch (e) {
      debugPrint('[Pulse] sendSealed error: $e');
      return false;
    } finally {
      try { ch?.sink.close(); } catch (_) {}
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

    // Client-side send jitter for traffic decorrelation
    await _sendJitter();

    // Try sealed sender first (anonymous delivery)
    final cert = _popSealedCert();
    if (cert != null) {
      final ok = await _sendSealed(cert.token, targetPubkey, message.encryptedPayload);
      if (ok) return true;
      debugPrint('[Pulse] Sealed send failed, falling back to normal send');
    }

    try {
      final channel = await _getConnection();
      if (channel == null) return false;

      // Append random suffix so rapid-fire messages within the same millisecond
      // get distinct IDs and are not deduplicated/dropped by the relay.
      final msgId = message.id.isNotEmpty
          ? message.id
          : '${DateTime.now().millisecondsSinceEpoch}_${Random.secure().nextInt(0xFFFFFF).toRadixString(16)}';

      channel.sink.add(_bucketPad(jsonEncode({
        'type': 'send',
        'id': msgId,
        'to': targetPubkey,
        'body': message.encryptedPayload,
      })));
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

      channel.sink.add(_bucketPad(jsonEncode({
        'type': 'signal',
        'to': targetPubkey,
        'payload': signalPayload,
      })));
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

      channel.sink.add(jsonEncode({'type': 'keys_put', 'bundle': bundle}));
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
      final completer = _shared.pendingKeysCompleters.putIfAbsent(
          pubkey, () => Completer<Map<String, dynamic>?>());

      channel.sink.add(jsonEncode({'type': 'keys_get', 'pubkey': pubkey}));

      Timer(const Duration(seconds: 10), () {
        final c = _shared.pendingKeysCompleters.remove(pubkey);
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
      final shared = _shared.channel;
      if (shared != null && _shared.authenticated) {
        shared.sink.add(jsonMsg);
      } else {
        debugPrint('[Pulse] sendRaw: no authenticated connection');
      }
    }
  }

  /// Clear private key from memory and close connection.
  void zeroize() {
    for (final c in _shared.pendingKeysCompleters.values) {
      if (!c.isCompleted) c.complete(null);
    }
    _shared.pendingKeysCompleters.clear();
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

/// Stream of message IDs confirmed stored by ANY connected Pulse server.
///
/// Multiplexes the per-server `serverAckCtrl` streams from every pool
/// entry. New pool entries added after this getter is first called are
/// also picked up — `_PulseSharedWs._pool` is observed indirectly
/// because [_PulseSharedWs.forUrl] calls `register` here when it
/// inserts a fresh entry.
StreamController<String>? _pulseServerAcksMux;
Stream<String> get pulseServerAcks {
  final mux = _pulseServerAcksMux ??= () {
    final c = StreamController<String>.broadcast();
    // Hook into current pool entries.
    for (final s in _PulseSharedWs._pool.values) {
      s.serverAckCtrl.stream.listen(c.add);
    }
    // Future entries register themselves via _PulseSharedWs.forUrl().
    _PulseSharedWs._onNewPoolEntry = (s) => s.serverAckCtrl.stream.listen(c.add);
    return c;
  }();
  return mux.stream;
}
