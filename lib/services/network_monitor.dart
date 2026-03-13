import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Lightweight internet connectivity probe.
///
/// Uses a TCP connect to well-known DNS servers (no actual DNS query).
/// Does not send any application data — pure connectivity check.
class NetworkMonitor {
  NetworkMonitor._();
  static final instance = NetworkMonitor._();

  bool _available = true;
  bool get isAvailable => _available;

  Timer? _timer;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Starts periodic connectivity checks every [interval].
  /// [onChanged] is called whenever the status flips.
  void startMonitoring({
    Duration interval = const Duration(seconds: 30),
    required void Function(bool isAvailable) onChanged,
  }) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) async {
      final was = _available;
      _available = await checkOnce();
      if (was != _available) {
        debugPrint('[NetworkMonitor] Internet ${_available ? "restored" : "lost"}');
        onChanged(_available);
      }
    });
  }

  void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
  }

  /// Single-shot check: returns true if internet is reachable.
  static Future<bool> checkOnce() async {
    // Try two well-known DNS servers via TCP (port 53).
    // We don't send data — just check that a TCP connection can be established.
    for (final host in ['8.8.8.8', '1.1.1.1']) {
      try {
        final socket = await Socket.connect(
          host, 53,
          timeout: const Duration(seconds: 3),
        );
        socket.destroy();
        return true;
      } catch (_) {}
    }
    return false;
  }
}
