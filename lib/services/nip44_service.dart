import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:cryptography/cryptography.dart' as cryptography;
import 'package:flutter/foundation.dart';
import '../adapters/nostr_adapter.dart' show computeEcdhSecretAsync;
import 'local_storage_service.dart';

/// NIP-44 v2 encryption: XChaCha20 + HMAC-SHA256.
///
/// Uses the `cryptography` package for XChaCha20 and the `crypto` package
/// for HMAC-SHA256. Tracks seen nonces per conversation key to detect replays.

const int _version = 2;
const int _minPadSize = 32;
const int _maxNoncesPerKey = 10000;

/// Global ceiling on total tracked nonces (across all conversation keys).
/// At 80 bytes per nonce-hex entry this caps nonce-cache RAM at ~16 MB.
const int _totalNoncesHardLimit = 200000;

/// When the hard limit is hit, the oldest conversation key is trimmed to this
/// many entries rather than deleted entirely — keeping replay protection for
/// the most-recent messages in that conversation.
const int _minNoncesAfterTrim = 50;

/// Tracks seen nonces per conversation-key to detect replay attacks.
/// Key: conversation key hex string. Value: insertion-ordered set of nonce hex strings.
final Map<String, LinkedHashSet<String>> _seenNonces = {};

/// Total nonce count across all conversation keys. Bounded to prevent unbounded growth.
int _totalNonceCount = 0;

/// Lazy-load state: nonces are loaded from SQLite on the first decrypt call
/// and held in-memory for the session. SQLite write is fire-and-forget.
bool _nonceDbLoaded = false;
Future<void>? _nonceDbLoadFuture;

/// Pending nonce writes batched for efficiency.
final List<(String, String)> _pendingNonceWrites = [];
Timer? _nonceFlushTimer;

/// Flush pending nonces to SQLite.
Future<void> _flushPendingNonces() async {
  _nonceFlushTimer?.cancel();
  _nonceFlushTimer = null;
  if (_pendingNonceWrites.isEmpty) return;
  final batch = List<(String, String)>.from(_pendingNonceWrites);
  _pendingNonceWrites.clear();
  await LocalStorageService().saveNonces(batch);
}

/// Schedule a nonce flush (debounced 500ms).
void _scheduleNonceFlush() {
  _nonceFlushTimer?.cancel();
  _nonceFlushTimer = Timer(const Duration(milliseconds: 500), _flushPendingNonces);
}

/// Load recent nonces (≤ 2 days old) from SQLite into [_seenNonces].
/// Called lazily before the first [nip44Decrypt] to restore replay protection
/// across app restarts. Purges stale entries as a side-effect.
Future<void> _loadNoncesFromDb() async {
  if (_nonceDbLoaded) return;
  _nonceDbLoaded = true;
  try {
    final entries = await LocalStorageService().loadRecentNonces(maxAgeDays: 2);
    for (final (convKey, nonceHex) in entries) {
      final set = _seenNonces.putIfAbsent(convKey, () => LinkedHashSet<String>());
      if (!set.contains(nonceHex)) {
        // Respect per-key cap when importing
        while (set.length >= _maxNoncesPerKey) {
          set.remove(set.first);
          _totalNonceCount--;
        }
        set.add(nonceHex);
        _totalNonceCount++;
      }
    }
    debugPrint('[NIP44] Loaded $_totalNonceCount nonces from DB');
    // Purge rows older than 2 days in the background
    unawaited(LocalStorageService().purgeOldNonces(maxAgeDays: 2));
  } catch (e) {
    debugPrint('[NIP44] Failed to load nonces from DB: $e');
  }
}

/// Check for duplicate nonce and record it. Throws on replay.
Future<void> _checkAndRecordNonce(Uint8List convKey, Uint8List nonce) async {
  final keyHex = hex.encode(convKey);
  final nonceHex = hex.encode(nonce);

  final set = _seenNonces.putIfAbsent(keyHex, () => LinkedHashSet<String>());
  if (set.contains(nonceHex)) {
    throw FormatException('Duplicate nonce — possible replay attack');
  }

  // Evict oldest entries if at capacity
  while (set.length >= _maxNoncesPerKey) {
    set.remove(set.first);
    _totalNonceCount--;
  }
  set.add(nonceHex);
  _totalNonceCount++;
  // Batch nonce writes: debounced flush reduces SQLite round-trips when
  // processing many messages at once (e.g. 50 offline messages → 1 write).
  _pendingNonceWrites.add((keyHex, nonceHex));
  _scheduleNonceFlush();

  // Global safety valve: trim the oldest conversation key rather than deleting
  // it entirely. Deleting would allow replay of any previously-seen nonce in
  // that conversation; trimming to _minNoncesAfterTrim keeps protection for
  // recent messages while still bounding memory.
  if (_totalNonceCount > _totalNoncesHardLimit) {
    // Flush pending writes to DB BEFORE trimming from memory. Without this,
    // nonces that are only in _pendingNonceWrites (not yet on disk) would be
    // silently forgotten if the app crashes after the trim — creating a replay
    // window for those evicted nonces. Must await to guarantee DB commit
    // completes before in-memory eviction.
    await _flushPendingNonces();
    final oldestKey = _seenNonces.keys.first;
    final oldestSet = _seenNonces[oldestKey]!;
    while (oldestSet.length > _minNoncesAfterTrim &&
        _totalNonceCount > _totalNoncesHardLimit) {
      oldestSet.remove(oldestSet.first);
      _totalNonceCount--;
    }
    if (oldestSet.isEmpty) _seenNonces.remove(oldestKey);
  }
}

