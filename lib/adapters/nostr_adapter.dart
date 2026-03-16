import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:convert/convert.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:pointycastle/export.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';
import '../services/tor_service.dart' as tor;
import '../services/utls_service.dart';
import '../services/cloudflare_ip_service.dart';
import 'inbox_manager.dart';

/// ─────────────────────────────────────────────────────────
/// Nostr Adapter — Signal Protocol over Nostr transport
///
/// Protocol mapping:
///   kind 4    → Chat message (content = Signal-encrypted payload, no NIP-04)
///   kind 10009 → Signal public key bundle (unencrypted, replaceable)
///   kind 20000 → Ephemeral signaling event (WebRTC, NIP-04 encrypted)
/// ─────────────────────────────────────────────────────────

const _defaultRelay = 'wss://relay.damus.io';

/// Connects a WebSocket to [url] using pre-resolved [ips] (bypasses system DNS).
///
/// This is the key censorship workaround: GFW sometimes poisons DNS for
/// CF-hosted Nostr relays. We use DoH-resolved IPs to connect directly,
/// letting HttpClient handle TLS with the original hostname as SNI.
///
/// Strategy: connect plain TCP to the resolved IP, then let dart:io's
/// HttpClient do the TLS+WebSocket upgrade using the original hostname
/// (from the URL) for SNI — exactly as the Tor bridge does with loopback.
Future<WebSocketChannel> _connectDirectViaIps(
    String url, List<String> ips) async {
  final uri = Uri.parse(url);
  final port = (uri.hasPort && uri.port != 0)
      ? uri.port
      : (uri.scheme == 'wss' ? 443 : 80);
  final normalized = (!uri.hasPort || uri.port == 0)
      ? uri.replace(port: port).toString()
      : url;

  Exception? lastErr;
  for (final ip in ips) {
    try {
      final httpClient = HttpClient();
      httpClient.connectionFactory = (cfUri, proxyHost, proxyPort) async {
        // Plain TCP to the CF IP — HttpClient sees the original URL host for SNI
        final raw = await Socket.connect(ip, port,
            timeout: const Duration(seconds: 4));
        return ConnectionTask.fromSocket(
            Future.value(raw), () => raw.destroy());
      };
      final ws = await WebSocket.connect(normalized, customClient: httpClient)
          .timeout(const Duration(seconds: 4));
      return IOWebSocketChannel(ws);
    } catch (e) {
      lastErr = e is Exception ? e : Exception(e.toString());
    }
  }
  throw lastErr ?? Exception('_connectDirectViaIps: no working IP');
}

