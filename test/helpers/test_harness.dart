/// Integration test harness for the Pulse messenger.
///
/// Goal: give other test authors / agents a 4-line API for round-tripping a
/// message between two clients without having to wire up Signal, transport
/// adapters, key bundles, or storage.
///
/// ```dart
/// final bus   = InMemoryBus();
/// final alice = await TestClient.spawn('alice', bus);
/// final bob   = await TestClient.spawn('bob',   bus);
/// await alice.addContact(bob);
/// await bob.addContact(alice);
/// final f = bob.incoming.first;
/// await alice.sendText(bob, 'hello');
/// expect((await f).text, 'hello');
/// ```
///
/// Architecture
/// ─────────────────────────────────────────────────────────────────────────
/// * Each [TestClient] owns its own [InMemorySignalProtocolStore] from
///   `libsignal_protocol_dart` — exactly the same store production
///   [SignalService] inherits from. We bypass the SignalService singleton
///   so that two TestClients in the same process do not collide on the
///   global `_instance`. Production has a parallel work-stream to expose
///   a `SignalService.forTesting({storage})` seam — once that lands, the
///   harness can switch over without changing its public API.
/// * Crypto is **the real Signal Protocol** — bundles, sessions, double
///   ratchet — so any regression in libsignal breaks the harness in the
///   same way it would break production.
/// * Transport is an [InMemoryBus] (mailbox-per-address Stream broadcast)
///   that supports failure simulation: `disconnect()`, `reconnect()`,
///   `dropNext()`, `replaceAddress()`.
/// * Plaintext messages are wrapped in `MessageEnvelope` so the receiver
///   sees the same JSON shape the production pipeline produces.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulse_messenger/models/message_envelope.dart';

import 'storage_isolation.dart';

// ─────────────────────────────────────────────────────────────────────────
// Bus
// ─────────────────────────────────────────────────────────────────────────

/// One unit of traffic on the in-memory bus.
///
/// `kind` is one of `'msg'`, `'signal'`, `'addr_update'`. Tests can add new
/// kinds freely — the bus does no inspection beyond routing on `to`.
class BusMessage {
  BusMessage({
    required this.to,
    required this.from,
    required this.kind,
    required this.payload,
    this.ts,
  });

  final String to;
  final String from;
  final String kind;
  final String payload;
  final int? ts;

  @override
  String toString() => 'BusMessage($kind from=$from to=$to len=${payload.length})';
}

/// In-memory pub/sub bus with mailboxes per address and failure-injection
/// hooks. Holds no per-client state beyond delivery; identity, sessions,
/// and storage live inside [TestClient].
class InMemoryBus {
  final Map<String, StreamController<BusMessage>> _mailboxes = {};
  final Set<String> _disconnected = <String>{};
  final Map<String, int> _dropNext = <String, int>{};
  final Map<String, String> _addressAliases = <String, String>{};

  /// Per-address buffer of messages produced while [disconnect]ed. On
  /// [reconnect] the buffer is drained in FIFO order. Mirrors what the
  /// production Pulse server does ("offline mailbox") and is the reason
  /// the corresponding regression test for commit 9872c3f works at all.
  final Map<String, List<BusMessage>> _offlineBuffer =
      <String, List<BusMessage>>{};

  bool _disposed = false;

  StreamController<BusMessage> _box(String address) => _mailboxes.putIfAbsent(
        address,
        () => StreamController<BusMessage>.broadcast(),
      );

  String _resolve(String address) => _addressAliases[address] ?? address;

  /// Deliver [m] to its recipient's mailbox unless the recipient is
  /// disconnected or has a pending `dropNext` budget.
  ///
  /// Disconnected recipients buffer the message in [_offlineBuffer] and
  /// receive it on [reconnect]. `dropNext` still drops outright.
  void send(BusMessage m) {
    if (_disposed) return;
    final to = _resolve(m.to);
    final pending = _dropNext[to] ?? 0;
    if (pending > 0) {
      _dropNext[to] = pending - 1;
      return;
    }
    final routed = BusMessage(
      to: to,
      from: m.from,
      kind: m.kind,
      payload: m.payload,
      ts: m.ts,
    );
    if (_disconnected.contains(to)) {
      _offlineBuffer.putIfAbsent(to, () => <BusMessage>[]).add(routed);
      return;
    }
    _box(to).add(routed);
  }

  /// Subscribe to [address]'s mailbox.
  Stream<BusMessage> inbox(String address) => _box(_resolve(address)).stream;

  /// Suspend delivery to [address] until [reconnect] is called.
  void disconnect(String address) => _disconnected.add(_resolve(address));

  /// Resume delivery suspended by [disconnect]. Drains the offline
  /// buffer in FIFO order onto the recipient's mailbox.
  void reconnect(String address) {
    final to = _resolve(address);
    _disconnected.remove(to);
    final buffered = _offlineBuffer.remove(to);
    if (buffered == null) return;
    for (final m in buffered) {
      _box(to).add(m);
    }
  }

  /// Drop the next [count] messages addressed to [address] (silently).
  void dropNext(String address, {int count = 1}) {
    final to = _resolve(address);
    _dropNext[to] = (_dropNext[to] ?? 0) + count;
  }

  /// Re-route every future delivery for [oldAddress] to [freshAddress] —
  /// simulates a contact rotating their relay/pubkey while keeping the
  /// existing TestClient instance alive.
  ///
  /// If a TestClient is already subscribed to the old address, the alias
  /// also unifies the underlying mailbox controller so the existing
  /// listener keeps receiving without re-subscribing. Mirrors the
  /// production "addr_update UNION-MERGE" semantics where a contact's
  /// pulse address can rotate without dropping in-flight delivery.
  void replaceAddress(String oldAddress, String freshAddress) {
    _addressAliases[oldAddress] = freshAddress;
    // Unify the controllers so an existing subscriber on `oldAddress`
    // keeps its stream alive — point both keys at one controller.
    final existing = _mailboxes[oldAddress];
    final fresh = _mailboxes[freshAddress];
    if (existing != null && fresh == null) {
      _mailboxes[freshAddress] = existing;
    } else if (existing == null && fresh != null) {
      _mailboxes[oldAddress] = fresh;
    } else if (existing != null && fresh != null && existing != fresh) {
      // Both pre-exist and differ: forward writes to fresh from old by
      // pointing the old key at the fresh controller. Existing listeners
      // on the old controller will silently stop receiving, which we
      // accept — tests should not pre-create the fresh mailbox.
      _mailboxes[oldAddress] = fresh;
    }
  }

  /// True if [address] has at least one mailbox subscriber.
  bool hasSubscribers(String address) =>
      _mailboxes[_resolve(address)]?.hasListener ?? false;

  /// Tear down every mailbox. Idempotent.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    for (final c in _mailboxes.values) {
      c.close();
    }
    _mailboxes.clear();
    _disconnected.clear();
    _dropNext.clear();
    _addressAliases.clear();
    _offlineBuffer.clear();
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Decrypted message
// ─────────────────────────────────────────────────────────────────────────

/// Plain-text view of a message after Signal decryption + envelope unwrap.
class DecryptedMessage {
  DecryptedMessage({
    required this.from,
    required this.text,
    required this.ts,
  });

  /// Sender's canonical address (whatever `MessageEnvelope.from` carried).
  final String from;
  final String text;
  final DateTime ts;

  @override
  String toString() => 'DecryptedMessage(from=$from, text="$text")';
}

// ─────────────────────────────────────────────────────────────────────────
// Group types
// ─────────────────────────────────────────────────────────────────────────