/// Clear the nonce replay cache (useful for testing or memory pressure).
/// Also purges the SQLite nonce table so replay protection resets cleanly.
void clearNonceCache() {
  _seenNonces.clear();
  _totalNonceCount = 0;
  _nonceDbLoaded = false;
  _nonceDbLoadFuture = null;
  _nonceFlushTimer?.cancel();
  _pendingNonceWrites.clear();
  unawaited(LocalStorageService().purgeOldNonces(maxAgeDays: 0));
}

/// HKDF-extract (RFC 5869): PRK = HMAC-Hash(salt, IKM).
Uint8List _hkdfExtract(Uint8List salt, Uint8List ikm) {
  final hmac = crypto.Hmac(crypto.sha256, salt);
  return Uint8List.fromList(hmac.convert(ikm).bytes);
}

/// HKDF-expand (RFC 5869): OKM = T(1) || T(2) || ... truncated to [length].
Uint8List _hkdfExpand(Uint8List prk, Uint8List info, int length) {
  final n = (length + 31) ~/ 32; // ceil(L / HashLen)
  final okm = BytesBuilder();
  var prev = Uint8List(0);
  for (int i = 1; i <= n; i++) {
    final hmac = crypto.Hmac(crypto.sha256, prk);
    final input = BytesBuilder()
      ..add(prev)
      ..add(info)
      ..add([i]);
    prev = Uint8List.fromList(hmac.convert(input.toBytes()).bytes);
    okm.add(prev);
  }
  return Uint8List.sublistView(okm.toBytes(), 0, length);
}

/// Step 1: Compute conversation key from ECDH shared secret.
/// convKey = HKDF-extract(salt="nip44-v2", ikm=sharedX)
Uint8List computeConversationKey(Uint8List sharedX) {
  final salt = Uint8List.fromList(utf8.encode('nip44-v2'));
  return _hkdfExtract(salt, sharedX);
}

/// Step 2: Derive per-message keys from conversation key + nonce.
/// Returns (chachaKey[32], chachaNonce[24], hmacKey[32]).
({Uint8List chachaKey, Uint8List chachaNonce, Uint8List hmacKey})
    deriveMessageKeys(Uint8List convKey, Uint8List nonce) {
  final expanded = _hkdfExpand(convKey, nonce, 88);
  return (
    chachaKey: Uint8List.sublistView(expanded, 0, 32),
    chachaNonce: Uint8List.sublistView(expanded, 32, 56),
    hmacKey: Uint8List.sublistView(expanded, 56, 88),
  );
}

/// Calculates the padded length per NIP-44 v2 specification.
int _calcPaddedLen(int unpaddedLen) {
  if (unpaddedLen <= 32) return 32;
  final nextPower = 1 << (unpaddedLen - 1).bitLength; // next power of 2 >= unpaddedLen
  final chunk = nextPower <= 256 ? 32 : nextPower ~/ 8;
  return chunk * ((unpaddedLen - 1) ~/ chunk + 1);
}

/// Step 3: Pad plaintext per NIP-44 spec.
/// Format: 2-byte BE length prefix + content + zero-pad per _calcPaddedLen.
Uint8List nip44Pad(String plaintext) {
  final content = utf8.encode(plaintext);
  final contentLen = content.length;
  if (contentLen < 1 || contentLen > 65535) {
    throw ArgumentError('NIP-44: plaintext must be 1-65535 bytes');
  }

  // Calculate padded size using NIP-44 v2 spec algorithm.
  // The 2-byte prefix is included in the padded block size calculation.
  final paddedLen = _calcPaddedLen(2 + contentLen);

  final result = Uint8List(paddedLen);
  // 2-byte big-endian length prefix
  result[0] = (contentLen >> 8) & 0xFF;
  result[1] = contentLen & 0xFF;
  // Copy content after prefix; rest is already zeros
  result.setRange(2, 2 + contentLen, content);
  return result;
}