/// Connect a WebSocket through the uTLS HTTP CONNECT proxy.
///
/// Mirrors TorService.connectWebSocket (SOCKS5 pattern) but sends an
/// HTTP CONNECT request instead of a SOCKS5 handshake.  This avoids
/// Dart's WebSocket.connect/findProxy bug that produces "https://host:0#"
/// when routing wss:// through an HTTP CONNECT proxy.
Future<WebSocketChannel> _connectWebSocketViaUtls(
    String url, int proxyPort) async {
  final uri = Uri.parse(url);
  final targetHost = uri.host;
  final targetPort =
      uri.hasPort ? uri.port : (uri.scheme == 'wss' ? 443 : 80);

  // 1. Bind a throw-away local bridge so HttpClient can connect normally.
  final server = await ServerSocket.bind(
      InternetAddress.loopbackIPv4, 0,
      shared: false);
  final bridgePort = server.port;

  // 2. Handle exactly one client connection → proxy it through uTLS proxy.
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

      // Proxy → client (buffered until tunnel ready).
      proxy.listen(
        (data) {
          if (!tunnelReady) {
            rxBuf.addAll(data);
            for (final w in [...waiters]) { if (!w.isCompleted) w.complete(); }
            waiters.removeWhere((c) => c.isCompleted);
          } else {
            try { client.add(data); } catch (_) {}
          }
        },
        onDone: () { try { client.close(); } catch (_) {} },
        onError: (Object _) { client.destroy(); proxy?.destroy(); },
        cancelOnError: true,
      );

      // Client → proxy (buffered until tunnel ready).
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

      // HTTP CONNECT request.
      proxy.write(
          'CONNECT $targetHost:$targetPort HTTP/1.1\r\n'
          'Host: $targetHost:$targetPort\r\n\r\n');

      // Wait for "HTTP/1.x 200 …\r\n\r\n".
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
          .timeout(const Duration(seconds: 10), onTimeout: () => false);
      if (!ok) {
        debugPrint('[Nostr] uTLS CONNECT to $targetHost:$targetPort refused');
        client.destroy();
        proxy.destroy();
        return;
      }

      tunnelReady = true;
      // Flush any proxy bytes received after the 200 header.
      if (rxBuf.isNotEmpty) {
        try { client.add(Uint8List.fromList(rxBuf)); } catch (_) {}
        rxBuf.clear();
      }
      // Flush client data buffered before tunnel was ready.
      for (final d in clientBuf) {
        try { proxy.add(d); } catch (_) {}
      }
    } catch (e) {
      debugPrint('[Nostr] uTLS bridge error: $e');
      client.destroy();
      proxy?.destroy();
    }
  }).catchError((_) {}));

  // 3. HttpClient whose connectionFactory uses our local bridge.
  //    WebSocket.connect(url) sees the original host for correct TLS SNI.
  final httpClient = HttpClient();
  httpClient.connectionFactory = (uri2, proxyHost2, proxyPort2) async {
    final s = await Socket.connect(
        InternetAddress.loopbackIPv4, bridgePort,
        timeout: const Duration(seconds: 60));
    return ConnectionTask.fromSocket(Future.value(s), () => s.destroy());
  };

  // 4. dart:io handles TLS negotiation + HTTP WebSocket upgrade.
  //
  // Dart doesn't know the default port for the 'wss' scheme (only 'https'),
  // so `wss://host` → port 0 internally → wrong Host header → relay rejects.
  // Explicitly set port 443 so the upgrade request carries the correct Host.
  final wsUri = Uri.parse(url);
  final normalizedUrl = (!wsUri.hasPort || wsUri.port == 0)
      ? wsUri.replace(port: wsUri.scheme == 'wss' ? 443 : 80).toString()
      : url;
  try {
    final ws = await WebSocket.connect(normalizedUrl, customClient: httpClient);
    return IOWebSocketChannel(ws);
  } catch (e) {
    try { await server.close(); } catch (_) {}
    rethrow;
  }
}

// ─── Shared WebSocket connect (CF-direct → Tor → I2P → uTLS → plain) ───────
//
// Single implementation used by both InboxReader and Sender.
// Connection chain: CF-direct (DoH-resolved) → Tor SOCKS5 → I2P SOCKS5
//                   → uTLS (Chrome TLS fingerprint) → plain WebSocket.
//
// NOTE: I2P is an external proxy — the app doesn't bundle an I2P daemon.
// Users who run their own I2P router can configure the SOCKS5 endpoint in
// Settings → I2P Proxy. This enables routing Nostr traffic through I2P
// outproxies (e.g. relay.damus.i2p) as an additional censorship bypass.

Future<WebSocketChannel> _nostrWsConnect(
  String url, {
  required bool torEnabled,
  required String torHost,
  required int torPort,
  required bool i2pEnabled,
  required String i2pHost,
  required int i2pPort,
}) async {
  // Step 0: CF-direct with DoH-resolved IP (bypasses poisoned system DNS)
  try {
    final host = Uri.parse(url).host;
    if (host.isNotEmpty) {
      final (isCf, ips) = await CloudflareIpService.instance
          .resolveAndCheck(host)
          .timeout(const Duration(seconds: 4),
              onTimeout: () => (false, <String>[]));
      if (isCf && ips.isNotEmpty) {
        try {
          final ch = await _connectDirectViaIps(url, ips);
          debugPrint('[Nostr] CF-direct (DoH): $url via ${ips.first}');
          return ch;
        } catch (_) {
          debugPrint('[Nostr] CF-direct failed → Tor fallback: $url');
        }
      }
    }
  } catch (_) {}

  // Priority: Tor → I2P → uTLS (Chrome fingerprint) → plain
  if (torEnabled && tor.TorService.instance.isBootstrapped) {
    try {
      return await tor.connectWebSocket(url,
          torHost: torHost, torPort: torPort,
          socks5Timeout: const Duration(seconds: 8));
    } catch (e) {
      debugPrint('[Nostr] Tor path failed ($e) — trying uTLS');
    }
  }
  if (i2pEnabled) {
    try {
      return await tor.connectWebSocket(url,
          torHost: i2pHost, torPort: i2pPort,
          socks5Timeout: const Duration(seconds: 8));
    } catch (e) {
      debugPrint('[Nostr] I2P path failed ($e) — trying uTLS');
    }
  }
  final utlsPort = UTLSService.instance.proxyPort;
  if (utlsPort != null) {
    return _connectWebSocketViaUtls(url, utlsPort);
  }
  // Plain WebSocket — normalize port so Dart doesn't produce an invalid URI.
  final wsUri = Uri.parse(url);
  final normalized = (!wsUri.hasPort || wsUri.port == 0)
      ? wsUri.replace(port: wsUri.scheme == 'wss' ? 443 : 80).toString()
      : url;
  return WebSocketChannel.connect(Uri.parse(normalized));
}

