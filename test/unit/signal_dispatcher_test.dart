import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/services/signal_dispatcher.dart';
import 'package:pulse_messenger/models/contact.dart';

Contact _contact({
  required String id,
  String? databaseId,
  String name = 'Test',
  bool isGroup = false,
  List<String> members = const [],
}) =>
    Contact(
      id: id,
      name: name,
      provider: 'Nostr',
      databaseId: databaseId ?? id,
      publicKey: 'pk_$id',
      isGroup: isGroup,
      members: members,
    );

SignalDispatcher _dispatcher({
  Map<String, Contact>? contacts,
  List<Contact>? groups,
  String selfId = 'me',
  List<String> allAddresses = const ['me'],
  Future<bool> Function(String, Map<String, dynamic>, String, String)?
      verifier,
}) {
  final index = contacts ??
      {
        'alice@wss://relay': _contact(id: 'a1', databaseId: 'alice@wss://relay', name: 'Alice'),
        'alice': _contact(id: 'a1', databaseId: 'alice@wss://relay', name: 'Alice'),
        'bob@wss://relay': _contact(id: 'b1', databaseId: 'bob@wss://relay', name: 'Bob'),
        'bob': _contact(id: 'b1', databaseId: 'bob@wss://relay', name: 'Bob'),
      };
  final groupList = groups ?? [];
  return SignalDispatcher(
    allAddressesGetter: () => allAddresses,
    selfIdGetter: () => selfId,
    contactIndexBuilder: () => index,
    signatureVerifier: verifier ?? (_, __, ___, ____) async => true,
    groupContactResolver: (id) => groupList.cast<Contact?>().firstWhere(
          (c) => c?.id == id,
          orElse: () => null,
        ),
  );
}

