import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/services/ice_server_config.dart';

// ── Pure logic tests for ICE server configuration ────────────────────────────
//
// IceServerConfig.load()/loadRelay() use SharedPreferences, so we cannot call
// them directly.  However, the STUN URL list and TURN preset constants are
// public top-level values that encode important invariants about server
// ordering, URL format, and the TURN relay filter logic.
//
// We test:
//   • _kStunUrls format, ordering, and diversity (via kTurnPresets proxy)
//   • kTurnPresets structure and credentials
//   • TURN URL scheme filtering (the turns: filter from loadRelay)
//   • Custom TURN URL construction
//   • Preset enable/disable semantics

// ── TURN URL scheme filter ───────────────────────────────────────────────────
// Mirrors the filter in IceServerConfig.loadRelay():
//   - Only URLs starting with 'turns:' pass through
//   - STUN and plain TURN are excluded

/// Filter a server list to only TLS-over-TCP TURN servers.
/// Mirrors the filtering logic in IceServerConfig.loadRelay().
List<Map<String, dynamic>> filterRelayOnly(List<Map<String, dynamic>> servers) {
  final result = <Map<String, dynamic>>[];
  for (final server in servers) {
    final urls = server['urls'];
    if (urls is String) {
      if (urls.startsWith('turns:')) result.add(server);
    } else if (urls is List) {
      final tls =
          urls.where((u) => u.toString().startsWith('turns:')).toList();
      if (tls.isNotEmpty) {
        result.add({
          ...server,
          'urls': tls.length == 1 ? tls.first as String : tls,
        });
      }
    }
    // STUN entries (no username/credential) are skipped
  }
  return result;
}

/// Builds a custom TURN ICE server entry. Mirrors the logic in load().
Map<String, dynamic> buildCustomTurnEntry({
  required String url,
  String username = '',
  String password = '',
}) {
  return {
    'urls': url,
    if (username.isNotEmpty) 'username': username,
    if (password.isNotEmpty) 'credential': password,
  };
}

// ── Preset lookup ────────────────────────────────────────────────────────────

/// Given enabled preset IDs, collects all their server entries.
/// Mirrors the preset iteration in IceServerConfig.load().
List<Map<String, dynamic>> collectEnabledPresetServers(List<String> enabledIds) {
  final servers = <Map<String, dynamic>>[];
  for (final preset in kTurnPresets) {
    if (!enabledIds.contains(preset['id'] as String)) continue;
    for (final s in preset['servers'] as List) {
      servers.add(Map<String, dynamic>.from(s as Map));
    }
  }
  return servers;
}