// ─── Secp256k1 key utilities ──────────────────────────────

final _secp256k1 = ECCurve_secp256k1();

/// Public API: derive Nostr pubkey (x-coordinate) from hex private key
String deriveNostrPubkeyHex(String privkeyHex) => _derivePubkeyHex(privkeyHex);

String _derivePubkeyHex(String privkeyHex) {
  final d = BigInt.parse(privkeyHex, radix: 16);
  final G = _secp256k1.G;
  final Q = G * d;
  final xBytes = _bigIntToBytes(Q!.x!.toBigInteger()!, 32);
  return hex.encode(xBytes);
}

Uint8List _bigIntToBytes(BigInt n, int length) {
  final bytes = Uint8List(length);
  var value = n;
  for (int i = length - 1; i >= 0; i--) {
    bytes[i] = (value & BigInt.from(0xFF)).toInt();
    value = value >> 8;
  }
  return bytes;
}

Uint8List _sha256(List<int> data) {
  return Uint8List.fromList(crypto.sha256.convert(data).bytes);
}

Uint8List _taggedHash(String tag, List<int> data) {
  final tagHash = _sha256(utf8.encode(tag));
  return _sha256([...tagHash, ...tagHash, ...data]);
}

String _signEvent(String privkeyHex, String eventId) {
  final msgBytes = Uint8List.fromList(hex.decode(eventId));
  var d = BigInt.parse(privkeyHex, radix: 16);
  final n = _secp256k1.n;
  final G = _secp256k1.G;

  final P = G * d;
  if (P!.y!.toBigInteger()!.isOdd) d = n - d;

  final pubkeyHex = _derivePubkeyHex(privkeyHex);
  final pubBytes = Uint8List.fromList(hex.decode(pubkeyHex));
  final privBytes = Uint8List.fromList(hex.decode(privkeyHex));
  final randBytes = Uint8List(32);
  final auxRng = Random.secure();
  for (int i = 0; i < 32; i++) {
    randBytes[i] = auxRng.nextInt(256);
  }
  final nonceHash = _taggedHash('BIP0340/nonce', [...randBytes, ...privBytes, ...msgBytes]);
  var k = BigInt.parse(hex.encode(nonceHash), radix: 16) % n;
  if (k == BigInt.zero) k = BigInt.one;

  var R = G * k;
  if (R!.y!.toBigInteger()!.isOdd) {
    k = n - k;
    R = G * k;
  }
  final rx = _bigIntToBytes(R!.x!.toBigInteger()!, 32);
  final eBytes = _taggedHash('BIP0340/challenge', [...rx, ...pubBytes, ...msgBytes]);
  final e = BigInt.parse(hex.encode(eBytes), radix: 16) % n;
  final s = (k + e * d) % n;
  return hex.encode([...rx, ..._bigIntToBytes(s, 32)]);
}

String _buildEventId(Map<String, dynamic> event) {
  final serialized = jsonEncode([
    0, event['pubkey'], event['created_at'], event['kind'], event['tags'], event['content'],
  ]);
  return hex.encode(_sha256(utf8.encode(serialized)));
}

Map<String, dynamic> _buildEvent({
  required String privkeyHex,
  required int kind,
  required String content,
  List<List<String>>? tags,
}) {
  final pubkey = _derivePubkeyHex(privkeyHex);
  final createdAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final event = <String, dynamic>{
    'pubkey': pubkey, 'created_at': createdAt, 'kind': kind,
    'tags': tags ?? [], 'content': content,
  };
  final id = _buildEventId(event);
  event['id'] = id;
  event['sig'] = _signEvent(privkeyHex, id);
  return event;
}

