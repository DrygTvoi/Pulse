import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/contact.dart';
import '../models/user_status.dart';
import '../services/rate_limiter.dart';

// ── Event types emitted by SignalDispatcher ─────────────────────────────────

/// Raw signal forwarded verbatim (for active-call routing).
class SignalRawEvent {
  final Map<String, dynamic> signal;
  SignalRawEvent(this.signal);
}

/// Incoming 1-on-1 call offer.
class SignalIncomingCallEvent {
  final Map<String, dynamic> signal;
  SignalIncomingCallEvent(this.signal);
}

/// Incoming group call offer (carries groupId and isVideoCall flag).
class SignalIncomingGroupCallEvent {
  final Map<String, dynamic> signal;
  final String groupId;
  final bool isVideoCall;
  SignalIncomingGroupCallEvent(this.signal, this.groupId, {this.isVideoCall = true});
}

/// Contact started typing (optionally in a group room).
class SignalTypingEvent {
  final Contact contact;
  final String? groupId;
  SignalTypingEvent(this.contact, {this.groupId});
}

/// Read receipt (1-on-1).
class SignalReadReceiptEvent {
  final String fromId;
  SignalReadReceiptEvent(this.fromId);
}

/// Group read receipt.
class SignalGroupReadReceiptEvent {
  final String fromId;
  final String groupId;
  final String msgId;
  SignalGroupReadReceiptEvent(this.fromId, this.groupId, this.msgId);
}

/// Delivery acknowledgment.
class SignalDeliveryAckEvent {
  final String fromId;
  final String msgId;
  final String? groupId;
  SignalDeliveryAckEvent(this.fromId, this.msgId, {this.groupId});
}

/// TTL update from contact.
class SignalTtlUpdateEvent {
  final Contact contact;
  final int seconds;
  SignalTtlUpdateEvent(this.contact, this.seconds);
}

/// Reaction on a message.
class SignalReactionEvent {
  final String storageKey;
  final String msgId;
  final String emoji;
  final String from;
  final bool remove;
  SignalReactionEvent({
    required this.storageKey,
    required this.msgId,
    required this.emoji,
    required this.from,
    required this.remove,
  });
}

/// Message edit.
class SignalEditEvent {
  final Contact contact;
  final String msgId;
  final String text;
  final String? groupId;
  SignalEditEvent(this.contact, this.msgId, this.text, {this.groupId});
}

/// Remote-side delete request for a specific message.
class SignalMsgDeleteEvent {
  final String msgId;
  final String? groupId;
  final String fromId;
  SignalMsgDeleteEvent(this.fromId, this.msgId, {this.groupId});
}

/// Group invite was declined by the recipient.
class SignalGroupInviteDeclineEvent {
  final Contact fromContact;
  final String groupId;
  SignalGroupInviteDeclineEvent(this.fromContact, this.groupId);
}

/// Heartbeat (online status).
class SignalHeartbeatEvent {
  final Contact contact;
  SignalHeartbeatEvent(this.contact);
}

/// Remote key bundle received.
class SignalKeysEvent {
  final Contact contact;
  final Map<String, dynamic> payload;
  SignalKeysEvent(this.contact, this.payload);
}

/// P2P signaling (WebRTC DataChannel).
class SignalP2PEvent {
  final Contact contact;
  final String type;
  final Map<String, dynamic> payload;
  SignalP2PEvent(this.contact, this.type, this.payload);
}

/// Peer relay exchange.
class SignalRelayExchangeEvent {
  final List<String> relays;
  SignalRelayExchangeEvent(this.relays);
}

/// Peer TURN server exchange (sent when a call connects via TURN).
class SignalTurnExchangeEvent {
  final List<Map<String, dynamic>> servers;
  SignalTurnExchangeEvent(this.servers);
}

/// Peer Blossom server exchange.
class SignalBlossomExchangeEvent {
  final List<String> servers;
  SignalBlossomExchangeEvent(this.servers);
}

/// Status/story update from contact.
class SignalStatusUpdateEvent {
  final Contact contact;
  final UserStatus status;
  SignalStatusUpdateEvent(this.contact, this.status);
}

/// Address migration update.
class SignalAddrUpdateEvent {
  final Contact contact;
  final String primary;
  final List<String> all;
  SignalAddrUpdateEvent(this.contact, this.primary, this.all);
}

/// Profile update from contact.
class SignalProfileUpdateEvent {
  final Contact contact;
  final String about;
  final String avatarB64;
  SignalProfileUpdateEvent(this.contact, this.about, this.avatarB64);
}

/// Chunk re-request from receiver.
class SignalChunkReqEvent {
  final String fid;
  final List<int> missing;
  final String senderId;
  SignalChunkReqEvent(this.fid, this.missing, this.senderId);
}

/// Sender key distribution for group E2EE.
class SignalSenderKeyDistEvent {
  final Contact fromContact;
  final String groupId;
  final String skdmB64;
  SignalSenderKeyDistEvent(this.fromContact, this.groupId, this.skdmB64);
}

