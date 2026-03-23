import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bundled_binary_service.dart';
import 'bridge_fetch_service.dart';
import 'tor_turn_proxy.dart';

// ─── TorService — process lifecycle ───────────────────────────────────────────
//
// PT selection strategy (in order of preference):
//   1. obfs4     — fastest bootstrap (~15-30 s), TCP-based, requires obfs4proxy
//   2. WebTunnel — HTTPS/WS behind CDN (~30-60 s), same binary as obfs4proxy
//   3. Snowflake — WebRTC-based, works when TCP is blocked, ~30-60 s bootstrap
//   4. Plain Tor — direct, works where Tor is not blocked (~30-60 s bootstrap)
//
// Bridge lines are fetched dynamically from bridges.torproject.org via CF IP
// (BridgeFetchService) and cached 24 h; embedded lists are the fallback.
//
// Uses SOCKS port 9250 to avoid conflicting with system tor on 9050.

enum _PtMode { obfs4, webTunnel, snowflake, plain }

class TorService {
  static TorService instance = TorService._();
  TorService._();

  /// Protected constructor for test subclasses.
  @visibleForTesting
  TorService.forTesting();

  /// Replace the singleton for testing.
  @visibleForTesting
  static void setInstanceForTesting(TorService inst) => instance = inst;

  static const int socksPort = 9250;

  Process? _process;
  StreamSubscription<String>? _stdoutSub;
  StreamSubscription<String>? _stderrSub;
  bool _bootstrapped = false;
  bool _persistent = false;
  bool _starting = false;
  int _bootstrapPercent = 0;
  _PtMode? _activeMode;

  final _stateCtrl = StreamController<void>.broadcast();

  bool get isRunning        => _process != null;
  bool get isBootstrapped   => _bootstrapped;
  bool get persistent       => _persistent;
  int  get bootstrapPercent => _bootstrapPercent;
  String get activePtLabel  => switch (_activeMode) {
    _PtMode.obfs4      => 'obfs4',
    _PtMode.webTunnel  => 'webtunnel',
    _PtMode.snowflake  => 'snowflake',
    _PtMode.plain      => 'plain',
    null               => '',
  };

  /// Fires whenever bootstrap progress or running state changes.
  Stream<void> get stateChanges => _stateCtrl.stream;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Starts tor in persistent mode (not stopped after probing).
  Future<bool> startPersistent() async {
    _persistent = true;
    final ok = await start();
    if (!ok) _persistent = false;
    return ok;
  }

