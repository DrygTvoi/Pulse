import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart' as crypto;
import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// ─── Secp256k1 key utilities (copied from nostr_adapter.dart) ────────────────

final _secp256k1 = ECCurve_secp256k1();

Uint8List _bigIntToBytes(BigInt n, int length) {
  final bytes = Uint8List(length);
  var value = n;
  for (int i = length - 1; i >= 0; i--) {
    bytes[i] = (value & BigInt.from(0xFF)).toInt();
    value = value >> 8;
  }
  return bytes;
}

String _derivePubkeyHex(String privkeyHex) {
  final d = BigInt.parse(privkeyHex, radix: 16);
  final G = _secp256k1.G;
  final Q = G * d;
  final xBytes = _bigIntToBytes(Q!.x!.toBigInteger()!, 32);
  return hex.encode(xBytes);
}

String _nip04Encrypt(String senderPrivkeyHex, String recipientPubkeyHex, String plaintext) {
  const pHex = 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F';
  final p = BigInt.parse(pHex, radix: 16);
  final d = BigInt.parse(senderPrivkeyHex, radix: 16);
  final curve = _secp256k1.curve;
  final x = BigInt.parse(recipientPubkeyHex, radix: 16);
  final y2 = (x.modPow(BigInt.from(3), p) + BigInt.from(7)) % p;
  final y = y2.modPow((p + BigInt.one) ~/ BigInt.from(4), p);
  final useY = y.isEven ? y : p - y;
  final sharedPoint = curve.createPoint(x, useY) * d;
  final xVal = sharedPoint?.x?.toBigInteger();
  if (xVal == null) throw FormatException('NIP-04 encrypt: invalid shared point');
  final sharedX = _bigIntToBytes(xVal, 32);
  final rng = Random.secure();
  final iv = Uint8List.fromList(List.generate(16, (_) => rng.nextInt(256)));
  final plaintextBytes = Uint8List.fromList(utf8.encode(plaintext));
  final cipher = CBCBlockCipher(AESEngine());
  cipher.init(true, ParametersWithIV<KeyParameter>(KeyParameter(Uint8List.fromList(sharedX)), iv));
  final padLen = 16 - (plaintextBytes.length % 16);
  final padded = Uint8List(plaintextBytes.length + padLen)
    ..setAll(0, plaintextBytes)
    ..fillRange(plaintextBytes.length, plaintextBytes.length + padLen, padLen);
  final ciphertext = Uint8List(padded.length);
  for (int i = 0; i < padded.length; i += 16) {
    cipher.processBlock(padded, i, ciphertext, i);
  }
  return '${base64.encode(ciphertext)}?iv=${base64.encode(iv)}';
}

String _nip04Decrypt(String recipientPrivkeyHex, String senderPubkeyHex, String ciphertext) {
  final parts = ciphertext.split('?iv=');
  if (parts.length != 2) throw FormatException('Invalid NIP-04 ciphertext');
  final ct = base64.decode(parts[0]);
  final iv = base64.decode(parts[1]);
  const pHex = 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F';
  final p = BigInt.parse(pHex, radix: 16);
  final d = BigInt.parse(recipientPrivkeyHex, radix: 16);
  final curve = _secp256k1.curve;
  final x = BigInt.parse(senderPubkeyHex, radix: 16);
  final y2 = (x.modPow(BigInt.from(3), p) + BigInt.from(7)) % p;
  final y = y2.modPow((p + BigInt.one) ~/ BigInt.from(4), p);
  final useY = y.isEven ? y : p - y;
  final sharedPoint = curve.createPoint(x, useY) * d;
  final xVal = sharedPoint?.x?.toBigInteger();
  if (xVal == null) throw FormatException('NIP-04 decrypt: invalid shared point');
  final sharedX = _bigIntToBytes(xVal, 32);
  final cipherObj = CBCBlockCipher(AESEngine());
  cipherObj.init(false, ParametersWithIV<KeyParameter>(KeyParameter(Uint8List.fromList(sharedX)), Uint8List.fromList(iv)));
  final plainBytes = Uint8List(ct.length);
  for (int i = 0; i < ct.length; i += 16) {
    cipherObj.processBlock(Uint8List.fromList(ct), i, plainBytes, i);
  }
  final padLen = plainBytes.last;
  return utf8.decode(plainBytes.sublist(0, plainBytes.length - padLen));
}

