import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'psiphon_service.dart';

// ── PsiphonTurnProxy ─────────────────────────────────────────────────────────
//
// Transparent TCP proxy: tunnels TURN-over-TCP through the running Psiphon SOCKS5.
// WebRTC ICE sees   turn:127.0.0.1:<localPort>?transport=tcp
// and the proxy forwards every connection via Psiphon to <remoteHost>:<remotePort>.
//
// Multiple instances run on different local ports for redundancy:
//   openrelay  :43478 → openrelay.metered.ca:3478   (community free tier)
//   freestun   :43479 → freestun.net:3479            (community free tier)
//
// Ports 43478/43479 avoid conflict with Tor's 33478/33479.
// Psiphon bootstraps in 3-5s vs Tor's 60-120s, so these proxies become
// available much sooner on censored networks.

class PsiphonTurnProxy {
  // ── Preset instances ────────────────────────────────────────────────────────

  static final openrelay = PsiphonTurnProxy._(
    localPort:  43478,
    remoteHost: 'openrelay.metered.ca',
    remotePort: 3478,
    username:   'openrelayproject',
    credential: 'openrelayproject',
  );

  static final freestun = PsiphonTurnProxy._(
    localPort:  43479,
    remoteHost: 'freestun.net',
    remotePort: 3479,
    username:   'free',
    credential: 'free',
  );

  /// All configured proxy instances.
  static final _all = [openrelay, freestun];

  // ── Aggregate helpers ───────────────────────────────────────────────────────

  /// Starts all proxies. Called after Psiphon bootstrap.
  static Future<void> startAll() async {
    for (final p in _all) { await p.start(); }
  }

  /// Stops all proxies.
  static Future<void> stopAll() async {
    for (final p in _all) { await p.stop(); }
  }

  /// ICE server entries from every currently-running proxy.
  static List<Map<String, dynamic>> get allIceServerEntries =>
      _all.where((p) => p.isRunning).map((p) => p.iceServerEntry).toList();

  // ── Instance ──────────────────────────────────────────────────────────────

  final int    localPort;
  final String remoteHost;
  final int    remotePort;
  final String username;
  final String credential;

  ServerSocket? _server;
  bool get isRunning => _server != null;

  PsiphonTurnProxy._({
    required this.localPort,
    required this.remoteHost,
    required this.remotePort,
    required this.username,
    required this.credential,
  });

  /// ICE server entry for this proxy.
  Map<String, dynamic> get iceServerEntry => {
    'urls':       'turn:127.0.0.1:$localPort?transport=tcp',
    'username':   username,
    'credential': credential,
  };

  Future<bool> start() async {
    if (_server != null) return true;
    if (!PsiphonService.instance.isRunning) return false;

    try {
      _server = await ServerSocket.bind(
          InternetAddress.loopbackIPv4, localPort, shared: true);
      _server!.listen(
        _handleClient,
        onError: (_) {},
        onDone:  () { _server = null; },
      );
      debugPrint('[PsiphonTurnProxy] :$localPort → $remoteHost:$remotePort via Psiphon');
      return true;
    } catch (e) {
      debugPrint('[PsiphonTurnProxy] start :$localPort failed: $e');
      _server = null;
      return false;
    }
  }

  Future<void> stop() async {
    await _server?.close();
    _server = null;
  }

  void _handleClient(Socket client) {
    _bridge(client).catchError((Object e) {
      debugPrint('[PsiphonTurnProxy] bridge error: $e');
      try { client.destroy(); } catch (_) {}
    });
  }

  Future<void> _bridge(Socket client) async {
    final proxyPort = PsiphonService.instance.proxyPort;
    if (proxyPort == null) {
      client.destroy();
      return;
    }

    client.setOption(SocketOption.tcpNoDelay, true);

    final proxy = await Socket.connect(
      '127.0.0.1', proxyPort,
      timeout: const Duration(seconds: 10),
    );
    proxy.setOption(SocketOption.tcpNoDelay, true);

    final rxBuf     = <int>[];
    final clientBuf = <List<int>>[];
    final waiters   = <Completer<void>>[];
    bool  active    = false;

    proxy.listen(
      (data) {
        if (!active) {
          rxBuf.addAll(data);
          for (final w in [...waiters]) {
            if (!w.isCompleted) w.complete();
          }
          waiters.removeWhere((c) => c.isCompleted);
        } else {
          try { client.add(data); } catch (_) {}
        }
      },
      onDone:  () { try { client.close();   } catch (_) {} },
      onError: (Object _) { client.destroy(); proxy.destroy(); },
      cancelOnError: true,
    );

    client.listen(
      (data) {
        if (!active) {
          clientBuf.add(data);
        } else {
          try { proxy.add(data); } catch (_) {}
        }
      },
      onDone:  () { try { proxy.close(); } catch (_) {} },
      onError: (Object _) { client.destroy(); proxy.destroy(); },
      cancelOnError: true,
    );

    Future<List<int>> readN(int n) async {
      while (rxBuf.length < n) {
        final c = Completer<void>();
        waiters.add(c);
        await c.future;
      }
      final result = rxBuf.sublist(0, n);
      rxBuf.removeRange(0, n);
      return result;
    }

    // ── SOCKS5 handshake ──────────────────────────────────────────────────────
    // 1. Greeting: VER=5, 1 method, NO_AUTH
    proxy.add([0x05, 0x01, 0x00]);
    final greet = await readN(2).timeout(const Duration(seconds: 15));
    if (greet[0] != 0x05 || greet[1] != 0x00) {
      throw SocketException('SOCKS5: unexpected greeting ${greet[1]}');
    }

    // 2. CONNECT request using domain name
    // F3: Use utf8.encode, not codeUnits — SOCKS5 requires byte encoding.
    final hostBytes = utf8.encode(remoteHost);
    if (hostBytes.length > 255) throw SocketException('SOCKS5: hostname too long');
    proxy.add([
      0x05, 0x01, 0x00, 0x03,
      hostBytes.length, ...hostBytes,
      (remotePort >> 8) & 0xFF,
      remotePort & 0xFF,
    ]);

    // 3. Response: VER + REP + RSV + ATYP + BND.ADDR + BND.PORT
    final hdr = await readN(4).timeout(const Duration(seconds: 15));
    if (hdr[1] != 0x00) {
      throw SocketException('SOCKS5 CONNECT rejected: REP=0x${hdr[1].toRadixString(16)}');
    }
    // Consume bound address + port (size depends on ATYP)
    final int addrLen;
    if (hdr[3] == 0x01) {
      addrLen = 4;   // IPv4
    } else if (hdr[3] == 0x04) {
      addrLen = 16;  // IPv6
    } else {
      // Domain: next byte is length
      final lb = await readN(1);
      addrLen = lb[0];
    }
    await readN(addrLen + 2); // addr bytes + 2-byte port

    // ── Activate bridge ───────────────────────────────────────────────────────
    active = true;
    for (final chunk in clientBuf) {
      try { proxy.add(chunk); } catch (_) {}
    }
    clientBuf.clear();
    if (rxBuf.isNotEmpty) {
      try { client.add(rxBuf.toList()); } catch (_) {}
      rxBuf.clear();
    }
  }
}
