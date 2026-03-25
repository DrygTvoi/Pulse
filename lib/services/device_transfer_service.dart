import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart' as crypto;
import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// Use shared crypto — NIP-44 for encryption, secp256k1 for ECDH.
import '../adapters/nostr_adapter.dart' show computeEcdhSecret, computeEcdhSecretAsync;
import '../services/nip44_service.dart' show nip44Encrypt, nip44Decrypt;
import '../services/nostr_event_builder.dart' as neb;

/// 12-char hex verification code derived from ECDH shared secret.
/// 6 bytes (48 bits) → 2^48 ≈ 281 trillion combinations, brute-force infeasible
/// even at 1M ECDH ops/sec (would take ~9 years vs 16 seconds for 3-byte code).
String _verificationCode(String privHex, String peerPubHex) {
  final sharedX = computeEcdhSecret(privHex, peerPubHex, context: 'device_transfer');
  final hash = crypto.sha256.convert(sharedX).bytes;
  return hex.encode(hash.take(6).toList()).toUpperCase();
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

  /// Completer gated on user confirming verification code match (sender side).
  Completer<void>? _bundleConfirmed;

  /// Call after user confirms the verification code matches on the sender side.
  /// This unblocks the /confirm-and-get-bundle endpoint so the receiver can
  /// fetch the encrypted key bundle.
  void confirmTransfer() {
    if (_bundleConfirmed != null && !_bundleConfirmed!.isCompleted) {
      _bundleConfirmed!.complete();
    }
  }

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
        if (data[key] is! String) {
          throw FormatException('Invalid type for $key in transfer bundle: ${data[key].runtimeType}');
        }
        await _secureStorage.write(key: key, value: data[key] as String);
      }
    }
    if (data['user_identity'] != null) {
      if (data['user_identity'] is! String) {
        throw FormatException('Invalid type for user_identity in transfer bundle');
      }
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
    _bundleConfirmed = Completer<void>();
    try {
      await for (final req in _server!) {
        if (_disposed) break;

        // Phase 1: Exchange pubkeys + verification code (no bundle yet).
        if (req.method == 'POST' && req.uri.path == '/exchange') {
          try {
            final body = await utf8.decoder.bind(req).join();
            final json = jsonDecode(body) as Map<String, dynamic>;
            _peerPubHex = json['pubkey'] as String;
            verificationCode = _verificationCode(_myPrivHex, _peerPubHex);
            final response = jsonEncode({
              'pubkey': _myPubHex,
              'verification': verificationCode,
            });
            req.response
              ..statusCode = 200
              ..headers.contentType = ContentType.json
              ..write(response);
            await req.response.close();
            // Signal that the exchange phase completed (UI shows code).
            if (!_exchangeCompleter.isCompleted) _exchangeCompleter.complete();
          } catch (e) {
            req.response.statusCode = 400;
            await req.response.close();
            if (!_exchangeCompleter.isCompleted) {
              _exchangeCompleter.completeError(e);
            }
          }

        // Phase 2: Receiver requests bundle after both users confirm the code.
        } else if (req.method == 'POST' && req.uri.path == '/confirm-and-get-bundle') {
          try {
            if (_peerPubHex.isEmpty) {
              req.response.statusCode = 409; // Conflict — exchange not done
              await req.response.close();
              continue;
            }
            // Wait for sender-side confirmation (2-minute timeout).
            await _bundleConfirmed!.future.timeout(const Duration(minutes: 2));
            final bundle = await _collectBundle();
            final sharedX = await computeEcdhSecretAsync(
              _myPrivHex, _peerPubHex, context: 'device_transfer');
            final encrypted = await nip44Encrypt(sharedX, jsonEncode(bundle));
            final response = jsonEncode({'ciphertext': encrypted});
            req.response
              ..statusCode = 200
              ..headers.contentType = ContentType.json
              ..write(response);
            await req.response.close();
          } catch (e) {
            req.response.statusCode = 408; // Timeout or error
            await req.response.close();
          }
          break; // Transfer complete or failed — stop serving.

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
  ///
  /// Phase 1: POST /exchange — sends our pubkey, receives sender's pubkey +
  /// verification code. The caller must show the code to the user.
  ///
  /// Phase 2: After the user confirms the code, call [confirmAndReceiveBundle]
  /// to POST /confirm-and-get-bundle and import the encrypted key bundle.
  Future<void> receiveLanTransfer(String code) async {
    final parts = code.split(':');
    // parts[0]=LAN, parts[1]=ip, parts[2]=port, parts[3]=srcPub (64 hex chars)
    if (parts.length < 4) throw FormatException('Invalid LAN transfer code');
    final ip = parts[1];
    final port = int.tryParse(parts[2]);
    if (port == null) throw FormatException('Invalid port in LAN transfer code');

    _genKeypair();

    // Phase 1: exchange pubkeys, get verification code.
    // parts[3] is the sender's pubkey baked into the QR code — bind to it so
    // an ARP-poisoning attacker cannot substitute their own pubkey here.
    final expectedSenderPub = parts[3];
    final client = HttpClient();
    try {
      final request = await client.post(ip, port, '/exchange');
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode({'pubkey': _myPubHex}));
      final response = await request.close();
      final body = await utf8.decoder.bind(response).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final returnedPub = json['pubkey'] as String? ?? '';
      // Cryptographic binding: the server MUST return the same pubkey that was
      // encoded in the transfer code (QR/string).  Any deviation means the
      // responding host is not the legitimate sender device — abort immediately.
      if (returnedPub != expectedSenderPub) {
        throw FormatException(
            'Server pubkey mismatch — possible MITM attack. '
            'Expected $expectedSenderPub, got $returnedPub');
      }
      _peerPubHex = returnedPub;
      verificationCode = json['verification'] as String;
    } finally {
      client.close();
    }
    // At this point the UI should display verificationCode and wait for user
    // to tap Confirm, then call confirmAndReceiveBundle(code).
  }

  /// Phase 2 (receiver side): request the encrypted bundle from the sender
  /// after the user has confirmed the verification code.
  Future<void> confirmAndReceiveBundle(String code) async {
    final parts = code.split(':');
    if (parts.length < 4) throw FormatException('Invalid LAN transfer code');
    final ip = parts[1];
    final port = int.tryParse(parts[2]);
    if (port == null) throw FormatException('Invalid port in LAN transfer code');

    final client = HttpClient();
    try {
      final request = await client.post(ip, port, '/confirm-and-get-bundle');
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode({'pubkey': _myPubHex}));
      final response = await request.close();
      if (response.statusCode != 200) {
        throw Exception(
            'Bundle request failed with status ${response.statusCode}');
      }
      final body = await utf8.decoder.bind(response).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final ciphertext = json['ciphertext'] as String;
      final sharedX = await computeEcdhSecretAsync(
          _myPrivHex, _peerPubHex, context: 'device_transfer');
      final plain = await nip44Decrypt(sharedX, ciphertext);
      await _importBundle(jsonDecode(plain) as Map<String, dynamic>);
    } finally {
      client.close();
    }
  }

  // ─── Nostr — Source ────────────────────────────────────────────────────────

  /// Start Nostr transfer as sender. Returns code: "NOS:relay_url|pubkey"
  Future<String> startNostrTransfer(String relay) async {
    _genKeypair();
    final code = 'NOS:$relay|$_myPubHex';
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
          final kbPubHex = event['content'];
          if (kbPubHex is! String || kbPubHex.length != 64) continue;
          _peerPubHex = kbPubHex;
          verificationCode = _verificationCode(_myPrivHex, _peerPubHex);
          // F1-CRITICAL: Gate bundle transmission on user confirmation.
          // Complete the exchange completer so the UI can show the verification
          // code; the bundle is NOT sent until confirmTransfer() is called.
          if (!_exchangeCompleter.isCompleted) _exchangeCompleter.complete();
          _bundleConfirmed = Completer<void>();
          try {
            await _bundleConfirmed!.future.timeout(const Duration(minutes: 2));
          } on TimeoutException {
            debugPrint('[DeviceTransfer] Nostr: user did not confirm in time');
            break;
          }
          // Encrypt and send bundle back (NIP-44) only after user confirms
          final bundle = await _collectBundle();
          final sharedX = await computeEcdhSecretAsync(
            _myPrivHex, _peerPubHex, context: 'device_transfer');
          final encrypted = await nip44Encrypt(sharedX, jsonEncode(bundle));
          final replyEvent = await neb.buildEvent(
            privkeyHex: _myPrivHex,
            kind: 4,
            content: encrypted,
            tags: [['p', _peerPubHex]],
          );
          channel.sink.add(jsonEncode(['EVENT', replyEvent]));
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

  /// Connect to Nostr sender. Code format: "NOS:relay_url|srcPubHex"
  Future<void> receiveNostrTransfer(String code) async {
    final withoutPrefix = code.substring(4); // strip "NOS:"
    final pipeIdx = withoutPrefix.lastIndexOf('|');
    if (pipeIdx < 0) throw FormatException('Invalid Nostr transfer code — missing | delimiter');
    final relay = withoutPrefix.substring(0, pipeIdx);
    final srcPubHex = withoutPrefix.substring(pipeIdx + 1);
    if (srcPubHex.length != 64) throw FormatException('Invalid pubkey in Nostr transfer code');

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
      final announceEvent = await neb.buildEvent(
        privkeyHex: _myPrivHex,
        kind: 4,
        content: _myPubHex,
        tags: [['p', srcPubHex]],
      );
      channel.sink.add(jsonEncode(['EVENT', announceEvent]));

      // Wait for bundle reply (60s timeout)
      bool received = false;
      await for (final raw in channel.stream.timeout(const Duration(seconds: 60))) {
        if (received) break;
        try {
          final data = jsonDecode(raw as String) as List;
          if (data[0] != 'EVENT' || data[1] != subId) continue;
          final event = data[2] as Map<String, dynamic>;
          if (event['kind'] != 4) continue;
          final senderPub = event['pubkey'] as String;
          if (senderPub != srcPubHex) continue;
          final sharedX = await computeEcdhSecretAsync(
              _myPrivHex, srcPubHex, context: 'device_transfer');
          final plain = await nip44Decrypt(sharedX, event['content'] as String);
          // F4: Store bundle in memory first; import ONLY after user confirms code.
          // Old code imported immediately — an MITM who controlled the relay could
          // deliver a crafted bundle before the user sees the verification code.
          final pendingBundle = jsonDecode(plain) as Map<String, dynamic>;
          verificationCode = _verificationCode(_myPrivHex, srcPubHex);
          _peerPubHex = srcPubHex;
          received = true;
          // Gate the actual key write on user confirmation.
          _bundleConfirmed = Completer<void>();
          if (!_exchangeCompleter.isCompleted) _exchangeCompleter.complete();
          try {
            await _bundleConfirmed!.future.timeout(const Duration(minutes: 2));
            await _importBundle(pendingBundle);
          } on TimeoutException {
            debugPrint('[DeviceTransfer] Nostr receiver: confirmation timed out');
          }
          break;
        } catch (e) {
          debugPrint('[DeviceTransfer] Nostr target parse error: $e');
        }
      }
      if (!received) throw TimeoutException('No bundle received from source device');
    } finally {
      channel?.sink.close();
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    await _server?.close(force: true);
    _ws?.sink.close();
    // Zeroize ephemeral key material so it doesn't linger in memory.
    _myPrivHex = '';
    _myPubHex = '';
    _peerPubHex = '';
    verificationCode = '';
  }
}