/// Group invite from a known contact — receiver can accept or decline.
class SignalGroupInviteEvent {
  final Contact fromContact;
  final String groupId;
  final String groupName;
  final List<String> members;
  final String? creatorId;
  SignalGroupInviteEvent(this.fromContact, this.groupId, this.groupName, this.members, {this.creatorId});
}

/// Group membership change broadcast by group admin.
class SignalGroupUpdateEvent {
  final String groupId;
  final String groupName;
  final List<String> members;
  final String? creatorId;
  final String senderId;
  SignalGroupUpdateEvent(this.groupId, this.groupName, this.members,
      {this.creatorId, this.senderId = ''});
}

// ── Callbacks for operations the dispatcher cannot do on its own ────────────

/// Signature verifier: returns true if HMAC is valid.
typedef SignatureVerifier = Future<bool> Function(
    String type, Map<String, dynamic> payload, String hmac, String senderPub);

/// Contact index builder: returns {databaseId|idPart → Contact}.
typedef ContactIndexBuilder = Map<String, Contact> Function();

/// Resolves a group contact by its UUID. Returns null if not found.
typedef GroupContactResolver = Contact? Function(String groupId);

// ── SignalDispatcher ────────────────────────────────────────────────────────

/// Extracts the signal-dispatching logic from ChatController into a
/// standalone, testable class. Emits typed events via streams so that
/// ChatController (or any subscriber) can react to them without coupling.
class SignalDispatcher {
  SignalDispatcher({
    required List<String> Function() allAddressesGetter,
    required String Function() selfIdGetter,
    required ContactIndexBuilder contactIndexBuilder,
    required SignatureVerifier signatureVerifier,
    required GroupContactResolver groupContactResolver,
    RateLimiter? rateLimiter,
  })  : _allAddressesGetter = allAddressesGetter,
        _selfIdGetter = selfIdGetter,
        _contactIndexBuilder = contactIndexBuilder,
        _verifySignature = signatureVerifier,
        _resolveGroupContact = groupContactResolver,
        _sigRateLimiter = rateLimiter ??
            RateLimiter(maxTokens: 20, refillInterval: Duration(seconds: 3));

  final List<String> Function() _allAddressesGetter;
  final String Function() _selfIdGetter;
  final ContactIndexBuilder _contactIndexBuilder;
  final SignatureVerifier _verifySignature;
  final GroupContactResolver _resolveGroupContact;
  final RateLimiter _sigRateLimiter;
  // Separate limiter for webrtc offer/answer — 6 per minute per sender.
  final RateLimiter _webrtcRateLimiter =
      RateLimiter(maxTokens: 6, refillInterval: Duration(seconds: 10));

  // ── Streams ──────────────────────────────────────────────────────────────
  final _rawCtrl = StreamController<SignalRawEvent>.broadcast();
  final _incomingCallCtrl = StreamController<SignalIncomingCallEvent>.broadcast();
  final _incomingGroupCallCtrl = StreamController<SignalIncomingGroupCallEvent>.broadcast();
  final _typingCtrl = StreamController<SignalTypingEvent>.broadcast();
  final _readReceiptCtrl = StreamController<SignalReadReceiptEvent>.broadcast();
  final _groupReadReceiptCtrl = StreamController<SignalGroupReadReceiptEvent>.broadcast();
  final _deliveryAckCtrl = StreamController<SignalDeliveryAckEvent>.broadcast();
  final _ttlUpdateCtrl = StreamController<SignalTtlUpdateEvent>.broadcast();
  final _reactionCtrl = StreamController<SignalReactionEvent>.broadcast();
  final _editCtrl = StreamController<SignalEditEvent>.broadcast();
  final _heartbeatCtrl = StreamController<SignalHeartbeatEvent>.broadcast();
  final _keysCtrl = StreamController<SignalKeysEvent>.broadcast();
  final _p2pCtrl = StreamController<SignalP2PEvent>.broadcast();
  final _relayExchangeCtrl = StreamController<SignalRelayExchangeEvent>.broadcast();
  final _turnExchangeCtrl  = StreamController<SignalTurnExchangeEvent>.broadcast();
  final _blossomExchangeCtrl = StreamController<SignalBlossomExchangeEvent>.broadcast();
  final _statusUpdateCtrl = StreamController<SignalStatusUpdateEvent>.broadcast();
  final _addrUpdateCtrl = StreamController<SignalAddrUpdateEvent>.broadcast();
  final _profileUpdateCtrl = StreamController<SignalProfileUpdateEvent>.broadcast();
  final _chunkReqCtrl = StreamController<SignalChunkReqEvent>.broadcast();
  final _groupUpdateCtrl = StreamController<SignalGroupUpdateEvent>.broadcast();
  final _groupInviteCtrl = StreamController<SignalGroupInviteEvent>.broadcast();
  final _msgDeleteCtrl = StreamController<SignalMsgDeleteEvent>.broadcast();
  final _groupInviteDeclineCtrl =
      StreamController<SignalGroupInviteDeclineEvent>.broadcast();
  final _senderKeyDistCtrl =
      StreamController<SignalSenderKeyDistEvent>.broadcast();