// ─── NIP-04 (kept for WebRTC signaling only) ─────────────

String _nip04Encrypt(String senderPrivkeyHex, String recipientPubkeyHex, String plaintext) {
  const pHex = 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F';
  final p = BigInt.parse(pHex, radix: 16);
  final d = BigInt.parse(senderPrivkeyHex, radix: 16);
  final curve = _secp256k1.curve;
  final x = BigInt.parse(recipientPubkeyHex, radix: 16);
  final y2 = (x.modPow(BigInt.from(3), p) + BigInt.from(7)) % p;
  final y = y2.modPow((p + BigInt.one) ~/ BigInt.from(4), p);
  final useY = y.isEven ? y : p - y;
  final sharedPoint = curve.createPoint(x, useY) * d;
  final xVal = sharedPoint?.x?.toBigInteger();
  if (xVal == null) throw FormatException('NIP-04 encrypt: invalid shared point');
  final sharedX = _bigIntToBytes(xVal, 32);

  final rng = Random.secure();
  final iv = Uint8List.fromList(List.generate(16, (_) => rng.nextInt(256)));
  final plaintextBytes = Uint8List.fromList(utf8.encode(plaintext));
  final cipher = CBCBlockCipher(AESEngine());
  cipher.init(true, ParametersWithIV<KeyParameter>(KeyParameter(Uint8List.fromList(sharedX)), iv));
  final padLen = 16 - (plaintextBytes.length % 16);
  final padded = Uint8List(plaintextBytes.length + padLen)
    ..setAll(0, plaintextBytes)
    ..fillRange(plaintextBytes.length, plaintextBytes.length + padLen, padLen);
  final ciphertext = Uint8List(padded.length);
  for (int i = 0; i < padded.length; i += 16) { cipher.processBlock(padded, i, ciphertext, i); }
  return '${base64.encode(ciphertext)}?iv=${base64.encode(iv)}';
}

String _nip04Decrypt(String recipientPrivkeyHex, String senderPubkeyHex, String ciphertext) {
  final parts = ciphertext.split('?iv=');
  if (parts.length != 2) throw FormatException('Invalid NIP-04 ciphertext');
  final ct = base64.decode(parts[0]);
  final iv = base64.decode(parts[1]);
  const pHex = 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F';
  final p = BigInt.parse(pHex, radix: 16);
  final d = BigInt.parse(recipientPrivkeyHex, radix: 16);
  final curve = _secp256k1.curve;
  final x = BigInt.parse(senderPubkeyHex, radix: 16);
  final y2 = (x.modPow(BigInt.from(3), p) + BigInt.from(7)) % p;
  final y = y2.modPow((p + BigInt.one) ~/ BigInt.from(4), p);
  final useY = y.isEven ? y : p - y;
  final sharedPoint = curve.createPoint(x, useY) * d;
  final xVal = sharedPoint?.x?.toBigInteger();
  if (xVal == null) throw FormatException('NIP-04 decrypt: invalid shared point');
  final sharedX = _bigIntToBytes(xVal, 32);
  final cipher = CBCBlockCipher(AESEngine());
  cipher.init(false, ParametersWithIV<KeyParameter>(KeyParameter(Uint8List.fromList(sharedX)), Uint8List.fromList(iv)));
  final plainBytes = Uint8List(ct.length);
  for (int i = 0; i < ct.length; i += 16) { cipher.processBlock(Uint8List.fromList(ct), i, plainBytes, i); }
  final padLen = plainBytes.last;
  return utf8.decode(plainBytes.sublist(0, plainBytes.length - padLen));
}

// ─── InboxReader ─────────────────────────────────────────

class NostrInboxReader implements InboxReader {
  String _privateKeyHex = '';
  String _publicKeyHex = '';
  String _relayUrl = _defaultRelay;
  final Set<String> _seenIds = {};

  // Tor settings — loaded once in initializeReader
  bool _torEnabled = false;
  String _torHost = '127.0.0.1';
  int _torPort = 9050;

