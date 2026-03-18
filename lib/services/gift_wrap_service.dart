import 'dart:convert';
import 'dart:math';
import '../adapters/nostr_adapter.dart' show computeEcdhSecret;
import 'nip44_service.dart' as nip44;
import 'nostr_event_builder.dart' as eb;

/// NIP-59 Gift Wrap: triple-layer encryption for metadata-private Nostr events.
///
/// Wrap flow:
///   1. Inner event = real kind event, signed by sender
///   2. Seal (kind:13) = NIP-44-encrypt(innerJSON, sender→recipient), signed by sender
///   3. Gift Wrap (kind:1059) = NIP-44-encrypt(sealJSON, ephemeral→recipient),
///      signed by ephemeral key, randomized timestamp ±2 hours
///
/// Unwrap flow:
///   1. Decrypt kind:1059 content with our privkey + event.pubkey (ephemeral)
///   2. Parse seal (kind:13), decrypt content with our privkey + seal.pubkey
///   3. Verify inner event Schnorr signature
///   4. Return inner event for dispatch

/// Wrap an inner event in a Gift Wrap envelope.
///
/// [senderPrivkey]: hex sender private key (signs inner + seal)
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
  final innerEvent = eb.buildEvent(
    privkeyHex: senderPrivkey,
    kind: innerKind,
    content: innerContent,
    tags: innerTags,
  );

  // 2. Seal (kind:13): NIP-44 encrypt inner event JSON, signed by sender
  final innerJson = jsonEncode(innerEvent);
  final sealSharedX = computeEcdhSecret(senderPrivkey, recipientPubkey);
  final sealContent = await nip44.nip44Encrypt(sealSharedX, innerJson);
  final sealEvent = eb.buildEvent(
    privkeyHex: senderPrivkey,
    kind: 13,
    content: sealContent,
    tags: [],
  );

  // 3. Gift Wrap (kind:1059): NIP-44 encrypt seal JSON with ephemeral key
  final ephemeralPrivkey = eb.generateRandomPrivkey();
  final sealJson = jsonEncode(sealEvent);
  final wrapSharedX = computeEcdhSecret(ephemeralPrivkey, recipientPubkey);
  final wrapContent = await nip44.nip44Encrypt(wrapSharedX, sealJson);

  // Randomize timestamp ±2 hours for metadata privacy
  final rng = Random.secure();
  final jitter = rng.nextInt(14400) - 7200; // ±2 hours in seconds
  final ts = DateTime.now().millisecondsSinceEpoch ~/ 1000 + jitter;

  final wrapEvent = eb.buildEvent(
    privkeyHex: ephemeralPrivkey,
    kind: 1059,
    content: wrapContent,
    tags: [['p', recipientPubkey]],
    createdAt: ts,
  );

  return wrapEvent;
}

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

    final ephemeralPubkey = wrapEvent['pubkey'] as String? ?? '';
    final wrapContent = wrapEvent['content'] as String? ?? '';
    if (ephemeralPubkey.isEmpty || wrapContent.isEmpty) return null;

    // 1. Decrypt Gift Wrap → Seal
    final wrapSharedX = computeEcdhSecret(recipientPrivkey, ephemeralPubkey);
    final sealJson = await nip44.nip44Decrypt(wrapSharedX, wrapContent);
    final sealEvent = jsonDecode(sealJson) as Map<String, dynamic>;

    final sealKind = sealEvent['kind'] as int?;
    if (sealKind != 13) return null;

    // 2. Decrypt Seal → Inner event
    final sealPubkey = sealEvent['pubkey'] as String? ?? '';
    final sealContent = sealEvent['content'] as String? ?? '';
    if (sealPubkey.isEmpty || sealContent.isEmpty) return null;

    final sealSharedX = computeEcdhSecret(recipientPrivkey, sealPubkey);
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