Uint8List _sha256(List<int> data) =>
    Uint8List.fromList(crypto.sha256.convert(data).bytes);

Uint8List _taggedHash(String tag, List<int> data) {
  final tagHash = _sha256(utf8.encode(tag));
  return _sha256([...tagHash, ...tagHash, ...data]);
}

String _signEvent(String privkeyHex, String eventId) {
  final msgBytes = Uint8List.fromList(hex.decode(eventId));
  var d = BigInt.parse(privkeyHex, radix: 16);
  final n = _secp256k1.n;
  final G = _secp256k1.G;
  final P = G * d;
  if (P!.y!.toBigInteger()!.isOdd) d = n - d;
  final pubkeyHex = _derivePubkeyHex(privkeyHex);
  final pubBytes = Uint8List.fromList(hex.decode(pubkeyHex));
  final privBytes = Uint8List.fromList(hex.decode(privkeyHex));
  final randBytes = Uint8List(32);
  final auxRng = Random.secure();
  for (int i = 0; i < 32; i++) { randBytes[i] = auxRng.nextInt(256); }
  final nonceHash = _taggedHash('BIP0340/nonce', [...randBytes, ...privBytes, ...msgBytes]);
  var k = BigInt.parse(hex.encode(nonceHash), radix: 16) % n;
  if (k == BigInt.zero) k = BigInt.one;
  var R = G * k;
  if (R!.y!.toBigInteger()!.isOdd) {
    k = n - k;
    R = G * k;
  }
  final rx = _bigIntToBytes(R!.x!.toBigInteger()!, 32);
  final eBytes = _taggedHash('BIP0340/challenge', [...rx, ...pubBytes, ...msgBytes]);
  final e = BigInt.parse(hex.encode(eBytes), radix: 16) % n;
  final s = (k + e * d) % n;
  return hex.encode([...rx, ..._bigIntToBytes(s, 32)]);
}

String _buildEventId(Map<String, dynamic> event) {
  final serialized = jsonEncode([
    0, event['pubkey'], event['created_at'], event['kind'], event['tags'], event['content'],
  ]);
  return hex.encode(_sha256(utf8.encode(serialized)));
}

Map<String, dynamic> _buildEvent({
  required String privkeyHex,
  required int kind,
  required String content,
  List<List<String>>? tags,
}) {
  final pubkey = _derivePubkeyHex(privkeyHex);
  final createdAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final event = <String, dynamic>{
    'pubkey': pubkey, 'created_at': createdAt, 'kind': kind,
    'tags': tags ?? [], 'content': content,
  };
  final id = _buildEventId(event);
  event['id'] = id;
  event['sig'] = _signEvent(privkeyHex, id);
  return event;
}

/// 6-char hex verification code derived from ECDH shared secret.
String _verificationCode(String privHex, String peerPubHex) {
  const pHex = 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F';
  final p = BigInt.parse(pHex, radix: 16);
  final x = BigInt.parse(peerPubHex, radix: 16);
  final y2 = (x.modPow(BigInt.from(3), p) + BigInt.from(7)) % p;
  final y = y2.modPow((p + BigInt.one) ~/ BigInt.from(4), p);
  final useY = y.isEven ? y : p - y;
  final sharedPoint = _secp256k1.curve.createPoint(x, useY) * BigInt.parse(privHex, radix: 16);
  final sharedX = _bigIntToBytes(sharedPoint!.x!.toBigInteger()!, 32);
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
    final rng = Random.secure();
    _myPrivHex = hex.encode(Uint8List.fromList(List.generate(32, (_) => rng.nextInt(256))));
    _myPubHex = _derivePubkeyHex(_myPrivHex);
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
            final encrypted = _nip04Encrypt(_myPrivHex, _peerPubHex, jsonEncode(bundle));
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
    final port = int.parse(parts[2]);
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
      final plain = _nip04Decrypt(_myPrivHex, srcPubHex, ciphertext);
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
          final encrypted = _nip04Encrypt(_myPrivHex, _peerPubHex, jsonEncode(bundle));
          final replyEvent = _buildEvent(
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
      final announceEvent = _buildEvent(
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
          final plain = _nip04Decrypt(_myPrivHex, srcPubHex, event['content'] as String);
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
