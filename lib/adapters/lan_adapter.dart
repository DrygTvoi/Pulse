import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/message.dart';
import 'inbox_manager.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

/// Administratively-scoped multicast address (RFC 2365).
/// Traffic stays on the local network — never routed to the internet.
const _multicastGroup = '239.255.42.99';
const _port           = 7842;

/// UDP datagrams larger than this are dropped before parsing (DoS guard).
/// Covers Signal-encrypted text + small media; large files are rejected.
const _maxDatagramBytes = 60000;

// ── LanInboxReader ────────────────────────────────────────────────────────────

/// Listens on the LAN multicast group and surfaces incoming Signal-encrypted
/// messages to ChatController.  Runs on every Pulse device on the subnet.
/// Only the intended recipient can decrypt — same model as Nostr.
class LanInboxReader implements InboxReader {
  String _selfAddress = '';
  RawDatagramSocket? _socket;

  final _msgCtrl = StreamController<List<Message>>.broadcast();
  final _sigCtrl = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _seenIds  = <String>{};

  @override
  Stream<bool> get healthChanges => Stream<bool>.empty();

  @override
  Future<void> initializeReader(String apiKey, String databaseId) async {
    _selfAddress = databaseId;
    await _bindSocket();
  }

  Future<void> _bindSocket() async {
    try {
      _socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4, _port,
        reuseAddress: true, reusePort: true,
      );
      _socket!.joinMulticast(InternetAddress(_multicastGroup));
      _socket!.listen(_onEvent);
      debugPrint('[LAN] Listening on $_multicastGroup:$_port');
    } catch (e) {
      debugPrint('[LAN] Reader bind failed: $e');
    }
  }

  void _onEvent(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;
    final dg = _socket?.receive();
    if (dg == null || dg.data.length > _maxDatagramBytes) return;
    _handleDatagram(dg.data);
  }

  void _handleDatagram(List<int> raw) {
    try {
      final outer = jsonDecode(utf8.decode(raw)) as Map<String, dynamic>;
      final from    = outer['from']    as String? ?? '';
      final payload = outer['payload'] as String? ?? '';
      final type    = outer['t']       as String? ?? 'msg';
      final id      = outer['id']      as String? ?? '';
      final tsMs    = outer['ts']      as int?    ?? 0;

      if (from.isEmpty || payload.isEmpty) return;
      if (from == _selfAddress) return; // ignore own broadcasts

      if (id.isNotEmpty) {
        if (_seenIds.contains(id)) return;
        _seenIds.add(id);
        if (_seenIds.length > 2000) {
          _seenIds.removeAll(_seenIds.take(1000).toList());
        }
      }

      if (type == 'sig') {
        try {
          final sigData = jsonDecode(payload) as Map<String, dynamic>;
          _sigCtrl.add([sigData]);
        } catch (_) {}
        return;
      }

      _msgCtrl.add([
        Message(
          id:               id.isNotEmpty ? id : '${from}_$tsMs',
          senderId:         from,
          receiverId:       _selfAddress,
          encryptedPayload: payload,
          timestamp:        tsMs > 0
              ? DateTime.fromMillisecondsSinceEpoch(tsMs)
              : DateTime.now(),
          adapterType: 'lan',
        )
      ]);
    } catch (e) {
      debugPrint('[LAN] Datagram parse error: $e');
    }
  }

  @override
  Stream<List<Message>> listenForMessages() => _msgCtrl.stream;

  @override
  Stream<List<Map<String, dynamic>>> listenForSignals() => _sigCtrl.stream;

  /// Key bundles are not distributed over LAN — falls back to cached sessions.
  @override
  Future<Map<String, dynamic>?> fetchPublicKeys() async => null;

  @override
  Future<String?> provisionGroup(String groupName) async => null;

  void close() {
    _socket?.close();
    _socket = null;
    if (!_msgCtrl.isClosed) _msgCtrl.close();
    if (!_sigCtrl.isClosed) _sigCtrl.close();
  }
}

// ── LanMessageSender ──────────────────────────────────────────────────────────

/// Broadcasts Signal-encrypted messages to all Pulse devices on the LAN.
/// TTL = 1 ensures traffic never leaves the local subnet.
class LanMessageSender implements MessageSender {
  String _selfAddress = '';
  RawDatagramSocket? _socket;
  final _dest = InternetAddress(_multicastGroup);

  @override
  Future<void> initializeSender(String apiKey) async {
    _selfAddress = apiKey; // apiKey = caller's selfAddress
    try {
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      _socket!.multicastHops = 1; // TTL = 1: local subnet only
      debugPrint('[LAN] Sender ready (selfAddress: $_selfAddress)');
    } catch (e) {
      debugPrint('[LAN] Sender bind failed: $e');
    }
  }

  @override
  Future<bool> sendMessage(
      String targetDatabaseId, String roomId, Message message) {
    return _broadcast('msg', message.encryptedPayload, message.id);
  }

  @override
  Future<bool> sendSignal(
    String targetDatabaseId,
    String roomId,
    String senderId,
    String type,
    Map<String, dynamic> payload,
  ) {
    // Key bundles are not broadcast over LAN
    if (type == 'sys_keys') return Future.value(false);
    return _broadcast(
      'sig',
      jsonEncode({
        'type':     type,
        'roomId':   roomId,
        'senderId': senderId,
        'payload':  payload,
      }),
      '${type}_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  Future<bool> _broadcast(String type, String payload, String id) async {
    if (_socket == null) return false;
    try {
      final data = utf8.encode(jsonEncode({
        'from':    _selfAddress,
        'payload': payload,
        't':       type,
        'id':      id,
        'ts':      DateTime.now().millisecondsSinceEpoch,
      }));
      if (data.length > _maxDatagramBytes) {
        debugPrint('[LAN] Payload too large (${data.length}B) — not broadcast');
        return false;
      }
      _socket!.send(data, _dest, _port);
      return true;
    } catch (e) {
      debugPrint('[LAN] Broadcast error: $e');
      return false;
    }
  }

  void close() => _socket?.close();
}
