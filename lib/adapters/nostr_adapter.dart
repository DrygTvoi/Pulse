import 'dart:async';
import 'dart:collection';
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
import '../services/nostr_event_builder.dart' as eb;
import 'inbox_manager.dart';
import '../services/adaptive_relay_service.dart';

/// ─────────────────────────────────────────────────────────
/// Nostr Adapter — Signal Protocol over Nostr transport
///
/// Protocol mapping:
///   kind 4    → Chat message (content = Signal-encrypted payload, no NIP-04)
///   kind 10009 → Signal public key bundle (unencrypted, replaceable)
///   kind 20000 → Ephemeral signaling event (WebRTC, NIP-04 encrypted)
/// ─────────────────────────────────────────────────────────

const _defaultRelay = kDefaultNostrRelay;

/// Gather up to [limit] deduplicated known relays from SharedPrefs in priority order:
/// 1. [primary] (passed in)
/// 2. `nostr_relay` (user-configured)
/// 3. `probe_nostr_relay` (connectivity probe, ~6h TTL)
/// 4. `adaptive_cf_relay` (CF-aware, ~15min TTL)
/// 5. `kDefaultNostrRelay` (hardcoded fallback)
/// Well-known reliable relays for key exchange fallback.
const _kWellKnownRelays = [
  'wss://nos.lol',
  'wss://relay.nostr.wirednet.jp',
];

Future<List<String>> gatherKnownRelays(String primary, {int limit = 5}) async {
  final prefs = await SharedPreferences.getInstance();
  // Preferred relays (user-configured, probed, adaptive) come first in a fixed order.
  final preferred = <String>[
    primary,
    prefs.getString('nostr_relay') ?? '',
    prefs.getString('probe_nostr_relay') ?? '',
    prefs.getString('adaptive_cf_relay') ?? '',
  ];
  // Fallback well-known relays are shuffled per call to avoid always
  // concentrating new accounts on the same two relays.
  final fallbacks = <String>[
    kDefaultNostrRelay,
    ..._kWellKnownRelays,
  ]..shuffle();
  final candidates = [...preferred, ...fallbacks];
  final seen = <String>{};
  final result = <String>[];
  for (var url in candidates) {
    if (url.isEmpty) continue;
    if (!url.startsWith('ws://') && !url.startsWith('wss://')) {
      url = 'wss://$url';
    }
    if (!_isValidRelayUrl(url) || !seen.add(url)) continue;
    result.add(url);
    if (result.length >= limit) break;
  }
  return result;
}

/// Global per-relay WebSocket pool.  The first reader to connect to a relay
/// registers its channel + pending-fetch map here; subsequent readers and
/// senders reuse the channel instead of opening a second connection (which
/// many relays rate-limit or reject).
///
/// The pending-fetch map is owned by the reader's shared loop, which dispatches
/// incoming events to matching completers.  This lets other code send REQs on
/// the shared channel without adding a second `.listen()` (single-subscription
/// streams only allow one listener).
final Map<String, ({WebSocketChannel ch, Map<String, Completer<Map<String, dynamic>?>> fetches})> _relayPool = {};

/// Module-level OK completers for publish confirmations.
/// Both the subscription loop and the publisher's pool listener dispatch here,
/// so publishes routed through the shared relay channel get proper OK handling.
final Map<String, Completer<bool>> _publishOkCompleters = {};

/// Register a connected channel for reuse by other readers/senders on the same relay.
void _registerRelayChannel(String relayUrl, WebSocketChannel ch,
    Map<String, Completer<Map<String, dynamic>?>> pendingFetches) {
  _relayPool[relayUrl] = (ch: ch, fetches: pendingFetches);
}

/// Remove a closed/dead channel from the pool.
void _unregisterRelayChannel(String relayUrl) {
  _relayPool.remove(relayUrl);
}

/// Get a pooled entry for a relay if one exists and the channel is still open.
({WebSocketChannel ch, Map<String, Completer<Map<String, dynamic>?>> fetches})? _getSharedRelayEntry(String relayUrl) {
  final entry = _relayPool[relayUrl];
  if (entry == null) return null;
  try {
    if (entry.ch.closeCode != null) {
      _relayPool.remove(relayUrl);
      return null;
    }
  } catch (_) {
    _relayPool.remove(relayUrl);
    return null;
  }
  return entry;
}

/// Circuit breaker for uTLS proxy — if it fails, skip for 5 minutes.
/// Prevents resource exhaustion from many concurrent bridge attempts.
DateTime? _utlsFailedUntil;

/// Connect a WebSocket through the uTLS HTTP CONNECT proxy.
///
/// Mirrors TorService.connectWebSocket (SOCKS5 pattern) but sends an
/// HTTP CONNECT request instead of a SOCKS5 handshake.  This avoids
/// Dart's WebSocket.connect/findProxy bug that produces "https://host:0#"
/// when routing wss:// through an HTTP CONNECT proxy.
Future<WebSocketChannel> _connectWebSocketViaUtls(
    String url, int proxyPort, {String? upstreamSocks5}) async {
  // Skip if uTLS recently failed — avoids creating many dead bridge sockets.
  // Bypass when using upstream SOCKS5 (force-Tor): different route, previous
  // direct failures don't apply.
  if (upstreamSocks5 == null &&
      _utlsFailedUntil != null && DateTime.now().isBefore(_utlsFailedUntil!)) {
    throw StateError('uTLS circuit breaker open');
  }
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

      // HTTP CONNECT request (with optional upstream SOCKS5 for Tor chaining).
      final socksHeader = upstreamSocks5 != null
          ? 'X-Upstream-Socks5: $upstreamSocks5\r\n'
          : '';
      proxy.write(
          'CONNECT $targetHost:$targetPort HTTP/1.1\r\n'
          'Host: $targetHost:$targetPort\r\n'
          '$socksHeader\r\n');
      await proxy.flush();

      // Wait for "HTTP/1.x 200 …\r\n\r\n".
      // Longer timeout when routing through Tor SOCKS5 (circuit setup is slow).
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
        debugPrint('[Nostr] uTLS CONNECT to $targetHost:$targetPort refused');
        // Trip circuit breaker — all hosts share the same Go proxy, so one
        // failure means the proxy is unreachable or not running.
        // Don't trip when using upstream SOCKS5 — failure is route-specific.
        if (upstreamSocks5 == null) {
          _utlsFailedUntil = DateTime.now().add(const Duration(minutes: 5));
        }
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
      _utlsFailedUntil = DateTime.now().add(const Duration(minutes: 5));
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
      ? '${wsUri.scheme}://${wsUri.host}:${wsUri.scheme == 'wss' ? 443 : 80}${wsUri.path}'
      : url;
  try {
    final ws = await WebSocket.connect(normalizedUrl, customClient: httpClient);
    ws.pingInterval = const Duration(seconds: 30);
    _utlsFailedUntil = null; // Success — reset circuit breaker.
    return IOWebSocketChannel(ws);
  } catch (e) {
    _utlsFailedUntil = DateTime.now().add(const Duration(minutes: 5));
    httpClient.close(force: true);
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
  bool forceTor = false,
}) async {
  // 0. Force-Tor: uTLS+Tor chain (Chrome fingerprint + IP hidden via Tor)
  //    Falls back to plain Tor SOCKS5 if uTLS proxy unavailable.
  if (forceTor && torEnabled && tor.TorService.instance.isBootstrapped) {
    final utlsPort = UTLSService.instance.proxyPort;
    if (utlsPort != null) {
      try {
        debugPrint('[Nostr] Force-Tor: uTLS+Tor chain to $url');
        return await _connectWebSocketViaUtls(url, utlsPort,
            upstreamSocks5: '$torHost:$torPort')
            .timeout(const Duration(seconds: 20));
      } catch (e) {
        debugPrint('[Nostr] Force-Tor uTLS+Tor failed ($e) — trying plain Tor');
      }
    }
    // Fallback: plain Tor SOCKS5 (no uTLS fingerprint masking)
    try {
      debugPrint('[Nostr] Force-Tor: plain Tor SOCKS5 to $url');
      return await tor.connectWebSocket(url,
          torHost: torHost, torPort: torPort,
          socks5Timeout: const Duration(seconds: 12));
    } catch (e) {
      debugPrint('[Nostr] Force-Tor plain failed ($e) — falling back');
    }
  }

  // When forceTor is set, skip layers 1-4 entirely
  if (!forceTor) {

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
      // Build Worker URL via URI parsing — prevents path-traversal injection.
      // Naive string concat allows "host/../evil.com" to traverse to a different
      // host after HTTP normalisation; Uri.parse + replace avoids this.
      var workerStr = cfWorkerRelay;
      if (!workerStr.startsWith('wss://') && !workerStr.startsWith('ws://')) {
        workerStr = 'wss://$workerStr';
      }
      final workerUri = Uri.parse(workerStr);
      if (workerUri.host.isEmpty) throw FormatException('CF Worker: empty host');
      final workerUrl = workerUri.replace(queryParameters: {'r': url}).toString();
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

  } // end if (!forceTor)

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
  debugPrint('[Nostr] Trying plain WS to $url');
  final wsUri = Uri.parse(url);
  final normalized = (!wsUri.hasPort || wsUri.port == 0)
      ? '${wsUri.scheme}://${wsUri.host}:${wsUri.scheme == 'wss' ? 443 : 80}${wsUri.path}'
      : url;
  final ws = await WebSocket.connect(normalized)
      .timeout(const Duration(seconds: 10));
  ws.pingInterval = const Duration(seconds: 30);
  debugPrint('[Nostr] Plain WS connected to $url');
  return IOWebSocketChannel(ws);
}

