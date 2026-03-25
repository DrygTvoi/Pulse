import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';
import 'package:path_provider/path_provider.dart';
import 'bundled_binary_service.dart';

/// Returns an HTTP client tunneled through Psiphon SOCKS5, or null if Psiphon
/// is not running.  Mirrors `buildTorHttpClient()` from tor_service.dart.
IOClient? buildPsiphonHttpClient({bool acceptBadCertificate = false}) {
  if (!PsiphonService.instance.isRunning) return null;
  final psiphonPort = PsiphonService.instance.proxyPort;
  if (psiphonPort == null) return null;

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
    unawaited(_runPsiphonSocks5Bridge(server, host, port, psiphonPort));
    try {
      final s = await Socket.connect(InternetAddress.loopbackIPv4, localPort,
          timeout: const Duration(seconds: 60));
      return ConnectionTask.fromSocket(Future.value(s), () => s.destroy());
    } catch (e) {
      unawaited(server.close());
      rethrow;
    }
  };
  return IOClient(inner);
}

/// Internal bridge: accepts one local connection then tunnels it to
/// [targetHost]:[targetPort] via Psiphon SOCKS5.
Future<void> _runPsiphonSocks5Bridge(
    ServerSocket server, String targetHost, int targetPort,
    int psiphonPort) async {
  Socket? client;
  Socket? proxy;
  try {
    client = await server.first;
    unawaited(server.close());

    proxy = await Socket.connect(
        InternetAddress.loopbackIPv4, psiphonPort,
        timeout: const Duration(seconds: 30));
    proxy.setOption(SocketOption.tcpNoDelay, true);

    final rxBuf = <int>[];
    final waiters = <Completer<void>>[];
    final clientBuf = <List<int>>[];
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
      onError: (Object _) { client?.destroy(); proxy?.destroy(); },
      cancelOnError: true,
    );
    client.listen(
      (data) {
        if (!active) { clientBuf.add(data); }
        else { try { proxy!.add(data); } catch (_) {} }
      },
      onDone: () { try { proxy?.destroy(); } catch (_) {} },
      onError: (Object _) { client?.destroy(); proxy?.destroy(); },
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

    active = true;
    if (rxBuf.isNotEmpty) {
      try { client.add(rxBuf.toList()); } catch (_) {}
      rxBuf.clear();
    }
    for (final d in clientBuf) { try { proxy.add(d); } catch (_) {} }
    clientBuf.clear();
    debugPrint('[Psiphon] HTTP bridge active → $targetHost:$targetPort');
  } catch (e) {
    debugPrint('[Psiphon] HTTP bridge error ($targetHost:$targetPort): $e');
    client?.destroy();
    proxy?.destroy();
    try { await server.close(); } catch (_) {}
  }
}

/// Manages the `pulse-psiphon` subprocess — a Psiphon tunnel client that
/// exposes a local SOCKS5 proxy.
///
/// Psiphon connects through ~2000+ rotating VPS worldwide using obfuscated
/// protocols (OSSH, TLS-OSSH, FRONTED-MEEK). Bootstrap: 3-5s typical.
///
/// Usage:
///   await PsiphonService.instance.ensureRunning();
///   final port = PsiphonService.instance.proxyPort;
///   // Use SOCKS5 via 127.0.0.1:port
///
/// Auto-restarts on crash with exponential backoff (2s, 4s, 8s, max 60s).
/// Falls back gracefully: if the binary is unavailable, ensureRunning() is a
/// no-op and proxyPort returns null — callers fall through to Tor/plain.
class PsiphonService {
  static final instance = PsiphonService._();
  PsiphonService._();

  Process? _process;
  int? _port;
  bool _starting = false;
  bool _stopped = false;
  int _restartCount = 0;
  static const _maxRestartDelay = 60; // seconds
  static const _maxRestarts = 10;

  bool get isRunning => _process != null && _port != null;

  /// SOCKS5 proxy port, or null if not running.
  int? get proxyPort => _port;

