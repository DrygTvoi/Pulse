import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'bundled_binary_service.dart';

/// Manages the `pulse-utls-proxy` subprocess — a local HTTP CONNECT proxy
/// that uses Chrome's TLS fingerprint (via the Go uTLS library) for all
/// upstream connections.
///
/// This defeats DPI systems (GFW, Iranian DPI) that block traffic by
/// identifying Dart's distinctive TLS ClientHello fingerprint.
///
/// Usage:
///   await UTLSService.instance.ensureRunning();
///   final client = UTLSService.instance.buildHttpClient();
///   if (client != null) {
///     final ws = await WebSocket.connect(url, customClient: client);
///   }
///
/// Falls back gracefully: if the binary is unavailable, ensureRunning() is a
/// no-op and buildHttpClient() returns null — callers use plain dart:io TLS.
class UTLSService {
  static final instance = UTLSService._();
  UTLSService._();

  Process? _process;
  int? _port;
  bool _starting = false;

  bool get isRunning => _process != null && _port != null;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Start the proxy if not already running.
  /// Safe to call multiple times — idempotent.
  Future<void> ensureRunning() async {
    if (isRunning || _starting) return;
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

  Future<void> stop() async {
    _process?.kill();
    await _process?.exitCode.catchError((_) => -1);
    _process = null;
    _port = null;
    debugPrint('[UTLSService] stopped');
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  Future<void> _start() async {
    final binaryPath =
        await BundledBinaryService.extract('pulse-utls-proxy');
    if (binaryPath == null) {
      debugPrint('[UTLSService] pulse-utls-proxy not available — skipping uTLS');
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
        final port = int.tryParse(line.trim());
        if (port != null && !portCompleter.isCompleted) {
          portCompleter.complete(port);
        }
      });

      _process!.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) => debugPrint('[uTLS:err] $line'));

      _process!.exitCode.then((_) {
        _process = null;
        _port = null;
        debugPrint('[UTLSService] proxy exited');
      });

      _port = await portCompleter.future
          .timeout(const Duration(seconds: 5), onTimeout: () => null);

      if (_port == null) {
        await stop();
        debugPrint('[UTLSService] timed out waiting for port');
      } else {
        debugPrint('[UTLSService] proxy running on 127.0.0.1:$_port');
      }
    } catch (e) {
      debugPrint('[UTLSService] start error: $e');
      _process = null;
      _port = null;
    }
  }
}
