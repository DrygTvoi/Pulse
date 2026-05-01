part of 'chat_controller.dart';

/// Group lifecycle management — invites, accept/decline, broadcast
/// updates, member seeding, sender-key rotation, and group delete.
/// Extracted from ChatController so the main file doesn't carry
/// every group-related method inline.
///
/// State (`_contacts`, `_broadcaster`, `_identity`, …) stays on
/// ChatController; the helper accesses it via `_c._field`.
class _GroupManager {
  final ChatController _c;
  _GroupManager(this._c);

  Future<void> sendGroupInvite(Contact target, Contact group) async {
    // Pre-warm the Pulse server connection on the creator side so the very
    // first invite (and the SFU room create that often follows) doesn't
    // race against WS auth. Fire-and-forget — the invite send itself runs
    // over Nostr/Session/whatever transport the target has, the pulse
    // connection is for FUTURE group messages.
    if (group.isPulseGroup && group.groupServerUrl.isNotEmpty) {
      unawaited(_c.ensureGroupPulseConnection(group.groupServerUrl));
    }
    return _c._broadcaster.sendGroupInvite(target, group, _c._contacts.contacts);
  }

  Future<void> declineGroupInvite(SignalGroupInviteEvent invite) async {
    if (_c._identity == null || _c._selfId.isEmpty) return;
    await _c._sendSignalTo(invite.fromContact, 'group_invite_decline', {
      'groupId': invite.groupId,
      'from': _c._selfId,
    });
    debugPrint('[Group] Declined invite from ${invite.fromContact.name} for "${invite.groupName}"');
  }

  Future<void> sendGroupHistory(Contact target, Contact group, {int limit = 50}) async {
    if (_c._identity == null || _c._selfId.isEmpty) return;
    final storageKey = group.storageKey;
    final stored = await LocalStorageService()
        .loadMessagesPage(storageKey, pageSize: limit);
    if (stored.isEmpty) return;
    final messages = stored
        .map((raw) {
          try {
            final data = raw['data'] is String
                ? jsonDecode(raw['data'] as String) as Map<String, dynamic>
                : raw;
            final text = data['encryptedPayload'] as String? ?? '';
            if (text.isEmpty) return null;
            return Message.tryFromJson(raw);
          } catch (_) { return null; }
        })
        .whereType<Message>()
        .toList();
    await _c._broadcaster.sendGroupHistory(target, group, messages);
  }

  /// Build a `pulse://group?cfg=…` shareable invite URL for [group]. Returns
  /// null for non-group contacts. Embeds member pubkeys + transport
  /// addresses so the recipient can route to everyone immediately on accept.
  String? buildGroupInviteLink(Contact group) {
    if (!group.isGroup) return null;
    final memberAddresses =
        _c._broadcaster.buildMemberAddressesForInvite(group, _c._contacts.contacts);
    return GroupInviteLink.build(group, memberAddresses: memberAddresses);
  }

  /// Accept a group invite that arrived via a `pulse://group?cfg=…` deep
  /// link. The sender is *not* the in-app inviter (we got this out of band)
  /// but the embedded `creatorId` + `memberPubkeys` are sufficient to seed
  /// routing. After joining, broadcast a group_update so existing members
  /// learn we're now in the roster.
  Future<void> acceptGroupInviteFromLink(GroupInvitePayload payload) async {
    if (_c._contacts.findById(payload.groupId) != null) {
      debugPrint('[Group] Invite link: already in group ${payload.groupId}');
      return;
    }
    if (payload.creatorId == null || payload.creatorId!.isEmpty) {
      debugPrint('[Group] Invite link rejected: no creatorId');
      return;
    }
    final myUuid = _c._identity?.id ?? '';
    if (myUuid.isEmpty) {
      debugPrint('[Group] Invite link deferred: identity not ready');
      return;
    }
    final mergedMembers = List<String>.from(payload.members);
    if (myUuid.isNotEmpty && !mergedMembers.contains(myUuid)) {
      mergedMembers.add(myUuid);
    }
    final newGroup = Contact(
      id: payload.groupId,
      name: payload.name,
      provider: 'group',
      databaseId: '',
      publicKey: '',
      isGroup: true,
      members: mergedMembers,
      creatorId: payload.creatorId,
      memberPubkeys: payload.memberPubkeys,
    );
    await _c._contacts.addContact(newGroup);
    _c._invalidateContactIndex();
    await _ensurePendingContactsForMembers(
        payload.memberPubkeys, payload.memberAddresses);
    final enriched = await enrichGroupMemberPubkeys(newGroup);
    if (enriched != newGroup) {
      await _c._contacts.updateContact(enriched);
    }
    unawaited(broadcastGroupUpdate(enriched));
    unawaited(_c._republishAllKeys());
    debugPrint('[Group] Joined "${payload.name}" via invite link '
        '(${mergedMembers.length} members)');
    _c._scheduleNotify();
  }