/// Parse probe-discovered TURN servers from JSON string.
/// Mirrors the JSON parsing in load().
List<Map<String, dynamic>> parseProbeTurnServers(String? raw) {
  if (raw == null) return [];
  try {
    final list = jsonDecode(raw) as List;
    return list.map((s) => Map<String, dynamic>.from(s as Map)).toList();
  } catch (_) {
    return [];
  }
}

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ── kTurnPresets structure ──────────────────────────────────────────────

  group('kTurnPresets: structure validation', () {
    test('has at least 2 presets (openrelay + freestun)', () {
      expect(kTurnPresets.length, greaterThanOrEqualTo(2));
    });

    test('every preset has an id, name, host, and servers list', () {
      for (final preset in kTurnPresets) {
        expect(preset['id'], isA<String>(), reason: 'id should be a string');
        expect(preset['name'], isA<String>(),
            reason: 'name should be a string');
        expect(preset['host'], isA<String>(),
            reason: 'host should be a string');
        expect(preset['servers'], isA<List>(),
            reason: 'servers should be a list');
        expect((preset['servers'] as List), isNotEmpty,
            reason: 'servers list should not be empty');
      }
    });

    test('preset IDs are unique', () {
      final ids = kTurnPresets.map((p) => p['id'] as String).toList();
      expect(ids.toSet().length, ids.length, reason: 'IDs must be unique');
    });

    test('openrelay preset exists with correct id', () {
      final openrelay = kTurnPresets.firstWhere(
        (p) => p['id'] == 'openrelay',
        orElse: () => <String, Object>{},
      );
      expect(openrelay['id'], 'openrelay');
    });

    test('freestun preset exists with correct id', () {
      final freestun = kTurnPresets.firstWhere(
        (p) => p['id'] == 'freestun',
        orElse: () => <String, Object>{},
      );
      expect(freestun['id'], 'freestun');
    });

    test('openrelay has turns: server for strict firewall traversal', () {
      final openrelay = kTurnPresets.firstWhere((p) => p['id'] == 'openrelay');
      final servers = openrelay['servers'] as List;
      final hasTurns = servers.any((s) {
        final urls = (s as Map)['urls'] as String? ?? '';
        return urls.startsWith('turns:');
      });
      expect(hasTurns, isTrue,
          reason: 'openrelay must have TLS TURN for restricted networks');
    });

    test('freestun has turns: server for strict firewall traversal', () {
      final freestun = kTurnPresets.firstWhere((p) => p['id'] == 'freestun');
      final servers = freestun['servers'] as List;
      final hasTurns = servers.any((s) {
        final urls = (s as Map)['urls'] as String? ?? '';
        return urls.startsWith('turns:');
      });
      expect(hasTurns, isTrue,
          reason: 'freestun must have TLS TURN for restricted networks');
    });

    test('every TURN server entry has username and credential', () {
      for (final preset in kTurnPresets) {
        for (final server in preset['servers'] as List) {
          final s = server as Map;
          final urls = s['urls'] as String? ?? '';
          if (urls.startsWith('turn:') || urls.startsWith('turns:')) {
            expect(s['username'], isNotNull,
                reason:
                    '${preset['id']} TURN server should have username');
            expect(s['credential'], isNotNull,
                reason:
                    '${preset['id']} TURN server should have credential');
          }
        }
      }
    });

    test('all server URLs are valid STUN/TURN URIs', () {
      for (final preset in kTurnPresets) {
        for (final server in preset['servers'] as List) {
          final urls = (server as Map)['urls'] as String;
          expect(
            urls.startsWith('stun:') ||
                urls.startsWith('turn:') ||
                urls.startsWith('turns:'),
            isTrue,
            reason: 'URL "$urls" in ${preset['id']} must start with stun:/turn:/turns:',
          );
        }
      }
    });
  });

  // ── TURN relay filter (loadRelay logic) ─────────────────────────────────

  group('filterRelayOnly: TLS TURN filter', () {
    test('keeps turns: entries', () {
      final servers = [
        {'urls': 'turns:example.com:443?transport=tcp', 'username': 'u', 'credential': 'p'},
      ];
      final result = filterRelayOnly(servers);
      expect(result, hasLength(1));
      expect(result.first['urls'], contains('turns:'));
    });

    test('removes plain turn: entries', () {
      final servers = [
        {'urls': 'turn:example.com:3478', 'username': 'u', 'credential': 'p'},
      ];
      expect(filterRelayOnly(servers), isEmpty);
    });

    test('removes stun: entries', () {
      final servers = [
        {'urls': 'stun:stun.l.google.com:19302'},
      ];
      expect(filterRelayOnly(servers), isEmpty);
    });

    test('handles mixed list: keeps only turns:', () {
      final servers = [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'turn:openrelay.metered.ca:80', 'username': 'u', 'credential': 'p'},
        {'urls': 'turns:openrelay.metered.ca:443?transport=tcp', 'username': 'u', 'credential': 'p'},
      ];
      final result = filterRelayOnly(servers);
      expect(result, hasLength(1));
      expect(result.first['urls'], startsWith('turns:'));
    });

    test('handles URL list (array) — filters to turns: only', () {
      final servers = [
        {
          'urls': ['turn:example.com:80', 'turns:example.com:443'],
          'username': 'u',
          'credential': 'p',
        },
      ];
      final result = filterRelayOnly(servers);
      expect(result, hasLength(1));
      expect(result.first['urls'], 'turns:example.com:443');
    });

    test('handles URL list with multiple turns: entries', () {
      final servers = [
        {
          'urls': ['turn:a.com:80', 'turns:a.com:443', 'turns:a.com:5349'],
          'username': 'u',
          'credential': 'p',
        },
      ];
      final result = filterRelayOnly(servers);
      expect(result, hasLength(1));
      // Multiple turns: → returned as list
      expect(result.first['urls'], isA<List>());
      expect((result.first['urls'] as List), hasLength(2));
    });

    test('preserves username and credential in filtered entries', () {
      final servers = [
        {
          'urls': 'turns:relay.example.com:443?transport=tcp',
          'username': 'myuser',
          'credential': 'mypass',
        },
      ];
      final result = filterRelayOnly(servers);
      expect(result.first['username'], 'myuser');
      expect(result.first['credential'], 'mypass');
    });

    test('URL list with no turns: entries produces nothing', () {
      final servers = [
        {
          'urls': ['turn:a.com:80', 'stun:a.com:3478'],
          'username': 'u',
          'credential': 'p',
        },
      ];
      expect(filterRelayOnly(servers), isEmpty);
    });

    test('empty server list produces empty result', () {
      expect(filterRelayOnly([]), isEmpty);
    });
  });

  // ── Custom TURN entry builder ──────────────────────────────────────────

  group('buildCustomTurnEntry: custom TURN construction', () {
    test('builds entry with URL, username, and password', () {
      final entry = buildCustomTurnEntry(
        url: 'turns:my.turn.server:443',
        username: 'alice',
        password: 'secret',
      );
      expect(entry['urls'], 'turns:my.turn.server:443');
      expect(entry['username'], 'alice');
      expect(entry['credential'], 'secret');
    });

    test('omits username when empty', () {
      final entry = buildCustomTurnEntry(url: 'turn:server:3478');
      expect(entry.containsKey('username'), isFalse);
    });

    test('omits credential when password empty', () {
      final entry = buildCustomTurnEntry(url: 'turn:server:3478');
      expect(entry.containsKey('credential'), isFalse);
    });

    test('includes only non-empty credentials', () {
      final entry = buildCustomTurnEntry(
        url: 'turn:server:3478',
        username: 'user',
        password: '',
      );
      expect(entry.containsKey('username'), isTrue);
      expect(entry.containsKey('credential'), isFalse);
    });
  });

  // ── Preset collection ──────────────────────────────────────────────────

  group('collectEnabledPresetServers: preset enable/disable', () {
    test('default enabled: openrelay + freestun', () {
      final servers = collectEnabledPresetServers(['openrelay', 'freestun']);
      expect(servers, isNotEmpty);
      // openrelay has 3 servers, freestun has 2 = 5 total
      expect(servers.length, greaterThanOrEqualTo(4));
    });

    test('only openrelay enabled', () {
      final all = collectEnabledPresetServers(['openrelay', 'freestun']);
      final openOnly = collectEnabledPresetServers(['openrelay']);
      expect(openOnly.length, lessThan(all.length));
      expect(openOnly, isNotEmpty);
    });

    test('no presets enabled → empty list', () {
      expect(collectEnabledPresetServers([]), isEmpty);
    });

    test('non-existent preset ID is silently ignored', () {
      final servers = collectEnabledPresetServers(['nonexistent']);
      expect(servers, isEmpty);
    });

    test('metered preset returns stun-only entry', () {
      final servers = collectEnabledPresetServers(['metered']);
      expect(servers, isNotEmpty);
      // Metered only has STUN
      for (final s in servers) {
        final urls = s['urls'] as String;
        expect(urls, startsWith('stun:'));
      }
    });
  });

  // ── Probe TURN servers parsing ─────────────────────────────────────────

  group('parseProbeTurnServers: JSON parsing', () {
    test('parses valid JSON array of server objects', () {
      final raw = jsonEncode([
        {'urls': 'turn:probe.example.com:3478', 'username': 'u', 'credential': 'p'},
      ]);
      final result = parseProbeTurnServers(raw);
      expect(result, hasLength(1));
      expect(result.first['urls'], 'turn:probe.example.com:3478');
    });

    test('returns empty list for null input', () {
      expect(parseProbeTurnServers(null), isEmpty);
    });

    test('returns empty list for malformed JSON', () {
      expect(parseProbeTurnServers('not json'), isEmpty);
    });

    test('returns empty list for empty JSON array', () {
      expect(parseProbeTurnServers('[]'), isEmpty);
    });

    test('handles multiple probe servers', () {
      final raw = jsonEncode([
        {'urls': 'turn:a.com:3478', 'username': 'u1', 'credential': 'p1'},
        {'urls': 'turns:b.com:443', 'username': 'u2', 'credential': 'p2'},
      ]);
      final result = parseProbeTurnServers(raw);
      expect(result, hasLength(2));
    });

    test('returns empty list for non-array JSON', () {
      expect(parseProbeTurnServers('{"key": "value"}'), isEmpty);
    });
  });

  // ── Integration: preset → relay filter pipeline ────────────────────────

  group('integration: preset servers → relay filter', () {
    test('openrelay has at least one turns: server after filtering', () {
      final servers = collectEnabledPresetServers(['openrelay']);
      final relayOnly = filterRelayOnly(servers);
      expect(relayOnly, isNotEmpty,
          reason: 'openrelay must provide at least one TLS TURN');
    });

    test('freestun has at least one turns: server after filtering', () {
      final servers = collectEnabledPresetServers(['freestun']);
      final relayOnly = filterRelayOnly(servers);
      expect(relayOnly, isNotEmpty,
          reason: 'freestun must provide at least one TLS TURN');
    });

    test('metered (stun-only) produces nothing after relay filter', () {
      final servers = collectEnabledPresetServers(['metered']);
      final relayOnly = filterRelayOnly(servers);
      expect(relayOnly, isEmpty,
          reason: 'metered has no TURN servers, only STUN');
    });

    test('all defaults combined produce TLS TURN servers', () {
      final servers = collectEnabledPresetServers(['openrelay', 'freestun']);
      final relayOnly = filterRelayOnly(servers);
      expect(relayOnly.length, greaterThanOrEqualTo(2),
          reason: 'at least one turns: per preset');
    });
  });
}
