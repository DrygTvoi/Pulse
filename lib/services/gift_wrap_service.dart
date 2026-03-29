import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../adapters/nostr_adapter.dart' show computeEcdhSecretAsync;
import 'nip44_service.dart' as nip44;
import 'nostr_event_builder.dart' as eb;

/// NIP-59 Gift Wrap: triple-layer encryption for metadata-private Nostr events.
///
/// Wrap flow:
///   1. Inner event = real kind event, signed by sender
///   2. Seal (kind:13) = NIP-44-encrypt(innerJSON, ephemeralSeal→recipient), signed by ephemeral seal key
///   3. Gift Wrap (kind:1059) = NIP-44-encrypt(sealJSON, ephemeral→recipient),
///      signed by ephemeral key, randomized timestamp ±1 hour
///
/// Unwrap flow:
///   1. Decrypt kind:1059 content with our privkey + event.pubkey (ephemeral)
///   2. Parse seal (kind:13), decrypt content with our privkey + seal.pubkey
///   3. Verify inner event Schnorr signature
///   4. Return inner event for dispatch

/// Wrap an inner event in a Gift Wrap envelope.
///
/// [senderPrivkey]: hex sender private key (signs inner event only)
/// [recipientPubkey]: hex recipient public key
/// [innerKind]: the real event kind (4, 20000, etc.)
/// [innerContent]: the real event content
/// [innerTags]: optional tags for the inner event
Future<Map<String, dynamic>> wrapEvent({
  required String senderPrivkey,
  required String recipientPubkey,
  required int innerKind,
  required String innerContent,
  List<List<String>>? innerTags,
}) async {
  // 1. Build and sign the inner event
  final innerEvent = await eb.buildEvent(
    privkeyHex: senderPrivkey,
    kind: innerKind,
    content: innerContent,
    tags: innerTags,
  );

  // 2. Seal (kind:13): NIP-44 encrypt inner event JSON with ephemeral key.
  //    Using an ephemeral key for the seal means that even if the sender's
  //    long-term identity key is later compromised, past seals cannot be
  //    decrypted (forward secrecy for the seal layer). The ephemeral pubkey
  //    is placed in the seal event's `pubkey` field so the recipient can
  //    derive the shared secret. The real sender pubkey is in the inner event.
  final innerJson = jsonEncode(innerEvent);
  final ephemeralSealPrivkey = eb.generateRandomPrivkey();
  final sealSharedX = await computeEcdhSecretAsync(ephemeralSealPrivkey, recipientPubkey, context: 'giftwrap');
  final sealContent = await nip44.nip44Encrypt(sealSharedX, innerJson);
  final sealEvent = await eb.buildEvent(
    privkeyHex: ephemeralSealPrivkey,
    kind: 13,
    content: sealContent,
    tags: [],
  );

  // 3. Gift Wrap (kind:1059): NIP-44 encrypt seal JSON with ephemeral key
  final ephemeralPrivkey = eb.generateRandomPrivkey();
  final sealJson = jsonEncode(sealEvent);
  final wrapSharedX = await computeEcdhSecretAsync(ephemeralPrivkey, recipientPubkey, context: 'giftwrap');
  final wrapContent = await nip44.nip44Encrypt(wrapSharedX, sealJson);

  // Randomize timestamp into the past for metadata privacy.
  // NIP-59 recommends ±48 h, but relays reject future timestamps ("created_at
  // too late"), so we jitter only backward (0 to -2 hours). This provides
  // meaningful timing obfuscation while staying within relay acceptance windows.
  final rng = Random.secure();
  final jitter = -(rng.nextInt(7200)); // 0 to -2 hours
  final ts = DateTime.now().millisecondsSinceEpoch ~/ 1000 + jitter;

  final wrapEvent = await eb.buildEvent(
    privkeyHex: ephemeralPrivkey,
    kind: 1059,
    content: wrapContent,
    tags: [['p', recipientPubkey]],
    createdAt: ts,
  );

  return wrapEvent;
}