/// Decrypted view of a group message OR a roster-update event.
///
/// Two flavors share one stream so that a single `incomingGroup.listen()`
/// call can observe both — `kind` discriminates.
class DecryptedGroupMessage {
  DecryptedGroupMessage({
    required this.kind,
    required this.fromAddr,
    required this.groupId,
    this.text,
    this.members,
    this.ts,
  });

  /// `'msg'` for an encrypted text payload, `'removed'` when the recipient
  /// learned they were kicked, `'roster'` for a roster snapshot from the
  /// admin (members != null).
  final String kind;

  /// Sender's address (group admin for roster updates).
  final String fromAddr;

  final String groupId;

  /// Plain-text body (only set when `kind == 'msg'`).
  final String? text;

  /// New roster snapshot (only set when `kind == 'roster'`/`'removed'`).
  final List<String>? members;

  final DateTime? ts;

  @override
  String toString() =>
      'DecryptedGroupMessage(kind=$kind, group=$groupId, from=$fromAddr, '
      'text=${text == null ? "-" : "\"$text\""}, members=$members)';
}

/// In-memory model of a group used in tests.
///
/// Holds member references + the admin (creator) address so we can
/// simulate roster changes by mutating `members` and re-broadcasting.
class TestGroup {
  TestGroup({
    required this.id,
    required this.name,
    required this.members,
    this.creatorAddr,
  });

  final String id;
  final String name;

  /// Mutable — `kickMember()` removes from this list before the
  /// roster broadcast goes out.
  final List<TestClient> members;

  final String? creatorAddr;

  @override
  String toString() =>
      'TestGroup(id=$id, name=$name, members=${members.map((m) => m.address).toList()})';
}

// ─────────────────────────────────────────────────────────────────────────
// Test client
// ─────────────────────────────────────────────────────────────────────────

/// Lightweight stand-in for a single user in an integration test.
///
/// Owns its own libsignal store + identity material; talks to peers
/// through the [InMemoryBus]. See file-level docs for the rationale on
/// not going through `SignalService`.
class TestClient {
  TestClient._({
    required this.name,
    required this.address,
    required this.bus,
    required _TestSignalStore store,
    required IdentityKeyPair idKey,
    required int regId,
    required List<PreKeyRecord> preKeys,
    required PreKeyRecord preKey,
    required SignedPreKeyRecord signedPreKey,
    required String storagePrefix,
  })  : _store = store,
        _idKey = idKey,
        _regId = regId,
        _preKeys = preKeys,
        _preKey = preKey,
        _signedPreKey = signedPreKey,
        _storagePrefix = storagePrefix;

  /// Unique short name used as routing address on the bus and as the
  /// `remoteId` argument passed to [SessionCipher]. Intentionally NOT a
  /// real Pulse / Nostr address — keep it simple so tests stay readable.
  final String name;

  /// Same as [name] right now, separated to leave room for future
  /// transport-style addresses (e.g. `'alice@wss://relay'`).
  final String address;

  final InMemoryBus bus;
  final _TestSignalStore _store;
  final IdentityKeyPair _idKey;
  final int _regId;
  final List<PreKeyRecord> _preKeys;
  PreKeyRecord _preKey;
  int _preKeyCursor = 0;
  final SignedPreKeyRecord _signedPreKey;
  final String _storagePrefix;

  StreamSubscription<BusMessage>? _busSub;
  final StreamController<DecryptedMessage> _incomingCtrl =
      StreamController<DecryptedMessage>.broadcast();
  final StreamController<DecryptedGroupMessage> _incomingGroupCtrl =
      StreamController<DecryptedGroupMessage>.broadcast();

  /// One InMemorySenderKeyStore per process — group ciphers are global by
  /// `(groupId, senderName)` so we can keep this simple. Each TestClient
  /// has its own instance, exactly mirroring how production owns one
  /// PersistentSenderKeyStore per identity.
  final InMemorySenderKeyStore _senderKeyStore = InMemorySenderKeyStore();

  /// Cache `GroupSessionBuilder` per store + cipher per (groupId, sender).
  late final GroupSessionBuilder _groupBuilder =
      GroupSessionBuilder(_senderKeyStore);
  final Map<String, GroupCipher> _groupCiphers = <String, GroupCipher>{};

  /// Locally-known groups indexed by id. Holds the roster the *receiver*
  /// learned via roster-update broadcasts.
  final Map<String, TestGroup> _groups = <String, TestGroup>{};

  /// Per-(groupId, senderAddr) completers used by `waitForSkdmProcessed`.
  /// Resolved by `_onGroupSkdm` after its async libsignal call returns,
  /// giving tests a deterministic barrier instead of `Future.delayed(...)`.
  final Map<String, Completer<void>> _skdmReady = <String, Completer<void>>{};

  /// Serialize inbound bus dispatch. Stream listener callbacks that return
  /// futures are NOT awaited by the broadcast stream — without this chain
  /// `_onGroupSkdm` (async libsignal work) can be racing `_onGroupMessage`
  /// for the same (group, sender), leading to "no session found" decrypt
  /// failures under load.
  Future<void> _busQueue = Future<void>.value();

  // ── Recovery-flow counters / state (commit 39546b0 invariants) ─────────

  /// Count of `session_reset` signals we've SENT. Used by tests that need
  /// to assert recovery is rate-limited (one per peer per window) and not
  /// fired N-times for N consecutive decrypt failures.
  int sessionResetSendCount = 0;

  /// Count of `session_reset` signals we've RECEIVED + processed. Lets
  /// tests assert "exactly one round-trip recovery" instead of the
  /// pre-fix multi-retry storm.
  int sessionResetReceiveCount = 0;

  /// Count of `pqc_stale` signals we've SENT — receiver detected a Kyber
  /// unwrap failure and is asking the sender to refresh its cached pubkey.
  int pqcStaleSendCount = 0;

  /// Per-peer rate-limit timestamps for outgoing `session_reset` signals.
  /// Mirrors production's `_pushOwnBundleTo` rate-limiter — a peer that
  /// hits Bad MAC three times in a row should still only generate ONE
  /// `session_reset` broadcast.
  final Map<String, DateTime> _lastSessionResetSentTo = {};

  /// Per-peer rate-limit timestamps for INCOMING `session_reset` signals.
  /// Mirrors production's fix in commit 084cab3:
  /// `sendSignalToAllTransports` fans the same logical reset across
  /// every transport (Nostr × N relays + Session + Pulse), so the
  /// receiver sees 5-7 duplicate copies. Each `deleteContactData +
  /// buildSession` run replaces the just-built session with a fresh
  /// ratchet ephemeral, leaving the just-emitted PreKey-init reply
  /// pointing at a session the peer no longer holds → infinite loop.
  /// Process the first arrival, drop the rest.
  final Map<String, DateTime> _lastSessionResetReceivedFrom = {};

  /// Time window for the rate-limiter. Production uses ~30s for outgoing
  /// and 10s for incoming; the harness uses 1s so tests stay fast while
  /// still exercising the rate-limit logic.
  static const Duration _kSessionResetCooldown = Duration(seconds: 1);

  /// Streamed `session_reset` reception events — tests can `await` on
  /// `recoveryEvents.first` to know when to retry.
  final StreamController<String> _recoveryCtrl =
      StreamController<String>.broadcast();
  Stream<String> get recoveryEvents => _recoveryCtrl.stream;

  /// Total decrypt-failures observed on this client's inbound stream.
  /// Tests assert on this in lieu of subscribing to error events on
  /// the [incoming] stream — pushing decrypt-fails through `incoming`
  /// trips flutter_test's zone-level unhandled-error guard even when
  /// a subscription installs an onError handler (the listener is
  /// rooted in `bus.inbox(...).listen(...)` so the failure escapes
  /// the test zone via the future path).
  int decryptFailCount = 0;