  Future<void> acceptGroupInvite(SignalGroupInviteEvent invite) async {
    final _ex = _c._contacts.findById(invite.groupId);
    if (_ex != null && _ex.isGroup) return;
    if (invite.creatorId == null || invite.creatorId!.isEmpty) {
      debugPrint('[Group] Rejected invite with no creatorId');
      return;
    }
    debugPrint('[Group] Accepting invite for "${invite.groupName}" '
        'from ${invite.fromContact.name} '
        '(creatorId=${invite.creatorId}, members=${invite.members.length}, '
        'memberPubkeys=${invite.memberPubkeys.length})');
    final newGroup = Contact(
      id: invite.groupId,
      name: invite.groupName,
      provider: 'group',
      databaseId: '',
      publicKey: '',
      isGroup: true,
      members: invite.members,
      creatorId: invite.creatorId,
      memberPubkeys: invite.memberPubkeys,
      groupTransportMode: invite.groupTransportMode,
      groupServerUrl: invite.groupServerUrl,
      groupServerInvite: invite.groupServerInvite,
    );
    await _c._contacts.addContact(newGroup);
    _c._invalidateContactIndex();

    // ── Establish Pulse infrastructure FIRST so key pre-warming below
    //     can actually fetch bundles from the group's Pulse server.
    //     Previous order (prewarm → seed → connect) meant every
    //     _prewarmSignalSession ran against Nostr-only addresses, and
    //     members whose keys were only on Pulse were unresolvable —
    //     group sends from the joining device silently dropped them.
    if (newGroup.isPulseGroup && newGroup.groupServerUrl.isNotEmpty) {
      // Fire-and-forget the connection — prewarm uses ad-hoc readers
      // that open their own socket when needed, but the server may
      // rate-limit auth; this call starts the handshake early so the
      // shared pool is warm when prewarm iterates Pulse addresses.
      unawaited(_c.ensureGroupPulseConnection(newGroup.groupServerUrl));
    }
    if (newGroup.isPulseGroup &&
        newGroup.groupServerUrl.isNotEmpty &&
        invite.memberPulsePubkeys.isNotEmpty) {
      await _seedMemberPulseAddresses(
          invite.memberPulsePubkeys, invite.memberPubkeys,
          newGroup.groupServerUrl);
    }

    await _ensurePendingContactsForMembers(
        invite.memberPubkeys, invite.memberAddresses,
        memberNames: invite.memberNames);
    if (invite.memberNames.isNotEmpty) {
      await _promotePlaceholderNames(invite.memberNames, invite.memberPubkeys);
    }
    // After joining, broadcast a group_update so existing members
    // learn we're now in the roster. Without this, the creator (and
    // other members) never learn this member's addresses, so:
    //  - The new member never appears in `recipients` on the creator's
    //    side → SKDM is never delivered → SK decrypt fails → raw
    //    base64 ciphertext displayed instead of real messages.
    //  - Offline-accepted members are permanently broken.
    final enriched = await enrichGroupMemberPubkeys(newGroup);
    if (enriched != newGroup) {
      await _c._contacts.updateContact(enriched);
    }
    unawaited(broadcastGroupUpdate(enriched));
    unawaited(_c._republishAllKeys());
    debugPrint('[Group] Joined group "${invite.groupName}" via invite');
    _c._scheduleNotify();
  }

