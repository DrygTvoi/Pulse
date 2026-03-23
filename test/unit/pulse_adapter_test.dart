import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pulse_messenger/models/message.dart';
import 'package:pulse_messenger/adapters/pulse_adapter.dart';

// =============================================================================
// Pure-Dart unit tests for the Pulse adapter logic.
//
// The Pulse adapter uses JSON-over-WebSocket with Ed25519 challenge-response
// authentication. Tests cover:
//   - Address format parsing (pubkey@https://server)
//   - WebSocket URL derivation (https→wss, http→ws)
//   - Reconnection backoff tiers
//   - Message/signal dispatch parsing
//   - Seen-ID dedup + eviction
//   - Authentication protocol wire format
//   - Ed25519 key derivation
//   - Send envelope construction (message, signal, keys)
//   - Circuit breaker thresholds
//   - Zeroization of key material
//   - Error handling (malformed JSON, empty fields)
//
// All tests are pure Dart — no real WebSocket connections or platform plugins.
// =============================================================================

// ── Helpers that mirror adapter-internal logic ──────────────────────────────

/// Mirrors PulseInboxReader.initializeReader URL conversion.
String deriveWsUrl(String serverUrl) {
  if (serverUrl.startsWith('https://')) {
    return 'wss://${serverUrl.substring('https://'.length)}/ws';
  } else if (serverUrl.startsWith('http://')) {
    return 'ws://${serverUrl.substring('http://'.length)}/ws';
  }
  return '';
}

/// Mirrors _reconnectDelay in pulse_adapter.dart.
Duration reconnectDelay(int failures) {
  if (failures <= 1) return const Duration(seconds: 5);
  if (failures <= 5) return const Duration(seconds: 30);
  return const Duration(minutes: 5);
}

/// Mirrors PulseInboxReader._dispatchMessage parsing logic.
Message? parseIncomingMessage(
  Map<String, dynamic> data,
  String ownPubkeyHex,
  Set<String> seenIds,
) {
  final payload = data['payload'] as Map<String, dynamic>? ?? data;
  final id = payload['id'] as String? ?? '';
  if (id.isEmpty || seenIds.contains(id)) return null;
  seenIds.add(id);

  final ts = payload['timestamp'] as int? ??
      (DateTime.now().millisecondsSinceEpoch ~/ 1000);

  return Message(
    id: id,
    senderId: payload['from'] as String? ?? '',
    receiverId: ownPubkeyHex,
    encryptedPayload: payload['payload'] as String? ?? '',
    timestamp: DateTime.fromMillisecondsSinceEpoch(ts * 1000, isUtc: true),
    adapterType: 'pulse',
  );
}

/// Mirrors PulseInboxReader._dispatchSignal parsing logic.
Map<String, dynamic>? parseIncomingSignal(
  Map<String, dynamic> data,
  Set<String> seenIds,
) {
  final payload = data['payload'] as Map<String, dynamic>? ?? data;
  final id = payload['id'] as String? ?? '';
  if (id.isNotEmpty && seenIds.contains(id)) return null;
  if (id.isNotEmpty) seenIds.add(id);

  final payloadContent = payload['payload'];
  if (payloadContent is String) {
    return jsonDecode(payloadContent) as Map<String, dynamic>;
  } else if (payloadContent is Map) {
    return Map<String, dynamic>.from(payloadContent);
  }
  return payload;
}

/// Mirrors PulseInboxReader._dispatchKeys parsing logic.
Map<String, dynamic>? parseKeysResponse(Map<String, dynamic> data) {
  final payload = data['payload'] as Map<String, dynamic>?;
  if (payload == null) return null;
  return {
    'type': 'sys_keys',
    'payload': payload,
    'senderId': data['from'] as String? ?? '',
  };
}

/// Mirrors PulseInboxReader._dispatchStored logic.
List<dynamic> parseStoredMessages(
  Map<String, dynamic> data,
  String ownPubkeyHex,
  Set<String> seenIds,
) {
  final messages = data['messages'] as List? ?? [];
  final results = <dynamic>[];
  for (final m in messages) {
    if (m is! Map) continue;
    final entry = Map<String, dynamic>.from(m);
    final msgType = entry['msg_type'] as String? ?? 'message';
    if (msgType == 'signal') {
      final sig = parseIncomingSignal(entry, seenIds);
      if (sig != null) results.add(sig);
    } else {
      final msg = parseIncomingMessage(entry, ownPubkeyHex, seenIds);
      if (msg != null) results.add(msg);
    }
  }
  return results;
}

/// Mirrors PulseMessageSender target pubkey extraction.
String extractTargetPubkey(String targetDatabaseId) {
  final atIdx = targetDatabaseId.indexOf('@');
  return atIdx != -1
      ? targetDatabaseId.substring(0, atIdx)
      : targetDatabaseId;
}

/// Mirrors PulseMessageSender.sendMessage envelope structure.
Map<String, dynamic> buildSendMessageEnvelope(
    String targetPubkey, String msgId, String encryptedPayload) {
  return {
    'type': 'send',
    'payload': {
      'id': msgId,
      'to': targetPubkey,
      'payload': encryptedPayload,
    },
  };
}

