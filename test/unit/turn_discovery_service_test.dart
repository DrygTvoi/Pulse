import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

// ── Pure logic extracted from TurnDiscoveryService ────────────────────────────
//
// TurnDiscoveryService uses WebSocket and platform I/O internally, so we
// extract the testable decision-making logic and validate it in isolation —
// same pattern as nip65_discovery_test.dart.
//
// Extracted logic mirrors:
//   • turn-tag extraction from kind:10010 events
//   • TURN URL filtering (turn:/turns: only)
//   • ICE server map construction (urls, username, credential)
//   • Cache key format (ts + servers wrapper)
//   • Deduplication by URL

// ── turn-tag extraction ───────────────────────────────────────────────────────

/// Mirrors the inner loop in _queryRelay that parses turn-tags from a
/// kind:10010 event's tags list.
List<Map<String, dynamic>> extractTurnServers(List<dynamic> tags) {
  final servers = <Map<String, dynamic>>[];
  for (final tag in tags) {
    if (tag is! List || tag.length < 2 || tag[0] != 'turn') continue;
    final turnUrl = tag[1] as String? ?? '';
    if (!turnUrl.startsWith('turn:') && !turnUrl.startsWith('turns:')) continue;
    final entry = <String, dynamic>{'urls': turnUrl};
    if (tag.length >= 3) {
      final username = tag[2] as String? ?? '';
      if (username.isNotEmpty) entry['username'] = username;
    }
    if (tag.length >= 4) {
      final credential = tag[3] as String? ?? '';
      if (credential.isNotEmpty) entry['credential'] = credential;
    }
    servers.add(entry);
  }
  return servers;
}

// ── Deduplication ─────────────────────────────────────────────────────────────

/// Mirrors the deduplication in discover(): deduplicate by URL.
List<Map<String, dynamic>> deduplicateTurnServers(
    List<List<Map<String, dynamic>>> results) {
  final seen    = <String>{};
  final servers = <Map<String, dynamic>>[];
  for (final list in results) {
    for (final s in list) {
      final url = s['urls'] as String? ?? '';
      if (url.isNotEmpty && seen.add(url)) {
        servers.add(s);
      }
    }
  }
  return servers;
}

// ── Cache format ──────────────────────────────────────────────────────────────

/// Mirrors the cache write in discover().
String buildCacheEntry(List<Map<String, dynamic>> servers) {
  return jsonEncode({
    'ts':      DateTime.now().toIso8601String(),
    'servers': servers,
  });
}