  /// For each `(memberUuid → pulsePubkey)` entry from a pulse-group invite
  /// or update, look up the local contact (by UUID first, then by Nostr
  /// pubkey from `memberPubkeys`) and graft `<pulsePub>@<groupServerUrl>`
  /// into their `transportAddresses['Pulse']` if not already present.
  Future<void> _seedMemberPulseAddresses(
      Map<String, String> memberPulsePubkeys,
      Map<String, String> memberPubkeys,
      String groupServerUrl) async {
    if (memberPulsePubkeys.isEmpty || groupServerUrl.isEmpty) return;
    var seeded = 0;
    for (final entry in memberPulsePubkeys.entries) {
      final uuid = entry.key;
      final pulsePub = entry.value.toLowerCase();
      if (pulsePub.length != 64) continue;
      Contact? c = _c._contacts.findById(uuid);
      if (c == null) {
        final nostrPub = memberPubkeys[uuid]?.toLowerCase();
        if (nostrPub != null && nostrPub.isNotEmpty) {
          c = _c._contacts.findByPubkey(nostrPub);
        }
      }
      if (c == null) continue;
      final addr = '$pulsePub@$groupServerUrl';
      final existing = List<String>.from(c.transportAddresses['Pulse'] ?? const []);
      if (existing.any((a) => a.toLowerCase() == addr.toLowerCase())) continue;
      existing.add(addr);
      final newTa = Map<String, List<String>>.from(c.transportAddresses);
      newTa['Pulse'] = existing;
      final newTp = List<String>.from(c.transportPriority);
      if (!newTp.contains('Pulse')) newTp.add('Pulse');
      final patched = c.copyWith(
        transportAddresses: newTa,
        transportPriority: newTp,
      );
      await _c._contacts.updateContact(patched);
      seeded++;
    }
    if (seeded > 0) {
      _c._invalidateContactIndex();
      debugPrint('[PulseGroup] Seeded $seeded member Pulse address(es) on $groupServerUrl');
      _c._scheduleNotify();
    }
  }

  /// For every `(memberUuid → pubkey)` entry we don't already have a local
  /// contact for (matched by pubkey), create a pending contact so
  /// `findByPubkey` resolves on subsequent group sends.
  Future<void> _ensurePendingContactsForMembers(
      Map<String, String> memberPubkeys,
      Map<String, Map<String, List<String>>> memberAddresses,
      {Map<String, String> memberNames = const {}}) async {
    if (memberPubkeys.isEmpty) return;
    final selfId = _c._selfId;
    final ownPubAt = selfId.indexOf('@');
    final ownPub =
        (ownPubAt > 0 ? selfId.substring(0, ownPubAt) : selfId).toLowerCase();
    final probeRelays =
        ConnectivityProbeService.instance.lastResult.nostrRelays;
    final fallbackRelays = <String>[];
    for (final r in probeRelays) {
      if (fallbackRelays.length >= 3) break;
      final normalized = r.startsWith('ws') ? r : 'wss://$r';
      if (!fallbackRelays.contains(normalized)) fallbackRelays.add(normalized);
    }
    if (fallbackRelays.isEmpty) fallbackRelays.add(ChatController._kDefaultNostrRelay);
    var created = 0;
    for (final entry in memberPubkeys.entries) {
      final uuid = entry.key;
      final pub = entry.value.toLowerCase();
      if (pub.isEmpty || pub == ownPub) continue;
      if (_c._contacts.findByPubkey(pub) != null) continue;
      final addresses = memberAddresses[uuid];
      final ta = (addresses != null && addresses.isNotEmpty)
          ? addresses.map((k, v) => MapEntry(k, List<String>.from(v)))
          : <String, List<String>>{
              'Nostr': [for (final r in fallbackRelays) '$pub@$r'],
            };
      final shortPub = pub.length >= 8 ? pub.substring(0, 8) : pub;
      final fromInviter = memberNames[uuid]?.trim() ?? '';
      final name = fromInviter.isNotEmpty ? fromInviter : 'Member $shortPub';
      final c = await ContactManager().createPendingContact(
        senderId: pub,
        senderName: name,
        address: pub,
        transportAddresses: ta,
        isHidden: true,
        publicKey: pub,
      );
      if (c != null) {
        created++;
        unawaited(_prewarmSignalSession(c));
      }
    }
    if (created > 0) {
      _c._invalidateContactIndex();
      debugPrint('[Group] Auto-pended $created group members for pubkey routing');
    }
  }

