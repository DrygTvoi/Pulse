import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart' as crypto;
import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// Use shared crypto — no duplicated NIP-04 / secp256k1 code.
import '../adapters/nostr_adapter.dart' show nip04Encrypt, nip04Decrypt, computeEcdhSecret;
import '../services/nostr_event_builder.dart' as neb;

/// 6-char hex verification code derived from ECDH shared secret.
String _verificationCode(String privHex, String peerPubHex) {
  final sharedX = computeEcdhSecret(privHex, peerPubHex);
  final hash = crypto.sha256.convert(sharedX).bytes;
  return hex.encode(hash.take(3).toList()).toUpperCase();
}

// ─── DeviceTransferService ───────────────────────────────────────────────────

class DeviceTransferService {
  static const _secureStorage = FlutterSecureStorage();

  // Ephemeral keypair for this session
  String _myPrivHex = '';
  String _myPubHex = '';
  String _peerPubHex = '';
  String verificationCode = '';

  final Completer<void> _exchangeCompleter = Completer();
  Future<void> get exchangeComplete => _exchangeCompleter.future;

  HttpServer? _server;
  WebSocketChannel? _ws;
  bool _disposed = false;

  void _genKeypair() {
    _myPrivHex = neb.generateRandomPrivkey();
    _myPubHex = neb.derivePubkeyHex(_myPrivHex);
  }

  // ─── Bundle collection ─────────────────────────────────────────────────────

  Future<Map<String, String>> _collectBundle() async {
    final prefs = await SharedPreferences.getInstance();
    final bundle = <String, String>{};
    for (final key in ['signal_id_key', 'signal_reg_id', 'signal_signed_prekey_0', 'nostr_privkey']) {
      final val = await _secureStorage.read(key: key);
      if (val != null && val.isNotEmpty) bundle[key] = val;
    }
    final userIdentity = prefs.getString('user_identity');
    if (userIdentity != null) bundle['user_identity'] = userIdentity;
    return bundle;
  }