  /// Starts tor with the best available PT.
  /// PT chain: obfs4 (if binary) → Snowflake (if binary) → plain Tor.
  /// Returns false if tor is unavailable or all strategies time out.
  Future<bool> start() async {
    if (Platform.isIOS) { debugPrint('[TorService] Not available on iOS'); return false; }
    if (_bootstrapped) return true;
    if (_starting) return false; // prevent concurrent start()
    _starting = true;

    // Adopt an existing routing SOCKS5 on our port (e.g. previous session).
    if (await _isSocks5Listening(socksPort)) {
      final routing = await _socks5TcpProbe(
              '127.0.0.1', socksPort, '1.1.1.1', 80)
          .timeout(const Duration(seconds: 3), onTimeout: () => false);
      if (routing) {
        debugPrint('[TorService] Existing SOCKS5 on :$socksPort — adopting');
        _bootstrapped = true;
        _bootstrapPercent = 100;
        _starting = false;
        _stateCtrl.add(null);
        return true;
      }
      debugPrint('[TorService] Zombie SOCKS5 on :$socksPort — killing');
      await _killZombieOnPort(socksPort);
      await Future.delayed(const Duration(milliseconds: 800));
      if (await _isSocks5Listening(socksPort)) return false;
    }

    final torPath = await _findTor();
    if (torPath == null) {
      debugPrint('[TorService] tor binary not found');
      return false;
    }

    final tmpDir  = await getTemporaryDirectory();
    final dataDir = Directory('${tmpDir.path}/pulse_tor');
    await dataDir.create(recursive: true);

    // Prefetch dynamic bridges in background (cache miss is OK — will use embedded)
    unawaited(BridgeFetchService.instance.getSnowflakeBridges());
    unawaited(BridgeFetchService.instance.getWebTunnelBridges());

    // User preference: auto = full chain, or force a specific PT
    final prefs = await SharedPreferences.getInstance();
    final pref = prefs.getString('preferred_pt') ?? 'auto';
    final timeoutSec = prefs.getInt('tor_timeout_sec') ?? 60;

    // ── PT chain ───────────────────────────────────────────────────────────
    final obfs4Path = await _findObfs4Proxy();
    final sfPath    = await _findSnowflake();

    // 1. obfs4 (fast, TCP-based, ~15-30 s bootstrap)
    if ((pref == 'auto' || pref == 'obfs4') && obfs4Path != null) {
      final bridges = await BridgeFetchService.instance.getObfs4Bridges();
      if (bridges.isNotEmpty) {
        debugPrint('[TorService] Trying obfs4...');
        final ok = await _launchTor(torPath, dataDir.path,
            mode: _PtMode.obfs4, ptPath: obfs4Path, bridges: bridges,
            timeoutSec: timeoutSec);
        if (ok) return true;
        debugPrint('[TorService] obfs4 failed — trying WebTunnel');
      }
    }

    // 2. WebTunnel (HTTPS/WS behind CDN, GFW-resistant, same binary as obfs4)
    if ((pref == 'auto' || pref == 'webtunnel') && obfs4Path != null) {
      final wtBridges = await BridgeFetchService.instance.getWebTunnelBridges();
      if (wtBridges.isNotEmpty) {
        debugPrint('[TorService] Trying WebTunnel...');
        final ok = await _launchTor(torPath, dataDir.path,
            mode: _PtMode.webTunnel, ptPath: obfs4Path, bridges: wtBridges,
            timeoutSec: timeoutSec);
        if (ok) return true;
        debugPrint('[TorService] WebTunnel failed — trying Snowflake');
      }
    }

    // 3. Snowflake (WebRTC-based, works when TCP is blocked, ~60-120 s)
    if ((pref == 'auto' || pref == 'snowflake') && sfPath != null) {
      final bridges = await BridgeFetchService.instance.getSnowflakeBridges();
      debugPrint('[TorService] Trying Snowflake...');
      final ok = await _launchTor(torPath, dataDir.path,
          mode: _PtMode.snowflake, ptPath: sfPath, bridges: bridges,
          timeoutSec: timeoutSec);
      if (ok) return true;
      debugPrint('[TorService] Snowflake failed — trying plain Tor');
    }

    // 4. Plain Tor (works in regions where Tor is not blocked)
    if (pref == 'auto' || pref == 'plain') {
      debugPrint('[TorService] Trying plain Tor...');
      final plainOk = await _launchTor(torPath, dataDir.path,
          mode: _PtMode.plain, timeoutSec: timeoutSec);
      if (plainOk) return true;
    }

    // All PTs failed — kill any lingering process to avoid zombies
    _process?.kill();
    await _process?.exitCode.catchError((_) => -1);
    _process = null;
    _bootstrapPercent = 0;
    _starting = false;
    _stateCtrl.add(null);
    return false;
  }

  Future<void> stop() async {
    _persistent = false;
    unawaited(TorTurnProxy.stopAll());
    _stdoutSub?.cancel();
    _stderrSub?.cancel();
    _stdoutSub = null;
    _stderrSub = null;
    _process?.kill();
    await _process?.exitCode.catchError((_) => -1);
    _process = null;
    _bootstrapped = false;
    _bootstrapPercent = 0;
    _activeMode = null;
    _stateCtrl.add(null);
    // Clean up torrc files to avoid leaking bridge fingerprints
    try {
      final tmpDir = await getTemporaryDirectory();
      final dataDir = Directory('${tmpDir.path}/pulse_tor');
      if (await dataDir.exists()) {
        // Delete only torrc files, keep cached state
        await for (final entity in dataDir.list()) {
          if (entity is File && entity.path.contains('torrc_')) {
            await entity.delete();
          }
        }
      }
    } catch (_) {}
    debugPrint('[TorService] stopped');
  }

  /// Test if [host]:[port] is reachable through the tor SOCKS5 proxy.
  Future<bool> probe(String host, int port) async {
    if (!_bootstrapped) return false;
    return _socks5TcpProbe('127.0.0.1', socksPort, host, port);
  }

