import '../models/contact.dart';
import '../models/user_status.dart';

// ── Event types emitted by SignalDispatcher ─────────────────────────────────
//
// Pure data classes. Extracted from signal_dispatcher.dart for readability —
// the dispatcher file is large enough on its own. signal_dispatcher.dart
// re-exports this file, so existing `import '.../signal_dispatcher.dart'`
// callers don't need to change anything.

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
  /// Non-null when this is an SFU-hosted call: holds the room id + access
  /// token receivers need to join the same SFU room.
  final String? sfuRoomId;
  final String? sfuToken;
  SignalIncomingGroupCallEvent(this.signal, this.groupId,
      {this.isVideoCall = true, this.sfuRoomId, this.sfuToken});
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
///
/// For 1-on-1 chats `contact` is the peer that changed the setting and
/// `groupId` is null. For group chats `contact` is the group member who
/// initiated the change and `groupId` is the group's contactId — the
/// receiver applies the TTL to the group chat, attributing the change to
/// the member.
class SignalTtlUpdateEvent {
  final Contact contact;
  final int seconds;
  final String? groupId;
  SignalTtlUpdateEvent(this.contact, this.seconds, {this.groupId});
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
/// Peer requests we delete our Signal session with them and rebuild on
/// next send. Triggered by the peer detecting a stale-prekey decrypt
/// failure — their existing sessions with us can no longer decrypt our
/// messages because the prekey bundle we used for session setup has been
/// rotated out on their side.
class SignalSessionResetEvent {
  final Contact contact;
  /// Sender's CURRENT Signal bundle, snapshotted right after they
  /// republished it. When present, the receiver MUST `deleteContactData`
  /// then `buildSession(this.bundle)` atomically — refetching from a
  /// relay loses races with relay propagation. Older clients that
  /// don't include the bundle still work via the legacy refetch path
  /// (slightly racy but functional).
  final Map<String, dynamic>? bundle;
  SignalSessionResetEvent(this.contact, {this.bundle});
}

class SignalAddrUpdateEvent {
  final Contact contact;
  final String primary;
  final List<String> all;
  /// Raw payload map — may contain 'transportAddresses' and 'transportPriority'
  /// from new-format addr_update signals.
  final Map<String, dynamic> rawPayload;
  /// Transport the signal arrived on (e.g. 'Pulse', 'Nostr', 'LAN').
  /// Used to decide whether to trust private-IP addresses: LAN / Pulse are
  /// trusted channels; Nostr / Session leak metadata publicly.
  final String? sourceTransport;
  SignalAddrUpdateEvent(this.contact, this.primary, this.all, this.rawPayload,
      {this.sourceTransport});
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
  /// Map of each member UUID (as assigned on the creator's device) → the
  /// member's Nostr secp256k1 pubkey. Used by the receiver to resolve
  /// members back to their own local contacts / fetch profile info —
  /// without this there is no cross-device mapping from UUID to identity.
  final Map<String, String> memberPubkeys;
  /// Per-member UUID → `Map<Transport, List<address>>`. Lets receivers
  /// auto-create pending contacts for group members they don't already
  /// know locally, so group sends don't silently drop that recipient.
  /// Empty for legacy invites pre-dating this field.
  final Map<String, Map<String, List<String>>> memberAddresses;
  /// Per-member UUID → display name as known to the inviter. Lets receivers
  /// label auto-pending member contacts with a real human name instead of
  /// the "Member <pubkey>" stub. Empty for legacy invites.
  final Map<String, String> memberNames;
  /// Per-member UUID → universal Pulse pubkey (64-hex). Receivers pair
  /// each pubkey with [groupServerUrl] to address pulse-mode messages
  /// without waiting for the member's own addr_update to propagate.
  /// Empty when the inviter doesn't know the member's Pulse pubkey
  /// (member never used Pulse before).
  final Map<String, String> memberPulsePubkeys;
  /// Group transport mode as picked by the creator: 'mesh' | 'pulse' (or
  /// '' for legacy invites — receiver treats empty as 'mesh', the new
  /// post-2026-04-26 default).
  final String groupTransportMode;
  /// Pulse server endpoint, set only when groupTransportMode == 'pulse'.
  final String groupServerUrl;
  /// Optional invite code for closed Pulse servers.
  final String groupServerInvite;
  SignalGroupInviteEvent(this.fromContact, this.groupId, this.groupName, this.members,
      {this.creatorId,
      this.memberPubkeys = const {},
      this.memberAddresses = const {},
      this.memberNames = const {},
      this.memberPulsePubkeys = const {},
      this.groupTransportMode = '',
      this.groupServerUrl = '',
      this.groupServerInvite = ''});
}

/// Group membership change broadcast by group admin.
class SignalGroupUpdateEvent {
  final String groupId;
  final String groupName;
  final List<String> members;
  final String? creatorId;
  final String senderId;
  final Map<String, String> memberPubkeys;
  /// See [SignalGroupInviteEvent.memberAddresses].
  final Map<String, Map<String, List<String>>> memberAddresses;
  /// See [SignalGroupInviteEvent.memberNames].
  final Map<String, String> memberNames;
  /// See [SignalGroupInviteEvent.memberPulsePubkeys].
  final Map<String, String> memberPulsePubkeys;
  /// See [SignalGroupInviteEvent.groupTransportMode].
  final String groupTransportMode;
  /// See [SignalGroupInviteEvent.groupServerUrl].
  final String groupServerUrl;
  /// See [SignalGroupInviteEvent.groupServerInvite].
  final String groupServerInvite;
  /// Optional base64-encoded group avatar. Empty string = no change; the
  /// receiver should keep its existing local avatar in that case.
  final String avatar;
  SignalGroupUpdateEvent(this.groupId, this.groupName, this.members,
      {this.creatorId,
      this.senderId = '',
      this.memberPubkeys = const {},
      this.memberAddresses = const {},
      this.memberNames = const {},
      this.memberPulsePubkeys = const {},
      this.groupTransportMode = '',
      this.groupServerUrl = '',
      this.groupServerInvite = '',
      this.avatar = ''});
}
