import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'bundled_binary_service.dart';

// ─── TorService — process lifecycle ───────────────────────────────────────────

/// Manages a `tor` process used for bootstrap probing only.
///
/// Binary resolution order:
///   1. Bundled binary extracted from assets (BundledBinaryService)
///   2. System `tor` found in PATH
///   3. Unavailable → start() returns false
///
/// If `snowflake-client` is available (bundled or system), tor is configured
/// with a Snowflake pluggable transport bridge so it works in censored regions
/// (China, Iran) where plain Tor is blocked.
///
/// Uses SOCKS port 9250 to avoid conflicting with any existing system tor
/// daemon on port 9050.
///
/// Lifecycle: start() → [probe via SOCKS5] → stop().
/// Not used for ongoing message traffic — only for relay/node discovery.
class TorService {
  static final instance = TorService._();
  TorService._();

  static const int socksPort = 9250;

  // Public Snowflake bridge from the Tor Project (updated rarely).
  // See: https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/snowflake
  static const _snowflakeBridge =
      'snowflake 192.0.2.3:1 2B280B23E1107BB62ABFC40DDCC8824814F80A72 '
      'fingerprint=2B280B23E1107BB62ABFC40DDCC8824814F80A72 '
      'url=https://snowflake.torproject.org/ '
      'front=cdn.sstatic.net '
      'ice=stun:stun.l.google.com:19302,stun:stun.voip.blackberry.com:3478,'
      'stun:stun.altar.com.pl:3478';

  Process? _process;
  bool _bootstrapped = false;
  bool _persistent = false;

  bool get isRunning      => _process != null;
  bool get isBootstrapped => _bootstrapped;
  bool get persistent     => _persistent;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Starts tor in persistent mode (not stopped after probing).
  /// Returns false if tor is unavailable or times out.
  Future<bool> startPersistent() async {
    _persistent = true;
    final ok = await start();
    if (!ok) _persistent = false;
    return ok;
  }

  /// Starts tor and waits for 100 % bootstrap (up to 90 s).
  /// Returns false if tor is unavailable or times out.
  Future<bool> start() async {
    if (_bootstrapped) return true;

    // 1. Find tor binary
    final torPath = await _findTor();
    if (torPath == null) {
      debugPrint('[TorService] tor not available (bundled or system)');
      return false;
    }

    // 2. Find snowflake-client (optional)
    final snowflakePath = await _findSnowflake();

    // 3. Prepare data directory and write torrc
    final tmpDir = await getTemporaryDirectory();
    final dataDir = Directory('${tmpDir.path}/pulse_tor');
    await dataDir.create(recursive: true);

    final torrcPath = await _writeTorrc(
      dataDir:       dataDir.path,
      snowflakePath: snowflakePath,
    );

    debugPrint('[TorService] Starting tor'
        '${snowflakePath != null ? " + Snowflake" : " (plain)"}');

    try {
      _process = await Process.start(torPath, ['-f', torrcPath]);

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

      _process!.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) => debugPrint('[Tor:err] $line'));

      _process!.exitCode.then((_) {
        if (!completer.isCompleted) completer.complete(false);
      });

      // Snowflake bootstrap is slower (WebRTC negotiation) — allow 120 s.
      final timeoutSec = snowflakePath != null ? 120 : 90;
      _bootstrapped = await completer.future.timeout(
        Duration(seconds: timeoutSec),
        onTimeout: () => false,
      );

      if (!_bootstrapped) await stop();
      return _bootstrapped;
    } catch (e) {
      debugPrint('[TorService] start error: $e');
      return false;
    }
  }

  Future<void> stop() async {
    _persistent = false;
    _process?.kill();
    await _process?.exitCode.catchError((_) => -1);
    _process = null;
    _bootstrapped = false;
    debugPrint('[TorService] stopped');
  }

  /// Test if [host]:[port] is reachable through the tor SOCKS5 proxy.
  Future<bool> probe(String host, int port) async {
    if (!_bootstrapped) return false;
    return _socks5TcpProbe('127.0.0.1', socksPort, host, port);
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Bundled binary first, then system PATH.
  Future<String?> _findTor() async {
    final bundled = await BundledBinaryService.extract('tor');
    if (bundled != null) {
      debugPrint('[TorService] Using bundled tor: $bundled');
      return bundled;
    }
    if (Platform.isWindows) return null; // no `which` on Windows
    final res = await Process.run('which', ['tor']);
    if (res.exitCode == 0) {
      final path = (res.stdout as String).trim();
      debugPrint('[TorService] Using system tor: $path');
      return path;
    }
    return null;
  }

  Future<String?> _findSnowflake() async {
    final bundled = await BundledBinaryService.extract('snowflake-client');
    if (bundled != null) {
      debugPrint('[TorService] Using bundled snowflake-client: $bundled');
      return bundled;
    }
    if (Platform.isWindows) return null;
    final res = await Process.run('which', ['snowflake-client']);
    if (res.exitCode == 0) {
      final path = (res.stdout as String).trim();
      debugPrint('[TorService] Using system snowflake-client: $path');
      return path;
    }
    return null;
  }

  Future<String> _writeTorrc({
    required String dataDir,
    String? snowflakePath,
  }) async {
    final buf = StringBuffer()
      ..writeln('SocksPort $socksPort')
      ..writeln('DataDirectory $dataDir')
      ..writeln('Log notice stdout');

    if (snowflakePath != null) {
      buf
        ..writeln('UseBridges 1')
        ..writeln('ClientTransportPlugin snowflake exec $snowflakePath')
        ..writeln('Bridge $_snowflakeBridge');
    }

    final torrcPath = '$dataDir/torrc';
    await File(torrcPath).writeAsString(buf.toString());
    return torrcPath;
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
