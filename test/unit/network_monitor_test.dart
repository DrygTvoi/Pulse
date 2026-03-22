import 'package:flutter_test/flutter_test.dart';

// ── Pure logic extracted from NetworkMonitor ──────────────────────────────────
//
// NetworkMonitor uses dart:io (Socket.connect, NetworkInterface.list) which
// require real network access.  We extract all testable decision-making logic
// into pure functions mirroring the production code.
//
// Extracted logic mirrors:
//   • _setsEqual()             → setsEqual()
//   • IP change detection flow → detectIpChange()
//   • connectivity flip        → detectConnectivityFlip()
//   • restored-as-network-change logic

// ── Set equality ─────────────────────────────────────────────────────────────

/// Mirrors NetworkMonitor._setsEqual — checks if two sets contain the same
/// elements.
bool setsEqual(Set<String> a, Set<String> b) {
  if (a.length != b.length) return false;
  return a.containsAll(b);
}

// ── IP change detection ──────────────────────────────────────────────────────

/// Mirrors the IP-change detection in startMonitoring's timer callback.
/// Returns true if interface IPs have changed.
bool detectIpChange(Set<String> lastIps, Set<String> currentIps) {
  return !setsEqual(lastIps, currentIps);
}

// ── Connectivity flip detection ──────────────────────────────────────────────

/// Mirrors the `was != _available` check.
/// Returns (shouldNotifyChanged, shouldNotifyNetworkChanged).
///
/// Rules from production:
///   1. If connectivity changed (was != current) → notify onChanged
///   2. If restored (was=false, current=true) → ALSO notify onNetworkChanged
///   3. If IPs changed → notify onNetworkChanged (handled separately)
({bool notifyChanged, bool notifyRestored}) detectConnectivityFlip({
  required bool wasAvailable,
  required bool isAvailable,
}) {
  final changed = wasAvailable != isAvailable;
  final restored = isAvailable && !wasAvailable;
  return (notifyChanged: changed, notifyRestored: changed && restored);
}

// ── Loopback filter ──────────────────────────────────────────────────────────

/// Mirrors the `!addr.isLoopback` filter in _snapshotIps().
/// Since InternetAddress is dart:io, we test the filter concept with strings.
bool isNonLoopback(String ip) {
  return ip != '127.0.0.1' && !ip.startsWith('127.') && ip != '::1';
}

