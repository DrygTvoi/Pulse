import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/models/message_envelope.dart';

void main() {
  group('MessageEnvelope.wrap()', () {
    test('produces valid JSON with all required fields', () {
      final json = MessageEnvelope.wrap('alice@firebase', 'hello');
      final map = jsonDecode(json) as Map<String, dynamic>;
      expect(map['_v'], equals(1));
      expect(map['_from'], equals('alice@firebase'));
      expect(map['body'], equals('hello'));
    });

    test('encodes Firebase address correctly', () {
      final json = MessageEnvelope.wrap(
          'uid@https://my-project.firebaseio.com', 'test');
      final map = jsonDecode(json) as Map<String, dynamic>;
      expect(map['_from'], equals('uid@https://my-project.firebaseio.com'));
    });

    test('encodes Nostr address correctly', () {
      final json =
          MessageEnvelope.wrap('pubkey@wss://relay.damus.io', 'hi');
      final map = jsonDecode(json) as Map<String, dynamic>;
      expect(map['_from'], equals('pubkey@wss://relay.damus.io'));
    });

    test('encodes group JSON body without modification', () {
      const body = '{"_group":"g1","text":"hello group"}';
      final json = MessageEnvelope.wrap('alice', body);
      final map = jsonDecode(json) as Map<String, dynamic>;
      expect(map['body'], equals(body));
    });

    test('encodes empty body', () {
      final json = MessageEnvelope.wrap('alice', '');
      final map = jsonDecode(json) as Map<String, dynamic>;
      expect(map['body'], equals(''));
    });
  });

  group('MessageEnvelope.tryUnwrap()', () {
    test('parses valid envelope and returns correct fields', () {
      final raw = jsonEncode(
          {'_v': 1, '_from': 'alice@firebase', 'body': 'hello'});
      final env = MessageEnvelope.tryUnwrap(raw);
      expect(env, isNotNull);
      expect(env!.from, equals('alice@firebase'));
      expect(env.body, equals('hello'));
    });

    test('returns null for plain text (no JSON)', () {
      expect(MessageEnvelope.tryUnwrap('just a message'), isNull);
    });

    test('returns null for empty string', () {
      expect(MessageEnvelope.tryUnwrap(''), isNull);
    });

    test('returns null for JSON missing _from field', () {
      final raw = jsonEncode({'_v': 1, 'body': 'hello'});
      expect(MessageEnvelope.tryUnwrap(raw), isNull);
    });

    test('returns null for JSON missing body field', () {
      final raw = jsonEncode({'_v': 1, '_from': 'alice'});
      expect(MessageEnvelope.tryUnwrap(raw), isNull);
    });

    test('returns null for empty _from', () {
      final raw = jsonEncode({'_v': 1, '_from': '', 'body': 'hi'});
      expect(MessageEnvelope.tryUnwrap(raw), isNull);
    });

    test('returns null for invalid JSON starting with {', () {
      expect(MessageEnvelope.tryUnwrap('{invalid json}'), isNull);
    });

    test('wrap + tryUnwrap round-trip preserves data', () {
      const from = 'pubkey@wss://relay.nostr.com';
      const body = '{"t":"img","d":"base64data","n":"photo.jpg","sz":1234}';
      final raw = MessageEnvelope.wrap(from, body);
      final env = MessageEnvelope.tryUnwrap(raw);
      expect(env, isNotNull);
      expect(env!.from, equals(from));
      expect(env.body, equals(body));
    });

    test('round-trip with Firebase cross-project address', () {
      const from = 'abc123@https://project-42.firebaseio.com';
      const body = 'cross-project message';
      final env = MessageEnvelope.tryUnwrap(MessageEnvelope.wrap(from, body));
      expect(env!.from, equals(from));
      expect(env.body, equals(body));
    });
  });
}
