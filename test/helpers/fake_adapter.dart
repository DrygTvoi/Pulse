/// Duck-typed in-memory transport adapter for the integration test harness.
///
/// Implements just enough of the production adapter surface (`sendMessage`,
/// `sendSignal`, `listenForMessages`, `listenForSignals`) to be plugged into
/// `InboxManager.setAdapterForTesting()` if a future test needs the full
/// ChatController pipeline.
///
/// The current [TestClient] (see `test_harness.dart`) talks to the bus
/// directly and does not go through `InboxManager` at all. This adapter is
/// provided so that other tests can opt into fuller wiring without having
/// to invent another in-memory loopback.
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:pulse_messenger/adapters/inbox_manager.dart';
import 'package:pulse_messenger/models/message.dart';

import 'test_harness.dart';

/// In-memory adapter that publishes/subscribes to an [InMemoryBus].
///
/// A single instance plays both reader and sender roles for one address —
/// every TestClient gets its own [FakeAdapter] keyed by its address.
///
/// Conforms structurally to both [InboxReader] and [MessageSender] but is
/// declared `implements` against the duck-typed shape so production code
/// can keep its existing abstract base classes.
class FakeAdapter implements InboxReader, MessageSender {
  FakeAdapter({required this.ownerAddress, required this.bus});

  /// Canonical address this adapter belongs to ("alice", "bob", …).
  final String ownerAddress;

  /// Shared bus that carries [BusMessage]s between every TestClient.
  final InMemoryBus bus;

  StreamSubscription<BusMessage>? _sub;
  final _messageCtrl = StreamController<List<Message>>.broadcast();
  final _signalCtrl = StreamController<List<Map<String, dynamic>>>.broadcast();

  bool _initialized = false;

  // ── InboxReader surface ──────────────────────────────────────────────

  @override
  Future<void> initializeReader(String apiKey, String databaseId) async {
    if (_initialized) return;
    _initialized = true;
    _sub = bus.inbox(ownerAddress).listen((m) {
      switch (m.kind) {
        case 'msg':
          // Relay raw payload as a single Message to mimic production.
          _messageCtrl.add([
            Message(
              id: 'fake_${DateTime.now().microsecondsSinceEpoch}',
              senderId: m.from,
              receiverId: m.to,
              encryptedPayload: m.payload,
              timestamp: DateTime.fromMillisecondsSinceEpoch(
                  m.ts ?? DateTime.now().millisecondsSinceEpoch),
              adapterType: 'fake',
            ),
          ]);
          break;
        case 'signal':
          try {
            final payload = jsonDecode(m.payload) as Map<String, dynamic>;
            _signalCtrl.add([{
              'from': m.from,
              ...payload,
            }]);
          } catch (e) {
            debugPrint('[FakeAdapter] bad signal payload: $e');
          }
          break;
        default:
          // Other kinds (addr_update, etc.) ride the signal stream as well.
          _signalCtrl.add([{
            'from': m.from,
            'type': m.kind,
            'raw': m.payload,
          }]);
      }
    });
  }

  @override
  Stream<List<Message>> listenForMessages() => _messageCtrl.stream;

  @override
  Stream<List<Map<String, dynamic>>> listenForSignals() => _signalCtrl.stream;

  @override
  Stream<bool> get healthChanges => const Stream<bool>.empty();

  @override
  Future<String?> provisionGroup(String groupName) async => null;

  @override
  Future<Map<String, dynamic>?> fetchPublicKeys() async => null;

  // ── MessageSender surface ────────────────────────────────────────────

  @override
  Future<void> initializeSender(String apiKey) async {}

  @override
  Future<bool> sendMessage(
      String targetDatabaseId, String roomId, Message message) async {
    bus.send(BusMessage(
      to: targetDatabaseId,
      from: ownerAddress,
      kind: 'msg',
      payload: message.encryptedPayload,
      ts: message.timestamp.millisecondsSinceEpoch,
    ));
    return true;
  }

  @override
  Future<bool> sendSignal(String targetDatabaseId, String roomId,
      String senderId, String type, Map<String, dynamic> payload) async {
    bus.send(BusMessage(
      to: targetDatabaseId,
      from: senderId,
      kind: 'signal',
      payload: jsonEncode({'type': type, 'payload': payload}),
    ));
    return true;
  }

  // ── Lifecycle ────────────────────────────────────────────────────────

  Future<void> dispose() async {
    await _sub?.cancel();
    await _messageCtrl.close();
    await _signalCtrl.close();
  }
}