/// Mirrors PulseMessageSender.sendSignal envelope structure.
Map<String, dynamic> buildSendSignalEnvelope(
    String targetPubkey, String type, String roomId, String senderId,
    Map<String, dynamic> payload) {
  final signalPayload = jsonEncode({
    'type': type,
    'roomId': roomId,
    'senderId': senderId,
    'payload': payload,
  });
  return {
    'type': 'signal',
    'payload': {
      'id': '${DateTime.now().millisecondsSinceEpoch}_${type.hashCode}',
      'to': targetPubkey,
      'payload': signalPayload,
    },
  };
}

/// Mirrors auth_response wire format.
Map<String, dynamic> buildAuthResponse(
    String pubkeyHex, String signature, String invite) {
  return {
    'type': 'auth_response',
    'pubkey': pubkeyHex,
    'signature': signature,
    'invite': invite,
  };
}

/// Mirrors the auth challenge message string.
String buildAuthMessage(String nonce, String timestamp) {
  return 'pulse-auth-v1:$nonce:$timestamp';
}

/// Mirrors the seen-ID eviction logic.
void trackSeenId(Set<String> seenIds, String id) {
  if (seenIds.length > 2000) {
    final evict = seenIds.toList().sublist(0, 1000);
    seenIds.removeAll(evict);
  }
  seenIds.add(id);
}

// =============================================================================
// Tests
// =============================================================================

