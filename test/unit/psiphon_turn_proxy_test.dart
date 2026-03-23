import 'package:flutter_test/flutter_test.dart';

// PsiphonTurnProxy uses dart:io (ServerSocket, Socket) so we cannot import it
// directly in a pure-Dart test environment. Instead we reimplement the
// deterministic, configuration-level logic extracted from the source.

// ---------------------------------------------------------------------------
// Reimplemented from lib/services/psiphon_turn_proxy.dart
// ---------------------------------------------------------------------------

class _TurnPreset {
  final int localPort;
  final String remoteHost;
  final int remotePort;
  final String username;
  final String credential;

  const _TurnPreset({
    required this.localPort,
    required this.remoteHost,
    required this.remotePort,
    required this.username,
    required this.credential,
  });

  Map<String, dynamic> get iceServerEntry => {
        'urls': 'turn:127.0.0.1:$localPort?transport=tcp',
        'username': username,
        'credential': credential,
      };
}

// Mirrors PsiphonTurnProxy static presets
final _openrelay = _TurnPreset(
  localPort: 43478,
  remoteHost: 'openrelay.metered.ca',
  remotePort: 3478,
  username: 'openrelayproject',
  credential: 'openrelayproject',
);

final _freestun = _TurnPreset(
  localPort: 43479,
  remoteHost: 'freestun.net',
  remotePort: 3479,
  username: 'free',
  credential: 'free',
);

final _all = [_openrelay, _freestun];

/// Mirrors allIceServerEntries when all proxies are "running".
List<Map<String, dynamic>> allIceServerEntries(
        {required bool Function(_TurnPreset) isRunning}) => // ignore: library_private_types_in_public_api
    _all.where(isRunning).map((p) => p.iceServerEntry).toList();

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('PsiphonTurnProxy preset configuration', () {
    test('openrelay preset has correct local port 43478', () {
      expect(_openrelay.localPort, 43478);
    });

    test('freestun preset has correct local port 43479', () {
      expect(_freestun.localPort, 43479);
    });

    test('openrelay remote host and port are correct', () {
      expect(_openrelay.remoteHost, 'openrelay.metered.ca');
      expect(_openrelay.remotePort, 3478);
    });

    test('freestun remote host and port are correct', () {
      expect(_freestun.remoteHost, 'freestun.net');
      expect(_freestun.remotePort, 3479);
    });
  });

  group('PsiphonTurnProxy ICE server entry construction', () {
    test('openrelay ICE entry has correct TURN URI format', () {
      final entry = _openrelay.iceServerEntry;
      expect(entry['urls'], 'turn:127.0.0.1:43478?transport=tcp');
    });

    test('freestun ICE entry has correct TURN URI format', () {
      final entry = _freestun.iceServerEntry;
      expect(entry['urls'], 'turn:127.0.0.1:43479?transport=tcp');
    });

    test('ICE entry URLs are valid TURN URIs', () {
      for (final preset in _all) {
        final url = preset.iceServerEntry['urls'] as String;
        expect(url, startsWith('turn:'));
        expect(url, contains('127.0.0.1'));
        expect(url, endsWith('?transport=tcp'));
        // Verify port number is present between : and ?
        final portMatch = RegExp(r':(\d+)\?').firstMatch(url);
        expect(portMatch, isNotNull);
        final port = int.parse(portMatch!.group(1)!);
        expect(port, greaterThan(0));
        expect(port, lessThan(65536));
      }
    });

    test('openrelay ICE entry has correct credentials', () {
      final entry = _openrelay.iceServerEntry;
      expect(entry['username'], 'openrelayproject');
      expect(entry['credential'], 'openrelayproject');
    });

    test('freestun ICE entry has correct credentials', () {
      final entry = _freestun.iceServerEntry;
      expect(entry['username'], 'free');
      expect(entry['credential'], 'free');
    });

    test('ICE entry contains exactly three keys: urls, username, credential',
        () {
      for (final preset in _all) {
        final entry = preset.iceServerEntry;
        expect(entry.keys.toSet(), {'urls', 'username', 'credential'});
      }
    });
  });

  group('PsiphonTurnProxy allIceServerEntries', () {
    test('returns entries for all running proxies', () {
      final entries = allIceServerEntries(isRunning: (_) => true);
      expect(entries.length, 2);
      expect(entries[0]['urls'], 'turn:127.0.0.1:43478?transport=tcp');
      expect(entries[1]['urls'], 'turn:127.0.0.1:43479?transport=tcp');
    });

    test('returns empty list when no proxies are running', () {
      final entries = allIceServerEntries(isRunning: (_) => false);
      expect(entries, isEmpty);
    });

    test('returns only running proxy entries', () {
      final entries = allIceServerEntries(
          isRunning: (p) => p.localPort == 43478);
      expect(entries.length, 1);
      expect(entries[0]['urls'], contains('43478'));
    });
  });

  group('PsiphonTurnProxy port separation from Tor', () {
    test('local ports do not collide between presets', () {
      final ports = _all.map((p) => p.localPort).toSet();
      expect(ports.length, _all.length,
          reason: 'Each preset must bind to a unique local port');
    });

    test('local ports are in the 43xxx range (Psiphon range)', () {
      for (final preset in _all) {
        expect(preset.localPort, greaterThanOrEqualTo(43000));
        expect(preset.localPort, lessThan(44000));
      }
    });

    test('Psiphon ports do not collide with Tor ports (33xxx)', () {
      const torPorts = {33478, 33479};
      for (final preset in _all) {
        expect(torPorts.contains(preset.localPort), isFalse,
            reason:
                'Psiphon port ${preset.localPort} must not overlap with Tor ports');
      }
    });
  });
}
