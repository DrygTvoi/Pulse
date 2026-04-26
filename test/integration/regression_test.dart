/// Five regression tests covering bugs that were fixed during the
/// 2026-04-26 group-messaging push (commits 39546b0 + 9872c3f) plus
/// foundational invariants the harness should always uphold.
///
/// Each test should run in well under one second; all five together
/// finish in roughly the same time as one production-style E2E test.
///
/// Run with:
///   LD_LIBRARY_PATH=linux/libs flutter test test/integration/regression_test.dart
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import '../helpers/storage_isolation.dart';
import '../helpers/test_harness.dart';

void main() {
  setUp(() {
    resetSharedPreferences();
    resetSecureStorageBuckets();
  });

  // ─────────────────────────────────────────────────────────────────────
  // Test 1 — session-asymmetry recovery on reinstall.
  //
  // Catches the regression fixed in commit 39546b0: when one peer wipes
  // their Signal store (reinstall) and the other peer keeps the old
  // session, the next message must rebuild a fresh PreKey session
  // instead of silently failing on "Bad MAC".
  // ─────────────────────────────────────────────────────────────────────
  test('1on1 round-trip after Alice reinstalls (key rotation)', () async {
    final bus = InMemoryBus();
    addTearDown(bus.dispose);

    final alice1 = await TestClient.spawn('alice', bus);
    final bob = await TestClient.spawn('bob', bus);

    await alice1.addContact(bob);
    await bob.addContact(alice1);

    final firstFut = bob.incoming.first;
    await alice1.sendText(bob, 'before-rotation');
    expect((await firstFut.timeout(const Duration(seconds: 2))).text,
        'before-rotation');

    // Alice "reinstalls": wipe her TestClient (drops her libsignal store)
    // and respawn with the same address. New identity material, same
    // bus mailbox.
    await alice1.dispose();

    final alice2 = await TestClient.spawn('alice', bus, freshIdentity: true);
    addTearDown(alice2.dispose);
    addTearDown(bob.dispose);

    // Bob's store still trusts alice1's identity key. Production's
    // `deleteContactData` recovery (commit 39546b0) wipes the trusted
    // entry before rebuilding so the new identity is accepted.
    await bob.forgetPeer(alice2.address);

    // Both sides re-fetch each other's bundles.
    await alice2.addContact(bob);
    await bob.addContact(alice2);

    final secondFut = bob.incoming.first;
    await alice2.sendText(bob, 'after-rotation');
    final got = await secondFut.timeout(const Duration(seconds: 2));
    expect(got.text, 'after-rotation');
  });

  // ─────────────────────────────────────────────────────────────────────
  // Test 2 — buffered delivery across disconnect/reconnect.
  //
  // Catches commit 9872c3f: the production Pulse pool used to tear
  // down its subscription on reconnectInbox(), losing every message
  // queued during the offline window. The harness mirrors the
  // expected behaviour: messages are buffered while disconnected and
  // drained in FIFO order on reconnect.
  // ─────────────────────────────────────────────────────────────────────
  test('Bus disconnect → reconnect: buffered messages delivered in order',
      () async {
    final bus = InMemoryBus();
    addTearDown(bus.dispose);

    final alice = await TestClient.spawn('alice', bus);
    final bob = await TestClient.spawn('bob', bus);
    addTearDown(alice.dispose);
    addTearDown(bob.dispose);

    await alice.addContact(bob);
    await bob.addContact(alice);

    // Bring up a listener BEFORE the disconnect so we'd see anything
    // that leaked through.
    final received = <String>[];
    final sub = bob.incoming.listen((m) => received.add(m.text));

    bus.disconnect('bob');
    await alice.sendText(bob, 'one');
    await alice.sendText(bob, 'two');
    await alice.sendText(bob, 'three');

    // Confirm nothing arrived during the offline window.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(received, isEmpty,
        reason: 'no messages should be delivered while disconnected');

    bus.reconnect('bob');

    // Drain micro-tasks; libsignal decrypt is async.
    for (var i = 0; i < 10 && received.length < 3; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 25));
    }

    expect(received, equals(['one', 'two', 'three']));
    await sub.cancel();
  });

  // ─────────────────────────────────────────────────────────────────────
  // Test 3 — group sender-key fan-out to two members.
  //
  // Establishes the baseline group invariant: a creator can mint a
  // sender-key, distribute it to two members, encrypt one message, and
  // both members decrypt the SAME plaintext.
  // ─────────────────────────────────────────────────────────────────────
  test('Group of 3 — round-trip', () async {
    final bus = InMemoryBus();
    addTearDown(bus.dispose);

    final alice = await TestClient.spawn('alice', bus);
    final bob = await TestClient.spawn('bob', bus);
    final carol = await TestClient.spawn('carol', bus);
    addTearDown(alice.dispose);
    addTearDown(bob.dispose);
    addTearDown(carol.dispose);

    final bobGotMsg = bob.incomingGroup.firstWhere((e) => e.kind == 'msg');
    final carolGotMsg = carol.incomingGroup.firstWhere((e) => e.kind == 'msg');

    final group = await alice.createGroup('test-group', [bob, carol]);

    // Allow SKDM dispatch to settle before encrypting.
    await Future<void>.delayed(const Duration(milliseconds: 30));

    await alice.sendGroupText(group, 'hello group');

    final bobMsg = await bobGotMsg.timeout(const Duration(seconds: 2));
    final carolMsg = await carolGotMsg.timeout(const Duration(seconds: 2));

    expect(bobMsg.text, 'hello group');
    expect(carolMsg.text, 'hello group');
    expect(bobMsg.groupId, group.id);
    expect(carolMsg.groupId, group.id);
    expect(bobMsg.fromAddr, alice.address);
    expect(carolMsg.fromAddr, alice.address);
  });

  // ─────────────────────────────────────────────────────────────────────
  // Test 4 — kicked member receives a 'removed' notification.
  //
  // Catches commit 39546b0's invariant: when alice kicks carol, the
  // production code now broadcasts the group-update to the OLD roster
  // (including carol) so the kicked member learns they're out. Before
  // the fix, carol's roster snapshot stayed stale forever.
  // ─────────────────────────────────────────────────────────────────────
  test('Group — kicked member receives roster removal', () async {
    final bus = InMemoryBus();
    addTearDown(bus.dispose);

    final alice = await TestClient.spawn('alice', bus);
    final bob = await TestClient.spawn('bob', bus);
    final carol = await TestClient.spawn('carol', bus);
    addTearDown(alice.dispose);
    addTearDown(bob.dispose);
    addTearDown(carol.dispose);

    // Buffer carol's group events from the moment her client comes up.
    final carolEvents = <DecryptedGroupMessage>[];
    final carolSub =
        carol.incomingGroup.listen((e) => carolEvents.add(e));
    addTearDown(carolSub.cancel);

    // Same for bob — used to confirm the new roster also reaches the
    // remaining members.
    final bobEvents = <DecryptedGroupMessage>[];
    final bobSub = bob.incomingGroup.listen((e) => bobEvents.add(e));
    addTearDown(bobSub.cancel);

    final group = await alice.createGroup('kick-test', [bob, carol]);
    await Future<void>.delayed(const Duration(milliseconds: 30));

    // Sanity: carol got the initial roster.
    expect(carolEvents.where((e) => e.kind == 'roster'), isNotEmpty);

    await alice.kickFromGroup(group, carol);
    await Future<void>.delayed(const Duration(milliseconds: 30));

    // Catches commit 39546b0: kicked member must be told about the kick.
    final removalEvents = carolEvents.where((e) => e.kind == 'removed');
    expect(removalEvents, isNotEmpty,
        reason: 'kicked member should receive a removal notice');
    expect(removalEvents.first.groupId, group.id);

    // The remaining roster should have been delivered to bob and should
    // exclude carol.
    final bobRosters = bobEvents.where((e) => e.kind == 'roster').toList();
    expect(bobRosters.last.members, contains(bob.address));
    expect(bobRosters.last.members, contains(alice.address));
    expect(bobRosters.last.members, isNot(contains(carol.address)));
  });

  // ─────────────────────────────────────────────────────────────────────
  // Test 5 — replaceAddress preserves an existing subscription.
  //
  // Catches the addr_update UNION-MERGE invariant: when a peer rotates
  // their pulse address, in-flight messages routed to the old address
  // still reach the existing client without the listener being torn
  // down. Bob speaks to alice via her old address; the bus aliases
  // forward to her new mailbox; alice keeps her Signal session and
  // decrypts both messages.
  // ─────────────────────────────────────────────────────────────────────
  test('Bus replaceAddress — messages still route to the existing client',
      () async {
    final bus = InMemoryBus();
    addTearDown(bus.dispose);

    final alice = await TestClient.spawn('alice@bus', bus);
    final bob = await TestClient.spawn('bob@bus', bus);
    addTearDown(alice.dispose);
    addTearDown(bob.dispose);

    await alice.addContact(bob);
    await bob.addContact(alice);

    // Warm up sessions on both sides — alice -> bob first so bob's
    // session reaches "established" state before we test the reverse.
    final firstBob = bob.incoming.first;
    await alice.sendText(bob, 'hi-1');
    expect((await firstBob.timeout(const Duration(seconds: 2))).text, 'hi-1');

    final firstAlice = alice.incoming.first;
    await bob.sendText(alice, 'reply-1');
    expect((await firstAlice.timeout(const Duration(seconds: 2))).text,
        'reply-1');

    // Alice rotates her bus address. Bob has no idea — he still sends
    // to 'alice@bus'. UNION-MERGE on the bus aliases the old key to the
    // new mailbox so alice's existing subscription stays live.
    bus.replaceAddress('alice@bus', 'alice2@bus');

    final secondAlice = alice.incoming.first;
    await bob.sendText(alice, 'reply-2');
    final got = await secondAlice.timeout(const Duration(seconds: 2));
    expect(got.text, 'reply-2');

    // Direction alice -> bob should also keep working: alice sends with
    // her usual `from`, bob's mailbox is unaffected by the alias.
    final secondBob = bob.incoming.first;
    await alice.sendText(bob, 'hi-2');
    expect((await secondBob.timeout(const Duration(seconds: 2))).text, 'hi-2');
  });
}