  Stream<SignalRawEvent> get rawSignals => _rawCtrl.stream;
  Stream<SignalIncomingCallEvent> get incomingCalls => _incomingCallCtrl.stream;
  Stream<SignalIncomingGroupCallEvent> get incomingGroupCalls => _incomingGroupCallCtrl.stream;
  Stream<SignalTypingEvent> get typingEvents => _typingCtrl.stream;
  Stream<SignalReadReceiptEvent> get readReceipts => _readReceiptCtrl.stream;
  Stream<SignalGroupReadReceiptEvent> get groupReadReceipts => _groupReadReceiptCtrl.stream;
  Stream<SignalDeliveryAckEvent> get deliveryAcks => _deliveryAckCtrl.stream;
  Stream<SignalTtlUpdateEvent> get ttlUpdates => _ttlUpdateCtrl.stream;
  Stream<SignalReactionEvent> get reactions => _reactionCtrl.stream;
  Stream<SignalEditEvent> get edits => _editCtrl.stream;
  Stream<SignalHeartbeatEvent> get heartbeats => _heartbeatCtrl.stream;
  Stream<SignalKeysEvent> get keysEvents => _keysCtrl.stream;
  Stream<SignalP2PEvent> get p2pEvents => _p2pCtrl.stream;
  Stream<SignalRelayExchangeEvent> get relayExchanges => _relayExchangeCtrl.stream;
  Stream<SignalTurnExchangeEvent>  get turnExchanges  => _turnExchangeCtrl.stream;
  Stream<SignalBlossomExchangeEvent> get blossomExchanges => _blossomExchangeCtrl.stream;
  Stream<SignalStatusUpdateEvent> get statusUpdates => _statusUpdateCtrl.stream;
  Stream<SignalAddrUpdateEvent> get addrUpdates => _addrUpdateCtrl.stream;
  Stream<SignalProfileUpdateEvent> get profileUpdates => _profileUpdateCtrl.stream;
  Stream<SignalChunkReqEvent> get chunkRequests => _chunkReqCtrl.stream;
  Stream<SignalGroupUpdateEvent> get groupUpdates => _groupUpdateCtrl.stream;
  Stream<SignalGroupInviteEvent> get groupInvites => _groupInviteCtrl.stream;
  Stream<SignalMsgDeleteEvent> get msgDeletes => _msgDeleteCtrl.stream;
  Stream<SignalGroupInviteDeclineEvent> get groupInviteDeclines =>
      _groupInviteDeclineCtrl.stream;
  Stream<SignalSenderKeyDistEvent> get senderKeyDists =>
      _senderKeyDistCtrl.stream;

  // ── Constants ────────────────────────────────────────────────────────────

  /// Signal types that require HMAC signature verification (anti-forgery).
  static const _signatureRequiredSignals = <String>{
    'addr_update',
    'sys_keys',
    'relay_exchange',
    'turn_exchange',
    'blossom_exchange',
    'profile_update',
    'group_update',
    'group_invite',
    'status_update',
    'msg_delete',
    'edit',
    // BUG-2 fix: unauthenticated SKDM injection allows key replacement on
    // Firebase/Oxen transports where sender is not a bare Nostr pubkey.
    'sender_key_dist',
    // FINDING-2 fix: chunk_req must be authenticated to prevent amplification DoS.
    'chunk_req',
    // F-TTL fix: ttl_update must be authenticated — an unauthenticated sender
    // could set TTL to 0 and silently wipe all messages in a conversation.
    'ttl_update',
    // A forged group_invite_decline from a relay-injected senderId poisons
    // the group creator's invite state without this HMAC requirement.
    'group_invite_decline',
    // F4 fix: reactions must be authenticated — an unsigned reaction lets any
    // relay operator attribute emoji reactions to arbitrary contacts.
    'reaction',
    // Heartbeats already carry _sig/_spk (SignalBroadcaster._sendSignalTo signs
    // all signals for non-Nostr transports). Without verification a relay can
    // forge heartbeats to make any contact appear online persistently.
    'heartbeat',
  };

  /// Signal types exempt from the general rate limiter (system-critical or
  /// high-volume per call).  All webrtc_* signals are exempt from the general
  /// limiter — offer/answer have their own stricter per-sender limiter below,
  /// and candidates are high-volume during ICE negotiation.
  static const _rateLimitExemptSignals = <String>{
    'sys_keys',
    'addr_update',
    'webrtc_offer',
    'webrtc_answer',
    'webrtc2_offer',
    'webrtc2_answer',
    'webrtc_candidate',
    'webrtc2_candidate',
    'webrtc_reoffer',
    'webrtc_reanswer',
  };

  /// Per-sender rate limiter for webrtc offer/answer — max 6 per minute.
  /// Prevents relay-based call-flood DoS while allowing normal re-negotiation.
  static const _webrtcOfferTypes = <String>{
    'webrtc_offer', 'webrtc_answer', 'webrtc2_offer', 'webrtc2_answer',
    'webrtc_reoffer', 'webrtc_reanswer',
  };

