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
    client._busSub = bus.inbox(client.address).listen(client._onBusMessage);

    return client;
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
      default:
        return; // signals routed elsewhere
    }
  }

  Future<void> _onDirectMessage(BusMessage m) async {
    try {
      final plaintext = await _decrypt(m.from, m.payload);
      final envelope = MessageEnvelope.tryUnwrap(plaintext);
      if (envelope == null) {
        // Plaintext fallback — still useful for tests that assert on raw
        // (un-enveloped) decrypted bodies.
        _incomingCtrl.add(DecryptedMessage(
          from: m.from,
          text: plaintext,
          ts: DateTime.fromMillisecondsSinceEpoch(
              m.ts ?? DateTime.now().millisecondsSinceEpoch),
        ));
        return;
      }
      _incomingCtrl.add(DecryptedMessage(
        from: envelope.from,
        text: envelope.body,
        ts: DateTime.fromMillisecondsSinceEpoch(
            m.ts ?? DateTime.now().millisecondsSinceEpoch),
      ));
    } catch (e, st) {
      // Surface decrypt failures so tests that *expect* failure can
      // `.handleError(...)`. Without this they'd hang on `.first`.
      _incomingCtrl.addError(e, st);
    }
  }

  Future<void> _onGroupSkdm(BusMessage m) async {
    try {
      final j = jsonDecode(m.payload) as Map<String, dynamic>;
      final gid = j['gid'] as String;
      final skdmBytes = base64Decode(j['skdm'] as String);
      final senderKeyName =
          SenderKeyName(gid, SignalProtocolAddress(m.from, 1));
      final skdm = SenderKeyDistributionMessageWrapper.fromSerialized(
          Uint8List.fromList(skdmBytes));
      await _groupBuilder.process(senderKeyName, skdm);
      // Invalidate cached cipher so a fresh one picks up the new state.
      _groupCiphers.remove('$gid::${m.from}');
    } catch (e, st) {
      _incomingGroupCtrl.addError(e, st);
    }
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
