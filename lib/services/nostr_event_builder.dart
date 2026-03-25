import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart' as crypto;
import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';

/// Public Nostr event utilities extracted for use by Gift Wrap and other services.

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

Uint8List _sha256(List<int> data) =>
    Uint8List.fromList(crypto.sha256.convert(data).bytes);

Uint8List _taggedHash(String tag, List<int> data) {
  final tagHash = _sha256(utf8.encode(tag));
  return _sha256([...tagHash, ...tagHash, ...data]);
}

/// Derive Nostr public key (x-coordinate hex) from hex private key.
String derivePubkeyHex(String privkeyHex) {
  final d = BigInt.parse(privkeyHex, radix: 16);
  final Q = _secp256k1.G * d;
  return hex.encode(_bigIntToBytes(Q!.x!.toBigInteger()!, 32));
}

/// Top-level function for compute(): performs BIP-340 Schnorr signing
/// in a background isolate. Receives a Map with 'privkeyHex', 'eventId',
/// and 'auxRand' (random bytes generated on main isolate).
String _schnorrSignIsolate(Map<String, dynamic> params) {
  final String privkeyHex = params['privkeyHex'];
  final String eventId = params['eventId'];
  final List<int> auxRand = (params['auxRand'] as List).cast<int>();

  // Recreate curve in the isolate (top-level _secp256k1 is not shared)
  final secp = ECCurve_secp256k1();

  Uint8List bigIntToBytes(BigInt n, int length) {
    final bytes = Uint8List(length);
    var value = n;
    for (int i = length - 1; i >= 0; i--) {
      bytes[i] = (value & BigInt.from(0xFF)).toInt();
      value = value >> 8;
    }
    return bytes;
  }

  Uint8List sha256(List<int> data) =>
      Uint8List.fromList(crypto.sha256.convert(data).bytes);

  Uint8List taggedHash(String tag, List<int> data) {
    final tagHash = sha256(utf8.encode(tag));
    return sha256([...tagHash, ...tagHash, ...data]);
  }

  final msgBytes = Uint8List.fromList(hex.decode(eventId));
  var d = BigInt.parse(privkeyHex, radix: 16);
  final n = secp.n;
  final G = secp.G;

  final P = G * d;
  if (P!.y!.toBigInteger()!.isOdd) d = n - d;

  // Derive pubkey inside isolate (cannot call top-level derivePubkeyHex)
  final dOrig = BigInt.parse(privkeyHex, radix: 16);
  final Q = secp.G * dOrig;
  final pubBytes =
      Uint8List.fromList(hex.decode(hex.encode(bigIntToBytes(Q!.x!.toBigInteger()!, 32))));

  final privBytes = Uint8List.fromList(hex.decode(privkeyHex));
  final randBytes = Uint8List.fromList(auxRand);

  final nonceHash = taggedHash(
      'BIP0340/nonce', [...randBytes, ...privBytes, ...msgBytes]);
  var k = BigInt.parse(hex.encode(nonceHash), radix: 16) % n;
  if (k == BigInt.zero) k = BigInt.one;

  var R = G * k;
  if (R!.y!.toBigInteger()!.isOdd) {
    k = n - k;
    R = G * k;
  }
  final rx = bigIntToBytes(R!.x!.toBigInteger()!, 32);
  final eBytes =
      taggedHash('BIP0340/challenge', [...rx, ...pubBytes, ...msgBytes]);
  final e = BigInt.parse(hex.encode(eBytes), radix: 16) % n;
  final s = (k + e * d) % n;
  return hex.encode([...rx, ...bigIntToBytes(s, 32)]);
}

/// BIP-340 Schnorr sign an event ID in a background isolate.
Future<String> signEvent(String privkeyHex, String eventId) {
  // Generate random bytes on the main isolate (secure RNG)
  final auxRng = Random.secure();
  final randBytes = List<int>.generate(32, (_) => auxRng.nextInt(256));

  return compute(_schnorrSignIsolate, <String, dynamic>{
    'privkeyHex': privkeyHex,
    'eventId': eventId,
    'auxRand': randBytes,
  });
}

