import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Circuit breaker for bridges and relays.
///
/// Tracks consecutive failures per endpoint. After [maxFailures] consecutive
/// failures, the endpoint is "tripped" and skipped for an exponentially
/// increasing backoff period: 5min → 30min → 2h → 12h (capped).
///
/// A single success resets the breaker for that endpoint.
class CircuitBreakerService {
  static final instance = CircuitBreakerService._();
  CircuitBreakerService._();

  static const _prefsKey = 'circuit_breaker_v1';
  static const int maxFailures = 3;
  static const List<Duration> _backoffs = [
    Duration(minutes: 5),
    Duration(minutes: 30),
    Duration(hours: 2),
    Duration(hours: 12),
  ];

  // In-memory state: endpoint → {failures: int, lastFailure: DateTime, tripCount: int}
  final Map<String, _BreakerState> _state = {};
  bool _loaded = false;

  /// Whether the endpoint should be skipped (circuit is open/tripped).
  Future<bool> shouldSkip(String endpoint) async {
    await _ensureLoaded();
    final s = _state[endpoint];
    if (s == null || s.failures < maxFailures) return false;
    final backoff = _backoffs[s.tripCount.clamp(0, _backoffs.length - 1)];
    return DateTime.now().difference(s.lastFailure) < backoff;
  }

  /// Synchronous version — returns false if not yet loaded.
  bool shouldSkipSync(String endpoint) {
    final s = _state[endpoint];
    if (s == null || s.failures < maxFailures) return false;
    final backoff = _backoffs[s.tripCount.clamp(0, _backoffs.length - 1)];
    return DateTime.now().difference(s.lastFailure) < backoff;
  }

  /// Record a failure for the endpoint.
  Future<void> recordFailure(String endpoint) async {
    await _ensureLoaded();
    final s = _state[endpoint] ?? _BreakerState();
    s.failures++;
    s.lastFailure = DateTime.now();
    if (s.failures >= maxFailures) {
      s.tripCount++;
    }
    _state[endpoint] = s;
    // Cap total entries to prevent unbounded growth
    if (_state.length > 500) {
      final sorted = _state.entries.toList()
        ..sort((a, b) => a.value.lastFailure.compareTo(b.value.lastFailure));
      for (final entry in sorted.take(_state.length - 500)) {
        _state.remove(entry.key);
      }
    }
    await _save();
  }

  /// Record a success — resets the breaker for the endpoint.
  Future<void> recordSuccess(String endpoint) async {
    await _ensureLoaded();
    _state.remove(endpoint);
    await _save();
  }

  /// Get failure count for an endpoint.
  int getFailures(String endpoint) => _state[endpoint]?.failures ?? 0;

  /// Clear all breaker state (e.g. when user forces a re-probe).
  Future<void> reset() async {
    _state.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        for (final entry in map.entries) {
          final v = entry.value as Map<String, dynamic>;
          // FINDING-6 fix: clamp values to prevent SharedPrefs poisoning from
          // permanently blocking relays (e.g. via rooted device or adb).
          _state[entry.key] = _BreakerState(
            failures: ((v['f'] as int? ?? 0)).clamp(0, 100),
            lastFailure: DateTime.fromMillisecondsSinceEpoch(v['t'] as int? ?? 0),
            tripCount: ((v['tc'] as int? ?? 0)).clamp(0, _backoffs.length - 1),
          );
        }
        // Cap total entry count on load (attacker could write 1000+ entries).
        if (_state.length > 500) {
          final sorted = _state.entries.toList()
            ..sort((a, b) => b.value.lastFailure.compareTo(a.value.lastFailure));
          _state
            ..clear()
            ..addEntries(sorted.take(500));
        }
      } catch (e) {
        debugPrint('[CircuitBreaker] Failed to restore state: $e');
      }
    }
    _loaded = true;
    // Purge entries older than 7 days to prevent unbounded growth
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    _state.removeWhere((_, s) => s.lastFailure.isBefore(cutoff) && s.failures < maxFailures);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, dynamic>{};
    for (final entry in _state.entries) {
      map[entry.key] = {
        'f': entry.value.failures,
        't': entry.value.lastFailure.millisecondsSinceEpoch,
        'tc': entry.value.tripCount,
      };
    }
    await prefs.setString(_prefsKey, jsonEncode(map));
  }
}

class _BreakerState {
  int failures;
  DateTime lastFailure;
  int tripCount; // how many times the breaker has tripped (for backoff escalation)

  _BreakerState({
    this.failures = 0,
    DateTime? lastFailure,
    this.tripCount = 0,
  }) : lastFailure = lastFailure ?? DateTime.fromMillisecondsSinceEpoch(0);
}
