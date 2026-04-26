import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contact.dart';
import '../adapters/inbox_manager.dart';
import '../adapters/firebase_adapter.dart';
import '../adapters/nostr_adapter.dart';
import '../adapters/session_adapter.dart';
import '../adapters/pulse_adapter.dart';
import '../constants.dart';
import 'signal_service.dart';
import 'pqc_service.dart';
import 'crypto_layer.dart';

/// Manages cryptographic keys:
/// - PQC (Kyber-1024) per-contact key cache
/// - Signal bundle publishing / republishing
/// - HMAC-SHA256 payload signing (ECDH-based)
/// - Pubkey extraction helpers
class KeyManager {
  final SignalService _signalService;
  final PqcService _pqcService;
  static const _secureStorage = FlutterSecureStorage();
  static const _kDefaultNostrRelay = kDefaultNostrRelay;

  // In-memory PQC key cache: contactId → Kyber-1024 public key
  // LinkedHashMap preserves insertion order for oldest-first eviction.
  static const _kyberCacheMaxSize = 2000;
  final LinkedHashMap<String, Uint8List> _contactKyberPks =
      LinkedHashMap<String, Uint8List>();

  KeyManager(this._signalService, this._pqcService);

  // ── PQC key helpers ──────────────────────────────────────────────────────

