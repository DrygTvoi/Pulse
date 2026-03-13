import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

// ─── TorService — process lifecycle ───────────────────────────────────────────

/// Manages a system `tor` process used for bootstrap probing only.
///
/// Uses a non-default SOCKS port (9250) to avoid conflicting with any
/// existing system tor daemon on port 9050.
///
/// Lifecycle: start() → [probe via SOCKS5] → stop().
/// Not used for ongoing message traffic — only for finding reachable servers.
class TorService {
  static final instance = TorService._();
  TorService._();

  static const int socksPort = 9250;

  Process? _process;
  bool _bootstrapped = false;

  bool get isRunning      => _process != null;
  bool get isBootstrapped => _bootstrapped;

  /// Starts tor and waits for 100 % bootstrap (up to 90 s).
  /// Returns false if tor is not installed or times out.
  Future<bool> start() async {
    if (_bootstrapped) return true;

    final which = await Process.run('which', ['tor']);
    if (which.exitCode != 0) {
      debugPrint('[TorService] tor not found in PATH — skipping');
      return false;
    }

    final tmpDir = await getTemporaryDirectory();
    final dataDir = Directory('${tmpDir.path}/pulse_tor');
    await dataDir.create(recursive: true);

    try {
      _process = await Process.start('tor', [
        '--SocksPort',     '$socksPort',
        '--Log',           'notice stdout',
        '--DataDirectory', dataDir.path,
      ]);

      final completer = Completer<bool>();

      _process!.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        debugPrint('[Tor] $line');
        if (line.contains('Bootstrapped 100%') && !completer.isCompleted) {
          completer.complete(true);
        }
      });

      _process!.exitCode.then((_) {
        if (!completer.isCompleted) completer.complete(false);
      });

      _bootstrapped = await completer.future
          .timeout(const Duration(seconds: 90), onTimeout: () => false);

      if (!_bootstrapped) await stop();
      return _bootstrapped;
    } catch (e) {
      debugPrint('[TorService] start error: $e');
      return false;
    }
  }

  Future<void> stop() async {
    _process?.kill();
    await _process?.exitCode.catchError((_) => -1);
    _process = null;
    _bootstrapped = false;
    debugPrint('[TorService] stopped');
  }

  /// Test if [host]:[port] is reachable through the tor SOCKS5 proxy.
  /// Pure dart:io — no extra packages.
  Future<bool> probe(String host, int port) async {
    if (!_bootstrapped) return false;
    return _socks5TcpProbe('127.0.0.1', socksPort, host, port);
  }
}

// ─── SOCKS5 TCP probe (pure dart:io) ──────────────────────────────────────────

/// Opens a SOCKS5 CONNECT to [targetHost]:[targetPort] through a proxy and
/// immediately closes it.  Returns true if the connection succeeded.
/// Used only for reachability probing — sends no application data.
Future<bool> _socks5TcpProbe(
    String proxyHost, int proxyPort, String targetHost, int targetPort) async {
  Socket? sock;
  try {
    sock = await Socket.connect(proxyHost, proxyPort,
        timeout: const Duration(seconds: 8));
    sock.setOption(SocketOption.tcpNoDelay, true);

    // Collect incoming bytes with a stream
    final rxCtrl = StreamController<List<int>>();
    sock.listen(rxCtrl.add,
        onError: (_) => rxCtrl.close(), onDone: rxCtrl.close);

    Future<Uint8List?> readN(int n) async {
      final buf = <int>[];
      await for (final chunk in rxCtrl.stream) {
        buf.addAll(chunk);
        if (buf.length >= n) break;
      }
      if (buf.length < n) return null;
      return Uint8List.fromList(buf.sublist(0, n));
    }

    // 1. Greeting: version=5, 1 method, no-auth
    sock.add([0x05, 0x01, 0x00]);
    final greet = await readN(2)
        .timeout(const Duration(seconds: 8), onTimeout: () => null);
    if (greet == null || greet[1] != 0x00) return false;

    // 2. CONNECT request with domain name (ATYP=0x03)
    final hostBytes = utf8.encode(targetHost);
    sock.add([
      0x05, 0x01, 0x00, 0x03,
      hostBytes.length, ...hostBytes,
      (targetPort >> 8) & 0xFF, targetPort & 0xFF,
    ]);
    final resp = await readN(4)
        .timeout(const Duration(seconds: 15), onTimeout: () => null);
    return resp != null && resp[1] == 0x00;
  } catch (_) {
    return false;
  } finally {
    sock?.destroy();
  }
}