  /// When [contact]'s pubkey rotates (peer reinstalled), every group whose
  /// `memberPubkeys` map still points at the OLD pubkey for this member
  /// needs to be patched in-place.
  Future<void> refreshGroupMembershipForContact(Contact contact) async {
    final newPub = _extractPubkeyFromContact(contact);
    if (newPub.isEmpty) return;
    final updated = <Contact>[];
    for (final g in _c._contacts.contacts) {
      if (!g.isGroup) continue;
      String? mappedKey;
      for (final entry in g.memberPubkeys.entries) {
        if (entry.key == contact.id ||
            entry.value.toLowerCase() == newPub.toLowerCase()) {
          mappedKey = entry.key;
          break;
        }
      }
      if (mappedKey == null) continue;
      final newMap = Map<String, String>.from(g.memberPubkeys);
      final oldPub = newMap[mappedKey];
      if (oldPub != null && oldPub.toLowerCase() == newPub.toLowerCase()) continue;
      newMap[mappedKey] = newPub;
      final newMembers = List<String>.from(g.members);
      if (!newMembers.contains(mappedKey)) newMembers.add(mappedKey);
      final patched = g.copyWith(
        memberPubkeys: newMap,
        members: newMembers,
      );
      await _c._contacts.updateContact(patched);
      updated.add(patched);
    }
    if (updated.isNotEmpty) {
      _c._invalidateContactIndex();
      debugPrint('[Group] Refreshed memberPubkeys for ${contact.name} '
          'in ${updated.length} group(s) after identity rotation');
      _c._scheduleNotify();
    }
  }

  /// Replace "Member <pubkey>" placeholder names on already-existing
  /// contacts with the human-readable name we just learned via group_invite
  /// or group_update.
  Future<void> _promotePlaceholderNames(
      Map<String, String> memberNames,
      Map<String, String> memberPubkeys) async {
    if (memberNames.isEmpty) return;
    final placeholder = RegExp(r'^Member [0-9a-f]{4,}$');
    var renamed = 0;
    for (final entry in memberNames.entries) {
      final uuid = entry.key;
      final newName = entry.value.trim();
      if (newName.isEmpty || placeholder.hasMatch(newName)) continue;
      Contact? c = _c._contacts.findById(uuid);
      if (c == null) {
        final pub = memberPubkeys[uuid]?.toLowerCase();
        if (pub != null && pub.isNotEmpty) {
          c = _c._contacts.findByPubkey(pub);
        }
      }
      if (c == null) continue;
      if (!placeholder.hasMatch(c.name)) continue;
      final patched = c.copyWith(name: newName);
      await _c._contacts.updateContact(patched);
      renamed++;
    }
    if (renamed > 0) {
      _c._invalidateContactIndex();
      debugPrint('[Group] Promoted $renamed placeholder name(s) → real names');
      _c._scheduleNotify();
    }
  }

  /// Pull the 64-hex pubkey out of a contact's Nostr/Pulse address. Returns
  /// "" if no recognizable hex prefix is found.
  String _extractPubkeyFromContact(Contact c) {
    for (final addrs in c.transportAddresses.values) {
      for (final addr in addrs) {
        final at = addr.indexOf('@');
        final left = at > 0 ? addr.substring(0, at) : addr;
        if (ChatController._hex64.hasMatch(left)) return left.toLowerCase();
      }
    }
    return '';
  }