/// Maximum age of a gift-wrap outer event.
/// NIP-44 nonce cache TTL is 7 days; 14 days gives a safety margin while
/// blocking old archived events that a relay could replay after nonce expiry.
const _kMaxWrapAgeSeconds = 14 * 24 * 3600;

/// Maximum future drift allowed (2 × the ±1 h jitter added at wrap time).
const _kMaxWrapFutureSeconds = 7200;

/// Unwrap a Gift Wrap event (kind:1059).
///
/// Returns the verified inner event, or null if verification fails.
/// [recipientPrivkey]: our hex private key
/// [wrapEvent]: the kind:1059 event from the relay
Future<Map<String, dynamic>?> unwrapEvent({
  required String recipientPrivkey,
  required Map<String, dynamic> wrapEvent,
}) async {
  try {
    final wrapKind = wrapEvent['kind'] as int?;
    if (wrapKind != 1059) return null;

    // Reject events with implausible timestamps.
    // Without this check, a relay can archive kind:1059 events and replay
    // them to a freshly-connected client after the NIP-44 nonce cache (7d)
    // expires, bypassing replay detection entirely.
    final wrapTs = wrapEvent['created_at'] as int?;
    if (wrapTs != null) {
      final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (nowSec - wrapTs > _kMaxWrapAgeSeconds) {
        debugPrint('[GiftWrap] Rejected stale event (age=${nowSec - wrapTs}s)');
        return null;
      }
      if (wrapTs - nowSec > _kMaxWrapFutureSeconds) {
        debugPrint('[GiftWrap] Rejected future-dated event (drift=${wrapTs - nowSec}s)');
        return null;
      }
    }

    final ephemeralPubkey = wrapEvent['pubkey'] as String? ?? '';
    final wrapContent = wrapEvent['content'] as String? ?? '';
    if (ephemeralPubkey.isEmpty || wrapContent.isEmpty) return null;

    // Verify we are the intended recipient via the outer 'p' tag.
    // Prevents relays from replaying gift wraps addressed to other users.
    final ourPubkey = eb.derivePubkeyHex(recipientPrivkey);
    final wrapTags = wrapEvent['tags'] as List? ?? [];
    final isForUs = wrapTags.any((tag) =>
        tag is List && tag.length >= 2 && tag[0] == 'p' && tag[1] == ourPubkey);
    if (!isForUs) {
      debugPrint('[GiftWrap] p-tag mismatch — not addressed to us');
      return null;
    }

    // 1. Decrypt Gift Wrap → Seal
    final wrapSharedX = await computeEcdhSecretAsync(recipientPrivkey, ephemeralPubkey, context: 'giftwrap');
    final sealJson = await nip44.nip44Decrypt(wrapSharedX, wrapContent);
    final sealEvent = jsonDecode(sealJson) as Map<String, dynamic>;

    // Verify seal event signature before trusting its contents
    if (!eb.verifyEventSignature(sealEvent)) {
      debugPrint('[GiftWrap] Seal signature invalid — dropping');
      return null;
    }

    final sealKind = sealEvent['kind'] as int?;
    if (sealKind != 13) return null;

    // 2. Decrypt Seal → Inner event
    final sealPubkey = sealEvent['pubkey'] as String? ?? '';
    final sealContent = sealEvent['content'] as String? ?? '';
    if (sealPubkey.isEmpty || sealContent.isEmpty) return null;

    final sealSharedX = await computeEcdhSecretAsync(recipientPrivkey, sealPubkey, context: 'giftwrap');
    final innerJson = await nip44.nip44Decrypt(sealSharedX, sealContent);
    final innerEvent = jsonDecode(innerJson) as Map<String, dynamic>;

    // 3. Verify inner event Schnorr signature
    if (!eb.verifyEventSignature(innerEvent)) {
      return null;
    }

    return innerEvent;
  } catch (e) {
    return null;
  }
}
