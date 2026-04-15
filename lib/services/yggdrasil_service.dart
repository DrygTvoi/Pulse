import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

// ── Yggdrasil Overlay Network Service ─────────────────────────────────────────
//
// Yggdrasil is a decentralised overlay network that assigns every node a
// globally-routable 200::/7 IPv6 address derived from its public key.
// Connectivity is peer-to-peer once bootstrapped — no central relay needed.
//
// Architecture for Pulse calls:
//   • The pulse-utls-proxy Go binary embeds a Yggdrasil node AND a local
//     pion/turn server on 127.0.0.1:53478.
//   • The TURN relay addresses are Yggdrasil IPv6 + port.
//   • Flutter WebRTC connects to the local TURN as any other TURN server.
//   • Outbound connections to remote Yggdrasil relay addresses are bridged
//     via POST /ygg/proxy — creates a local UDP proxy backed by Yggdrasil TCP.
//   • The ICE candidate interceptor in SignalingService rewrites remote
//     Yggdrasil candidates to 127.0.0.1:LOCAL_PORT before passing to WebRTC.
//
// This provides censorship-resistant P2P calls without VpnService or any
// developer-operated infrastructure.  Works on Android without root.
//
// Graceful degradation:
//   • If the Go binary is not running or Yggdrasil fails to bootstrap,
//     isReady is false and all TURN / proxy calls are no-ops.
//   • Existing STUN/TURN path is completely unaffected.

class YggdrasilService {
  static YggdrasilService instance = YggdrasilService._();
  YggdrasilService._();

  /// Protected constructor for test subclasses.
  @visibleForTesting
  YggdrasilService.forTesting();

  /// Replace the singleton for testing.
  @visibleForTesting
  static void setInstanceForTesting(YggdrasilService inst) => instance = inst;

  String? _address;    // "200:aaa::1" — our Yggdrasil IPv6 (without brackets)
  String? _pubkey;     // base64 ed25519 public key (for proxy requests)
  int?    _port;       // HTTP port of the pulse-utls-proxy Go binary
  String? _token;      // per-session secret for /ygg and /ygg/proxy auth
  int     _turnPort = 0; // actual TURN port reported by Go binary (0 = TURN not running)
  String  _turnUser = '';     // runtime-generated TURN username (from /ygg response)
  String  _turnPassword = ''; // runtime-generated TURN password (from /ygg response)
  bool    _initialised  = false;
  bool    _initialising = false; // guard against concurrent init() calls

  /// True when Yggdrasil bootstrapped successfully AND the local TURN is live.
  /// If TURN failed to start (e.g. port conflict), isReady is false so we
  /// don't advertise a broken TURN server to WebRTC.
  bool get isReady => _address != null && _port != null && _turnPort > 0;

  /// Our Yggdrasil IPv6 address (without brackets), e.g. "200:aaa::1".
  String? get address => _address;

  /// Our ed25519 public key in base64, sent in signaling offer/answer so the
  /// remote peer can construct Yggdrasil overlay routes back to us.
  String? get pubkey => _pubkey;

  // ── ICE server entry ───────────────────────────────────────────────────────