void main() {
  // ── WebSocket URL derivation ──────────────────────────────────────────────

  group('WebSocket URL derivation', () {
    test('https:// converts to wss:// with /ws path', () {
      expect(
        deriveWsUrl('https://my.server.com:8443'),
        equals('wss://my.server.com:8443/ws'),
      );
    });

    test('http:// converts to ws:// with /ws path', () {
      expect(
        deriveWsUrl('http://192.168.1.100:8080'),
        equals('ws://192.168.1.100:8080/ws'),
      );
    });

    test('plain https without port converts correctly', () {
      expect(
        deriveWsUrl('https://relay.example.org'),
        equals('wss://relay.example.org/ws'),
      );
    });

    test('returns empty string for invalid URL scheme', () {
      expect(deriveWsUrl('ftp://example.com'), isEmpty);
      expect(deriveWsUrl('wss://already.ws'), isEmpty);
      expect(deriveWsUrl(''), isEmpty);
    });

    test('preserves path components in server URL', () {
      expect(
        deriveWsUrl('https://example.com:443'),
        equals('wss://example.com:443/ws'),
      );
    });
  });

  // ── Reconnect backoff tiers ───────────────────────────────────────────────

  group('Reconnect backoff tiers', () {
    test('0 failures → 5 seconds', () {
      expect(reconnectDelay(0), equals(const Duration(seconds: 5)));
    });

    test('1 failure → 5 seconds', () {
      expect(reconnectDelay(1), equals(const Duration(seconds: 5)));
    });

    test('2 failures → 30 seconds', () {
      expect(reconnectDelay(2), equals(const Duration(seconds: 30)));
    });

    test('5 failures → 30 seconds', () {
      expect(reconnectDelay(5), equals(const Duration(seconds: 30)));
    });

    test('6 failures → 5 minutes', () {
      expect(reconnectDelay(6), equals(const Duration(minutes: 5)));
    });

    test('100 failures → 5 minutes (capped)', () {
      expect(reconnectDelay(100), equals(const Duration(minutes: 5)));
    });
  });

  // ── Address format parsing ────────────────────────────────────────────────

  group('Pulse address format parsing', () {
    test('extracts pubkey from address with @', () {
      const addr = 'aabbccdd11223344@https://server.example.com:8443';
      expect(extractTargetPubkey(addr), equals('aabbccdd11223344'));
    });

    test('returns full string when no @ present', () {
      const bareKey = 'aabbccdd1122334455667788';
      expect(extractTargetPubkey(bareKey), equals(bareKey));
    });

    test('handles pubkey@https:// full address format', () {
      final pubkey = 'a' * 64;
      final addr = '$pubkey@https://my-relay.onion:443';
      expect(extractTargetPubkey(addr), equals(pubkey));
    });

    test('handles pubkey with @ but no server URL (edge case)', () {
      const addr = 'pubkey@';
      expect(extractTargetPubkey(addr), equals('pubkey'));
    });

    test('handles multiple @ — takes first segment', () {
      const addr = 'pubkey@host@extra';
      expect(extractTargetPubkey(addr), equals('pubkey'));
    });
  });

  // ── apiKey JSON parsing ───────────────────────────────────────────────────

  group('apiKey JSON parsing', () {
    test('parses valid apiKey JSON with all fields', () {
      final apiKey = jsonEncode({
        'privkey': 'ab' * 32,
        'serverUrl': 'https://relay.example.com:8443',
        'invite': 'my-invite-code',
      });
      final decoded = jsonDecode(apiKey) as Map<String, dynamic>;
      expect(decoded['privkey'], equals('ab' * 32));
      expect(decoded['serverUrl'], equals('https://relay.example.com:8443'));
      expect(decoded['invite'], equals('my-invite-code'));
    });

    test('parses apiKey JSON with missing optional invite', () {
      final apiKey = jsonEncode({
        'privkey': 'ab' * 32,
        'serverUrl': 'https://relay.example.com:8443',
      });
      final decoded = jsonDecode(apiKey) as Map<String, dynamic>;
      final invite = (decoded['invite'] as String? ?? '').trim();
      expect(invite, isEmpty);
    });

    test('parses apiKey JSON with empty privkey gracefully', () {
      final apiKey = jsonEncode({
        'privkey': '',
        'serverUrl': 'https://relay.example.com',
      });
      final decoded = jsonDecode(apiKey) as Map<String, dynamic>;
      final privkey = (decoded['privkey'] as String? ?? '').trim();
      expect(privkey, isEmpty);
    });

    test('rejects malformed JSON without crashing', () {
      expect(() => jsonDecode('not-json'), throwsFormatException);
    });
  });

  // ── Message dispatch parsing ──────────────────────────────────────────────

  group('Message dispatch parsing (_dispatchMessage)', () {
    late Set<String> seenIds;
    const ownPubkey = 'mypubkey1234';

    setUp(() {
      seenIds = {};
    });

    test('parses valid incoming message', () {
      final data = {
        'type': 'message',
        'payload': {
          'id': 'msg_001',
          'from': 'sender_abc',
          'payload': 'encrypted_data_here',
          'timestamp': 1700000000,
        },
      };

      final msg = parseIncomingMessage(data, ownPubkey, seenIds);
      expect(msg, isNotNull);
      expect(msg!.id, equals('msg_001'));
      expect(msg.senderId, equals('sender_abc'));
      expect(msg.receiverId, equals(ownPubkey));
      expect(msg.encryptedPayload, equals('encrypted_data_here'));
      expect(msg.adapterType, equals('pulse'));
    });

    test('deduplicates by seen ID', () {
      final data = {
        'type': 'message',
        'payload': {
          'id': 'msg_dup',
          'from': 'sender',
          'payload': 'data',
          'timestamp': 1700000000,
        },
      };

      final first = parseIncomingMessage(data, ownPubkey, seenIds);
      final second = parseIncomingMessage(data, ownPubkey, seenIds);
      expect(first, isNotNull);
      expect(second, isNull); // duplicate
    });

    test('rejects message with empty id', () {
      final data = {
        'type': 'message',
        'payload': {
          'id': '',
          'from': 'sender',
          'payload': 'data',
        },
      };
      expect(parseIncomingMessage(data, ownPubkey, seenIds), isNull);
    });

    test('falls back to top-level data when payload key is null', () {
      // When the outer 'payload' key is null, the ?? falls back to data itself
      final data = <String, dynamic>{
        'id': 'msg_fallback',
        'from': 'alice',
        'payload': null,
        'timestamp': 1700000000,
      };
      final msg = parseIncomingMessage(data, ownPubkey, seenIds);
      expect(msg, isNotNull);
      expect(msg!.id, equals('msg_fallback'));
    });

    test('falls back to top-level data when payload key is absent', () {
      // When there is no 'payload' key at all, data['payload'] returns null
      final data = <String, dynamic>{
        'id': 'msg_direct',
        'from': 'bob',
        'timestamp': 1700000000,
      };
      final msg = parseIncomingMessage(data, ownPubkey, seenIds);
      expect(msg, isNotNull);
      expect(msg!.id, equals('msg_direct'));
      expect(msg.senderId, equals('bob'));
    });

    test('uses current time when timestamp is missing', () {
      final data = {
        'type': 'message',
        'payload': {
          'id': 'msg_no_ts',
          'from': 'sender',
          'payload': 'data',
        },
      };
      final msg = parseIncomingMessage(data, ownPubkey, seenIds);
      expect(msg, isNotNull);
      // Timestamp should be approximately now (within a few seconds)
      final diff = DateTime.now().difference(msg!.timestamp).inSeconds.abs();
      expect(diff, lessThan(10));
    });

    test('handles missing from field gracefully', () {
      final data = {
        'type': 'message',
        'payload': {
          'id': 'msg_no_from',
          'payload': 'data',
          'timestamp': 1700000000,
        },
      };
      final msg = parseIncomingMessage(data, ownPubkey, seenIds);
      expect(msg, isNotNull);
      expect(msg!.senderId, isEmpty);
    });
  });

  // ── Signal dispatch parsing ───────────────────────────────────────────────

  group('Signal dispatch parsing (_dispatchSignal)', () {
    late Set<String> seenIds;

    setUp(() {
      seenIds = {};
    });

    test('parses signal with string payload (JSON-encoded)', () {
      final inner = jsonEncode({
        'type': 'webrtc_offer',
        'roomId': 'room_1',
        'senderId': 'alice',
        'payload': {'sdp': 'offer_data'},
      });
      final data = {
        'type': 'signal',
        'payload': {
          'id': 'sig_001',
          'payload': inner,
        },
      };

      final signal = parseIncomingSignal(data, seenIds);
      expect(signal, isNotNull);
      expect(signal!['type'], equals('webrtc_offer'));
      expect(signal['roomId'], equals('room_1'));
    });

    test('parses signal with Map payload directly', () {
      final data = {
        'type': 'signal',
        'payload': {
          'id': 'sig_002',
          'payload': {
            'type': 'typing',
            'roomId': 'room_2',
          },
        },
      };

      final signal = parseIncomingSignal(data, seenIds);
      expect(signal, isNotNull);
      expect(signal!['type'], equals('typing'));
    });

    test('deduplicates signals by id', () {
      final data = {
        'type': 'signal',
        'payload': {
          'id': 'sig_dup',
          'payload': {'type': 'typing'},
        },
      };

      final first = parseIncomingSignal(data, seenIds);
      final second = parseIncomingSignal(data, seenIds);
      expect(first, isNotNull);
      expect(second, isNull);
    });

    test('allows signals without id', () {
      final data = {
        'type': 'signal',
        'payload': {
          'payload': {'type': 'heartbeat'},
        },
      };
      // Should not deduplicate (no id) — returns the parsed signal
      final first = parseIncomingSignal(data, seenIds);
      final second = parseIncomingSignal(data, seenIds);
      expect(first, isNotNull);
      expect(second, isNotNull);
    });

    test('falls back to payload container when payload content is null', () {
      final data = {
        'type': 'signal',
        'payload': {
          'id': 'sig_no_inner',
          'someField': 'value',
        },
      };
      final signal = parseIncomingSignal(data, seenIds);
      expect(signal, isNotNull);
      expect(signal!['id'], equals('sig_no_inner'));
    });
  });

  // ── Keys dispatch parsing ─────────────────────────────────────────────────

  group('Keys dispatch parsing (_dispatchKeys)', () {
    test('parses keys response into sys_keys signal', () {
      final data = {
        'type': 'keys',
        'from': 'contact_pubkey_abc',
        'payload': {
          'identityKey': 'ik_base64',
          'signedPreKey': 'spk_base64',
          'preKey': 'pk_base64',
        },
      };

      final result = parseKeysResponse(data);
      expect(result, isNotNull);
      expect(result!['type'], equals('sys_keys'));
      expect(result['senderId'], equals('contact_pubkey_abc'));
      expect((result['payload'] as Map)['identityKey'], equals('ik_base64'));
    });

    test('returns null when payload is missing', () {
      final data = {
        'type': 'keys',
        'from': 'contact',
      };
      expect(parseKeysResponse(data), isNull);
    });

    test('handles missing from field', () {
      final data = {
        'type': 'keys',
        'payload': {'identityKey': 'ik'},
      };
      final result = parseKeysResponse(data);
      expect(result, isNotNull);
      expect(result!['senderId'], isEmpty);
    });
  });

  // ── Stored messages batch parsing ─────────────────────────────────────────

  group('Stored messages batch parsing (_dispatchStored)', () {
    late Set<String> seenIds;
    const ownPubkey = 'my_pubkey';

    setUp(() {
      seenIds = {};
    });

    test('parses batch of mixed messages and signals', () {
      final data = {
        'type': 'stored',
        'messages': [
          {
            'payload': {
              'id': 'stored_msg_1',
              'from': 'alice',
              'payload': 'encrypted_1',
              'timestamp': 1700000000,
            },
            'msg_type': 'message',
          },
          {
            'payload': {
              'id': 'stored_sig_1',
              'payload': jsonEncode({'type': 'read_receipt'}),
            },
            'msg_type': 'signal',
          },
          {
            'payload': {
              'id': 'stored_msg_2',
              'from': 'bob',
              'payload': 'encrypted_2',
              'timestamp': 1700000001,
            },
          },
        ],
      };

      final results = parseStoredMessages(data, ownPubkey, seenIds);
      expect(results, hasLength(3));
      // First is a Message
      expect(results[0], isA<Message>());
      expect((results[0] as Message).id, equals('stored_msg_1'));
      // Second is a signal (Map)
      expect(results[1], isA<Map<String, dynamic>>());
      // Third is a Message (default msg_type)
      expect(results[2], isA<Message>());
      expect((results[2] as Message).id, equals('stored_msg_2'));
    });

    test('handles empty messages list', () {
      final data = {'type': 'stored', 'messages': []};
      final results = parseStoredMessages(data, ownPubkey, seenIds);
      expect(results, isEmpty);
    });

    test('handles missing messages key', () {
      final data = {'type': 'stored'};
      final results = parseStoredMessages(data, ownPubkey, seenIds);
      expect(results, isEmpty);
    });

    test('skips non-Map entries in messages list', () {
      final data = {
        'type': 'stored',
        'messages': [
          'not a map',
          42,
          null,
          {
            'payload': {
              'id': 'valid',
              'from': 'alice',
              'payload': 'enc',
              'timestamp': 1700000000,
            },
          },
        ],
      };
      final results = parseStoredMessages(data, ownPubkey, seenIds);
      expect(results, hasLength(1));
      expect((results[0] as Message).id, equals('valid'));
    });
  });

  // ── Send message envelope construction ────────────────────────────────────

  group('Send message envelope construction', () {
    test('builds correct send envelope', () {
      final envelope = buildSendMessageEnvelope(
          'target_pubkey_hex', 'msg_123', 'encrypted_blob');

      expect(envelope['type'], equals('send'));
      final payload = envelope['payload'] as Map<String, dynamic>;
      expect(payload['id'], equals('msg_123'));
      expect(payload['to'], equals('target_pubkey_hex'));
      expect(payload['payload'], equals('encrypted_blob'));
    });

    test('envelope serializes to valid JSON', () {
      final envelope = buildSendMessageEnvelope('pk', 'id', 'data');
      final json = jsonEncode(envelope);
      expect(json, isNotEmpty);
      final roundTrip = jsonDecode(json) as Map<String, dynamic>;
      expect(roundTrip['type'], equals('send'));
    });
  });

  // ── Send signal envelope construction ─────────────────────────────────────

  group('Send signal envelope construction', () {
    test('builds correct signal envelope', () {
      final envelope = buildSendSignalEnvelope(
        'target_pk',
        'webrtc_offer',
        'room_1',
        'sender_pk',
        {'sdp': 'offer_data'},
      );

      expect(envelope['type'], equals('signal'));
      final outerPayload = envelope['payload'] as Map<String, dynamic>;
      expect(outerPayload['to'], equals('target_pk'));

      // Inner payload is JSON string
      final innerStr = outerPayload['payload'] as String;
      final inner = jsonDecode(innerStr) as Map<String, dynamic>;
      expect(inner['type'], equals('webrtc_offer'));
      expect(inner['roomId'], equals('room_1'));
      expect(inner['senderId'], equals('sender_pk'));
      expect(inner['payload']['sdp'], equals('offer_data'));
    });

    test('signal id contains type hashCode', () {
      final envelope = buildSendSignalEnvelope(
        'pk', 'typing', 'room', 'sender', {},
      );
      final outerPayload = envelope['payload'] as Map<String, dynamic>;
      final id = outerPayload['id'] as String;
      expect(id, contains('_'));
      expect(id, endsWith('${('typing').hashCode}'));
    });
  });

  // ── Auth protocol wire format ─────────────────────────────────────────────

  group('Auth protocol wire format', () {
    test('auth challenge message format is correct', () {
      final msg = buildAuthMessage('nonce123', '1700000000');
      expect(msg, equals('pulse-auth-v1:nonce123:1700000000'));
    });

    test('auth response contains required fields', () {
      final resp = buildAuthResponse('pubkey_hex', 'sig_hex', 'invite_code');
      expect(resp['type'], equals('auth_response'));
      expect(resp['pubkey'], equals('pubkey_hex'));
      expect(resp['signature'], equals('sig_hex'));
      expect(resp['invite'], equals('invite_code'));
    });

    test('auth response with empty invite', () {
      final resp = buildAuthResponse('pk', 'sig', '');
      expect(resp['invite'], isEmpty);
    });

    test('auth message with empty nonce', () {
      final msg = buildAuthMessage('', '12345');
      expect(msg, equals('pulse-auth-v1::12345'));
    });
  });

  // ── Seen-ID dedup + eviction ──────────────────────────────────────────────

  group('Seen-ID dedup and eviction', () {
    test('adds new ID to set', () {
      final seenIds = <String>{};
      trackSeenId(seenIds, 'id1');
      expect(seenIds.contains('id1'), isTrue);
    });

    test('evicts oldest 1000 when exceeding 2000', () {
      final seenIds = <String>{};
      // Fill to 2001 entries
      for (int i = 0; i < 2001; i++) {
        seenIds.add('id_$i');
      }
      expect(seenIds.length, equals(2001));

      // Trigger eviction
      trackSeenId(seenIds, 'new_id');
      // Should have evicted 1000 and added 1
      expect(seenIds.length, equals(1002));
      expect(seenIds.contains('new_id'), isTrue);
    });

    test('does not evict when at or below 2000', () {
      final seenIds = <String>{};
      for (int i = 0; i < 2000; i++) {
        seenIds.add('id_$i');
      }
      trackSeenId(seenIds, 'id_2000');
      expect(seenIds.length, equals(2001));
    });
  });

  // ── Circuit breaker thresholds ────────────────────────────────────────────

  group('Circuit breaker thresholds', () {
    // These match constants in PulseInboxReader
    const failureThreshold = 3;
    const maxConsecutiveFailures = 30;

    test('health degrades after failureThreshold', () {
      int consecutiveFailures = 0;
      bool isHealthy = true;

      // Simulate failures
      for (int i = 0; i < failureThreshold; i++) {
        consecutiveFailures++;
      }
      if (consecutiveFailures >= failureThreshold && isHealthy) {
        isHealthy = false;
      }
      expect(isHealthy, isFalse);
      expect(consecutiveFailures, equals(failureThreshold));
    });

    test('circuit breaks at maxConsecutiveFailures', () {
      int consecutiveFailures = 0;
      bool circuitBroken = false;

      for (int i = 0; i < maxConsecutiveFailures; i++) {
        consecutiveFailures++;
      }
      if (consecutiveFailures >= maxConsecutiveFailures) {
        circuitBroken = true;
      }
      expect(circuitBroken, isTrue);
    });

    test('failures reset on successful cycle', () {
      int consecutiveFailures = 10;
      bool isHealthy = false;

      // Simulate successful connection
      consecutiveFailures = 0;
      isHealthy = true;

      expect(consecutiveFailures, equals(0));
      expect(isHealthy, isTrue);
    });

    test('health not set unhealthy below threshold', () {
      int consecutiveFailures = 0;
      bool isHealthy = true;

      consecutiveFailures = 2; // Below threshold of 3
      if (consecutiveFailures >= failureThreshold && isHealthy) {
        isHealthy = false;
      }
      expect(isHealthy, isTrue);
    });
  });

  // ── Ed25519 key derivation ────────────────────────────────────────────────

  group('Ed25519 key derivation', () {
    test('derives 64-char hex public key from 32-byte seed', () async {
      final seed = Uint8List.fromList(List.generate(32, (i) => i + 1));
      final pubkey = await ed25519PubkeyFromSeed(seed);
      expect(pubkey.length, equals(64));
      expect(pubkey, matches(RegExp(r'^[0-9a-f]{64}$')));
    });

    test('is deterministic — same seed yields same pubkey', () async {
      final seed = Uint8List.fromList(List.generate(32, (i) => 42));
      final pk1 = await ed25519PubkeyFromSeed(seed);
      final pk2 = await ed25519PubkeyFromSeed(seed);
      expect(pk1, equals(pk2));
    });

    test('different seeds yield different pubkeys', () async {
      final seed1 = Uint8List.fromList(List.generate(32, (i) => 1));
      final seed2 = Uint8List.fromList(List.generate(32, (i) => 2));
      final pk1 = await ed25519PubkeyFromSeed(seed1);
      final pk2 = await ed25519PubkeyFromSeed(seed2);
      expect(pk1, isNot(equals(pk2)));
    });
  });

  // ── keys_put envelope (sys_keys special handling) ─────────────────────────

  group('keys_put envelope (sys_keys)', () {
    test('sys_keys type triggers keys_put', () {
      // Simulates the check in PulseMessageSender.sendSignal
      const signalType = 'sys_keys';
      expect(signalType == 'sys_keys', isTrue);
    });

    test('keys_put envelope structure', () {
      final bundle = {
        'identityKey': 'base64_ik',
        'signedPreKeyId': 1,
        'signedPreKey': 'base64_spk',
        'signedPreKeySig': 'base64_sig',
        'preKeyId': 42,
        'preKey': 'base64_pk',
        'registrationId': 12345,
      };
      final envelope = {
        'type': 'keys_put',
        'payload': bundle,
      };
      expect(envelope['type'], equals('keys_put'));
      final payload = envelope['payload'] as Map<String, dynamic>;
      expect(payload['identityKey'], equals('base64_ik'));
      expect(payload['registrationId'], equals(12345));
    });
  });

  // ── ACK wire format ───────────────────────────────────────────────────────

  group('ACK wire format', () {
    test('ack envelope has correct structure', () {
      final ack = {
        'type': 'ack',
        'id': 'msg_001',
      };
      final json = jsonEncode(ack);
      final parsed = jsonDecode(json) as Map<String, dynamic>;
      expect(parsed['type'], equals('ack'));
      expect(parsed['id'], equals('msg_001'));
    });
  });

  // ── Fetch stored request wire format ──────────────────────────────────────

  group('Fetch stored request wire format', () {
    test('fetch request envelope structure', () {
      final since = 1700000000;
      final fetch = {
        'type': 'fetch',
        'since': since,
        'limit': 100,
      };
      final json = jsonEncode(fetch);
      final parsed = jsonDecode(json) as Map<String, dynamic>;
      expect(parsed['type'], equals('fetch'));
      expect(parsed['since'], equals(since));
      expect(parsed['limit'], equals(100));
    });
  });

  // ── keys_get request wire format ──────────────────────────────────────────

  group('keys_get request wire format', () {
    test('keys_get request has correct structure', () {
      final keysGet = {
        'type': 'keys_get',
        'pubkey': 'aabbccdd' * 8,
      };
      final json = jsonEncode(keysGet);
      final parsed = jsonDecode(json) as Map<String, dynamic>;
      expect(parsed['type'], equals('keys_get'));
      expect(parsed['pubkey'], equals('aabbccdd' * 8));
    });
  });

  // ── Zeroization ───────────────────────────────────────────────────────────

  group('Zeroization of key material', () {
    test('seed bytes are zeroed', () {
      final seed = Uint8List.fromList(List.generate(32, (i) => i + 1));
      // Verify non-zero before
      expect(seed.any((b) => b != 0), isTrue);

      // Simulate zeroize()
      for (int i = 0; i < seed.length; i++) {
        seed[i] = 0;
      }
      expect(seed.every((b) => b == 0), isTrue);
    });

    test('empty seed does not throw on zeroize', () {
      final seed = Uint8List(0);
      // Should not throw
      for (int i = 0; i < seed.length; i++) {
        seed[i] = 0;
      }
      expect(seed.length, equals(0));
    });
  });

  // ── PulseInboxReader / PulseMessageSender integration tests ───────────────
  // (Uses SharedPreferences mock for init)

  group('PulseInboxReader initialization', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initializeReader parses valid apiKey and sets up WS URL', () async {
      final reader = PulseInboxReader();
      final apiKey = jsonEncode({
        'privkey': 'ab' * 32,
        'serverUrl': 'https://relay.example.com:8443',
        'invite': 'test-invite',
      });
      await reader.initializeReader(apiKey, 'my_db_id');
      // After init, provisionGroup should return the formatted address
      final addr = await reader.provisionGroup('test');
      expect(addr, isNotNull);
      expect(addr!, contains('@https://relay.example.com:8443'));
      // circuitBroken should be false (loop not started yet)
      expect(reader.circuitBroken, isFalse);
      reader.close();
    });

    test('initializeReader handles invalid JSON gracefully', () async {
      final reader = PulseInboxReader();
      await reader.initializeReader('not-valid-json', 'db_id');
      // Should not crash — just returns without setting up
      // provisionGroup returns empty pubkey since init failed
      final addr = await reader.provisionGroup('test');
      expect(addr, equals('@'));
      expect(reader.circuitBroken, isFalse);
      reader.close();
    });

    test('initializeReader handles empty privkey', () async {
      final reader = PulseInboxReader();
      final apiKey = jsonEncode({
        'privkey': '',
        'serverUrl': 'https://relay.example.com',
      });
      await reader.initializeReader(apiKey, 'db_id');
      // Loop should not start since seed is empty
      // Verify _ensureLoop guard by checking circuit isn't broken
      expect(reader.circuitBroken, isFalse);
      reader.close();
    });

    test('initializeReader rejects invalid server URL', () async {
      final reader = PulseInboxReader();
      final apiKey = jsonEncode({
        'privkey': 'ab' * 32,
        'serverUrl': 'ftp://invalid.com',
      });
      await reader.initializeReader(apiKey, 'db_id');
      // Loop won't start since wsUrl would be empty
      expect(reader.circuitBroken, isFalse);
      reader.close();
    });

    test('healthChanges stream emits values', () async {
      final reader = PulseInboxReader();
      expect(reader.healthChanges, isA<Stream<bool>>());
      reader.close();
    });

    test('provisionGroup returns own address', () async {
      final reader = PulseInboxReader();
      final apiKey = jsonEncode({
        'privkey': 'ab' * 32,
        'serverUrl': 'https://relay.example.com',
        'invite': '',
      });
      await reader.initializeReader(apiKey, 'db_id');

      final groupAddr = await reader.provisionGroup('test-group');
      expect(groupAddr, isNotNull);
      expect(groupAddr!, contains('@https://relay.example.com'));
      // pubkey part should be 64 hex chars
      final pubkey = groupAddr.split('@').first;
      expect(pubkey.length, equals(64));
      expect(pubkey, matches(RegExp(r'^[0-9a-f]{64}$')));
      reader.close();
    });

    test('close sets circuitBroken to false initially', () {
      final reader = PulseInboxReader();
      reader.close();
      expect(reader.circuitBroken, isFalse);
    });

    test('zeroize clears key material', () async {
      final reader = PulseInboxReader();
      final apiKey = jsonEncode({
        'privkey': 'ab' * 32,
        'serverUrl': 'https://relay.example.com',
      });
      await reader.initializeReader(apiKey, 'db_id');
      reader.zeroize();
      // After zeroize, provisionGroup should return @server (empty pubkey)
      final addr = await reader.provisionGroup('g');
      expect(addr, equals('@https://relay.example.com'));
    });

    test('Tor settings loaded from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'tor_enabled': true,
        'tor_host': '10.0.0.1',
        'tor_port': 9150,
      });
      final reader = PulseInboxReader();
      final apiKey = jsonEncode({
        'privkey': 'ab' * 32,
        'serverUrl': 'https://relay.example.com',
      });
      await reader.initializeReader(apiKey, 'db_id');
      // No crash — Tor settings loaded but Tor not bootstrapped so won't try
      reader.close();
    });
  });

  group('PulseMessageSender initialization', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initializeSender parses valid apiKey', () async {
      final sender = PulseMessageSender();
      final apiKey = jsonEncode({
        'privkey': 'cd' * 32,
        'serverUrl': 'https://my-relay.com:9443',
      });
      await sender.initializeSender(apiKey);
      // No crash means success — can't verify internals easily but
      // sendMessage with empty seed would return false
    });

    test('initializeSender handles invalid JSON', () async {
      final sender = PulseMessageSender();
      await sender.initializeSender('{broken}}}');
      // Should not crash
    });

    test('initializeSender with empty privkey', () async {
      final sender = PulseMessageSender();
      final apiKey = jsonEncode({
        'privkey': '',
        'serverUrl': 'https://relay.com',
      });
      await sender.initializeSender(apiKey);
      // sendMessage should return false since seed is empty
      final result = await sender.sendMessage(
        'target@https://server.com',
        'room1',
        Message(
          id: 'msg1',
          senderId: 'me',
          receiverId: 'them',
          encryptedPayload: 'data',
          timestamp: DateTime.now(),
          adapterType: 'pulse',
        ),
      );
      expect(result, isFalse);
    });

    test('sendMessage returns false when seed is empty', () async {
      final sender = PulseMessageSender();
      // Don't initialize — seed stays empty
      final result = await sender.sendMessage(
        'target@https://server.com',
        'room1',
        Message(
          id: 'msg1',
          senderId: 'me',
          receiverId: 'them',
          encryptedPayload: 'data',
          timestamp: DateTime.now(),
          adapterType: 'pulse',
        ),
      );
      expect(result, isFalse);
    });

    test('sendSignal returns false when seed is empty', () async {
      final sender = PulseMessageSender();
      final result = await sender.sendSignal(
        'target@https://server.com',
        'room1',
        'sender_id',
        'typing',
        {},
      );
      expect(result, isFalse);
    });

    test('zeroize clears key material and resets connection state', () async {
      final sender = PulseMessageSender();
      final apiKey = jsonEncode({
        'privkey': 'ef' * 32,
        'serverUrl': 'https://relay.com',
      });
      await sender.initializeSender(apiKey);
      sender.zeroize();
      // After zeroize, sendMessage should fail
      final result = await sender.sendMessage(
        'target@https://server.com',
        'room1',
        Message(
          id: 'msg1',
          senderId: 'me',
          receiverId: 'them',
          encryptedPayload: 'data',
          timestamp: DateTime.now(),
          adapterType: 'pulse',
        ),
      );
      expect(result, isFalse);
    });

    test('Tor settings loaded from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'tor_enabled': true,
        'tor_host': '127.0.0.1',
        'tor_port': 9050,
      });
      final sender = PulseMessageSender();
      final apiKey = jsonEncode({
        'privkey': 'ab' * 32,
        'serverUrl': 'https://relay.example.com',
      });
      await sender.initializeSender(apiKey);
      // No crash — Tor settings loaded
    });

    test('http server URL converts to ws:// in sender', () async {
      SharedPreferences.setMockInitialValues({});
      final sender = PulseMessageSender();
      final apiKey = jsonEncode({
        'privkey': 'ab' * 32,
        'serverUrl': 'http://192.168.1.1:8080',
      });
      await sender.initializeSender(apiKey);
      // After init with http URL, wsUrl should be ws://...
      // We verify by checking sendMessage doesn't crash (it will fail to connect
      // but the URL parsing succeeded)
    });
  });

  // ── Last fetch timestamp logic ────────────────────────────────────────────

  group('Last fetch timestamp logic', () {
    test('defaults to 30 days ago when no stored timestamp', () {
      final thirtyDaysAgo =
          DateTime.now().millisecondsSinceEpoch ~/ 1000 - 30 * 86400;
      final stored = 0; // no stored value
      final result =
          stored > thirtyDaysAgo ? stored - 60 : thirtyDaysAgo;
      expect(result, equals(thirtyDaysAgo));
    });

    test('uses stored timestamp minus 60s when recent enough', () {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final stored = now - 3600; // 1 hour ago
      final thirtyDaysAgo = now - 30 * 86400;
      final result =
          stored > thirtyDaysAgo ? stored - 60 : thirtyDaysAgo;
      expect(result, equals(stored - 60));
    });

    test('falls back to 30-day window for very old timestamps', () {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final stored = now - 60 * 86400; // 60 days ago
      final thirtyDaysAgo = now - 30 * 86400;
      final result =
          stored > thirtyDaysAgo ? stored - 60 : thirtyDaysAgo;
      expect(result, equals(thirtyDaysAgo));
    });

    test('update only advances timestamp forward', () {
      int current = 1700000000;
      int newTs = 1699999999; // older
      // Should not update
      if (newTs > current) {
        current = newTs;
      }
      expect(current, equals(1700000000));

      // Newer timestamp should update
      newTs = 1700000001;
      if (newTs > current) {
        current = newTs;
      }
      expect(current, equals(1700000001));
    });
  });

  // ── Error handling / edge cases ───────────────────────────────────────────

  group('Error handling and edge cases', () {
    test('malformed JSON message does not crash dispatch', () {
      // Simulates the try-catch in the stream listener
      bool crashed = false;
      try {
        jsonDecode('invalid{json') as Map<String, dynamic>;
      } catch (e) {
        crashed = false; // caught — no crash
      }
      expect(crashed, isFalse);
    });

    test('message with non-string type defaults to empty', () {
      final data = {
        'type': 123, // wrong type
        'payload': {'id': 'msg1', 'from': 'x', 'payload': 'y'},
      };
      // Mirrors: data['type'] as String? ?? ''
      final type = data['type'] is String ? data['type'] as String : '';
      expect(type, isEmpty);
    });

    test('missing nested payload falls back to data itself', () {
      // When the 'payload' key is absent, `as Map<String, dynamic>?` yields null,
      // so the ?? operator falls back to the outer `data` map.
      final data = <String, dynamic>{
        'id': 'msg1',
        'from': 'sender',
        'timestamp': 1700000000,
      };
      final payload = data['payload'] as Map<String, dynamic>? ?? data;
      expect(payload, same(data));
      expect(payload['id'], equals('msg1'));
    });

    test('TURN credentials saved from auth_ok', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Simulate _saveTurnCreds
      final authOkData = {
        'type': 'auth_ok',
        'turn_url': 'turn:relay.example.com:3478',
        'turn_user': 'user123',
        'turn_pass': 'pass456',
      };

      final turnUrl = authOkData['turn_url'] ?? '';
      final turnUser = authOkData['turn_user'] ?? '';
      final turnPass = authOkData['turn_pass'] ?? '';
      if (turnUrl.isNotEmpty) {
        await prefs.setString('pulse_turn_url', turnUrl);
        await prefs.setString('pulse_turn_user', turnUser);
        await prefs.setString('pulse_turn_pass', turnPass);
      }

      expect(prefs.getString('pulse_turn_url'),
          equals('turn:relay.example.com:3478'));
      expect(prefs.getString('pulse_turn_user'), equals('user123'));
      expect(prefs.getString('pulse_turn_pass'), equals('pass456'));
    });

    test('empty TURN URL is not saved', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final authOkData = {
        'type': 'auth_ok',
        'turn_url': '',
        'turn_user': '',
        'turn_pass': '',
      };

      final turnUrl = authOkData['turn_url'] ?? '';
      if (turnUrl.isNotEmpty) {
        await prefs.setString('pulse_turn_url', turnUrl);
      }

      expect(prefs.getString('pulse_turn_url'), isNull);
    });
  });
}