  /// Cache a contact's Kyber public key from their Signal bundle.
  void cacheContactKyberPk(String contactId, Map<String, dynamic> bundle) {
    final kyberPkList = bundle['kyberPublicKey'];
    if (kyberPkList == null) return;
    try {
      final pk = Uint8List.fromList(List<int>.from(kyberPkList));
      // ML-KEM-1024 public key is always 1568 bytes — reject anything else to
      // prevent a malicious relay from injecting a wrong-sized key that would
      // crash encapsulate() and DoS outbound messages to this contact.
      if (pk.length != 1568) {
        debugPrint('[KeyManager] Rejected invalid Kyber PK for $contactId: ${pk.length} bytes (expected 1568)');
        return;
      }
      _contactKyberPks[contactId] = pk;
      if (_contactKyberPks.length > _kyberCacheMaxSize) {
        _contactKyberPks.remove(_contactKyberPks.keys.first);
      }
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('pqc_contact_pk_$contactId', base64Encode(pk));
      });
    } catch (e) {
      debugPrint('[KeyManager] Failed to cache kyber pk for $contactId: $e');
    }
  }

  /// True if a Kyber public key is cached for this contact (in-memory only).
  bool hasPqcKey(String contactId) =>
      _contactKyberPks.containsKey(contactId);

  /// Async variant: checks in-memory cache first, then SharedPreferences.
  Future<bool> hasPqcKeyAsync(String contactId) async {
    if (_contactKyberPks.containsKey(contactId)) return true;
    final pk = await loadContactKyberPk(contactId);
    return pk != null;
  }

  /// Remove a cached Kyber pk (e.g. after PQC unwrap failure).
  void clearContactKyberPk(String contactId) {
    _contactKyberPks.remove(contactId);
    final pub = contactId.split('@').first;
    _contactKyberPks.removeWhere((k, _) => k.split('@').first == pub);
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('pqc_contact_pk_$contactId');
    });
  }

  /// Load contact's Kyber pk: in-memory first, then SharedPreferences.
  Future<Uint8List?> loadContactKyberPk(String contactId) async {
    if (_contactKyberPks.containsKey(contactId)) {
      return _contactKyberPks[contactId];
    }
    final prefs = await SharedPreferences.getInstance();
    final b64 = prefs.getString('pqc_contact_pk_$contactId');
    if (b64 == null) return null;
    final pk = base64Decode(b64);
    // ML-KEM-1024 public key is always 1568 bytes — reject stored keys that
    // don't match to stay consistent with cacheContactKyberPk validation.
    if (pk.length != 1568) {
      debugPrint('[KeyManager] Rejected stored Kyber PK for $contactId: ${pk.length} bytes');
      return null;
    }
    _contactKyberPks[contactId] = pk;
    if (_contactKyberPks.length > _kyberCacheMaxSize) {
      _contactKyberPks.remove(_contactKyberPks.keys.first);
    }
    return pk;
  }

  /// Wrap a Signal ciphertext with the PQC hybrid layer for [contactId].
  /// No-op if no Kyber key is available.
  Future<String> pqcWrap(String signalCt, String contactId) async {
    final pk = await loadContactKyberPk(contactId);
    return await CryptoLayer.wrap(signalCt, pk);
  }

  // ── Key publishing ───────────────────────────────────────────────────────

  /// Publish Signal+PQC bundle to own inbox on every app start.
  ///
  /// Always publishes (not "maybe") because Signal keys may have been
  /// regenerated after account restore / reinstall while the relay still
  /// holds the stale bundle.  Cost: one replaceable Nostr event per start.
  Future<void> maybePublishOwnKeys(
      String preferredAdapter, String selfId, String adapterApiKey) async {
    if (selfId.isEmpty) return;
    await publishOwnKeys(preferredAdapter, adapterApiKey, selfId);
  }

  /// Build our current public Signal+PQC bundle for direct delivery (e.g.
  /// pushing to a contact whose session just broke). Same shape as the one
  /// published via `publishOwnKeys`.
  Future<Map<String, dynamic>> buildOwnBundle() async {
    final bundle = await _signalService.getPublicBundle();
    if (_pqcService.isInitialized) {
      bundle['kyberPublicKey'] = _pqcService.publicKey.toList();
    }
    return bundle;
  }

  /// Publish Signal+PQC public bundle to own inbox.
  /// For Nostr: publishes to up to 3 known relays for redundancy.
  Future<void> publishOwnKeys(
      String provider, String apiKey, String selfId) async {
    if (selfId.isEmpty) return;
    try {
      final bundle = await _signalService.getPublicBundle();
      if (_pqcService.isInitialized) {
        bundle['kyberPublicKey'] = _pqcService.publicKey.toList();
      }
      switch (provider.toLowerCase()) {
        case 'firebase':
          final sender = FirebaseInboxSender();
          await sender.initializeSender(apiKey);
          await sender.sendSignal(selfId, selfId, selfId, 'sys_keys', bundle);
          debugPrint('[KeyManager] Published Signal keys for Firebase/$selfId');
        case 'nostr':
          final privkey =
              await _secureStorage.read(key: 'nostr_privkey') ?? '';
          if (privkey.isEmpty) return;
          final primaryRelay = _kDefaultNostrRelay;
          final relays = await gatherKnownRelays(primaryRelay, limit: 5);
          for (final relay in relays) {
            try {
              final sender = NostrMessageSender();
              final senderApiKey = jsonEncode({'privkey': privkey, 'relay': relay});
              await sender.initializeSender(senderApiKey);
              await sender.sendSignal(selfId, selfId, selfId, 'sys_keys', bundle);
              debugPrint('[KeyManager] Published Signal keys to $relay');
            } catch (e) {
              debugPrint('[KeyManager] Key publish to $relay failed: $e');
            }
          }
        case 'session':
          final sender = SessionMessageSender();
          final prefs = await SharedPreferences.getInstance();
          final senderApiKey = prefs.getString('session_node_url') ?? prefs.getString('oxen_node_url') ?? '';
          await sender.initializeSender(senderApiKey);
          await sender.sendSignal(selfId, selfId, selfId, 'sys_keys', bundle);
          debugPrint('[KeyManager] Published Signal keys for Session/$selfId');
        default:
          return;
      }
    } catch (e) {
      debugPrint('[KeyManager] Key publishing failed: $e');
    }
  }

  /// Clear the published flag so next [maybePublishOwnKeys] call re-publishes.
  Future<void> clearPublishedFlag(
      String preferredAdapter, String selfId) async {
    final prefs = await SharedPreferences.getInstance();
    final flag = 'signal_keys_published_${preferredAdapter}_$selfId';
    await prefs.remove(flag);
  }

  /// Re-publish bundle to a specific secondary adapter.
  Future<void> publishKeysToAdapter(
      String provider, String apiKey, String selfId) async {
    if (selfId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final flag = 'signal_keys_published_${provider.toLowerCase()}_$selfId';
      // Always re-publish Session keys (storage servers expire data).
      // Other adapters: publish once.
      if (provider != 'Session' && prefs.getBool(flag) == true) return;
      final bundle = await _signalService.getPublicBundle();
      if (_pqcService.isInitialized) {
        bundle['kyberPublicKey'] = _pqcService.publicKey.toList();
      }
      MessageSender sender;
      if (provider == 'Firebase') {
        sender = FirebaseInboxSender();
      } else if (provider == 'Nostr') {
        try {
          final cfg = jsonDecode(apiKey);
          if ((cfg['privkey'] as String? ?? '').isEmpty) return;
        } catch (e) {
          debugPrint('[KeyManager] publishKeysToAdapter: malformed Nostr config: $e');
          return;
        }
        sender = NostrMessageSender();
      } else if (provider == 'Session') {
        sender = SessionMessageSender();
      } else if (provider == 'Pulse') {
        // Pulse uses the same key-derivation seed across servers, but each
        // server holds its own key store — peers fetching our bundle from
        // a particular `serverUrl` need it to have been published THERE.
        // Used by `ensureGroupPulseConnection` so pulse-group peers can
        // bootstrap their Signal session against us via the host server.
        sender = PulseMessageSender();
      } else {
        return;
      }
      await sender.initializeSender(apiKey);
      await sender.sendSignal(selfId, selfId, selfId, 'sys_keys', bundle);
      await prefs.setBool(flag, true);
      debugPrint('[KeyManager] Published Signal keys to secondary $provider/$selfId');
    } catch (e) {
      debugPrint('[KeyManager] Secondary key publish failed: $e');
    }
  }

  /// Push our own Signal bundle to [contact]'s Session inbox (in-band key exchange).
  Future<void> publishSessionKeysTo(Contact contact, String selfId) async {
    if (selfId.isEmpty) return;
    try {
      final bundle = await _signalService.getPublicBundle();
      if (_pqcService.isInitialized) {
        bundle['kyberPublicKey'] = _pqcService.publicKey.toList();
      }
      final prefs = await SharedPreferences.getInstance();
      final nodeUrl = prefs.getString('session_node_url') ?? prefs.getString('oxen_node_url') ?? '';
      final sender = SessionMessageSender();
      await sender.initializeSender(nodeUrl);
      await sender.sendSignal(
          contact.databaseId, contact.databaseId, selfId, 'sys_keys', bundle);
    } catch (e) {
      debugPrint('[KeyManager] Session key push to ${contact.name} failed: $e');
    }
  }

  // ── HMAC signing ─────────────────────────────────────────────────────────

  /// Compute HMAC-SHA256 over signal payload using ECDH shared secret.
  /// Returns the original payload enriched with `_sig` and `_spk` fields.
  Future<Map<String, dynamic>> signPayload(
      Contact contact,
      String type,
      Map<String, dynamic> payload,
      String? selfPubkey) async {
    try {
      final privkey =
          await _secureStorage.read(key: 'nostr_privkey') ?? '';
      if (privkey.isEmpty) return payload;
      final recipientPub = extractPubkey(contact.databaseId, [contact]);
      if (recipientPub == null) {
        debugPrint('[KeyManager] HMAC sign: no recipientPub for ${contact.databaseId.substring(0, 12)}…');
        return payload;
      }
      final senderPub = selfPubkey ?? deriveNostrPubkeyHex(privkey);
      final canonical = jsonEncode({'t': type, 'p': payload});
      final hmac = signSignalPayload(privkey, recipientPub, canonical);
      return {...payload, '_sig': hmac, '_spk': senderPub};
    } catch (e) {
      debugPrint('[KeyManager] Signal sign error: $e');
      return payload;
    }
  }

  /// Verify HMAC-SHA256 signature on an incoming signal payload.
  Future<bool> verifySignalSignature(
      String type, Map<String, dynamic> payload, String hmac,
      String senderPub) async {
    try {
      final privkey =
          await _secureStorage.read(key: 'nostr_privkey') ?? '';
      // Empty privkey must REJECT, not accept all signatures.
      // Returning true here would let any forged signal pass after key loss.
      if (privkey.isEmpty) {
        debugPrint('[KeyManager] HMAC verify: no privkey — rejecting $type');
        return false;
      }
      final cleanPayload = Map<String, dynamic>.from(payload)
        ..remove('_sig')
        ..remove('_spk');
      final canonical = jsonEncode({'t': type, 'p': cleanPayload});
      return verifySignalPayload(privkey, senderPub, canonical, hmac);
    } catch (e) {
      debugPrint('[KeyManager] Signature verification error: $e');
      return false;
    }
  }

  // ── Pubkey extraction ────────────────────────────────────────────────────

  /// Extract Nostr pubkey from any address format.
  static final _hex64 = RegExp(r'^[0-9a-f]{64}$');

  /// Extract a Nostr secp256k1 pubkey (64-char hex) from a contact address.
  /// Prefers Nostr relay addresses (@wss://@ws://) since those are guaranteed
  /// secp256k1 keys. Pulse addresses may use a different key scheme.
  String? extractPubkey(String databaseId, List<Contact> contacts) {
    // 1. Direct Nostr format: pubkey@wss://relay or pubkey@ws://relay
    String? _fromNostrAddr(String addr) {
      final wss = addr.indexOf('@wss://');
      final ws = wss == -1 ? addr.indexOf('@ws://') : -1;
      final at = wss != -1 ? wss : ws;
      if (at > 0) {
        final pub = addr.substring(0, at);
        if (_hex64.hasMatch(pub)) return pub;
      }
      return null;
    }

    // Try the provided address directly (Nostr format)
    final direct = _fromNostrAddr(databaseId);
    if (direct != null) return direct;

    // Raw 64-char hex pubkey
    if (_hex64.hasMatch(databaseId)) return databaseId;

    // Look up contact and search Nostr addresses first
    final contact = contacts.cast<Contact?>().firstWhere(
          (c) => c?.databaseId == databaseId,
          orElse: () => null,
        );
    if (contact == null) return null;

    // Priority 1: Nostr transport addresses (guaranteed secp256k1)
    for (final addr in contact.transportAddresses['Nostr'] ?? <String>[]) {
      final pub = _fromNostrAddr(addr);
      if (pub != null) return pub;
    }

    // Priority 2: Any other address with @wss:// or @ws://
    for (final addrs in contact.transportAddresses.values) {
      for (final addr in addrs) {
        final pub = _fromNostrAddr(addr);
        if (pub != null) return pub;
      }
    }

    // Priority 3: Contact's stored Nostr pubkey (from addr_update payload)
    if (contact.publicKey.isNotEmpty && _hex64.hasMatch(contact.publicKey)) {
      return contact.publicKey;
    }

    return null;
  }
}