/// Build a Nostr event ID (SHA-256 of serialized array).
String buildEventId(Map<String, dynamic> event) {
  final serialized = jsonEncode([
    0,
    event['pubkey'],
    event['created_at'],
    event['kind'],
    event['tags'],
    event['content'],
  ]);
  return hex.encode(_sha256(utf8.encode(serialized)));
}

/// Build and sign a complete Nostr event.
Future<Map<String, dynamic>> buildEvent({
  required String privkeyHex,
  required int kind,
  required String content,
  List<List<String>>? tags,
  int? createdAt,
}) async {
  final pubkey = derivePubkeyHex(privkeyHex);
  final ts = createdAt ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final event = <String, dynamic>{
    'pubkey': pubkey,
    'created_at': ts,
    'kind': kind,
    'tags': tags ?? [],
    'content': content,
  };
  final id = buildEventId(event);
  event['id'] = id;
  event['sig'] = await signEvent(privkeyHex, id);
  return event;
}

/// Verify a BIP-340 Schnorr signature on an event.
bool verifyEventSignature(Map<String, dynamic> event) {
  try {
    final id = event['id'] as String;
    final sig = event['sig'] as String;
    final pubkeyHex = event['pubkey'] as String;

    // Recompute event ID and verify it matches
    final computedId = buildEventId(event);
    if (computedId != id) return false;

    final sigBytes = hex.decode(sig);
    if (sigBytes.length != 64) return false;

    final rx = BigInt.parse(hex.encode(sigBytes.sublist(0, 32)), radix: 16);
    final s = BigInt.parse(hex.encode(sigBytes.sublist(32, 64)), radix: 16);

    final n = _secp256k1.n;
    // BIP-340 §Verification: fail if s ≥ n or r ≥ p (field modulus).
    if (s >= n) return false;
    final G = _secp256k1.G;
    const pHex =
        'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F';
    final p = BigInt.parse(pHex, radix: 16);
    // BIP-340 §Verification: fail if r ≥ p.
    if (rx == BigInt.zero || rx >= p) return false;

    // Lift x to point P (even y)
    final px = BigInt.parse(pubkeyHex, radix: 16);
    if (px == BigInt.zero || px >= p) return false;
    final py2 = (px.modPow(BigInt.from(3), p) + BigInt.from(7)) % p;
    final py = py2.modPow((p + BigInt.one) ~/ BigInt.from(4), p);
    // Verify the lifted y is actually a square root (point is on the curve)
    if ((py * py) % p != py2) return false;
    final useY = py.isEven ? py : p - py;
    final P = _secp256k1.curve.createPoint(px, useY);

    // Reject identity point and small-order / invalid subgroup points
    if (P.isInfinity) return false;
    final nP = P * n;
    if (nP == null || !nP.isInfinity) return false;

    final msgBytes = hex.decode(id);
    final pubBytes = hex.decode(pubkeyHex);
    final rxBytes = sigBytes.sublist(0, 32);
    final eBytes = _taggedHash(
        'BIP0340/challenge', [...rxBytes, ...pubBytes, ...msgBytes]);
    final e = BigInt.parse(hex.encode(eBytes), radix: 16) % n;

    // R = s*G - e*P
    final sG = G * s;
    final negE = n - e;
    final eP = P * negE;
    final R = sG! + eP!;
    if (R == null || R.isInfinity) return false;
    if (R.y!.toBigInteger()!.isOdd) return false;
    return R.x!.toBigInteger() == rx;
  } catch (_) {
    return false;
  }
}

/// Generate a random 32-byte hex private key.
String generateRandomPrivkey() {
  final rng = Random.secure();
  return hex.encode(Uint8List.fromList(List.generate(32, (_) => rng.nextInt(256))));
}