  // ── Contact resolution ───────────────────────────────────────────────────

  /// Resolve a contact by senderId (full databaseId or userId part).
  Contact? _resolveContact(String senderId, Map<String, Contact> index) {
    final c = index[senderId];
    if (c != null) return c;
    final atIdx = senderId.indexOf('@');
    if (atIdx > 0) return index[senderId.substring(0, atIdx)];
    return null;
  }

  /// Returns true if this contact has at least one address with a 64-hex Nostr pubkey.
  /// Used to determine whether webrtc offer/answer HMAC is expected.
  static bool _contactHasNostrPubkey(Contact contact) {
    for (final addr in [contact.databaseId, ...contact.alternateAddresses]) {
      final atIdx = addr.indexOf('@wss://');
      if (atIdx != -1) {
        final pub = addr.substring(0, atIdx);
        if (RegExp(r'^[0-9a-f]{64}$').hasMatch(pub)) return true;
      }
      if (RegExp(r'^[0-9a-f]{64}$').hasMatch(addr)) return true;
    }
    return false;
  }

  // ── Main dispatch entry point ────────────────────────────────────────────

  /// Process a batch of incoming signals, emitting typed events.
  Future<void> dispatch(List<Map<String, dynamic>> signals) async {
    final contactByDbId = _contactIndexBuilder();

    for (var sig in signals) {
      try {
        // Per-sender rate limiting for non-system signals.
        final sigType = sig['type'] as String? ?? '';
        final sigSender = sig['senderId'] as String? ?? '';
        if (sigSender.isNotEmpty &&
            !_allAddressesGetter().contains(sigSender) &&
            sigSender != _selfIdGetter() &&
            !_rateLimitExemptSignals.contains(sigType) &&
            !sigType.startsWith('p2p_') &&
            !_sigRateLimiter.allow(sigSender)) {
          debugPrint('[SignalDispatcher] Rate limited signal ($sigType) from: $sigSender');
          continue;
        }

        // Stricter rate limit for webrtc offer/answer (6 per 10s per sender).
        if (_webrtcOfferTypes.contains(sigType) &&
            sigSender.isNotEmpty &&
            !_allAddressesGetter().contains(sigSender) &&
            !_webrtcRateLimiter.allow(sigSender)) {
          debugPrint('[SignalDispatcher] Rate limited webrtc signal ($sigType) from: $sigSender');
          continue;
        }

        // Verify HMAC signature on security-critical signals.
        // F4-1: The bare-pubkey HMAC bypass must be gated on adapterType=='nostr'
        // to prevent Firebase senders from setting senderId to a 64-hex string
        // and bypassing HMAC. Only signals that went through Nostr Schnorr
        // verification (marked by NostrAdapter with adapterType='nostr') are exempt.
        // The security is in adapterType — set by our adapter code after Schnorr
        // verification, not attacker-controllable from Firebase.
        if (_signatureRequiredSignals.contains(sigType)) {
          final isNostrVerified = (sig['adapterType'] as String? ?? '') == 'nostr';
          if (!isNostrVerified) {
            final payload = sig['payload'];
            if (payload is Map<String, dynamic>) {
              final hmac = payload['_sig'] as String?;
              final senderPub = payload['_spk'] as String?;
              if (hmac == null || senderPub == null) {
                debugPrint(
                    '[SignalDispatcher] REJECTED unsigned signal ($sigType) from $sigSender');
                continue;
              }
              if (!await _verifySignature(sigType, payload, hmac, senderPub)) {
                debugPrint(
                    '[SignalDispatcher] REJECTED forged signal ($sigType) — HMAC invalid');
                continue;
              }
            }
          }
        }

        // webrtc offer/answer HMAC: if the sender contact has a Nostr pubkey
        // (most Oxen contacts do), require _sig/_spk to prevent a relay
        // operator from forging a fake "Incoming call from Alice" event.
        // Firebase-only contacts cannot use ECDH-HMAC and are allowed unsigned.
        if (_webrtcOfferTypes.contains(sigType)) {
          final isNostrVerified = (sig['adapterType'] as String? ?? '') == 'nostr';
          if (!isNostrVerified) {
            final rawPayload = sig['payload'];
            if (rawPayload is Map<String, dynamic>) {
              final hmac = rawPayload['_sig'] as String?;
              final senderPub = rawPayload['_spk'] as String?;
              final senderContact = _resolveContact(sigSender, contactByDbId);
              final needsSig = senderContact != null &&
                  _contactHasNostrPubkey(senderContact);
              if (needsSig && (hmac == null || senderPub == null)) {
                debugPrint(
                    '[SignalDispatcher] REJECTED unsigned webrtc signal ($sigType) from $sigSender');
                continue;
              }
              if (hmac != null && senderPub != null) {
                if (!await _verifySignature(sigType, rawPayload, hmac, senderPub)) {
                  debugPrint(
                      '[SignalDispatcher] REJECTED forged webrtc signal ($sigType) — HMAC invalid');
                  continue;
                }
              }
            }
          }
        }

        // Broadcast raw signal (for active calls).
        if (!_rawCtrl.isClosed) _rawCtrl.add(SignalRawEvent(sig));

        // ── Route by type ──────────────────────────────────────────────
        if (sigType == 'webrtc_offer') {
          final rawPayload = sig['payload'];
          final groupId =
              rawPayload is Map ? rawPayload['groupId'] as String? : null;
          final isVideoCall =
              rawPayload is Map ? (rawPayload['isVideoCall'] as bool? ?? true) : true;
          if (groupId != null) {
            if (!_incomingGroupCallCtrl.isClosed) {
              _incomingGroupCallCtrl.add(SignalIncomingGroupCallEvent(
                  {...sig, 'groupId': groupId, 'isVideoCall': isVideoCall},
                  groupId,
                  isVideoCall: isVideoCall));
            }
          } else {
            if (!_incomingCallCtrl.isClosed) {
              _incomingCallCtrl.add(SignalIncomingCallEvent(sig));
            }
          }
        } else if (sigType == 'typing') {
          final fromId = sig['senderId'] as String? ?? '';
          final typingContact = _resolveContact(fromId, contactByDbId);
          final payload = sig['payload'];
          final groupId = payload is Map ? payload['groupId'] as String? : null;
          if (typingContact != null && !_typingCtrl.isClosed) {
            _typingCtrl.add(SignalTypingEvent(typingContact, groupId: groupId));
          }
        } else if (sigType == 'msg_read') {
          final payload = sig['payload'];
          final from = (payload is Map ? payload['from'] as String? : null) ??
              sig['from'] as String? ??
              '';
          final groupId =
              payload is Map ? payload['groupId'] as String? : null;
          final msgId = payload is Map ? payload['msgId'] as String? : null;
          if (groupId != null && msgId != null && from.isNotEmpty) {
            if (!_groupReadReceiptCtrl.isClosed) {
              _groupReadReceiptCtrl
                  .add(SignalGroupReadReceiptEvent(from, groupId, msgId));
            }
          } else if (from.isNotEmpty) {
            if (!_readReceiptCtrl.isClosed) {
              _readReceiptCtrl.add(SignalReadReceiptEvent(from));
            }
          }
        } else if (sigType == 'msg_ack') {
          final payload = sig['payload'];
          final msgId = payload is Map ? payload['msgId'] as String? : null;
          final from =
              (payload is Map ? payload['from'] as String? : null) ?? '';
          final ackGroupId =
              payload is Map ? payload['groupId'] as String? : null;
          if (msgId != null && from.isNotEmpty) {
            if (!_deliveryAckCtrl.isClosed) {
              _deliveryAckCtrl.add(
                  SignalDeliveryAckEvent(from, msgId, groupId: ackGroupId));
            }
          }
        } else if (sigType == 'ttl_update') {
          final payload = sig['payload'];
          final seconds =
              (payload is Map ? payload['seconds'] : null) as int? ?? 0;
          final fromId = sig['senderId'] as String? ?? '';
          final sender = _resolveContact(fromId, contactByDbId);
          if (sender != null && !_ttlUpdateCtrl.isClosed) {
            _ttlUpdateCtrl.add(SignalTtlUpdateEvent(sender, seconds));
          }
        } else if (sigType == 'reaction') {
          final payload = sig['payload'];
          if (payload is Map) {
            final msgId = payload['msgId'] as String? ?? '';
            final emoji = payload['emoji'] as String? ?? '';
            // F4 fix: always use the HMAC-verified transport sender, not the
            // payload 'from' field which is peer-controlled. A malicious relay
            // could set payload['from'] = victim's id to forge reactions.
            final from = sig['senderId'] as String? ?? '';
            final remove = payload['remove'] == true;
            final groupId = payload['groupId'] as String?;
            debugPrint('[SignalDispatcher] reaction: msgId=$msgId emoji=$emoji from=$from groupId=$groupId');
            if (msgId.isNotEmpty && emoji.isNotEmpty && from.isNotEmpty) {
              String storageKey;
              if (groupId != null) {
                final groupContact = _resolveGroupContact(groupId);
                storageKey = groupContact?.storageKey ?? groupId;
              } else {
                final reactionContact =
                    _resolveContact(from, contactByDbId);
                debugPrint('[SignalDispatcher] reaction resolve: contact=${reactionContact?.name} storageKey=${reactionContact?.storageKey}');
                storageKey = reactionContact?.storageKey ?? '';
              }
              if (storageKey.isNotEmpty && !_reactionCtrl.isClosed) {
                debugPrint('[SignalDispatcher] reaction emitted: storageKey=$storageKey');
                _reactionCtrl.add(SignalReactionEvent(
                  storageKey: storageKey,
                  msgId: msgId,
                  emoji: emoji,
                  from: from,
                  remove: remove,
                ));
              } else {
                debugPrint('[SignalDispatcher] reaction DROPPED: storageKey empty or ctrl closed');
              }
            }
          }
        } else if (sigType == 'edit') {
          final payload = sig['payload'];
          debugPrint('[SignalDispatcher] edit received: payload=$payload senderId=${sig['senderId']} adapterType=${sig['adapterType']}');
          if (payload is Map) {
            final msgId = payload['msgId'] as String? ?? '';
            final text = payload['text'] as String? ?? '';
            // FINDING-2 fix: use authenticated transport sender, not
            // payload['from'] which is attacker-controlled and would allow
            // an authenticated peer to resolve a different contact as editor.
            final from = sig['senderId'] as String? ?? '';
            final editGroupId = payload['groupId'] as String?;
            debugPrint('[SignalDispatcher] edit: msgId=$msgId text=${text.substring(0, text.length.clamp(0, 30))} from=$from groupId=$editGroupId');
            if (msgId.isNotEmpty && text.isNotEmpty) {
              final editContact = _resolveContact(from, contactByDbId);
              debugPrint('[SignalDispatcher] edit: resolved contact=${editContact?.name} id=${editContact?.id} dbId=${editContact?.databaseId}');
              if (editContact != null && !_editCtrl.isClosed) {
                _editCtrl.add(SignalEditEvent(editContact, msgId, text,
                    groupId: editGroupId));
              } else {
                debugPrint('[SignalDispatcher] edit DROPPED: contact=${editContact == null ? "null" : "found"} ctrlClosed=${_editCtrl.isClosed}');
              }
            } else {
              debugPrint('[SignalDispatcher] edit DROPPED: msgId empty=${msgId.isEmpty} text empty=${text.isEmpty}');
            }
          }
        } else if (sigType == 'heartbeat') {
          final payload = sig['payload'];
          final from =
              (payload is Map ? payload['from'] as String? : null) ??
                  sig['senderId'] as String? ??
                  '';
          final hbContact = _resolveContact(from, contactByDbId);
          if (hbContact != null && !_heartbeatCtrl.isClosed) {
            _heartbeatCtrl.add(SignalHeartbeatEvent(hbContact));
          }
        } else if (sigType == 'sys_keys') {
          final senderId = sig['senderId'] as String? ?? '';
          final payload = sig['payload'];
          if (payload is Map<String, dynamic> && senderId.isNotEmpty) {
            final keyContact = _resolveContact(senderId, contactByDbId);
            if (keyContact != null && !_keysCtrl.isClosed) {
              _keysCtrl.add(SignalKeysEvent(
                  keyContact, Map<String, dynamic>.from(payload)));
            }
          }
        } else if (sigType.startsWith('p2p_')) {
          final senderId = sig['senderId'] as String? ?? '';
          final p2pContact = _resolveContact(senderId, contactByDbId);
          if (p2pContact != null) {
            // Verify HMAC on non-Nostr transports — prevents relay from
            // injecting forged p2p_offer/answer/ice with spoofed senderId.
            final isNostrVerified = (sig['adapterType'] as String? ?? '') == 'nostr';
            if (!isNostrVerified) {
              final payload = sig['payload'];
              if (payload is Map<String, dynamic>) {
                final hmac = payload['_sig'] as String?;
                final senderPub = payload['_spk'] as String?;
                if (hmac == null || senderPub == null) {
                  debugPrint('[SignalDispatcher] REJECTED unsigned p2p signal ($sigType) from $senderId');
                  continue;
                }
                if (!await _verifySignature(sigType, payload, hmac, senderPub)) {
                  debugPrint('[SignalDispatcher] REJECTED forged p2p signal ($sigType) — HMAC invalid');
                  continue;
                }
              }
            }
            final rawPayload = sig['payload'];
            if (rawPayload is Map<String, dynamic> && !_p2pCtrl.isClosed) {
              _p2pCtrl.add(SignalP2PEvent(p2pContact, sigType, rawPayload));
            }
          }
        } else if (sigType == 'relay_exchange') {
          // Only accept relay suggestions from known contacts — prevents unknown
          // senders from influencing relay selection.
          final relayContact = _resolveContact(sigSender, contactByDbId);
          if (relayContact == null) {
            debugPrint('[SignalDispatcher] relay_exchange from unknown sender $sigSender — ignored');
            continue;
          }
          final payload = sig['payload'];
          final rawRelays = payload is Map ? payload['relays'] : payload;
          // Validate relay URLs: must be ws:// or wss://, reject loopback.
          final relays = rawRelays is List
              ? rawRelays.whereType<String>().where((r) {
                  if (!r.startsWith('wss://') && !r.startsWith('ws://')) {
                    return false;
                  }
                  final host = Uri.tryParse(r)?.host ?? '';
                  if (host.isEmpty) return false;
                  if (host == 'localhost' || host == '127.0.0.1' ||
                      host == '::1' || host == '0.0.0.0') { return false; }
                  if (host.startsWith('10.') || host.startsWith('192.168.') ||
                      host.startsWith('169.254.')) { return false; }
                  if (host.startsWith('172.')) {
                    final seg = int.tryParse(host.split('.').elementAtOrNull(1) ?? '');
                    if (seg != null && seg >= 16 && seg <= 31) return false;
                  }
                  return true;
                }).toList()
              : <String>[];
          if (relays.isNotEmpty && !_relayExchangeCtrl.isClosed) {
            _relayExchangeCtrl.add(SignalRelayExchangeEvent(relays));
          }
        } else if (sigType == 'turn_exchange') {
          // FINDING-2 fix: gate on known contact, same as relay_exchange.
          final turnContact = _resolveContact(sigSender, contactByDbId);
          if (turnContact == null) {
            debugPrint('[SignalDispatcher] turn_exchange from unknown sender '
                '$sigSender — ignored');
            continue;
          }
          final payload = sig['payload'];
          final rawServers = payload is Map ? payload['servers'] : null;
          final servers = rawServers is List
              ? rawServers
                  .take(50) // cap before iteration — prevents heap-alloc DoS
                  .whereType<Map>()
                  .map((s) => Map<String, dynamic>.from(s))
                  .toList()
              : <Map<String, dynamic>>[];
          if (servers.isNotEmpty && !_turnExchangeCtrl.isClosed) {
            _turnExchangeCtrl.add(SignalTurnExchangeEvent(servers));
          }
        } else if (sigType == 'blossom_exchange') {
          final blossomContact = _resolveContact(sigSender, contactByDbId);
          if (blossomContact == null) {
            debugPrint('[SignalDispatcher] blossom_exchange from unknown sender '
                '$sigSender — ignored');
            continue;
          }
          final payload = sig['payload'];
          final rawServers = payload is Map ? payload['servers'] : null;
          final servers = rawServers is List
              ? rawServers
                  .take(20)
                  .whereType<String>()
                  .where((u) {
                    if (!u.startsWith('https://')) return false;
                    final host = Uri.tryParse(u)?.host ?? '';
                    if (host.isEmpty || host == 'localhost' ||
                        host == '127.0.0.1' || host == '::1' ||
                        host == '0.0.0.0') {
                      return false;
                    }
                    if (host.startsWith('10.') || host.startsWith('192.168.') ||
                        host.startsWith('169.254.')) {
                      return false;
                    }
                    if (host.startsWith('172.')) {
                      final seg = int.tryParse(host.split('.').elementAtOrNull(1) ?? '');
                      if (seg != null && seg >= 16 && seg <= 31) return false;
                    }
                    return true;
                  })
                  .toList()
              : <String>[];
          if (servers.isNotEmpty && !_blossomExchangeCtrl.isClosed) {
            _blossomExchangeCtrl.add(SignalBlossomExchangeEvent(servers));
          }
        } else if (sigType == 'status_update') {
          final rawPayload = sig['payload'];
          final statusJson =
              rawPayload is Map<String, dynamic> ? rawPayload : null;
          final senderId = sig['senderId'] as String? ?? '';
          if (statusJson is Map<String, dynamic>) {
            final senderContact =
                _resolveContact(senderId, contactByDbId);
            if (senderContact != null) {
              try {
                final status = UserStatus.fromJson(statusJson);
                if (!status.isExpired && !_statusUpdateCtrl.isClosed) {
                  _statusUpdateCtrl
                      .add(SignalStatusUpdateEvent(senderContact, status));
                }
              } catch (e) {
                debugPrint(
                    '[SignalDispatcher] status_update parse error: $e');
              }
            }
          }
        } else if (sigType == 'addr_update') {
          final payload = sig['payload'];
          if (payload is Map) {
            final senderId = sig['senderId'] as String? ?? '';
            final primary = payload['primary'] as String? ?? '';
            final all =
                (payload['all'] as List?)?.cast<String>() ?? <String>[];
            var addrContact = _resolveContact(senderId, contactByDbId);
            if (addrContact == null && all.isNotEmpty) {
              for (final a in all) {
                addrContact = _resolveContact(a, contactByDbId);
                if (addrContact != null) break;
              }
            }
            if (addrContact != null &&
                primary.isNotEmpty &&
                !_addrUpdateCtrl.isClosed) {
              _addrUpdateCtrl
                  .add(SignalAddrUpdateEvent(addrContact, primary, all));
            }
          }
        } else if (sigType == 'profile_update') {
          final payload = sig['payload'];
          if (payload is Map) {
            final senderId = sig['senderId'] as String? ?? '';
            final about = payload['about'] as String? ?? '';
            final avatarB64 = payload['avatar'] as String? ?? '';
            // F7: Prevent storage exhaustion via oversized avatar payload.
            if (avatarB64.length > 400 * 1024) {
              debugPrint('[SignalDispatcher] profile_update: oversized avatar dropped (${avatarB64.length} bytes)');
              continue;
            }
            final profileContact =
                _resolveContact(senderId, contactByDbId);
            if (profileContact != null && !_profileUpdateCtrl.isClosed) {
              _profileUpdateCtrl.add(
                  SignalProfileUpdateEvent(profileContact, about, avatarB64));
            }
          }
        } else if (sigType == 'group_update') {
          final payload = sig['payload'];
          if (payload is Map) {
            final groupId = payload['groupId'] as String?;
            final groupName = payload['name'] as String? ?? '';
            final rawMembers = payload['members'];
            final creatorId = payload['creatorId'] as String?;
            if (groupId != null && rawMembers is List && rawMembers.length <= 200 && !_groupUpdateCtrl.isClosed) {
              _groupUpdateCtrl.add(SignalGroupUpdateEvent(
                  groupId, groupName, rawMembers.whereType<String>().toList(),
                  creatorId: creatorId, senderId: sigSender));
            }
          }
        } else if (sigType == 'group_invite') {
          final payload = sig['payload'];
          if (payload is Map) {
            final groupId = payload['groupId'] as String?;
            final groupName = payload['name'] as String? ?? '';
            final rawMembers = payload['members'];
            final creatorId = payload['creatorId'] as String?;
            final senderId = sig['senderId'] as String? ?? '';
            final inviter = _resolveContact(senderId, contactByDbId);
            if (groupId != null && rawMembers is List && rawMembers.length <= 200 && inviter != null &&
                !_groupInviteCtrl.isClosed) {
              _groupInviteCtrl.add(SignalGroupInviteEvent(
                  inviter, groupId, groupName, rawMembers.whereType<String>().toList(),
                  creatorId: creatorId));
            }
          }
        } else if (sigType == 'group_invite_decline') {
          final payload = sig['payload'];
          if (payload is Map) {
            final groupId = payload['groupId'] as String?;
            final senderId = sig['senderId'] as String? ?? '';
            final decliner = _resolveContact(senderId, contactByDbId);
            if (groupId != null && decliner != null &&
                !_groupInviteDeclineCtrl.isClosed) {
              _groupInviteDeclineCtrl
                  .add(SignalGroupInviteDeclineEvent(decliner, groupId));
            }
          }
        } else if (sigType == 'msg_delete') {
          final payload = sig['payload'];
          debugPrint('[SignalDispatcher] msg_delete received: payload=$payload senderId=${sig['senderId']}');
          if (payload is Map) {
            final msgId = payload['msgId'] as String?;
            final deleteGroupId = payload['groupId'] as String?;
            final senderId = sig['senderId'] as String? ?? '';
            debugPrint('[SignalDispatcher] msg_delete: msgId=$msgId deleteGroupId=$deleteGroupId senderId=$senderId');
            if (msgId != null && senderId.isNotEmpty && !_msgDeleteCtrl.isClosed) {
              _msgDeleteCtrl.add(SignalMsgDeleteEvent(senderId, msgId, groupId: deleteGroupId));
            }
          }
        } else if (sigType == 'sender_key_dist') {
          final payload = sig['payload'];
          if (payload is Map) {
            final groupId = payload['groupId'] as String?;
            final skdm = payload['skdm'] as String?;
            final senderId = sig['senderId'] as String? ?? '';
            final sender = _resolveContact(senderId, contactByDbId);
            if (groupId != null && skdm != null && sender != null &&
                !_senderKeyDistCtrl.isClosed) {
              _senderKeyDistCtrl
                  .add(SignalSenderKeyDistEvent(sender, groupId, skdm));
            }
          }
        } else if (sigType == 'chunk_req') {
          // FINDING-2 fix: only accept chunk resend requests from known contacts.
          final chunkContact = _resolveContact(sigSender, contactByDbId);
          if (chunkContact == null) {
            debugPrint('[SignalDispatcher] chunk_req from unknown sender '
                '$sigSender — ignored');
            continue;
          }
          final payload = sig['payload'];
          if (payload is Map) {
            final fid = payload['fid'] as String?;
            final missing = payload['missing'];
            if (fid != null && missing is List && !_chunkReqCtrl.isClosed) {
              // Cap before List.from() — prevents 8MB heap spike per signal.
              final capped = missing.take(200).whereType<int>().toList();
              _chunkReqCtrl.add(SignalChunkReqEvent(
                  fid, capped, sigSender));
            }
          }
        }
      } catch (e) {
        debugPrint('[SignalDispatcher] Skipping malformed signal: $e');
      }
    }
  }

  /// Release resources. Call from ChatController.dispose().
  void dispose() {
    _rawCtrl.close();
    _incomingCallCtrl.close();
    _incomingGroupCallCtrl.close();
    _typingCtrl.close();
    _readReceiptCtrl.close();
    _groupReadReceiptCtrl.close();
    _deliveryAckCtrl.close();
    _ttlUpdateCtrl.close();
    _reactionCtrl.close();
    _editCtrl.close();
    _heartbeatCtrl.close();
    _keysCtrl.close();
    _p2pCtrl.close();
    _relayExchangeCtrl.close();
    _turnExchangeCtrl.close();
    _blossomExchangeCtrl.close();
    _statusUpdateCtrl.close();
    _addrUpdateCtrl.close();
    _profileUpdateCtrl.close();
    _chunkReqCtrl.close();
    _groupUpdateCtrl.close();
    _groupInviteCtrl.close();
    _groupInviteDeclineCtrl.close();
    _senderKeyDistCtrl.close();
    _msgDeleteCtrl.close();
    _sigRateLimiter.clear();
  }
}