  /// Best-effort fetch of the contact's published Signal+PQC bundle and
  /// `buildSession` so the first encryptMessage doesn't have to take the
  /// slow lazy path.
  Future<void> _prewarmSignalSession(Contact contact) async {
    try {
      Map<String, dynamic>? bundle;
      for (final entry in contact.transportAddresses.entries) {
        final provider = entry.key;
        if (provider == 'Session') continue;
        for (final addr in entry.value) {
          try {
            final b = await _c._fetchKeysFromAddress(addr, provider);
            if (b != null) { bundle = b; break; }
          } catch (_) {}
        }
        if (bundle != null) break;
      }
      if (bundle == null) return;
      await _c._signalService.buildSession(contact.databaseId, bundle);
      _c._keys.cacheContactKyberPk(contact.databaseId, bundle);
      debugPrint('[Group] Pre-warmed Signal session with ${contact.name}');
    } catch (e) {
      debugPrint('[Group] _prewarmSignalSession(${contact.name}) failed: $e');
    }
  }

  /// Caller side of an SFU group call: after `room_create` returns a
  /// roomId + token, push the invite to every group member.
  Future<void> broadcastSfuCallInvite(
      Contact group, String roomId, String token,
      {bool isVideoCall = false}) async {
    _c._registerActiveGroupCall(
        group.id, roomId, token, _c._identity?.id ?? 'self',
        isVideoCall: isVideoCall);
    final serverUrl = group.groupServerUrl;
    String ownPulseAddr = '';
    if (serverUrl.isNotEmpty) {
      ownPulseAddr = _c._allAddresses.firstWhere(
          (a) => a.endsWith('@$serverUrl'),
          orElse: () => '');
      if (ownPulseAddr.isEmpty) {
        try {
          final pulseKey = await ChatController._secureStorage.read(key: 'pulse_privkey') ?? '';
          if (pulseKey.isNotEmpty) {
            final seed = Uint8List.fromList(hex.decode(pulseKey));
            final pulsePub = await ed25519PubkeyFromSeed(seed);
            ownPulseAddr = '$pulsePub@$serverUrl';
          }
        } catch (e) {
          debugPrint('[Chat] broadcastSfuCallInvite: failed to derive Pulse pk: $e');
        }
      }
    }
    debugPrint('[Chat] broadcastSfuCallInvite: ownPulseAddr="${ownPulseAddr.isEmpty ? "<empty>" : "${ownPulseAddr.substring(0, ownPulseAddr.length.clamp(0, 24))}…"}"');
    return _c._broadcaster.broadcastSfuInvite(
        group, roomId, token, _c._contacts.contacts,
        isVideoCall: isVideoCall,
        ownPulseAddr: ownPulseAddr);
  }

  /// Broadcast a group's metadata to every member. Optionally include an
  /// `avatar` blob (base64) — it's only sent when actually changed.
  Future<void> broadcastGroupUpdate(Contact group,
      {String? previousName, String? avatar,
      Iterable<String>? recipientMemberIds}) async {
    await _c._broadcaster.broadcastGroupUpdate(group, _c._contacts.contacts,
        avatar: avatar, recipientMemberIds: recipientMemberIds);
    final selfUuid = _c._identity?.id ?? 'self';
    final renamed =
        previousName != null && previousName.isNotEmpty && previousName != group.name;
    final avatarChanged = avatar != null && avatar.isNotEmpty;
    if (renamed || avatarChanged) {
      await _c._insertSystemMessage(group, {
        '_sys': renamed && avatarChanged
            ? 'group_meta_changed'
            : (avatarChanged ? 'group_avatar_changed' : 'group_renamed'),
        if (renamed) 'old': previousName,
        if (renamed) 'new': group.name,
        'by': selfUuid,
      });
      _c._scheduleNotify();
    }
  }