/// Unpad NIP-44 padded plaintext.
String nip44Unpad(Uint8List padded) {
  if (padded.length < _minPadSize) {
    throw FormatException('NIP-44: padded data too short');
  }
  final contentLen = (padded[0] << 8) | padded[1];
  if (contentLen < 1 || contentLen > padded.length - 2) {
    throw FormatException('NIP-44: invalid content length in padding');
  }
  return utf8.decode(padded.sublist(2, 2 + contentLen));
}

/// Step 4: Encrypt plaintext with NIP-44 v2.
/// Returns base64(0x02 || nonce[32] || ciphertext || mac[32]).
Future<String> nip44Encrypt(Uint8List sharedX, String plaintext) async {
  final convKey = computeConversationKey(sharedX);
  final rng = Random.secure();
  final nonce = Uint8List.fromList(List.generate(32, (_) => rng.nextInt(256)));

  final keys = deriveMessageKeys(convKey, nonce);
  final padded = nip44Pad(plaintext);

  // XChaCha20 encrypt (no built-in MAC — we do HMAC separately)
  final algo = cryptography.Xchacha20(macAlgorithm: cryptography.MacAlgorithm.empty);
  final secretKey = cryptography.SecretKey(keys.chachaKey);
  final secretBox = await algo.encrypt(
    padded,
    secretKey: secretKey,
    nonce: keys.chachaNonce,
  );
  final ct = Uint8List.fromList(secretBox.cipherText);

  // HMAC-SHA256(hmacKey, nonce || ciphertext)
  final hmac = crypto.Hmac(crypto.sha256, keys.hmacKey);
  final macInput = BytesBuilder()
    ..add(nonce)
    ..add(ct);
  final mac = Uint8List.fromList(hmac.convert(macInput.toBytes()).bytes);

  // Assemble: version || nonce || ct || mac
  final payload = BytesBuilder()
    ..addByte(_version)
    ..add(nonce)
    ..add(ct)
    ..add(mac);
  return base64.encode(payload.toBytes());
}

/// Step 5: Decrypt NIP-44 v2 payload.
Future<String> nip44Decrypt(Uint8List sharedX, String payload) async {
  final raw = base64.decode(payload);
  if (raw.length < 1 + 32 + _minPadSize + 32) {
    throw FormatException('NIP-44: payload too short');
  }

  final version = raw[0];
  if (version != _version) {
    throw FormatException('NIP-44: unsupported version $version');
  }

  final nonce = Uint8List.sublistView(raw, 1, 33);
  final ct = Uint8List.sublistView(raw, 33, raw.length - 32);
  final mac = Uint8List.sublistView(raw, raw.length - 32);

  final convKey = computeConversationKey(sharedX);

  // Ensure nonces from previous sessions are loaded before checking.
  // The Future is cached so this only runs once per app lifetime.
  _nonceDbLoadFuture ??= _loadNoncesFromDb();
  await _nonceDbLoadFuture;

  final keys = deriveMessageKeys(convKey, nonce);

  // Verify HMAC BEFORE recording nonce — F2-1: prevents nonce slot exhaustion
  // by forged ciphertexts with fresh random nonces.
  final hmac = crypto.Hmac(crypto.sha256, keys.hmacKey);
  final macInput = BytesBuilder()
    ..add(nonce)
    ..add(ct);
  final expected = Uint8List.fromList(hmac.convert(macInput.toBytes()).bytes);

  // Constant-time comparison
  if (expected.length != mac.length) {
    throw FormatException('NIP-44: MAC verification failed');
  }
  int cmp = 0;
  for (int i = 0; i < expected.length; i++) {
    cmp |= expected[i] ^ mac[i];
  }
  if (cmp != 0) {
    throw FormatException('NIP-44: MAC verification failed');
  }

  // Replay detection: only record nonce after authentication succeeds
  await _checkAndRecordNonce(convKey, nonce);

  // Decrypt
  final algo = cryptography.Xchacha20(macAlgorithm: cryptography.MacAlgorithm.empty);
  final secretKey = cryptography.SecretKey(keys.chachaKey);
  final secretBox = cryptography.SecretBox(
    ct,
    nonce: keys.chachaNonce,
    mac: cryptography.Mac.empty,
  );
  final plainBytes = await algo.decrypt(secretBox, secretKey: secretKey);
  return nip44Unpad(Uint8List.fromList(plainBytes));
}

// ── Convenience wrappers using Nostr keypairs ──────────────

/// Encrypt with NIP-44 using hex-encoded Nostr private/public keys.
Future<String> nip44EncryptWithKeys(
    String privHex, String pubHex, String text) async {
  final sharedX = await computeEcdhSecretAsync(privHex, pubHex, context: 'nip44');
  return nip44Encrypt(sharedX, text);
}

/// Decrypt NIP-44 payload using hex-encoded Nostr private/public keys.
Future<String> nip44DecryptWithKeys(
    String privHex, String pubHex, String payload) async {
  final sharedX = await computeEcdhSecretAsync(privHex, pubHex, context: 'nip44');
  return nip44Decrypt(sharedX, payload);
}
