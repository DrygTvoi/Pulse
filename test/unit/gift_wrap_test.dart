import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/services/gift_wrap_service.dart';
import 'package:pulse_messenger/services/nostr_event_builder.dart';

const _privA =
    'b94f5374fce5edbc8e2a8697c15331677e6ebf0b000000000000000000000001';
const _privB =
    'c6047f9441ed7d6d3045406e95c07cd85c778e4b8cef3ca7abac09b95c709ee5';

void main() {
  final pubA = derivePubkeyHex(_privA);
  final pubB = derivePubkeyHex(_privB);

  group('Gift Wrap', () {
    test('wrap/unwrap round-trip for kind:4 message', () async {
      final wrapped = await wrapEvent(
        senderPrivkey: _privA,
        recipientPubkey: pubB,
        innerKind: 4,
        innerContent: 'Hello from A!',
        innerTags: [['p', pubB]],
      );
      expect(wrapped['kind'], equals(1059));

      final inner = await unwrapEvent(
        recipientPrivkey: _privB,
        wrapEvent: wrapped,
      );
      expect(inner, isNotNull);
      expect(inner!['kind'], equals(4));
      expect(inner['content'], equals('Hello from A!'));
      expect(inner['pubkey'], equals(pubA));
    });

    test('wrap/unwrap round-trip for kind:20000 signal', () async {
      final wrapped = await wrapEvent(
        senderPrivkey: _privA,
        recipientPubkey: pubB,
        innerKind: 20000,
        innerContent: '{"type":"typing","roomId":"r1"}',
      );
      final inner = await unwrapEvent(
        recipientPrivkey: _privB,
        wrapEvent: wrapped,
      );
      expect(inner, isNotNull);
      expect(inner!['kind'], equals(20000));
    });

    test('wrapped event uses ephemeral pubkey (not sender)', () async {
      final wrapped = await wrapEvent(
        senderPrivkey: _privA,
        recipientPubkey: pubB,
        innerKind: 4,
        innerContent: 'test',
      );
      // The outer event pubkey should NOT be sender's pubkey
      expect(wrapped['pubkey'], isNot(equals(pubA)));
    });

    test('timestamp is randomized (within ±2 hours)', () async {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final wrapped = await wrapEvent(
        senderPrivkey: _privA,
        recipientPubkey: pubB,
        innerKind: 4,
        innerContent: 'test',
      );
      final ts = wrapped['created_at'] as int;
      // Should be within 2 hours + some slack
      expect((ts - now).abs(), lessThan(7200 + 10));
    });

    test('inner event signature is verified', () async {
      final wrapped = await wrapEvent(
        senderPrivkey: _privA,
        recipientPubkey: pubB,
        innerKind: 4,
        innerContent: 'signed content',
      );
      final inner = await unwrapEvent(
        recipientPrivkey: _privB,
        wrapEvent: wrapped,
      );
      expect(inner, isNotNull);
      expect(verifyEventSignature(inner!), isTrue);
    });

    test('wrong recipient cannot unwrap', () async {
      const wrongPriv =
          '1111111111111111111111111111111111111111111111111111111111111111';
      final wrapped = await wrapEvent(
        senderPrivkey: _privA,
        recipientPubkey: pubB,
        innerKind: 4,
        innerContent: 'private',
      );
      final inner = await unwrapEvent(
        recipientPrivkey: wrongPriv,
        wrapEvent: wrapped,
      );
      expect(inner, isNull);
    });

    test('tampered outer content returns null', () async {
      final wrapped = await wrapEvent(
        senderPrivkey: _privA,
        recipientPubkey: pubB,
        innerKind: 4,
        innerContent: 'test',
      );
      wrapped['content'] = 'definitely_not_valid_base64!!!';
      final inner = await unwrapEvent(
        recipientPrivkey: _privB,
        wrapEvent: wrapped,
      );
      expect(inner, isNull);
    });

    test('non-1059 kind returns null', () async {
      final inner = await unwrapEvent(
        recipientPrivkey: _privB,
        wrapEvent: {'kind': 4, 'pubkey': pubA, 'content': 'test'},
      );
      expect(inner, isNull);
    });

    test('multiple wraps produce different ephemeral keys', () async {
      final w1 = await wrapEvent(
        senderPrivkey: _privA,
        recipientPubkey: pubB,
        innerKind: 4,
        innerContent: 'test',
      );
      final w2 = await wrapEvent(
        senderPrivkey: _privA,
        recipientPubkey: pubB,
        innerKind: 4,
        innerContent: 'test',
      );
      expect(w1['pubkey'], isNot(equals(w2['pubkey'])));
    });

    test('p-tag contains recipient pubkey', () async {
      final wrapped = await wrapEvent(
        senderPrivkey: _privA,
        recipientPubkey: pubB,
        innerKind: 4,
        innerContent: 'test',
      );
      final tags = (wrapped['tags'] as List).cast<List>();
      final pTag = tags.firstWhere((t) => t[0] == 'p');
      expect(pTag[1], equals(pubB));
    });
  });
}
