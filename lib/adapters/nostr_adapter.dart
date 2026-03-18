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
import '../constants.dart';
import '../models/message.dart';
import '../services/tor_service.dart' as tor;
import '../services/utls_service.dart';
import '../services/psiphon_service.dart';
import '../services/nip44_service.dart' as nip44;
import '../services/gift_wrap_service.dart' as giftwrap;
import 'inbox_manager.dart';

/// ─────────────────────────────────────────────────────────
/// Nostr Adapter — Signal Protocol over Nostr transport
///
/// Protocol mapping:
///   kind 4    → Chat message (content = Signal-encrypted payload, no NIP-04)
///   kind 10009 → Signal public key bundle (unencrypted, replaceable)
///   kind 20000 → Ephemeral signaling event (WebRTC, NIP-04 encrypted)
/// ─────────────────────────────────────────────────────────

const _defaultRelay = kDefaultNostrRelay;

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

// ─── Shared WebSocket connect ────────────────────────────────────────────────
//
// Single implementation used by both InboxReader and Sender.
// Connection chain (each step is a fast fallback, no wasted time):
//
//   1. uTLS+ECH      (~2s) — Go proxy: Chrome fingerprint + ECH + DoH resolve
//   2. CF Worker      (~2s) — personal relay proxy on CF CDN (if configured)
//   3. Custom SOCKS5  (~2s) — V2Ray/Xray/Shadowsocks (if configured)
//   4. Psiphon      (~3-5s) — ~2000 rotating VPS, obfuscated protocols
//   5. Tor SOCKS5   (~120s) — Tor with PTs (obfs4/WebTunnel/Snowflake)
//   6. I2P SOCKS5           — external I2P router (if configured)
//   7. Plain WS             — last resort, no proxy
//
// The Go uTLS proxy handles DoH resolution, Chrome TLS fingerprint, and ECH
// (Encrypted Client Hello) — GFW sees only a decoy SNI, not the real hostname.