  /// Fetches a URL via Tor SOCKS5. Returns null if not bootstrapped or on error.
  Future<String?> fetchUrl(String url, {int timeoutSec = 20}) async {
    if (!_bootstrapped) return null;
    return fetchUrlViaSocks5(url,
        proxyHost: '127.0.0.1', proxyPort: socksPort, timeoutSec: timeoutSec);
  }

  // ── Core launch ────────────────────────────────────────────────────────────

  Future<bool> _launchTor(
    String torPath,
    String dataDir, {
    required _PtMode mode,
    String? ptPath,
    List<String> bridges = const [],
    required int timeoutSec,
  }) async {
    // Kill any previous process before retrying with a new PT
    if (_process != null) {
      _process!.kill();
      await _process!.exitCode.catchError((_) => -1);
      _process = null;
      _bootstrapped = false;
      _bootstrapPercent = 0;
    }

    final torrcPath = await _writeTorrc(
      dataDir: dataDir,
      mode: mode,
      ptPath: ptPath,
      bridges: bridges,
    );

    try {
      _process = await Process.start(torPath, ['-f', torrcPath]);
      final completer = Completer<bool>();

      _stdoutSub?.cancel();
      _stdoutSub = _process!.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        debugPrint('[Tor/$mode] $line');
        final pct = RegExp(r'Bootstrapped (\d+)%').firstMatch(line);
        if (pct != null) {
          _bootstrapPercent = int.parse(pct.group(1)!);
          _stateCtrl.add(null);
        }
        if (line.contains('Bootstrapped 100%') && !completer.isCompleted) {
          _bootstrapped = true;
          completer.complete(true);
        }
      });

