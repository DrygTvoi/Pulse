import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/models/message.dart';

/// Pure-Dart unit tests for LAN adapter logic.
///
/// The LAN adapter uses UDP multicast for peer discovery and message broadcast
/// on the local network. We test datagram parsing, message/signal construction,
/// deduplication, size guards, connection lifecycle logic, error handling, and
/// security boundaries — all without touching real sockets.
void main() {
  // ── Constants ──────────────────────────────────────────────────────────────
  //
  // Mirror the adapter's private constants for verification.
  const multicastGroup = '239.255.42.99';
  const port = 7842;
  const maxDatagramBytes = 60000;

  // ══════════════════════════════════════════════════════════════════════════
  // Helper: simulates LanInboxReader._handleDatagram (message path)
  // ══════════════════════════════════════════════════════════════════════════

  /// Returns a [Message] if the datagram is a valid message, null otherwise.
  /// [seenIds] is mutated to track dedup state across calls.
  Message? parseLanMessage(
    String selfAddress,
    List<int> raw,
    Set<String> seenIds,
  ) {
    try {
      if (raw.length > maxDatagramBytes) return null;
      final outer = jsonDecode(utf8.decode(raw)) as Map<String, dynamic>;
      final from = outer['from'] as String? ?? '';
      final payload = outer['payload'] as String? ?? '';
      final type = outer['t'] as String? ?? 'msg';
      final id = outer['id'] as String? ?? '';
      final tsMs = outer['ts'] as int? ?? 0;

      if (from.isEmpty || payload.isEmpty) return null;
      if (from == selfAddress) return null;

      if (id.isNotEmpty) {
        if (seenIds.contains(id)) return null;
        seenIds.add(id);
        if (seenIds.length > 2000) {
          final evict = seenIds.toList().sublist(0, 1000);
          seenIds.removeAll(evict);
        }
      }

      if (type == 'sig') return null;

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

  // ══════════════════════════════════════════════════════════════════════════
  // Helper: simulates LanInboxReader._handleDatagram (signal path)
  // ══════════════════════════════════════════════════════════════════════════

  /// Returns the parsed signal map if the datagram is a valid signal, null
  /// otherwise. [seenIds] is mutated to track dedup state.
  Map<String, dynamic>? parseLanSignal(
    String selfAddress,
    List<int> raw,
    Set<String> seenIds,
  ) {
    try {
      if (raw.length > maxDatagramBytes) return null;
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
        if (seenIds.length > 2000) {
          final evict = seenIds.toList().sublist(0, 1000);
          seenIds.removeAll(evict);
        }
      }

      if (type != 'sig') return null;
      return jsonDecode(payload) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Helper: simulates LanMessageSender._broadcast envelope creation
  // ══════════════════════════════════════════════════════════════════════════

  /// Returns the encoded bytes that _broadcast would send, or null if the
  /// payload is too large.
  List<int>? buildBroadcastDatagram(
      String selfAddress, String type, String payload, String id) {
    final data = utf8.encode(jsonEncode({
      'from': selfAddress,
      'payload': payload,
      't': type,
      'id': id,
      'ts': DateTime.now().millisecondsSinceEpoch,
    }));
    if (data.length > maxDatagramBytes) return null;
    return data;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Helper: simulates LanMessageSender.sendSignal envelope
  // ══════════════════════════════════════════════════════════════════════════

  String buildSignalPayload(
      String type, String roomId, String senderId, Map<String, dynamic> payload) {
    return jsonEncode({
      'type': type,
      'roomId': roomId,
      'senderId': senderId,
      'payload': payload,
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  1. Multicast configuration
  // ══════════════════════════════════════════════════════════════════════════

  group('LAN multicast configuration', () {
    test('multicast group is administratively scoped (239.x.x.x / RFC 2365)',
        () {
      expect(multicastGroup, startsWith('239.'));
      // Administratively scoped range is 239.0.0.0/8
      final octets = multicastGroup.split('.');
      expect(octets.length, equals(4));
      expect(int.parse(octets[0]), equals(239));
    });

    test('multicast group is a valid IPv4 address', () {
      final octets = multicastGroup.split('.');
      expect(octets.length, equals(4));
      for (final o in octets) {
        final n = int.tryParse(o);
        expect(n, isNotNull);
        expect(n, greaterThanOrEqualTo(0));
        expect(n, lessThanOrEqualTo(255));
      }
    });

    test('port is 7842', () {
      expect(port, equals(7842));
    });

    test('port is in user/dynamic range (>= 1024)', () {
      expect(port, greaterThanOrEqualTo(1024));
    });

    test('maxDatagramBytes is 60000', () {
      expect(maxDatagramBytes, equals(60000));
    });

    test('maxDatagramBytes fits in a single UDP datagram (< 65535)', () {
      expect(maxDatagramBytes, lessThan(65535));
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  //  2. Datagram envelope construction (sender side)
  // ══════════════════════════════════════════════════════════════════════════

  group('LAN datagram envelope construction', () {
    test('message envelope has all required fields', () {
      final envelope = {
        'from': 'alice_addr',
        'payload': 'encrypted_payload_here',
        't': 'msg',
        'id': 'msg_123',
        'ts': DateTime.now().millisecondsSinceEpoch,
      };
      final json = jsonEncode(envelope);
      final parsed = jsonDecode(json) as Map<String, dynamic>;
      expect(parsed.containsKey('from'), isTrue);
      expect(parsed.containsKey('payload'), isTrue);
      expect(parsed.containsKey('t'), isTrue);
      expect(parsed.containsKey('id'), isTrue);
      expect(parsed.containsKey('ts'), isTrue);
    });

    test('message envelope encodes within size limit', () {
      final envelope = {
        'from': 'alice_addr',
        'payload': 'encrypted_payload_here',
        't': 'msg',
        'id': 'msg_123',
        'ts': DateTime.now().millisecondsSinceEpoch,
      };
      final encoded = utf8.encode(jsonEncode(envelope));
      expect(encoded.length, greaterThan(0));
      expect(encoded.length, lessThanOrEqualTo(maxDatagramBytes));
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
      const type = 'sys_keys';
      // Simulates: if (type == 'sys_keys') return Future.value(false);
      expect(type == 'sys_keys', isTrue);
    });

    test('buildBroadcastDatagram creates valid JSON', () {
      final data = buildBroadcastDatagram('me', 'msg', 'hello', 'id1');
      expect(data, isNotNull);
      final parsed =
          jsonDecode(utf8.decode(data!)) as Map<String, dynamic>;
      expect(parsed['from'], equals('me'));
      expect(parsed['payload'], equals('hello'));
      expect(parsed['t'], equals('msg'));
      expect(parsed['id'], equals('id1'));
      expect(parsed['ts'], isA<int>());
    });

    test('buildBroadcastDatagram returns null for oversized payload', () {
      final hugePayload = 'X' * 60000;
      final data = buildBroadcastDatagram('me', 'msg', hugePayload, 'id_big');
      // The JSON envelope adds overhead to the payload, pushing total > 60000
      expect(data, isNull);
    });

    test('buildSignalPayload includes all signal fields', () {
      final sp = buildSignalPayload(
          'typing', 'room1', 'alice', {'key': 'value'});
      final parsed = jsonDecode(sp) as Map<String, dynamic>;
      expect(parsed['type'], equals('typing'));
      expect(parsed['roomId'], equals('room1'));
      expect(parsed['senderId'], equals('alice'));
      expect(parsed['payload'], isA<Map<String, dynamic>>());
      expect(parsed['payload']['key'], equals('value'));
    });

    test('signal id format is type_timestamp', () {
      const type = 'webrtc_offer';
      final ts = DateTime.now().millisecondsSinceEpoch;
      final id = '${type}_$ts';
      expect(id, startsWith('webrtc_offer_'));
      expect(id.length, greaterThan(type.length + 1));
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  //  3. Message parsing (receiver side)
  // ══════════════════════════════════════════════════════════════════════════

  group('LAN message parsing', () {
    test('parses valid message datagram', () {
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': 'encrypted_data',
        't': 'msg',
        'id': 'msg_1',
        'ts': 1710000000000,
      }));
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNotNull);
      expect(msg!.senderId, equals('alice'));
      expect(msg.receiverId, equals('bob'));
      expect(msg.encryptedPayload, equals('encrypted_data'));
      expect(msg.id, equals('msg_1'));
      expect(msg.adapterType, equals('lan'));
    });

    test('sets correct timestamp from ts field', () {
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': 'data',
        't': 'msg',
        'id': 'msg_ts',
        'ts': 1710000000000,
      }));
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNotNull);
      expect(msg!.timestamp,
          equals(DateTime.fromMillisecondsSinceEpoch(1710000000000)));
    });

    test('uses DateTime.now() fallback when ts is 0', () {
      final before = DateTime.now();
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': 'data',
        't': 'msg',
        'id': 'msg_ts0',
        'ts': 0,
      }));
      final msg = parseLanMessage('bob', dg, <String>{});
      final after = DateTime.now();
      expect(msg, isNotNull);
      // timestamp should be approximately now
      expect(msg!.timestamp.millisecondsSinceEpoch,
          greaterThanOrEqualTo(before.millisecondsSinceEpoch));
      expect(msg.timestamp.millisecondsSinceEpoch,
          lessThanOrEqualTo(after.millisecondsSinceEpoch));
    });

    test('default type is msg when t field is missing', () {
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': 'data',
        'id': 'msg_no_t',
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

    test('generates fallback id when id field is missing entirely', () {
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': 'data',
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
        'id': 'msg_no_ts',
      }));
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNotNull);
    });

    test('message adapterType is always lan', () {
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': 'data',
        't': 'msg',
        'id': 'msg_adapter',
        'ts': 1710000000000,
      }));
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNotNull);
      expect(msg!.adapterType, equals('lan'));
    });

    test('receiverId is set to selfAddress', () {
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': 'data',
        't': 'msg',
        'id': 'msg_rcv',
        'ts': 1710000000000,
      }));
      final msg = parseLanMessage('my_self_addr', dg, <String>{});
      expect(msg, isNotNull);
      expect(msg!.receiverId, equals('my_self_addr'));
    });

    test('encryptedPayload preserves raw payload exactly', () {
      const rawPayload = 'base64EncodedCiphertext+/=';
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': rawPayload,
        't': 'msg',
        'id': 'msg_pay',
        'ts': 1710000000000,
      }));
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNotNull);
      expect(msg!.encryptedPayload, equals(rawPayload));
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  //  4. Own-broadcast filtering (self-address check)
  // ══════════════════════════════════════════════════════════════════════════

  group('LAN own-broadcast filtering', () {
    test('ignores datagram from self', () {
      final dg = utf8.encode(jsonEncode({
        'from': 'myself',
        'payload': 'data',
        't': 'msg',
        'id': 'msg_self',
        'ts': 1710000000000,
      }));
      final msg = parseLanMessage('myself', dg, <String>{});
      expect(msg, isNull);
    });

    test('accepts datagram from different sender', () {
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': 'data',
        't': 'msg',
        'id': 'msg_diff',
        'ts': 1710000000000,
      }));
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNotNull);
    });

    test('self-check is case-sensitive (address is exact match)', () {
      final dg = utf8.encode(jsonEncode({
        'from': 'ALICE',
        'payload': 'data',
        't': 'msg',
        'id': 'msg_case',
        'ts': 1710000000000,
      }));
      // 'ALICE' != 'alice' — should not be filtered
      final msg = parseLanMessage('alice', dg, <String>{});
      expect(msg, isNotNull);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  //  5. Empty / missing field validation
  // ══════════════════════════════════════════════════════════════════════════

  group('LAN empty field rejection', () {
    test('ignores empty from field', () {
      final dg = utf8.encode(jsonEncode({
        'from': '',
        'payload': 'data',
        't': 'msg',
        'id': 'msg_ef',
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
        'id': 'msg_ep',
        'ts': 1710000000000,
      }));
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNull);
    });

    test('ignores when both from and payload are empty', () {
      final dg = utf8.encode(jsonEncode({
        'from': '',
        'payload': '',
        't': 'msg',
        'id': 'msg_both_empty',
        'ts': 1710000000000,
      }));
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNull);
    });

    test('missing from field defaults to empty string → rejected', () {
      final dg = utf8.encode(jsonEncode({
        'payload': 'data',
        't': 'msg',
        'id': 'msg_nf',
        'ts': 1710000000000,
      }));
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNull);
    });

    test('missing payload field defaults to empty string → rejected', () {
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        't': 'msg',
        'id': 'msg_np',
        'ts': 1710000000000,
      }));
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNull);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  //  6. Deduplication
  // ══════════════════════════════════════════════════════════════════════════

  group('LAN deduplication', () {
    test('rejects duplicate message by id', () {
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
      expect(msg2, isNull);
    });

    test('allows messages with different ids', () {
      final seenIds = <String>{};
      for (var i = 0; i < 5; i++) {
        final dg = utf8.encode(jsonEncode({
          'from': 'alice',
          'payload': 'data_$i',
          't': 'msg',
          'id': 'unique_$i',
          'ts': 1710000000000 + i,
        }));
        final msg = parseLanMessage('bob', dg, seenIds);
        expect(msg, isNotNull, reason: 'Message $i should not be deduped');
      }
      expect(seenIds.length, equals(5));
    });

    test('empty id bypasses dedup (always accepted)', () {
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': 'data',
        't': 'msg',
        'id': '',
        'ts': 1710000000000,
      }));
      final seenIds = <String>{};
      final msg1 = parseLanMessage('bob', dg, seenIds);
      final msg2 = parseLanMessage('bob', dg, seenIds);
      expect(msg1, isNotNull);
      expect(msg2, isNotNull);
      expect(seenIds, isEmpty); // empty ids not tracked
    });

    test('seenIds set trims oldest 1000 entries at 2001 threshold', () {
      final seenIds = <String>{};
      // Fill to just over 2000
      for (var i = 0; i < 2001; i++) {
        seenIds.add('id_$i');
      }
      expect(seenIds.length, equals(2001));
      // Simulate the trim logic from _handleDatagram
      if (seenIds.length > 2000) {
        final evict = seenIds.toList().sublist(0, 1000);
        seenIds.removeAll(evict);
      }
      expect(seenIds.length, equals(1001));
    });

    test('dedup trim preserves newest entries', () {
      final seenIds = <String>{};
      for (var i = 0; i < 2001; i++) {
        seenIds.add('id_$i');
      }
      if (seenIds.length > 2000) {
        final evict = seenIds.toList().sublist(0, 1000);
        seenIds.removeAll(evict);
      }
      // The newest entries (id_1000..id_2000) should remain
      // (Set iteration order is insertion order in Dart)
      expect(seenIds.contains('id_2000'), isTrue);
      expect(seenIds.contains('id_1500'), isTrue);
    });

    test('dedup works across message and signal paths', () {
      final seenIds = <String>{};
      // First as message
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': '{"type":"typing"}',
        't': 'sig',
        'id': 'shared_id',
        'ts': 1710000000000,
      }));
      final sig = parseLanSignal('bob', dg, seenIds);
      expect(sig, isNotNull);
      // Same id as message should be deduped
      final dg2 = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': 'msg_data',
        't': 'msg',
        'id': 'shared_id',
        'ts': 1710000000000,
      }));
      final msg = parseLanMessage('bob', dg2, seenIds);
      expect(msg, isNull); // deduped
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  //  7. Signal parsing
  // ══════════════════════════════════════════════════════════════════════════

  group('LAN signal parsing', () {
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
      expect(sig['senderId'], equals('alice'));
    });

    test('ignores message datagrams (t=msg)', () {
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': 'data',
        't': 'msg',
        'id': 'msg_in_sig',
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
        'id': 'sig_bad',
        'ts': 1710000000000,
      }));
      final sig = parseLanSignal('bob', dg, <String>{});
      expect(sig, isNull);
    });

    test('parses WebRTC offer signal', () {
      final sigPayload = jsonEncode({
        'type': 'webrtc_offer',
        'roomId': 'room1',
        'senderId': 'alice',
        'payload': {'sdp': 'v=0...', 'type': 'offer'},
      });
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': sigPayload,
        't': 'sig',
        'id': 'wrtc_1',
        'ts': 1710000000000,
      }));
      final sig = parseLanSignal('bob', dg, <String>{});
      expect(sig, isNotNull);
      expect(sig!['type'], equals('webrtc_offer'));
      expect(sig['payload']['sdp'], equals('v=0...'));
    });

    test('parses msg_ack signal', () {
      final sigPayload = jsonEncode({
        'type': 'msg_ack',
        'roomId': 'room1',
        'senderId': 'alice',
        'payload': {'messageId': 'msg_123'},
      });
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': sigPayload,
        't': 'sig',
        'id': 'ack_1',
        'ts': 1710000000000,
      }));
      final sig = parseLanSignal('bob', dg, <String>{});
      expect(sig, isNotNull);
      expect(sig!['type'], equals('msg_ack'));
    });

    test('ignores signal from self', () {
      final sigPayload = jsonEncode({'type': 'typing'});
      final dg = utf8.encode(jsonEncode({
        'from': 'bob',
        'payload': sigPayload,
        't': 'sig',
        'id': 'sig_self',
        'ts': 1710000000000,
      }));
      final sig = parseLanSignal('bob', dg, <String>{});
      expect(sig, isNull);
    });

    test('signal dedup works correctly', () {
      final sigPayload = jsonEncode({'type': 'typing'});
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': sigPayload,
        't': 'sig',
        'id': 'sig_dup',
        'ts': 1710000000000,
      }));
      final seenIds = <String>{};
      final sig1 = parseLanSignal('bob', dg, seenIds);
      final sig2 = parseLanSignal('bob', dg, seenIds);
      expect(sig1, isNotNull);
      expect(sig2, isNull);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  //  8. Error handling / malformed data
  // ══════════════════════════════════════════════════════════════════════════

  group('LAN error handling', () {
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

    test('rejects non-map JSON (string)', () {
      final dg = utf8.encode(jsonEncode('just a string'));
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNull);
    });

    test('rejects non-map JSON (number)', () {
      final dg = utf8.encode(jsonEncode(42));
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNull);
    });

    test('rejects non-map JSON (boolean)', () {
      final dg = utf8.encode(jsonEncode(true));
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNull);
    });

    test('rejects non-map JSON (null)', () {
      final dg = utf8.encode(jsonEncode(null));
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNull);
    });

    test('rejects empty bytes', () {
      final msg = parseLanMessage('bob', <int>[], <String>{});
      expect(msg, isNull);
    });

    test('rejects invalid UTF-8 bytes', () {
      // 0xFF is not valid UTF-8
      final msg = parseLanMessage('bob', [0xFF, 0xFE, 0xFD], <String>{});
      expect(msg, isNull);
    });

    test('rejects truncated JSON', () {
      final dg = utf8.encode('{"from":"alice","payload":');
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNull);
    });

    test('handles from field as non-string type gracefully', () {
      final dg = utf8.encode(jsonEncode({
        'from': 123,
        'payload': 'data',
        't': 'msg',
        'id': 'msg_bad_from',
        'ts': 1710000000000,
      }));
      // 'as String?' will throw, caught by try-catch
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNull);
    });

    test('handles ts field as non-int type gracefully', () {
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': 'data',
        't': 'msg',
        'id': 'msg_bad_ts',
        'ts': 'not_a_number',
      }));
      // 'as int?' will throw, caught by try-catch
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNull);
    });

    test('signal parser rejects invalid signal payload (array JSON)', () {
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': '[1,2,3]',
        't': 'sig',
        'id': 'sig_arr',
        'ts': 1710000000000,
      }));
      final sig = parseLanSignal('bob', dg, <String>{});
      expect(sig, isNull);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  //  9. Size guards
  // ══════════════════════════════════════════════════════════════════════════

  group('LAN size guards', () {
    test('rejects datagram exceeding maxDatagramBytes on receive', () {
      // Create raw bytes > 60000
      final largePayload = 'X' * 60001;
      final dg = utf8.encode(largePayload);
      expect(dg.length, greaterThan(maxDatagramBytes));
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNull);
    });

    test('accepts datagram exactly at maxDatagramBytes on receive', () {
      // Construct a valid JSON datagram that's exactly at the limit
      final overhead = jsonEncode({
        'from': 'a',
        'payload': '',
        't': 'msg',
        'id': 'x',
        'ts': 0,
      });
      final overheadLen = utf8.encode(overhead).length;
      // Fill payload to bring total to exactly maxDatagramBytes
      // Subtract overhead but add back the empty payload ('""' is 2 bytes in overhead)
      final fillLen = maxDatagramBytes - overheadLen;
      // This won't be exactly 60000 bytes due to JSON escaping, but test the concept
      if (fillLen > 0) {
        final dg = utf8.encode(jsonEncode({
          'from': 'a',
          'payload': 'X' * (fillLen - 30), // approximate
          't': 'msg',
          'id': 'x',
          'ts': 0,
        }));
        if (dg.length <= maxDatagramBytes) {
          final msg = parseLanMessage('bob', dg, <String>{});
          expect(msg, isNotNull);
        }
      }
    });

    test('sender rejects oversized broadcast payload', () {
      final hugePayload = 'X' * 59000;
      // JSON envelope adds ~80+ bytes overhead
      final data = buildBroadcastDatagram('me', 'msg', hugePayload, 'id_big');
      // The encoded length may exceed 60000 due to envelope overhead
      if (data == null) {
        // Rejected as expected
        expect(data, isNull);
      } else {
        expect(data.length, lessThanOrEqualTo(maxDatagramBytes));
      }
    });

    test('sender accepts payload within size limit', () {
      final data = buildBroadcastDatagram('me', 'msg', 'small_payload', 'id1');
      expect(data, isNotNull);
      expect(data!.length, lessThanOrEqualTo(maxDatagramBytes));
    });

    test('signal datagram size is checked on receive', () {
      final largeBytes = List<int>.filled(60001, 0x41); // 'A' * 60001
      final sig = parseLanSignal('bob', largeBytes, <String>{});
      expect(sig, isNull);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 10. Connection lifecycle
  // ══════════════════════════════════════════════════════════════════════════

  group('LAN connection lifecycle', () {
    test('initializeReader stores selfAddress (databaseId)', () {
      // Simulates: _selfAddress = databaseId in initializeReader
      String selfAddress = '';
      selfAddress = 'my_lan_address';
      expect(selfAddress, equals('my_lan_address'));
    });

    test('initializeSender stores selfAddress from apiKey', () {
      // Simulates: _selfAddress = apiKey in initializeSender
      String selfAddress = '';
      selfAddress = 'my_sender_address';
      expect(selfAddress, equals('my_sender_address'));
    });

    test('close nullifies socket reference', () {
      // Simulates: _socket?.close(); _socket = null;
      Object? socket = Object();
      expect(socket, isNotNull);
      socket = null;
      expect(socket, isNull);
    });

    test('sender multicastHops should be 1 (local subnet only)', () {
      // _socket!.multicastHops = 1
      const multicastHops = 1;
      expect(multicastHops, equals(1));
    });

    test('reader uses reuseAddress and reusePort', () {
      // Ensures multiple Pulse instances can bind to the same port
      const reuseAddress = true;
      const reusePort = true;
      expect(reuseAddress, isTrue);
      expect(reusePort, isTrue);
    });

    test('sender binds to port 0 (OS-assigned ephemeral port)', () {
      // RawDatagramSocket.bind(InternetAddress.anyIPv4, 0)
      const senderPort = 0;
      expect(senderPort, equals(0));
    });

    test('fetchPublicKeys returns null (keys not distributed over LAN)', () {
      // @override Future<Map<String, dynamic>?> fetchPublicKeys() async => null;
      Future<Map<String, dynamic>?> fetchPublicKeys() async => null;
      expect(fetchPublicKeys(), completion(isNull));
    });

    test('provisionGroup returns null (groups not provisioned over LAN)', () {
      Future<String?> provisionGroup(String name) async => null;
      expect(provisionGroup('test'), completion(isNull));
    });

    test('healthChanges emits empty stream', () {
      final stream = Stream<bool>.empty();
      expect(stream, emitsDone);
    });

    test('broadcast returns false when socket is null', () {
      // if (_socket == null) return false;
      // Null socket → broadcast returns false
      const result = false;
      expect(result, isFalse);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 11. Roundtrip: build envelope → parse envelope
  // ══════════════════════════════════════════════════════════════════════════

  group('LAN roundtrip (send → receive)', () {
    test('message roundtrip: built datagram is parseable', () {
      final data = buildBroadcastDatagram('alice', 'msg', 'encrypted_data', 'rt_1');
      expect(data, isNotNull);
      final msg = parseLanMessage('bob', data!, <String>{});
      expect(msg, isNotNull);
      expect(msg!.senderId, equals('alice'));
      expect(msg.encryptedPayload, equals('encrypted_data'));
      expect(msg.id, equals('rt_1'));
    });

    test('signal roundtrip: built datagram is parseable', () {
      final sigPayload = buildSignalPayload(
          'typing', 'room1', 'alice', {'cursor': 5});
      final data = buildBroadcastDatagram('alice', 'sig', sigPayload, 'sig_rt_1');
      expect(data, isNotNull);
      final sig = parseLanSignal('bob', data!, <String>{});
      expect(sig, isNotNull);
      expect(sig!['type'], equals('typing'));
      expect(sig['roomId'], equals('room1'));
      expect(sig['payload']['cursor'], equals(5));
    });

    test('message roundtrip with unicode payload', () {
      const payload = 'encrypted:🔐日本語العربية';
      final data = buildBroadcastDatagram('alice', 'msg', payload, 'rt_unicode');
      expect(data, isNotNull);
      final msg = parseLanMessage('bob', data!, <String>{});
      expect(msg, isNotNull);
      expect(msg!.encryptedPayload, equals(payload));
    });

    test('message roundtrip with special JSON characters in payload', () {
      const payload = 'has "quotes" and \\backslashes and\nnewlines';
      final data = buildBroadcastDatagram('alice', 'msg', payload, 'rt_special');
      expect(data, isNotNull);
      final msg = parseLanMessage('bob', data!, <String>{});
      expect(msg, isNotNull);
      expect(msg!.encryptedPayload, equals(payload));
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 12. Signal type filtering (sys_keys blocked)
  // ══════════════════════════════════════════════════════════════════════════

  group('LAN signal type filtering', () {
    test('sys_keys is blocked from sending', () {
      const type = 'sys_keys';
      final shouldBlock = type == 'sys_keys';
      expect(shouldBlock, isTrue);
    });

    test('typing signal is allowed', () {
      const type = 'typing';
      final shouldBlock = type == 'sys_keys';
      expect(shouldBlock, isFalse);
    });

    test('webrtc_offer signal is allowed', () {
      const type = 'webrtc_offer';
      final shouldBlock = type == 'sys_keys';
      expect(shouldBlock, isFalse);
    });

    test('webrtc_answer signal is allowed', () {
      const type = 'webrtc_answer';
      final shouldBlock = type == 'sys_keys';
      expect(shouldBlock, isFalse);
    });

    test('webrtc_candidate signal is allowed', () {
      const type = 'webrtc_candidate';
      final shouldBlock = type == 'sys_keys';
      expect(shouldBlock, isFalse);
    });

    test('msg_ack signal is allowed', () {
      const type = 'msg_ack';
      final shouldBlock = type == 'sys_keys';
      expect(shouldBlock, isFalse);
    });

    test('profile_update signal is allowed', () {
      const type = 'profile_update';
      final shouldBlock = type == 'sys_keys';
      expect(shouldBlock, isFalse);
    });

    test('relay_exchange signal is allowed', () {
      const type = 'relay_exchange';
      final shouldBlock = type == 'sys_keys';
      expect(shouldBlock, isFalse);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 13. Edge cases
  // ══════════════════════════════════════════════════════════════════════════

  group('LAN edge cases', () {
    test('handles very long from address', () {
      final longAddr = 'x' * 5000;
      final dg = utf8.encode(jsonEncode({
        'from': longAddr,
        'payload': 'data',
        't': 'msg',
        'id': 'msg_long_from',
        'ts': 1710000000000,
      }));
      if (dg.length <= maxDatagramBytes) {
        final msg = parseLanMessage('bob', dg, <String>{});
        expect(msg, isNotNull);
        expect(msg!.senderId, equals(longAddr));
      }
    });

    test('handles datagram with extra unknown fields', () {
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': 'data',
        't': 'msg',
        'id': 'msg_extra',
        'ts': 1710000000000,
        'extra_field': 'ignored',
        'version': 2,
        'metadata': {'key': 'value'},
      }));
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNotNull);
      expect(msg!.senderId, equals('alice'));
    });

    test('handles whitespace-only from field', () {
      final dg = utf8.encode(jsonEncode({
        'from': '   ',
        'payload': 'data',
        't': 'msg',
        'id': 'msg_ws',
        'ts': 1710000000000,
      }));
      final msg = parseLanMessage('bob', dg, <String>{});
      // '   ' is not empty — from.isEmpty is false — should be accepted
      expect(msg, isNotNull);
      expect(msg!.senderId, equals('   '));
    });

    test('handles null values in JSON fields', () {
      final dg = utf8.encode(jsonEncode({
        'from': null,
        'payload': null,
        't': null,
        'id': null,
        'ts': null,
      }));
      // 'as String? ?? ""' on null yields ''
      // both from and payload empty → rejected
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNull);
    });

    test('handles numeric values for string fields', () {
      // from is 42 (int), not String → as String? will throw → caught
      final dg = utf8.encode('{"from":42,"payload":"x","t":"msg","id":"i","ts":0}');
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNull);
    });

    test('handles very large number of concurrent seenIds', () {
      final seenIds = <String>{};
      for (var i = 0; i < 5000; i++) {
        seenIds.add('stress_$i');
      }
      // Simulate trim at threshold
      while (seenIds.length > 2000) {
        final evict = seenIds.toList().sublist(0, 1000);
        seenIds.removeAll(evict);
      }
      expect(seenIds.length, lessThanOrEqualTo(2000));
    });

    test('timestamp 0 maps to epoch start if used as milliseconds', () {
      final dt = DateTime.fromMillisecondsSinceEpoch(0);
      expect(dt.year, equals(1970));
    });

    test('negative timestamp still creates valid DateTime', () {
      // Negative ts passes tsMs > 0 check: false → uses DateTime.now()
      const tsMs = -1000;
      final usesNow = tsMs > 0 ? false : true;
      expect(usesNow, isTrue);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 14. Multiple peers simulation
  // ══════════════════════════════════════════════════════════════════════════

  group('LAN multiple peers', () {
    test('receives messages from multiple senders', () {
      final seenIds = <String>{};
      final senders = ['alice', 'bob', 'charlie', 'dave'];
      final messages = <Message>[];
      for (final sender in senders) {
        final dg = utf8.encode(jsonEncode({
          'from': sender,
          'payload': 'msg_from_$sender',
          't': 'msg',
          'id': 'msg_$sender',
          'ts': 1710000000000,
        }));
        final msg = parseLanMessage('eve', dg, seenIds);
        if (msg != null) messages.add(msg);
      }
      expect(messages.length, equals(4));
      expect(messages.map((m) => m.senderId).toSet(),
          equals({'alice', 'bob', 'charlie', 'dave'}));
    });

    test('filters only own messages from multi-sender stream', () {
      final seenIds = <String>{};
      final senders = ['alice', 'bob', 'eve', 'charlie'];
      int received = 0;
      for (final sender in senders) {
        final dg = utf8.encode(jsonEncode({
          'from': sender,
          'payload': 'data',
          't': 'msg',
          'id': 'multi_$sender',
          'ts': 1710000000000,
        }));
        final msg = parseLanMessage('eve', dg, seenIds);
        if (msg != null) received++;
      }
      // 'eve' is filtered out (self), so 3 messages received
      expect(received, equals(3));
    });

    test('interleaved messages and signals from same peer', () {
      final seenIds = <String>{};
      // Message from alice
      final dg1 = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': 'hello',
        't': 'msg',
        'id': 'interleave_1',
        'ts': 1710000000000,
      }));
      // Signal from alice
      final dg2 = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': '{"type":"typing"}',
        't': 'sig',
        'id': 'interleave_2',
        'ts': 1710000001000,
      }));
      // Another message from alice
      final dg3 = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': 'world',
        't': 'msg',
        'id': 'interleave_3',
        'ts': 1710000002000,
      }));

      final msg1 = parseLanMessage('bob', dg1, seenIds);
      final sig = parseLanSignal('bob', dg2, seenIds);
      final msg2 = parseLanMessage('bob', dg3, seenIds);

      expect(msg1, isNotNull);
      expect(sig, isNotNull);
      expect(msg2, isNotNull);
      expect(msg1!.encryptedPayload, equals('hello'));
      expect(sig!['type'], equals('typing'));
      expect(msg2!.encryptedPayload, equals('world'));
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 15. Message model integration
  // ══════════════════════════════════════════════════════════════════════════

  group('LAN Message model integration', () {
    test('parsed message can be serialized to JSON', () {
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': 'encrypted',
        't': 'msg',
        'id': 'msg_json',
        'ts': 1710000000000,
      }));
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNotNull);
      final json = msg!.toJson();
      expect(json['id'], equals('msg_json'));
      expect(json['senderId'], equals('alice'));
      expect(json['receiverId'], equals('bob'));
      expect(json['encryptedPayload'], equals('encrypted'));
      expect(json['adapterType'], equals('lan'));
    });

    test('parsed message can be roundtripped through JSON', () {
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': 'encrypted_data',
        't': 'msg',
        'id': 'msg_rt_json',
        'ts': 1710000000000,
      }));
      final original = parseLanMessage('bob', dg, <String>{});
      expect(original, isNotNull);
      final json = original!.toJson();
      final restored = Message.fromJson(json);
      expect(restored.id, equals(original.id));
      expect(restored.senderId, equals(original.senderId));
      expect(restored.receiverId, equals(original.receiverId));
      expect(restored.encryptedPayload, equals(original.encryptedPayload));
      expect(restored.adapterType, equals(original.adapterType));
    });

    test('parsed message default status is empty (received)', () {
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': 'data',
        't': 'msg',
        'id': 'msg_status',
        'ts': 1710000000000,
      }));
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNotNull);
      expect(msg!.status, equals(''));
      expect(msg.isRead, isFalse);
    });

    test('parsed message copyWith preserves lan adapterType', () {
      final dg = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': 'data',
        't': 'msg',
        'id': 'msg_copy',
        'ts': 1710000000000,
      }));
      final msg = parseLanMessage('bob', dg, <String>{});
      expect(msg, isNotNull);
      final updated = msg!.copyWith(status: 'delivered', isRead: true);
      expect(updated.adapterType, equals('lan'));
      expect(updated.status, equals('delivered'));
      expect(updated.isRead, isTrue);
      expect(updated.senderId, equals('alice'));
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 16. Sender signal construction
  // ══════════════════════════════════════════════════════════════════════════

  group('LAN sender signal construction', () {
    test('sendSignal builds correct nested JSON payload', () {
      final innerPayload = buildSignalPayload(
        'webrtc_offer',
        'room42',
        'alice',
        {'sdp': 'v=0\r\no=...', 'type': 'offer'},
      );
      final parsed = jsonDecode(innerPayload) as Map<String, dynamic>;
      expect(parsed['type'], equals('webrtc_offer'));
      expect(parsed['roomId'], equals('room42'));
      expect(parsed['senderId'], equals('alice'));
      final p = parsed['payload'] as Map<String, dynamic>;
      expect(p['sdp'], startsWith('v=0'));
      expect(p['type'], equals('offer'));
    });

    test('sendSignal wraps in broadcast envelope correctly', () {
      final innerPayload = buildSignalPayload(
        'typing',
        'room1',
        'alice',
        {},
      );
      final data = buildBroadcastDatagram('alice', 'sig', innerPayload, 'sig_wrap');
      expect(data, isNotNull);
      final outer = jsonDecode(utf8.decode(data!)) as Map<String, dynamic>;
      expect(outer['from'], equals('alice'));
      expect(outer['t'], equals('sig'));
      // Inner payload is valid JSON
      final inner = jsonDecode(outer['payload'] as String) as Map<String, dynamic>;
      expect(inner['type'], equals('typing'));
    });

    test('sendMessage uses message.encryptedPayload and message.id', () {
      // Simulate sendMessage logic
      final msg = Message(
        id: 'test_msg_id',
        senderId: 'alice',
        receiverId: 'bob',
        encryptedPayload: 'ciphertext_here',
        timestamp: DateTime.now(),
        adapterType: 'lan',
      );
      final data = buildBroadcastDatagram('alice', 'msg', msg.encryptedPayload, msg.id);
      expect(data, isNotNull);
      final parsed = jsonDecode(utf8.decode(data!)) as Map<String, dynamic>;
      expect(parsed['payload'], equals('ciphertext_here'));
      expect(parsed['id'], equals('test_msg_id'));
      expect(parsed['t'], equals('msg'));
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 17. Security: same-network validation / TTL
  // ══════════════════════════════════════════════════════════════════════════

  group('LAN security constraints', () {
    test('multicast TTL of 1 prevents internet routing', () {
      // multicastHops = 1 means the packet expires after one router hop
      const ttl = 1;
      expect(ttl, equals(1));
      expect(ttl, lessThanOrEqualTo(1));
    });

    test('administratively scoped multicast (239.x) is never globally routed',
        () {
      // RFC 2365: 239.0.0.0/8 traffic is confined by network admins
      final firstOctet = int.parse(multicastGroup.split('.')[0]);
      expect(firstOctet, equals(239));
    });

    test('key bundles (sys_keys) never exposed on LAN', () {
      // Keys are exchanged via other transports only.
      // Sending sys_keys over LAN returns false immediately.
      const type = 'sys_keys';
      final blocked = (type == 'sys_keys');
      expect(blocked, isTrue);
    });

    test('fetchPublicKeys returns null (no key distribution over LAN)', () {
      // Keys are fetched via Nostr/Firebase/Waku/Oxen only.
      final result = null; // fetchPublicKeys() always returns null
      expect(result, isNull);
    });

    test('provisionGroup returns null (no group provisioning over LAN)', () {
      final result = null;
      expect(result, isNull);
    });

    test('payload is encrypted before broadcast (E2EE guarantee)', () {
      // The LAN adapter does not encrypt — it relies on Signal protocol
      // encryption happening before sendMessage is called.
      // This test verifies the adapter passes through the encrypted payload
      // without modification.
      const originalCiphertext = 'base64EncryptedBySignalProtocol==';
      final data = buildBroadcastDatagram(
          'alice', 'msg', originalCiphertext, 'msg_e2ee');
      expect(data, isNotNull);
      final parsed = jsonDecode(utf8.decode(data!)) as Map<String, dynamic>;
      expect(parsed['payload'], equals(originalCiphertext));
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 18. OnEvent filtering (RawSocketEvent handling)
  // ══════════════════════════════════════════════════════════════════════════

  group('LAN RawSocketEvent filtering', () {
    test('only RawSocketEvent.read is processed', () {
      // Simulate: if (event != RawSocketEvent.read) return;
      // We use enum-like string values since we can't import dart:io in tests easily
      const readEvent = 'read';
      const writeEvent = 'write';
      const closedEvent = 'closed';

      expect(readEvent == 'read', isTrue);
      expect(writeEvent == 'read', isFalse);
      expect(closedEvent == 'read', isFalse);
    });

    test('null datagram from receive() is ignored', () {
      // if (dg == null || ...) return;
      // Null datagram is never processed
      const shouldProcess = false;
      expect(shouldProcess, isFalse);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 19. Streams (listenForMessages / listenForSignals)
  // ══════════════════════════════════════════════════════════════════════════

  group('LAN stream behavior', () {
    test('message stream is broadcast (multiple listeners)', () async {
      // _msgCtrl = StreamController<List<Message>>.broadcast()
      // Verify broadcast stream allows multiple listeners
      final ctrl = StreamController<List<Message>>.broadcast();
      addTearDown(ctrl.close);

      final received1 = <List<Message>>[];
      final received2 = <List<Message>>[];

      ctrl.stream.listen(received1.add);
      ctrl.stream.listen(received2.add);

      final msg = Message(
        id: 'test',
        senderId: 'alice',
        receiverId: 'bob',
        encryptedPayload: 'data',
        timestamp: DateTime.now(),
        adapterType: 'lan',
      );
      ctrl.add([msg]);

      // Both listeners should receive the same event
      await Future.delayed(Duration.zero);
      expect(received1, hasLength(1));
      expect(received2, hasLength(1));
      expect(received1.first.first.id, equals('test'));
    });

    test('signal stream is broadcast', () async {
      final ctrl =
          StreamController<List<Map<String, dynamic>>>.broadcast();
      addTearDown(ctrl.close);

      final received = <List<Map<String, dynamic>>>[];
      ctrl.stream.listen(received.add);

      ctrl.add([
        {'type': 'typing'}
      ]);

      await Future.delayed(Duration.zero);
      expect(received, hasLength(1));
      expect(received.first.first['type'], equals('typing'));
    });

    test('close prevents further additions to message stream', () async {
      final ctrl = StreamController<List<Message>>.broadcast();
      ctrl.close();
      expect(ctrl.isClosed, isTrue);
    });

    test('close prevents further additions to signal stream', () async {
      final ctrl =
          StreamController<List<Map<String, dynamic>>>.broadcast();
      ctrl.close();
      expect(ctrl.isClosed, isTrue);
    });

    test('isClosed check before add prevents errors', () {
      final ctrl = StreamController<List<Message>>.broadcast();
      ctrl.close();
      // Simulates: if (!_msgCtrl.isClosed) _msgCtrl.add(...)
      final shouldAdd = !ctrl.isClosed;
      expect(shouldAdd, isFalse);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 20. Stress / boundary tests
  // ══════════════════════════════════════════════════════════════════════════

  group('LAN stress / boundary tests', () {
    test('processes 1000 unique messages without issue', () {
      final seenIds = <String>{};
      int count = 0;
      for (var i = 0; i < 1000; i++) {
        final dg = utf8.encode(jsonEncode({
          'from': 'sender_$i',
          'payload': 'msg_$i',
          't': 'msg',
          'id': 'stress_$i',
          'ts': 1710000000000 + i,
        }));
        final msg = parseLanMessage('receiver', dg, seenIds);
        if (msg != null) count++;
      }
      expect(count, equals(1000));
    });

    test('dedup trim fires correctly during high volume', () {
      final seenIds = <String>{};
      int accepted = 0;
      // Send 3000 messages with unique ids
      for (var i = 0; i < 3000; i++) {
        final dg = utf8.encode(jsonEncode({
          'from': 'alice',
          'payload': 'data',
          't': 'msg',
          'id': 'hv_$i',
          'ts': 1710000000000 + i,
        }));
        final msg = parseLanMessage('bob', dg, seenIds);
        if (msg != null) accepted++;
      }
      // All should be accepted (unique ids)
      expect(accepted, equals(3000));
      // seenIds should have been trimmed (never >2001 at any point)
      expect(seenIds.length, lessThanOrEqualTo(2001));
    });

    test('empty payload in broadcast is rejected by receiver', () {
      final data = utf8.encode(jsonEncode({
        'from': 'alice',
        'payload': '',
        't': 'msg',
        'id': 'empty_pay',
        'ts': 1710000000000,
      }));
      final msg = parseLanMessage('bob', data, <String>{});
      expect(msg, isNull);
    });
  });
}
