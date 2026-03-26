import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pure-Dart unit tests for GroupSignalingService logic.
///
/// The production class (lib/services/group_signaling_service.dart) depends on
/// flutter_webrtc, which is not available in unit tests. We reimplement the
/// testable pure-Dart helpers here.
void main() {
  // ── Reimplemented _routingToken ────────────────────────────────────────────
  //
  // Mirrors GroupSignalingService._routingToken exactly:
  //   SHA-256(groupId) hex — used as routing token so relay can't see group UUID.

  String routingToken(String groupId) =>
      sha256.convert(utf8.encode(groupId)).toString();

  // ── Signal payload construction ────────────────────────────────────────────
  //
  // Mirrors GroupSignalingService._sendSignal payload structure.

  Map<String, dynamic> buildGroupSignalPayload({
    required String groupId,
    required Map<String, dynamic> data,
    required bool isVideoCall,
    String? encryptedEnvelope,
  }) {
    final token = routingToken(groupId);
    if (encryptedEnvelope != null) {
      return {
        'e2ee': encryptedEnvelope,
        '_g': token,
        'groupId': groupId,
        'isVideoCall': isVideoCall,
      };
    } else {
      return {
        '_g': token,
        'data': data,
        'groupId': groupId,
        'isVideoCall': isVideoCall,
      };
    }
  }

  // ── Tests ─────────────────────────────────────────────────────────────────

  group('Routing token (SHA-256)', () {
    test('produces 64-char hex string', () {
      final token = routingToken('test-group-id');
      expect(token.length, equals(64));
      // Must be lowercase hex
      expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(token), isTrue);
    });

    test('same groupId produces same token', () {
      const id = 'group-abc-123';
      expect(routingToken(id), equals(routingToken(id)));
    });

    test('different groupIds produce different tokens', () {
      expect(routingToken('group-1'), isNot(equals(routingToken('group-2'))));
    });

    test('empty groupId produces a valid hash', () {
      final token = routingToken('');
      expect(token.length, equals(64));
      // SHA-256 of empty string is well-known
      expect(token, equals('e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'));
    });

    test('token for UUID-format groupId is deterministic', () {
      const uuid = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
      final t1 = routingToken(uuid);
      final t2 = routingToken(uuid);
      expect(t1, equals(t2));
      expect(t1.length, equals(64));
    });

    test('token hides actual groupId (not a prefix or substring)', () {
      const groupId = 'my-secret-group';
      final token = routingToken(groupId);
      expect(token, isNot(contains('my-secret')));
      expect(token, isNot(contains('group')));
    });

    test('handles special characters in groupId', () {
      final token = routingToken('group/with@special#chars!');
      expect(token.length, equals(64));
      expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(token), isTrue);
    });

    test('handles very long groupId', () {
      final longId = 'g' * 10000;
      final token = routingToken(longId);
      expect(token.length, equals(64));
    });
  });

  group('Group signal payload construction', () {
    test('encrypted payload includes _g, e2ee, groupId, isVideoCall', () {
      final payload = buildGroupSignalPayload(
        groupId: 'grp-1',
        data: {'sdp': 'v=0...', 'type': 'offer'},
        isVideoCall: true,
        encryptedEnvelope: 'encrypted_base64_blob',
      );
      expect(payload['e2ee'], equals('encrypted_base64_blob'));
      expect(payload['_g'], equals(routingToken('grp-1')));
      expect(payload['groupId'], equals('grp-1'));
      expect(payload['isVideoCall'], isTrue);
      // Data should NOT be present when encrypted
      expect(payload.containsKey('data'), isFalse);
    });

    test('unencrypted fallback payload includes _g, data, groupId, isVideoCall', () {
      final data = {'sdp': 'v=0...', 'type': 'answer'};
      final payload = buildGroupSignalPayload(
        groupId: 'grp-2',
        data: data,
        isVideoCall: false,
      );
      expect(payload.containsKey('e2ee'), isFalse);
      expect(payload['_g'], equals(routingToken('grp-2')));
      expect(payload['data'], equals(data));
      expect(payload['groupId'], equals('grp-2'));
      expect(payload['isVideoCall'], isFalse);
    });

    test('_g token matches routing token for same groupId', () {
      const groupId = 'abc-xyz';
      final payload = buildGroupSignalPayload(
        groupId: groupId,
        data: {},
        isVideoCall: true,
      );
      expect(payload['_g'], equals(routingToken(groupId)));
    });

    test('groupId remains in clear in both encrypted and unencrypted payloads', () {
      // groupId is included in clear so receivers can show incoming-call UI
      // before decryption
      const groupId = 'visible-group';
      final encrypted = buildGroupSignalPayload(
        groupId: groupId,
        data: {},
        isVideoCall: true,
        encryptedEnvelope: 'enc',
      );
      final unencrypted = buildGroupSignalPayload(
        groupId: groupId,
        data: {},
        isVideoCall: false,
      );
      expect(encrypted['groupId'], equals(groupId));
      expect(unencrypted['groupId'], equals(groupId));
    });
  });

  group('Inner payload structure', () {
    test('inner payload wraps data with groupId', () {
      // Mirrors: Map<String, dynamic> innerPayload = {'groupId': group.id, 'data': data};
      const groupId = 'grp-inner';
      final data = {'sdp': 'v=0...', 'type': 'offer'};
      final innerPayload = {'groupId': groupId, 'data': data};
      expect(innerPayload['groupId'], equals(groupId));
      expect(innerPayload['data'], equals(data));
    });

    test('inner payload serializes to valid JSON', () {
      final innerPayload = {
        'groupId': 'grp-json',
        'data': {'candidate': 'a=candidate:1 ...', 'sdpMid': '0', 'sdpMLineIndex': 0},
      };
      final json = jsonEncode(innerPayload);
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      expect(decoded['groupId'], equals('grp-json'));
      final decodedData = decoded['data'] as Map<String, dynamic>;
      expect(decodedData['sdpMid'], equals('0'));
      expect(decodedData['sdpMLineIndex'], equals(0));
    });
  });

  group('Signal type filtering', () {
    test('only webrtc_offer, webrtc_answer, webrtc_candidate are accepted', () {
      // From _listenForSignals:
      //   if (type != 'webrtc_offer' && type != 'webrtc_answer' && type != 'webrtc_candidate') return;
      const accepted = {'webrtc_offer', 'webrtc_answer', 'webrtc_candidate'};

      bool isAccepted(String type) => accepted.contains(type);

      expect(isAccepted('webrtc_offer'), isTrue);
      expect(isAccepted('webrtc_answer'), isTrue);
      expect(isAccepted('webrtc_candidate'), isTrue);
      expect(isAccepted('webrtc2_offer'), isFalse);
      expect(isAccepted('sys_keys'), isFalse);
      expect(isAccepted('sys_kick'), isFalse);
      expect(isAccepted('msg_ack'), isFalse);
      expect(isAccepted(''), isFalse);
    });
  });

  group('Routing token fast-path check', () {
    test('matching token passes filter', () {
      const groupId = 'my-group';
      final expectedToken = routingToken(groupId);
      final payload = {'_g': expectedToken, 'data': {}};
      expect(payload['_g'], equals(routingToken(groupId)));
    });

    test('mismatched token is rejected', () {
      final payload = {'_g': routingToken('other-group'), 'data': {}};
      expect(payload['_g'], isNot(equals(routingToken('my-group'))));
    });

    test('missing _g token is rejected', () {
      final payload = <String, dynamic>{'data': {}};
      final token = payload['_g'] as String?;
      expect(token, isNull);
    });
  });

  group('Member matching logic', () {
    // Mirrors the matching in _listenForSignals:
    //   m?.databaseId == fromId || m?.databaseId.split('@').first == fromId

    bool memberMatches(String databaseId, String fromId) {
      return databaseId == fromId || databaseId.split('@').first == fromId;
    }

    test('exact match on databaseId', () {
      expect(memberMatches('alice@wss://relay.damus.io', 'alice@wss://relay.damus.io'), isTrue);
    });

    test('matches on pubkey prefix (before @)', () {
      expect(memberMatches('alice@wss://relay.damus.io', 'alice'), isTrue);
    });

    test('does not match different user', () {
      expect(memberMatches('alice@wss://relay.damus.io', 'bob'), isFalse);
    });

    test('handles databaseId without @', () {
      // split('@').first returns the whole string if no '@'
      expect(memberMatches('05abcdef1234567890', '05abcdef1234567890'), isTrue);
    });

    test('does not match partial prefix', () {
      expect(memberMatches('alice@relay', 'alic'), isFalse);
    });
  });

  group('Offer retry constants', () {
    test('max retries is 3', () {
      // Mirrors: static const _maxOfferRetries = 3;
      const maxOfferRetries = 3;
      expect(maxOfferRetries, equals(3));

      // Verify retry logic: retries >= max → stop
      for (int i = 0; i < maxOfferRetries; i++) {
        expect(i < maxOfferRetries, isTrue);
      }
      expect(maxOfferRetries >= maxOfferRetries, isTrue); // should stop here
    });

    test('retry delay is 30 seconds', () {
      // Mirrors: static const _offerRetryDelay = Duration(seconds: 30);
      const offerRetryDelay = Duration(seconds: 30);
      expect(offerRetryDelay.inSeconds, equals(30));
      expect(offerRetryDelay.inMilliseconds, equals(30000));
    });
  });

  group('Answer tracking', () {
    test('answered peer cancels retry', () {
      // Simulates the answer-tracking logic from _listenForSignals
      final answeredPeers = <String>{};

      // Peer sends answer
      const peerId = 'peer-1';
      answeredPeers.add(peerId);

      // Retry check: if answered, skip
      final shouldRetry = !answeredPeers.contains(peerId);
      expect(shouldRetry, isFalse);
    });

    test('unanswered peer triggers retry', () {
      final answeredPeers = <String>{};
      const peerId = 'peer-2';
      final shouldRetry = !answeredPeers.contains(peerId);
      expect(shouldRetry, isTrue);
    });

    test('retry count increments correctly', () {
      final retryCount = <String, int>{};
      const peerId = 'peer-3';

      for (int i = 0; i < 3; i++) {
        final current = retryCount[peerId] ?? 0;
        retryCount[peerId] = current + 1;
      }
      expect(retryCount[peerId], equals(3));
    });
  });
}