      _stderrSub?.cancel();
      _stderrSub = _process!.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) => debugPrint('[Tor/$mode:err] $line'));

      _process!.exitCode.then((_) {
        if (!completer.isCompleted) completer.complete(false);
      });

      _bootstrapped = await completer.future
          .timeout(Duration(seconds: timeoutSec), onTimeout: () => false);

      if (_bootstrapped) {
        _activeMode = mode;
        _starting = false;
        debugPrint('[TorService] Bootstrapped via $mode');
        unawaited(TorTurnProxy.startAll());
        return true;
      }
      // This PT failed — don't stop process here; let caller try next PT
      return false;
    } catch (e) {
      debugPrint('[TorService] launch error ($mode): $e');
      return false;
    }
  }

  // ── torrc writer ───────────────────────────────────────────────────────────

  Future<String> _writeTorrc({
    required String dataDir,
    required _PtMode mode,
    String? ptPath,
    List<String> bridges = const [],
  }) async {
    final buf = StringBuffer()
      ..writeln('SocksPort $socksPort')
      ..writeln('DataDirectory $dataDir')
      ..writeln('Log notice stdout')
      // Faster circuit building
      ..writeln('LearnCircuitBuildTimeout 1')
      ..writeln('CircuitBuildTimeout 60');

    switch (mode) {
      case _PtMode.obfs4:
        buf
          ..writeln('UseBridges 1')
          ..writeln('ClientTransportPlugin obfs4 exec $ptPath');
        for (final b in bridges) {
          buf.writeln('Bridge $b');
        }
      case _PtMode.webTunnel:
        // WebTunnel wraps Tor traffic as a WebSocket upgrade inside HTTPS.
        // Indistinguishable from normal HTTPS traffic; works behind CDNs.
        // Uses the same lyrebird/obfs4proxy binary — it ships webtunnel support.
        buf
          ..writeln('UseBridges 1')
          ..writeln('ClientTransportPlugin webtunnel exec $ptPath');
        for (final b in bridges) {
          buf.writeln('Bridge $b');
        }
      case _PtMode.snowflake:
        // Diverse STUN servers for Snowflake ICE — accessible from most regions.
        // Snowflake tries them in order; one responsive server is enough.
        // Google STUN blocked in mainland China → non-Google servers listed first.
        const sfStun = 'stun:stun.cloudflare.com:3478,'
            'stun:global.stun.twilio.com:3478,'
            'stun:stun.relay.metered.ca:80,'
            'stun:stun.nextcloud.com:3478,'
            'stun:stun.nextcloud.com:443,'
            'stun:stun.bethesda.net:3478,'
            'stun:stun.mixvoip.com:3478,'
            'stun:stun.voipgate.com:3478,'
            'stun:stun.epygi.com:3478,'
            'stun:stun.stunprotocol.org:3478,'
            'stun:stun.services.mozilla.com:3478,'
            'stun:74.125.250.129:19302';
        buf
          ..writeln('UseBridges 1')
          ..writeln('ClientTransportPlugin snowflake exec $ptPath '
              '-max 1 -ice $sfStun');
        for (final b in bridges) {
          buf.writeln('Bridge $b');
        }
      case _PtMode.plain:
        break; // no bridges
    }

    final torrcPath = '$dataDir/torrc_${mode.name}';
    await File(torrcPath).writeAsString(buf.toString());
    return torrcPath;
  }

  // ── Binary finders ─────────────────────────────────────────────────────────

  Future<String?> _findTor() async {
    final bundled = await BundledBinaryService.extract('tor');
    if (bundled != null) return bundled;
    if (Platform.isWindows) return null;
    final res = await Process.run('which', ['tor']);
    if (res.exitCode == 0) return (res.stdout as String).trim();
    return null;
  }

  Future<String?> _findSnowflake() async {
    final bundled = await BundledBinaryService.extract('snowflake-client');
    if (bundled != null) return bundled;
    if (Platform.isWindows) return null;
    final res = await Process.run('which', ['snowflake-client']);
    if (res.exitCode == 0) return (res.stdout as String).trim();
    return null;
  }

  /// Looks for obfs4proxy (or the newer lyrebird binary) bundled or in PATH.
  Future<String?> _findObfs4Proxy() async {
    // Try 'obfs4proxy' name first, then 'lyrebird' (newer upstream name)
    for (final name in ['obfs4proxy', 'lyrebird']) {
      final bundled = await BundledBinaryService.extract(name);
      if (bundled != null) {
        debugPrint('[TorService] Using bundled $name: $bundled');
        return bundled;
      }
      if (!Platform.isWindows) {
        final res = await Process.run('which', [name]);
        if (res.exitCode == 0) {
          final path = (res.stdout as String).trim();
          debugPrint('[TorService] Using system $name: $path');
          return path;
        }
      }
    }
    return null;
  }

  // ── SOCKS5 helpers ─────────────────────────────────────────────────────────

  Future<void> _killZombieOnPort(int port) async {
    if (Platform.isWindows) return;
    try {
      final r = await Process.run('fuser', ['-k', '$port/tcp']);
      if (r.exitCode == 0) return;
    } catch (_) {}
    try {
      final r = await Process.run('lsof', ['-ti', 'tcp:$port']);
      final pids = (r.stdout as String).trim().split('\n')
          .where((s) => s.isNotEmpty).toList();
      for (final pid in pids) {
        await Process.run('kill', [pid.trim()]);
      }
    } catch (_) {}
  }

  Future<bool> _isSocks5Listening(int port) async {
    Socket? s;
    try {
      s = await Socket.connect(InternetAddress.loopbackIPv4, port,
          timeout: const Duration(milliseconds: 600));
      s.setOption(SocketOption.tcpNoDelay, true);
      s.add([0x05, 0x01, 0x00]);
      final buf = <int>[];
      await s.listen((data) => buf.addAll(data)).asFuture<void>()
          .timeout(const Duration(milliseconds: 600), onTimeout: () {});
      return buf.length >= 2 && buf[0] == 0x05;
    } catch (_) {
      return false;
    } finally {
      s?.destroy();
    }
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
    {String? torHost, int torPort = 9050,
    Duration socks5Timeout = const Duration(seconds: 25)}) async {
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
          timeout: socks5Timeout);
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
          await c.future.timeout(const Duration(seconds: 15));
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

      final hdr = await readN(4).timeout(socks5Timeout);
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
  // Normalize port: Dart doesn't know the default port for 'wss' scheme,
  // so `wss://host` without port → port 0 → wrong Host header → 101 rejected.
  final wsUri = Uri.parse(url);
  final normalizedUrl = (!wsUri.hasPort || wsUri.port == 0)
      ? '${wsUri.scheme}://${wsUri.host}:${wsUri.scheme == 'wss' ? 443 : 80}${wsUri.path}'
      : url;
  try {
    final ws = await WebSocket.connect(normalizedUrl, customClient: httpClient);
    return IOWebSocketChannel(ws);
  } catch (e) {
    // If WebSocket.connect fails, no client ever connects to the bridge
    // ServerSocket → server.first never completes → ServerSocket leaks.
    try { await server.close(); } catch (_) {}
    rethrow;
  }
}

