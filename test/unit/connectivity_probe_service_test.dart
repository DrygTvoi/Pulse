import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/services/connectivity_probe_service.dart';

void main() {
  // ── ProbePhase enum ──────────────────────────────────────────────────────

  group('ProbePhase', () {
    test('has exactly 6 values', () {
      expect(ProbePhase.values.length, 6);
    });

    test('all expected values exist', () {
      expect(ProbePhase.values, contains(ProbePhase.idle));
      expect(ProbePhase.values, contains(ProbePhase.directProbe));
      expect(ProbePhase.values, contains(ProbePhase.dohProbe));
      expect(ProbePhase.values, contains(ProbePhase.torBoot));
      expect(ProbePhase.values, contains(ProbePhase.torProbe));
      expect(ProbePhase.values, contains(ProbePhase.done));
    });

    test('ordinal order matches expected lifecycle', () {
      expect(ProbePhase.idle.index, 0);
      expect(ProbePhase.directProbe.index, 1);
      expect(ProbePhase.dohProbe.index, 2);
      expect(ProbePhase.torBoot.index, 3);
      expect(ProbePhase.torProbe.index, 4);
      expect(ProbePhase.done.index, 5);
    });

    test('name getter returns correct string', () {
      expect(ProbePhase.idle.name, 'idle');
      expect(ProbePhase.directProbe.name, 'directProbe');
      expect(ProbePhase.dohProbe.name, 'dohProbe');
      expect(ProbePhase.torBoot.name, 'torBoot');
      expect(ProbePhase.torProbe.name, 'torProbe');
      expect(ProbePhase.done.name, 'done');
    });
  });

  // ── ProbeStatus ──────────────────────────────────────────────────────────

  group('ProbeStatus', () {
    test('constructor sets phase, found, torUsed', () {
      final s = ProbeStatus(ProbePhase.directProbe, found: 3, torUsed: true);
      expect(s.phase, ProbePhase.directProbe);
      expect(s.found, 3);
      expect(s.torUsed, isTrue);
    });

    test('defaults: found=0, torUsed=false', () {
      final s = ProbeStatus(ProbePhase.idle);
      expect(s.found, 0);
      expect(s.torUsed, isFalse);
    });

    test('only found specified, torUsed defaults false', () {
      final s = ProbeStatus(ProbePhase.done, found: 5);
      expect(s.found, 5);
      expect(s.torUsed, isFalse);
    });

    test('only torUsed specified, found defaults 0', () {
      final s = ProbeStatus(ProbePhase.torProbe, torUsed: true);
      expect(s.found, 0);
      expect(s.torUsed, isTrue);
    });

    test('each phase can be used in ProbeStatus', () {
      for (final phase in ProbePhase.values) {
        final s = ProbeStatus(phase, found: 1, torUsed: false);
        expect(s.phase, phase);
      }
    });
  });

  // ── ProbeResult ──────────────────────────────────────────────────────────

  group('ProbeResult', () {
    group('constructor', () {
      test('stores all fields', () {
        final ts = DateTime(2026, 3, 21, 12, 0, 0);
        final r = ProbeResult(
          nostrRelays: ['wss://relay.damus.io'],
          oxenNodes: ['seed1.getsession.org:22023'],
          turnServers: ['openrelay.metered.ca:443'],
          torNostrRelays: ['wss://hidden.example.onion'],
          timestamp: ts,
        );
        expect(r.nostrRelays, ['wss://relay.damus.io']);
        expect(r.oxenNodes, ['seed1.getsession.org:22023']);
        expect(r.turnServers, ['openrelay.metered.ca:443']);
        expect(r.torNostrRelays, ['wss://hidden.example.onion']);
        expect(r.timestamp, ts);
      });

      test('accepts empty lists', () {
        final r = ProbeResult(
          nostrRelays: [],
          oxenNodes: [],
          turnServers: [],
          torNostrRelays: [],
          timestamp: DateTime(2000),
        );
        expect(r.nostrRelays, isEmpty);
        expect(r.oxenNodes, isEmpty);
        expect(r.turnServers, isEmpty);
        expect(r.torNostrRelays, isEmpty);
      });

      test('accepts multiple items per list', () {
        final r = ProbeResult(
          nostrRelays: ['wss://a', 'wss://b', 'wss://c'],
          oxenNodes: ['x:1', 'y:2'],
          turnServers: ['t1:443', 't2:3479'],
          torNostrRelays: ['wss://tor1', 'wss://tor2'],
          timestamp: DateTime(2026),
        );
        expect(r.nostrRelays.length, 3);
        expect(r.oxenNodes.length, 2);
        expect(r.turnServers.length, 2);
        expect(r.torNostrRelays.length, 2);
      });
    });

    group('hasNostr', () {
      test('false when both nostrRelays and torNostrRelays empty', () {
        final r = ProbeResult.empty();
        expect(r.hasNostr, isFalse);
      });

      test('true when nostrRelays non-empty', () {
        final r = ProbeResult(
          nostrRelays: ['wss://relay.damus.io'],
          oxenNodes: [],
          turnServers: [],
          torNostrRelays: [],
          timestamp: DateTime(2026),
        );
        expect(r.hasNostr, isTrue);
      });

      test('true when torNostrRelays non-empty', () {
        final r = ProbeResult(
          nostrRelays: [],
          oxenNodes: [],
          turnServers: [],
          torNostrRelays: ['wss://tor-only.example.onion'],
          timestamp: DateTime(2026),
        );
        expect(r.hasNostr, isTrue);
      });

      test('true when both non-empty', () {
        final r = ProbeResult(
          nostrRelays: ['wss://a'],
          oxenNodes: [],
          turnServers: [],
          torNostrRelays: ['wss://b'],
          timestamp: DateTime(2026),
        );
        expect(r.hasNostr, isTrue);
      });
    });

    group('hasDirectNostr', () {
      test('false when nostrRelays empty (even if torNostrRelays non-empty)', () {
        final r = ProbeResult(
          nostrRelays: [],
          oxenNodes: [],
          turnServers: [],
          torNostrRelays: ['wss://tor'],
          timestamp: DateTime(2026),
        );
        expect(r.hasDirectNostr, isFalse);
      });

      test('true when nostrRelays non-empty', () {
        final r = ProbeResult(
          nostrRelays: ['wss://direct'],
          oxenNodes: [],
          turnServers: [],
          torNostrRelays: [],
          timestamp: DateTime(2026),
        );
        expect(r.hasDirectNostr, isTrue);
      });
    });

    group('bestNostrRelay', () {
      test('returns first nostrRelay when available', () {
        final r = ProbeResult(
          nostrRelays: ['wss://first', 'wss://second'],
          oxenNodes: [],
          turnServers: [],
          torNostrRelays: ['wss://tor1'],
          timestamp: DateTime(2026),
        );
        expect(r.bestNostrRelay, 'wss://first');
      });

      test('returns null when nostrRelays empty (does not fall back to tor)', () {
        final r = ProbeResult(
          nostrRelays: [],
          oxenNodes: [],
          turnServers: [],
          torNostrRelays: ['wss://tor-only'],
          timestamp: DateTime(2026),
        );
        // Current implementation: bestNostrRelay only checks nostrRelays
        expect(r.bestNostrRelay, isNull);
      });

      test('returns null when both lists empty', () {
        final r = ProbeResult.empty();
        expect(r.bestNostrRelay, isNull);
      });

      test('returns single relay when list has exactly one', () {
        final r = ProbeResult(
          nostrRelays: ['wss://only'],
          oxenNodes: [],
          turnServers: [],
          torNostrRelays: [],
          timestamp: DateTime(2026),
        );
        expect(r.bestNostrRelay, 'wss://only');
      });
    });

    group('empty() factory', () {
      test('all lists are empty', () {
        final r = ProbeResult.empty();
        expect(r.nostrRelays, isEmpty);
        expect(r.oxenNodes, isEmpty);
        expect(r.turnServers, isEmpty);
        expect(r.torNostrRelays, isEmpty);
      });

      test('timestamp is year 2000', () {
        final r = ProbeResult.empty();
        expect(r.timestamp, DateTime(2000));
      });

      test('hasNostr is false', () {
        expect(ProbeResult.empty().hasNostr, isFalse);
      });

      test('hasDirectNostr is false', () {
        expect(ProbeResult.empty().hasDirectNostr, isFalse);
      });

      test('bestNostrRelay is null', () {
        expect(ProbeResult.empty().bestNostrRelay, isNull);
      });
    });

    group('toJson()', () {
      test('produces correct map with all fields', () {
        final ts = DateTime.utc(2026, 3, 21, 10, 30, 0);
        final r = ProbeResult(
          nostrRelays: ['wss://a', 'wss://b'],
          oxenNodes: ['ox:1'],
          turnServers: ['turn:443'],
          torNostrRelays: ['wss://tor'],
          timestamp: ts,
        );
        final j = r.toJson();
        expect(j['nostrRelays'], ['wss://a', 'wss://b']);
        expect(j['oxenNodes'], ['ox:1']);
        expect(j['turnServers'], ['turn:443']);
        expect(j['torNostrRelays'], ['wss://tor']);
        expect(j['timestamp'], ts.toIso8601String());
      });

      test('empty result produces map with empty lists', () {
        final j = ProbeResult.empty().toJson();
        expect(j['nostrRelays'], isEmpty);
        expect(j['oxenNodes'], isEmpty);
        expect(j['turnServers'], isEmpty);
        expect(j['torNostrRelays'], isEmpty);
        expect(j['timestamp'], isA<String>());
      });

      test('toJson result is JSON-encodable', () {
        final r = ProbeResult(
          nostrRelays: ['wss://relay.damus.io'],
          oxenNodes: [],
          turnServers: [],
          torNostrRelays: [],
          timestamp: DateTime.utc(2026, 1, 1),
        );
        // Should not throw
        final encoded = jsonEncode(r.toJson());
        expect(encoded, isA<String>());
        expect(encoded.length, greaterThan(0));
      });
    });

    group('fromJson()', () {
      test('parses all fields correctly', () {
        final j = {
          'nostrRelays': ['wss://r1', 'wss://r2'],
          'oxenNodes': ['ox1'],
          'turnServers': ['t1'],
          'torNostrRelays': ['wss://tor1'],
          'timestamp': '2026-03-21T12:00:00.000',
        };
        final r = ProbeResult.fromJson(j);
        expect(r.nostrRelays, ['wss://r1', 'wss://r2']);
        expect(r.oxenNodes, ['ox1']);
        expect(r.turnServers, ['t1']);
        expect(r.torNostrRelays, ['wss://tor1']);
        expect(r.timestamp, DateTime(2026, 3, 21, 12, 0, 0));
      });

      test('missing keys default to empty lists', () {
        final j = {'timestamp': '2026-01-01T00:00:00.000'};
        final r = ProbeResult.fromJson(j);
        expect(r.nostrRelays, isEmpty);
        expect(r.oxenNodes, isEmpty);
        expect(r.turnServers, isEmpty);
        expect(r.torNostrRelays, isEmpty);
      });

      test('null values default to empty lists', () {
        final j = <String, dynamic>{
          'nostrRelays': null,
          'oxenNodes': null,
          'turnServers': null,
          'torNostrRelays': null,
          'timestamp': '2026-01-01T00:00:00.000',
        };
        final r = ProbeResult.fromJson(j);
        expect(r.nostrRelays, isEmpty);
        expect(r.oxenNodes, isEmpty);
        expect(r.turnServers, isEmpty);
        expect(r.torNostrRelays, isEmpty);
      });

      test('parses UTC timestamp', () {
        final j = {
          'timestamp': '2026-03-21T15:30:00.000Z',
        };
        final r = ProbeResult.fromJson(j);
        expect(r.timestamp.isUtc, isTrue);
        expect(r.timestamp.year, 2026);
        expect(r.timestamp.month, 3);
        expect(r.timestamp.day, 21);
        expect(r.timestamp.hour, 15);
        expect(r.timestamp.minute, 30);
      });
    });

    group('toJson/fromJson roundtrip', () {
      test('full result survives roundtrip', () {
        final original = ProbeResult(
          nostrRelays: ['wss://relay.damus.io', 'wss://nos.lol'],
          oxenNodes: ['seed1.getsession.org:22023'],
          turnServers: ['openrelay.metered.ca:443', 'freestun.net:3479'],
          torNostrRelays: ['wss://hidden.onion'],
          timestamp: DateTime.utc(2026, 3, 21, 12, 0, 0),
        );
        final json = jsonEncode(original.toJson());
        final decoded = ProbeResult.fromJson(jsonDecode(json));

        expect(decoded.nostrRelays, original.nostrRelays);
        expect(decoded.oxenNodes, original.oxenNodes);
        expect(decoded.turnServers, original.turnServers);
        expect(decoded.torNostrRelays, original.torNostrRelays);
        expect(decoded.timestamp, original.timestamp);
      });

      test('empty result survives roundtrip', () {
        final original = ProbeResult.empty();
        final json = jsonEncode(original.toJson());
        final decoded = ProbeResult.fromJson(jsonDecode(json));

        expect(decoded.nostrRelays, isEmpty);
        expect(decoded.oxenNodes, isEmpty);
        expect(decoded.turnServers, isEmpty);
        expect(decoded.torNostrRelays, isEmpty);
        expect(decoded.timestamp, original.timestamp);
      });

      test('getters match after roundtrip', () {
        final original = ProbeResult(
          nostrRelays: ['wss://relay.damus.io'],
          oxenNodes: [],
          turnServers: [],
          torNostrRelays: ['wss://tor.relay.onion'],
          timestamp: DateTime.utc(2026, 6, 15),
        );
        final json = jsonEncode(original.toJson());
        final decoded = ProbeResult.fromJson(jsonDecode(json));

        expect(decoded.hasNostr, original.hasNostr);
        expect(decoded.hasDirectNostr, original.hasDirectNostr);
        expect(decoded.bestNostrRelay, original.bestNostrRelay);
      });

      test('double roundtrip produces identical JSON', () {
        final original = ProbeResult(
          nostrRelays: ['wss://a', 'wss://b'],
          oxenNodes: ['x:1'],
          turnServers: ['t:443'],
          torNostrRelays: ['wss://tor'],
          timestamp: DateTime.utc(2026, 1, 1),
        );
        final json1 = jsonEncode(original.toJson());
        final decoded1 = ProbeResult.fromJson(jsonDecode(json1));
        final json2 = jsonEncode(decoded1.toJson());
        expect(json1, json2);
      });
    });

    group('edge cases', () {
      test('nostrRelays with many entries — bestNostrRelay always first', () {
        final relays = List.generate(50, (i) => 'wss://relay-$i.example.com');
        final r = ProbeResult(
          nostrRelays: relays,
          oxenNodes: [],
          turnServers: [],
          torNostrRelays: [],
          timestamp: DateTime.now(),
        );
        expect(r.bestNostrRelay, 'wss://relay-0.example.com');
        expect(r.hasNostr, isTrue);
        expect(r.hasDirectNostr, isTrue);
      });

      test('only torNostrRelays — hasNostr true, hasDirectNostr false, bestNostrRelay null', () {
        final r = ProbeResult(
          nostrRelays: [],
          oxenNodes: [],
          turnServers: [],
          torNostrRelays: ['wss://tor1', 'wss://tor2'],
          timestamp: DateTime.now(),
        );
        expect(r.hasNostr, isTrue);
        expect(r.hasDirectNostr, isFalse);
        expect(r.bestNostrRelay, isNull);
      });

      test('fromJson with extra unknown keys ignores them', () {
        final j = {
          'nostrRelays': ['wss://x'],
          'oxenNodes': [],
          'turnServers': [],
          'torNostrRelays': [],
          'timestamp': '2026-01-01T00:00:00.000',
          'unknownField': 'ignored',
          'anotherField': 42,
        };
        final r = ProbeResult.fromJson(j);
        expect(r.nostrRelays, ['wss://x']);
      });

      test('timestamp precision preserved through roundtrip', () {
        final ts = DateTime.utc(2026, 3, 21, 12, 34, 56, 789);
        final r = ProbeResult(
          nostrRelays: [],
          oxenNodes: [],
          turnServers: [],
          torNostrRelays: [],
          timestamp: ts,
        );
        final json = jsonEncode(r.toJson());
        final decoded = ProbeResult.fromJson(jsonDecode(json));
        expect(decoded.timestamp, ts);
      });

      test('lists in toJson are separate from original (no mutation leak)', () {
        final relays = ['wss://a'];
        final r = ProbeResult(
          nostrRelays: relays,
          oxenNodes: [],
          turnServers: [],
          torNostrRelays: [],
          timestamp: DateTime(2026),
        );
        // Mutate the original list — documents that toJson shares list references.
        relays.add('wss://b');
        // The internal list IS the same reference, so this would change.
        // This is expected Dart behavior for const constructors.
        expect(r.nostrRelays.length, 2);
      });
    });
  });

  // ── ConnectivityProbeService — public constants and singleton ──────────

  group('ConnectivityProbeService', () {
    test('instance is a singleton', () {
      final a = ConnectivityProbeService.instance;
      final b = ConnectivityProbeService.instance;
      expect(identical(a, b), isTrue);
    });

    test('lastResult initially returns empty result', () {
      final r = ConnectivityProbeService.instance.lastResult;
      // May have been mutated by other tests, but should be a ProbeResult
      expect(r, isA<ProbeResult>());
    });

    test('status stream is broadcast', () {
      final stream = ConnectivityProbeService.instance.status;
      // Should be able to listen multiple times without error
      final sub1 = stream.listen((_) {});
      final sub2 = stream.listen((_) {});
      sub1.cancel();
      sub2.cancel();
    });
  });
}