Future<WebSocketChannel> _nostrWsConnect(
  String url, {
  required bool torEnabled,
  required String torHost,
  required int torPort,
  required bool i2pEnabled,
  required String i2pHost,
  required int i2pPort,
  required bool customProxyEnabled,
  required String customProxyHost,
  required int customProxyPort,
  required String cfWorkerRelay,
}) async {
  // 1. uTLS+ECH (Go proxy: Chrome fingerprint + ECH + DoH)
  final utlsPort = UTLSService.instance.proxyPort;
  if (utlsPort != null) {
    try {
      return await _connectWebSocketViaUtls(url, utlsPort)
          .timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint('[Nostr] uTLS+ECH path failed ($e) — trying next');
    }
  }

  // 2. CF Worker relay proxy (if configured)
  if (cfWorkerRelay.isNotEmpty && utlsPort != null) {
    try {
      // Build Worker URL: wss://domain/?r=<relay_url>
      var workerHost = cfWorkerRelay;
      if (!workerHost.startsWith('wss://') && !workerHost.startsWith('ws://')) {
        workerHost = 'wss://$workerHost';
      }
      final workerUrl = '$workerHost/?r=${Uri.encodeComponent(url)}';
      return await _connectWebSocketViaUtls(workerUrl, utlsPort)
          .timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint('[Nostr] CF Worker path failed ($e) — trying next');
    }
  }

  // 3. Custom SOCKS5 proxy (V2Ray/Xray/Shadowsocks)
  if (customProxyEnabled) {
    try {
      return await tor.connectWebSocket(url,
          torHost: customProxyHost, torPort: customProxyPort,
          socks5Timeout: const Duration(seconds: 8));
    } catch (e) {
      debugPrint('[Nostr] Custom proxy path failed ($e) — trying Tor');
    }
  }

  // 4. Psiphon SOCKS5 (~2000 rotating VPS, 3-5s bootstrap)
  final psiphonPort = PsiphonService.instance.proxyPort;
  if (psiphonPort != null) {
    try {
      return await tor.connectWebSocket(url,
          torHost: '127.0.0.1', torPort: psiphonPort,
          socks5Timeout: const Duration(seconds: 10));
    } catch (e) {
      debugPrint('[Nostr] Psiphon path failed ($e) — trying Tor');
    }
  }

  // 5. Tor SOCKS5
  if (torEnabled && tor.TorService.instance.isBootstrapped) {
    try {
      return await tor.connectWebSocket(url,
          torHost: torHost, torPort: torPort,
          socks5Timeout: const Duration(seconds: 8));
    } catch (e) {
      debugPrint('[Nostr] Tor path failed ($e) — trying I2P');
    }
  }

  // 6. I2P SOCKS5
  if (i2pEnabled) {
    try {
      return await tor.connectWebSocket(url,
          torHost: i2pHost, torPort: i2pPort,
          socks5Timeout: const Duration(seconds: 8));
    } catch (e) {
      debugPrint('[Nostr] I2P path failed ($e) — falling back to plain');
    }
  }

  // 7. Plain WebSocket — normalize port so Dart doesn't produce an invalid URI.
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

/// Public API: compute ECDH shared secret (x-coord) from our privkey + their pubkey.
/// Same derivation as NIP-04 — deterministic per-pair shared key.
Uint8List computeEcdhSecret(String ourPrivkeyHex, String theirPubkeyHex) {
  const pHex = 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F';
  final p = BigInt.parse(pHex, radix: 16);
  final d = BigInt.parse(ourPrivkeyHex, radix: 16);
  final curve = _secp256k1.curve;
  final x = BigInt.parse(theirPubkeyHex, radix: 16);
  final y2 = (x.modPow(BigInt.from(3), p) + BigInt.from(7)) % p;
  final y = y2.modPow((p + BigInt.one) ~/ BigInt.from(4), p);
  final useY = y.isEven ? y : p - y;
  final sharedPoint = curve.createPoint(x, useY) * d;
  final xVal = sharedPoint?.x?.toBigInteger();
  if (xVal == null) throw StateError('ECDH: invalid shared point');
  return _bigIntToBytes(xVal, 32);
}

/// Encrypt plaintext with NIP-04 (AES-CBC + HMAC-SHA256 MAC). Visible for testing.
@visibleForTesting
String nip04Encrypt(String senderPrivkeyHex, String recipientPubkeyHex, String plaintext) =>
    _nip04Encrypt(senderPrivkeyHex, recipientPubkeyHex, plaintext);

/// Decrypt NIP-04 ciphertext. Requires MAC — throws if missing or invalid. Visible for testing.
@visibleForTesting
String nip04Decrypt(String recipientPrivkeyHex, String senderPubkeyHex, String ciphertext) =>
    _nip04Decrypt(recipientPrivkeyHex, senderPubkeyHex, ciphertext);

/// Sign a signal payload with HMAC-SHA256 using ECDH shared secret.
/// Returns hex-encoded HMAC.
String signSignalPayload(String senderPrivkeyHex, String recipientPubkeyHex, String canonicalJson) {
  final secret = computeEcdhSecret(senderPrivkeyHex, recipientPubkeyHex);
  final hmac = crypto.Hmac(crypto.sha256, secret);
  return hmac.convert(utf8.encode(canonicalJson)).toString();
}

/// Verify a signal's HMAC using ECDH shared secret.
bool verifySignalPayload(String receiverPrivkeyHex, String senderPubkeyHex, String canonicalJson, String hmacHex) {
  final secret = computeEcdhSecret(receiverPrivkeyHex, senderPubkeyHex);
  final hmac = crypto.Hmac(crypto.sha256, secret);
  final expected = hmac.convert(utf8.encode(canonicalJson)).toString();
  // Constant-time comparison to prevent timing attacks.
  if (expected.length != hmacHex.length) return false;
  int result = 0;
  for (int i = 0; i < expected.length; i++) {
    result |= expected.codeUnitAt(i) ^ hmacHex.codeUnitAt(i);
  }
  return result == 0;
}

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
  // Encrypt-then-MAC: HMAC-SHA256 over ciphertext+IV using derived MAC key.
  final macKey = _sha256([...sharedX, 0x01]); // derive separate MAC key
  final hmac = crypto.Hmac(crypto.sha256, macKey);
  final mac = hmac.convert([...ciphertext, ...iv]).toString();
  return '${base64.encode(ciphertext)}?iv=${base64.encode(iv)}&mac=$mac';
}