/// Fetches a URL via a SOCKS5 proxy using the same local-bridge technique as
/// [connectWebSocket]. Supports both http and https targets (HttpClient handles
/// TLS through the tunnel). Returns the response body as a String, or null.
Future<String?> fetchUrlViaSocks5(String url,
    {String proxyHost = '127.0.0.1',
     int proxyPort = TorService.socksPort,
     int timeoutSec = 20}) async {
  final uri = Uri.parse(url);
  final targetHost = uri.host;
  final targetPort = (uri.hasPort && uri.port != 0)
      ? uri.port
      : (uri.scheme == 'https' ? 443 : 80);

  // ── 1. Local bridge server ─────────────────────────────────────────────────
  final server = await ServerSocket.bind(
      InternetAddress.loopbackIPv4, 0, shared: false);
  final bridgePort = server.port;

  // ── 2. Bridge handler ──────────────────────────────────────────────────────
  unawaited(server.first.then((client) async {
    unawaited(server.close());
    Socket? proxy;
    try {
      proxy = await Socket.connect(proxyHost, proxyPort,
          timeout: Duration(seconds: timeoutSec));
      proxy.setOption(SocketOption.tcpNoDelay, true);

      final rxBuf   = <int>[];
      final waiters = <Completer<void>>[];
      final clientBuf = <List<int>>[];
      bool bridgeActive = false;

      proxy.listen(
        (data) {
          if (!bridgeActive) {
            rxBuf.addAll(data);
            for (final w in [...waiters]) { if (!w.isCompleted) w.complete(); }
            waiters.removeWhere((c) => c.isCompleted);
          } else {
            try { client.add(data); } catch (_) {}
          }
        },
        onDone:  () { try { client.close(); } catch (_) {} },
        onError: (Object _) { client.destroy(); proxy?.destroy(); },
        cancelOnError: true,
      );
      client.listen(
        (data) {
          if (!bridgeActive) { clientBuf.add(data); }
          else { try { proxy!.add(data); } catch (_) {} }
        },
        onDone:  () { try { proxy?.close(); } catch (_) {} },
        onError: (Object _) { client.destroy(); proxy?.destroy(); },
        cancelOnError: true,
      );

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

      // SOCKS5 greeting
      proxy.add([0x05, 0x01, 0x00]);
      final greet = await readN(2).timeout(const Duration(seconds: 10));
      if (greet[0] != 0x05 || greet[1] != 0x00) {
        throw SocketException('SOCKS5: proxy requires auth');
      }

      // SOCKS5 CONNECT
      final hostBytes = utf8.encode(targetHost);
      if (hostBytes.length > 255) throw ArgumentError('Hostname too long');
      proxy.add([
        0x05, 0x01, 0x00, 0x03,
        hostBytes.length, ...hostBytes,
        (targetPort >> 8) & 0xFF, targetPort & 0xFF,
      ]);
      final hdr = await readN(4).timeout(Duration(seconds: timeoutSec));
      if (hdr[1] != 0x00) {
        throw SocketException(
            'SOCKS5 CONNECT to $targetHost:$targetPort failed (${hdr[1]})');
      }
      switch (hdr[3]) {
        case 0x01: await readN(4 + 2); break;
        case 0x03:
          final len = (await readN(1))[0];
          await readN(len + 2); break;
        case 0x04: await readN(16 + 2); break;
      }

      // Flush and activate bridge
      if (rxBuf.isNotEmpty) {
        try { client.add(rxBuf.toList()); } catch (_) {}
        rxBuf.clear();
      }
      bridgeActive = true;
      for (final d in clientBuf) { try { proxy.add(d); } catch (_) {} }
      clientBuf.clear();
      debugPrint('[Tor] HTTP bridge active: $targetHost:$targetPort');
    } catch (e) {
      debugPrint('[Tor] HTTP bridge error: $e');
      client.destroy();
      proxy?.destroy();
    }
  }).catchError((_) {}));

  // ── 3. HttpClient via the bridge (handles TLS transparently) ──────────────
  final httpClient = HttpClient();
  httpClient.connectionFactory = (_, _, _) async {
    final s = await Socket.connect(InternetAddress.loopbackIPv4, bridgePort,
        timeout: const Duration(seconds: 30));
    return ConnectionTask.fromSocket(Future.value(s), () => s.destroy());
  };

  try {
    final req = await httpClient
        .getUrl(uri)
        .timeout(Duration(seconds: timeoutSec));
    req.headers.set('Accept', 'application/json');
    final resp = await req.close().timeout(Duration(seconds: timeoutSec));
    if (resp.statusCode != 200) { httpClient.close(force: true); return null; }
    final body = await utf8.decoder
        .bind(resp)
        .join()
        .timeout(Duration(seconds: timeoutSec));
    httpClient.close(force: true);
    return body;
  } catch (e) {
    debugPrint('[TorService] fetchUrl failed: $e');
    httpClient.close(force: true);
    return null;
  }
}

