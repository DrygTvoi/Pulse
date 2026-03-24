import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Lightweight internet connectivity probe with network-change detection.
///
/// Uses a TCP connect to well-known DNS servers (no actual DNS query).
/// Also detects interface IP changes (WiFi↔cellular, VPN toggle) and
/// fires [onNetworkChanged] so callers can re-probe/reconnect.
class NetworkMonitor {
  NetworkMonitor._();
  static final instance = NetworkMonitor._();

  bool _available = true;
  bool get isAvailable => _available;

  Timer? _timer;
  Set<String> _lastIps = {};

  // ── Public API ────────────────────────────────────────────────────────────

  /// Starts periodic connectivity checks every [interval].
  /// [onChanged] is called whenever the connectivity status flips.
  /// [onNetworkChanged] is called when network interfaces change (IP swap),
  ///   even if connectivity status stays the same (e.g. WiFi→cellular).
  void startMonitoring({
    Duration interval = const Duration(seconds: 30),
    required void Function(bool isAvailable) onChanged,
    void Function()? onNetworkChanged,
  }) {
    _timer?.cancel();
    // Snapshot current IPs
    _snapshotIps().then((ips) { _lastIps = ips; });
    _timer = Timer.periodic(interval, (_) async {
      final was = _available;
      _available = await checkOnce();

      // Detect interface IP changes (WiFi↔cellular, VPN toggle)
      final currentIps = await _snapshotIps();
      final ipsChanged = !_setsEqual(_lastIps, currentIps);
      if (ipsChanged) {
        _lastIps = currentIps;
        debugPrint('[NetworkMonitor] Interface IPs changed: $currentIps');
        // FINDING-11 fix: only fire here when connectivity status didn't also
        // change — avoids double-fire when both conditions occur simultaneously.
        if (was == _available) onNetworkChanged?.call();
      }

      if (was != _available) {
        debugPrint('[NetworkMonitor] Internet ${_available ? "restored" : "lost"}');
        onChanged(_available);
        // Connectivity restored → also treat as network change (single fire
        // covers both IP change and connectivity restoration).
        if (_available && !was) {
          onNetworkChanged?.call();
        }
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
      Socket? socket;
      try {
        socket = await Socket.connect(
          host, 53,
          timeout: const Duration(seconds: 3),
        );
        return true;
      } catch (e) {
        debugPrint('[Network] Connectivity check to $host failed: $e');
      } finally {
        socket?.destroy();
      }
    }
    return false;
  }

  /// Collect all non-loopback IPv4 addresses from active interfaces.
  Future<Set<String>> _snapshotIps() async {
    try {
      final interfaces = await NetworkInterface.list(
          type: InternetAddressType.IPv4);
      final ips = <String>{};
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (!addr.isLoopback) {
            ips.add(addr.address);
          }
        }
      }
      return ips;
    } catch (_) {
      return {};
    }
  }

  bool _setsEqual(Set<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }
}
