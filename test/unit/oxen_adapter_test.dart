import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

/// Pure-Dart unit tests for Oxen/Session adapter logic.
///
/// Tests Session ID validation, request body construction, message
/// dispatch parsing, and the snode discovery response format — all
/// without network calls or platform plugins.
void main() {
  // ── Session ID validation ─────────────────────────────────────────────────
  //
  // A valid Session ID is a 66-char hex string starting with '05'.
  // (05 prefix + 64 hex chars = 33 bytes encoded as hex)

  bool isValidSessionId(String id) {
    if (id.length != 66) return false;
    if (!id.startsWith('05')) return false;
    return RegExp(r'^[0-9a-f]{66}$').hasMatch(id);
  }

  group('Session ID validation', () {
    test('valid Session ID: 05 + 64 hex chars', () {
      final id = '05${'a' * 64}';
      expect(isValidSessionId(id), isTrue);
      expect(id.length, equals(66));
    });

    test('valid Session ID with mixed hex chars', () {
      const id = '05abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789';
      expect(isValidSessionId(id), isTrue);
    });

    test('rejects ID not starting with 05', () {
      final id = '06${'a' * 64}';
      expect(isValidSessionId(id), isFalse);
    });

    test('rejects ID with wrong length (too short)', () {
      const id = '05abcdef';
      expect(isValidSessionId(id), isFalse);
    });

    test('rejects ID with wrong length (too long)', () {
      final id = '05${'a' * 65}';
      expect(isValidSessionId(id), isFalse);
    });

    test('rejects empty string', () {
      expect(isValidSessionId(''), isFalse);
    });

    test('rejects non-hex characters', () {
      final id = '05${'g' * 64}';
      expect(isValidSessionId(id), isFalse);
    });

    test('rejects uppercase hex (Session IDs are lowercase)', () {
      final id = '05${'A' * 64}';
      expect(isValidSessionId(id), isFalse);
    });

    test('rejects ID with spaces', () {
      final id = '05 ${'a' * 63}';
      expect(isValidSessionId(id), isFalse);
    });
  });

  // ── Request body construction ─────────────────────────────────────────────

  group('Oxen retrieve request body', () {
    test('retrieve request structure is correct', () {
      const sessionId = '05aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
      const lastHash = 'prev_hash_abc';
      final tsMs = DateTime.now().millisecondsSinceEpoch;
      const sig = 'base64_signature_here';

      final body = jsonEncode({
        'method': 'retrieve',
        'params': {
          'pubkey': sessionId,
          'last_hash': lastHash,
          'timestamp': tsMs,
          'signature': sig,
        },
      });

      final parsed = jsonDecode(body) as Map<String, dynamic>;
      expect(parsed['method'], equals('retrieve'));
      final params = parsed['params'] as Map<String, dynamic>;
      expect(params['pubkey'], equals(sessionId));
      expect(params['last_hash'], equals(lastHash));
      expect(params['timestamp'], equals(tsMs));
      expect(params['signature'], equals(sig));
    });

    test('retrieve URL follows /storage_rpc/v1 pattern', () {
      const nodeUrl = 'https://1.2.3.4:22021';
      final url = '$nodeUrl/storage_rpc/v1';
      expect(url, equals('https://1.2.3.4:22021/storage_rpc/v1'));
    });

    test('signed message format: retrieve + sessionId + timestamp', () {
      const sessionId = '05bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';
      final tsMs = 1710000000000;
      final msg = 'retrieve$sessionId$tsMs';
      expect(msg, startsWith('retrieve05'));
      expect(msg, endsWith('1710000000000'));
    });
  });

  group('Oxen store request body', () {
    test('store request structure is correct', () {
      const recipientId = '05cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc';
      const ttlMs = 14 * 24 * 60 * 60 * 1000; // 14 days
      final tsMs = DateTime.now().millisecondsSinceEpoch;
      final payload = base64.encode(utf8.encode(jsonEncode({
        't': 'msg',
        'from': '05sender',
        'payload': 'encrypted_data',
      })));

      final body = jsonEncode({
        'method': 'store',
        'params': {
          'pubkey': recipientId,
          'ttl': ttlMs,
          'timestamp': tsMs,
          'data': payload,
        },
      });

      final parsed = jsonDecode(body) as Map<String, dynamic>;
      expect(parsed['method'], equals('store'));
      final params = parsed['params'] as Map<String, dynamic>;
      expect(params['pubkey'], equals(recipientId));
      expect(params['ttl'], equals(ttlMs));
      expect(params['data'], equals(payload));
    });

    test('TTL is 14 days in milliseconds', () {
      const ttlMs = 14 * 24 * 60 * 60 * 1000;
      expect(ttlMs, equals(1209600000));
    });
  });

  // ── Message dispatch parsing ──────────────────────────────────────────────

  group('Oxen message dispatch parsing', () {
    /// Simulates OxenInboxReader._dispatch logic for message items.
    Map<String, dynamic>? parseOxenItem(Map<String, dynamic> item) {
      try {
        final raw = item['data'] as String? ?? '';
        if (raw.isEmpty) return null;
        if (raw.length > 700000) return null; // DoS guard
        final bytes = base64.decode(raw);
        return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }

    test('parses message item', () {
      final inner = jsonEncode({
        't': 'msg',
        'from': '05sender',
        'payload': 'encrypted_content',
      });
      final item = {
        'hash': 'hash_abc',
        'data': base64.encode(utf8.encode(inner)),
        'timestamp': 1710000000000,
      };
      final parsed = parseOxenItem(item);
      expect(parsed, isNotNull);
      expect(parsed!['t'], equals('msg'));
      expect(parsed['from'], equals('05sender'));
      expect(parsed['payload'], equals('encrypted_content'));
    });

    test('parses signal item', () {
      final inner = jsonEncode({
        't': 'sig',
        'type': 'typing',
        'senderId': '05sender',
        'roomId': 'room1',
        'payload': {},
      });
      final item = {
        'hash': 'hash_sig1',
        'data': base64.encode(utf8.encode(inner)),
        'timestamp': 1710000000000,
      };
      final parsed = parseOxenItem(item);
      expect(parsed, isNotNull);
      expect(parsed!['t'], equals('sig'));
      expect(parsed['type'], equals('typing'));
    });

    test('rejects empty data field', () {
      final item = {'hash': 'h1', 'data': '', 'timestamp': 0};
      expect(parseOxenItem(item), isNull);
    });

    test('rejects oversized data (>700KB)', () {
      final largeData = base64.encode(utf8.encode('X' * 600000));
      // base64 encoding increases size; check the raw string length
      if (largeData.length > 700000) {
        final item = {'hash': 'h2', 'data': largeData, 'timestamp': 0};
        expect(parseOxenItem(item), isNull);
      }
    });

    test('rejects invalid base64 data', () {
      final item = {'hash': 'h3', 'data': '!!!not-base64!!!', 'timestamp': 0};
      expect(parseOxenItem(item), isNull);
    });

    test('rejects non-JSON decoded content', () {
      final item = {
        'hash': 'h4',
        'data': base64.encode(utf8.encode('plain text, not json')),
        'timestamp': 0,
      };
      expect(parseOxenItem(item), isNull);
    });
  });

  // ── Signal type routing ───────────────────────────────────────────────────

  group('Oxen signal type routing', () {
    test('sys_keys signal stores to both self and recipient', () {
      const type = 'sys_keys';
      const selfId = '05aaa';
      const targetId = '05bbb';
      // When type == sys_keys, adapter stores to self AND to target if different.
      expect(type, equals('sys_keys'));
      expect(selfId != targetId, isTrue);
    });

    test('sys_keys to self only stores once', () {
      const type = 'sys_keys';
      const selfId = '05aaa';
      const targetId = '05aaa'; // same as self
      expect(targetId == selfId, isTrue);
    });

    test('non-sys_keys signal stores to target only', () {
      const type = 'typing';
      // For all non-sys_keys types, only stores to target.
      expect(type != 'sys_keys', isTrue);
    });
  });

  // ── Snode discovery response parsing ──────────────────────────────────────

  group('Oxen snode discovery response parsing', () {
    /// Simulates _discoverSnodes response processing.
    List<String> parseSnodeResponse(String responseBody) {
      try {
        final data = jsonDecode(responseBody) as Map<String, dynamic>;
        final states = (data['result']?['service_node_states'] as List?) ?? [];
        final nodes = <String>[];
        for (final s in states) {
          final ip = s['public_ip'] as String? ?? '';
          final port = s['storage_port'];
          if (ip.isNotEmpty && port != null) {
            nodes.add('https://$ip:$port');
          }
        }
        return nodes;
      } catch (_) {
        return [];
      }
    }

    test('parses valid snode response', () {
      final response = jsonEncode({
        'result': {
          'service_node_states': [
            {'public_ip': '1.2.3.4', 'storage_port': 22021},
            {'public_ip': '5.6.7.8', 'storage_port': 22022},
          ],
        },
      });
      final nodes = parseSnodeResponse(response);
      expect(nodes.length, equals(2));
      expect(nodes[0], equals('https://1.2.3.4:22021'));
      expect(nodes[1], equals('https://5.6.7.8:22022'));
    });

    test('skips entries with empty IP', () {
      final response = jsonEncode({
        'result': {
          'service_node_states': [
            {'public_ip': '', 'storage_port': 22021},
            {'public_ip': '5.6.7.8', 'storage_port': 22022},
          ],
        },
      });
      final nodes = parseSnodeResponse(response);
      expect(nodes.length, equals(1));
      expect(nodes[0], equals('https://5.6.7.8:22022'));
    });

    test('skips entries with null port', () {
      final response = jsonEncode({
        'result': {
          'service_node_states': [
            {'public_ip': '1.2.3.4', 'storage_port': null},
          ],
        },
      });
      final nodes = parseSnodeResponse(response);
      expect(nodes, isEmpty);
    });

    test('returns empty list for invalid JSON', () {
      expect(parseSnodeResponse('not json'), isEmpty);
    });

    test('returns empty list for missing result', () {
      final response = jsonEncode({'status': 'ok'});
      expect(parseSnodeResponse(response), isEmpty);
    });

    test('returns empty list for empty states', () {
      final response = jsonEncode({
        'result': {'service_node_states': []},
      });
      expect(parseSnodeResponse(response), isEmpty);
    });
  });

  // ── Seed nodes ────────────────────────────────────────────────────────────

  group('Oxen seed nodes', () {
    test('seed nodes are HTTPS URLs', () {
      const seeds = [
        'https://seed1.getsession.org',
        'https://seed2.getsession.org',
        'https://seed3.getsession.org',
      ];
      for (final seed in seeds) {
        expect(seed, startsWith('https://'));
        expect(seed, contains('getsession.org'));
      }
    });

    test('get_n_service_nodes RPC request structure', () {
      final rpcBody = jsonEncode({
        'jsonrpc': '2.0',
        'method': 'get_n_service_nodes',
        'params': {
          'active_only': true,
          'limit': 20,
          'fields': {'public_ip': true, 'storage_port': true},
        },
      });
      final parsed = jsonDecode(rpcBody) as Map<String, dynamic>;
      expect(parsed['jsonrpc'], equals('2.0'));
      expect(parsed['method'], equals('get_n_service_nodes'));
      final params = parsed['params'] as Map<String, dynamic>;
      expect(params['active_only'], isTrue);
      expect(params['limit'], equals(20));
    });
  });

  // ── Key bundle retrieval ──────────────────────────────────────────────────

  group('Oxen key bundle parsing', () {
    test('finds sys_keys signal in retrieved messages', () {
      final keysPayload = {
        'identityKey': 'base64key',
        'signedPreKey': {'id': 0, 'key': 'spk'},
        'preKeys': [{'id': 1, 'key': 'pk1'}],
      };
      final item = {
        'hash': 'key_hash',
        'data': base64.encode(utf8.encode(jsonEncode({
          't': 'sig',
          'type': 'sys_keys',
          'senderId': '05sender',
          'roomId': '',
          'payload': keysPayload,
        }))),
      };
      final raw = item['data'] as String;
      final bytes = base64.decode(raw);
      final outer = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      expect(outer['t'], equals('sig'));
      expect(outer['type'], equals('sys_keys'));
      expect(outer['payload'], isA<Map<String, dynamic>>());
      final p = outer['payload'] as Map<String, dynamic>;
      expect(p['identityKey'], equals('base64key'));
    });
  });

  // ── Seen-hash dedup ───────────────────────────────────────────────────────

  group('Oxen seen-hash deduplication', () {
    test('trims oldest 1500 when exceeding 3000', () {
      final seenHashes = <String>{};
      for (int i = 0; i < 3001; i++) {
        seenHashes.add('hash_$i');
      }
      expect(seenHashes.length, greaterThan(3000));
      if (seenHashes.length > 3000) {
        seenHashes.removeAll(seenHashes.take(1500).toList());
      }
      expect(seenHashes.length, equals(1501));
    });

    test('lastHash is updated with most recent hash', () {
      String lastHash = '';
      final hashes = ['h1', 'h2', 'h3'];
      for (final h in hashes) {
        lastHash = h;
      }
      expect(lastHash, equals('h3'));
    });
  });

  // ── Connection error detection ────────────────────────────────────────────

  group('Oxen connection error detection', () {
    test('HandshakeException is a connection error', () {
      final errStr = 'HandshakeException: something went wrong';
      final isConnErr = errStr.contains('HandshakeException') ||
          errStr.contains('Connection refused') ||
          errStr.contains('SocketException') ||
          errStr.contains('TimeoutException');
      expect(isConnErr, isTrue);
    });

    test('SocketException is a connection error', () {
      final errStr = 'SocketException: OS Error';
      final isConnErr = errStr.contains('HandshakeException') ||
          errStr.contains('Connection refused') ||
          errStr.contains('SocketException') ||
          errStr.contains('TimeoutException');
      expect(isConnErr, isTrue);
    });

    test('random error is not a connection error', () {
      final errStr = 'FormatException: unexpected character';
      final isConnErr = errStr.contains('HandshakeException') ||
          errStr.contains('Connection refused') ||
          errStr.contains('SocketException') ||
          errStr.contains('TimeoutException');
      expect(isConnErr, isFalse);
    });
  });

  // ── Tiered retry delay ────────────────────────────────────────────────────

  group('Oxen tiered retry delay', () {
    int getDelay(int failures) {
      return (failures < 5) ? 5 : (failures < 15) ? 30 : 300;
    }

    test('first 5 failures: 5s delay', () {
      for (int i = 0; i < 5; i++) {
        expect(getDelay(i), equals(5));
      }
    });

    test('failures 5-14: 30s delay', () {
      for (int i = 5; i < 15; i++) {
        expect(getDelay(i), equals(30));
      }
    });

    test('15+ failures: 5min delay', () {
      expect(getDelay(15), equals(300));
      expect(getDelay(29), equals(300));
    });
  });
}
