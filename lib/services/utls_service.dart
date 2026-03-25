import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'bundled_binary_service.dart';

/// Manages the `pulse-utls-proxy` subprocess — a local HTTP CONNECT proxy
/// with full anti-GFW stack:
///
///   - ECH (Encrypted Client Hello) — hides real SNI from DPI
///   - ECH retry configs — auto-recovers on ECH key rotation
///   - TLS fingerprint rotation — Chrome/Firefox/Edge/Safari/Randomized
///   - DoH resolution — bypasses DNS poisoning (7 providers)
///   - Probe resistance — looks like nginx on non-CONNECT
///
/// Usage:
///   await UTLSService.instance.ensureRunning();
///   final port = UTLSService.instance.proxyPort;
///   // Dart sends CONNECT host:443 → Go proxy handles TLS+ECH+DoH
///
/// Auto-restarts on crash with exponential backoff (1s, 2s, 4s, max 30s).
/// Falls back gracefully: if the binary is unavailable, ensureRunning() is a
/// no-op and proxyPort returns null — callers fall through to Tor/plain.
class UTLSService {
  static UTLSService instance = UTLSService._();
  UTLSService._();

  /// Protected constructor for test subclasses.
  @visibleForTesting
  UTLSService.forTesting();

  /// Replace the singleton for testing.
  @visibleForTesting
  static void setInstanceForTesting(UTLSService inst) => instance = inst;

  Process? _process;
  int? _port;
  String? _proxyToken; // per-session secret printed alongside port on stdout
  bool _starting = false;
  bool _stopped = false; // true when stop() called explicitly
  int _restartCount = 0;
  static const _maxRestartDelay = 30; // seconds
  static const _maxRestarts = 10;

  /// True when the uTLS proxy binary was successfully extracted and started.
  /// False if the binary is missing (e.g. unsupported platform) — callers can
  /// show a "No ECH" warning chip to inform the user.
  final ValueNotifier<bool> available = ValueNotifier<bool>(false);

  bool get isRunning => _process != null && _port != null;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Start the proxy if not already running.
  /// Safe to call multiple times — idempotent.
  Future<void> ensureRunning() async {
    if (isRunning || _starting) return;
    _stopped = false;
    _starting = true;
    try {
      await _start();
    } finally {
      _starting = false;
    }
  }

  /// Returns a dart:io [HttpClient] whose connections are routed through the
  /// uTLS proxy, or null if the proxy is not running.
  HttpClient? buildHttpClient() {
    if (!isRunning) return null;
    final client = HttpClient();
    client.findProxy = (_) => 'PROXY 127.0.0.1:$_port';
    return client;
  }

  /// Port the proxy is listening on, or null if not running.
  int? get proxyPort => _port;

  /// Per-session secret token for /ygg and /ygg/proxy endpoints.
  /// Null if the proxy hasn't started or uses an older binary format.
  String? get proxyToken => _proxyToken;

  Future<void> stop() async {
    _stopped = true;
    _process?.kill();
    await _process?.exitCode.catchError((_) => -1);
    _process = null;
    _port = null;
    _proxyToken = null;
    debugPrint('[UTLSService] stopped');
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  Future<void> _start() async {
    final binaryPath =
        await BundledBinaryService.extract('pulse-utls-proxy');
    if (binaryPath == null) {
      debugPrint('[UTLSService] pulse-utls-proxy not available — skipping uTLS');
      available.value = false;
      return;
    }

    try {
      _process = await Process.start(binaryPath, []);

      // The proxy prints its port as the first stdout line.
      final portCompleter = Completer<int?>();

      _process!.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        // Proxy prints "PORT TOKEN" — parse both.
        // Older binaries print just "PORT" — token remains null (no auth).
        final parts = line.trim().split(' ');
        final port = int.tryParse(parts[0]);
        // BUG-07 fix: validate port is in unprivileged range before trusting
        if (port != null && port >= 1024 && port <= 65535 &&
            !portCompleter.isCompleted) {
          if (parts.length >= 2 && parts[1].length == 64) {
            _proxyToken = parts[1]; // 64 hex chars = 32 bytes
          }
          portCompleter.complete(port);
        }
      });

      _process!.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) => debugPrint('[uTLS] $line'));

      // Auto-restart on unexpected exit
      _process!.exitCode.then((_) {
        _process = null;
        _port = null;
        _proxyToken = null;
        available.value = false;
        if (!_stopped) {
          if (_restartCount >= _maxRestarts) {
            debugPrint('[UTLSService] proxy crashed — max restarts '
                '($_maxRestarts) reached, giving up');
            return;
          }
          // Exponential backoff: 1s, 2s, 4s, 8s... max 30s
          final delay = (_restartCount < 5)
              ? (1 << _restartCount)
              : _maxRestartDelay;
          _restartCount++;
          debugPrint('[UTLSService] proxy crashed — restarting in ${delay}s '
              '(attempt $_restartCount/$_maxRestarts)');
          Future.delayed(Duration(seconds: delay), () {
            if (!_stopped) ensureRunning();
          });
        } else {
          debugPrint('[UTLSService] proxy exited (explicit stop)');
        }
      });

      _port = await portCompleter.future
          .timeout(const Duration(seconds: 5), onTimeout: () => null);

      if (_port == null) {
        await stop();
        _stopped = false; // allow auto-restart after timeout
        available.value = false;
        debugPrint('[UTLSService] timed out waiting for port');
      } else {
        _restartCount = 0; // reset on successful start
        available.value = true;
        debugPrint('[UTLSService] proxy running on 127.0.0.1:$_port');
      }
    } catch (e) {
      debugPrint('[UTLSService] start error: $e');
      _process = null;
      _port = null;
      _proxyToken = null;
    }
  }
}
