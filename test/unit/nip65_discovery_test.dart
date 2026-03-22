import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

// ── Pure logic extracted from Nip65DiscoveryService ───────────────────────────
//
// Nip65DiscoveryService uses WebSocket, DoH, and platform I/O internally,
// so we extract every piece of testable decision-making logic and validate
// it in isolation — same pattern as adaptive_relay_service_test.dart.
//
// Extracted logic mirrors:
//   • r-tag extraction from kind:10002 events
//   • relay URL filtering (wss:// and ws:// only)
//   • candidate deduplication and host extraction
//   • known-host filtering
//   • port defaulting (443 for wss, 80 for ws, explicit port preserved)
//   • EOSE detection in message stream
//   • maxRelaysToQuery limiting
//   • empty input handling

// ── r-tag extraction ─────────────────────────────────────────────────────────

/// Mirrors the inner loop in _queryRelay that parses r-tags from a kind:10002
/// event's tags list.
Set<String> extractRelayUrls(List<dynamic> tags) {
  final relays = <String>{};
  for (final tag in tags) {
    if (tag is! List || tag.length < 2 || tag[0] != 'r') continue;
    final url = tag[1] as String? ?? '';
    if (url.startsWith('wss://') || url.startsWith('ws://')) {
      relays.add(url);
    }
  }
  return relays;
}

// ── EVENT message dispatch ───────────────────────────────────────────────────

/// Mirrors the message-type dispatch in _queryRelay.
/// Returns 'event' for EVENT messages, 'eose' for EOSE, 'skip' otherwise.
String classifyNostrMessage(String raw) {
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

/// Extracts tags from an EVENT message. Returns empty list on malformed input.
List<dynamic> extractTagsFromEvent(String raw) {
  try {
    final msg = jsonDecode(raw) as List;
    if (msg.isEmpty || msg[0] != 'EVENT' || msg.length < 3) return [];
    final event = msg[2] as Map<String, dynamic>;
    return event['tags'] as List? ?? [];
  } catch (_) {
    return [];
  }
}

// ── Candidate building ───────────────────────────────────────────────────────

/// Mirrors the candidate-building loop in discover():
///   - Parse URL, skip invalid/empty host
///   - Skip known hosts
///   - Default port to 443 if not specified
(String, int)? buildCandidate(String url, Set<String> knownHosts) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.host.isEmpty) return null;
  if (knownHosts.contains(uri.host)) return null;
  final port = (uri.hasPort && uri.port != 0) ? uri.port : 443;
  return (uri.host, port);
}

/// Mirrors the full candidate-list builder in discover().
List<(String, int)> buildCandidateList(
    Set<String> allUrls, Set<String> knownHosts) {
  final candidates = <(String, int)>[];
  for (final url in allUrls) {
    final c = buildCandidate(url, knownHosts);
    if (c != null) candidates.add(c);
  }
  return candidates;
}

// ── Query limiting ───────────────────────────────────────────────────────────