  // I2P settings — loaded once in initializeReader (Tor takes priority)
  bool _i2pEnabled = false;
  String _i2pHost = '127.0.0.1';
  int _i2pPort = 4447;

  Future<WebSocketChannel> _wsConnect(String url) => _nostrWsConnect(url,
      torEnabled: _torEnabled, torHost: _torHost, torPort: _torPort,
      i2pEnabled: _i2pEnabled, i2pHost: _i2pHost, i2pPort: _i2pPort);

  @override
  Future<void> initializeReader(String apiKey, String databaseId) async {
    // Parse databaseId: "pubkey@wss://relay" for contact readers, plain relay for own reader
    final wsIdx = databaseId.indexOf('@wss://');
    final wsIdx2 = databaseId.indexOf('@ws://');
    final atIdx = wsIdx != -1 ? wsIdx : (wsIdx2 != -1 ? wsIdx2 : -1);
    if (atIdx != -1) {
      _publicKeyHex = databaseId.substring(0, atIdx);
      _relayUrl = databaseId.substring(atIdx + 1);
    } else {
      _relayUrl = databaseId.isNotEmpty ? databaseId : _defaultRelay;
    }

    // Parse apiKey: JSON {"privkey":"...","relay":"..."} or raw hex or empty
    if (apiKey.startsWith('{')) {
      try {
        final decoded = jsonDecode(apiKey);
        _privateKeyHex = (decoded['privkey'] as String? ?? '').trim();
        final relayOverride = (decoded['relay'] as String? ?? '').trim();
        if (relayOverride.isNotEmpty && atIdx == -1) _relayUrl = relayOverride;
      } catch (_) {}
    } else if (apiKey.isNotEmpty && !apiKey.startsWith('{')) {
      _privateKeyHex = apiKey.trim();
    }

    // Derive own pubkey from privkey if not already set via databaseId
    if (_privateKeyHex.isNotEmpty && _publicKeyHex.isEmpty) {
      try { _publicKeyHex = _derivePubkeyHex(_privateKeyHex); } catch (_) {}
    }

    // Load Tor and I2P settings
    final prefs = await SharedPreferences.getInstance();
    _torEnabled = prefs.getBool('tor_enabled') ?? false;
    _torHost = prefs.getString('tor_host') ?? '127.0.0.1';
    _torPort = prefs.getInt('tor_port') ?? 9050;
    _i2pEnabled = prefs.getBool('i2p_enabled') ?? false;
    _i2pHost = prefs.getString('i2p_host') ?? '127.0.0.1';
    _i2pPort = prefs.getInt('i2p_port') ?? 4447;

    // If relay is still the hardcoded default, try probe-suggested or adaptive relay
    if (_relayUrl == _defaultRelay) {
      final adaptive = prefs.getString('adaptive_cf_relay') ?? '';
      if (adaptive.isNotEmpty) {
        _relayUrl = adaptive;
      } else {
        var probed = prefs.getString('probe_nostr_relay') ?? '';
        if (probed.isNotEmpty) {
          // Probe may store just the hostname without scheme — add wss:// if missing
          if (!probed.startsWith('ws://') && !probed.startsWith('wss://')) {
            probed = 'wss://$probed';
          }
          _relayUrl = probed;
        }
      }
    }
  }

  void _trackSeenId(String id) {
    if (_seenIds.length > 2000) {
      _seenIds.removeAll(_seenIds.take(1000).toList());
    }
    _seenIds.add(id);
  }

  // ── Shared WebSocket — one connection for both messages and signals ────────

  // Both listenForMessages() and listenForSignals() are backed by a single
  // WebSocket connection that subscribes to kind 4 (messages) and kind 20000
  // (signals) in one REQ. Events are dispatched to broadcast StreamControllers.
  final StreamController<List<Message>> _msgCtrl = StreamController.broadcast();
  final StreamController<List<Map<String, dynamic>>> _sigCtrl = StreamController.broadcast();
  final StreamController<bool> _healthCtrl = StreamController<bool>.broadcast();
  int _consecutiveFailures = 0;
  bool _isHealthy = true;
  static const _failureThreshold = 3;
  bool _loopStarted = false;

  @override
  Stream<bool> get healthChanges => _healthCtrl.stream;

  void _ensureLoop() {
    if (_loopStarted || _privateKeyHex.isEmpty) return;
    _loopStarted = true;
    unawaited(_runSharedLoop());
  }