/// Routes a WebSocket connection through a SOCKS5 proxy (e.g. Tor).
///
/// Strategy — local TCP bridge:
///   1. Bind a loopback ServerSocket on a random port.
///   2. HttpClient connects to it (using connectionFactory).
///   3. Our bridge handler connects to the SOCKS5 proxy, does the
///      SOCKS5 handshake, then pipes data bidirectionally.
///   4. HttpClient performs TLS + WebSocket HTTP upgrade transparently
///      through the bridge (SNI hostname is preserved in TLS).
///
/// No new pub.dev packages required — pure dart:io.
Future<WebSocketChannel> connectWebSocket(String url,
    {String? torHost, int torPort = 9050}) async {
  if (torHost == null) {
    return WebSocketChannel.connect(Uri.parse(url));
  }

  final uri = Uri.parse(url);
  final targetHost = uri.host;
  final targetPort =
      uri.hasPort ? uri.port : (uri.scheme == 'wss' ? 443 : 80);

  // ── 1. Create local bridge server ──────────────────────────────────────────
  final server = await ServerSocket.bind(
      InternetAddress.loopbackIPv4, 0,
      shared: false);

  // ── 2. Register bridge handler (runs when HttpClient connects) ─────────────
  unawaited(server.first.then((client) async {
    unawaited(server.close()); // no more connections needed
    Socket? proxy;
    try {
      proxy = await Socket.connect(torHost, torPort,
          timeout: const Duration(seconds: 30));
      proxy.setOption(SocketOption.tcpNoDelay, true);

      // Buffer SOCKS5 response bytes + incoming client data during handshake.
      final rxBuf = <int>[];
      final waiters = <Completer<void>>[];
      final clientBuf = <List<int>>[];
      bool bridgeActive = false;

      // Forward proxy → client; buffer until bridge is active.
      proxy.listen(
        (data) {
          if (!bridgeActive) {
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

      // Forward client → proxy; buffer until bridge is active.
      client.listen(
        (data) {
          if (!bridgeActive) {
            clientBuf.add(data);
          } else {
            try { proxy!.add(data); } catch (_) {}
          }
        },
        onDone: () { try { proxy?.close(); } catch (_) {} },
        onError: (Object _) { client.destroy(); proxy?.destroy(); },
        cancelOnError: true,
      );

      // Sequential read helper for the SOCKS5 handshake.
      Future<Uint8List> readN(int n) async {
        while (rxBuf.length < n) {
          final c = Completer<void>();
          waiters.add(c);
          await c.future;
        }
        final result = Uint8List.fromList(rxBuf.take(n).toList());
        rxBuf.removeRange(0, n);
        return result;
      }

      // ── SOCKS5 greeting: version=5, 1 method, no-auth ──────────────────────
      proxy.add([0x05, 0x01, 0x00]);
      final greet = await readN(2).timeout(const Duration(seconds: 15));
      if (greet[0] != 0x05 || greet[1] != 0x00) {
        throw SocketException(
            'SOCKS5: proxy requires auth (method=0x${greet[1].toRadixString(16)}). '
            'Configure Tor with no authentication (default).');
      }

      // ── SOCKS5 CONNECT with domain name (ATYP=0x03) ────────────────────────
      final hostBytes = utf8.encode(targetHost);
      if (hostBytes.length > 255) throw ArgumentError('Hostname too long');
      proxy.add([
        0x05, 0x01, 0x00, 0x03,             // VER CMD RSV ATYP=DOMAIN
        hostBytes.length, ...hostBytes,      // domain
        (targetPort >> 8) & 0xFF, targetPort & 0xFF, // port
      ]);

      final hdr = await readN(4).timeout(const Duration(seconds: 30));
      if (hdr[1] != 0x00) {
        const repMsg = {
          0x01: 'general failure',        0x02: 'not allowed by ruleset',
          0x03: 'network unreachable',    0x04: 'host unreachable',
          0x05: 'connection refused',     0x06: 'TTL expired',
          0x07: 'command not supported',  0x08: 'address type not supported',
        };
        final desc = repMsg[hdr[1]] ??
            'unknown (0x${hdr[1].toRadixString(16)})';
        throw SocketException('SOCKS5 CONNECT to $targetHost:$targetPort failed: $desc');
      }
      // Drain bound-address from response.
      switch (hdr[3]) {
        case 0x01: await readN(4 + 2); break;               // IPv4 + port
        case 0x03:
          final len = (await readN(1))[0];
          await readN(len + 2); break;                       // domain + port
        case 0x04: await readN(16 + 2); break;              // IPv6 + port
      }

      // ── Bridge active: flush buffers ────────────────────────────────────────
      if (rxBuf.isNotEmpty) {
        try { client.add(rxBuf.toList()); } catch (_) {}
        rxBuf.clear();
      }
      bridgeActive = true;
      for (final d in clientBuf) {
        try { proxy.add(d); } catch (_) {}
      }
      clientBuf.clear();

      debugPrint('[Tor] Bridge active: $targetHost:$targetPort '
          'via $torHost:$torPort');
    } catch (e) {
      debugPrint('[Tor] Bridge error: $e');
      client.destroy();
      proxy?.destroy();
    }
  }).catchError((_) {}));

  // ── 3. HttpClient whose connectionFactory uses our local bridge ────────────
  //
  // WebSocket.connect(url) will call connectionFactory with the original URL
  // (e.g. https://relay.damus.io:443). This preserves TLS SNI hostname so
  // certificate verification works correctly even though TCP goes to loopback.
  final httpClient = HttpClient();
  final bridgePort = server.port;
  httpClient.connectionFactory = (uri2, proxyHost2, proxyPort2) async {
    final s = await Socket.connect(InternetAddress.loopbackIPv4, bridgePort,
        timeout: const Duration(seconds: 60));
    return ConnectionTask.fromSocket(
        Future.value(s), () => s.destroy());
  };

  // ── 4. Connect WebSocket; dart:io handles TLS + HTTP upgrade ──────────────
  final ws = await WebSocket.connect(url, customClient: httpClient);
  return IOWebSocketChannel(ws);
}