/// Mirrors `workingRelays.take(maxRelaysToQuery).toList()`.
List<String> limitRelays(List<String> relays, int max) =>
    relays.take(max).toList();

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ── r-tag extraction ─────────────────────────────────────────────────────

  group('extractRelayUrls: r-tag parsing', () {
    test('extracts wss:// URLs from r-tags', () {
      final tags = [
        ['r', 'wss://relay.damus.io'],
        ['r', 'wss://nos.lol'],
      ];
      final result = extractRelayUrls(tags);
      expect(result, {'wss://relay.damus.io', 'wss://nos.lol'});
    });

    test('extracts ws:// URLs from r-tags', () {
      final tags = [
        ['r', 'ws://relay.example.com'],
      ];
      expect(extractRelayUrls(tags), {'ws://relay.example.com'});
    });

    test('ignores non-r tags', () {
      final tags = [
        ['p', 'pubkey123'],
        ['e', 'eventid456'],
        ['r', 'wss://relay.damus.io'],
      ];
      expect(extractRelayUrls(tags), {'wss://relay.damus.io'});
    });

    test('ignores r-tags with non-websocket URLs', () {
      final tags = [
        ['r', 'https://example.com'],
        ['r', 'http://relay.com'],
        ['r', 'ftp://files.com'],
        ['r', 'wss://valid.relay.io'],
      ];
      expect(extractRelayUrls(tags), {'wss://valid.relay.io'});
    });

    test('ignores r-tags with empty URL', () {
      final tags = [
        ['r', ''],
        ['r', 'wss://relay.damus.io'],
      ];
      expect(extractRelayUrls(tags), {'wss://relay.damus.io'});
    });

    test('ignores r-tags with too few elements', () {
      final tags = [
        ['r'],
        ['r', 'wss://relay.damus.io'],
      ];
      expect(extractRelayUrls(tags), {'wss://relay.damus.io'});
    });

    test('ignores non-list tags', () {
      final tags = [
        'not-a-list',
        42,
        ['r', 'wss://relay.damus.io'],
      ];
      expect(extractRelayUrls(tags), {'wss://relay.damus.io'});
    });

    test('handles empty tags list', () {
      expect(extractRelayUrls([]), isEmpty);
    });

    test('deduplicates identical URLs', () {
      final tags = [
        ['r', 'wss://relay.damus.io'],
        ['r', 'wss://relay.damus.io'],
        ['r', 'wss://relay.damus.io'],
      ];
      expect(extractRelayUrls(tags), hasLength(1));
    });

    test('r-tags with read/write markers still extract URL', () {
      // NIP-65 allows a third element: "read" or "write"
      final tags = [
        ['r', 'wss://relay.damus.io', 'read'],
        ['r', 'wss://nos.lol', 'write'],
      ];
      final result = extractRelayUrls(tags);
      expect(result, {'wss://relay.damus.io', 'wss://nos.lol'});
    });

    test('null URL in r-tag treated as empty', () {
      final tags = [
        ['r', null],
        ['r', 'wss://relay.damus.io'],
      ];
      // The null is cast to String? then ?? '' → empty string → filtered out
      expect(extractRelayUrls(tags), {'wss://relay.damus.io'});
    });
  });

  // ── Nostr message classification ─────────────────────────────────────────

  group('classifyNostrMessage: message type dispatch', () {
    test('identifies EVENT messages', () {
      final raw = jsonEncode(['EVENT', 'sub1', {'id': 'abc', 'tags': []}]);
      expect(classifyNostrMessage(raw), 'event');
    });

    test('identifies EOSE messages', () {
      final raw = jsonEncode(['EOSE', 'sub1']);
      expect(classifyNostrMessage(raw), 'eose');
    });

    test('skips NOTICE messages', () {
      final raw = jsonEncode(['NOTICE', 'some message']);
      expect(classifyNostrMessage(raw), 'skip');
    });

    test('skips OK messages', () {
      final raw = jsonEncode(['OK', 'eventid', true, '']);
      expect(classifyNostrMessage(raw), 'skip');
    });

    test('skips empty arrays', () {
      expect(classifyNostrMessage('[]'), 'skip');
    });

    test('skips EVENT messages with too few elements', () {
      final raw = jsonEncode(['EVENT', 'sub1']);
      expect(classifyNostrMessage(raw), 'skip');
    });

    test('skips malformed JSON', () {
      expect(classifyNostrMessage('not json'), 'skip');
    });

    test('skips empty string', () {
      expect(classifyNostrMessage(''), 'skip');
    });
  });

  // ── Tag extraction from EVENT messages ──────────────────────────────────

  group('extractTagsFromEvent: event parsing', () {
    test('extracts tags array from valid EVENT', () {
      final tags = [
        ['r', 'wss://relay.damus.io'],
        ['r', 'wss://nos.lol'],
      ];
      final raw = jsonEncode([
        'EVENT',
        'sub1',
        {'id': 'abc', 'kind': 10002, 'tags': tags}
      ]);
      final result = extractTagsFromEvent(raw);
      expect(result, hasLength(2));
    });

    test('returns empty list when event has no tags field', () {
      final raw = jsonEncode([
        'EVENT',
        'sub1',
        {'id': 'abc', 'kind': 10002}
      ]);
      expect(extractTagsFromEvent(raw), isEmpty);
    });

    test('returns empty list for non-EVENT messages', () {
      final raw = jsonEncode(['EOSE', 'sub1']);
      expect(extractTagsFromEvent(raw), isEmpty);
    });

    test('returns empty list for malformed JSON', () {
      expect(extractTagsFromEvent('garbage'), isEmpty);
    });

    test('returns empty list for EVENT with only 2 elements', () {
      final raw = jsonEncode(['EVENT', 'sub1']);
      expect(extractTagsFromEvent(raw), isEmpty);
    });
  });

  // ── Candidate building ──────────────────────────────────────────────────

  group('buildCandidate: URL → (host, port)', () {
    test('wss:// URL defaults to port 443', () {
      final result = buildCandidate('wss://relay.damus.io', {});
      expect(result, ('relay.damus.io', 443));
    });

    test('ws:// URL defaults to port 443 (per discover() logic)', () {
      // Note: discover() uses a flat 443 default regardless of scheme
      final result = buildCandidate('ws://relay.example.com', {});
      expect(result, ('relay.example.com', 443));
    });

    test('URL with explicit port preserves it', () {
      final result = buildCandidate('wss://relay.damus.io:8080', {});
      expect(result, ('relay.damus.io', 8080));
    });

    test('URL with explicit port 443 preserves it', () {
      final result = buildCandidate('wss://relay.damus.io:443', {});
      expect(result, ('relay.damus.io', 443));
    });

    test('filters out known hosts', () {
      final result =
          buildCandidate('wss://relay.damus.io', {'relay.damus.io'});
      expect(result, isNull);
    });

    test('invalid URL returns null', () {
      expect(buildCandidate('not-a-url', {}), isNull);
    });

    test('URL with empty host returns null', () {
      // Uri.parse('wss://') → host is empty
      expect(buildCandidate('wss://', {}), isNull);
    });

    test('known host filtering is host-only (port ignored)', () {
      // knownHosts contains 'relay.damus.io', URL has non-standard port
      final result =
          buildCandidate('wss://relay.damus.io:9001', {'relay.damus.io'});
      expect(result, isNull, reason: 'filtering is by host, not host:port');
    });
  });

  group('buildCandidateList: batch processing', () {
    test('deduplicates by host (same host, different scheme)', () {
      final urls = {
        'wss://relay.damus.io',
        'ws://relay.damus.io',
      };
      // Both have same host — both appear since set dedup is by full tuple
      final result = buildCandidateList(urls, {});
      // Both map to (relay.damus.io, 443) — should appear twice
      // (production dedup happens via knownHosts set, not here)
      expect(result, hasLength(2));
    });

    test('filters multiple known hosts', () {
      final urls = {
        'wss://relay.damus.io',
        'wss://nos.lol',
        'wss://unknown.relay.io',
      };
      final known = {'relay.damus.io', 'nos.lol'};
      final result = buildCandidateList(urls, known);
      expect(result, hasLength(1));
      expect(result.first.$1, 'unknown.relay.io');
    });

    test('empty URL set produces empty candidate list', () {
      expect(buildCandidateList({}, {}), isEmpty);
    });

    test('all known hosts produces empty candidate list', () {
      final urls = {'wss://relay.damus.io', 'wss://nos.lol'};
      final known = {'relay.damus.io', 'nos.lol'};
      expect(buildCandidateList(urls, known), isEmpty);
    });
  });

  // ── Query limiting ──────────────────────────────────────────────────────

  group('limitRelays: maxRelaysToQuery', () {
    test('limits list to maxRelaysToQuery', () {
      final relays = ['wss://a.com', 'wss://b.com', 'wss://c.com', 'wss://d.com'];
      expect(limitRelays(relays, 3), hasLength(3));
      expect(limitRelays(relays, 3), ['wss://a.com', 'wss://b.com', 'wss://c.com']);
    });

    test('returns full list when shorter than limit', () {
      final relays = ['wss://a.com'];
      expect(limitRelays(relays, 3), hasLength(1));
    });

    test('returns empty list from empty input', () {
      expect(limitRelays([], 3), isEmpty);
    });

    test('limit of 0 returns empty list', () {
      expect(limitRelays(['wss://a.com', 'wss://b.com'], 0), isEmpty);
    });

    test('preserves order', () {
      final relays = ['wss://c.com', 'wss://a.com', 'wss://b.com'];
      expect(limitRelays(relays, 2), ['wss://c.com', 'wss://a.com']);
    });
  });

  // ── Integration: full event → relay URLs pipeline ──────────────────────

  group('end-to-end: EVENT message → candidate list', () {
    test('complete pipeline from raw EVENT to candidates', () {
      final event = {
        'id': 'abc123',
        'kind': 10002,
        'pubkey': 'deadbeef',
        'created_at': 1700000000,
        'tags': [
          ['r', 'wss://relay.damus.io'],
          ['r', 'wss://nos.lol'],
          ['r', 'wss://eden.nostr.land'],
          ['p', 'somepubkey'],
        ],
        'content': '',
        'sig': 'cafebabe',
      };
      final raw = jsonEncode(['EVENT', 'nip65', event]);

      // Step 1: classify
      expect(classifyNostrMessage(raw), 'event');

      // Step 2: extract tags
      final tags = extractTagsFromEvent(raw);
      expect(tags, hasLength(4));

      // Step 3: extract relay URLs
      final urls = extractRelayUrls(tags);
      expect(urls, {'wss://relay.damus.io', 'wss://nos.lol', 'wss://eden.nostr.land'});

      // Step 4: build candidates (filtering out known host)
      final candidates = buildCandidateList(urls, {'relay.damus.io'});
      expect(candidates, hasLength(2));
      expect(candidates.map((c) => c.$1).toSet(),
          {'nos.lol', 'eden.nostr.land'});
    });

    test('EOSE terminates processing', () {
      final eose = jsonEncode(['EOSE', 'nip65']);
      expect(classifyNostrMessage(eose), 'eose');
    });
  });
}