String _nip04Decrypt(String recipientPrivkeyHex, String senderPubkeyHex, String ciphertext) {
  // Parse: base64_ct?iv=base64_iv[&mac=hex_hmac]
  final ivSplit = ciphertext.split('?iv=');
  if (ivSplit.length != 2) throw FormatException('Invalid NIP-04 ciphertext');
  final ctB64 = ivSplit[0];
  String ivB64;
  String? macHex;
  if (ivSplit[1].contains('&mac=')) {
    final macSplit = ivSplit[1].split('&mac=');
    ivB64 = macSplit[0];
    macHex = macSplit[1];
  } else {
    ivB64 = ivSplit[1];
  }
  final ct = base64.decode(ctB64);
  final iv = base64.decode(ivB64);
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
  // Verify MAC before decrypting (Encrypt-then-MAC). MAC is required — no fallback.
  if (macHex == null) throw FormatException('NIP-04 decrypt: missing MAC');
  final macKey = _sha256([...sharedX, 0x01]);
  final hmac = crypto.Hmac(crypto.sha256, macKey);
  final expected = hmac.convert([...ct, ...iv]).toString();
  if (expected.length != macHex.length) {
    throw FormatException('NIP-04 decrypt: MAC verification failed');
  }
  int cmp = 0;
  for (int i = 0; i < expected.length; i++) {
    cmp |= expected.codeUnitAt(i) ^ macHex.codeUnitAt(i);
  }
  if (cmp != 0) throw FormatException('NIP-04 decrypt: MAC verification failed');
  final cipher = CBCBlockCipher(AESEngine());
  cipher.init(false, ParametersWithIV<KeyParameter>(KeyParameter(Uint8List.fromList(sharedX)), Uint8List.fromList(iv)));
  final plainBytes = Uint8List(ct.length);
  for (int i = 0; i < ct.length; i += 16) { cipher.processBlock(Uint8List.fromList(ct), i, plainBytes, i); }
  // Validate PKCS#7 padding to prevent padding oracle attacks.
  if (plainBytes.isEmpty) throw FormatException('NIP-04 decrypt: empty plaintext after AES-CBC');
  final padLen = plainBytes.last;
  if (padLen < 1 || padLen > 16 || padLen > plainBytes.length) {
    throw FormatException('NIP-04 decrypt: invalid PKCS#7 padding length');
  }
  for (int i = plainBytes.length - padLen; i < plainBytes.length; i++) {
    if (plainBytes[i] != padLen) {
      throw FormatException('NIP-04 decrypt: invalid PKCS#7 padding bytes');
    }
  }
  return utf8.decode(plainBytes.sublist(0, plainBytes.length - padLen));
}

// ─── InboxReader ─────────────────────────────────────────

class NostrInboxReader implements InboxReader {
  String _privateKeyHex = '';
  String _publicKeyHex = '';
  String _relayUrl = _defaultRelay;
  final Set<String> _seenIds = {};

  /// Emits a sender pubkey whenever an incoming signal fails MAC verification.
  /// This indicates a possible tamper attempt or malicious relay injection.
  static final StreamController<String> tamperWarnings =
      StreamController<String>.broadcast();

  // Tor settings — loaded once in initializeReader
  bool _torEnabled = false;
  String _torHost = '127.0.0.1';
  int _torPort = 9050;

  // I2P settings — loaded once in initializeReader (Tor takes priority)
  bool _i2pEnabled = false;
  String _i2pHost = '127.0.0.1';
  int _i2pPort = 4447;

  // Custom proxy + CF Worker — loaded once in initializeReader
  bool _customProxyEnabled = false;
  String _customProxyHost = '127.0.0.1';
  int _customProxyPort = 10808;
  String _cfWorkerRelay = '';

