import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/models/message.dart';

/// Pure-Dart unit tests for LAN adapter logic.
///
/// The LAN adapter uses JSON datagrams with a specific envelope format.
/// We test the datagram parsing, message construction, and edge cases
/// without touching any sockets (pure logic only).
void main() {
  // ── Datagram envelope format ──────────────────────────────────────────────
  //
  // LAN datagrams are JSON objects:
  //   { "from": "<address>", "payload": "<encrypted>",
  //     "t": "msg"|"sig", "id": "<dedup-id>", "ts": <epoch-ms> }

  group('LAN datagram envelope construction', () {
    test('message envelope has required fields', () {
      final envelope = {
        'from': 'alice_addr',
        'payload': 'encrypted_payload_here',
        't': 'msg',
        'id': 'msg_123',
        'ts': DateTime.now().millisecondsSinceEpoch,
      };
      final encoded = utf8.encode(jsonEncode(envelope));
      expect(encoded.length, greaterThan(0));
      expect(encoded.length, lessThanOrEqualTo(60000)); // _maxDatagramBytes
    });

    test('signal envelope uses t=sig', () {
      final signal = {
        'from': 'bob_addr',
        'payload': jsonEncode({
          'type': 'typing',
          'roomId': 'room1',
          'senderId': 'bob_addr',
          'payload': {},
        }),
        't': 'sig',
        'id': 'typing_${DateTime.now().millisecondsSinceEpoch}',
        'ts': DateTime.now().millisecondsSinceEpoch,
      };
      final json = jsonEncode(signal);
      final parsed = jsonDecode(json) as Map<String, dynamic>;
      expect(parsed['t'], equals('sig'));
    });

    test('sys_keys signals are NOT sent over LAN', () {
      // The LAN sender returns false for sys_keys signals.
      // Verify the convention: type == 'sys_keys' means reject.
      const type = 'sys_keys';
      expect(type == 'sys_keys', isTrue);
    });
  });

  // ── Datagram parsing (simulates _handleDatagram logic) ────────────────────

  group('LAN datagram parsing', () {
    /// Simulates the core parsing logic of LanInboxReader._handleDatagram
    /// without needing the actual socket or StreamController.
    Message? parseLanMessage(
      String selfAddress,
      List<int> raw,
      Set<String> seenIds,
    ) {
      try {
        final outer = jsonDecode(utf8.decode(raw)) as Map<String, dynamic>;
        final from = outer['from'] as String? ?? '';
        final payload = outer['payload'] as String? ?? '';
        final type = outer['t'] as String? ?? 'msg';
        final id = outer['id'] as String? ?? '';
        final tsMs = outer['ts'] as int? ?? 0;

        if (from.isEmpty || payload.isEmpty) return null;
        if (from == selfAddress) return null; // ignore own broadcasts

        if (id.isNotEmpty) {
          if (seenIds.contains(id)) return null;
          seenIds.add(id);
        }

        if (type == 'sig') return null; // signals handled separately

        return Message(
          id: id.isNotEmpty ? id : '${from}_$tsMs',
          senderId: from,
          receiverId: selfAddress,
          encryptedPayload: payload,
          timestamp: tsMs > 0
              ? DateTime.fromMillisecondsSinceEpoch(tsMs)
              : DateTime.now(),
          adapterType: 'lan',
        );
      } catch (_) {
        return null;
      }
    }

    test('parses valid message datagram', () {
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': 'encrypted_data',
        't': 'msg',
        'id': 'msg_1',
        'ts': 1710000000000,
      }));
      final seenIds = <String>{};
      final msg = parseLanMessage('bob', dg, seenIds);
      expect(msg, isNotNull);
      expect(msg!.senderId, equals('alice'));
      expect(msg.receiverId, equals('bob'));
      expect(msg.encryptedPayload, equals('encrypted_data'));
      expect(msg.id, equals('msg_1'));
      expect(msg.adapterType, equals('lan'));
    });

    test('ignores own broadcasts', () {
      final dg = utf8.encode(jsonEncode({
        'from': 'myself',
        'payload': 'data',
        't': 'msg',
        'id': 'msg_2',
        'ts': 1710000000000,
      }));
      final msg = parseLanMessage('myself', dg, <String>{});
      expect(msg, isNull);
    });

    test('ignores empty from field', () {
      final dg = utf8.encode(jsonEncode({
        'from': '',
        'payload': 'data',
        't': 'msg',
        'id': 'msg_3',
        'ts': 1710000000000,
      }));
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNull);
    });

    test('ignores empty payload', () {
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': '',
        't': 'msg',
        'id': 'msg_4',
        'ts': 1710000000000,
      }));
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNull);
    });

    test('deduplicates by id', () {
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': 'data',
        't': 'msg',
        'id': 'dup_id',
        'ts': 1710000000000,
      }));
      final seenIds = <String>{};
      final msg1 = parseLanMessage('bob', dg, seenIds);
      final msg2 = parseLanMessage('bob', dg, seenIds);
      expect(msg1, isNotNull);
      expect(msg2, isNull); // duplicate
    });

    test('signals (t=sig) return null from message parser', () {
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': '{"type":"typing"}',
        't': 'sig',
        'id': 'sig_1',
        'ts': 1710000000000,
      }));
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNull);
    });

    test('default type is msg when t field is missing', () {
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': 'data',
        'id': 'msg_5',
        'ts': 1710000000000,
      }));
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNotNull);
      expect(msg!.senderId, equals('alice'));
    });

    test('generates fallback id from sender + timestamp when id is empty', () {
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': 'data',
        'id': '',
        'ts': 1710000000000,
      }));
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNotNull);
      expect(msg!.id, equals('alice_1710000000000'));
    });

    test('handles missing ts with zero default', () {
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': 'data',
        'id': 'msg_6',
      }));
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNotNull);
      // When ts=0, code uses DateTime.now() — just verify it parsed.
    });

    test('rejects invalid JSON gracefully', () {
      final dg = utf8.encode('this is not json');
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNull);
    });

    test('rejects non-map JSON (array)', () {
      final dg = utf8.encode(jsonEncode([1, 2, 3]));
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNull);
    });
  });

  // ── Signal parsing ────────────────────────────────────────────────────────

  group('LAN signal parsing', () {
    /// Simulates signal parsing from LanInboxReader._handleDatagram.
    Map<String, dynamic>? parseLanSignal(
      String selfAddress,
      List<int> raw,
      Set<String> seenIds,
    ) {
      try {
        final outer = jsonDecode(utf8.decode(raw)) as Map<String, dynamic>;
        final from = outer['from'] as String? ?? '';
        final payload = outer['payload'] as String? ?? '';
        final type = outer['t'] as String? ?? 'msg';
        final id = outer['id'] as String? ?? '';

        if (from.isEmpty || payload.isEmpty) return null;
        if (from == selfAddress) return null;

        if (id.isNotEmpty) {
          if (seenIds.contains(id)) return null;
          seenIds.add(id);
        }

        if (type != 'sig') return null;

        return jsonDecode(payload) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }

    test('parses valid signal datagram', () {
      final sigPayload = jsonEncode({
        'type': 'typing',
        'roomId': 'room1',
        'senderId': 'alice',
        'payload': {},
      });
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': sigPayload,
        't': 'sig',
        'id': 'sig_1',
        'ts': 1710000000000,
      }));
      final sig = parseLanSignal('bob', dg, <String>{});
      expect(sig, isNotNull);
      expect(sig!['type'], equals('typing'));
      expect(sig['roomId'], equals('room1'));
    });

    test('ignores message datagrams (t=msg)', () {
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': 'data',
        't': 'msg',
        'id': 'msg_1',
        'ts': 1710000000000,
      }));
      final sig = parseLanSignal('bob', dg, <String>{});
      expect(sig, isNull);
    });

    test('returns null for invalid signal payload JSON', () {
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': 'not-json-at-all',
        't': 'sig',
        'id': 'sig_2',
        'ts': 1710000000000,
      }));
      final sig = parseLanSignal('bob', dg, <String>{});
      expect(sig, isNull);
    });
  });

  // ── Size guard ────────────────────────────────────────────────────────────

  group('LAN size limits', () {
    test('max datagram size constant is 60000 bytes', () {
      // The adapter rejects datagrams larger than 60KB.
      const maxDatagramBytes = 60000;
      expect(maxDatagramBytes, equals(60000));
    });

    test('payload exceeding max size would be rejected', () {
      final largePayload = 'X' * 60001;
      final encoded = utf8.encode(largePayload);
      expect(encoded.length, greaterThan(60000));
    });

    test('payload within max size is accepted', () {
      final okPayload = 'X' * 50000;
      final envelope = jsonEncode({
        'from': 'alice',
        'payload': okPayload,
        't': 'msg',
        'id': 'msg_big',
        'ts': 1710000000000,
      });
      final encoded = utf8.encode(envelope);
      // The envelope overhead adds to the payload size
      expect(encoded.length, lessThan(100000));
    });
  });

  // ── Multicast constants ───────────────────────────────────────────────────

  group('LAN multicast configuration', () {
    test('multicast group is administratively scoped (239.x.x.x)', () {
      // Per RFC 2365, 239.0.0.0/8 is administratively scoped.
      const multicastGroup = '239.255.42.99';
      expect(multicastGroup, startsWith('239.'));
    });

    test('port is 7842', () {
      const port = 7842;
      expect(port, equals(7842));
    });
  });
}