// ─── Secp256k1 key utilities ──────────────────────────────

final _secp256k1 = ECCurve_secp256k1();

/// Issue 1: secp256k1 field prime — parsed once at module level, not per call.
final BigInt _secp256k1P = BigInt.parse(
    'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F',
    radix: 16);

/// Issue 2: ECDH shared-secret cache — keyed by "context:ourPub:theirPub".
/// Avoids ~300ms EC math per message for the same key pair.
/// Domain-separated: different protocols get independent cache entries.
/// LinkedHashMap preserves insertion order for LRU eviction (max 500 entries).
/// Each entry carries a timestamp for TTL-based expiry (1 hour).
final LinkedHashMap<String, ({Uint8List secret, DateTime cachedAt})> _ecdhCache =
    LinkedHashMap<String, ({Uint8List secret, DateTime cachedAt})>();
const _ecdhCacheMaxSize = 500;
const _ecdhCacheTtl = Duration(hours: 1);

/// Issue 3: Cached pubkey derivation — privkey doesn't change at runtime.
/// Maps SHA-256(privkeyHex) → pubkeyHex to avoid storing raw privkey as map key.
/// LinkedHashMap preserves insertion order for LRU eviction (max 200 entries).
final LinkedHashMap<String, String> _pubkeyCache = LinkedHashMap<String, String>();
const _pubkeyCacheMaxSize = 200;

/// Use SHA-256 of privkey as cache key to avoid storing raw privkey in map key slot.
String _privkeyToCacheKey(String privkeyHex) {
  final bytes = hex.decode(privkeyHex);
  return crypto.sha256.convert(bytes).toString();
}

/// Public API: derive Nostr pubkey (x-coordinate) from hex private key
String deriveNostrPubkeyHex(String privkeyHex) => _derivePubkeyHex(privkeyHex);

/// Public API: compute ECDH shared secret (x-coord) from our privkey + their pubkey.
/// Same derivation as NIP-04 — deterministic per-pair shared key.
/// Results are cached per key pair + context (Issue 2).
///
/// [context] provides domain separation so the same key pair produces
/// independent cache entries for different protocols ('nip04', 'nip44',
/// 'giftwrap', 'mac', 'device_transfer', etc.). Defaults to 'default'.
Uint8List computeEcdhSecret(String ourPrivkeyHex, String theirPubkeyHex,
    {String context = 'default'}) {
  // Issue 2: return cached secret if available and not expired (TTL check).
  // Use derived pubkey (not privkey) in cache key to avoid leaking key material in memory.
  final ourPubHex = _derivePubkeyHex(ourPrivkeyHex);
  final cacheKey = '$context:$ourPubHex:$theirPubkeyHex';
  final cached = _ecdhCache[cacheKey];
  if (cached != null) {
    if (DateTime.now().difference(cached.cachedAt) < _ecdhCacheTtl) {
      return cached.secret;
    }
    // Expired — evict stale entry and recompute.
    _ecdhCache.remove(cacheKey);
  }

  final d = BigInt.parse(ourPrivkeyHex, radix: 16);
  final curve = _secp256k1.curve;
  final x = BigInt.parse(theirPubkeyHex, radix: 16);
  // Issue 1: use module-level _secp256k1P instead of re-parsing.
  final y2 = (x.modPow(BigInt.from(3), _secp256k1P) + BigInt.from(7)) % _secp256k1P;
  final y = y2.modPow((_secp256k1P + BigInt.one) ~/ BigInt.from(4), _secp256k1P);
  // Validate point is on curve: y^2 mod p must equal y2
  if ((y * y) % _secp256k1P != y2) {
    throw ArgumentError('ECDH: peer public key is not on secp256k1');
  }
  final useY = y.isEven ? y : _secp256k1P - y;
  final sharedPoint = curve.createPoint(x, useY) * d;
  final xVal = sharedPoint?.x?.toBigInteger();
  if (xVal == null) throw StateError('ECDH: invalid shared point');
  // F2-8: Reject degenerate shared point with zero x-coordinate — would
  // produce all-zero key material known to any observer.
  if (xVal == BigInt.zero) throw StateError('ECDH: degenerate shared point (x=0)');
  final result = _bigIntToBytes(xVal, 32);

  // Issue 2: store in cache with LRU eviction.
  _ecdhCache[cacheKey] = (secret: result, cachedAt: DateTime.now());
  if (_ecdhCache.length > _ecdhCacheMaxSize) {
    _ecdhCache.remove(_ecdhCache.keys.first);
  }
  return result;
}

/// Clear ECDH cache — call if privkey changes (shouldn't normally happen).
void clearEcdhCache() => _ecdhCache.clear();

/// Encrypt plaintext with NIP-04 (AES-CBC + HMAC-SHA256 MAC).
String nip04Encrypt(String senderPrivkeyHex, String recipientPubkeyHex, String plaintext) =>
    _nip04Encrypt(senderPrivkeyHex, recipientPubkeyHex, plaintext);

/// Decrypt NIP-04 ciphertext. Requires MAC — throws if missing or invalid.
String nip04Decrypt(String recipientPrivkeyHex, String senderPubkeyHex, String ciphertext) =>
    _nip04Decrypt(recipientPrivkeyHex, senderPubkeyHex, ciphertext);

/// Sign a signal payload with HMAC-SHA256 using ECDH shared secret.
/// Returns hex-encoded HMAC.
String signSignalPayload(String senderPrivkeyHex, String recipientPubkeyHex, String canonicalJson) {
  final secret = computeEcdhSecret(senderPrivkeyHex, recipientPubkeyHex, context: 'mac');
  final hmac = crypto.Hmac(crypto.sha256, secret);
  return hmac.convert(utf8.encode(canonicalJson)).toString();
}