  Future<void> _runSharedLoop() async {
    int retryDelay = 5;
    while (true) {
      WebSocketChannel? channel;
      bool cycleSuccess = false;
      try {
        channel = await _wsConnect(_relayUrl);
        await channel.ready;

        final subId = 'sub_${DateTime.now().millisecondsSinceEpoch}';
        final since = await _getSince();
        channel.sink.add(jsonEncode(['REQ', subId, {
          'kinds': [4, 20000],
          '#p': [_publicKeyHex],
          'since': since,
          'limit': 100,
        }]));

        retryDelay = 5; // reset backoff on successful connect
        cycleSuccess = true;
        if (!_isHealthy && !_healthCtrl.isClosed) {
          _isHealthy = true;
          _healthCtrl.add(true);
        }
        _consecutiveFailures = 0;

        try {
          await for (final raw in channel.stream) {
            try {
              final data = jsonDecode(raw as String) as List;
              if (data[0] == 'EOSE') {
                debugPrint('[Nostr] EOSE on $_relayUrl');
                continue;
              }
              if (data[0] != 'EVENT' || data[1] != subId) continue;
              final event = data[2] as Map<String, dynamic>;
              final id = event['id'] as String;
              if (_seenIds.contains(id)) continue;
              _trackSeenId(id);
              final ts = event['created_at'] as int?;
              if (ts != null) unawaited(_updateSince(ts));
              final kind = event['kind'] as int;
              if (kind == 4) {
                _dispatchMessage(event);
              } else if (kind == 20000) {
                _dispatchSignal(event);
              }
            } catch (e) {
              debugPrint('[Nostr] Parse error: $e');
            }
          }
        } finally {
          unawaited(channel.sink.close());
        }
      } catch (e) {
        debugPrint('[Nostr] Connection error: $e');
        try { channel?.sink.close(); } catch (_) {}
      }

      if (!cycleSuccess) {
        _consecutiveFailures++;
        if (_consecutiveFailures >= _failureThreshold && _isHealthy && !_healthCtrl.isClosed) {
          _isHealthy = false;
          _healthCtrl.add(false);
        }
      }
      debugPrint('[Nostr] Reconnecting in ${retryDelay}s…');
      await Future.delayed(Duration(seconds: retryDelay));
      retryDelay = (retryDelay * 2).clamp(5, 300);
    }
  }

  void _dispatchMessage(Map<String, dynamic> event) {
    try {
      _msgCtrl.add([Message(
        id: event['id'] as String,
        senderId: event['pubkey'] as String,
        receiverId: _publicKeyHex,
        encryptedPayload: event['content'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch((event['created_at'] as int) * 1000),
        adapterType: 'nostr',
      )]);
    } catch (e) {
      debugPrint('[Nostr] Failed to parse message: $e');
    }
  }

  void _dispatchSignal(Map<String, dynamic> event) {
    try {
      final senderPubkey = event['pubkey'] as String;
      final plain = _nip04Decrypt(_privateKeyHex, senderPubkey, event['content'] as String);
      final data = jsonDecode(plain) as Map<String, dynamic>;
      _sigCtrl.add([{
        'type': data['type'],
        'senderId': senderPubkey,
        'roomId': data['roomId'],
        'payload': data['payload'],
      }]);
    } catch (e) {
      debugPrint('[Nostr] Signal parse error: $e');
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

  // ─────────────────────────────────────────────────────────────────────────

  /// One-shot fetch of the contact's Signal public key bundle (kind 10009)
  @override
  Future<Map<String, dynamic>?> fetchPublicKeys() async {
    if (_publicKeyHex.isEmpty || _relayUrl.isEmpty) return null;
    final completer = Completer<Map<String, dynamic>?>();
    WebSocketChannel? channel;
    StreamSubscription<dynamic>? sub;
    try {
      channel = await _wsConnect(_relayUrl);
      await channel.ready;
      final subId = 'keys_${DateTime.now().millisecondsSinceEpoch}';
      channel.sink.add(jsonEncode(['REQ', subId, {
        'kinds': [10009],
        'authors': [_publicKeyHex],
        'limit': 1,
      }]));
      Timer(const Duration(seconds: 10), () {
        if (!completer.isCompleted) completer.complete(null);
      });
      sub = channel.stream.listen((raw) {
        try {
          final data = jsonDecode(raw as String) as List;
          if (data[0] == 'EVENT' && data[1] == subId) {
            final event = data[2] as Map<String, dynamic>;
            final bundle = jsonDecode(event['content'] as String) as Map<String, dynamic>;
            if (!completer.isCompleted) completer.complete(bundle);
          } else if (data[0] == 'EOSE') {
            if (!completer.isCompleted) completer.complete(null);
          }
        } catch (_) {}
      }, onError: (_) {
        if (!completer.isCompleted) completer.complete(null);
      });
      return await completer.future;
    } catch (e) {
      debugPrint('[Nostr] fetchPublicKeys error: $e');
      return null;
    } finally {
      await sub?.cancel();
      channel?.sink.close();
    }
  }

  /// SharedPreferences key for the last-seen timestamp for this relay.
  String get _sinceKey => 'nostr_since_${_relayUrl.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';

  Future<int> _getSince() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getInt(_sinceKey) ?? 0;
    // Use stored timestamp (minus 60s buffer), but never older than 30 days.
    final thirtyDaysAgo = DateTime.now().millisecondsSinceEpoch ~/ 1000 - 30 * 86400;
    return stored > thirtyDaysAgo ? stored - 60 : thirtyDaysAgo;
  }

  Future<void> _updateSince(int unixSeconds) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_sinceKey) ?? 0;
    if (unixSeconds > current) await prefs.setInt(_sinceKey, unixSeconds);
  }