  /// Returns an RTCIceServer entry for our local pion/turn relay, or null
  /// when Yggdrasil is not running.
  ///
  /// Uses the actual TURN port reported by the Go binary — handles port
  /// conflicts where the preferred port 53478 was already in use.
  Map<String, dynamic>? get iceServerEntry {
    if (!isReady || _turnUser.isEmpty || _turnPassword.isEmpty) return null;
    return {
      'urls':       'turn:127.0.0.1:$_turnPort',
      'username':   _turnUser,
      'credential': _turnPassword,
    };
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  /// Initialise by querying the Go binary's /ygg endpoint.
  ///
  /// [proxyPort] is the port printed by pulse-utls-proxy to stdout —
  /// the same port used for the HTTP CONNECT proxy.
  ///
  /// Safe to call multiple times.
  /// Re-initialises when [proxyPort] changes — handles Go binary restarts
  /// where the old HTTP port is closed and a new port is assigned.
  Future<void> init(int proxyPort, {String? token}) async {
    if (_initialised && _port == proxyPort) return;
    if (_initialising) return; // concurrent call already in progress — let it finish
    _initialising = true;
    // Binary restarted (new port) or first call — reset all state.
    _initialised = false;
    _address     = null;
    _pubkey      = null;
    _turnPort    = 0;
    _port  = proxyPort;
    _token = token;
    final client = HttpClient();
    try {
      final request = await client
          .getUrl(Uri.parse('http://127.0.0.1:$proxyPort/ygg'))
          .timeout(const Duration(seconds: 5));
      if (token != null) request.headers.set('X-Proxy-Token', token);
      final response = await request.close().timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final body = await response
            .transform(utf8.decoder)
            .join()
            .timeout(const Duration(seconds: 3));
        if (body.length > 65536) {
          throw FormatException('Yggdrasil /ygg response too large (${body.length} bytes)');
        }
        final data     = jsonDecode(body) as Map<String, dynamic>;
        final addr     = data['addr']      as String?;
        final pubkey   = data['pubkey']    as String?;
        final turnPort = (data['turn_port'] as num?)?.toInt() ?? 0;
        final turnUser = data['user']      as String? ?? '';
        final turnPass = data['pass']      as String? ?? '';
        if (addr != null && addr.isNotEmpty &&
            turnPort > 0 && turnPort <= 65535 &&
            turnUser.isNotEmpty && turnPass.isNotEmpty) {
          _address      = addr;
          _pubkey       = pubkey;
          _turnPort     = turnPort;
          _turnUser     = turnUser;
          _turnPassword = turnPass;
          _initialised  = true;
          debugPrint('[Yggdrasil] Ready: addr=$_address, turn=127.0.0.1:$_turnPort');
        } else if (addr != null && addr.isNotEmpty && turnPort == 0) {
          debugPrint('[Yggdrasil] node ready but TURN not running (port conflict?)');
        } else {
          debugPrint('[Yggdrasil] /ygg returned no address (Yggdrasil not started)');
        }
      } else {
        debugPrint('[Yggdrasil] /ygg HTTP ${response.statusCode} '
            '(binary may not support Yggdrasil)');
      }
    } catch (e) {
      debugPrint('[Yggdrasil] init failed (non-fatal): $e');
    } finally {
      client.close();
      _initialising = false;
    }
  }

  // ── Outbound proxy ─────────────────────────────────────────────────────────

  /// Creates a local UDP↔Yggdrasil bridge for [yggRelayAddr].
  ///
  /// [yggRelayAddr] is a Yggdrasil relay address in "[200:x:y::z]:port" form,
  /// as found in an incoming ICE relay candidate.
  ///
  /// [remotePubkey] is the remote node's base64 ed25519 public key, received
  /// in their signaling offer/answer.  Required for overlay routing.
  ///
  /// Returns the local UDP port number on 127.0.0.1, or null on failure.
  ///
  /// The bridge persists until the Go binary exits.  Multiple calls with the
  /// same target reuse the same proxy (deduplicated on the Go side).
  Future<int?> proxyRemote(String yggRelayAddr, String remotePubkey) async {
    if (!isReady) return null;
    // Cap input lengths to prevent Go binary amplification via
    // malicious ICE candidate with a huge address string.
    if (yggRelayAddr.length > 60 || remotePubkey.length > 64) {
      debugPrint('[Yggdrasil] proxyRemote rejected oversized params');
      return null;
    }
    final client = HttpClient();
    try {
      final request = await client
          .postUrl(Uri.parse('http://127.0.0.1:$_port/ygg/proxy'))
          .timeout(const Duration(seconds: 3));
      request.headers.contentType = ContentType.json;
      if (_token != null) request.headers.set('X-Proxy-Token', _token!);
      request.write(jsonEncode({'target': yggRelayAddr, 'pubkey': remotePubkey}));
      final response = await request.close().timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final body = await response
            .transform(utf8.decoder)
            .join()
            .timeout(const Duration(seconds: 2));
        if (body.length > 4096) {
          throw FormatException('Yggdrasil /ygg/proxy response too large');
        }
        final data      = jsonDecode(body) as Map<String, dynamic>;
        final localPort = data['local_port'] as int?;
        if (localPort != null && localPort >= 1 && localPort <= 65535) {
          debugPrint('[Yggdrasil] Proxy $yggRelayAddr → 127.0.0.1:$localPort');
          return localPort;
        }
        return null;
      }
    } catch (e) {
      debugPrint('[Yggdrasil] proxyRemote failed (non-fatal): $e');
    } finally {
      client.close();
    }
    return null;
  }
}
