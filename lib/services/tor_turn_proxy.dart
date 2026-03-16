import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'tor_service.dart';

// ── TorTurnProxy ───────────────────────────────────────────────────────────────
//
// Transparent TCP proxy: tunnels TURN-over-TCP through the running Tor SOCKS5.
// WebRTC ICE sees   turn:127.0.0.1:<localPort>?transport=tcp
// and the proxy forwards every connection via Tor to <remoteHost>:<remotePort>.
//
// Multiple instances run on different local ports for redundancy:
//   openrelay  :33478 → openrelay.metered.ca:3478   (community free tier)
//   freestun   :33479 → freestun.net:3479            (community free tier)
//
// If one TURN server is down or overloaded, ICE picks the other.
// Via Tor both servers are reachable regardless of GFW/Iran/Russia IP blocks.
//
// Lifecycle: TorService.startPersistent() calls TorTurnProxy.startAll() after
//            100 % bootstrap. TorTurnProxy.stopAll() on Tor shutdown.

class TorTurnProxy {
  // ── Preset instances ────────────────────────────────────────────────────────

  static final openrelay = TorTurnProxy._(
    localPort:  33478,
    remoteHost: 'openrelay.metered.ca',
    remotePort: 3478,
    username:   'openrelayproject',
    credential: 'openrelayproject',
  );

  static final freestun = TorTurnProxy._(
    localPort:  33479,
    remoteHost: 'freestun.net',
    remotePort: 3479,
    username:   'free',
    credential: 'free',
  );

  /// Backward-compatible singleton reference (primary proxy).
  static TorTurnProxy get instance => openrelay;

  /// All configured proxy instances.
  static final _all = [openrelay, freestun];

  // ── Aggregate helpers ───────────────────────────────────────────────────────

  /// Starts all proxies. Called by TorService after Tor bootstrap.
  static Future<void> startAll() async {
    for (final p in _all) { await p.start(); }
  }

  /// Stops all proxies. Called by TorService on shutdown.
  static Future<void> stopAll() async {
    for (final p in _all) { await p.stop(); }
  }

  /// ICE server entries from every currently-running proxy.
  /// Inserted into RTCPeerConnection iceServers so WebRTC uses whichever
  /// TURN server responds first.
  static List<Map<String, dynamic>> get allIceServerEntries =>
      _all.where((p) => p.isRunning).map((p) => p.iceServerEntry).toList();

  // ── Instance ────────────────────────────────────────────────────────────────

  final int    localPort;
  final String remoteHost;
  final int    remotePort;
  final String username;
  final String credential;

  ServerSocket? _server;
  bool get isRunning => _server != null;

  TorTurnProxy._({
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
    if (!TorService.instance.isBootstrapped) return false;

    try {
      _server = await ServerSocket.bind(
          InternetAddress.loopbackIPv4, localPort, shared: true);
      _server!.listen(
        _handleClient,
        onError: (_) {},
        onDone:  () { _server = null; },
      );
      debugPrint('[TorTurnProxy] :$localPort → $remoteHost:$remotePort via Tor');
      return true;
    } catch (e) {
      debugPrint('[TorTurnProxy] start :$localPort failed: $e');
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
      debugPrint('[TorTurnProxy] bridge error: $e');
      try { client.destroy(); } catch (_) {}
    });
  }

  Future<void> _bridge(Socket client) async {
    client.setOption(SocketOption.tcpNoDelay, true);

    final proxy = await Socket.connect(
      '127.0.0.1', TorService.socksPort,
      timeout: const Duration(seconds: 10),
    );
    proxy.setOption(SocketOption.tcpNoDelay, true);

    // Buffer-based bridge: accumulate proxy→client bytes during SOCKS5 handshake,
    // buffer client→proxy bytes, then switch to direct forwarding.
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

    // Sequential read helper used during the SOCKS5 handshake phase.
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
    final hostBytes = remoteHost.codeUnits;
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