  /// Build (or refresh) the `memberPubkeys` map on a group Contact by
  /// looking up each member's Nostr pubkey from our local contact list.
  Future<Contact> enrichGroupMemberPubkeys(Contact group) async {
    if (!group.isGroup) return group;
    final myUuid = _c._identity?.id ?? '';
    final map = <String, String>{}..addAll(group.memberPubkeys);
    if (myUuid.isNotEmpty && !map.containsKey(myUuid)) {
      final atIdx = _c._selfId.indexOf('@');
      final ownPub = atIdx > 0 ? _c._selfId.substring(0, atIdx) : _c._selfId;
      if (ChatController._hex64.hasMatch(ownPub)) map[myUuid] = ownPub;
    }
    for (final memberId in group.members) {
      if (map.containsKey(memberId)) continue;
      final mc = _c._contacts.findById(memberId);
      if (mc == null) continue;
      final nostrAddrs = mc.transportAddresses['Nostr'] ?? const [];
      if (nostrAddrs.isEmpty) continue;
      final atIdx = nostrAddrs.first.indexOf('@');
      if (atIdx <= 0) continue;
      final pub = nostrAddrs.first.substring(0, atIdx);
      if (ChatController._hex64.hasMatch(pub)) map[memberId] = pub;
    }
    return group.copyWith(memberPubkeys: map);
  }

  /// Creator-only: broadcast an empty-roster tombstone then remove the
  /// group locally.
  Future<void> deleteGroup(Contact group) async {
    if (!group.isGroup) return;
    final recipients = List<String>.from(group.members);
    final tombstone = group.copyWith(members: const <String>[]);
    await _c._broadcaster.broadcastGroupUpdate(
        tombstone, _c._contacts.contacts,
        recipientMemberIds: recipients);
    await _c._contacts.removeContact(group.id);
    _c._invalidateContactIndex();
    _c._scheduleNotify();
    if (!_c._groupUpdatePublicCtrl.isClosed) {
      _c._groupUpdatePublicCtrl.add(SignalGroupUpdateEvent(
          group.id, group.name, const [],
          creatorId: group.creatorId, senderId: _c._selfId));
    }
    debugPrint('[Group] Deleted ${group.name} — tombstone sent to '
        '${recipients.length} recipient(s)');
  }

  /// Rotate the sender key for a group after a member is removed, then
  /// redistribute to all remaining members.
  Future<void> rotateGroupSenderKey(Contact group) async {
    if (!group.isGroup || _c._selfId.isEmpty) return;
    try {
      final sk = SenderKeyService.instance;
      final skdmBytes = await sk.rotateKey(group.id, _c._selfId);
      final skdmB64 = base64Encode(skdmBytes);
      for (final memberId in group.members) {
        final memberContact = _c._contacts.findById(memberId);
        if (memberContact == null) continue;
        final distOk = await _c._sendSignalTo(memberContact, 'sender_key_dist', {
          'groupId': group.id,
          'skdm': skdmB64,
        });
        if (distOk) await sk.markDistributed(group.id, memberId);
        // Also send as a _sys message so Pulse stores it for offline
        // recipients. The signal path (above) is real-time only.
        final skdmSys = jsonEncode({
          '_sys': 'sender_key_dist',
          'p': {'groupId': group.id, 'skdm': skdmB64},
        });
        unawaited(_c._sendToContact(memberContact, skdmSys));
      }
      debugPrint('[SenderKey] Rotated and redistributed key for group ${group.name}');
    } catch (e) {
      debugPrint('[SenderKey] Key rotation failed for group ${group.name}: $e');
    }
  }

  Future<void> markGroupMessagesRead(Contact group) async {
    if (!group.isGroup || _c._identity == null || _c._selfId.isEmpty) return;
    final room = _c._repo.getRoomForContact(group.id);
    if (room == null) return;
    await _c._broadcaster.markGroupMessagesRead(
        group, room.messages, _c._contacts.contacts, _c._selfId);
  }
}