/// Performs an HTTP(S) POST via Tor SOCKS5 without the local-bridge pattern.
///
/// Unlike [buildTorHttpClient] (which pipes through a local TCP bridge),
/// this function connects directly to the Tor SOCKS5 proxy, does the
/// SOCKS5 handshake, upgrades to TLS (for https), and performs a raw
/// HTTP/1.1 POST — all on the same socket.
///
/// Designed for Oxen/Session snodes that use self-signed certificates.
/// Returns the response body as a String, or null on failure.
Future<String?> postUrlViaSocks5({
  required String url,
  required String body,
  Map<String, String> headers = const {},
  String proxyHost = '127.0.0.1',
  int proxyPort = TorService.socksPort,
  int timeoutSec = 25,
}) async {
  final uri = Uri.parse(url);
  final targetHost = uri.host;
  final targetPort = (uri.hasPort && uri.port != 0)
      ? uri.port
      : (uri.scheme == 'https' ? 443 : 80);
  final isHttps = uri.scheme == 'https';

  Socket? rawSock;
  try {
    // ── 1. Connect to SOCKS5 proxy ─────────────────────────────────────────
    rawSock = await Socket.connect(proxyHost, proxyPort,
        timeout: Duration(seconds: timeoutSec));
    rawSock.setOption(SocketOption.tcpNoDelay, true);

    // ── 2. SOCKS5 handshake ────────────────────────────────────────────────
    // Use completer-based buffered reader on a single subscription.
    final rxBuf = <int>[];
    final waiters = <Completer<void>>[];
    bool socks5Done = false;

    final sub = rawSock.listen(
      (data) {
        if (!socks5Done) {
          rxBuf.addAll(data);
          for (final w in [...waiters]) {
            if (!w.isCompleted) w.complete();
          }
          waiters.removeWhere((c) => c.isCompleted);
        }
      },
      onError: (Object e) {
        for (final w in waiters) {
          if (!w.isCompleted) w.completeError(e);
        }
      },
      onDone: () {
        for (final w in waiters) {
          if (!w.isCompleted) {
            w.completeError(SocketException('Socket closed during SOCKS5'));
          }
        }
      },
    );

    Future<Uint8List> readN(int n) async {
      while (rxBuf.length < n) {
        final c = Completer<void>();
        waiters.add(c);
        await c.future.timeout(Duration(seconds: timeoutSec));
      }
      final r = Uint8List.fromList(rxBuf.sublist(0, n));
      rxBuf.removeRange(0, n);
      return r;
    }

    // Greeting: version=5, 1 method, no-auth
    rawSock.add([0x05, 0x01, 0x00]);
    final greet = await readN(2);
    if (greet[0] != 0x05 || greet[1] != 0x00) {
      throw SocketException('SOCKS5 auth negotiation failed');
    }

    // CONNECT
    final hostBytes = utf8.encode(targetHost);
    rawSock.add([
      0x05, 0x01, 0x00, 0x03,
      hostBytes.length, ...hostBytes,
      (targetPort >> 8) & 0xFF, targetPort & 0xFF,
    ]);
    final hdr = await readN(4);
    if (hdr[1] != 0x00) {
      throw SocketException(
          'SOCKS5 CONNECT to $targetHost:$targetPort failed (rep=${hdr[1]})');
    }
    // Drain bound-address
    switch (hdr[3]) {
      case 0x01: await readN(6); break;
      case 0x03:
        final len = (await readN(1))[0];
        await readN(len + 2); break;
      case 0x04: await readN(18); break;
    }

    socks5Done = true;

    // ── 3. Cancel stream subscription so SecureSocket can take over ───────
    await sub.cancel();

    // ── 4. TLS upgrade ──────────────────────────────────────────────────────
    Socket dataSock = rawSock;
    if (isHttps) {
      dataSock = await SecureSocket.secure(rawSock,
              host: targetHost, onBadCertificate: (_) => true)
          .timeout(Duration(seconds: timeoutSec));
    }

    // ── 5. Send raw HTTP/1.1 POST ───────────────────────────────────────────
    final bodyBytes = utf8.encode(body);
    final path = uri.path.isEmpty ? '/' : uri.path;
    final hostHeader = (targetPort == 443 || targetPort == 80)
        ? targetHost
        : '$targetHost:$targetPort';

    final reqBuf = StringBuffer()
      ..write('POST $path HTTP/1.1\r\n')
      ..write('Host: $hostHeader\r\n')
      ..write('Content-Length: ${bodyBytes.length}\r\n')
      ..write('Connection: close\r\n');
    for (final e in headers.entries) {
      reqBuf.write('${e.key}: ${e.value}\r\n');
    }
    reqBuf.write('\r\n');

    dataSock.add(utf8.encode(reqBuf.toString()));
    dataSock.add(bodyBytes);
    await dataSock.flush();

    // ── 6. Read response (Connection: close → read until stream ends) ──────
    final respBytes = <int>[];
    await dataSock
        .listen((data) => respBytes.addAll(data))
        .asFuture<void>()
        .timeout(Duration(seconds: timeoutSec));

    dataSock.destroy();

    // ── 7. Parse HTTP response ─────────────────────────────────────────────
    final resp = utf8.decode(respBytes, allowMalformed: true);
    final hdrEnd = resp.indexOf('\r\n\r\n');
    if (hdrEnd < 0) return null;

    final statusLine = resp.substring(0, resp.indexOf('\r\n'));
    final parts = statusLine.split(' ');
    if (parts.length < 2) return null;
    final statusCode = int.tryParse(parts[1]) ?? 0;
    if (statusCode != 200) {
      debugPrint('[TorService] postUrl $targetHost got $statusCode');
      return null;
    }
    return resp.substring(hdrEnd + 4);
  } catch (e) {
    debugPrint('[TorService] postUrl failed ($targetHost:$targetPort): $e');
    rawSock?.destroy();
    return null;
  }
}