Set<String> filterNonLoopback(Set<String> ips) {
  return ips.where(isNonLoopback).toSet();
}

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ── Set equality ────────────────────────────────────────────────────────

  group('setsEqual: IP set comparison', () {
    test('empty sets are equal', () {
      expect(setsEqual({}, {}), isTrue);
    });

    test('identical single-element sets are equal', () {
      expect(setsEqual({'192.168.1.1'}, {'192.168.1.1'}), isTrue);
    });

    test('identical multi-element sets are equal', () {
      expect(
        setsEqual(
          {'192.168.1.1', '10.0.0.1', '172.16.0.1'},
          {'172.16.0.1', '10.0.0.1', '192.168.1.1'},
        ),
        isTrue,
      );
    });

    test('different-length sets are not equal', () {
      expect(setsEqual({'192.168.1.1'}, {'192.168.1.1', '10.0.0.1'}), isFalse);
    });

    test('same-length sets with different elements are not equal', () {
      expect(setsEqual({'192.168.1.1'}, {'10.0.0.1'}), isFalse);
    });

    test('empty vs non-empty is not equal', () {
      expect(setsEqual({}, {'192.168.1.1'}), isFalse);
      expect(setsEqual({'192.168.1.1'}, {}), isFalse);
    });

    test('subset is not equal to superset', () {
      expect(
        setsEqual({'192.168.1.1', '10.0.0.1'}, {'192.168.1.1', '10.0.0.1', '172.16.0.1'}),
        isFalse,
      );
    });

    test('overlapping sets of same size are not equal', () {
      expect(
        setsEqual({'192.168.1.1', '10.0.0.1'}, {'192.168.1.1', '172.16.0.1'}),
        isFalse,
      );
    });
  });

  // ── IP change detection ────────────────────────────────────────────────

  group('detectIpChange: interface IP monitoring', () {
    test('no change when IPs are identical', () {
      expect(
        detectIpChange({'192.168.1.100'}, {'192.168.1.100'}),
        isFalse,
      );
    });

    test('detects added IP (e.g. VPN connected)', () {
      expect(
        detectIpChange(
          {'192.168.1.100'},
          {'192.168.1.100', '10.8.0.1'},
        ),
        isTrue,
      );
    });

    test('detects removed IP (e.g. WiFi disconnected)', () {
      expect(
        detectIpChange(
          {'192.168.1.100', '10.8.0.1'},
          {'10.8.0.1'},
        ),
        isTrue,
      );
    });

    test('detects IP swap (WiFi to cellular)', () {
      expect(
        detectIpChange({'192.168.1.100'}, {'10.0.0.50'}),
        isTrue,
      );
    });

    test('empty to non-empty is a change', () {
      expect(detectIpChange({}, {'192.168.1.100'}), isTrue);
    });

    test('non-empty to empty is a change', () {
      expect(detectIpChange({'192.168.1.100'}, {}), isTrue);
    });

    test('both empty is not a change', () {
      expect(detectIpChange({}, {}), isFalse);
    });

    test('same IPs in different order is not a change (sets are unordered)', () {
      expect(
        detectIpChange(
          {'10.0.0.1', '192.168.1.1'},
          {'192.168.1.1', '10.0.0.1'},
        ),
        isFalse,
      );
    });
  });

  // ── Connectivity flip detection ────────────────────────────────────────

  group('detectConnectivityFlip: status transitions', () {
    test('no change: both available', () {
      final result = detectConnectivityFlip(wasAvailable: true, isAvailable: true);
      expect(result.notifyChanged, isFalse);
      expect(result.notifyRestored, isFalse);
    });

    test('no change: both unavailable', () {
      final result = detectConnectivityFlip(wasAvailable: false, isAvailable: false);
      expect(result.notifyChanged, isFalse);
      expect(result.notifyRestored, isFalse);
    });

    test('connection lost: available → unavailable', () {
      final result = detectConnectivityFlip(wasAvailable: true, isAvailable: false);
      expect(result.notifyChanged, isTrue);
      expect(result.notifyRestored, isFalse);
    });

    test('connection restored: unavailable → available', () {
      final result = detectConnectivityFlip(wasAvailable: false, isAvailable: true);
      expect(result.notifyChanged, isTrue);
      expect(result.notifyRestored, isTrue,
          reason: 'restored connectivity also triggers onNetworkChanged');
    });
  });

  // ── Loopback filtering ─────────────────────────────────────────────────

  group('isNonLoopback: loopback address filtering', () {
    test('127.0.0.1 is loopback', () {
      expect(isNonLoopback('127.0.0.1'), isFalse);
    });

    test('127.x.x.x range is loopback', () {
      expect(isNonLoopback('127.0.0.2'), isFalse);
      expect(isNonLoopback('127.255.255.255'), isFalse);
    });

    test('::1 is loopback', () {
      expect(isNonLoopback('::1'), isFalse);
    });

    test('192.168.1.1 is not loopback', () {
      expect(isNonLoopback('192.168.1.1'), isTrue);
    });

    test('10.0.0.1 is not loopback', () {
      expect(isNonLoopback('10.0.0.1'), isTrue);
    });

    test('public IP is not loopback', () {
      expect(isNonLoopback('8.8.8.8'), isTrue);
    });
  });

  group('filterNonLoopback: batch filtering', () {
    test('removes all loopback addresses', () {
      final ips = {'127.0.0.1', '192.168.1.1', '::1', '10.0.0.1'};
      expect(filterNonLoopback(ips), {'192.168.1.1', '10.0.0.1'});
    });

    test('preserves all non-loopback addresses', () {
      final ips = {'192.168.1.1', '10.0.0.1', '8.8.8.8'};
      expect(filterNonLoopback(ips), ips);
    });

    test('returns empty set when all are loopback', () {
      expect(filterNonLoopback({'127.0.0.1', '::1'}), isEmpty);
    });

    test('returns empty set from empty input', () {
      expect(filterNonLoopback({}), isEmpty);
    });
  });

  // ── Combined scenario ──────────────────────────────────────────────────

  group('combined: monitoring tick simulation', () {
    test('WiFi → cellular: IPs change, connectivity stays', () {
      final lastIps = {'192.168.1.100'};
      final currentIps = {'10.0.0.50'};
      final wasAvailable = true;
      final isAvailable = true;

      final ipChanged = detectIpChange(lastIps, currentIps);
      final flip = detectConnectivityFlip(
          wasAvailable: wasAvailable, isAvailable: isAvailable);

      expect(ipChanged, isTrue, reason: 'WiFi→cellular changes IP');
      expect(flip.notifyChanged, isFalse,
          reason: 'connectivity did not change');
      expect(flip.notifyRestored, isFalse);
    });

    test('network lost then restored: both flags fire', () {
      // Tick 1: lose connectivity
      final flip1 = detectConnectivityFlip(
          wasAvailable: true, isAvailable: false);
      expect(flip1.notifyChanged, isTrue);
      expect(flip1.notifyRestored, isFalse);

      // Tick 2: restore connectivity with different IP
      final flip2 = detectConnectivityFlip(
          wasAvailable: false, isAvailable: true);
      final ipChanged = detectIpChange({'192.168.1.100'}, {'10.0.0.50'});

      expect(flip2.notifyChanged, isTrue);
      expect(flip2.notifyRestored, isTrue);
      expect(ipChanged, isTrue);
    });

    test('stable connection, no IP change: nothing fires', () {
      final flip = detectConnectivityFlip(
          wasAvailable: true, isAvailable: true);
      final ipChanged =
          detectIpChange({'192.168.1.100'}, {'192.168.1.100'});

      expect(flip.notifyChanged, isFalse);
      expect(flip.notifyRestored, isFalse);
      expect(ipChanged, isFalse);
    });
  });
}