  Future<WebSocketChannel> _wsConnect(String url) => _nostrWsConnect(url,
      torEnabled: _torEnabled, torHost: _torHost, torPort: _torPort,
      i2pEnabled: _i2pEnabled, i2pHost: _i2pHost, i2pPort: _i2pPort,
      customProxyEnabled: _customProxyEnabled,
      customProxyHost: _customProxyHost, customProxyPort: _customProxyPort,
      cfWorkerRelay: _cfWorkerRelay);

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
      } catch (e) {
        debugPrint('[Nostr] Failed to parse apiKey JSON: $e');
      }
    } else if (apiKey.isNotEmpty && !apiKey.startsWith('{')) {
      _privateKeyHex = apiKey.trim();
    }

    // Derive own pubkey from privkey if not already set via databaseId
    if (_privateKeyHex.isNotEmpty && _publicKeyHex.isEmpty) {
      try { _publicKeyHex = _derivePubkeyHex(_privateKeyHex); } catch (e) {
        debugPrint('[Nostr] Failed to derive pubkey from privkey: $e');
      }
    }

    // Load Tor, I2P, and custom proxy settings
    final prefs = await SharedPreferences.getInstance();
    _torEnabled = prefs.getBool('tor_enabled') ?? false;
    _torHost = prefs.getString('tor_host') ?? '127.0.0.1';
    _torPort = prefs.getInt('tor_port') ?? 9050;
    _i2pEnabled = prefs.getBool('i2p_enabled') ?? false;
    _i2pHost = prefs.getString('i2p_host') ?? '127.0.0.1';
    _i2pPort = prefs.getInt('i2p_port') ?? 4447;
    _customProxyEnabled = prefs.getBool('custom_proxy_enabled') ?? false;
    _customProxyHost = prefs.getString('custom_proxy_host') ?? '127.0.0.1';
    _customProxyPort = prefs.getInt('custom_proxy_port') ?? 10808;
    _cfWorkerRelay = prefs.getString('cf_worker_relay') ?? '';

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
  static const _maxConsecutiveFailures = 30;

  /// True when the shared loop stopped after [_maxConsecutiveFailures] failures.
  bool get circuitBroken => _circuitBroken;
  bool _circuitBroken = false;

  bool _loopStarted = false;

  @override
  Stream<bool> get healthChanges => _healthCtrl.stream;

  void _ensureLoop() {
    if (_loopStarted || _privateKeyHex.isEmpty) return;
    _loopStarted = true;
    unawaited(_runSharedLoop());
  }

  Future<void> _runSharedLoop() async {
    while (true) {
      WebSocketChannel? channel;
      bool cycleSuccess = false;
      try {
        channel = await _wsConnect(_relayUrl);
        await channel.ready;
        debugPrint('[Nostr] Connected to $_relayUrl');

        final subId = 'sub_${DateTime.now().millisecondsSinceEpoch}';
        final since = await _getSince();
        channel.sink.add(jsonEncode(['REQ', subId, {
          'kinds': [4, 20000, 1059],
          '#p': [_publicKeyHex],
          'since': since,
          'limit': 100,
        }]));

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
              if (data.isEmpty) continue;
              if (data[0] == 'EOSE') {
                debugPrint('[Nostr] EOSE on $_relayUrl');
                continue;
              }
              if (data.length < 3 || data[0] != 'EVENT' || data[1] != subId) continue;
              final event = data[2] as Map<String, dynamic>?;
              if (event == null) continue;
              final id = event['id'] as String?;
              if (id == null || id.isEmpty) continue;
              if (_seenIds.contains(id)) continue;
              _trackSeenId(id);
              final ts = event['created_at'] as int?;
              if (ts != null) unawaited(_updateSince(ts));
              final kind = (event['kind'] as int?) ?? -1;
              if (kind == 1059) {
                _dispatchGiftWrap(event);
              } else if (kind == 4) {
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
        if (_consecutiveFailures >= _maxConsecutiveFailures) {
          debugPrint('[Nostr] Max retries ($_maxConsecutiveFailures) reached, stopping');
          _circuitBroken = true;
          break;
        }
        // Tiered delay: 5s for first 5 failures, 30s up to 15, then 5min
        final delay = Duration(seconds:
            (_consecutiveFailures < 5) ? 5
            : (_consecutiveFailures < 15) ? 30
            : 300);
        debugPrint('[Nostr] Reconnecting in ${delay.inSeconds}s (failure $_consecutiveFailures/$_maxConsecutiveFailures)…');
        await Future.delayed(delay);
      } else {
        // Successful cycle — reconnect quickly (relay closed gracefully).
        debugPrint('[Nostr] Reconnecting in 2s…');
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  void _dispatchGiftWrap(Map<String, dynamic> event) async {
    try {
      final inner = await giftwrap.unwrapEvent(
        recipientPrivkey: _privateKeyHex,
        wrapEvent: event,
      );
      if (inner == null) {
        debugPrint('[Nostr] Gift Wrap: failed to unwrap');
        return;
      }
      final innerKind = (inner['kind'] as int?) ?? -1;
      if (innerKind == 4) {
        _dispatchMessage(inner);
      } else if (innerKind == 20000) {
        _dispatchSignal(inner);
      } else {
        debugPrint('[Nostr] Gift Wrap: unknown inner kind $innerKind');
      }
    } catch (e) {
      debugPrint('[Nostr] Gift Wrap dispatch error: $e');
    }
  }

  void _dispatchMessage(Map<String, dynamic> event) {
    try {
      final id = event['id'] as String? ?? '';
      final pubkey = event['pubkey'] as String? ?? '';
      final content = event['content'] as String? ?? '';
      final createdAt = event['created_at'] as int?;
      if (id.isEmpty || pubkey.isEmpty || content.isEmpty) return;
      _msgCtrl.add([Message(
        id: id,
        senderId: pubkey,
        receiverId: _publicKeyHex,
        encryptedPayload: content,
        timestamp: createdAt != null && createdAt > 0
            ? DateTime.fromMillisecondsSinceEpoch(createdAt * 1000)
            : DateTime.now(),
        adapterType: 'nostr',
      )]);
    } catch (e) {
      debugPrint('[Nostr] Failed to parse message: $e');
    }
  }

  void _dispatchSignal(Map<String, dynamic> event) async {
    try {
      final senderPubkey = event['pubkey'] as String? ?? '';
      final content = event['content'] as String? ?? '';
      if (senderPubkey.isEmpty || content.isEmpty) return;

      // Detect NIP-44 vs NIP-04: NIP-44 is base64 starting with version byte 0x02.
      String plain;
      bool isNip44 = false;
      try {
        final raw = base64.decode(content);
        isNip44 = raw.isNotEmpty && raw[0] == 0x02;
      } catch (_) {
        // Not valid base64 or too short — try NIP-04
      }

      if (isNip44) {
        plain = await nip44.nip44DecryptWithKeys(_privateKeyHex, senderPubkey, content);
      } else {
        plain = _nip04Decrypt(_privateKeyHex, senderPubkey, content);
      }

      final data = jsonDecode(plain) as Map<String, dynamic>;
      _sigCtrl.add([{
        'type': data['type'],
        'senderId': senderPubkey,
        'roomId': data['roomId'],
        'payload': data['payload'],
      }]);
    } catch (e) {
      debugPrint('[Nostr] Signal parse error: $e');
      if (e.toString().contains('MAC verification failed')) {
        final senderId = event['pubkey'] as String? ?? 'unknown';
        NostrInboxReader.tamperWarnings.add(senderId);
      }
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
        } catch (e) {
          debugPrint('[Nostr] fetchPublicKeys parse error: $e');
        }
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

  /// Clear private key from memory.
  void zeroize() {
    _privateKeyHex = '';
    _publicKeyHex = '';
  }
}

// ─── MessageSender ───────────────────────────────────────

class NostrMessageSender implements MessageSender {
  String _privateKeyHex = '';
  String _relayUrl = _defaultRelay;

  // Persistent WS pool: relay URL → (channel, lastUsed)
  final Map<String, ({WebSocketChannel ch, DateTime ts})> _wsPool = {};
  static const _wsPoolTtl = Duration(minutes: 5);

  // Tor settings — loaded once in initializeSender
  bool _torEnabled = false;
  String _torHost = '127.0.0.1';
  int _torPort = 9050;

  // I2P settings — loaded once in initializeSender (Tor takes priority)
  bool _i2pEnabled = false;
  String _i2pHost = '127.0.0.1';
  int _i2pPort = 4447;

  // Custom proxy + CF Worker — loaded once in initializeSender
  bool _customProxyEnabled = false;
  String _customProxyHost = '127.0.0.1';
  int _customProxyPort = 10808;
  String _cfWorkerRelay = '';

  Future<WebSocketChannel> _wsConnect(String url) => _nostrWsConnect(url,
      torEnabled: _torEnabled, torHost: _torHost, torPort: _torPort,
      i2pEnabled: _i2pEnabled, i2pHost: _i2pHost, i2pPort: _i2pPort,
      customProxyEnabled: _customProxyEnabled,
      customProxyHost: _customProxyHost, customProxyPort: _customProxyPort,
      cfWorkerRelay: _cfWorkerRelay);

  @override
  Future<void> initializeSender(String apiKey) async {
    if (apiKey.startsWith('{')) {
      try {
        final decoded = jsonDecode(apiKey);
        _privateKeyHex = (decoded['privkey'] as String? ?? '').trim();
        final relay = (decoded['relay'] as String? ?? '').trim();
        _relayUrl = relay.isNotEmpty ? relay : _defaultRelay;
      } catch (e) {
        debugPrint('[Nostr] Sender failed to parse apiKey JSON: $e');
      }
    } else {
      _privateKeyHex = apiKey.trim();
    }

    // Load Tor, I2P, and custom proxy settings
    final prefs = await SharedPreferences.getInstance();
    _torEnabled = prefs.getBool('tor_enabled') ?? false;
    _torHost = prefs.getString('tor_host') ?? '127.0.0.1';
    _torPort = prefs.getInt('tor_port') ?? 9050;
    _i2pEnabled = prefs.getBool('i2p_enabled') ?? false;
    _i2pHost = prefs.getString('i2p_host') ?? '127.0.0.1';
    _i2pPort = prefs.getInt('i2p_port') ?? 4447;
    _customProxyEnabled = prefs.getBool('custom_proxy_enabled') ?? false;
    _customProxyHost = prefs.getString('custom_proxy_host') ?? '127.0.0.1';
    _customProxyPort = prefs.getInt('custom_proxy_port') ?? 10808;
    _cfWorkerRelay = prefs.getString('cf_worker_relay') ?? '';

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

  /// Get or create a pooled WebSocket connection for a relay.
  Future<WebSocketChannel?> _getPooledWs(String relayUrl) async {
    final cached = _wsPool[relayUrl];
    if (cached != null) {
      final age = DateTime.now().difference(cached.ts);
      if (age < _wsPoolTtl) {
        return cached.ch;
      }
      // Stale — close and reconnect.
      try { cached.ch.sink.close(); } catch (_) {}
      _wsPool.remove(relayUrl);
    }
    try {
      final ch = await _wsConnect(relayUrl);
      await ch.ready;
      _wsPool[relayUrl] = (ch: ch, ts: DateTime.now());
      // Listen for close/errors to evict from pool. Subscription kept via
      // onDone/onError self-cleanup (removes pool entry which drops channel ref).
      ch.stream.listen(
        (_) { /* consume data frames to keep stream alive */ },
        onDone: () => _wsPool.remove(relayUrl),
        onError: (_) => _wsPool.remove(relayUrl),
        cancelOnError: true,
      );
      return ch;
    } catch (e) {
      debugPrint('[Nostr] Pool connect failed: $e');
      return null;
    }
  }

  Future<bool> _publishEvent(Map<String, dynamic> event, String relayUrl) async {
    try {
      // Try pooled connection first; fall back to one-shot on failure.
      var channel = await _getPooledWs(relayUrl);
      bool isPooled = channel != null;
      if (channel == null) {
        channel = await _wsConnect(relayUrl);
        await channel.ready;
        isPooled = false;
      }

      channel.sink.add(jsonEncode(['EVENT', event]));

      // For pooled connections, we don't wait for OK (fire-and-forget with pool).
      // For one-shot, wait for confirmation.
      if (!isPooled) {
        final completer = Completer<bool>();
        final sub = channel.stream.listen((raw) {
          try {
            final data = jsonDecode(raw as String) as List;
            if (data[0] == 'OK' && data[1] == event['id']) {
              if (!completer.isCompleted) completer.complete(data[2] == true);
            }
          } catch (e) {
            debugPrint('[Nostr] Sender response parse error: $e');
          }
        }, onError: (_) {
          if (!completer.isCompleted) completer.complete(false);
        });
        final result = await completer.future.timeout(
          const Duration(seconds: 10), onTimeout: () => true,
        );
        sub.cancel();
        channel.sink.close();
        return result;
      }
      return true;
    } catch (e) {
      debugPrint('[Nostr] Failed to publish: $e');
      // Evict broken pool entry.
      _wsPool.remove(relayUrl);
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
      // Wrap kind:4 message in Gift Wrap (NIP-59) for metadata privacy
      final event = await giftwrap.wrapEvent(
        senderPrivkey: senderKey,
        recipientPubkey: recipientPubkey,
        innerKind: 4,
        innerContent: message.encryptedPayload,
        innerTags: [['p', recipientPubkey]],
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
      final encrypted = await nip44.nip44EncryptWithKeys(signingKey, recipientPubkey, signalPayload);
      // Wrap kind:20000 signal in Gift Wrap (NIP-59) for metadata privacy
      final event = await giftwrap.wrapEvent(
        senderPrivkey: signingKey,
        recipientPubkey: recipientPubkey,
        innerKind: 20000,
        innerContent: encrypted,
        innerTags: [['p', recipientPubkey]],
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

  /// Clear private key from memory and close pooled connections.
  void zeroize() {
    _privateKeyHex = '';
    for (final entry in _wsPool.values) {
      try { entry.ch.sink.close(); } catch (_) {}
    }
    _wsPool.clear();
  }
}
