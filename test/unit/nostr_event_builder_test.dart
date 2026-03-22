import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/services/nostr_event_builder.dart';

const _priv1 =
    '0000000000000000000000000000000000000000000000000000000000000001';
const _priv2 =
    'b94f5374fce5edbc8e2a8697c15331677e6ebf0b000000000000000000000001';

void main() {
  group('derivePubkeyHex', () {
    test('privkey 1 → generator point', () {
      expect(
        derivePubkeyHex(_priv1),
        equals(
            '79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798'),
      );
    });

    test('result is 64 hex chars', () {
      final pub = derivePubkeyHex(_priv2);
      expect(pub.length, equals(64));
      expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(pub), isTrue);
    });
  });

  group('buildEvent', () {
    test('produces valid event structure', () async {
      final event = await buildEvent(
        privkeyHex: _priv2,
        kind: 4,
        content: 'hello',
        tags: [['p', 'abc']],
      );
      expect(event['pubkey'], equals(derivePubkeyHex(_priv2)));
      expect(event['kind'], equals(4));
      expect(event['content'], equals('hello'));
      expect(event['id'], isA<String>());
      expect(event['sig'], isA<String>());
      expect((event['id'] as String).length, equals(64));
      expect((event['sig'] as String).length, equals(128));
    });

    test('respects custom createdAt', () async {
      final event = await buildEvent(
        privkeyHex: _priv2,
        kind: 1,
        content: 'test',
        createdAt: 1700000000,
      );
      expect(event['created_at'], equals(1700000000));
    });

    test('different content → different id', () async {
      final e1 = await buildEvent(privkeyHex: _priv2, kind: 1, content: 'a');
      final e2 = await buildEvent(privkeyHex: _priv2, kind: 1, content: 'b');
      expect(e1['id'], isNot(equals(e2['id'])));
    });
  });

  group('verifyEventSignature', () {
    test('valid event passes', () async {
      final event = await buildEvent(
        privkeyHex: _priv2,
        kind: 1,
        content: 'test content',
      );
      expect(verifyEventSignature(event), isTrue);
    });

    test('tampered content fails', () async {
      final event = await buildEvent(
        privkeyHex: _priv2,
        kind: 1,
        content: 'original',
      );
      event['content'] = 'tampered';
      expect(verifyEventSignature(event), isFalse);
    });

    test('tampered id fails', () async {
      final event = await buildEvent(
        privkeyHex: _priv2,
        kind: 1,
        content: 'test',
      );
      event['id'] = 'a' * 64;
      expect(verifyEventSignature(event), isFalse);
    });

    test('wrong sig fails', () async {
      final event = await buildEvent(
        privkeyHex: _priv2,
        kind: 1,
        content: 'test',
      );
      event['sig'] = '0' * 128;
      expect(verifyEventSignature(event), isFalse);
    });

    test('different keys produce valid signatures', () async {
      final e1 = await buildEvent(privkeyHex: _priv1, kind: 1, content: 'a');
      final e2 = await buildEvent(privkeyHex: _priv2, kind: 1, content: 'a');
      expect(verifyEventSignature(e1), isTrue);
      expect(verifyEventSignature(e2), isTrue);
      expect(e1['pubkey'], isNot(equals(e2['pubkey'])));
    });
  });

  group('generateRandomPrivkey', () {
    test('produces 64 hex chars', () {
      final key = generateRandomPrivkey();
      expect(key.length, equals(64));
      expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(key), isTrue);
    });

    test('each call produces unique key', () {
      final keys = List.generate(10, (_) => generateRandomPrivkey());
      expect(keys.toSet().length, equals(10));
    });
  });

  group('buildEventId', () {
    test('is deterministic', () {
      final event = {
        'pubkey': derivePubkeyHex(_priv2),
        'created_at': 1700000000,
        'kind': 1,
        'tags': <List<String>>[],
        'content': 'hello',
      };
      expect(buildEventId(event), equals(buildEventId(event)));
    });

    test('produces 64 hex chars', () {
      final event = {
        'pubkey': derivePubkeyHex(_priv2),
        'created_at': 1700000000,
        'kind': 1,
        'tags': <List<String>>[],
        'content': 'test',
      };
      final id = buildEventId(event);
      expect(id.length, equals(64));
      expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(id), isTrue);
    });
  });
}