  Future<void> _importBundle(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in ['signal_id_key', 'signal_reg_id', 'signal_signed_prekey_0', 'nostr_privkey']) {
      if (data[key] != null) {
        await _secureStorage.write(key: key, value: data[key] as String);
      }
    }
    if (data['user_identity'] != null) {
      await prefs.setString('user_identity', data['user_identity'] as String);
    }
    // Clear so new device regenerates prekeys on next initialize()
    await _secureStorage.delete(key: 'signal_prekeys_generated');
    // Clear publish flags so ChatController republishes on next connect
    for (final k in prefs.getKeys().where((k) => k.startsWith('signal_keys_published_')).toList()) {
      await prefs.remove(k);
    }
  }

  // ─── LAN — Source ──────────────────────────────────────────────────────────

  /// Start LAN transfer as sender. Returns transfer code: "LAN:ip:port:pubkey"
  Future<String> startLanTransfer() async {
    _genKeypair();
    _server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    final port = _server!.port;
    final ip = await _getLocalIp();
    final code = 'LAN:$ip:$port:$_myPubHex';
    unawaited(_serveLanExchange());
    // 5-minute timeout
    Timer(const Duration(minutes: 5), () {
      if (!_exchangeCompleter.isCompleted) {
        _exchangeCompleter.completeError('Transfer timed out');
      }
      _server?.close(force: true);
    });
    return code;
  }

  Future<String> _getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (!addr.isLoopback) return addr.address;
        }
      }
    } catch (e) {
      debugPrint('[DeviceTransfer] Failed to get local IP: $e');
    }
    return '127.0.0.1';
  }

  Future<void> _serveLanExchange() async {
    try {
      await for (final req in _server!) {
        if (_disposed) break;
        if (req.method == 'POST' && req.uri.path == '/exchange') {
          try {
            final body = await utf8.decoder.bind(req).join();
            final json = jsonDecode(body) as Map<String, dynamic>;
            _peerPubHex = json['pubkey'] as String;
            verificationCode = _verificationCode(_myPrivHex, _peerPubHex);
            final bundle = await _collectBundle();
            final encrypted = nip04Encrypt(_myPrivHex, _peerPubHex, jsonEncode(bundle));
            final response = jsonEncode({'ciphertext': encrypted});
            req.response
              ..statusCode = 200
              ..headers.contentType = ContentType.json
              ..write(response);
            await req.response.close();
            if (!_exchangeCompleter.isCompleted) _exchangeCompleter.complete();
          } catch (e) {
            req.response.statusCode = 400;
            await req.response.close();
            if (!_exchangeCompleter.isCompleted) {
              _exchangeCompleter.completeError(e);
            }
          }
          break;
        } else {
          req.response.statusCode = 404;
          await req.response.close();
        }
      }
    } catch (e) {
      debugPrint('[DeviceTransfer] LAN serve error: $e');
      if (!_exchangeCompleter.isCompleted) {
        _exchangeCompleter.completeError(e);
      }
    } finally {
      await _server?.close(force: true);
    }
  }

  // ─── LAN — Target ──────────────────────────────────────────────────────────

  /// Connect to LAN sender. Code format: "LAN:ip:port:srcPubHex"
  Future<void> receiveLanTransfer(String code) async {
    final parts = code.split(':');
    // parts[0]=LAN, parts[1]=ip, parts[2]=port, parts[3]=srcPub (64 hex chars)
    if (parts.length < 4) throw FormatException('Invalid LAN transfer code');
    final ip = parts[1];
    final port = int.tryParse(parts[2]);
    if (port == null) throw FormatException('Invalid port in LAN transfer code');
    final srcPubHex = parts[3];

    _genKeypair();

    final client = HttpClient();
    try {
      final request = await client.post(ip, port, '/exchange');
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode({'pubkey': _myPubHex}));
      final response = await request.close();
      final body = await utf8.decoder.bind(response).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final ciphertext = json['ciphertext'] as String;
      final plain = nip04Decrypt(_myPrivHex, srcPubHex, ciphertext);
      await _importBundle(jsonDecode(plain) as Map<String, dynamic>);
      verificationCode = _verificationCode(_myPrivHex, srcPubHex);
      _peerPubHex = srcPubHex;
    } finally {
      client.close();
    }
  }

  // ─── Nostr — Source ────────────────────────────────────────────────────────

  /// Start Nostr transfer as sender. Returns code: "NOS:relay:pubkey"
  Future<String> startNostrTransfer(String relay) async {
    _genKeypair();
    final code = 'NOS:$relay:$_myPubHex';
    unawaited(_serveNostrExchange(relay));
    // 5-minute timeout
    Timer(const Duration(minutes: 5), () {
      if (!_exchangeCompleter.isCompleted) {
        _exchangeCompleter.completeError('Transfer timed out');
      }
      _ws?.sink.close();
    });
    return code;
  }

  Future<void> _serveNostrExchange(String relay) async {
    WebSocketChannel? channel;
    try {
      channel = WebSocketChannel.connect(Uri.parse(relay));
      _ws = channel;
      await channel.ready;

      final subId = 'dt_${DateTime.now().millisecondsSinceEpoch}';
      final since = DateTime.now().millisecondsSinceEpoch ~/ 1000 - 5;
      channel.sink.add(jsonEncode(['REQ', subId, {
        'kinds': [4],
        '#p': [_myPubHex],
        'since': since,
        'limit': 1,
      }]));

      await for (final raw in channel.stream) {
        if (_disposed) break;
        try {
          final data = jsonDecode(raw as String) as List;
          if (data[0] != 'EVENT' || data[1] != subId) continue;
          final event = data[2] as Map<String, dynamic>;
          if (event['kind'] != 4) continue;
          // Target sends its pubkey as plaintext content
          final kbPubHex = event['content'] as String;
          if (kbPubHex.length != 64) continue; // sanity check
          _peerPubHex = kbPubHex;
          verificationCode = _verificationCode(_myPrivHex, _peerPubHex);
          // Encrypt and send bundle back
          final bundle = await _collectBundle();
          final encrypted = nip04Encrypt(_myPrivHex, _peerPubHex, jsonEncode(bundle));
          final replyEvent = neb.buildEvent(
            privkeyHex: _myPrivHex,
            kind: 4,
            content: encrypted,
            tags: [['p', _peerPubHex]],
          );
          channel.sink.add(jsonEncode(['EVENT', replyEvent]));
          if (!_exchangeCompleter.isCompleted) _exchangeCompleter.complete();
          break;
        } catch (e) {
          debugPrint('[DeviceTransfer] Nostr source parse error: $e');
        }
      }
    } catch (e) {
      debugPrint('[DeviceTransfer] Nostr source error: $e');
      if (!_exchangeCompleter.isCompleted) {
        _exchangeCompleter.completeError(e);
      }
    } finally {
      channel?.sink.close();
    }
  }

  // ─── Nostr — Target ────────────────────────────────────────────────────────

  /// Connect to Nostr sender. Code format: "NOS:relay:srcPubHex"
  Future<void> receiveNostrTransfer(String code) async {
    // Code: "NOS:wss://relay.damus.io:deadbeef..."
    // srcPub is always the last 64 chars; relay is everything between "NOS:" and ":$srcPub"
    final withoutPrefix = code.substring(4); // strip "NOS:"
    final srcPubHex = withoutPrefix.substring(withoutPrefix.length - 64);
    final relay = withoutPrefix.substring(0, withoutPrefix.length - 65); // strip ":$srcPub"

    _genKeypair();

    WebSocketChannel? channel;
    try {
      channel = WebSocketChannel.connect(Uri.parse(relay));
      _ws = channel;
      await channel.ready;

      final subId = 'dt_${DateTime.now().millisecondsSinceEpoch}';
      final since = DateTime.now().millisecondsSinceEpoch ~/ 1000 - 5;

      // Subscribe for incoming reply
      channel.sink.add(jsonEncode(['REQ', subId, {
        'kinds': [4],
        '#p': [_myPubHex],
        'since': since,
        'limit': 1,
      }]));

      // Publish our pubkey to the source
      final announceEvent = neb.buildEvent(
        privkeyHex: _myPrivHex,
        kind: 4,
        content: _myPubHex,
        tags: [['p', srcPubHex]],
      );
      channel.sink.add(jsonEncode(['EVENT', announceEvent]));

      // Wait for bundle reply (60s timeout)
      bool received = false;
      await channel.stream.timeout(const Duration(seconds: 60)).forEach((raw) async {
        if (received) return;
        try {
          final data = jsonDecode(raw as String) as List;
          if (data[0] != 'EVENT' || data[1] != subId) return;
          final event = data[2] as Map<String, dynamic>;
          if (event['kind'] != 4) return;
          final senderPub = event['pubkey'] as String;
          if (senderPub != srcPubHex) return;
          final plain = nip04Decrypt(_myPrivHex, srcPubHex, event['content'] as String);
          await _importBundle(jsonDecode(plain) as Map<String, dynamic>);
          verificationCode = _verificationCode(_myPrivHex, srcPubHex);
          _peerPubHex = srcPubHex;
          received = true;
        } catch (e) {
          debugPrint('[DeviceTransfer] Nostr target parse error: $e');
        }
      });
      if (!received) throw TimeoutException('No bundle received from source device');
    } finally {
      channel?.sink.close();
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    await _server?.close(force: true);
    _ws?.sink.close();
  }
}