/// Mirrors the cache read in discover().
({List<Map<String, dynamic>> servers, bool fresh}) parseCacheEntry(
    String raw, int cacheTtlH) {
  try {
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final ts   = DateTime.tryParse(data['ts'] as String? ?? '');
    if (ts != null && DateTime.now().difference(ts).inHours < cacheTtlH) {
      final servers = (data['servers'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      return (servers: servers, fresh: true);
    }
  } catch (_) {}
  return (servers: [], fresh: false);
}

// ── MESSAGE classification ─────────────────────────────────────────────────

/// Mirrors the inner dispatch in _queryRelay for NIP-117.
String classifyNip117Message(String raw) {
  try {
    final msg = jsonDecode(raw) as List;
    if (msg.isEmpty) return 'skip';
    if (msg[0] == 'EOSE') return 'eose';
    if (msg[0] != 'EVENT' || msg.length < 3) return 'skip';
    return 'event';
  } catch (_) {
    return 'skip';
  }
}

// ── Peer TURN merge logic ─────────────────────────────────────────────────────

/// Mirrors IceServerConfig.savePeerTurnServers merging logic.
Map<String, Map<String, dynamic>> mergePeerTurn(
  Map<String, Map<String, dynamic>> existing,
  List<Map<String, dynamic>> newServers,
) {
  final result = Map<String, Map<String, dynamic>>.from(existing);
  for (final s in newServers) {
    final url = s['urls'] as String? ?? '';
    if (url.isNotEmpty &&
        (url.startsWith('turn:') || url.startsWith('turns:'))) {
      result[url] = s;
    }
  }
  return result;
}

/// Trims to at most [maxEntries], keeping the last-added.
List<Map<String, dynamic>> trimTurnList(
    Map<String, Map<String, dynamic>> map, int maxEntries) {
  final list = map.values.toList();
  return list.length > maxEntries ? list.sublist(list.length - maxEntries) : list;
}

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ── turn-tag extraction ─────────────────────────────────────────────────

  group('extractTurnServers: turn-tag parsing', () {
    test('extracts turn: URL from tag', () {
      final tags = [
        ['turn', 'turn:server.example.com:3478', 'user', 'pass'],
      ];
      final result = extractTurnServers(tags);
      expect(result, hasLength(1));
      expect(result.first['urls'], 'turn:server.example.com:3478');
      expect(result.first['username'], 'user');
      expect(result.first['credential'], 'pass');
    });

    test('extracts turns: URL from tag', () {
      final tags = [
        ['turn', 'turns:server.example.com:5349?transport=tcp', 'u', 'p'],
      ];
      final result = extractTurnServers(tags);
      expect(result, hasLength(1));
      expect(result.first['urls'], startsWith('turns:'));
    });

    test('ignores non-turn tags', () {
      final tags = [
        ['r', 'wss://relay.example.com'],
        ['p', 'somepubkey'],
        ['turn', 'turn:valid.example.com:3478', 'u', 'p'],
      ];
      final result = extractTurnServers(tags);
      expect(result, hasLength(1));
    });

    test('ignores tags with non-TURN URL schemes', () {
      final tags = [
        ['turn', 'stun:stun.example.com:3478', 'u', 'p'],
        ['turn', 'https://example.com', 'u', 'p'],
        ['turn', 'turn:valid.example.com:3478', 'u', 'p'],
      ];
      final result = extractTurnServers(tags);
      expect(result, hasLength(1));
      expect(result.first['urls'], 'turn:valid.example.com:3478');
    });

    test('omits username when tag has no username element', () {
      final tags = [
        ['turn', 'turn:server.example.com:3478'],
      ];
      final result = extractTurnServers(tags);
      expect(result, hasLength(1));
      expect(result.first.containsKey('username'), isFalse);
      expect(result.first.containsKey('credential'), isFalse);
    });

    test('omits credential when tag has no credential element', () {
      final tags = [
        ['turn', 'turn:server.example.com:3478', 'myuser'],
      ];
      final result = extractTurnServers(tags);
      expect(result.first['username'], 'myuser');
      expect(result.first.containsKey('credential'), isFalse);
    });

    test('omits empty username', () {
      final tags = [
        ['turn', 'turn:server.example.com:3478', '', 'pass'],
      ];
      final result = extractTurnServers(tags);
      expect(result.first.containsKey('username'), isFalse);
    });

    test('omits empty credential', () {
      final tags = [
        ['turn', 'turn:server.example.com:3478', 'user', ''],
      ];
      final result = extractTurnServers(tags);
      expect(result.first.containsKey('credential'), isFalse);
    });

    test('handles empty tag list', () {
      expect(extractTurnServers([]), isEmpty);
    });

    test('handles non-list elements in tags', () {
      final tags = [
        'not-a-list',
        42,
        ['turn', 'turn:valid.example.com:3478', 'u', 'p'],
      ];
      final result = extractTurnServers(tags);
      expect(result, hasLength(1));
    });

    test('handles null URL in tag', () {
      final tags = [
        ['turn', null, 'u', 'p'],
        ['turn', 'turn:valid.example.com:3478', 'u', 'p'],
      ];
      final result = extractTurnServers(tags);
      expect(result, hasLength(1));
    });

    test('extracts multiple TURN servers from same event', () {
      final tags = [
        ['turn', 'turn:a.example.com:3478', 'u1', 'p1'],
        ['turn', 'turn:b.example.com:3479', 'u2', 'p2'],
        ['turn', 'turns:c.example.com:5349', 'u3', 'p3'],
      ];
      final result = extractTurnServers(tags);
      expect(result, hasLength(3));
    });
  });

  // ── Deduplication ──────────────────────────────────────────────────────

  group('deduplicateTurnServers: URL-based deduplication', () {
    test('deduplicates by URL across multiple relay results', () {
      final results = [
        [
          {'urls': 'turn:a.com:3478', 'username': 'u1', 'credential': 'p1'},
        ],
        [
          {'urls': 'turn:a.com:3478', 'username': 'u1', 'credential': 'p1'},
          {'urls': 'turn:b.com:3479', 'username': 'u2', 'credential': 'p2'},
        ],
      ];
      final result = deduplicateTurnServers(results);
      expect(result, hasLength(2));
      final urls = result.map((s) => s['urls']).toSet();
      expect(urls, {'turn:a.com:3478', 'turn:b.com:3479'});
    });

    test('empty results produce empty list', () {
      expect(deduplicateTurnServers([]), isEmpty);
    });

    test('empty sub-lists produce empty list', () {
      expect(deduplicateTurnServers([[], []]), isEmpty);
    });

    test('keeps first occurrence when duplicated', () {
      final results = [
        [
          {'urls': 'turn:a.com:3478', 'username': 'first', 'credential': 'p'},
        ],
        [
          {'urls': 'turn:a.com:3478', 'username': 'second', 'credential': 'p'},
        ],
      ];
      final result = deduplicateTurnServers(results);
      expect(result, hasLength(1));
      expect(result.first['username'], 'first');
    });
  });

  // ── Cache format ──────────────────────────────────────────────────────

  group('cache format: read/write', () {
    test('buildCacheEntry produces valid JSON with ts and servers', () {
      final servers = [
        {'urls': 'turn:a.com:3478', 'username': 'u', 'credential': 'p'},
      ];
      final raw  = buildCacheEntry(servers);
      final data = jsonDecode(raw) as Map<String, dynamic>;
      expect(data.containsKey('ts'), isTrue);
      expect(data['servers'], isA<List>());
      expect((data['servers'] as List), hasLength(1));
    });

    test('parseCacheEntry returns fresh=true for recent timestamp', () {
      final servers = [
        {'urls': 'turn:a.com:3478', 'username': 'u', 'credential': 'p'},
      ];
      final raw    = buildCacheEntry(servers);
      final result = parseCacheEntry(raw, 6);
      expect(result.fresh, isTrue);
      expect(result.servers, hasLength(1));
    });

    test('parseCacheEntry returns fresh=false for expired timestamp', () {
      final old = jsonEncode({
        'ts':      DateTime.now()
            .subtract(const Duration(hours: 7))
            .toIso8601String(),
        'servers': <dynamic>[],
      });
      final result = parseCacheEntry(old, 6);
      expect(result.fresh, isFalse);
    });

    test('parseCacheEntry returns empty servers for invalid JSON', () {
      final result = parseCacheEntry('not json', 6);
      expect(result.fresh, isFalse);
      expect(result.servers, isEmpty);
    });
  });

  // ── Message classification ────────────────────────────────────────────

  group('classifyNip117Message: dispatch', () {
    test('identifies EVENT messages', () {
      final raw = jsonEncode(['EVENT', 'sub1', {'id': 'abc', 'tags': []}]);
      expect(classifyNip117Message(raw), 'event');
    });

    test('identifies EOSE messages', () {
      expect(classifyNip117Message(jsonEncode(['EOSE', 'sub1'])), 'eose');
    });

    test('skips NOTICE messages', () {
      expect(classifyNip117Message(jsonEncode(['NOTICE', 'msg'])), 'skip');
    });

    test('skips malformed JSON', () {
      expect(classifyNip117Message('not json'), 'skip');
    });

    test('skips EVENT with too few elements', () {
      expect(classifyNip117Message(jsonEncode(['EVENT', 'sub1'])), 'skip');
    });
  });

  // ── Peer TURN merge ───────────────────────────────────────────────────

  group('mergePeerTurn: merge + deduplicate', () {
    test('adds new entries keyed by URL', () {
      final result = mergePeerTurn({}, [
        {'urls': 'turn:a.com:3478', 'username': 'u', 'credential': 'p'},
      ]);
      expect(result, hasLength(1));
      expect(result.containsKey('turn:a.com:3478'), isTrue);
    });

    test('overwrites existing entry with same URL', () {
      final existing = <String, Map<String, dynamic>>{
        'turn:a.com:3478': {'urls': 'turn:a.com:3478', 'username': 'old'},
      };
      final result = mergePeerTurn(existing, [
        {'urls': 'turn:a.com:3478', 'username': 'new'},
      ]);
      expect(result['turn:a.com:3478']!['username'], 'new');
    });

    test('ignores STUN entries (stun: scheme)', () {
      final result = mergePeerTurn({}, [
        {'urls': 'stun:stun.example.com:3478'},
      ]);
      expect(result, isEmpty);
    });

    test('ignores entries with empty URL', () {
      final result = mergePeerTurn({}, [
        {'urls': ''},
      ]);
      expect(result, isEmpty);
    });

    test('accepts turns: scheme', () {
      final result = mergePeerTurn({}, [
        {'urls': 'turns:a.com:5349', 'username': 'u', 'credential': 'p'},
      ]);
      expect(result, hasLength(1));
    });

    test('trimTurnList caps at maxEntries', () {
      final map = <String, Map<String, dynamic>>{};
      for (var i = 0; i < 25; i++) {
        map['turn:server$i.com:3478'] = {'urls': 'turn:server$i.com:3478'};
      }
      final trimmed = trimTurnList(map, 20);
      expect(trimmed, hasLength(20));
    });

    test('trimTurnList leaves short list intact', () {
      final map = {
        'turn:a.com:3478': {'urls': 'turn:a.com:3478'},
        'turn:b.com:3479': {'urls': 'turn:b.com:3479'},
      };
      final trimmed = trimTurnList(map, 20);
      expect(trimmed, hasLength(2));
    });
  });

  // ── Integration: full EVENT → TURN servers pipeline ───────────────────

  group('end-to-end: kind:10010 EVENT → TURN server list', () {
    test('complete pipeline from raw EVENT to ICE server entries', () {
      final event = {
        'id':         'abc123',
        'kind':       10010,
        'pubkey':     'deadbeef',
        'created_at': 1700000000,
        'tags': [
          ['turn', 'turn:relay.example.com:3478',     'myuser', 'mysecret'],
          ['turn', 'turns:relay.example.com:5349',    'myuser', 'mysecret'],
          ['r',    'wss://relay.example.com'],  // should be ignored
          ['p',    'somepubkey'],               // should be ignored
        ],
        'content': '',
        'sig':     'cafebabe',
      };
      final raw = jsonEncode(['EVENT', 'nip117', event]);

      // Step 1: classify
      expect(classifyNip117Message(raw), 'event');

      // Step 2: parse event tags
      final msg  = jsonDecode(raw) as List;
      final tags = (msg[2] as Map<String, dynamic>)['tags'] as List;

      // Step 3: extract TURN servers
      final servers = extractTurnServers(tags);
      expect(servers, hasLength(2));
      expect(servers.map((s) => s['urls']).toList(),
          containsAll(['turn:relay.example.com:3478', 'turns:relay.example.com:5349']));

      // Step 4: verify credentials preserved
      for (final s in servers) {
        expect(s['username'],   'myuser');
        expect(s['credential'], 'mysecret');
      }
    });

    test('EOSE terminates processing', () {
      final eose = jsonEncode(['EOSE', 'nip117']);
      expect(classifyNip117Message(eose), 'eose');
    });

    test('event with no turn tags yields empty list', () {
      final event = {
        'id': 'xyz', 'kind': 10010, 'pubkey': 'abc',
        'tags': [['r', 'wss://relay.example.com']],
        'content': '', 'sig': 'sig',
      };
      final tags = event['tags'] as List;
      expect(extractTurnServers(tags), isEmpty);
    });
  });
}