  @override
  Future<String?> provisionGroup(String groupName) async => '$_publicKeyHex@$_relayUrl';
}

// ─── MessageSender ───────────────────────────────────────

class NostrMessageSender implements MessageSender {
  String _privateKeyHex = '';
  String _relayUrl = _defaultRelay;

  // Tor settings — loaded once in initializeSender
  bool _torEnabled = false;
  String _torHost = '127.0.0.1';
  int _torPort = 9050;

  // I2P settings — loaded once in initializeSender (Tor takes priority)
  bool _i2pEnabled = false;
  String _i2pHost = '127.0.0.1';
  int _i2pPort = 4447;

  Future<WebSocketChannel> _wsConnect(String url) => _nostrWsConnect(url,
      torEnabled: _torEnabled, torHost: _torHost, torPort: _torPort,
      i2pEnabled: _i2pEnabled, i2pHost: _i2pHost, i2pPort: _i2pPort);

  @override
  Future<void> initializeSender(String apiKey) async {
    if (apiKey.startsWith('{')) {
      try {
        final decoded = jsonDecode(apiKey);
        _privateKeyHex = (decoded['privkey'] as String? ?? '').trim();
        final relay = (decoded['relay'] as String? ?? '').trim();
        _relayUrl = relay.isNotEmpty ? relay : _defaultRelay;
      } catch (_) {}
    } else {
      _privateKeyHex = apiKey.trim();
    }

    // Load Tor and I2P settings
    final prefs = await SharedPreferences.getInstance();
    _torEnabled = prefs.getBool('tor_enabled') ?? false;
    _torHost = prefs.getString('tor_host') ?? '127.0.0.1';
    _torPort = prefs.getInt('tor_port') ?? 9050;
    _i2pEnabled = prefs.getBool('i2p_enabled') ?? false;
    _i2pHost = prefs.getString('i2p_host') ?? '127.0.0.1';
    _i2pPort = prefs.getInt('i2p_port') ?? 4447;

    // If relay is still the hardcoded default, try adaptive CF relay or probe-suggested
    if (_relayUrl == _defaultRelay) {
      final adaptive = prefs.getString('adaptive_cf_relay') ?? '';
      if (adaptive.isNotEmpty) {
        _relayUrl = adaptive;
      } else {
        var probed = prefs.getString('probe_nostr_relay') ?? '';
        if (probed.isNotEmpty) {
          if (!probed.startsWith('ws://') && !probed.startsWith('wss://')) {
            probed = 'wss://$probed';
          }
          _relayUrl = probed;
        }
      }
    }
  }

