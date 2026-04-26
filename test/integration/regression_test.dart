/// Regression tests covering bugs that were fixed during the
/// 2026-04-26 group-messaging push (commits 39546b0 + 9872c3f) plus
/// foundational invariants the harness should always uphold.
///
/// Each test should run in well under one second; the full suite
/// finishes in roughly the same time as one production-style E2E test.
///
/// Run with:
///   LD_LIBRARY_PATH=linux/libs flutter test test/integration/regression_test.dart
library;

import 'dart:async';
import 'dart:convert';

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

    // Deterministic SKDM-ready barrier: wait for the SKDM-processed
    // future the harness exposes. No `Future.delayed` race window —
    // the future completes the moment _onGroupSkdm finishes its async
    // processing for this (groupId, sender) pair on each member.
    await Future.wait([
      bob.waitForSkdmProcessed(group.id, alice.address)
          .timeout(const Duration(seconds: 3)),
      carol.waitForSkdmProcessed(group.id, alice.address)
          .timeout(const Duration(seconds: 3)),
    ]);

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

    // Deterministic barrier for the initial roster, attached BEFORE
    // createGroup so we never miss the event.
    final carolFirstRoster =
        carol.incomingGroup.firstWhere((e) => e.kind == 'roster');
    final bobFirstRoster =
        bob.incomingGroup.firstWhere((e) => e.kind == 'roster');

    final group = await alice.createGroup('kick-test', [bob, carol]);

    // Wait for both members to actually receive the initial roster
    // event — replaces a timer-based 30ms wait that could miss the
    // event under load.
    await Future.wait([
      carolFirstRoster.timeout(const Duration(seconds: 2)),
      bobFirstRoster.timeout(const Duration(seconds: 2)),
    ]);

    // Sanity: carol got the initial roster.
    expect(carolEvents.where((e) => e.kind == 'roster'), isNotEmpty);

    // Pre-arm barriers BEFORE the kick so we observe the events.
    final carolRemoval =
        carol.incomingGroup.firstWhere((e) => e.kind == 'removed');
    final bobNewRoster =
        bob.incomingGroup.firstWhere((e) => e.kind == 'roster');

    await alice.kickFromGroup(group, carol);

    // Catches commit 39546b0: kicked member must be told about the kick.
    final removeEvent =
        await carolRemoval.timeout(const Duration(seconds: 2));
    expect(removeEvent.groupId, group.id);
    expect(carolEvents.any((e) => e.kind == 'removed'), isTrue);

    // The remaining roster must reach bob and must exclude carol.
    final bobRosterEvent =
        await bobNewRoster.timeout(const Duration(seconds: 2));
    expect(bobRosterEvent.members, contains(bob.address));
    expect(bobRosterEvent.members, contains(alice.address));
    expect(bobRosterEvent.members, isNot(contains(carol.address)));
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

  // ─────────────────────────────────────────────────────────────────────
  // Test 6 — Session reset with inline bundle eliminates the relay race.
  //
  // Catches commit 39546b0: when a peer's Signal session for us has
  // gone bad (e.g. they wiped state), the recovery flow must NOT be
  //
  //   sender hits Bad MAC → wipe own session → wait for next inbound
  //   → maybe re-fetch peer bundle from relay → maybe rebuild → maybe
  //   the next message arrives before the re-fetch completes → loop.
  //
  // Instead the receiver who hit Bad MAC sends a `session_reset`
  // signal carrying its OWN current PreKey bundle inline. The sender
  // applies it atomically (forgetPeer + processPreKeyBundle) and the
  // very next outbound message decrypts on the first try — exactly
  // ONE round-trip recovery.
  // ─────────────────────────────────────────────────────────────────────
  test('session_reset with inline bundle: 1 round-trip recovery', () async {
    final bus = InMemoryBus();
    addTearDown(bus.dispose);

    final alice = await TestClient.spawn('alice@bus', bus);
    final bob = await TestClient.spawn('bob@bus', bus);
    addTearDown(alice.dispose);
    addTearDown(bob.dispose);

    await alice.addContact(bob);
    await bob.addContact(alice);

    // Warm up: hello round-trips fine.
    final helloFut = bob.incoming.first;
    await alice.sendText(bob, 'hello');
    expect((await helloFut.timeout(const Duration(seconds: 2))).text, 'hello');

    // Bob's session for alice goes bad — simulates "bob wiped state"
    // or "the on-disk session record got corrupted".
    await bob.forgetPeer(alice.address);

    // Alice sends — bob's _onDirectMessage hits a decrypt-fail and
    // (per the production fix) emits a `session_reset` signal back
    // at alice with bob's CURRENT bundle inline.
    final aliceRecovery = alice.recoveryEvents.first;
    await alice.sendText(bob, 'after-reset');

    // Alice receives the `session_reset` and atomically rebuilds.
    await aliceRecovery.timeout(const Duration(seconds: 2));
    expect(alice.sessionResetReceiveCount, 1,
        reason: 'alice should process exactly one session_reset');
    expect(bob.sessionResetSendCount, 1,
        reason: 'bob should emit exactly one session_reset for one fail');
    expect(bob.decryptFailCount, 1,
        reason: 'exactly one decrypt-fail before recovery');

    // Next message decrypts on the first try — the recovery is atomic
    // so we do NOT need to "wait for relay propagation" before retry.
    final recoveredFut = bob.incoming.first;
    await alice.sendText(bob, 'after-recovery');
    final got = await recoveredFut.timeout(const Duration(seconds: 2));
    expect(got.text, 'after-recovery');

    // Final invariant: NO additional resets fired during the happy
    // path that follows recovery — the rate-limiter was not the
    // reason we converged, the inline-bundle handoff was.
    expect(bob.sessionResetSendCount, 1);
    expect(bob.decryptFailCount, 1);
  });

  // ─────────────────────────────────────────────────────────────────────
  // Test 7 — PQC unwrap failure triggers a re-handshake (not silent drop).
  //
  // Catches commit 39546b0's PQC branch: a sender that cached a peer's
  // OLD Kyber pubkey and wraps a signal against it would silently fail
  // on the receiver side. Pre-fix, the receiver dropped the envelope
  // with no log, no notify, no recovery — calls/files/keys vanished.
  //
  // Post-fix: receiver detects the unwrap-fail, broadcasts a `pqc_stale`
  // signal carrying its CURRENT Kyber pubkey inline. Sender refreshes
  // the cache and the next wrapped envelope succeeds.
  //
  // The harness models PQC as a 64-byte cached pubkey + byte-equality
  // check (no actual KEM). The bug being regression-guarded is in the
  // control flow, not in the KEM math.
  // ─────────────────────────────────────────────────────────────────────
  test('PQC unwrap fail triggers pqc_stale + recovery', () async {
    final bus = InMemoryBus();
    addTearDown(bus.dispose);

    final alice = await TestClient.spawn('alice@bus', bus);
    final bob = await TestClient.spawn('bob@bus', bus);
    addTearDown(alice.dispose);
    addTearDown(bob.dispose);

    await alice.addContact(bob);
    await bob.addContact(alice);

    alice.enablePqc();
    bob.enablePqc();
    alice.cachePeerKyber(bob);
    bob.cachePeerKyber(alice);

    // Warm-up: PQC envelope round-trips fine.
    final firstFut = bob.incoming.first;
    await alice.sendPqcText(bob, 'pqc-ok');
    expect(
      (await firstFut.timeout(const Duration(seconds: 2))).text,
      'pqc-ok',
    );

    // Bob rotates his Kyber keypair WITHOUT telling alice (simulates a
    // peer that re-keyed mid-session, or reinstalled their PQC layer).
    bob.rotateKyber();

    // Alice still wraps with the stale cached pubkey — bob's unwrap
    // fails on the byte-equality check and (per commit 39546b0) emits
    // a `pqc_stale` signal carrying his fresh pubkey inline.
    await alice.sendPqcText(bob, 'pqc-fail');

    // Drain microtasks so the bus-routed signal lands in alice's
    // inbox handler.
    for (var i = 0; i < 10 && bob.pqcStaleSendCount == 0; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 25));
    }

    expect(bob.pqcStaleSendCount, 1,
        reason: 'unwrap-fail must trigger one pqc_stale, not silent drop');

    // Wait for the stale signal to refresh alice's cache.
    await Future<void>.delayed(const Duration(milliseconds: 50));

    // Retry — alice's cached pubkey is now bob's fresh one, so the
    // next wrapped envelope decrypts.
    final retryFut = bob.incoming.first;
    await alice.sendPqcText(bob, 'pqc-recovered');
    final got = await retryFut.timeout(const Duration(seconds: 2));
    expect(got.text, 'pqc-recovered');

    // Invariant: no further pqc_stale needed — the recovery loop
    // converged in one round-trip, not a silent retry storm.
    expect(bob.pqcStaleSendCount, 1);
  });

  // ─────────────────────────────────────────────────────────────────────
  // Test 8 — Wide stale-PreKey detection (Bad MAC / no-session) is
  // rate-limited to one session_reset per cooldown.
  //
  // Catches commit 39546b0: pre-fix, only `InvalidKeyIdException`
  // triggered `_pushOwnBundleTo`. Post-fix, the detector ALSO catches
  // Bad MAC and "no valid sessions" — both of which fire when the
  // sender's session for us has been wiped. The fix would be useless
  // (and a flooding hazard) without rate-limiting: 3 consecutive
  // failures must produce ONE outgoing `session_reset`, not three.
  // ─────────────────────────────────────────────────────────────────────
  test('Bad MAC / no-session detection is rate-limited to 1 reset',
      () async {
    final bus = InMemoryBus();
    addTearDown(bus.dispose);

    final alice = await TestClient.spawn('alice@bus', bus);
    final bob = await TestClient.spawn('bob@bus', bus);
    addTearDown(alice.dispose);
    addTearDown(bob.dispose);

    await alice.addContact(bob);
    await bob.addContact(alice);

    // Warm-up consumes bob's one-time prekey #0. Without this, bob's
    // store still has prekey 0 and the post-wipe PreKey message
    // decrypts cleanly (no session_reset triggered).
    final warmFut = bob.incoming.first;
    await alice.sendText(bob, 'warmup');
    expect((await warmFut.timeout(const Duration(seconds: 2))).text, 'warmup');

    // Bob's session for alice goes bad. The trusted-identity entry
    // is gone too — alice's next PreKey message will TOFU-reaccept,
    // try to load prekey 0 (consumed by warm-up), and throw
    // InvalidKeyIdException → recovery flow.
    await bob.forgetPeer(alice.address);

    // Alice fires 3 messages rapidly. Each one hits decrypt-fail on
    // bob until alice's session is rebuilt via the inline `session_reset`
    // bundle. The fix demands: ONE outgoing `session_reset`, not three.
    //
    // We do NOT wait for recovery between sends — the messages get
    // queued back-to-back so the rate-limiter sees rapid fire.
    final aSent = alice.sendText(bob, 'a');
    final bSent = alice.sendText(bob, 'b');
    final cSent = alice.sendText(bob, 'c');
    await Future.wait([aSent, bSent, cSent]);

    // Wait for bob's outgoing reset count to stabilize.
    await bob.waitForRecovery(const Duration(seconds: 3));

    // ── Core invariant ─────────────────────────────────────────────
    expect(bob.sessionResetSendCount, 1,
        reason:
            '3 consecutive decrypt failures must produce exactly ONE '
            'session_reset (rate-limiter regression — commit 39546b0)');
    expect(bob.decryptFailCount, greaterThanOrEqualTo(1),
        reason: 'at least one decrypt-fail should be observed');

    // ── Recovery still works after rate-limit kicked in ────────────
    final recoverFut = bob.incoming.first;
    await alice.sendText(bob, 'after');
    final got = await recoverFut.timeout(const Duration(seconds: 2));
    expect(got.text, 'after');
  });

  // ─────────────────────────────────────────────────────────────────────
  // Test 9 — pool subscriptions persist after reconnect simulation.
  //
  // Regression for commit 9872c3f: `reconnectInbox()` cancelled every
  // signal subscription but never re-attached the pool readers. The next
  // `ensureGroupPulseConnection()` early-returned because the pool still
  // looked "open", and every inbound signal was silently dropped on the
  // floor.
  //
  // Invariant: after `pulseRegressionSimulateReconnect()`, the next
  // inbound message reaches the recipient without loss.
  // ─────────────────────────────────────────────────────────────────────
  test(
      'Pool subscription survives reconnectInbox — '
      'next inbound after reconnect is delivered', () async {
    final bus = InMemoryBus();
    addTearDown(bus.dispose);

    final alice = await TestClient.spawn('alice', bus);
    final bob = await TestClient.spawn('bob', bus);
    addTearDown(alice.dispose);
    addTearDown(bob.dispose);

    await alice.addContact(bob);
    await bob.addContact(alice);

    // Baseline: alice receives a message to confirm her subscription is
    // wired before the simulated reconnect.
    final beforeFut = alice.incoming.first;
    await bob.sendText(alice, 'before');
    expect((await beforeFut.timeout(const Duration(seconds: 2))).text,
        'before');

    // Tear down + re-establish alice's bus subscription. This is the
    // regression: any future change to reconnectInbox MUST resubscribe
    // before this completes.
    await alice.pulseRegressionSimulateReconnect();

    // After reconnect, the next inbound message must still reach alice.
    final afterFut = alice.incoming.first;
    await bob.sendText(alice, 'after-reconnect');
    final got = await afterFut.timeout(const Duration(seconds: 2));
    expect(got.text, 'after-reconnect',
        reason:
            'reconnectInbox must re-establish the subscription so signals '
            'arriving after the reconnect are still delivered');
  });

  // ─────────────────────────────────────────────────────────────────────
  // Test 10 — wake-from-sleep detection triggers reconnect.
  //
  // Regression for commit 9872c3f: after the OS suspends the process the
  // WS sink turns into a zombie — `sink.add` returns void and writes go
  // into /dev/null. The watchdog now checks wall-clock between ticks; a
  // gap > 60s triggers tear-down + reopen of the pool.
  //
  // Invariant: messages sent while alice was "asleep" must be delivered
  // after `pulseRegressionSimulateWake()` resumes the bus.
  // ─────────────────────────────────────────────────────────────────────
  test(
      'Wake-from-sleep watchdog reopens pool — '
      'messages buffered during sleep arrive after wake', () async {
    final bus = InMemoryBus();
    addTearDown(bus.dispose);

    final alice = await TestClient.spawn('alice', bus);
    final bob = await TestClient.spawn('bob', bus);
    addTearDown(alice.dispose);
    addTearDown(bob.dispose);

    await alice.addContact(bob);
    await bob.addContact(alice);

    // Baseline send so we know the pipe is healthy before sleep.
    final baselineFut = alice.incoming.first;
    await bob.sendText(alice, 'baseline');
    expect((await baselineFut.timeout(const Duration(seconds: 2))).text,
        'baseline');

    // Buffer everything else alice receives so we can assert on the
    // post-wake delivery without racing `.first`.
    final received = <String>[];
    final sub = alice.incoming.listen((m) => received.add(m.text));
    addTearDown(sub.cancel);

    // Alice's process gets suspended. Bob keeps sending; messages pile up
    // in the bus offline buffer.
    await alice.pulseRegressionSimulateSleep(const Duration(seconds: 90));

    await bob.sendText(alice, 'while-asleep-1');
    await bob.sendText(alice, 'while-asleep-2');

    // Confirm nothing leaked through during the sleep window.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(received, isEmpty,
        reason: 'no messages should be delivered while suspended');

    // Wake. Watchdog detects > 60s gap → tear down + reopen.
    await alice.pulseRegressionSimulateWake();

    // Drain micro-tasks for libsignal decrypt.
    for (var i = 0; i < 12 && received.length < 2; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 25));
    }

    expect(received, equals(['while-asleep-1', 'while-asleep-2']),
        reason: 'wake must drain the offline buffer in FIFO order');

    // And new messages after wake still flow.
    await bob.sendText(alice, 'after-wake');
    for (var i = 0; i < 12 && received.length < 3; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 25));
    }
    expect(received.last, 'after-wake');
  });

  // ─────────────────────────────────────────────────────────────────────
  // Test 11 — addr_update UNION-MERGE preserves Pulse address.
  //
  // Regression for commit 39546b0: addr_update used to REPLACE the
  // contact's address map. If a peer re-published their Nostr addresses
  // before the Pulse startup probe finished, the incoming addr_update
  // arrived without the Pulse transport and silently wiped the Pulse
  // pubkey we already knew — every future Pulse send dropped on the floor.
  //
  // Invariant: an addr_update missing the Pulse transport must NOT erase
  // a previously-known Pulse pubkey for that contact.
  // ─────────────────────────────────────────────────────────────────────
  test(
      'addr_update UNION-MERGE preserves Pulse address when update only '
      'carries Nostr', () async {
    final bus = InMemoryBus();
    addTearDown(bus.dispose);

    final alice = await TestClient.spawn('alice', bus);
    final bob = await TestClient.spawn('bob', bus);
    addTearDown(alice.dispose);
    addTearDown(bob.dispose);

    // Seed alice's local view of bob: she already knows his Pulse
    // pubkey + a Nostr relay.
    final knownPulse = bob.pulseRegressionSelfPulsePub;
    alice.pulseRegressionSetContactAddresses(bob.address, {
      'Pulse': [knownPulse],
      'Nostr': ['bob@wss://relay-old.example'],
    });
    expect(alice.pulseRegressionGetContactPulse(bob.address), knownPulse,
        reason: 'sanity: alice knows bob via Pulse before the update');

    // Bob publishes an addr_update that ONLY carries Nostr addresses —
    // his Pulse startup probe has not run yet, so his shareable address
    // map omits the Pulse transport entirely. With pre-39546b0 REPLACE
    // semantics, this would erase alice's Pulse entry for bob.
    final update = BusMessage(
      to: alice.address,
      from: bob.address,
      kind: 'addr_update',
      payload: jsonEncode({
        'transportAddresses': {
          'Nostr': [
            'bob@wss://relay-new-1.example',
            'bob@wss://relay-new-2.example',
          ],
        },
      }),
    );
    await alice.pulseRegressionHandleAddrUpdate(update);

    // The Pulse pubkey alice already knew must still be there.
    expect(alice.pulseRegressionGetContactPulse(bob.address), knownPulse,
        reason:
            'addr_update must UNION-MERGE: a payload without Pulse must '
            'not erase a previously-learned Pulse pubkey');
  });

  // ─────────────────────────────────────────────────────────────────────
  // Test 12 — member Pulse addresses seeded on group invite.
  //
  // Regression for commit 39546b0: when a Pulse group is created, the
  // invite payload now carries `memberPulsePubkeys: {memberAddr →
  // pulsePub}`. The receiver auto-populates `contacts['Pulse']` for every
  // member so the FIRST message in the group routes via Pulse without an
  // out-of-band addr_update round-trip. Before the fix, carol's first
  // group send would fan out via whatever transport happened to be
  // configured (or silently fail on Pulse-only contacts).
  //
  // Invariant: after applying the invite, carol's local contact book has
  // a non-empty Pulse pubkey for every other member.
  // ─────────────────────────────────────────────────────────────────────
  test(
      'Group invite seeds member Pulse pubkeys — '
      'first group message reaches every member', () async {
    final bus = InMemoryBus();
    addTearDown(bus.dispose);

    final alice = await TestClient.spawn('alice', bus);
    final bob = await TestClient.spawn('bob', bus);
    final carol = await TestClient.spawn('carol', bus);
    addTearDown(alice.dispose);
    addTearDown(bob.dispose);
    addTearDown(carol.dispose);

    // Buffer the invite that alice broadcasts to carol.
    final inviteFut = bus
        .inbox(carol.address)
        .firstWhere((m) => m.kind == 'group_invite');

    // Alice creates the group and sends carol an invite that includes
    // memberPulsePubkeys for every member (alice + bob).
    const groupId = 'g-pulse-seed-001';
    await alice.pulseRegressionSendGroupInvite(
      carol,
      groupId: groupId,
      members: [alice, bob],
    );

    final invite = await inviteFut.timeout(const Duration(seconds: 1));
    await carol.pulseRegressionApplyInvite(invite);

    // Carol's local contact book must now know every other member's
    // Pulse pubkey — proving the seed-on-invite path worked. With the
    // pre-39546b0 invite payload (no memberPulsePubkeys) these would
    // both be null.
    final bobPulse = carol.pulseRegressionGetContactPulse(bob.address);
    final alicePulse = carol.pulseRegressionGetContactPulse(alice.address);
    expect(bobPulse, isNotNull,
        reason: 'invite must seed Pulse pubkey for bob');
    expect(alicePulse, isNotNull,
        reason: 'invite must seed Pulse pubkey for alice');
    expect(bobPulse, bob.pulseRegressionSelfPulsePub);
    expect(alicePulse, alice.pulseRegressionSelfPulsePub);

    // And carol shouldn't have accidentally seeded a self-entry.
    expect(carol.pulseRegressionGetContactPulse(carol.address), isNull,
        reason: 'invite must not seed a self Pulse entry');

    // Sanity: now that Pulse is seeded, a real first group message
    // round-trips to bob and alice (proves the harness end-to-end works
    // when the Pulse pubkeys are present from the very first send).
    await carol.addContact(bob);
    await carol.addContact(alice);

    // Pre-arm the msg listeners BEFORE createGroup so we don't miss
    // anything between "group created" and "barrier set up".
    final bobGotMsg = bob.incomingGroup.firstWhere((e) => e.kind == 'msg');
    final aliceGotMsg =
        alice.incomingGroup.firstWhere((e) => e.kind == 'msg');

    final group = await carol.createGroup('post-invite', [bob, alice]);

    // Wait for SKDM to be processed on every other member before sending
    // — replaces a 30ms timer that could be too short under load.
    await Future.wait([
      bob.waitForSkdmProcessed(group.id, carol.address)
          .timeout(const Duration(seconds: 3)),
      alice.waitForSkdmProcessed(group.id, carol.address)
          .timeout(const Duration(seconds: 3)),
    ]);

    await carol.sendGroupText(group, 'first-with-seeded-pulse');

    final bobMsg = await bobGotMsg.timeout(const Duration(seconds: 2));
    final aliceMsg = await aliceGotMsg.timeout(const Duration(seconds: 2));
    expect(bobMsg.text, 'first-with-seeded-pulse');
    expect(aliceMsg.text, 'first-with-seeded-pulse');
  });
}