  /// Start the tunnel if not already running.
  /// Safe to call multiple times — idempotent.
  Future<void> ensureRunning() async {
    if (Platform.isIOS) { debugPrint('[PsiphonService] Not available on iOS'); return; }
    if (isRunning || _starting) return;
    _stopped = false;
    _starting = true;
    try {
      await _start();
    } finally {
      _starting = false;
    }
  }

  Future<void> stop() async {
    _stopped = true;
    // Do NOT reset _restartCount here — a rapid stop()/ensureRunning() loop
    // (e.g. triggered by an attacker causing repeated network changes) would
    // otherwise bypass the _maxRestarts cap and allow unbounded process spawning.
    // _restartCount is reset to 0 in _start() when the tunnel successfully connects.
    _process?.kill();
    await _process?.exitCode.catchError((_) => -1);
    _process = null;
    _port = null;
    debugPrint('[PsiphonService] stopped');
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  Future<void> _start() async {
    final binaryPath = await BundledBinaryService.extract('pulse-psiphon');
    if (binaryPath == null) {
      debugPrint('[PsiphonService] pulse-psiphon not available — skipping');
      return;
    }

    try {
      // Pass a platform-appropriate writable data directory so Psiphon can
      // cache its server list and state.  On Android, os.TempDir() in Go
      // returns a system path (/data/local/tmp) that is not writable by apps.
      final supportDir = await getApplicationSupportDirectory();
      final psiphonDataDir = '${supportDir.path}/psiphon';

      _process = await Process.start(binaryPath, [psiphonDataDir]);

      // The binary prints its SOCKS5 port as the first stdout line.
      final portCompleter = Completer<int?>();

      _process!.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        if (line.length > 64) return; // guard against malformed output
        final port = int.tryParse(line.trim());
        // BUG-07 fix: validate port is in unprivileged range before trusting
        if (port != null && port >= 1024 && port <= 65535 &&
            !portCompleter.isCompleted) {
          portCompleter.complete(port);
        }
      });

      _process!.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) => debugPrint('[Psiphon] $line'));

      // Auto-restart on unexpected exit
      _process!.exitCode.then((_) {
        _process = null;
        _port = null;
        if (!_stopped) {
          if (_restartCount >= _maxRestarts) {
            debugPrint('[PsiphonService] tunnel crashed — max restarts '
                '($_maxRestarts) reached, giving up');
            return;
          }
          final delay = (_restartCount < 6)
              ? (2 << _restartCount) // 2s, 4s, 8s, 16s, 32s, 64s
              : _maxRestartDelay;
          _restartCount++;
          debugPrint('[PsiphonService] tunnel crashed — restarting in ${delay}s '
              '(attempt $_restartCount/$_maxRestarts)');
          Future.delayed(Duration(seconds: delay), () {
            if (!_stopped) ensureRunning();
          });
        } else {
          debugPrint('[PsiphonService] tunnel exited (explicit stop)');
        }
      });

      // Psiphon can take up to 120s to bootstrap (fetching server list, etc.)
      _port = await portCompleter.future
          .timeout(const Duration(seconds: 120), onTimeout: () => null);

      if (_port == null) {
        await stop();
        _stopped = false; // allow auto-restart after timeout
        debugPrint('[PsiphonService] timed out waiting for tunnel');
        if (_restartCount < _maxRestarts) {
          final delay = (_restartCount < 6)
              ? (2 << _restartCount)
              : _maxRestartDelay;
          _restartCount++;
          debugPrint('[PsiphonService] timed out — retrying in ${delay}s '
              '(attempt $_restartCount/$_maxRestarts)');
          Future.delayed(Duration(seconds: delay), () {
            if (!_stopped) ensureRunning();
          });
        }
      } else {
        _restartCount = 0;
        debugPrint('[PsiphonService] tunnel running — SOCKS5 on 127.0.0.1:$_port');
      }
    } catch (e) {
      debugPrint('[PsiphonService] start error: $e');
      _process = null;
      _port = null;
    }
  }
}
