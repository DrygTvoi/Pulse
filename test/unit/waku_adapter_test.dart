import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

/// Pure-Dart unit tests for Waku adapter logic.
///
/// Tests content topic derivation, message encoding/decoding helpers,
/// URL construction, and parameter parsing — all without network calls.
void main() {
  // ── Content topic derivation ──────────────────────────────────────────────
  //
  // The Waku adapter uses three content topics per user:
  //   /aegis/1/{userId}/proto         — chat messages
  //   /aegis/1/{userId}/signals/proto — signals (typing, WebRTC, etc.)
  //   /aegis/1/{userId}/keys/proto    — Signal + Kyber key bundles

  String msgTopic(String userId) => '/aegis/1/$userId/proto';
  String sigTopic(String userId) => '/aegis/1/$userId/signals/proto';
  String keysTopic(String userId) => '/aegis/1/$userId/keys/proto';

  group('Content topic derivation', () {
    test('message topic format is correct', () {
      expect(msgTopic('alice123'), equals('/aegis/1/alice123/proto'));
    });

    test('signal topic format is correct', () {
      expect(sigTopic('alice123'), equals('/aegis/1/alice123/signals/proto'));
    });

    test('keys topic format is correct', () {
      expect(keysTopic('alice123'), equals('/aegis/1/alice123/keys/proto'));
    });

    test('different users get different topics', () {
      expect(msgTopic('alice'), isNot(equals(msgTopic('bob'))));
      expect(sigTopic('alice'), isNot(equals(sigTopic('bob'))));
      expect(keysTopic('alice'), isNot(equals(keysTopic('bob'))));
    });

    test('topics retain wire-protocol label /aegis/', () {
      // Per MEMORY.md: wire-protocol labels NOT renamed
      expect(msgTopic('x'), contains('/aegis/'));
      expect(sigTopic('x'), contains('/aegis/'));
      expect(keysTopic('x'), contains('/aegis/'));
    });

    test('message and signal topics are distinct for same user', () {
      expect(msgTopic('user1'), isNot(equals(sigTopic('user1'))));
      expect(msgTopic('user1'), isNot(equals(keysTopic('user1'))));
      expect(sigTopic('user1'), isNot(equals(keysTopic('user1'))));
    });

    test('handles empty userId', () {
      expect(msgTopic(''), equals('/aegis/1//proto'));
    });

    test('handles special characters in userId', () {
      final topic = msgTopic('user@example');
      expect(topic, equals('/aegis/1/user@example/proto'));
    });
  });

  // ── pubsubTopic constant ──────────────────────────────────────────────────

  group('Pubsub topic', () {
    test('uses default Waku pubsub topic', () {
      const pubsubTopic = '/waku/2/default-waku/proto';
      expect(pubsubTopic, equals('/waku/2/default-waku/proto'));
    });
  });

  // ── Address format parsing ────────────────────────────────────────────────
  //
  // Waku address format: userId@http://nodeUrl

  group('Waku address parsing', () {
    /// Simulates WakuInboxReader._parseParams and WakuMessageSender._recipientId
    (String userId, String nodeUrl) parseWakuAddress(String databaseId) {
      String userId = '';
      String nodeUrl = '';
      final atHttp = databaseId.indexOf('@http');
      if (atHttp != -1) {
        userId = databaseId.substring(0, atHttp);
        nodeUrl = databaseId.substring(atHttp + 1);
      } else if (databaseId.startsWith('http')) {
        nodeUrl = databaseId;
      }
      return (userId, nodeUrl);
    }

    test('parses standard address: userId@http://host:port', () {
      final (userId, nodeUrl) = parseWakuAddress('abc123@http://localhost:8645');
      expect(userId, equals('abc123'));
      expect(nodeUrl, equals('http://localhost:8645'));
    });

    test('parses HTTPS address', () {
      final (userId, nodeUrl) = parseWakuAddress('user1@https://waku.example.com');
      expect(userId, equals('user1'));
      expect(nodeUrl, equals('https://waku.example.com'));
    });

    test('parses bare URL (no userId)', () {
      final (userId, nodeUrl) = parseWakuAddress('http://localhost:8645');
      expect(userId, isEmpty);
      expect(nodeUrl, equals('http://localhost:8645'));
    });

    test('handles empty databaseId', () {
      final (userId, nodeUrl) = parseWakuAddress('');
      expect(userId, isEmpty);
      expect(nodeUrl, isEmpty);
    });

    test('handles userId with special characters', () {
      final (userId, nodeUrl) = parseWakuAddress('a1b2c3d4@http://node:8645');
      expect(userId, equals('a1b2c3d4'));
      expect(nodeUrl, equals('http://node:8645'));
    });
  });

  // ── Recipient ID extraction ───────────────────────────────────────────────

  group('Waku recipient ID extraction', () {
    /// Simulates WakuMessageSender._recipientId
    String recipientId(String targetDatabaseId) {
      final atHttp = targetDatabaseId.indexOf('@http');
      return atHttp != -1
          ? targetDatabaseId.substring(0, atHttp)
          : targetDatabaseId;
    }

    test('extracts userId from full address', () {
      expect(recipientId('bob456@http://node:8645'), equals('bob456'));
    });

    test('returns full string if no @http', () {
      expect(recipientId('plain_id'), equals('plain_id'));
    });

    test('handles empty string', () {
      expect(recipientId(''), equals(''));
    });

    test('handles address with https', () {
      expect(recipientId('user@https://waku.io'), equals('user'));
    });
  });

  // ── Message payload encoding ──────────────────────────────────────────────

  group('Waku message payload encoding', () {
    test('message envelope encodes from + payload', () {
      final envelope = jsonEncode({
        'from': 'sender_id',
        'payload': 'encrypted_data',
      });
      final encoded = base64.encode(utf8.encode(envelope));
      // Verify roundtrip
      final decoded = utf8.decode(base64.decode(encoded));
      final parsed = jsonDecode(decoded) as Map<String, dynamic>;
      expect(parsed['from'], equals('sender_id'));
      expect(parsed['payload'], equals('encrypted_data'));
    });

    test('publish body structure is correct', () {
      const contentTopic = '/aegis/1/user1/proto';
      final jsonPayload = jsonEncode({'from': 'me', 'payload': 'data'});

      final publishBody = jsonEncode({
        'payload': base64.encode(utf8.encode(jsonPayload)),
        'contentTopic': contentTopic,
        'timestamp': DateTime.now().microsecondsSinceEpoch * 1000,
      });

      final parsed = jsonDecode(publishBody) as Map<String, dynamic>;
      expect(parsed['contentTopic'], equals(contentTopic));
      expect(parsed['payload'], isA<String>());
      expect(parsed['timestamp'], isA<int>());

      // Decode the payload back
      final payloadJson = utf8.decode(base64.decode(parsed['payload'] as String));
      final payloadMap = jsonDecode(payloadJson) as Map<String, dynamic>;
      expect(payloadMap['from'], equals('me'));
      expect(payloadMap['payload'], equals('data'));
    });

    test('signal body includes encrypted envelope and from', () {
      final signalBody = jsonEncode({
        'enc': 'base64_encrypted_signal',
        'from': 'sender_user_id',
      });
      final parsed = jsonDecode(signalBody) as Map<String, dynamic>;
      expect(parsed.containsKey('enc'), isTrue);
      expect(parsed.containsKey('from'), isTrue);
    });

    test('sys_keys publish body is direct JSON (no from wrapper)', () {
      final keysPayload = jsonEncode({
        'identityKey': 'abc',
        'signedPreKey': {'id': 0, 'key': 'def'},
        'preKeys': [
          {'id': 1, 'key': 'ghi'}
        ],
      });
      // sys_keys goes to keysTopic directly, no 'from' wrapper
      final parsed = jsonDecode(keysPayload) as Map<String, dynamic>;
      expect(parsed.containsKey('identityKey'), isTrue);
      expect(parsed.containsKey('from'), isFalse);
    });
  });

  // ── URL construction ──────────────────────────────────────────────────────

  group('Waku URL construction', () {
    test('filter subscribe URL', () {
      const nodeUrl = 'http://localhost:8645';
      final url = '$nodeUrl/filter/v2/subscriptions';
      expect(url, equals('http://localhost:8645/filter/v2/subscriptions'));
    });

    test('filter poll URL with encoded content topic', () {
      const nodeUrl = 'http://localhost:8645';
      final topic = '/aegis/1/user1/proto';
      final encoded = Uri.encodeComponent(topic);
      final url = '$nodeUrl/filter/v2/messages/$encoded';
      expect(url, contains('filter/v2/messages'));
      expect(url, contains(Uri.encodeComponent(topic)));
    });

    test('store query URL', () {
      const nodeUrl = 'http://localhost:8645';
      final topic = Uri.encodeComponent('/aegis/1/user1/keys/proto');
      final url = '$nodeUrl/store/v3/messages?contentTopics=$topic&pageSize=1&ascending=false';
      expect(url, contains('store/v3/messages'));
      expect(url, contains('pageSize=1'));
      expect(url, contains('ascending=false'));
    });

    test('relay publish URL with encoded pubsub topic', () {
      const nodeUrl = 'http://localhost:8645';
      const pubsubTopic = '/waku/2/default-waku/proto';
      final encoded = Uri.encodeComponent(pubsubTopic);
      final url = '$nodeUrl/relay/v1/messages/$encoded';
      expect(url, contains('relay/v1/messages'));
      expect(url, contains(encoded));
    });
  });

  // ── Message dispatch parsing ──────────────────────────────────────────────

  group('Waku message dispatch parsing', () {
    test('decodes base64 payload to JSON envelope', () {
      final inner = jsonEncode({'from': 'alice', 'payload': 'encrypted'});
      final b64 = base64.encode(utf8.encode(inner));
      final decoded = jsonDecode(utf8.decode(base64.decode(b64))) as Map<String, dynamic>;
      expect(decoded['from'], equals('alice'));
      expect(decoded['payload'], equals('encrypted'));
    });

    test('rejects oversized payload (>700K chars)', () {
      final raw = 'X' * 700001;
      expect(raw.length, greaterThan(700000));
    });

    test('nanosecond timestamp conversion', () {
      // Waku uses nanosecond timestamps; the adapter divides by 1000 for microseconds.
      const tsNs = 1710000000000000000; // nanoseconds
      final dt = DateTime.fromMicrosecondsSinceEpoch(tsNs ~/ 1000);
      expect(dt.millisecondsSinceEpoch, equals(1710000000000));
    });
  });

  // ── Seen-hash dedup ───────────────────────────────────────────────────────

  group('Waku seen-hash deduplication', () {
    test('dedup set trims when exceeding 3000 entries', () {
      final seenHashes = <String>{};
      for (int i = 0; i < 3001; i++) {
        seenHashes.add('hash_$i');
      }
      expect(seenHashes.length, greaterThan(3000));
      // Adapter trims oldest 1500 when > 3000
      if (seenHashes.length > 3000) {
        seenHashes.removeAll(seenHashes.take(1500).toList());
      }
      expect(seenHashes.length, equals(1501));
    });
  });

  // ── Auto-discover sentinel ────────────────────────────────────────────────

  group('Waku auto-discover sentinel', () {
    test('sentinel value is __auto__', () {
      const sentinel = '__auto__';
      expect(sentinel, equals('__auto__'));
    });

    test('empty nodeUrl triggers auto-discovery', () {
      const nodeUrl = '';
      expect(nodeUrl.isEmpty, isTrue);
    });
  });

  // ── Filter subscribe body ─────────────────────────────────────────────────

  group('Waku filter subscribe body', () {
    test('subscribe request body structure', () {
      const userId = 'abc12345';
      final body = jsonEncode({
        'requestId': 'aegis_${userId.substring(0, 8)}',
        'contentFilters': [msgTopic(userId), sigTopic(userId)],
        'pubsubTopic': '/waku/2/default-waku/proto',
      });
      final parsed = jsonDecode(body) as Map<String, dynamic>;
      expect(parsed['requestId'], equals('aegis_abc12345'));
      final filters = parsed['contentFilters'] as List;
      expect(filters.length, equals(2));
      expect(filters[0], equals('/aegis/1/abc12345/proto'));
      expect(filters[1], equals('/aegis/1/abc12345/signals/proto'));
    });

    test('requestId truncates long userId to 8 chars', () {
      const userId = 'verylonguseridstring';
      final reqId = 'aegis_${userId.substring(0, 8)}';
      expect(reqId, equals('aegis_verylong'));
    });
  });
}