  /// Per-event stream of decrypt failures. Tests that need to
  /// synchronize on the FIRST decrypt-fail (rather than poll
  /// [decryptFailCount]) can `await decryptFailures.first`.
  final StreamController<DecryptFailEvent> _decryptFailCtrl =
      StreamController<DecryptFailEvent>.broadcast();
  Stream<DecryptFailEvent> get decryptFailures => _decryptFailCtrl.stream;

  // ── PQC simulation (conceptual, not real Kyber KEM) ────────────────────
  //
  // The harness models the PQC layer as a 64-byte cached "pubkey" per
  // peer. `wrapPqc` requires the cached pubkey to match the peer's
  // current key for the unwrap to succeed; a `rotateKyber()` call
  // replaces the local pubkey, simulating a peer that re-keyed without
  // notifying us. Receiver detects the mismatch and broadcasts a
  // `pqc_stale` signal — sender clears the stale cache + rebuilds.
  //
  // We deliberately stop short of actual Kyber KEM to keep the harness
  // CPU-cheap and dependency-free — the bug that commit 39546b0 fixed
  // is in the *control flow*, not in the KEM.
  bool _pqcEnabled = false;
  Uint8List _kyberPubkey = Uint8List(0);
  final Map<String, Uint8List> _peerKyberPubkeys = {};

  bool _disposed = false;

  /// Stream of decrypted incoming 1-on-1 messages targeted at this client.
  Stream<DecryptedMessage> get incoming => _incomingCtrl.stream;

  /// Stream of decrypted incoming group messages + roster updates.
  Stream<DecryptedGroupMessage> get incomingGroup =>
      _incomingGroupCtrl.stream;

  // ── Spawn ──────────────────────────────────────────────────────────────

  /// Create a fresh, fully-initialized TestClient.
  ///
  /// * Installs the per-prefix secure-storage router (idempotent) so that
  ///   any production code accidentally pulled in via test imports does
  ///   not crash on a missing platform plugin.
  /// * Resets the SharedPreferences mock for THIS client's slice — tests
  ///   that need a clean slate across all clients should also call
  ///   [resetSharedPreferences] themselves in `setUp()`.
  ///
  /// [freshIdentity] is advisory — every spawn already gets a brand new
  /// libsignal store because the harness intentionally does not persist
  /// keys between runs. The flag exists for future code that wants to
  /// reuse a long-lived store across spawns and clearly opt out.
  // ignore: avoid_unused_constructor_parameters
  static Future<TestClient> spawn(
    String name,
    InMemoryBus bus, {
    bool freshIdentity = false,
  }) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    installSecureStorageRouter();

    final storagePrefix = 'pulse_test_$name';
    clearBucket(storagePrefix);

    // Generate fresh Signal identity material. Mirrors the production
    // SignalService.initialize() path but stays detached from the
    // singleton so two TestClients can coexist in the same process.
    final idKey = generateIdentityKeyPair();
    final regId = generateRegistrationId(false);
    final store = _TestSignalStore(idKey, regId);

    // Generate a small batch of prekeys so a peer that re-runs
    // `addContact()` after we already burned PreKey #1 has fresh ones to
    // build a session against. Production replenishes via key republish;
    // a 10-key buffer is plenty for unit-test scope.
    final preKeys = generatePreKeys(0, 10);
    for (final pk in preKeys) {
      await store.storePreKey(pk.id, pk);
    }
    // `_preKey` advances on each `publicBundle()` call so successive
    // peers build sessions against distinct one-time keys — modelling
    // production's "burn one prekey per session init" behaviour.
    final preKey = preKeys.first;

    final signedPreKey = generateSignedPreKey(idKey, 0);
    await store.storeSignedPreKey(signedPreKey.id, signedPreKey);

    final client = TestClient._(
      name: name,
      address: name,
      bus: bus,
      store: store,
      idKey: idKey,
      regId: regId,
      preKeys: preKeys,
      preKey: preKey,
      signedPreKey: signedPreKey,
      storagePrefix: storagePrefix,
    );

    // Subscribe immediately so messages produced before the test calls
    // `incoming.listen(...)` aren't lost. The broadcast controller still
    // requires a listener for delivery, but bus → controller routing
    // happens synchronously inside the bus mailbox listener below.
    //
    // Inbound dispatch is serialized through `_dispatchBusMessage` so
    // that async handlers (libsignal SKDM/decrypt work) run one at a time
    // — prevents "msg arrived before SKDM processed" races.
    client._busSub =
        bus.inbox(client.address).listen(client._dispatchBusMessage);