// ─── Tor-proxied HTTP client ───────────────────────────────────────────────────

/// Returns an [IOClient] whose TCP connections are tunneled through the local
/// Tor SOCKS5 proxy on port [TorService.socksPort].
///
/// If [acceptBadCertificate] is true, TLS verification is skipped — needed
/// for Oxen/Session snodes that use self-signed certificates.
///
/// Returns null if Tor is not bootstrapped.
IOClient? buildTorHttpClient({bool acceptBadCertificate = false}) {
  if (!TorService.instance.isBootstrapped) return null;
  final inner = HttpClient();
  if (acceptBadCertificate) {
    inner.badCertificateCallback = (cert, host, port) => true;
  }
  inner.connectionFactory = (uri, proxyHost, proxyPort) async {
    final host = uri.host;
    final port = (uri.hasPort && uri.port != 0)
        ? uri.port
        : (uri.scheme == 'https' ? 443 : 80);
    final server =
        await ServerSocket.bind(InternetAddress.loopbackIPv4, 0, shared: false);
    final localPort = server.port;

    // Signal: bridge completes this when SOCKS5 is done and pipe is active.
    // connectionFactory WAITS for it before handing the socket to HttpClient,
    // so HttpClient never sends TLS data into an unready bridge.
    final ready = Completer<bool>();
    unawaited(_runHttpSocks5Bridge(server, host, port, ready));

    final s = await Socket.connect(InternetAddress.loopbackIPv4, localPort,
        timeout: const Duration(seconds: 60));

    final ok = await ready.future
        .timeout(const Duration(seconds: 45), onTimeout: () => false);
    if (!ok) {
      s.destroy();
      throw SocketException(
          'Tor SOCKS5 bridge to $host:$port failed or timed out');
    }
    return ConnectionTask.fromSocket(Future.value(s), () => s.destroy());
  };
  return IOClient(inner);
}