  Future<bool> _publishEvent(Map<String, dynamic> event, String relayUrl) async {
    try {
      final channel = await _wsConnect(relayUrl);
      await channel.ready;
      channel.sink.add(jsonEncode(['EVENT', event]));
      final completer = Completer<bool>();
      final sub = channel.stream.listen((raw) {
        try {
          final data = jsonDecode(raw as String) as List;
          if (data[0] == 'OK' && data[1] == event['id']) {
            if (!completer.isCompleted) completer.complete(data[2] == true);
          }
        } catch (_) {}
      }, onError: (_) {
        if (!completer.isCompleted) completer.complete(false);
      });
      final result = await completer.future.timeout(
        const Duration(seconds: 10), onTimeout: () => true,
      );
      sub.cancel();
      channel.sink.close();
      return result;
    } catch (e) {
      debugPrint('[Nostr] Failed to publish: $e');
      return false;
    }
  }

  @override
  Future<bool> sendMessage(String targetDatabaseId, String roomId, Message message) async {
    // Use our own key or a throwaway if we have no Nostr identity (cross-adapter sender)
    String senderKey = _privateKeyHex;
    if (senderKey.isEmpty) {
      final rng = Random.secure();
      senderKey = hex.encode(Uint8List.fromList(List.generate(32, (_) => rng.nextInt(256))));
    }

    final parts = targetDatabaseId.split('@');
    final recipientPubkey = parts[0];
    final relay = parts.length > 1 ? parts.sublist(1).join('@') : _relayUrl;

    try {
      // Content is the Signal-encrypted payload directly — no NIP-04 outer wrapper
      // Signal provides E2EE; the relay sees sender/recipient pubkeys but not content
      final event = _buildEvent(
        privkeyHex: senderKey,
        kind: 4,
        content: message.encryptedPayload,
        tags: [['p', recipientPubkey]],
      );
      return await _publishEvent(event, relay);
    } catch (e) {
      debugPrint('[Nostr] sendMessage error: $e');
      return false;
    }
  }

  @override
  Future<bool> sendSignal(String targetDatabaseId, String roomId,
      String senderId, String type, Map<String, dynamic> payload) async {
    // Use our own key or a throwaway if we have no Nostr identity (cross-adapter sender).
    String signingKey = _privateKeyHex;
    if (signingKey.isEmpty) {
      final rng = Random.secure();
      signingKey = hex.encode(Uint8List.fromList(List.generate(32, (_) => rng.nextInt(256))));
    }

    final parts = targetDatabaseId.split('@');
    final recipientPubkey = parts[0];
    final relay = parts.length > 1 ? parts.sublist(1).join('@') : _relayUrl;

    // Signal key bundle (sys_keys): must use real key (kind 10009, replaceable by pubkey).
    if (type == 'sys_keys') {
      if (_privateKeyHex.isEmpty) return false; // sys_keys requires real identity
      try {
        final event = _buildEvent(
          privkeyHex: _privateKeyHex,
          kind: 10009,
          content: jsonEncode(payload),
          tags: [['d', 'signal_bundle']],
        );
        return await _publishEvent(event, relay);
      } catch (e) {
        debugPrint('[Nostr] sys_keys publish error: $e');
        return false;
      }
    }

    // All other signals (typing, msg_read, ttl_update, WebRTC): use signingKey.
    // NIP-04 encryption: sender's signingKey + recipient's pubkey for ECDH.
    // Recipient decrypts using event['pubkey'] (the ephemeral/throwaway sender key).
    try {
      final signalPayload = jsonEncode({
        'type': type, 'roomId': roomId, 'senderId': senderId, 'payload': payload,
      });
      final encrypted = _nip04Encrypt(signingKey, recipientPubkey, signalPayload);
      final event = _buildEvent(
        privkeyHex: signingKey,
        kind: 20000,
        content: encrypted,
        tags: [['p', recipientPubkey]],
      );
      return await _publishEvent(event, relay);
    } catch (e) {
      debugPrint('[Nostr] sendSignal error: $e');
      return false;
    }
  }

  Future<bool> publishProfile({required String name, String? about}) async {
    if (_privateKeyHex.isEmpty) return false;
    try {
      final event = _buildEvent(
        privkeyHex: _privateKeyHex,
        kind: 0,
        content: jsonEncode({'name': name, 'about': about ?? ''}),
      );
      return await _publishEvent(event, _relayUrl);
    } catch (e) {
      debugPrint('[Nostr] publishProfile error: $e');
      return false;
    }
  }
}