/// Verify a signal's HMAC using ECDH shared secret.
bool verifySignalPayload(String receiverPrivkeyHex, String senderPubkeyHex, String canonicalJson, String hmacHex) {
  final secret = computeEcdhSecret(receiverPrivkeyHex, senderPubkeyHex, context: 'mac');
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

/// Issue 3: cached pubkey derivation — privkey doesn't change during runtime.
String _derivePubkeyHex(String privkeyHex) {
  final cacheKey = _privkeyToCacheKey(privkeyHex);
  final cached = _pubkeyCache[cacheKey];
  if (cached != null) return cached;

  final d = BigInt.parse(privkeyHex, radix: 16);
  final G = _secp256k1.G;
  final Q = G * d;
  final xBytes = _bigIntToBytes(Q!.x!.toBigInteger()!, 32);
  final result = hex.encode(xBytes);

  _pubkeyCache[cacheKey] = result;
  if (_pubkeyCache.length > _pubkeyCacheMaxSize) {
    _pubkeyCache.remove(_pubkeyCache.keys.first);
  }
  return result;
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


// ─── Async ECDH (compute isolate) ────────────────────────

/// Isolate entry point: performs secp256k1 ECDH + pubkey derivation.
/// Returns {'secret': base64(sharedX), 'ourPubHex': hex}.
/// The isolate re-initialises all secp256k1 globals from scratch.
Map<String, dynamic> _ecdhFullIsolate(Map<String, dynamic> params) {
  final ourPrivkeyHex = params['ourPrivkeyHex'] as String;
  final theirPubkeyHex = params['theirPubkeyHex'] as String;

  final d = BigInt.parse(ourPrivkeyHex, radix: 16);
  final x = BigInt.parse(theirPubkeyHex, radix: 16);

  // Derive our pubkey (needed for cache key on return).
  final Q = _secp256k1.G * d;
  final ourPubHex = hex.encode(_bigIntToBytes(Q!.x!.toBigInteger()!, 32));

  // Compute ECDH shared secret (x-coordinate of d·P).
  final y2 = (x.modPow(BigInt.from(3), _secp256k1P) + BigInt.from(7)) % _secp256k1P;
  final y = y2.modPow((_secp256k1P + BigInt.one) ~/ BigInt.from(4), _secp256k1P);
  if ((y * y) % _secp256k1P != y2) {
    throw ArgumentError('ECDH: peer public key is not on secp256k1');
  }
  final useY = y.isEven ? y : _secp256k1P - y;
  final sharedPoint = _secp256k1.curve.createPoint(x, useY) * d;
  final xVal = sharedPoint?.x?.toBigInteger();
  if (xVal == null) throw StateError('ECDH: invalid shared point');
  // F2-8: Reject degenerate shared point with zero x-coordinate
  if (xVal == BigInt.zero) throw StateError('ECDH: degenerate shared point (x=0)');

  return {
    'secret': base64.encode(_bigIntToBytes(xVal, 32)),
    'ourPubHex': ourPubHex,
  };
}

/// Async version of [computeEcdhSecret]: runs secp256k1 math in a background
/// isolate on cache miss; subsequent calls for the same key pair + context are
/// served from the LRU cache without spawning an isolate.
///
/// Use this in async contexts (message encryption, gift-wrap) so heavy
/// elliptic-curve operations do not block the UI thread.
Future<Uint8List> computeEcdhSecretAsync(
    String ourPrivkeyHex, String theirPubkeyHex,
    {String context = 'default'}) async {
  // Fast path: if our pubkey is already cached we can check the ECDH cache
  // without touching the isolate at all.
  final privCacheKey = _privkeyToCacheKey(ourPrivkeyHex);
  final cachedPub = _pubkeyCache[privCacheKey];
  if (cachedPub != null) {
    final cacheKey = '$context:$cachedPub:$theirPubkeyHex';
    final cached = _ecdhCache[cacheKey];
    if (cached != null &&
        DateTime.now().difference(cached.cachedAt) < _ecdhCacheTtl) {
      return cached.secret;
    }
  }

  // Slow path: compute in background isolate (both pubkey derivation + ECDH).
  final result = await compute(_ecdhFullIsolate, {
    'ourPrivkeyHex': ourPrivkeyHex,
    'theirPubkeyHex': theirPubkeyHex,
  });
  final secret =
      Uint8List.fromList(base64.decode(result['secret'] as String));
  final ourPubHex = result['ourPubHex'] as String;

  // Populate both caches on the main thread.
  _pubkeyCache[privCacheKey] = ourPubHex;
  if (_pubkeyCache.length > _pubkeyCacheMaxSize) {
    _pubkeyCache.remove(_pubkeyCache.keys.first);
  }
  final cacheKey = '$context:$ourPubHex:$theirPubkeyHex';
  _ecdhCache[cacheKey] = (secret: secret, cachedAt: DateTime.now());
  if (_ecdhCache.length > _ecdhCacheMaxSize) {
    _ecdhCache.remove(_ecdhCache.keys.first);
  }
  return secret;
}

// ─── NIP-42 AUTH helper ───────────────────────────────────

/// Respond to a NIP-42 AUTH challenge from the relay.
/// Builds and signs a kind:22242 event in a background isolate, then sends
/// ["AUTH", event] on [ch]. No-op if [privkeyHex] is empty.
Future<void> _nostrRespondToAuth(WebSocketChannel ch, String relayUrl,
    String challenge, String privkeyHex) async {
  if (privkeyHex.isEmpty) return;
  try {
    final authEvent = await eb.buildEvent(
      privkeyHex: privkeyHex,
      kind: 22242,
      content: '',
      tags: [
        ['relay', relayUrl],
        ['challenge', challenge],
      ],
    );
    ch.sink.add(jsonEncode(['AUTH', authEvent]));
    debugPrint('[Nostr] AUTH → $relayUrl');
  } catch (e) {
    debugPrint('[Nostr] AUTH response error: $e');
  }
}

// ─── NIP-04 (kept for WebRTC signaling only) ─────────────

/// Issue 5: delegates ECDH to computeEcdhSecret() which uses the shared cache.
String _nip04Encrypt(String senderPrivkeyHex, String recipientPubkeyHex, String plaintext) {
  final sharedX = computeEcdhSecret(senderPrivkeyHex, recipientPubkeyHex, context: 'nip04');

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

/// Issue 5: delegates ECDH to computeEcdhSecret() which uses the shared cache.
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
  // Size cap before allocation — attacker can send huge NIP-04 ciphertext in a
  // valid-sig event (relay signs the outer event, not the ciphertext).
  if (ctB64.length > 131072) throw FormatException('NIP-04: ciphertext too large');
  if (ivB64.length > 64) throw FormatException('NIP-04: IV too large');
  final ct = base64.decode(ctB64);
  final iv = base64.decode(ivB64);
  final sharedX = computeEcdhSecret(recipientPrivkeyHex, senderPubkeyHex, context: 'nip04');
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

// ─── Relay URL validation (shared by InboxReader and MessageSender) ──────────

/// Returns true if [url] is a syntactically valid WebSocket relay URL and
/// does not point to a loopback or RFC-1918 private address.
bool _isValidRelayUrl(String url) {
  try {
    final uri = Uri.parse(url);
    if ((uri.scheme != 'wss' && uri.scheme != 'ws') ||
        uri.host.isEmpty || uri.host.length > 255 || url.length > 2048) {
      return false;
    }
    final h = uri.host.toLowerCase();
    if (h == 'localhost' || h == '127.0.0.1' || h == '::1' || h == '0.0.0.0') return false;
    if (h.startsWith('10.') || h.startsWith('192.168.') || h.startsWith('169.254.')) return false;
    if (h.startsWith('172.')) {
      final second = int.tryParse(h.split('.').elementAtOrNull(1) ?? '');
      if (second != null && second >= 16 && second <= 31) return false;
    }
    return true;
  } catch (_) {
    return false;
  }
}

// ─── InboxReader ─────────────────────────────────────────

class NostrInboxReader implements InboxReader {
  String _privateKeyHex = '';
  String _publicKeyHex = '';
  String _relayUrl = _defaultRelay;
  final Map<String, DateTime> _seenIds = {};
  Set<String> _persistentSeenIds = {}; // loaded from disk on init
  Timer? _seenIdsSaveTimer; // debounce disk writes
  bool _seenIdsDirty = false;

  SharedPreferences? _prefs;
  Future<SharedPreferences> _getPrefs() async =>
      _prefs ??= await SharedPreferences.getInstance();

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

  // Force all Nostr through Tor — loaded once in initializeReader
  bool _forceTor = false;

  Future<WebSocketChannel> _wsConnect(String url) => _nostrWsConnect(url,
      torEnabled: _torEnabled, torHost: _torHost, torPort: _torPort,
      i2pEnabled: _i2pEnabled, i2pHost: _i2pHost, i2pPort: _i2pPort,
      customProxyEnabled: _customProxyEnabled,
      customProxyHost: _customProxyHost, customProxyPort: _customProxyPort,
      cfWorkerRelay: _cfWorkerRelay, forceTor: _forceTor);

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
    final prefs = await _getPrefs();
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
    _forceTor = prefs.getBool('nostr_force_tor') ?? false;

    // Probe-suggested and adaptive relays are added as secondary subscriptions
    // by ChatController (lines 692-705) rather than overriding the primary relay.
    // This avoids a bug where the probe saves a dead relay that then becomes the
    // primary, causing all Nostr operations to fail.

    // Load persistent seen event IDs to prevent NIP-44 nonce replay on reconnect.
    // The extended since window re-fetches events that were already decrypted;
    // their NIP-44 nonces are in the DB, so re-decrypting would trigger replay
    // detection. Skipping already-seen IDs avoids this entirely.
    final seenJson = prefs.getString('nostr_seen_ids') ?? '[]';
    try {
      _persistentSeenIds = Set<String>.from(jsonDecode(seenJson) as List);
      _seenIds.addAll({for (final id in _persistentSeenIds) id: DateTime.now()});
    } catch (_) {}
  }


  void _trackSeenId(String id) {
    // Defense-in-depth: if the reader is closed, do not track. Tracking after
    // close persists ids of events we cannot deliver (listener was cancelled),
    // which causes the next reader to dedup-drop the same message when it
    // loads persistent _seenIds from disk on startup.
    if (_closed) return;
    // Time-based eviction: remove entries older than 30 minutes first.
    if (_seenIds.length >= 2000) {
      final cutoff = DateTime.now().subtract(const Duration(minutes: 30));
      _seenIds.removeWhere((_, ts) => ts.isBefore(cutoff));
      // If still over limit after time-based eviction, remove oldest by timestamp.
      if (_seenIds.length >= 2000) {
        final sorted = _seenIds.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value));
        for (int i = 0; i < 1000 && i < sorted.length; i++) {
          _seenIds.remove(sorted[i].key);
        }
      }
    }
    _seenIds[id] = DateTime.now();
    // Persist to disk so reconnects with extended since window skip old events.
    _persistentSeenIds.add(id);
    // Cap at 2000 most recent
    if (_persistentSeenIds.length > 2000) {
      _persistentSeenIds = Set<String>.from(
          _persistentSeenIds.toList().sublist(_persistentSeenIds.length - 1500));
    }
    _scheduleSaveSeenIds();
  }

  void _scheduleSaveSeenIds() {
    _seenIdsDirty = true;
    _seenIdsSaveTimer ??= Timer(const Duration(seconds: 5), () {
      _seenIdsSaveTimer = null;
      if (_seenIdsDirty) {
        _seenIdsDirty = false;
        unawaited(_savePersistentIds());
      }
    });
  }

  Future<void> _savePersistentIds() async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString('nostr_seen_ids', jsonEncode(_persistentSeenIds.toList()));
    } catch (_) {}
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
  bool _running = false;
  // Monotonic flag set at the very start of close(). Guards post-await
  // continuations (e.g. _dispatchGiftWrap after unwrapEvent) from poisoning
  // persistent _seenIds with ids that were never delivered to a live listener.
  // Once true, _trackSeenId and the three dispatchers are no-ops.
  bool _closed = false;
  WebSocketChannel? _activeChannel;

  // Issue 6: pending fetchPublicKeys requests dispatched by the shared loop.
  // Maps subscription ID → completer. The shared loop forwards matching events.
  final Map<String, Completer<Map<String, dynamic>?>> _pendingKeyFetches = {};

  @override
  Stream<bool> get healthChanges => _healthCtrl.stream;

  /// Stop the event loop and close the active WebSocket.
  void close() {
    // MUST be set FIRST, before any other work and before any unawaited futures
    // complete. In-flight _dispatchGiftWrap continuations (post unwrapEvent
    // await) check this flag and bail before persisting the inner id to disk —
    // otherwise the new reader loads the poisoned id and silently drops the
    // message when it re-receives the same event.
    _closed = true;
    _running = false;
    _loopStarted = false;
    // Flush pending seen IDs to disk before closing
    _seenIdsSaveTimer?.cancel();
    _seenIdsSaveTimer = null;
    if (_seenIdsDirty) {
      _seenIdsDirty = false;
      unawaited(_savePersistentIds());
    }
    try { _activeChannel?.sink.close(); } catch (_) {}
    _activeChannel = null;
    _closeSecondaryRelays();
  }

  // ── Secondary relay subscriptions ────────────────────────────────────────
  // When contacts use a different relay, we subscribe there too so that
  // fallback publishes (when their relay rate-limits us) are still received.
  final Set<String> _secondaryRelays = {};
  final Map<String, WebSocketChannel> _secondaryChannels = {};
  final Map<String, bool> _secondaryRunning = {};

  /// Relays where the secondary subscription has successfully connected.
  final Set<String> _secondaryConnected = {};
  Set<String> get connectedSecondaryRelays => Set.unmodifiable(_secondaryConnected);

  /// Add a secondary relay subscription (idempotent).
  /// If the main loop is already running, starts immediately.
  /// Otherwise, queued and started when _ensureLoop() fires.
  void addSecondaryRelay(String relayUrl) {
    if (relayUrl == _relayUrl) return; // already primary
    if (!_isValidRelayUrl(relayUrl)) return;
    if (_secondaryRelays.contains(relayUrl)) return;
    _secondaryRelays.add(relayUrl);
    debugPrint('[Nostr] addSecondaryRelay: $relayUrl (running=$_running)');
    if (_running && _publicKeyHex.isNotEmpty) {
      _startSecondaryLoop(relayUrl);
    }
    // Otherwise, _ensureLoop() will start it when the main loop begins.
  }

  void _startSecondaryLoop(String relayUrl) {
    if (_secondaryRunning[relayUrl] == true) return;
    _secondaryRunning[relayUrl] = true;
    unawaited(_runSecondaryLoop(relayUrl));
  }

  Future<void> _runSecondaryLoop(String relayUrl) async {
    int failures = 0;
    const maxFailures = 8; // give up after 8 consecutive failures
    while (_running && _secondaryRelays.contains(relayUrl)) {
      final connectTime = DateTime.now();
      try {
        final ch = await _wsConnect(relayUrl);
        _secondaryChannels[relayUrl] = ch;
        await ch.ready;
        _registerRelayChannel(relayUrl, ch, _pendingKeyFetches);
        _secondaryConnected.add(relayUrl);
        failures = 0; // connected — reset
        debugPrint('[Nostr] Secondary sub connected to $relayUrl');

        final subId = 'sec_${DateTime.now().millisecondsSinceEpoch}_${Random.secure().nextInt(0xFFFFFF).toRadixString(16)}';
        ch.sink.add(jsonEncode(['REQ', subId, {
          'kinds': [4, 20000, 1059],
          '#p': [_publicKeyHex],
          'limit': 50,
        }]));

        await for (final raw in ch.stream) {
          if (!_running || !_secondaryRelays.contains(relayUrl)) break;
          try {
            final data = jsonDecode(raw as String) as List;
            if (data.isEmpty) continue;
            final cmd = data[0] as String;
            if (cmd == 'NOTICE' || cmd == 'CLOSED') continue;
            if (cmd == 'AUTH' && data.length >= 2) {
              final rawC = data[1] as String?;
              if (rawC != null && rawC.length <= 256 && _privateKeyHex.isNotEmpty) {
                unawaited(_nostrRespondToAuth(ch, relayUrl, rawC, _privateKeyHex));
              }
              continue;
            }
            if (cmd == 'OK' && data.length >= 3) {
              final okId = (data[1] as String?) ?? '';
              final accepted = data[2] == true;
              final c = _publishOkCompleters.remove(okId);
              if (c != null && !c.isCompleted) c.complete(accepted);
              continue;
            }
            // Dispatch pending fetchPublicKeys responses (pool-based key fetch).
            if (data.length >= 2) {
              final incomingSubId = data[1] as String?;
              if (incomingSubId != null && incomingSubId != subId) {
                final fetchCompleter = _pendingKeyFetches[incomingSubId];
                if (fetchCompleter != null && !fetchCompleter.isCompleted) {
                  if (cmd == 'EVENT' && data.length >= 3) {
                    try {
                      final fetchEvent = data[2] as Map<String, dynamic>;
                      if (!eb.verifyEventSignature(fetchEvent)) {
                        debugPrint('[Nostr] fetchPublicKeys secondary: invalid sig — dropped');
                      } else {
                        final bundle = jsonDecode(fetchEvent['content'] as String) as Map<String, dynamic>;
                        fetchCompleter.complete(bundle);
                      }
                    } catch (e) {
                      debugPrint('[Nostr] fetchPublicKeys secondary parse error: $e');
                    }
                  } else if (cmd == 'EOSE') {
                    fetchCompleter.complete(null);
                  }
                  continue;
                }
              }
            }
            if (cmd == 'EOSE') continue;
            if (data.length < 3 || cmd != 'EVENT') continue;
            final event = data[2] as Map<String, dynamic>?;
            if (event == null) continue;
            final id = event['id'] as String?;
            if (id == null || id.isEmpty) continue;
            if (_seenIds.containsKey(id)) continue; // dedup with primary
            _trackSeenId(id);
            // Re-dispatch through the same event processing as primary loop.
            // We call the shared _dispatchEvent.
            _dispatchEventFromSecondary(event);
          } catch (_) {}
        }
      } catch (e) {
        debugPrint('[Nostr] Secondary loop error ($relayUrl): $e');
      }
      _secondaryChannels.remove(relayUrl);
      _secondaryConnected.remove(relayUrl);
      _unregisterRelayChannel(relayUrl);
      if (!_running || !_secondaryRelays.contains(relayUrl)) break;

      // Short-lived connections count as failures too.
      final uptime = DateTime.now().difference(connectTime);
      if (uptime < const Duration(seconds: 30)) failures++;

      if (failures >= maxFailures) {
        debugPrint('[Nostr] Secondary relay $relayUrl: $maxFailures consecutive failures, giving up');
        _secondaryRelays.remove(relayUrl);
        break;
      }

      // Exponential backoff: 10s, 20s, 40s, 80s, 160s (capped at 5 min)
      final delaySec = min(10 * (1 << failures), 300);
      debugPrint('[Nostr] Secondary relay $relayUrl: retry in ${delaySec}s (failure $failures/$maxFailures)');
      await Future.delayed(Duration(seconds: delaySec));
    }
    _secondaryRunning.remove(relayUrl);
  }

  /// Dispatch an event from a secondary relay through the normal pipeline.
  void _dispatchEventFromSecondary(Map<String, dynamic> event) {
    final kind = (event['kind'] as int?) ?? -1;
    final id = event['id'] as String? ?? '';
    debugPrint('[Nostr] Secondary EVENT kind=$kind id=${id.length >= 8 ? id.substring(0, 8) : id}…');
    if (!eb.verifyEventSignature(event)) {
      debugPrint('[Nostr] Secondary: dropped event with invalid signature');
      return;
    }
    if (kind == 1059) {
      _dispatchGiftWrap(event);
    } else if (kind == 4) {
      _dispatchMessage(event);
    } else if (kind == 20000) {
      _dispatchSignal(event);
    }
  }

  void _closeSecondaryRelays() {
    for (final url in _secondaryRelays.toList()) {
      _secondaryRunning[url] = false;
      try { _secondaryChannels[url]?.sink.close(); } catch (_) {}
      _secondaryChannels.remove(url);
      _unregisterRelayChannel(url);
    }
  }

  bool _forceReconnectPending = false;
  DateTime _lastDataReceived = DateTime.fromMillisecondsSinceEpoch(0);

  /// Force-close the current subscription WS so the loop reconnects immediately.
  /// Call before starting a call to ensure a fresh, live subscription.
  /// Returns true if an actual reconnect was triggered.
  /// Skips reconnect if the subscription received data within the last 30s
  /// (the WS is clearly alive — reconnecting would cause a signal gap).
  bool forceReconnect({bool hard = false}) {
    final age = DateTime.now().difference(_lastDataReceived);
    if (!hard && age.inSeconds < 30 && _activeChannel != null) {
      debugPrint('[Nostr] forceReconnect: subscription alive (last data ${age.inSeconds}s ago), skipping');
      return false;
    }
    debugPrint('[Nostr] forceReconnect: closing subscription WS to trigger fresh connection');
    _forceReconnectPending = true;
    // Unregister from global pool FIRST — otherwise the reconnect loop sees
    // the stale entry via _getSharedRelayEntry and enters piggyback mode
    // instead of creating a fresh subscription.
    _unregisterRelayChannel(_relayUrl);
    try { _activeChannel?.sink.close(); } catch (_) {}
    _activeChannel = null;
    return true;
  }

  void _ensureLoop() {
    if (_loopStarted || _privateKeyHex.isEmpty) return;
    _loopStarted = true;
    _running = true;
    unawaited(_runSharedLoop());
    // Start any secondary relay loops that were queued before the loop started.
    for (final relay in _secondaryRelays) {
      _startSecondaryLoop(relay);
    }
  }

  /// Attempt to switch to a better relay via AdaptiveRelayService.
  /// Returns true if a valid alternative was found and _relayUrl was updated.
  Future<bool> _tryRelaySwitch() async {
    try {
      final better = await AdaptiveRelayService.instance
          .getBestRelay(force: true)
          .timeout(const Duration(seconds: 12), onTimeout: () => null);
      if (better != null && better != _relayUrl && _isValidRelayUrl(better)) {
        debugPrint('[Nostr] Relay switch: $_relayUrl → $better');
        _relayUrl = better;
        return true;
      }
    } catch (e) {
      debugPrint('[Nostr] Relay switch failed: $e');
    }
    // Fallback: try probe_nostr_relay if adaptive returned nothing
    try {
      final prefs = await _getPrefs();
      var probed = prefs.getString('probe_nostr_relay') ?? '';
      if (probed.isNotEmpty) {
        if (!probed.startsWith('ws://') && !probed.startsWith('wss://')) {
          probed = 'wss://$probed';
        }
        if (probed != _relayUrl && _isValidRelayUrl(probed)) {
          debugPrint('[Nostr] Relay switch (probe fallback): $_relayUrl → $probed');
          _relayUrl = probed;
          return true;
        }
      }
    } catch (e) {
      debugPrint('[Nostr] Probe relay fallback failed: $e');
    }
    return false;
  }

  Future<void> _runSharedLoop() async {
    while (_running) {
      WebSocketChannel? channel;
      bool cycleSuccess = false;
      final connectTime = DateTime.now();
      if (!_running) break;
      try {
        // If another reader already has a connection to this relay, don't open
        // a second one — many relays rate-limit or reject duplicate connections.
        // Instead, wait for the existing pool connection to close, then retry.
        final existingPool = _getSharedRelayEntry(_relayUrl);
        if (existingPool != null) {
          _activeChannel = existingPool.ch;
          debugPrint('[Nostr] Piggybacking on shared pool for $_relayUrl');
          // Wait until the pool channel closes before trying our own connection.
          // This avoids duplicate connections while still allowing key fetches
          // through the _pendingKeyFetches mechanism.
          while (_running && _getSharedRelayEntry(_relayUrl) != null) {
            await Future.delayed(const Duration(seconds: 5));
          }
          _activeChannel = null;
          continue; // Pool closed — retry with our own connection.
        }

        channel = await _wsConnect(_relayUrl);
        _activeChannel = channel;
        await channel.ready;
        _registerRelayChannel(_relayUrl, channel, _pendingKeyFetches);
        debugPrint('[Nostr] Connected to $_relayUrl');

        final subId = 'sub_${DateTime.now().millisecondsSinceEpoch}_${Random.secure().nextInt(0xFFFFFF).toRadixString(16)}';
        // F7: Do NOT include 'since' in the subscription filter.
        // Nostr relays apply 'since' to BOTH historical AND real-time events.
        // Gift Wrap ±1h jitter on created_at means ~50% of new events would
        // have created_at < since and be silently dropped by the relay.
        // Use only 'limit' for historical backfill; persistent _seenIds
        // handle dedup for events already processed.
        debugPrint('[Nostr] SUB (no since, limit=200) pk=${_publicKeyHex.substring(0, 8)}…');
        try {
          channel.sink.add(jsonEncode(['REQ', subId, {
            'kinds': [4, 20000, 1059],
            '#p': [_publicKeyHex],
            'limit': 200,
          }]));
        } catch (e) {
          debugPrint('[Nostr] sink.add failed: $e');
          rethrow;
        }

        cycleSuccess = true;
        if (!_isHealthy && !_healthCtrl.isClosed) {
          _isHealthy = true;
          _healthCtrl.add(true);
        }
        _consecutiveFailures = 0;

        try {
          await for (final raw in channel.stream) {
            _lastDataReceived = DateTime.now();
            try {
              if (raw is String && raw.length > 2 * 1024 * 1024) {
                debugPrint('[Nostr] oversized WS frame (${raw.length} bytes) — dropped');
                continue;
              }
              final data = jsonDecode(raw as String) as List;
              if (data.isEmpty) continue;

              // OK responses: ["OK", event_id, accepted, reason]
              // MUST be handled BEFORE the subId routing block below because
              // data[1] is a 64-char event ID, not a subscription ID — it is
              // always != subId, so the routing block would silently swallow it
              // with `continue` and the publish completer would never fire,
              // causing every _publishEvent on the shared channel to time out.
              if (data[0] == 'OK') {
                final okId = (data.length > 1 ? data[1] as String? : null) ?? '';
                final accepted = data.length > 2 && data[2] == true;
                final reason = data.length > 3 ? data[3] : '';
                final short = okId.length >= 8 ? okId.substring(0, 8) : okId;
                debugPrint('[Nostr] OK on sub channel: id=$short… accepted=$accepted reason=$reason');
                final c = _publishOkCompleters.remove(okId);
                if (c != null && !c.isCompleted) c.complete(accepted);
                continue;
              }

              // Issue 6: dispatch events/EOSE for pending fetchPublicKeys requests
              // before the main subscription filters them out.
              if (data.length >= 2) {
                final incomingSubId = data[1] as String?;
                if (incomingSubId != null && incomingSubId != subId) {
                  final fetchCompleter = _pendingKeyFetches[incomingSubId];
                  if (fetchCompleter != null && !fetchCompleter.isCompleted) {
                    if (data[0] == 'EVENT' && data.length >= 3) {
                      try {
                        final fetchEvent = data[2] as Map<String, dynamic>;
                        // Verify Schnorr signature before trusting
                        // Signal bundle content — a malicious relay could inject
                        // fabricated prekeys enabling MITM on all future messages.
                        if (!eb.verifyEventSignature(fetchEvent)) {
                          debugPrint('[Nostr] fetchPublicKeys inline: invalid sig — dropped');
                        } else {
                          final bundle = jsonDecode(fetchEvent['content'] as String) as Map<String, dynamic>;
                          fetchCompleter.complete(bundle);
                        }
                      } catch (e) {
                        debugPrint('[Nostr] fetchPublicKeys inline parse error: $e');
                      }
                    } else if (data[0] == 'EOSE') {
                      fetchCompleter.complete(null);
                    }
                  }
                  continue;
                }
              }

              if (data[0] == 'EOSE') {
                debugPrint('[Nostr] EOSE on $_relayUrl');
                continue;
              }
              // NIP-42: respond to AUTH challenges from the relay.
              if (data[0] == 'AUTH' && data.length >= 2) {
                final rawChallenge = data[1] as String?;
                // Reject oversized AUTH challenges — no legitimate relay sends
                // challenges longer than 64 bytes. Truncating and signing a
                // prefix would produce a signature the relay cannot verify anyway.
                if (rawChallenge == null || rawChallenge.length > 256) {
                  debugPrint('[Nostr] AUTH: challenge absent or too long, ignoring');
                  continue;
                }
                if (_privateKeyHex.isNotEmpty) {
                  unawaited(_nostrRespondToAuth(
                      channel, _relayUrl, rawChallenge, _privateKeyHex));
                }
                continue;
              }
              // Log relay notices and OK responses on subscription channel.
              if (data[0] == 'NOTICE') {
                debugPrint('[Nostr] NOTICE from $_relayUrl: ${data.length > 1 ? data[1] : ''}');
                continue;
              }
              if (data[0] == 'OK') {
                final okId = (data.length > 1 ? data[1] as String? : null) ?? '';
                final accepted = data.length > 2 && data[2] == true;
                final reason = data.length > 3 ? data[3] : '';
                final short = okId.length >= 8 ? okId.substring(0, 8) : okId;
                debugPrint('[Nostr] OK on sub channel: id=$short… accepted=$accepted reason=$reason');
                // Dispatch to publish completers so publishes via shared channel get confirmation.
                final c = _publishOkCompleters.remove(okId);
                if (c != null && !c.isCompleted) c.complete(accepted);
                continue;
              }
              if (data[0] == 'CLOSED') {
                debugPrint('[Nostr] Subscription CLOSED by relay: ${data.length > 2 ? data[2] : ''}');
                break; // Exit the stream loop to trigger reconnect
              }
              if (data.length < 3 || data[0] != 'EVENT') continue;
              if (data[1] != subId) {
                // Could be a fetchPublicKeys response already handled above
                continue;
              }
              final event = data[2] as Map<String, dynamic>?;
              if (event == null) continue;
              final id = event['id'] as String?;
              if (id == null || id.isEmpty) continue;
              final kind = (event['kind'] as int?) ?? -1;
              debugPrint('[Nostr] EVENT kind=$kind id=${id.substring(0, 8)}…');
              if (_seenIds.containsKey(id)) {
                debugPrint('[Nostr] Dedup: already seen ${id.substring(0, 8)}');
                continue;
              }
              // Track AFTER signature verification — a relay sending an invalid-sig
              // event with a real ID would poison the dedup cache and suppress the
              // legitimate event for up to 30 minutes.
              if (!eb.verifyEventSignature(event)) {
                debugPrint('[Nostr] Dropped event with invalid signature: $id');
                continue;
              }
              _trackSeenId(id);
              // F6: Track wall-clock time, NOT event timestamps.
              // Gift Wrap (kind 1059) has ±1h jitter on created_at, so using
              // event timestamps would make 'since' unreliable. Instead, record
              // the real time when we received events. The _getSince() method
              // subtracts the jitter window (3600s) to catch all jittered events.
              unawaited(_updateSince(DateTime.now().millisecondsSinceEpoch ~/ 1000));
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
          debugPrint('[Nostr] Subscription stream ended (relay closed connection)');
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

        // Try switching relay at key failure thresholds
        if (_consecutiveFailures == 3 || _consecutiveFailures == 10) {
          if (await _tryRelaySwitch()) {
            _consecutiveFailures = 0;
            continue;
          }
        }

        if (_consecutiveFailures >= _maxConsecutiveFailures) {
          // Last chance: try relay switch before giving up
          if (await _tryRelaySwitch()) {
            debugPrint('[Nostr] Relay switch at circuit breaker — continuing with reduced failures');
            _consecutiveFailures = 15;
            continue;
          }
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
        if (!_running) break;
      } else {
        // Successful cycle but relay closed gracefully.
        if (_forceReconnectPending) {
          _forceReconnectPending = false;
          _consecutiveFailures = 0;
          debugPrint('[Nostr] Force-reconnecting immediately…');
        } else {
          // If connection was very short-lived, relay might be down — use backoff.
          final connectionDuration = DateTime.now().difference(connectTime);
          if (connectionDuration < const Duration(seconds: 30)) {
            _consecutiveFailures++;
            final delay = _consecutiveFailures < 3 ? 5 : (_consecutiveFailures < 10 ? 30 : 300);
            debugPrint('[Nostr] Short-lived connection (${connectionDuration.inSeconds}s) — reconnecting in ${delay}s');
            await Future.delayed(Duration(seconds: delay));
          } else {
            _consecutiveFailures = 0;
            debugPrint('[Nostr] Reconnecting in 2s…');
            await Future.delayed(const Duration(seconds: 2));
          }
        }
        if (!_running) break;
      }
    }
    _activeChannel = null;
    _unregisterRelayChannel(_relayUrl);
  }

  Future<void> _dispatchGiftWrap(Map<String, dynamic> event) async {
    final wrapId = ((event['id'] as String?) ?? '').length >= 8
        ? (event['id'] as String).substring(0, 8) : (event['id'] ?? '?');
    debugPrint('[Nostr] Gift Wrap: unwrapping $wrapId…');
    try {
      final inner = await giftwrap.unwrapEvent(
        recipientPrivkey: _privateKeyHex,
        wrapEvent: event,
      );
      if (inner == null) {
        final wrapPk = (event['pubkey'] as String? ?? '').length >= 8
            ? (event['pubkey'] as String).substring(0, 8) : event['pubkey'];
        debugPrint('[Nostr] Gift Wrap: failed to unwrap $wrapId (pk=$wrapPk…)');
        return;
      }
      final innerKind = (inner['kind'] as int?) ?? -1;
      debugPrint('[Nostr] Gift Wrap: unwrapped OK $wrapId → inner kind=$innerKind');
      // Reject inner events older than 7 days — the outer envelope timestamp
      // has ±1h jitter for privacy, but the inner event's created_at is
      // authentic (signed by sender). Without this check, an archived inner
      // event can be replayed after the 30-minute _seenIds TTL expires.
      final innerTs = (inner['created_at'] as int?) ?? 0;
      final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (innerTs < nowSec - 7 * 86400) {
        debugPrint('[Nostr] Gift Wrap: inner event too old ($innerTs), dropping');
        return;
      }
      // F2-3: Dedup inner event by inner event ID — outer ID (ephemeral) changes
      // on every re-broadcast, so we must check the semantic inner ID.
      final innerId = inner['id'] as String? ?? '';
      if (innerId.isNotEmpty && _seenIds.containsKey(innerId)) {
        debugPrint('[Nostr] Gift Wrap: inner dedup $wrapId (innerId=${innerId.substring(0, 8)})');
        return;
      }
      // Dispatch UNCONDITIONALLY: even if this reader is closed, another
      // reader (the new main reader after reconnectInbox) may be listening
      // on the same StreamController set via InboxManager's swap — wait, no,
      // each NostrInboxReader has its own _msgCtrl. So "closed reader"
      // means "listener cancelled its subscription". Broadcast controllers
      // silently drop add()s with no listeners, so the dispatch here is a
      // safe no-op in that case. The important invariant we enforce below
      // is: only persist innerId in _seenIds IF a listener actually saw
      // the event — otherwise we'd poison the persistent dedup cache and
      // the new reader (which shares disk state) would drop the re-received
      // event thinking it's a dup. We check hasListener AFTER add() which
      // is exactly the race we need: if the subscription was still active
      // at dispatch time, the listener got the event before we track.
      final bool delivered;
      if (innerKind == 4) {
        delivered = _msgCtrl.hasListener;
        _dispatchMessage(inner);
      } else if (innerKind == 20000) {
        delivered = _sigCtrl.hasListener;
        _dispatchSignal(inner);
      } else {
        debugPrint('[Nostr] Gift Wrap: unknown inner kind $innerKind');
        delivered = false;
      }
      // Track seenId only when the event reached a live listener. If no
      // listener (reader closed or subscription cancelled), let the next
      // reader re-receive and deliver it; the outer-id dedup on that
      // reader's _seenIds (populated freshly at init) will not fire, and
      // the inner event is replayed to the active subscription.
      if (delivered && innerId.isNotEmpty) _trackSeenId(innerId);
      if (!delivered && _closed) {
        debugPrint('[Nostr] Gift Wrap: reader closed, dispatch dropped for $wrapId — new reader will redeliver');
      }
    } catch (e) {
      debugPrint('[Nostr] Gift Wrap dispatch error for $wrapId: $e');
    }
  }

  void _dispatchMessage(Map<String, dynamic> event) {
    try {
      final id = event['id'] as String? ?? '';
      final pubkey = event['pubkey'] as String? ?? '';
      final content = event['content'] as String? ?? '';
      final createdAt = event['created_at'] as int?;
      if (id.isEmpty || pubkey.isEmpty || content.isEmpty) return;
      debugPrint('[Nostr] _dispatchMessage: id=${id.substring(0, 8)} pk=${pubkey.substring(0, 8)} hasListener=${_msgCtrl.hasListener} closed=$_closed');
      if (_closed) return;
      _msgCtrl.add([Message(
        id: id,
        senderId: pubkey,
        receiverId: _publicKeyHex,
        encryptedPayload: content,
        timestamp: createdAt != null && createdAt > 0 && createdAt < 32503680000
            ? DateTime.fromMillisecondsSinceEpoch(createdAt * 1000)
            : DateTime.now(),
        adapterType: 'nostr',
      )]);
    } catch (e) {
      debugPrint('[Nostr] Failed to parse message: $e');
    }
  }

  Future<void> _dispatchSignal(Map<String, dynamic> event) async {
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
        // Do NOT fall back to NIP-04 on any NIP-44 failure — a crafted structural
        // error (e.g. "NIP-44: padded data too short") would bypass auth-failure
        // detection and attempt NIP-04 decryption of attacker-controlled ciphertext.
        // The "coincidental 0x02 first byte" NIP-04 case is a vanishing edge case
        // that we sacrifice for security. NIP-44 is mandatory when indicated.
        plain = await nip44.nip44DecryptWithKeys(_privateKeyHex, senderPubkey, content);
      } else {
        plain = _nip04Decrypt(_privateKeyHex, senderPubkey, content);
      }

      final data = jsonDecode(plain) as Map<String, dynamic>;
      final sigType = data['type'] as String? ?? '';
      debugPrint('[Nostr] _dispatchSignal: type=$sigType from=${senderPubkey.length >= 8 ? senderPubkey.substring(0, 8) : senderPubkey}');
      // Skip on a closed reader — see _dispatchGiftWrap for the race explanation.
      // _dispatchSignal is async (awaits NIP-44 decryption above), so a close()
      // can interleave between the decrypt and the add. Checking _closed rather
      // than _sigCtrl.isClosed because controllers are never closed.
      if (!_closed) {
        _sigCtrl.add([{
          'type': data['type'],
          'senderId': senderPubkey,
          'roomId': data['roomId'],
          'payload': data['payload'],
          // F4-1: Mark as Nostr-adapter signal so SignalDispatcher can skip HMAC
          // only for signals that went through Schnorr verification above.
          'adapterType': 'nostr',
        }]);
      }
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

  /// Issue 6: reuse the active shared-loop WebSocket for key fetches when available.
  /// Sends a separate REQ on the existing channel; the shared loop dispatches
  /// matching responses via _pendingKeyFetches. Falls back to a new connection
  /// only if the shared loop isn't running.
  @override
  Future<Map<String, dynamic>?> fetchPublicKeys() async {
    if (_publicKeyHex.isEmpty || _relayUrl.isEmpty) {
      debugPrint('[Nostr] fetchPublicKeys: skip (pubkey=${_publicKeyHex.isEmpty ? "empty" : "ok"}, relay=${_relayUrl.isEmpty ? "empty" : _relayUrl})');
      return null;
    }
    debugPrint('[Nostr] fetchPublicKeys: pubkey=${_publicKeyHex.substring(0, 8)}… relay=$_relayUrl');

    final activeChannel = _activeChannel;
    final subId = 'keys_${DateTime.now().millisecondsSinceEpoch}_${Random.secure().nextInt(0xFFFFFF).toRadixString(16)}';

    // Issue 6: if the shared loop is active, piggyback on its WS connection.
    if (activeChannel != null) {
      final completer = Completer<Map<String, dynamic>?>();
      _pendingKeyFetches[subId] = completer;
      try {
        activeChannel.sink.add(jsonEncode(['REQ', subId, {
          'kinds': [10009],
          'authors': [_publicKeyHex],
          'limit': 1,
        }]));
        final result = await completer.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () => null,
        );
        // Close the relay-side subscription for this REQ.
        try { activeChannel.sink.add(jsonEncode(['CLOSE', subId])); } catch (_) {}
        return result;
      } catch (e) {
        debugPrint('[Nostr] fetchPublicKeys (shared) error: $e');
        return null;
      } finally {
        _pendingKeyFetches.remove(subId);
      }
    }

    // Fallback 2: borrow a shared pool channel from another reader on the same relay.
    // We inject our completer into the owner reader's _pendingKeyFetches map so its
    // shared loop dispatches the response — no second .listen() needed.
    final poolEntry = _getSharedRelayEntry(_relayUrl);
    if (poolEntry != null) {
      final poolSubId = 'keys_pool_${DateTime.now().millisecondsSinceEpoch}_${Random.secure().nextInt(0xFFFFFF).toRadixString(16)}';
      final c2 = Completer<Map<String, dynamic>?>();
      poolEntry.fetches[poolSubId] = c2;
      try {
        poolEntry.ch.sink.add(jsonEncode(['REQ', poolSubId, {
          'kinds': [10009],
          'authors': [_publicKeyHex],
          'limit': 1,
        }]));
        final result = await c2.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () => null,
        );
        try { poolEntry.ch.sink.add(jsonEncode(['CLOSE', poolSubId])); } catch (_) {}
        return result;
      } catch (e) {
        debugPrint('[Nostr] fetchPublicKeys (pool) error: $e');
        return null;
      } finally {
        poolEntry.fetches.remove(poolSubId);
      }
    }

    // Fallback 3: no shared pool — open a one-shot connection.
    debugPrint('[Nostr] fetchPublicKeys: opening one-shot to $_relayUrl');
    final completer = Completer<Map<String, dynamic>?>();
    WebSocketChannel? channel;
    StreamSubscription<dynamic>? sub;
    try {
      channel = await _wsConnect(_relayUrl);
      debugPrint('[Nostr] fetchPublicKeys: one-shot connected, sending REQ');
      await channel.ready;
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
            // Verify Schnorr signature on one-shot key fetch
            if (!eb.verifyEventSignature(event)) {
              debugPrint('[Nostr] fetchPublicKeys one-shot: invalid sig — dropped');
            } else {
              final bundle = jsonDecode(event['content'] as String) as Map<String, dynamic>;
              if (!completer.isCompleted) completer.complete(bundle);
            }
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

  Future<void> _updateSince(int unixSeconds) async {
    final prefs = await _getPrefs();
    final key = 'nostr_since_${_relayUrl.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
    final current = prefs.getInt(key) ?? 0;
    if (unixSeconds > current) await prefs.setInt(key, unixSeconds);
  }

  @override
  Future<String?> provisionGroup(String groupName) async => '$_publicKeyHex@$_relayUrl';

  /// Reload force-Tor setting and force-reconnect so new route takes effect.
  Future<void> resetConnections() async {
    final prefs = await _getPrefs();
    _forceTor = prefs.getBool('nostr_force_tor') ?? false;
    debugPrint('[Nostr] Reader reset, forceTor=$_forceTor');
    forceReconnect(hard: true);
  }

  /// Stop event loop and clear private key from memory.
  void zeroize() {
    close();
    _privateKeyHex = '';
    _publicKeyHex = '';
    // Clear caches that may hold derived key material.
    clearEcdhCache();
    _pubkeyCache.clear();
  }
}

// ─── MessageSender ───────────────────────────────────────

class NostrMessageSender implements MessageSender {
  String _privateKeyHex = '';
  String _relayUrl = _defaultRelay;

  SharedPreferences? _prefs;
  Future<SharedPreferences> _getPrefs() async =>
      _prefs ??= await SharedPreferences.getInstance();

  // Persistent WS pool: relay URL → (channel, lastUsed)
  final Map<String, ({WebSocketChannel ch, DateTime ts})> _wsPool = {};
  static const _wsPoolTtl = Duration(minutes: 5);
  final Map<String, StreamSubscription> _wsPoolSubs = {};
  Timer? _wsPoolCleanupTimer;
  // OK completers now module-level (_publishOkCompleters) so both
  // subscription loop and pool listener can dispatch confirmations.
  /// Backoff: relay URL → earliest time to reconnect (prevents reconnect storms).
  final Map<String, DateTime> _wsPoolBackoff = {};
  /// Connection lock: prevents thundering herd when many publishes fire concurrently.
  /// First caller creates the WS; others await the same future.
  final Map<String, Completer<WebSocketChannel?>> _wsPoolConnecting = {};

  /// Tracks whether pool connections were created via Tor.
  /// When this doesn't match the current forceTor+isBootstrapped state,
  /// the pool is evicted so new connections use the correct route.
  bool _poolCreatedWithTor = false;

  // initializeSender dedup: skip re-reading prefs when apiKey unchanged within TTL.
  String _lastInitApiKey = '';
  int _lastInitMs = 0;
  static const _initTtlMs = 10000; // 10 seconds

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

  // Force all Nostr through Tor — loaded once in initializeSender
  bool _forceTor = false;

  Future<WebSocketChannel> _wsConnect(String url) => _nostrWsConnect(url,
      torEnabled: _torEnabled, torHost: _torHost, torPort: _torPort,
      i2pEnabled: _i2pEnabled, i2pHost: _i2pHost, i2pPort: _i2pPort,
      customProxyEnabled: _customProxyEnabled,
      customProxyHost: _customProxyHost, customProxyPort: _customProxyPort,
      cfWorkerRelay: _cfWorkerRelay, forceTor: _forceTor);

  @override
  Future<void> initializeSender(String apiKey) async {
    // Start the pool cleanup timer once — runs even on dedup skips so that
    // idle relay connections are proactively closed every 5 minutes.
    _wsPoolCleanupTimer ??= Timer.periodic(const Duration(minutes: 5), (_) {
      final staleKeys = <String>[];
      final now = DateTime.now();
      for (final entry in _wsPool.entries) {
        if (now.difference(entry.value.ts) >= _wsPoolTtl) {
          staleKeys.add(entry.key);
        }
      }
      for (final key in staleKeys) {
        final entry = _wsPool.remove(key);
        _wsPoolSubs.remove(key)?.cancel();
        try { entry?.ch.sink.close(); } catch (_) {}
      }
    });

    // Skip re-reading prefs when apiKey is unchanged within TTL (avoids 11+
    // SharedPreferences lookups per message on high-frequency sends).
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    if (apiKey == _lastInitApiKey && nowMs - _lastInitMs < _initTtlMs) return;
    _lastInitApiKey = apiKey;
    _lastInitMs = nowMs;

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
    final prefs = await _getPrefs();
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
    _forceTor = prefs.getBool('nostr_force_tor') ?? false;

    // Probe-suggested and adaptive relays are handled by sendMessage() fallback
    // logic (gatherKnownRelays). Don't override the primary relay here — a probed
    // relay may be dead, causing all sends to fail before fallback kicks in.
  }

  /// Get or create a pooled WebSocket connection for a relay.
  /// Uses a connection lock to prevent thundering herd: when multiple publishes
  /// fire concurrently, only the first creates a WS — the rest await the same future.
  Future<WebSocketChannel?> _getPooledWs(String relayUrl) async {
    // 0. Route-change detection: evict pool if Tor availability changed.
    //    Handles: forceTor enabled before Tor ready → pool has non-Tor conn
    //    → Tor bootstraps → next send evicts pool → reconnects via Tor.
    final shouldUseTor = _forceTor && _torEnabled && tor.TorService.instance.isBootstrapped;
    if (shouldUseTor != _poolCreatedWithTor) {
      debugPrint('[Nostr] Route check: forceTor=$_forceTor torEnabled=$_torEnabled bootstrapped=${tor.TorService.instance.isBootstrapped} shouldUseTor=$shouldUseTor poolHadTor=$_poolCreatedWithTor poolSize=${_wsPool.length}');
    }
    if (shouldUseTor != _poolCreatedWithTor && _wsPool.isNotEmpty) {
      debugPrint('[Nostr] Pool evicted: route changed (tor=$shouldUseTor)');
      for (final entry in _wsPool.values) {
        try { entry.ch.sink.close(); } catch (_) {}
      }
      _wsPool.clear();
      for (final sub in _wsPoolSubs.values) { sub.cancel(); }
      _wsPoolSubs.clear();
      _wsPoolBackoff.clear();
    }
    final routeChanged = shouldUseTor != _poolCreatedWithTor;
    _poolCreatedWithTor = shouldUseTor;

    // 1. Check existing cached connection.
    final cached = _wsPool[relayUrl];
    if (cached != null) {
      final (ch: cachedCh, ts: cachedTs) = cached;
      if (DateTime.now().difference(cachedTs) < _wsPoolTtl) {
        _wsPool[relayUrl] = (ch: cachedCh, ts: DateTime.now()); // touch
        return cachedCh;
      }
      // Stale — close and reconnect.
      _wsPool.remove(relayUrl);
      _wsPoolSubs.remove(relayUrl)?.cancel();
      try { cachedCh.sink.close(); } catch (_) {}
    }

    // 2. Check shared relay pool (subscription channel on same relay).
    //    Skip if route just changed — shared connection uses the old route.
    if (!routeChanged) {
      final shared = _getSharedRelayEntry(relayUrl);
      if (shared != null) return shared.ch;
    }

    // 3. Backoff: don't reconnect too soon after a rejection/block.
    final backoffUntil = _wsPoolBackoff[relayUrl];
    if (backoffUntil != null && DateTime.now().isBefore(backoffUntil)) {
      debugPrint('[Nostr] Pool backoff active for $relayUrl');
      return null;
    }

    // 4. Connection lock: if another caller is already connecting, wait for it.
    final pending = _wsPoolConnecting[relayUrl];
    if (pending != null) {
      debugPrint('[Nostr] Pool connect in progress for $relayUrl — waiting');
      return pending.future;
    }

    // 5. We are the first — create the connection, others will await our completer.
    final lock = Completer<WebSocketChannel?>();
    _wsPoolConnecting[relayUrl] = lock;
    try {
      final ch = await _wsConnect(relayUrl);
      await ch.ready;
      _wsPool[relayUrl] = (ch: ch, ts: DateTime.now());
      _wsPoolBackoff.remove(relayUrl);
      // Listen for close/errors to evict from pool; also handle NIP-42 AUTH + OK.
      final sub = ch.stream.listen(
        (raw) {
          try {
            final data = jsonDecode(raw as String) as List;
            if (data.isEmpty) return;
            final cmd = data[0] as String;
            if (cmd == 'AUTH' && data.length >= 2) {
              final rawC = data[1] as String?;
              if (rawC == null || rawC.length > 256) {
                debugPrint('[Nostr] sender AUTH: challenge absent or too long, ignoring');
                return;
              }
              if (_privateKeyHex.isNotEmpty) {
                unawaited(_nostrRespondToAuth(ch, relayUrl, rawC, _privateKeyHex));
              }
            } else if (cmd == 'OK' && data.length >= 3) {
              final evId = (data[1] as String?) ?? '?';
              final accepted = data[2] == true;
              final reason = data.length > 3 ? (data[3] as String? ?? '') : '';
              final short = evId.length >= 8 ? evId.substring(0, 8) : evId;
              debugPrint('[Nostr] POOL OK id=$short… accepted=$accepted reason=$reason');
              final c = _publishOkCompleters.remove(evId);
              if (c != null && !c.isCompleted) c.complete(accepted);
            } else if (cmd == 'NOTICE' && data.length >= 2) {
              debugPrint('[Nostr] POOL NOTICE: ${data[1]}');
            }
          } catch (_) {}
        },
        onDone: () {
          _wsPool.remove(relayUrl);
          _wsPoolSubs.remove(relayUrl)?.cancel();
        },
        onError: (_) {
          _wsPool.remove(relayUrl);
          _wsPoolSubs.remove(relayUrl)?.cancel();
        },
        cancelOnError: true,
      );
      _wsPoolSubs[relayUrl] = sub;
      lock.complete(ch);
      return ch;
    } catch (e) {
      debugPrint('[Nostr] Pool connect failed: $e');
      _wsPoolBackoff[relayUrl] = DateTime.now().add(const Duration(seconds: 30));
      lock.complete(null);
      return null;
    } finally {
      _wsPoolConnecting.remove(relayUrl);
    }
  }

  Future<bool> _publishEvent(Map<String, dynamic> event, String relayUrl) async {
    final evId = ((event['id'] as String?) ?? '').length >= 8
        ? (event['id'] as String).substring(0, 8) : '?';
    debugPrint('[Nostr] _publishEvent id=$evId… → $relayUrl');
    try {
      // _getPooledWs handles: cached pool → shared relay → locked connect.
      // All concurrent publishes share a single connection per relay.
      final channel = await _getPooledWs(relayUrl);
      if (channel == null) {
        debugPrint('[Nostr] _publishEvent FAIL id=$evId… — no connection to $relayUrl');
        return false;
      }

      final eventId = event['id'] as String? ?? '';
      channel.sink.add(jsonEncode(['EVENT', event]));
      debugPrint('[Nostr] _publishEvent sent id=$evId… via pool');

      // Wait for OK via module-level _publishOkCompleters.
      // Both pool listener and subscription loop dispatch to this map.
      final completer = Completer<bool>();
      if (eventId.isNotEmpty) _publishOkCompleters[eventId] = completer;
      final result = await completer.future.timeout(
        const Duration(seconds: 3), onTimeout: () {
          _publishOkCompleters.remove(eventId);
          debugPrint('[Nostr] _publishEvent timeout waiting for OK id=$evId…');
          // Evict stale pool entry — the WS is likely dead.
          _wsPool.remove(relayUrl);
          _wsPoolSubs.remove(relayUrl)?.cancel();
          // Short backoff: 8 s is enough to avoid hammering a slow relay but
          // allows the next voice chunk to retry quickly (60 s was too long and
          // caused multi-chunk voice sends to stall for minutes).
          _wsPoolBackoff[relayUrl] = DateTime.now().add(const Duration(seconds: 8));
          return false;
        },
      );
      if (!result) {
        debugPrint('[Nostr] _publishEvent REJECTED id=$evId…');
      }
      return result;
    } catch (e) {
      debugPrint('[Nostr] Failed to publish: $e');
      _wsPool.remove(relayUrl);
      _wsPoolSubs.remove(relayUrl)?.cancel();
      _wsPoolBackoff[relayUrl] = DateTime.now().add(const Duration(seconds: 5));
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
    // Validate relay URL extracted from contact address — a malicious contact
    // imported via deep-link could set relay to ws://192.168.x.x/exfil.
    final rawRelay = parts.length > 1 ? parts.sublist(1).join('@') : '';
    final relay = (rawRelay.isNotEmpty && _isValidRelayUrl(rawRelay)) ? rawRelay : _relayUrl;

    debugPrint('[Nostr] sendMessage: recipient=${recipientPubkey.substring(0, 8)}… relay=$relay');
    try {
      // Wrap kind:4 message in Gift Wrap (NIP-59) for metadata privacy
      final event = await giftwrap.wrapEvent(
        senderPrivkey: senderKey,
        recipientPubkey: recipientPubkey,
        innerKind: 4,
        innerContent: message.encryptedPayload,
        innerTags: [['p', recipientPubkey]],
      );
      final wrapTs = event['created_at'];
      debugPrint('[Nostr] sendMessage: GiftWrap created_at=$wrapTs (jitter=${wrapTs - DateTime.now().millisecondsSinceEpoch ~/ 1000}s)');
      if (await _publishEvent(event, relay)) return true;
      // Retry once on same relay (pool entry was evicted on timeout, fresh WS).
      debugPrint('[Nostr] sendMessage: first attempt failed, retrying $relay');
      if (await _publishEvent(event, relay)) return true;
      // Fallback: publish to own relay if target relay failed (rate-limited, down, etc.)
      if (relay != _relayUrl) {
        debugPrint('[Nostr] sendMessage: target relay failed, trying own relay $_relayUrl');
        if (await _publishEvent(event, _relayUrl)) return true;
      }
      // Fallback: try all known relays (skip already tried)
      final tried = <String>{relay, _relayUrl};
      final fallbacks = await gatherKnownRelays(_relayUrl);
      for (final fb in fallbacks) {
        if (tried.contains(fb)) continue;
        debugPrint('[Nostr] sendMessage: trying fallback relay $fb');
        if (await _publishEvent(event, fb)) return true;
      }
      return false;
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
    final rawRelayS = parts.length > 1 ? parts.sublist(1).join('@') : '';
    final relay = (rawRelayS.isNotEmpty && _isValidRelayUrl(rawRelayS)) ? rawRelayS : _relayUrl;
    debugPrint('[Nostr] sendSignal: type=$type recipient=${recipientPubkey.substring(0, 8)}… relay=$relay');

    // Signal key bundle (sys_keys): must use real key (kind 10009, replaceable by pubkey).
    // Use _relayUrl (sender's configured relay) — publishOwnKeys creates a sender
    // per relay, so each sender targets a specific relay for redundancy.
    if (type == 'sys_keys') {
      if (_privateKeyHex.isEmpty) return false; // sys_keys requires real identity
      final sysKeysRelay = _relayUrl.isNotEmpty ? _relayUrl : relay;
      try {
        final event = await eb.buildEvent(
          privkeyHex: _privateKeyHex,
          kind: 10009,
          content: jsonEncode(payload),
          tags: [['d', 'signal_bundle']],
        );
        return await _publishEvent(event, sysKeysRelay);
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
      if (await _publishEvent(event, relay)) return true;
      // Fallback: publish to own relay if target relay failed (rate-limited, down, etc.)
      if (relay != _relayUrl) {
        debugPrint('[Nostr] sendSignal: target relay failed, trying own relay $_relayUrl');
        if (await _publishEvent(event, _relayUrl)) return true;
      }
      // Fallback: try all known relays (skip already tried)
      final tried = <String>{relay, _relayUrl};
      final fallbacks = await gatherKnownRelays(_relayUrl);
      for (final fb in fallbacks) {
        if (tried.contains(fb)) continue;
        debugPrint('[Nostr] sendSignal: trying fallback relay $fb');
        if (await _publishEvent(event, fb)) return true;
      }
      return false;
    } catch (e) {
      debugPrint('[Nostr] sendSignal error: $e');
      return false;
    }
  }

  Future<bool> publishProfile({required String name, String? about}) async {
    if (_privateKeyHex.isEmpty) return false;
    try {
      final event = await eb.buildEvent(
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

  /// Close all pooled connections and reload force-Tor setting.
  /// Called when proxy settings change so next connections use new route.
  Future<void> resetConnections() async {
    for (final entry in _wsPool.values) {
      try { entry.ch.sink.close(); } catch (_) {}
    }
    _wsPool.clear();
    for (final sub in _wsPoolSubs.values) {
      sub.cancel();
    }
    _wsPoolSubs.clear();
    _wsPoolBackoff.clear();
    // Force re-read of settings on next initializeSender call
    _lastInitMs = 0;
    final prefs = await _getPrefs();
    _forceTor = prefs.getBool('nostr_force_tor') ?? false;
    debugPrint('[Nostr] Sender pool reset, forceTor=$_forceTor');
  }

  /// Clear private key from memory and close pooled connections.
  void zeroize() {
    _wsPoolCleanupTimer?.cancel();
    _wsPoolCleanupTimer = null;
    _privateKeyHex = '';
    for (final entry in _wsPool.values) {
      try { entry.ch.sink.close(); } catch (_) {}
    }
    _wsPool.clear();
    for (final sub in _wsPoolSubs.values) {
      sub.cancel();
    }
    _wsPoolSubs.clear();
    // Clear caches that may hold derived key material.
    clearEcdhCache();
    _pubkeyCache.clear();
  }
}