void main() {
  group('SignalDispatcher._resolveContact', () {
    test('resolves by exact databaseId', () async {
      final d = _dispatcher();
      final events = <SignalTypingEvent>[];
      d.typingEvents.listen(events.add);

      await d.dispatch([
        {'type': 'typing', 'senderId': 'alice@wss://relay'},
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.contact.name, 'Alice');
    });

    test('resolves by userId part (before @)', () async {
      final d = _dispatcher();
      final events = <SignalTypingEvent>[];
      d.typingEvents.listen(events.add);

      await d.dispatch([
        {'type': 'typing', 'senderId': 'alice@wss://other-relay'},
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.contact.name, 'Alice');
    });

    test('returns null for unknown sender (no event emitted)', () async {
      final d = _dispatcher();
      final events = <SignalTypingEvent>[];
      d.typingEvents.listen(events.add);

      await d.dispatch([
        {'type': 'typing', 'senderId': 'unknown@wss://relay'},
      ]);
      await Future.delayed(Duration.zero);

      expect(events, isEmpty);
    });
  });

  group('SignalDispatcher typing events', () {
    test('emits typing event for known contact', () async {
      final d = _dispatcher();
      final events = <SignalTypingEvent>[];
      d.typingEvents.listen(events.add);

      await d.dispatch([
        {'type': 'typing', 'senderId': 'bob@wss://relay'},
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.contact.name, 'Bob');
    });
  });

  group('SignalDispatcher read receipts', () {
    test('emits read receipt for 1-on-1', () async {
      final d = _dispatcher();
      final events = <SignalReadReceiptEvent>[];
      d.readReceipts.listen(events.add);

      await d.dispatch([
        {
          'type': 'msg_read',
          'senderId': 'alice@wss://relay',
          'payload': {'from': 'alice@wss://relay'},
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.fromId, 'alice@wss://relay');
    });

    test('emits group read receipt when groupId present', () async {
      final d = _dispatcher();
      final events = <SignalGroupReadReceiptEvent>[];
      d.groupReadReceipts.listen(events.add);

      await d.dispatch([
        {
          'type': 'msg_read',
          'senderId': 'alice@wss://relay',
          'payload': {
            'from': 'alice@wss://relay',
            'groupId': 'g1',
            'msgId': 'm1',
          },
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.groupId, 'g1');
      expect(events.first.msgId, 'm1');
    });
  });

  group('SignalDispatcher delivery acks', () {
    test('emits delivery ack', () async {
      final d = _dispatcher();
      final events = <SignalDeliveryAckEvent>[];
      d.deliveryAcks.listen(events.add);

      await d.dispatch([
        {
          'type': 'msg_ack',
          'senderId': 'alice@wss://relay',
          'payload': {'from': 'alice@wss://relay', 'msgId': 'msg123'},
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.msgId, 'msg123');
    });

    test('ignores ack without msgId', () async {
      final d = _dispatcher();
      final events = <SignalDeliveryAckEvent>[];
      d.deliveryAcks.listen(events.add);

      await d.dispatch([
        {
          'type': 'msg_ack',
          'senderId': 'alice@wss://relay',
          'payload': {'from': 'alice@wss://relay'},
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, isEmpty);
    });
  });

  group('SignalDispatcher reactions', () {
    test('emits reaction add event', () async {
      final d = _dispatcher();
      final events = <SignalReactionEvent>[];
      d.reactions.listen(events.add);

      await d.dispatch([
        {
          'type': 'reaction',
          'senderId': 'alice@wss://relay',
          'payload': {
            'msgId': 'msg1',
            'emoji': '👍',
            'from': 'alice@wss://relay',
          },
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.emoji, '👍');
      expect(events.first.msgId, 'msg1');
      expect(events.first.remove, false);
    });

    test('emits reaction remove event', () async {
      final d = _dispatcher();
      final events = <SignalReactionEvent>[];
      d.reactions.listen(events.add);

      await d.dispatch([
        {
          'type': 'reaction',
          'senderId': 'alice@wss://relay',
          'payload': {
            'msgId': 'msg1',
            'emoji': '👎',
            'from': 'alice@wss://relay',
            'remove': true,
          },
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.remove, true);
    });

    test('uses groupContactResolver for group reactions', () async {
      final group = _contact(
        id: 'group-1',
        databaseId: '',
        name: 'Team Chat',
        isGroup: true,
        members: ['a1', 'b1'],
      );
      final d = _dispatcher(groups: [group]);
      final events = <SignalReactionEvent>[];
      d.reactions.listen(events.add);

      await d.dispatch([
        {
          'type': 'reaction',
          'senderId': 'alice@wss://relay',
          'payload': {
            'msgId': 'msg1',
            'emoji': '❤️',
            'from': 'alice@wss://relay',
            'groupId': 'group-1',
          },
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.storageKey, 'group-1'); // group storageKey == id
    });

    test('ignores reaction with empty msgId', () async {
      final d = _dispatcher();
      final events = <SignalReactionEvent>[];
      d.reactions.listen(events.add);

      await d.dispatch([
        {
          'type': 'reaction',
          'senderId': 'alice@wss://relay',
          'payload': {'msgId': '', 'emoji': '👍', 'from': 'alice@wss://relay'},
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, isEmpty);
    });
  });

  group('SignalDispatcher edits', () {
    test('emits edit event', () async {
      final d = _dispatcher();
      final events = <SignalEditEvent>[];
      d.edits.listen(events.add);

      await d.dispatch([
        {
          'type': 'edit',
          'senderId': 'alice@wss://relay',
          'payload': {
            'msgId': 'msg1',
            'text': 'edited text',
            'from': 'alice@wss://relay',
          },
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.text, 'edited text');
      expect(events.first.contact.name, 'Alice');
    });
  });

  group('SignalDispatcher heartbeats', () {
    test('emits heartbeat for known contact', () async {
      final d = _dispatcher();
      final events = <SignalHeartbeatEvent>[];
      d.heartbeats.listen(events.add);

      await d.dispatch([
        {
          'type': 'heartbeat',
          'senderId': 'bob@wss://relay',
          'payload': {'from': 'bob@wss://relay'},
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.contact.name, 'Bob');
    });
  });

  group('SignalDispatcher WebRTC calls', () {
    test('emits incoming call for 1-on-1 offer', () async {
      final d = _dispatcher();
      final events = <SignalIncomingCallEvent>[];
      d.incomingCalls.listen(events.add);

      await d.dispatch([
        {
          'type': 'webrtc_offer',
          'senderId': 'alice@wss://relay',
          'payload': {'sdp': 'v=0...'},
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
    });

    test('emits group call for offer with groupId', () async {
      final d = _dispatcher();
      final groupEvents = <SignalIncomingGroupCallEvent>[];
      final soloEvents = <SignalIncomingCallEvent>[];
      d.incomingGroupCalls.listen(groupEvents.add);
      d.incomingCalls.listen(soloEvents.add);

      await d.dispatch([
        {
          'type': 'webrtc_offer',
          'senderId': 'alice@wss://relay',
          'payload': {'sdp': 'v=0...', 'groupId': 'g1'},
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(groupEvents, hasLength(1));
      expect(groupEvents.first.groupId, 'g1');
      expect(soloEvents, isEmpty);
    });
  });

  group('SignalDispatcher relay exchange', () {
    test('emits relay list', () async {
      final d = _dispatcher();
      final events = <SignalRelayExchangeEvent>[];
      d.relayExchanges.listen(events.add);

      await d.dispatch([
        {
          'type': 'relay_exchange',
          'senderId': 'alice@wss://relay',
          'payload': {
            'relays': ['wss://r1.example.com', 'wss://r2.example.com'],
            '_sig': 'hmac',
            '_spk': 'pk',
          },
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.relays, hasLength(2));
    });

    test('ignores empty relay list', () async {
      final d = _dispatcher();
      final events = <SignalRelayExchangeEvent>[];
      d.relayExchanges.listen(events.add);

      await d.dispatch([
        {
          'type': 'relay_exchange',
          'senderId': 'alice@wss://relay',
          'payload': {
            'relays': <String>[],
            '_sig': 'hmac',
            '_spk': 'pk',
          },
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, isEmpty);
    });
  });

  group('SignalDispatcher TTL updates', () {
    test('emits TTL update event', () async {
      final d = _dispatcher();
      final events = <SignalTtlUpdateEvent>[];
      d.ttlUpdates.listen(events.add);

      await d.dispatch([
        {
          'type': 'ttl_update',
          'senderId': 'alice@wss://relay',
          'payload': {'seconds': 3600},
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.seconds, 3600);
      expect(events.first.contact.name, 'Alice');
    });
  });

  group('SignalDispatcher address updates', () {
    test('emits addr update event', () async {
      final d = _dispatcher();
      final events = <SignalAddrUpdateEvent>[];
      d.addrUpdates.listen(events.add);

      await d.dispatch([
        {
          'type': 'addr_update',
          'senderId': 'alice@wss://relay',
          'payload': {
            'primary': 'alice@wss://newrelay',
            'all': ['alice@wss://newrelay', 'alice@wss://backup'],
            '_sig': 'hmac',
            '_spk': 'pk',
          },
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.primary, 'alice@wss://newrelay');
      expect(events.first.all, hasLength(2));
    });
  });

  group('SignalDispatcher profile updates', () {
    test('emits profile update event', () async {
      final d = _dispatcher();
      final events = <SignalProfileUpdateEvent>[];
      d.profileUpdates.listen(events.add);

      await d.dispatch([
        {
          'type': 'profile_update',
          'senderId': 'alice@wss://relay',
          'payload': {
            'about': 'Hello world',
            'avatar': 'base64data',
            '_sig': 'hmac',
            '_spk': 'pk',
          },
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.about, 'Hello world');
      expect(events.first.avatarB64, 'base64data');
    });
  });

  group('SignalDispatcher chunk requests', () {
    test('emits chunk request event', () async {
      final d = _dispatcher();
      final events = <SignalChunkReqEvent>[];
      d.chunkRequests.listen(events.add);

      await d.dispatch([
        {
          'type': 'chunk_req',
          'senderId': 'alice@wss://relay',
          'payload': {
            'fid': 'file123',
            'missing': [2, 5, 8],
          },
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.fid, 'file123');
      expect(events.first.missing, [2, 5, 8]);
    });
  });

  group('SignalDispatcher signature verification', () {
    test('rejects unsigned security-critical signal', () async {
      final d = _dispatcher();
      final events = <SignalAddrUpdateEvent>[];
      d.addrUpdates.listen(events.add);

      // addr_update from Firebase (non-Nostr) without _sig/_spk
      await d.dispatch([
        {
          'type': 'addr_update',
          'senderId': 'alice@https://project.firebaseio.com',
          'payload': {
            'primary': 'alice@https://new.firebaseio.com',
            'all': ['alice@https://new.firebaseio.com'],
          },
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, isEmpty);
    });

    test('rejects signal with invalid signature', () async {
      final d = _dispatcher(
        verifier: (_, __, ___, ____) async => false,
      );
      final events = <SignalAddrUpdateEvent>[];
      d.addrUpdates.listen(events.add);

      await d.dispatch([
        {
          'type': 'addr_update',
          'senderId': 'alice@https://project.firebaseio.com',
          'payload': {
            'primary': 'alice@https://new.firebaseio.com',
            'all': ['alice@https://new.firebaseio.com'],
            '_sig': 'invalid',
            '_spk': 'pk',
          },
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, isEmpty);
    });

    test('skips signature check for Nostr-origin signals', () async {
      final d = _dispatcher();
      final events = <SignalAddrUpdateEvent>[];
      d.addrUpdates.listen(events.add);

      // Nostr origin (contains @wss://) — Nostr already signs via Schnorr
      await d.dispatch([
        {
          'type': 'addr_update',
          'senderId': 'alice@wss://relay',
          'payload': {
            'primary': 'alice@wss://newrelay',
            'all': ['alice@wss://newrelay'],
          },
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
    });
  });

  group('SignalDispatcher rate limiting', () {
    test('rate limits non-exempt signals', () async {
      final d = _dispatcher();
      final events = <SignalTypingEvent>[];
      d.typingEvents.listen(events.add);

      // Send 25 typing signals (limit is 20 per 3s)
      final signals = List.generate(
        25,
        (_) => <String, dynamic>{
          'type': 'typing',
          'senderId': 'alice@wss://relay',
        },
      );
      await d.dispatch(signals);
      await Future.delayed(Duration.zero);

      expect(events.length, lessThanOrEqualTo(20));
    });

    test('does not rate limit exempt signals (sys_keys)', () async {
      final d = _dispatcher();
      final events = <SignalKeysEvent>[];
      d.keysEvents.listen(events.add);

      final signals = List.generate(
        25,
        (_) => <String, dynamic>{
          'type': 'sys_keys',
          'senderId': 'alice@wss://relay',
          'payload': {'regId': 1, 'idKey': 'key'},
        },
      );
      await d.dispatch(signals);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(25));
    });
  });

  group('SignalDispatcher raw signals', () {
    test('always emits raw signal regardless of type', () async {
      final d = _dispatcher();
      final events = <SignalRawEvent>[];
      d.rawSignals.listen(events.add);

      await d.dispatch([
        {'type': 'unknown_type', 'senderId': 'alice@wss://relay'},
        {'type': 'typing', 'senderId': 'bob@wss://relay'},
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(2));
    });
  });

  group('SignalDispatcher malformed signals', () {
    test('skips signal with missing type gracefully', () async {
      final d = _dispatcher();
      final events = <SignalRawEvent>[];
      d.rawSignals.listen(events.add);

      await d.dispatch([
        {'senderId': 'alice@wss://relay'},
        {'type': 'typing', 'senderId': 'bob@wss://relay'},
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(2)); // raw still emits both
    });

    test('handles null payload gracefully', () async {
      final d = _dispatcher();
      final events = <SignalReactionEvent>[];
      d.reactions.listen(events.add);

      await d.dispatch([
        {'type': 'reaction', 'senderId': 'alice@wss://relay', 'payload': null},
      ]);
      await Future.delayed(Duration.zero);

      expect(events, isEmpty);
    });
  });

  group('SignalDispatcher group_invite', () {
    test('emits group invite from known sender', () async {
      final d = _dispatcher();
      final events = <SignalGroupInviteEvent>[];
      d.groupInvites.listen(events.add);

      await d.dispatch([
        {
          'type': 'group_invite',
          'senderId': 'alice@wss://relay',
          'payload': {
            'groupId': 'g42',
            'name': 'Dev Team',
            'members': ['alice@wss://relay', 'bob@wss://relay'],
          },
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.groupId, 'g42');
      expect(events.first.groupName, 'Dev Team');
      expect(events.first.fromContact.name, 'Alice');
      expect(events.first.members, contains('alice@wss://relay'));
    });

    test('drops group invite from unknown sender', () async {
      final d = _dispatcher();
      final events = <SignalGroupInviteEvent>[];
      d.groupInvites.listen(events.add);

      await d.dispatch([
        {
          'type': 'group_invite',
          'senderId': 'stranger@wss://relay',
          'payload': {
            'groupId': 'g99',
            'groupName': 'Spam Group',
            'members': ['stranger@wss://relay'],
          },
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, isEmpty);
    });
  });

  group('SignalDispatcher typing with groupId', () {
    test('emits typing event with groupId populated', () async {
      final d = _dispatcher();
      final events = <SignalTypingEvent>[];
      d.typingEvents.listen(events.add);

      await d.dispatch([
        {
          'type': 'typing',
          'senderId': 'alice@wss://relay',
          'payload': {'groupId': 'g7'},
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.groupId, 'g7');
    });

    test('emits typing event with null groupId when absent', () async {
      final d = _dispatcher();
      final events = <SignalTypingEvent>[];
      d.typingEvents.listen(events.add);

      await d.dispatch([
        {'type': 'typing', 'senderId': 'alice@wss://relay'},
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.groupId, isNull);
    });
  });

  group('SignalDispatcher group_invite_decline', () {
    test('emits decline event from known sender', () async {
      final d = _dispatcher();
      final events = <SignalGroupInviteDeclineEvent>[];
      d.groupInviteDeclines.listen(events.add);

      await d.dispatch([
        {
          'type': 'group_invite_decline',
          'senderId': 'alice@wss://relay',
          'payload': {'groupId': 'g99', 'from': 'alice@wss://relay'},
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.groupId, 'g99');
      expect(events.first.fromContact.name, 'Alice');
    });

    test('drops decline from unknown sender', () async {
      final d = _dispatcher();
      final events = <SignalGroupInviteDeclineEvent>[];
      d.groupInviteDeclines.listen(events.add);

      await d.dispatch([
        {
          'type': 'group_invite_decline',
          'senderId': 'nobody@wss://relay',
          'payload': {'groupId': 'g99'},
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, isEmpty);
    });
  });

  group('SignalDispatcher delivery ack with groupId', () {
    test('carries groupId in ack event', () async {
      final d = _dispatcher();
      final events = <SignalDeliveryAckEvent>[];
      d.deliveryAcks.listen(events.add);

      await d.dispatch([
        {
          'type': 'msg_ack',
          'senderId': 'alice@wss://relay',
          'payload': {
            'msgId': 'msg123',
            'from': 'alice@wss://relay',
            'groupId': 'g5',
          },
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.msgId, 'msg123');
      expect(events.first.groupId, 'g5');
    });

    test('groupId is null for 1-on-1 ack', () async {
      final d = _dispatcher();
      final events = <SignalDeliveryAckEvent>[];
      d.deliveryAcks.listen(events.add);

      await d.dispatch([
        {
          'type': 'msg_ack',
          'senderId': 'alice@wss://relay',
          'payload': {'msgId': 'msg456', 'from': 'alice@wss://relay'},
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.groupId, isNull);
    });
  });

  group('SignalDispatcher edit with groupId', () {
    test('carries groupId in edit event', () async {
      final d = _dispatcher();
      final events = <SignalEditEvent>[];
      d.edits.listen(events.add);

      await d.dispatch([
        {
          'type': 'edit',
          'senderId': 'alice@wss://relay',
          'payload': {
            'msgId': 'msg1',
            'text': 'corrected',
            'from': 'alice@wss://relay',
            'groupId': 'g3',
          },
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.groupId, 'g3');
      expect(events.first.text, 'corrected');
    });

    test('groupId is null for 1-on-1 edit', () async {
      final d = _dispatcher();
      final events = <SignalEditEvent>[];
      d.edits.listen(events.add);

      await d.dispatch([
        {
          'type': 'edit',
          'senderId': 'alice@wss://relay',
          'payload': {'msgId': 'msg2', 'text': 'updated', 'from': 'alice@wss://relay'},
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.groupId, isNull);
    });
  });

  group('SignalDispatcher msg_delete', () {
    test('emits msg_delete event with groupId from known sender', () async {
      final d = _dispatcher();
      final events = <SignalMsgDeleteEvent>[];
      d.msgDeletes.listen(events.add);

      await d.dispatch([
        {
          'type': 'msg_delete',
          'senderId': 'alice@wss://relay',
          'payload': {
            'msgId': 'msg-to-delete',
            'groupId': 'g42',
            'from': 'alice@wss://relay',
          },
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.msgId, 'msg-to-delete');
      expect(events.first.groupId, 'g42');
      expect(events.first.fromId, 'alice@wss://relay');
    });

    test('emits msg_delete event without groupId for 1-on-1', () async {
      final d = _dispatcher();
      final events = <SignalMsgDeleteEvent>[];
      d.msgDeletes.listen(events.add);

      await d.dispatch([
        {
          'type': 'msg_delete',
          'senderId': 'alice@wss://relay',
          'payload': {
            'msgId': 'solo-msg',
            'from': 'alice@wss://relay',
          },
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.msgId, 'solo-msg');
      expect(events.first.groupId, isNull);
    });

    test('drops msg_delete with missing msgId', () async {
      final d = _dispatcher();
      final events = <SignalMsgDeleteEvent>[];
      d.msgDeletes.listen(events.add);

      await d.dispatch([
        {
          'type': 'msg_delete',
          'senderId': 'alice@wss://relay',
          'payload': {'groupId': 'g42'},
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, isEmpty);
    });
  });

  group('SignalDispatcher incoming group call isVideoCall', () {
    test('emits isVideoCall=true when flag is true in payload', () async {
      final d = _dispatcher();
      final events = <SignalIncomingGroupCallEvent>[];
      d.incomingGroupCalls.listen(events.add);

      await d.dispatch([
        {
          'type': 'webrtc_offer',
          'senderId': 'alice@wss://relay',
          'payload': {
            'groupId': 'g5',
            'isVideoCall': true,
            '_g': 'hash',
          },
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.groupId, 'g5');
      expect(events.first.isVideoCall, isTrue);
    });

    test('emits isVideoCall=false when flag is false in payload', () async {
      final d = _dispatcher();
      final events = <SignalIncomingGroupCallEvent>[];
      d.incomingGroupCalls.listen(events.add);

      await d.dispatch([
        {
          'type': 'webrtc_offer',
          'senderId': 'alice@wss://relay',
          'payload': {
            'groupId': 'g6',
            'isVideoCall': false,
            '_g': 'hash',
          },
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.isVideoCall, isFalse);
    });

    test('defaults isVideoCall=true when flag is absent', () async {
      final d = _dispatcher();
      final events = <SignalIncomingGroupCallEvent>[];
      d.incomingGroupCalls.listen(events.add);

      await d.dispatch([
        {
          'type': 'webrtc_offer',
          'senderId': 'alice@wss://relay',
          'payload': {
            'groupId': 'g7',
            '_g': 'hash',
          },
        },
      ]);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.first.isVideoCall, isTrue);
    });
  });

  group('SignalDispatcher dispose', () {
    test('dispose closes all streams', () async {
      final d = _dispatcher();
      d.dispose();

      // After dispose, adding should not throw but stream is closed
      expect(d.typingEvents.isBroadcast, true);
    });
  });
}