/// Internal bridge: accepts one local connection then tunnels it to
/// [targetHost]:[targetPort] via Tor SOCKS5.
///
/// [ready] is completed with `true` when the SOCKS5 handshake succeeds and the
/// bidirectional pipe is active, or `false` on any error.
Future<void> _runHttpSocks5Bridge(
    ServerSocket server, String targetHost, int targetPort,
    Completer<bool> ready) async {
  Socket? client;
  Socket? proxy;
  try {
    client = await server.first;
    unawaited(server.close());

    proxy = await Socket.connect(
        InternetAddress.loopbackIPv4, TorService.socksPort,
        timeout: const Duration(seconds: 30));
    proxy.setOption(SocketOption.tcpNoDelay, true);

    final rxBuf = <int>[];
    final waiters = <Completer<void>>[];
    bool active = false;

    proxy.listen(
      (data) {
        if (!active) {
          rxBuf.addAll(data);
          for (final w in [...waiters]) {
            if (!w.isCompleted) w.complete();
          }
          waiters.removeWhere((c) => c.isCompleted);
        } else {
          try { client!.add(data); } catch (_) {}
        }
      },
      onDone: () { try { client?.close(); } catch (_) {} },
      onError: (Object e) {
        debugPrint('[Tor] HTTP bridge proxy error: $e');
        client?.destroy();
        proxy?.destroy();
      },
      cancelOnError: true,
    );
    client.listen(
      (data) {
        // After bridge is active, forward client→proxy directly.
        // Before active, no client data should arrive (connectionFactory
        // waits for the ready signal before returning the socket).
        if (active) {
          try { proxy!.add(data); } catch (_) {}
        }
      },
      onDone: () { try { proxy?.close(); } catch (_) {} },
      onError: (Object e) {
        debugPrint('[Tor] HTTP bridge client error: $e');
        client?.destroy();
        proxy?.destroy();
      },
      cancelOnError: true,
    );

    Future<List<int>> readN(int n) async {
      while (rxBuf.length < n) {
        final c = Completer<void>();
        waiters.add(c);
        await c.future.timeout(const Duration(seconds: 15));
      }
      final r = rxBuf.take(n).toList();
      rxBuf.removeRange(0, n);
      return r;
    }

    proxy.add([0x05, 0x01, 0x00]);
    final greet = await readN(2).timeout(const Duration(seconds: 10));
    if (greet[0] != 0x05 || greet[1] != 0x00) {
      throw SocketException('SOCKS5 auth negotiation failed');
    }

    final hostBytes = utf8.encode(targetHost);
    if (hostBytes.length > 255) throw ArgumentError('Hostname too long');
    proxy.add([
      0x05, 0x01, 0x00, 0x03,
      hostBytes.length, ...hostBytes,
      (targetPort >> 8) & 0xFF, targetPort & 0xFF,
    ]);
    final hdr = await readN(4).timeout(const Duration(seconds: 30));
    if (hdr[1] != 0x00) {
      throw SocketException(
          'SOCKS5 CONNECT to $targetHost:$targetPort failed (${hdr[1]})');
    }
    switch (hdr[3]) {
      case 0x01: await readN(6); break;               // IPv4 (4) + port (2)
      case 0x03:
        final len = (await readN(1))[0];
        await readN(len + 2); break;                  // domain + port
      case 0x04: await readN(18); break;              // IPv6 (16) + port (2)
    }

    // Flush any leftover proxy→client SOCKS5 data, then activate.
    // No clientBuf needed: connectionFactory waits for ready before returning
    // the socket, so HttpClient hasn't sent any data yet.
    if (rxBuf.isNotEmpty) {
      try { client.add(rxBuf.toList()); } catch (_) {}
      rxBuf.clear();
    }
    active = true;
    debugPrint('[Tor] HTTP bridge active → $targetHost:$targetPort');

    // Signal connectionFactory that the bridge is ready for traffic.
    if (!ready.isCompleted) ready.complete(true);
  } catch (e) {
    debugPrint('[Tor] HTTP bridge error ($targetHost:$targetPort): $e');
    if (!ready.isCompleted) ready.complete(false);
    client?.destroy();
    proxy?.destroy();
  }
}