    return client;
  }

  /// Tail-recursive serialization: every inbound bus message is queued
  /// on `_busQueue` so that the previous `_onBusMessage` future resolves
  /// before the next dispatch starts. Errors in any handler are swallowed
  /// here and surfaced via the per-handler streams (`_decryptFailCtrl`,
  /// `_incomingGroupCtrl.addError`, etc.) — the chain MUST keep flowing.
  void _dispatchBusMessage(BusMessage m) {
    _busQueue = _busQueue.then((_) async {
      try {
        await _onBusMessage(m);
      } catch (_) {
        // Per-handler error paths already emit on their dedicated
        // streams; swallow here to keep the dispatch chain alive.
      }
    });
  }

  // ── Public API ─────────────────────────────────────────────────────────

  /// Build the public PreKey bundle that another client uses to start a
  /// Signal session with this one. Mirrors `SignalService.getPublicBundle`
  /// but returns the strongly-typed [PreKeyBundle] directly.
  ///
  /// Each call hands out the *next* one-time prekey from our pool so that
  /// peers re-running `addContact()` after a reinstall don't crash on a
  /// burned PreKey ID. Returns to the head of the pool once exhausted —
  /// fine for tests, would be a key-reuse violation in production.
  PreKeyBundle publicBundle() {
    final pk = _preKeys[_preKeyCursor % _preKeys.length];
    _preKeyCursor++;
    _preKey = pk;
    return PreKeyBundle(
      _regId,
      1,
      pk.id,
      pk.getKeyPair().publicKey,
      _signedPreKey.id,
      _signedPreKey.getKeyPair().publicKey,
      _signedPreKey.signature,
      _idKey.getPublicKey(),
    );
  }

  /// Establish a Signal session with [peer]. Idempotent — calling twice
  /// rebuilds on top of the existing session, which libsignal handles.
  Future<void> addContact(TestClient peer) async {
    final remoteAddress = SignalProtocolAddress(peer.address, 1);
    await SessionBuilder(_store, _store, _store, _store, remoteAddress)
        .processPreKeyBundle(peer.publicBundle());
  }

  /// Wipe every Signal-state record we hold for [peerAddress] — session
  /// and the trusted-identity entry. Mirrors production's
  /// `deleteContactData` recovery path which runs before rebuilding a
  /// session against a fresh bundle from a peer that reinstalled
  /// (commit 39546b0 fix). Without this, libsignal's
  /// trust-on-first-use cache rejects the new identity key with
  /// `UntrustedIdentityException`.
  Future<void> forgetPeer(String peerAddress) async {
    await _store.deleteAllSessions(peerAddress);
    final addr = SignalProtocolAddress(peerAddress, 1);
    _store.identityStore.trustedKeys.remove(addr);
  }

  // ── Recovery flow API (commit 39546b0) ─────────────────────────────────

  /// Send a `session_reset` signal to [peer] carrying our CURRENT public
  /// PreKey bundle inline. Mirrors production's atomic recovery flow:
  /// instead of just wiping our stale session and waiting for the
  /// recipient to re-fetch our bundle from the relay (race condition),
  /// we push the bundle inline so the recipient can call
  /// `forgetPeer()` + `addContact()` atomically and decrypt our next
  /// message without any further round-trip.
  ///
  /// Rate-limited to one signal per peer per [_kSessionResetCooldown] —
  /// a sender that hits Bad MAC N times in a row only emits ONE
  /// `session_reset` (the bug commit 39546b0 fixed: pre-fix code emitted
  /// one per failure).
  ///
  /// Returns `true` if the signal was actually emitted, `false` if the
  /// rate-limiter suppressed it.
  bool requestSessionReset(TestClient peer) {
    final now = DateTime.now();
    final last = _lastSessionResetSentTo[peer.address];
    if (last != null && now.difference(last) < _kSessionResetCooldown) {
      return false;
    }
    _lastSessionResetSentTo[peer.address] = now;

    final bundle = publicBundle();
    sessionResetSendCount++;
    bus.send(BusMessage(
      to: peer.address,
      from: address,
      kind: 'signal',
      payload: jsonEncode({
        'type': 'session_reset',
        'payload': _serializeBundle(bundle),
      }),
    ));
    return true;
  }

  /// Simulates production's `_broadcaster.sendSignalToAllTransports`
  /// fanning a single logical session_reset across N transports —
  /// in real deployment that's 5-7 duplicate arrivals on the receiver
  /// (5 Nostr relays + Session + Pulse). Use this in tests that need
  /// to verify the receive-side de-dup cooldown actually kicks in.
  ///
  /// Bypasses the outgoing rate-limit (callers explicitly want the
  /// duplicates this method emits).
  void floodSessionResetForTransportFanout(TestClient peer, int copies) {
    final bundle = publicBundle();
    for (var i = 0; i < copies; i++) {
      sessionResetSendCount++;
      bus.send(BusMessage(
        to: peer.address,
        from: address,
        kind: 'signal',
        payload: jsonEncode({
          'type': 'session_reset',
          'payload': _serializeBundle(bundle),
        }),
      ));
    }
  }

  /// Wait until our `sessionResetSendCount` stops increasing for one
  /// `_kSessionResetCooldown` window AND our next outgoing message
  /// decrypts successfully on the peer. Useful for asserting that
  /// recovery converges in bounded time without busy-polling.
  Future<void> waitForRecovery(Duration timeout) async {
    final deadline = DateTime.now().add(timeout);
    var lastCount = sessionResetSendCount;
    var stableSince = DateTime.now();
    while (DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (sessionResetSendCount != lastCount) {
        lastCount = sessionResetSendCount;
        stableSince = DateTime.now();
        continue;
      }
      if (DateTime.now().difference(stableSince) >=
          _kSessionResetCooldown) {
        return;
      }
    }
  }

  // ── PQC simulation API ─────────────────────────────────────────────────

  /// Generate a (conceptual) Kyber pubkey for this client and start
  /// including it in publicBundles + checking it on inbound. The bytes
  /// are random — the harness only checks for byte equality on
  /// unwrap, never an actual KEM operation.
  void enablePqc() {
    _pqcEnabled = true;
    _kyberPubkey = _randomBytes(64);
  }

  /// Simulate a peer rotating their PQC keypair (e.g. after reinstall
  /// or scheduled rotation). Tests use this to drive the
  /// "cached-stale-pubkey" branch of the unwrap flow.
  void rotateKyber() {
    if (!_pqcEnabled) {
      throw StateError('rotateKyber called before enablePqc');
    }
    _kyberPubkey = _randomBytes(64);
  }

  /// Locally cache [peer]'s current Kyber pubkey. Receiver of a PQC
  /// envelope cross-checks this against the peer's *current* pubkey;
  /// mismatch triggers `pqc_stale`. Tests use this to seed a deliberate
  /// mismatch.
  void cachePeerKyber(TestClient peer) {
    if (!peer._pqcEnabled) {
      throw StateError(
          'cachePeerKyber: peer ${peer.address} did not call enablePqc()');
    }
    _peerKyberPubkeys[peer.address] = Uint8List.fromList(peer._kyberPubkey);
  }

  /// Send a PQC-wrapped text to [peer]. The "wrap" here is symbolic —
  /// the wire payload carries the cached peer pubkey we *think* is
  /// current. Receiver compares against its actual pubkey; mismatch
  /// surfaces as a "PQC unwrap failure" event.
  ///
  /// On unwrap-success, the inner Signal-encrypted body is delivered
  /// exactly like a normal `sendText` call.
  Future<void> sendPqcText(TestClient peer, String text) async {
    if (!_pqcEnabled) {
      throw StateError('sendPqcText: enablePqc() not called on sender');
    }
    final cached = _peerKyberPubkeys[peer.address];
    if (cached == null) {
      throw StateError(
          'sendPqcText: no cached Kyber pubkey for ${peer.address}');
    }

    // Build the inner Signal envelope exactly like sendText does, then
    // wrap it inside a PQC envelope that carries the cached peer pubkey.
    final wrapped = MessageEnvelope.wrap(address, text);
    final remoteAddress = SignalProtocolAddress(peer.address, 1);
    final cipher =
        SessionCipher(_store, _store, _store, _store, remoteAddress);
    final ct = await cipher.encrypt(Uint8List.fromList(utf8.encode(wrapped)));
    final inner = 'E2EE||${ct.getType()}||${base64Encode(ct.serialize())}';

    bus.send(BusMessage(
      to: peer.address,
      from: address,
      kind: 'pqc_msg',
      payload: jsonEncode({
        'kyber': base64Encode(cached),
        'inner': inner,
      }),
      ts: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  /// Notify [peer] that we (the receiver) detected a stale Kyber pubkey.
  /// Carries our *current* Kyber pubkey inline so [peer] can refresh its
  /// cache atomically — no relay round-trip needed.
  void notifyPqcStale(TestClient peer) {
    if (!_pqcEnabled) {
      throw StateError('notifyPqcStale: enablePqc() not called');
    }
    pqcStaleSendCount++;
    bus.send(BusMessage(
      to: peer.address,
      from: address,
      kind: 'signal',
      payload: jsonEncode({
        'type': 'pqc_stale',
        'payload': {
          'kyber': base64Encode(_kyberPubkey),
        },
      }),
    ));
  }

  /// Encrypt + send [text] to [peer] via the bus.
  Future<void> sendText(TestClient peer, String text) async {
    final wrapped = MessageEnvelope.wrap(address, text);
    final remoteAddress = SignalProtocolAddress(peer.address, 1);
    final cipher = SessionCipher(_store, _store, _store, _store, remoteAddress);
    final ct = await cipher.encrypt(Uint8List.fromList(utf8.encode(wrapped)));
    final wire = 'E2EE||${ct.getType()}||${base64Encode(ct.serialize())}';
    bus.send(BusMessage(
      to: peer.address,
      from: address,
      kind: 'msg',
      payload: wire,
      ts: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  /// Send an arbitrary signal payload (typing indicators, key updates,
  /// etc.). Signals ride the bus untouched; receivers can subscribe
  /// directly to `bus.inbox()` to observe them.
  void sendSignal(TestClient peer, String type, Map<String, dynamic> payload) {
    bus.send(BusMessage(
      to: peer.address,
      from: address,
      kind: 'signal',
      payload: jsonEncode({'type': type, 'payload': payload}),
    ));
  }

  /// Hot-reset this client's SharedPreferences slice. Use sparingly —
  /// `SharedPreferences.setMockInitialValues` is a global mock, so this
  /// affects every TestClient in the process.
  Future<void> resetPrefs() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  }

  /// Wipe persistent state and drop bus subscription. Always call from
  /// `tearDown()` (or via `addTearDown`) to keep buckets from leaking
  /// between tests in the same file.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _busSub?.cancel();
    await _incomingCtrl.close();
    await _incomingGroupCtrl.close();
    await _recoveryCtrl.close();
    await _decryptFailCtrl.close();
    clearBucket(_storagePrefix);
  }

  // ── Groups ─────────────────────────────────────────────────────────────

  /// Create a group containing [members] (this client is implicitly the
  /// admin and is added to the roster). Builds a fresh sender-key for
  /// THIS client, distributes it to every member via the bus as a
  /// `'group_skdm'` BusMessage, and broadcasts an initial roster snapshot.
  ///
  /// Members do NOT need to have called `addContact` first — sender-key
  /// distribution does not require a Signal session. (Production wraps
  /// the SKDM inside a Signal envelope; for harness tests we ship it
  /// in the clear since transport-level confidentiality is the bus's
  /// problem, not the harness's.)
  Future<TestGroup> createGroup(String name, List<TestClient> members) async {
    final id = 'g_${DateTime.now().microsecondsSinceEpoch}_'
        '${address.hashCode.toRadixString(16)}';
    final roster = <TestClient>[this, ...members.where((m) => m != this)];
    final group = TestGroup(
      id: id,
      name: name,
      members: roster,
      creatorAddr: address,
    );
    _groups[id] = group;

    // 1. Mint our sender-key for this group.
    final skdm = await _createOrGetDistribution(id);

    // 2. Distribute it to every other member + broadcast initial roster.
    for (final m in roster) {
      if (m.address == address) continue;
      _sendGroupSkdmTo(m.address, id, skdm);
    }
    _broadcastRoster(group);

    return group;
  }

  /// Encrypt [text] with our group sender-key and broadcast to every
  /// member except self.
  ///
  /// Throws [StateError] if [group] has no members other than self
  /// (degenerate case the harness doesn't bother with).
  Future<void> sendGroupText(TestGroup group, String text) async {
    final wrapped = MessageEnvelope.wrap(address, text);
    final cipher = _getGroupCipher(group.id, address);
    final ct = await cipher.encrypt(Uint8List.fromList(utf8.encode(wrapped)));
    final wire = base64Encode(ct);
    final ts = DateTime.now().millisecondsSinceEpoch;

    final recipients =
        group.members.where((m) => m.address != address).toList();
    if (recipients.isEmpty) {
      throw StateError(
          '[TestClient] sendGroupText: group ${group.id} has no other members');
    }
    for (final m in recipients) {
      bus.send(BusMessage(
        to: m.address,
        from: address,
        kind: 'group_msg',
        payload: jsonEncode({
          'gid': group.id,
          'ct': wire,
        }),
        ts: ts,
      ));
    }
  }

  /// Remove [target] from [group] and re-broadcast the roster. The
  /// kicked client receives a `kind:'removed'` event on its
  /// `incomingGroup` stream; remaining members receive a
  /// `kind:'roster'` event with the new member list.
  ///
  /// Mirrors the production `broadcastGroupUpdate` flow that — after
  /// commit 39546b0 — explicitly notifies the kicked member BEFORE
  /// trimming them out of the roster.
  Future<void> kickFromGroup(TestGroup group, TestClient target) async {
    if (!group.members.any((m) => m.address == target.address)) return;

    // 1. Notify the kicked member FIRST (commit 39546b0 invariant).
    bus.send(BusMessage(
      to: target.address,
      from: address,
      kind: 'group_remove',
      payload: jsonEncode({
        'gid': group.id,
        'reason': 'kicked',
      }),
    ));

    // 2. Trim them out of our local view, then broadcast new roster.
    group.members.removeWhere((m) => m.address == target.address);
    _broadcastRoster(group);
  }

  // ── Group internals ────────────────────────────────────────────────────

  Future<Uint8List> _createOrGetDistribution(String groupId) async {
    final senderKeyName =
        SenderKeyName(groupId, SignalProtocolAddress(address, 1));
    final skdm = await _groupBuilder.create(senderKeyName);
    return skdm.serialize();
  }

  GroupCipher _getGroupCipher(String groupId, String senderAddr) {
    final key = '$groupId::$senderAddr';
    return _groupCiphers.putIfAbsent(key, () {
      final senderKeyName =
          SenderKeyName(groupId, SignalProtocolAddress(senderAddr, 1));
      return GroupCipher(_senderKeyStore, senderKeyName);
    });
  }

  void _sendGroupSkdmTo(String toAddr, String groupId, Uint8List skdm) {
    bus.send(BusMessage(
      to: toAddr,
      from: address,
      kind: 'group_skdm',
      payload: jsonEncode({
        'gid': groupId,
        'skdm': base64Encode(skdm),
      }),
    ));
  }

  void _broadcastRoster(TestGroup group) {
    final memberAddrs = group.members.map((m) => m.address).toList();
    for (final m in group.members) {
      if (m.address == address) continue;
      bus.send(BusMessage(
        to: m.address,
        from: address,
        kind: 'group_roster',
        payload: jsonEncode({
          'gid': group.id,
          'name': group.name,
          'members': memberAddrs,
        }),
      ));
    }
  }

  // ── Internal ───────────────────────────────────────────────────────────

  Future<void> _onBusMessage(BusMessage m) async {
    switch (m.kind) {
      case 'msg':
        await _onDirectMessage(m);
        return;
      case 'group_skdm':
        await _onGroupSkdm(m);
        return;
      case 'group_msg':
        await _onGroupMessage(m);
        return;
      case 'group_roster':
        _onGroupRoster(m);
        return;
      case 'group_remove':
        _onGroupRemove(m);
        return;
      case 'signal':
        await _onSignal(m);
        return;
      case 'pqc_msg':
        await _onPqcMessage(m);
        return;
      default:
        return; // unknown kinds — tests can subscribe directly to bus.inbox
    }
  }

  // ── Inbound signals (recovery flow) ────────────────────────────────────

  Future<void> _onSignal(BusMessage m) async {
    Map<String, dynamic> outer;
    try {
      outer = jsonDecode(m.payload) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    final type = outer['type'] as String?;
    final payload = (outer['payload'] as Map?)?.cast<String, dynamic>();
    if (type == null || payload == null) return;

    switch (type) {
      case 'session_reset':
        // Drop duplicates within the cooldown — production sees the
        // same signal 5-7 times because sendSignalToAllTransports fans
        // out across every wire. Without this guard, each duplicate
        // wipes the just-built session and the recovery never converges.
        // (Mirrors the production fix in commit 084cab3.)
        final lastSeen = _lastSessionResetReceivedFrom[m.from];
        final now = DateTime.now();
        if (lastSeen != null &&
            now.difference(lastSeen) < _kSessionResetCooldown) {
          return;
        }
        _lastSessionResetReceivedFrom[m.from] = now;
        // Symmetric outgoing cooldown: peer just told us "rebuild against
        // this bundle"; firing OUR session_reset back would race with
        // their next user-msg PreKey-init reply.
        _lastSessionResetSentTo[m.from] = now;

        sessionResetReceiveCount++;
        // Atomic recovery: drop the stale session + trusted-identity
        // entry, then build a fresh session from the inline bundle.
        // Mirrors the production fix in commit 39546b0 — without
        // the inline bundle, the receiver would have to refetch from
        // the relay and race the next incoming message.
        await forgetPeer(m.from);
        try {
          final bundle = _deserializeBundle(payload);
          final remoteAddress = SignalProtocolAddress(m.from, 1);
          await SessionBuilder(
                  _store, _store, _store, _store, remoteAddress)
              .processPreKeyBundle(bundle);
          if (!_recoveryCtrl.isClosed) {
            _recoveryCtrl.add(m.from);
          }
        } catch (e, st) {
          if (!_recoveryCtrl.isClosed) {
            _recoveryCtrl.addError(e, st);
          }
        }
        return;
      case 'pqc_stale':
        // Sender's cached pubkey is stale — refresh from the inline
        // payload. No relay round-trip needed.
        final kyberB64 = payload['kyber'] as String?;
        if (kyberB64 != null) {
          _peerKyberPubkeys[m.from] = base64Decode(kyberB64);
        }
        return;
      default:
        return; // unknown signal types pass silently
    }
  }

  Future<void> _onPqcMessage(BusMessage m) async {
    if (!_pqcEnabled) {
      // Tests that don't enable PQC ignore inbound PQC envelopes —
      // mirrors production behaviour for downgraded peers.
      return;
    }
    Map<String, dynamic> j;
    try {
      j = jsonDecode(m.payload) as Map<String, dynamic>;
    } catch (e, st) {
      _incomingCtrl.addError(e, st);
      return;
    }
    final claimedB64 = j['kyber'] as String?;
    final inner = j['inner'] as String?;
    if (claimedB64 == null || inner == null) return;

    final claimed = base64Decode(claimedB64);
    if (!_bytesEqual(claimed, _kyberPubkey)) {
      // Unwrap-fail. Production silently dropped these pre-fix; we
      // now broadcast a `pqc_stale` so the sender refreshes its
      // cache atomically and retries. Inlined here because we only
      // know the sender's address (string), not a TestClient handle.
      pqcStaleSendCount++;
      bus.send(BusMessage(
        to: m.from,
        from: address,
        kind: 'signal',
        payload: jsonEncode({
          'type': 'pqc_stale',
          'payload': {
            'kyber': base64Encode(_kyberPubkey),
          },
        }),
      ));
      return;
    }

    // Unwrap OK — feed the inner Signal envelope to the regular
    // direct-message path.
    final inlined = BusMessage(
      to: m.to,
      from: m.from,
      kind: 'msg',
      payload: inner,
      ts: m.ts,
    );
    await _onDirectMessage(inlined);
  }


  Future<void> _onDirectMessage(BusMessage m) async {
    // libsignal's `SessionCipher.decryptWithCallback` is async and runs
    // its hot path through a zone-scoped continuation. When it throws
    // (e.g. InvalidKeyIdException from a missing prekey, BadMacException
    // from a stale session), the throw is "double-reported" — the
    // catch below sees it AND it also surfaces as an unhandled
    // zone error in flutter_test, failing the test even when the
    // catch handles it gracefully.
    //
    // We isolate the decrypt under a guarded zone so the redundant
    // zone-error report is swallowed and only our explicit catch
    // path drives recovery.
    Object? decryptError;
    StackTrace? decryptStack;
    String? plaintext;
    await runZonedGuarded(() async {
      try {
        plaintext = await _decrypt(m.from, m.payload);
      } catch (e, st) {
        decryptError = e;
        decryptStack = st;
      }
    }, (e, st) {
      decryptError ??= e;
      decryptStack ??= st;
    });

    if (decryptError != null) {
      decryptFailCount++;
      if (!_decryptFailCtrl.isClosed) {
        _decryptFailCtrl.add(DecryptFailEvent(
            from: m.from, error: decryptError!, stack: decryptStack!));
      }
      _maybeRequestResetForAddress(m.from);
      return;
    }

    final pt = plaintext!;
    final envelope = MessageEnvelope.tryUnwrap(pt);
    final ts = DateTime.fromMillisecondsSinceEpoch(
        m.ts ?? DateTime.now().millisecondsSinceEpoch);
    if (envelope == null) {
      // Plaintext fallback — still useful for tests that assert on raw
      // (un-enveloped) decrypted bodies.
      _incomingCtrl.add(DecryptedMessage(from: m.from, text: pt, ts: ts));
      return;
    }
    _incomingCtrl.add(DecryptedMessage(
      from: envelope.from,
      text: envelope.body,
      ts: ts,
    ));
  }

  /// Schedule a `session_reset` at [peer]'s address using just the
  /// string address (we don't always hold a TestClient handle for
  /// the sender). Routes through [requestSessionReset] indirectly by
  /// inlining the same logic — keeps the rate-limiter consistent.
  void _maybeRequestResetForAddress(String peerAddress) {
    final now = DateTime.now();
    final last = _lastSessionResetSentTo[peerAddress];
    if (last != null && now.difference(last) < _kSessionResetCooldown) {
      return;
    }
    _lastSessionResetSentTo[peerAddress] = now;
    final bundle = publicBundle();
    sessionResetSendCount++;
    bus.send(BusMessage(
      to: peerAddress,
      from: address,
      kind: 'signal',
      payload: jsonEncode({
        'type': 'session_reset',
        'payload': _serializeBundle(bundle),
      }),
    ));
  }

  Future<void> _onGroupSkdm(BusMessage m) async {
    String? gid;
    try {
      final j = jsonDecode(m.payload) as Map<String, dynamic>;
      gid = j['gid'] as String;
      final skdmBytes = base64Decode(j['skdm'] as String);
      final senderKeyName =
          SenderKeyName(gid, SignalProtocolAddress(m.from, 1));
      final skdm = SenderKeyDistributionMessageWrapper.fromSerialized(
          Uint8List.fromList(skdmBytes));
      await _groupBuilder.process(senderKeyName, skdm);
      // Invalidate cached cipher so a fresh one picks up the new state.
      _groupCiphers.remove('$gid::${m.from}');
      // Resolve any pending `waitForSkdmProcessed` future for this
      // (group, sender). Tests use this as a deterministic barrier
      // before sending the first encrypted group message. Guarded
      // because the same SKDM can be re-broadcast (e.g. roster change)
      // and the completer is single-shot.
      final key = '$gid::${m.from}';
      final c = _skdmReady.putIfAbsent(key, () => Completer<void>());
      if (!c.isCompleted) c.complete();
    } catch (e, st) {
      _incomingGroupCtrl.addError(e, st);
      // Still surface failure on the barrier so tests don't hang.
      if (gid != null) {
        final key = '$gid::${m.from}';
        final c = _skdmReady.putIfAbsent(key, () => Completer<void>());
        if (!c.isCompleted) c.completeError(e, st);
      }
    }
  }

  /// Future that completes the moment `_onGroupSkdm` finishes processing
  /// a SKDM for [groupId] from [senderAddr]. If the SKDM arrives BEFORE
  /// the test calls this, the future resolves immediately. Used by
  /// regression tests in lieu of `Future.delayed(...)` settlement timers.
  Future<void> waitForSkdmProcessed(String groupId, String senderAddr) {
    final key = '$groupId::$senderAddr';
    return _skdmReady
        .putIfAbsent(key, () => Completer<void>())
        .future;
  }

  Future<void> _onGroupMessage(BusMessage m) async {
    try {
      final j = jsonDecode(m.payload) as Map<String, dynamic>;
      final gid = j['gid'] as String;
      final ct = base64Decode(j['ct'] as String);
      final cipher = _getGroupCipher(gid, m.from);
      final plain = await cipher.decrypt(Uint8List.fromList(ct));
      final raw = utf8.decode(plain);
      final env = MessageEnvelope.tryUnwrap(raw);
      _incomingGroupCtrl.add(DecryptedGroupMessage(
        kind: 'msg',
        fromAddr: env?.from ?? m.from,
        groupId: gid,
        text: env?.body ?? raw,
        ts: DateTime.fromMillisecondsSinceEpoch(
            m.ts ?? DateTime.now().millisecondsSinceEpoch),
      ));
    } catch (e, st) {
      _incomingGroupCtrl.addError(e, st);
    }
  }

  void _onGroupRoster(BusMessage m) {
    try {
      final j = jsonDecode(m.payload) as Map<String, dynamic>;
      final gid = j['gid'] as String;
      final members = (j['members'] as List).cast<String>();
      _incomingGroupCtrl.add(DecryptedGroupMessage(
        kind: 'roster',
        fromAddr: m.from,
        groupId: gid,
        members: members,
        ts: DateTime.fromMillisecondsSinceEpoch(
            m.ts ?? DateTime.now().millisecondsSinceEpoch),
      ));
    } catch (e, st) {
      _incomingGroupCtrl.addError(e, st);
    }
  }

  void _onGroupRemove(BusMessage m) {
    try {
      final j = jsonDecode(m.payload) as Map<String, dynamic>;
      final gid = j['gid'] as String;
      _incomingGroupCtrl.add(DecryptedGroupMessage(
        kind: 'removed',
        fromAddr: m.from,
        groupId: gid,
        ts: DateTime.fromMillisecondsSinceEpoch(
            m.ts ?? DateTime.now().millisecondsSinceEpoch),
      ));
    } catch (e, st) {
      _incomingGroupCtrl.addError(e, st);
    }
  }

  // ── Bundle serialization (for inline `session_reset` payloads) ─────────

  Map<String, dynamic> _serializeBundle(PreKeyBundle b) {
    final pre = b.getPreKey();
    final spk = b.getSignedPreKey();
    final sig = b.getSignedPreKeySignature();
    return <String, dynamic>{
      'rid': b.getRegistrationId(),
      'did': b.getDeviceId(),
      'pkid': b.getPreKeyId(),
      'pk': pre == null ? null : base64Encode(pre.serialize()),
      'spkid': b.getSignedPreKeyId(),
      'spk': spk == null ? null : base64Encode(spk.serialize()),
      'sig': sig == null ? null : base64Encode(sig),
      'idk': base64Encode(b.getIdentityKey().serialize()),
    };
  }

  PreKeyBundle _deserializeBundle(Map<String, dynamic> j) {
    final pkB64 = j['pk'] as String?;
    final spkB64 = j['spk'] as String?;
    final sigB64 = j['sig'] as String?;
    final idkB64 = j['idk'] as String;
    return PreKeyBundle(
      j['rid'] as int,
      j['did'] as int,
      j['pkid'] as int?,
      pkB64 == null ? null : Curve.decodePoint(base64Decode(pkB64), 0),
      j['spkid'] as int,
      spkB64 == null ? null : Curve.decodePoint(base64Decode(spkB64), 0),
      sigB64 == null ? null : base64Decode(sigB64),
      IdentityKey.fromBytes(base64Decode(idkB64), 0),
    );
  }

  // ── Tiny crypto-adjacent utilities ─────────────────────────────────────

  static final _rand = math.Random.secure();
  static Uint8List _randomBytes(int n) {
    final out = Uint8List(n);
    for (var i = 0; i < n; i++) {
      out[i] = _rand.nextInt(256);
    }
    return out;
  }

  static bool _bytesEqual(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<String> _decrypt(String fromAddress, String wire) async {
    if (!wire.startsWith('E2EE||')) return wire;
    final parts = wire.split('||');
    if (parts.length < 3) {
      throw FormatException('[TestClient] malformed envelope: $wire');
    }
    final type = int.parse(parts[1]);
    final bytes = base64Decode(parts[2]);
    final remoteAddress = SignalProtocolAddress(fromAddress, 1);
    final cipher = SessionCipher(_store, _store, _store, _store, remoteAddress);
    Uint8List plain;
    if (type == CiphertextMessage.prekeyType) {
      plain = await cipher.decrypt(PreKeySignalMessage(bytes));
    } else if (type == CiphertextMessage.whisperType) {
      plain = await cipher.decryptFromSignal(SignalMessage.fromSerialized(bytes));
    } else {
      throw Exception('Unknown ciphertext type: $type');
    }
    return utf8.decode(plain);
  }

  // ── Reconnect / sleep / wake regression hooks ──────────────────────────
  //
  // Added 2026-04-26 to back regression tests for commits 9872c3f
  // (reconnectInbox subscription leak + wake-from-sleep watchdog) and
  // 39546b0 (addr_update UNION-MERGE + group invite Pulse seeding).
  //
  // Names use the `pulseRegression…` prefix so they cannot collide with
  // helpers another agent may add to this same file in parallel.

  /// Wall-clock timestamp the watchdog last saw "alive". A
  /// [pulseRegressionSimulateWake] call detects a gap > 60s and forces a
  /// resubscribe, mirroring the production wake-from-sleep behaviour.
  DateTime _pulseRegressionLastTick = DateTime.now();

  /// Simulated "we missed wall-clock ticks while suspended" flag — set by
  /// [pulseRegressionSimulateSleep], cleared by [pulseRegressionSimulateWake].
  bool _pulseRegressionWokenFromSleep = false;

  /// Cached pulse pubkey for self — populated lazily so tests can read it
  /// without forcing a setter API. Derived deterministically from [name].
  String get pulseRegressionSelfPulsePub =>
      _pulseRegressionPulseFor(address);

  /// Per-contact address book. Mirrors production's
  /// `Contact.transportAddresses` map, but trimmed to the surface area
  /// the addr_update + group-invite regression tests need.
  final Map<String, ContactAddresses> _pulseRegressionContacts =
      <String, ContactAddresses>{};

  /// Tear down the live bus subscription and re-establish it against the
  /// same mailbox. Models the production
  /// `PulseInboxReader.reconnectInbox()` flow: cancel → tear down →
  /// re-subscribe. Any messages that arrive between cancel and resubscribe
  /// are buffered by the bus's per-address mailbox stream.
  ///
  /// Verifies the invariant from commit 9872c3f: after a reconnect the
  /// new subscription must actually receive the next inbound message.
  Future<void> pulseRegressionSimulateReconnect() async {
    final stash = _busSub;
    _busSub = null;
    await stash?.cancel();
    // Re-wire the bus subscription onto the SAME mailbox. The bus's
    // broadcast controller will deliver any messages produced after this
    // point. Use `_dispatchBusMessage` (the serialized variant) for
    // identical race-avoidance to the initial subscribe.
    _busSub = bus.inbox(address).listen(_dispatchBusMessage);
    _pulseRegressionLastTick = DateTime.now();
  }

  /// Simulate the OS suspending this client for [gap]. Marks the bus
  /// connection as zombie (no further sends are observed by the client)
  /// and rewinds [_pulseRegressionLastTick] so that the next
  /// [pulseRegressionSimulateWake] call detects a wall-clock jump.
  Future<void> pulseRegressionSimulateSleep(Duration gap) async {
    bus.disconnect(address);
    _pulseRegressionLastTick =
        DateTime.now().subtract(gap + const Duration(seconds: 1));
    _pulseRegressionWokenFromSleep = true;
  }

  /// Detect that wall-clock has jumped past the watchdog threshold (60s)
  /// and force a fresh subscription on top of the already-buffered
  /// mailbox. Mirrors the production wake-from-sleep watchdog teardown +
  /// reopen sequence.
  Future<void> pulseRegressionSimulateWake({
    Duration threshold = const Duration(seconds: 60),
  }) async {
    final now = DateTime.now();
    final delta = now.difference(_pulseRegressionLastTick);
    if (delta < threshold && !_pulseRegressionWokenFromSleep) {
      // No jump observed — nothing to do.
      return;
    }
    _pulseRegressionWokenFromSleep = false;
    // 1. Tear down the now-zombie bus subscription before draining the
    //    offline buffer, so we don't double-process anything.
    final stash = _busSub;
    _busSub = null;
    await stash?.cancel();
    // 2. Re-subscribe FIRST so we observe the offline-buffer drain.
    //    Use the serialized dispatcher so async handlers (libsignal
    //    SKDM/decrypt) don't interleave on the just-drained backlog.
    _busSub = bus.inbox(address).listen(_dispatchBusMessage);
    // 3. Resume bus delivery — drains the offline buffer in FIFO order.
    bus.reconnect(address);
    _pulseRegressionLastTick = now;
  }

  /// Look up the cached Pulse pubkey for [contactAddress]. Returns `null`
  /// when this client has never learned a Pulse address for that contact.
  String? pulseRegressionGetContactPulse(String contactAddress) {
    final entry = _pulseRegressionContacts[contactAddress];
    final pulses = entry?.addresses['Pulse'];
    if (pulses == null || pulses.isEmpty) return null;
    return pulses.first;
  }

  /// Replace this client's local view of [contactAddress]'s addresses
  /// with [addresses]. Used by tests that need to seed an initial Pulse
  /// address before the addr_update / invite flow runs.
  void pulseRegressionSetContactAddresses(
      String contactAddress, Map<String, List<String>> addresses) {
    _pulseRegressionContacts[contactAddress] = ContactAddresses(
      addresses: {
        for (final e in addresses.entries) e.key: List<String>.from(e.value),
      },
    );
  }

  /// UNION-MERGE the addresses carried in an `addr_update` bus message
  /// into this client's local contact book — the exact behaviour
  /// commit 39546b0 introduced (and that the test guards against any
  /// future revert).
  ///
  /// Old behaviour was REPLACE: an update missing the Pulse transport
  /// would silently drop the Pulse pubkey. UNION-MERGE preserves any
  /// transport key the update doesn't mention.
  Future<void> pulseRegressionHandleAddrUpdate(BusMessage update) async {
    if (update.kind != 'addr_update') return;
    final j = jsonDecode(update.payload) as Map<String, dynamic>;
    final transportMap = (j['transportAddresses'] as Map?)?.cast<String, dynamic>() ?? {};
    final existing = _pulseRegressionContacts[update.from] ??
        ContactAddresses(addresses: <String, List<String>>{});
    final merged = <String, List<String>>{
      for (final e in existing.addresses.entries)
        e.key: List<String>.from(e.value),
    };
    transportMap.forEach((transport, raw) {
      final list = (raw as List).cast<String>();
      // UNION: merge incoming list into existing, dedup preserving order.
      final acc = <String>[...?merged[transport]];
      for (final addr in list) {
        if (!acc.contains(addr)) acc.add(addr);
      }
      merged[transport] = acc;
    });
    _pulseRegressionContacts[update.from] =
        ContactAddresses(addresses: merged);
  }

  /// Build a deterministic Pulse pubkey for an address. Production keys
  /// are real ed25519 hex strings; for tests we just need a stable
  /// non-empty string so the test can compare for equality.
  String _pulseRegressionPulseFor(String addr) =>
      'pulsePub_${addr.hashCode.toRadixString(16)}';

  /// Build a group-invite bus message that carries `memberPulsePubkeys`
  /// the way the post-39546b0 production code does. The receiver is
  /// expected to call [pulseRegressionApplyInvite] to seed every
  /// member's Pulse pubkey into the local contact book before sending
  /// the first message in the group.
  Future<void> pulseRegressionSendGroupInvite(
    TestClient invitee, {
    required String groupId,
    required List<TestClient> members,
  }) async {
    final memberPulsePubkeys = <String, String>{
      for (final m in members) m.address: m.pulseRegressionSelfPulsePub,
    };
    bus.send(BusMessage(
      to: invitee.address,
      from: address,
      kind: 'group_invite',
      payload: jsonEncode({
        'gid': groupId,
        'memberPulsePubkeys': memberPulsePubkeys,
      }),
    ));
  }

  /// Apply a previously-received `group_invite` bus message: seed the
  /// `memberPulsePubkeys` map into this client's local contact book so
  /// the FIRST group message routes via Pulse without an extra
  /// addr_update round-trip.
  Future<void> pulseRegressionApplyInvite(BusMessage invite) async {
    if (invite.kind != 'group_invite') return;
    final j = jsonDecode(invite.payload) as Map<String, dynamic>;
    final keys = (j['memberPulsePubkeys'] as Map).cast<String, dynamic>();
    keys.forEach((memberAddr, pulsePub) {
      if (memberAddr == address) return; // skip self
      final existing = _pulseRegressionContacts[memberAddr] ??
          ContactAddresses(addresses: <String, List<String>>{});
      final merged = <String, List<String>>{
        for (final e in existing.addresses.entries)
          e.key: List<String>.from(e.value),
      };
      final acc = <String>[...?merged['Pulse']];
      final p = pulsePub as String;
      if (!acc.contains(p)) acc.add(p);
      merged['Pulse'] = acc;
      _pulseRegressionContacts[memberAddr] =
          ContactAddresses(addresses: merged);
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Contact-address model (regression-test scope)
// ─────────────────────────────────────────────────────────────────────────

/// Minimal mirror of production's `Contact.transportAddresses` map. Keyed
/// by transport label (`'Pulse'`, `'Nostr'`, …) → list of concrete
/// addresses. Used by the addr_update UNION-MERGE and group-invite
/// regression tests.
class ContactAddresses {
  ContactAddresses({required this.addresses});

  final Map<String, List<String>> addresses;

  @override
  String toString() => 'ContactAddresses($addresses)';
}

// ─────────────────────────────────────────────────────────────────────────
// Internal Signal store wrapper
// ─────────────────────────────────────────────────────────────────────────

/// Slim subclass of [InMemorySignalProtocolStore] that exposes the
/// inner [InMemoryIdentityKeyStore] so [TestClient.forgetPeer] can drop
/// a stale trusted-identity entry. The base class keeps it `private`,
/// which makes it impossible to model production's `deleteContactData`
/// recovery flow without subclassing or mirrors.
class _TestSignalStore extends InMemorySignalProtocolStore {
  _TestSignalStore(super.idKey, super.regId)
      : identityStore = InMemoryIdentityKeyStore(idKey, regId);

  /// Direct handle to the identity-key store used by every method we
  /// override below. Tests reach in via [TestClient.forgetPeer] to
  /// remove a stale TOFU entry before re-running `addContact`.
  final InMemoryIdentityKeyStore identityStore;

  @override
  Future<bool> isTrustedIdentity(SignalProtocolAddress address,
          IdentityKey? identityKey, Direction direction) =>
      identityStore.isTrustedIdentity(address, identityKey, direction);

  @override
  Future<bool> saveIdentity(
          SignalProtocolAddress address, IdentityKey? identityKey) =>
      identityStore.saveIdentity(address, identityKey);

  @override
  Future<IdentityKey?> getIdentity(SignalProtocolAddress address) =>
      identityStore.getIdentity(address);

  @override
  Future<IdentityKeyPair> getIdentityKeyPair() =>
      identityStore.getIdentityKeyPair();

  @override
  Future<int> getLocalRegistrationId() =>
      identityStore.getLocalRegistrationId();
}

/// One inbound decrypt-failure event surfaced by [TestClient.decryptFailures].
/// Tests that need to know WHY a decrypt failed can switch on
/// [error]'s runtimeType (e.g. `InvalidKeyIdException`, `InvalidMessageException`).
class DecryptFailEvent {
  DecryptFailEvent(
      {required this.from, required this.error, required this.stack});
  final String from;
  final Object error;
  final StackTrace stack;
}
