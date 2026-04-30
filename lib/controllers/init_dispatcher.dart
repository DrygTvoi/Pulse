part of 'chat_controller.dart';

/// Signal dispatcher initialization: registers listeners for group
/// invites, updates, group-call signals, typing/read/edit/delete/
/// reaction signals, and message retry / file-resume control messages.
/// Wired once from [_initializeAdapters] and again on reconnect.
class _DispatcherInitializer {
  final ChatController _c;
  _DispatcherInitializer(this._c);

  void _initSignalDispatcher() {
    _c._signalDispatcher?.dispose();
    for (final s in _c._dispatcherSubs) { s.cancel(); }
    _c._dispatcherSubs.clear();

    _c._signalDispatcher = SignalDispatcher(
      allAddressesGetter: () => _c._allAddresses,
      selfIdGetter: () => _c._selfId,
      contactIndexBuilder: _c._getContactIndex,
      signatureVerifier: _c._verifySignalSignature,
      groupContactResolver: (id) {
        final c = _c._contacts.findById(id);
        return (c != null && c.isGroup) ? c : null;
      },
      rateLimiter: _c._sigRateLimiter,
    );

    final d = _c._signalDispatcher!;

    // PQC confirmation from signals — breaks the chicken-and-egg:
    // receiving a PQC-wrapped signal proves the contact has valid Kyber keys,
    // so we can PQC-wrap messages to them.
    _c._dispatcherSubs.add(d.pqcConfirmed.listen((senderId) {
      _c._pqcConfirmed.add(senderId);
      final prefix = senderId.split('@').first;
      for (final c in _c._contacts.contacts) {
        if (c.databaseId.split('@').first == prefix) {
          _c._pqcConfirmed.add(c.databaseId);
          break;
        }
      }
    }));

    _c._dispatcherSubs.add(d.rawSignals.listen((e) {
      if (!_c._signalStreamController.isClosed) _c._signalStreamController.add(e.signal);
      // Cache webrtc signals so callee can replay them after accepting the call
      final sigType = e.signal['type'] as String? ?? '';
      if (sigType.startsWith('webrtc_')) {
        _c._cacheCallSignal(e.signal);
      }
    }));

    _c._dispatcherSubs.add(d.incomingCalls.listen((e) {
      if (!_c._incomingCallController.isClosed) _c._incomingCallController.add(e.signal);
    }));

    _c._dispatcherSubs.add(d.incomingGroupCalls.listen((e) {
      if (!_c._incomingGroupCallController.isClosed) {
        _c._incomingGroupCallController.add({...e.signal, 'groupId': e.groupId});
      }
      // Conference mode: track the call so members who dismiss the
      // popup (or arrive after the invite landed) can still join via
      // the chat-screen "ongoing call" banner.
      final sigType = e.signal['type'] as String? ?? '';
      if (sigType == 'sfu_invite') {
        final p = e.signal['payload'];
        if (p is Map) {
          final roomId = p['sfuRoomId'] as String? ?? p['room_id'] as String? ?? '';
          final token = p['sfuToken'] as String? ?? p['token'] as String? ?? '';
          final isVideo = p['isVideoCall'] as bool? ?? false;
          final hostId = e.signal['senderId'] as String? ?? '';
          if (roomId.isNotEmpty && token.isNotEmpty) {
            _c._registerActiveGroupCall(e.groupId, roomId, token, hostId,
                isVideoCall: isVideo);
          }
        }
      }
    }));

    // Typing — delegate state to broadcaster, emit on our stream
    _c._dispatcherSubs.add(d.typingEvents.listen((e) {
      final targetId = e.groupId ?? e.contact.id;
      _c._broadcaster.handleTypingEvent(targetId, (id) {
        if (!_c._typingStreamCtrl.isClosed) _c._typingStreamCtrl.add(id);
        _c._scheduleNotify();
      }, memberId: e.groupId != null ? e.contact.id : null);
    }));

    _c._dispatcherSubs.add(d.readReceipts.listen((e) {
      _c._markSenderOnline(e.fromId);
      _c._handleReadReceipt(e.fromId);
    }));

    _c._dispatcherSubs.add(d.groupReadReceipts.listen((e) {
      _c._markSenderOnline(e.fromId);
      _c._handleGroupReadReceipt(e.fromId, e.groupId, e.msgId);
    }));

    _c._dispatcherSubs.add(d.deliveryAcks.listen((e) {
      _c._markSenderOnline(e.fromId);
      _c._handleDeliveryAck(e.fromId, e.msgId, groupId: e.groupId);
    }));

    // Pulse server-confirmed storage ACK → transition 'sending' → 'sent'
    _c._dispatcherSubs.add(pulseServerAcks.listen(_c._handleServerAck));

    _c._dispatcherSubs.add(d.ttlUpdates.listen((e) {
      // For group TTL signals, e.contact is the member who initiated the
      // change; the TTL must be applied to the group chat itself, with that
      // member recorded as the actor in the system notice.
      Contact? target = e.contact;
      if (e.groupId != null) {
        try {
          target = _c._contacts.contacts.firstWhere((c) => c.id == e.groupId);
        } catch (_) {
          target = null;
        }
      }
      if (target == null) return;
      unawaited(_c.setChatTtlSeconds(target, e.seconds,
          sendSignal: false, changedBy: e.contact.id));
    }));

    // Reactions — delegate to repo.
    // Skip self-echoes from relays: the transport-layer senderId may be a
    // bare pubkey or a different relay URL than our _c._selfId, so the naive
    // `${emoji}_${from}` composite key wouldn't match the local one we
    // just wrote in [_c.toggleReaction], and the user would see the reaction
    // twice under two different author identifiers.
    _c._dispatcherSubs.add(d.reactions.listen((e) {
      if (_c._isOwnAddress(e.from)) {
        debugPrint('[Chat] Reaction self-echo ignored: ${e.from}');
        return;
      }
      debugPrint('[Chat] Reaction received: storageKey=${e.storageKey} msgId=${e.msgId} emoji=${e.emoji} from=${e.from} remove=${e.remove}');
      _c._repo.applyRemoteReaction(e.storageKey, e.msgId, '${e.emoji}_${e.from}', e.remove);
      if (e.remove) {
        unawaited(LocalStorageService().removeReaction(e.storageKey, e.msgId, e.emoji, e.from));
      } else {
        unawaited(LocalStorageService().addReaction(e.storageKey, e.msgId, e.emoji, e.from));
      }
      _c._reactionVersions[e.storageKey] = (_c._reactionVersions[e.storageKey] ?? 0) + 1;
      _c._scheduleNotify();
    }));

    _c._dispatcherSubs.add(d.edits.listen((e) {
      debugPrint('[Edit] Received: contact=${e.contact.name} msgId=${e.msgId} text=${e.text.substring(0, e.text.length.clamp(0, 30))} groupId=${e.groupId}');
      final room = e.groupId != null
          ? (_c._repo.getRoomForContact(e.groupId!) ?? _c._repo.getRoomForContact(e.contact.id))
          : _c._repo.getRoomForContact(e.contact.id);
      if (room != null) {
        debugPrint('[Edit] Room found: contactId=${room.contact.id} msgs=${room.messages.length}');
        final idx = _c._repo.messageIndexById(room.contact.id, e.msgId);
        debugPrint('[Edit] Message lookup: idx=$idx msgId=${e.msgId}');
        if (idx != -1) {
          // Only the original sender may edit their own message.
          // Match by Contact record, not raw pubkey: the original message may
          // have been sent via a different transport than the edit (e.g.
          // msg.senderId is a Nostr secp256k1 pubkey, e.contact.databaseId
          // is a Pulse Ed25519 pubkey) — both belong to the same Contact.
          final msg = room.messages[idx];
          final msgBare = msg.senderId.contains('@')
              ? msg.senderId.split('@').first
              : msg.senderId;
          final contactIndex = _c._getContactIndex();
          final msgOwner = contactIndex[msg.senderId]
              ?? contactIndex[msgBare]
              ?? _c._contacts.findByAddress(msg.senderId)
              ?? _c._contacts.findByAddress(msgBare);
          if (msgOwner?.id != e.contact.id) {
            debugPrint('[Edit] Rejected: ${e.contact.name} (${e.contact.id}) '
                'tried to edit message owned by ${msgOwner?.name ?? msg.senderId}');
            return;
          }
          final storageKey = room.contact.storageKey;
          final updated = msg.copyWith(encryptedPayload: e.text, isEdited: true);
          room.messages[idx] = updated;
          unawaited(LocalStorageService().saveMessage(storageKey, updated.toJson()));
          _c._editVersions[storageKey] = (_c._editVersions[storageKey] ?? 0) + 1;
          _c._scheduleNotify();
          debugPrint('[Edit] SUCCESS: updated msgId=${e.msgId}');
        } else {
          debugPrint('[Edit] DROPPED: message not found. First 5 msg IDs: ${room.messages.take(5).map((m) => m.id).toList()}');
        }
      } else {
        debugPrint('[Edit] DROPPED: room not found for contactId=${e.contact.id}');
      }
    }));

    // Heartbeats — update broadcaster's last-seen
    _c._dispatcherSubs.add(d.heartbeats.listen((e) {
      _c._broadcaster.updateLastSeen(e.contact.id);
      _c._scheduleNotify();
    }));

    _c._dispatcherSubs.add(d.keysEvents.listen((e) async {
      final keyChanged = await _c._signalService.buildSession(
          e.contact.databaseId, e.payload);
      _c._keys.cacheContactKyberPk(e.contact.databaseId, e.payload);
      if (keyChanged && !_c._keyChangeCtrl.isClosed) {
        _c._keyChangeCtrl.add((contactName: e.contact.name, contactId: e.contact.databaseId));
      }
      if (keyChanged) {
        // Peer's identity rotated (e.g. reinstall after wipe). Sync the new
        // pubkey into every group's `memberPubkeys` map so subsequent
        // group_delete tombstones, group_update broadcasts, and pairwise
        // sender_key distributions go to the NEW identity instead of the
        // dead old one. Without this, "delete group" silently never
        // reaches a re-installed peer because _resolveGroupRecipients
        // looks up by old pubkey.
        await _c._refreshGroupMembershipForContact(e.contact);
      }
      if (e.contact.provider == 'Session') {
        unawaited(_c._keys.publishSessionKeysTo(e.contact, _c._selfId));
      }
    }));

    // PQC unwrap failure: dispatcher tried to unwrap a PQC2-wrapped signal
    // payload but our Kyber privkey couldn't decrypt it. The peer cached
    // our OLD Kyber pubkey (likely they reinstalled or we did) and keeps
    // wrapping replies for the dead key — every subsequent signal silently
    // gets dropped. Clear `_c._pqcConfirmed` so we stop telling broadcaster
    // to PQC-wrap THEIR replies, drop their cached Kyber so we don't try
    // to wrap, and trigger session_reset so the peer pulls our fresh
    // bundle (which carries our current Kyber pubkey).
    _c._dispatcherSubs.add(d.pqcUnwrapFailed.listen((senderId) async {
      if (senderId.isEmpty) return;
      _c._pqcConfirmed.remove(senderId);
      _c._pqcConfirmed.remove(senderId.split('@').first);
      _c._keys.clearContactKyberPk(senderId);
      // Find the local contact for this sender and push our fresh bundle.
      final idx = _c._getContactIndex();
      final c = idx[senderId] ?? idx[senderId.split('@').first];
      if (c != null) {
        debugPrint('[ChatController] PQC unwrap failed from ${c.name} — '
            'cleared cached Kyber + triggering session_reset with fresh bundle');
        unawaited(_c._pushOwnBundleTo(c));
      } else {
        debugPrint('[ChatController] PQC unwrap failed from unknown $senderId — '
            'cleared cached Kyber, no contact to push to');
      }
    }));

    // Peer-initiated session reset: they failed to decrypt our messages
    // because the prekey we used has been rotated out on their side.
    //
    // Modern peers include their freshly-republished Signal bundle inline
    // in the signal payload. When present, do delete + buildSession
    // atomically so we never race against the peer's own-inbox publish —
    // that race made about half of recoveries pull a stale bundle from a
    // relay that hadn't yet propagated the peer's update.
    //
    // Without inline bundle (legacy peer): just delete; our next encrypt
    // path will fetch their bundle from a relay (slightly racy, but the
    // peer is now expecting the rebuild so timing is more forgiving).
    _c._dispatcherSubs.add(d.sessionResets.listen((e) async {
      // Drop duplicates from the same peer within the cooldown window.
      // `sendSignalToAllTransports` fans out one logical session_reset
      // across every transport, so we see the same payload 5-7 times.
      // Processing each one rebuilds the session, generating a fresh
      // ratchet key, which leaves our just-sent PreKey-init pointing at
      // the previous (now-discarded) ratchet — peer can't decrypt and
      // fires another session_reset, looping forever.
      final lastSeen = _c._lastSessionResetReceived[e.contact.id];
      if (lastSeen != null &&
          DateTime.now().difference(lastSeen) < ChatController._kSessionResetReceiveCooldown) {
        debugPrint('[ChatController] Peer ${e.contact.name} session_reset within '
            'cooldown (${ChatController._kSessionResetReceiveCooldown.inSeconds}s) — ignoring duplicate');
        return;
      }
      _c._lastSessionResetReceived[e.contact.id] = DateTime.now();

      debugPrint('[ChatController] Peer ${e.contact.name} asked for session reset '
          '— clearing session (inlineBundle=${e.bundle != null})');
      await _c._signalService.deleteContactData(e.contact.databaseId);
      final bundle = e.bundle;
      if (bundle != null) {
        try {
          final keyChanged =
              await _c._signalService.buildSession(e.contact.databaseId, bundle);
          _c._keys.cacheContactKyberPk(e.contact.databaseId, bundle);
          if (keyChanged && !_c._keyChangeCtrl.isClosed) {
            _c._keyChangeCtrl
                .add((contactName: e.contact.name, contactId: e.contact.databaseId));
          }
          debugPrint('[ChatController] Built fresh session for ${e.contact.name} '
              'from inline bundle (keyChanged=$keyChanged)');
        } catch (err) {
          debugPrint('[ChatController] buildSession from inline bundle failed: $err');
        }
      }
      // Also suppress our own outgoing session_reset for this peer for the
      // same window — if we just rebuilt against their bundle, our next
      // user-msg PreKey-init carries the answer; firing OUR session_reset
      // back races with that and replaces their fresh session before they
      // can decrypt our PreKey.
      _c._lastStaleKeyPush[e.contact.id] = DateTime.now();
    }));

    _c._dispatcherSubs.add(d.p2pEvents.listen((e) {
      unawaited(P2PTransportService.instance.handleSignal(
          e.contact.id, e.type, e.payload));
    }));

    _c._dispatcherSubs.add(d.relayExchanges.listen((e) async {
      await ChatController.savePeerRelays(e.relays);
    }));

    _c._dispatcherSubs.add(d.turnExchanges.listen((e) async {
      await IceServerConfig.savePeerTurnServers(e.servers);
    }));

    _c._dispatcherSubs.add(d.blossomExchanges.listen((e) async {
      await BlossomService.instance.addPeerServers(e.servers);
    }));

    _c._dispatcherSubs.add(d.statusUpdates.listen((e) async {
      await StatusService.instance.saveContactStatus(e.contact.id, e.status);
      if (!_c._statusUpdatesCtrl.isClosed) {
        _c._statusUpdatesCtrl.add(e.contact.id);
      }
    }));

    _c._dispatcherSubs.add(d.addrUpdates.listen((e) async {
      final addrContact = e.contact;
      final payload = e.rawPayload;
      // Signals arriving via LAN or our own Pulse-relay are trusted channels —
      // a peer announcing a 192.168.x address over those is legitimate (shared
      // LAN / self-hosted relay). Public channels (Nostr, Firebase, Session)
      // leak metadata, so still reject private IPs there.
      final trustedSource =
          e.sourceTransport == 'LAN' || e.sourceTransport == 'Pulse';
      // F3/F4-4: Validate relay addresses — only wss:// and no private IPs
      // when arrived over a public transport.
      bool isValidAltAddr(String addr) {
        final lower = addr.toLowerCase();
        // Session addresses (66-char hex) are always valid
        if (lower.startsWith('05') && lower.length == 66 &&
            RegExp(r'^[0-9a-f]{66}$').hasMatch(lower)) return true;
        if (!lower.contains('@wss://') && !lower.contains('@ws://') &&
            !lower.contains('@https://') && !lower.contains('@http://')) return false;
        try {
          final urlPart = addr.substring(addr.indexOf('@') + 1);
          final uri = Uri.parse(urlPart);
          final h = uri.host;
          if (h.isEmpty || h == '0.0.0.0') return false;
          if (trustedSource) return true;
          if (h == 'localhost' || h == '127.0.0.1' || h == '::1') return false;
          if (h.startsWith('192.168.') || h.startsWith('10.') ||
              h.startsWith('169.254.')) { return false; }
          if (h.startsWith('172.')) {
            final seg = int.tryParse(h.split('.').elementAtOrNull(1) ?? '');
            if (seg != null && seg >= 16 && seg <= 31) return false;
          }
          if (h.startsWith('100.')) {
            final seg = int.tryParse(h.split('.').elementAtOrNull(1) ?? '');
            if (seg != null && seg >= 64 && seg <= 127) return false;
          }
          if (h.startsWith('fc') || h.startsWith('fd')) return false;
        } catch (_) { return false; }
        return true;
      }

      Contact updated;
      debugPrint('[ChatController] addr_update payload keys: ${payload.keys.toList()}'
          '${payload.containsKey('transportAddresses') ? ' ta=${payload['transportAddresses']}' : ''}'
          ' all=${(payload['all'] as List?)?.length ?? 0}');
      if (payload.containsKey('transportAddresses') && payload['transportAddresses'] is Map) {
        // ── New format: per-transport address map ────────────────────────
        final rawTa = payload['transportAddresses'] as Map;
        final ta = <String, List<String>>{};
        for (final entry in rawTa.entries) {
          final transport = entry.key as String;
          final addrs = (entry.value as List).whereType<String>().where(isValidAltAddr).toList();
          if (addrs.isNotEmpty) ta[transport] = addrs;
        }
        final tp = (payload['transportPriority'] as List?)?.whereType<String>().toList()
            ?? ta.keys.toList();
        if (ta.isEmpty) {
          debugPrint('[ChatController] addr_update: empty transportAddresses, ignoring');
          return;
        }
        // UNION-MERGE every transport's address list with what we already
        // have (was Nostr-only — broke pulse-mode groups because the sender
        // briefly sent an addr_update WITHOUT Pulse during startup, which
        // wiped the Pulse address we'd just learned, and the next message
        // failed with "No Pulse pubkey for X"). New addresses go first
        // (fresh primary takes precedence), existing ones backfill, capped
        // at 10 per transport to bound growth. A user genuinely SWITCHING
        // their Pulse/Session server can still happen — the new entries
        // will appear first in the priority order, and stale entries get
        // pruned by health-check / never-acked routing later. This trades
        // a sliver of "switch is instant" UX for "we never lose a learned
        // address mid-flight" reliability.
        for (final transport in {'Nostr', 'Pulse', 'Session', 'Firebase'}) {
          final existing = addrContact.transportAddresses[transport]
              ?? const <String>[];
          final incoming = ta[transport] ?? const <String>[];
          if (incoming.isEmpty && existing.isEmpty) continue;
          final merged = <String>[];
          final seen = <String>{};
          for (final a in incoming) {
            if (seen.add(a)) merged.add(a);
          }
          for (final a in existing) {
            if (merged.length >= 10) break;
            if (seen.add(a)) merged.add(a);
          }
          if (merged.isNotEmpty) ta[transport] = merged;
        }
        updated = addrContact.copyWith(
          transportAddresses: ta,
          transportPriority: tp,
        );
      } else {
        // ── Old format: primary + all flat list → build transport map ────
        final primary = e.primary;
        final all = e.all;
        if (primary.toLowerCase().contains('@wss://') ||
            primary.toLowerCase().contains('@ws://') ||
            primary.toLowerCase().contains('@https://') ||
            primary.toLowerCase().contains('@http://')) {
          if (!isValidAltAddr(primary)) {
            debugPrint('[ChatController] addr_update: invalid primary $primary, ignoring');
            return;
          }
        }
        final allAddrs = <String>{primary, ...all.where(isValidAltAddr)};
        final ta = ChatController._buildTransportMap(allAddrs.toList());
        final primaryTransport = ChatController._providerFromAddress(primary);
        final tp = [primaryTransport, ...ta.keys.where((t) => t != primaryTransport)];
        // Same UNION-MERGE for every transport as in the new-format branch.
        for (final transport in {'Nostr', 'Pulse', 'Session', 'Firebase'}) {
          final existing = addrContact.transportAddresses[transport]
              ?? const <String>[];
          final incoming = ta[transport] ?? const <String>[];
          if (incoming.isEmpty && existing.isEmpty) continue;
          final merged = <String>[];
          final seen = <String>{};
          for (final a in incoming) {
            if (seen.add(a)) merged.add(a);
          }
          for (final a in existing) {
            if (merged.length >= 10) break;
            if (seen.add(a)) merged.add(a);
          }
          if (merged.isNotEmpty) ta[transport] = merged;
        }
        updated = addrContact.copyWith(
          transportAddresses: ta,
          transportPriority: tp,
        );
      }
      // Save Nostr secp256k1 pubkey if provided (needed for HMAC signing
      // even when contact has no Nostr relay address).
      final nostrPub = payload['nostrPubkey'] as String?;
      if (nostrPub != null && nostrPub.isNotEmpty) {
        updated = updated.copyWith(publicKey: nostrPub);
      }
      // Ensure the contact has a Nostr fallback address for routing.
      updated = await _c._ensureNostrFallback(updated);
      await _c._contacts.updateContact(updated);
      _c._invalidateContactIndex();
      debugPrint('[ChatController] addr_update: ${addrContact.name} → ${updated.databaseId}'
          ' session=${updated.transportAddresses['Session'] ?? []}');
      _c._scheduleNotify();
    }));

    _c._dispatcherSubs.add(d.profileUpdates.listen((e) async {
      final profileContact = e.contact;
      bool changed = false;
      Contact updated = profileContact;
      if (e.about != profileContact.bio) {
        updated = updated.copyWith(bio: e.about);
        changed = true;
      }
      if (e.avatarB64.isNotEmpty) {
        await LocalStorageService().saveAvatar(profileContact.id, e.avatarB64);
        changed = true;
      }
      if (changed) {
        await _c._contacts.updateContact(updated);
        _c._invalidateContactIndex();
        _c._scheduleNotify();
      }
    }));

    _c._dispatcherSubs.add(d.chunkRequests.listen((e) {
      unawaited(_c._resendMissingChunks(e.fid, e.missing, e.senderId));
    }));

    _c._dispatcherSubs.add(d.groupInvites.listen((e) {
      debugPrint('[ChatController] relay group_invite from dispatcher: '
          'group="${e.groupName}" id=${e.groupId} from=${e.fromContact.name} '
          'publicCtrlClosed=${_c._groupInviteCtrl.isClosed} '
          'publicCtrlHasListener=${_c._groupInviteCtrl.hasListener}');
      if (!_c._groupInviteCtrl.isClosed) _c._groupInviteCtrl.add(e);
    }));

    _c._dispatcherSubs.add(d.groupInviteDeclines.listen((e) {
      if (!_c._groupInviteDeclineCtrl.isClosed) _c._groupInviteDeclineCtrl.add(e);
    }));

    _c._dispatcherSubs.add(d.msgDeletes.listen((e) {
      _c._handleRemoteDelete(e.fromId, e.msgId, groupId: e.groupId);
    }));

    _c._dispatcherSubs.add(d.groupUpdates.listen((e) async {
      // Drop loop-back broadcasts: every transport (Pulse server especially)
      // can echo our own kind:1059 / signed envelope back to us. Without
      // this filter the sender would re-apply their own change and emit a
      // duplicate "<self> renamed group" system notice.
      if (_c._isOwnAddress(e.senderId)) return;
      final g = _c._contacts.findById(e.groupId);
      if (g == null || !g.isGroup) return;
      final group = g;
      // NOTE: the old "senderUuid == group.creatorId" guard compared a
      // locally-generated contact UUID against the creator's own-identity
      // UUID on their device — cross-device UUIDs never match, so every
      // legitimate roster update was rejected. Signal-layer auth (Schnorr
      // on Nostr, HMAC on other transports) already proves the payload
      // was sent by the holder of e.senderId's private key; trusting it
      // is sufficient for the force-accept baseline. Pubkey-based
      // identity checks will replace this in a later step.
      debugPrint('[Group] group_update from ${e.senderId} for ${group.name}: '
          '${e.members.length} members');

      // Tombstone / self-kick: if we are no longer in the roster (or
      // the roster is empty, which is how the creator signals "group
      // deleted"), drop the group locally. Emits on _c._groupUpdatePublicCtrl
      // so any open chat screen + the home list both refresh.
      final myUuid = _c._identity?.id ?? '';
      final weWereMember = myUuid.isNotEmpty && group.members.contains(myUuid);
      final weStillMember = myUuid.isNotEmpty && e.members.contains(myUuid);
      if (e.members.isEmpty || (weWereMember && !weStillMember)) {
        await _c._contacts.removeContact(group.id);
        _c._invalidateContactIndex();
        debugPrint('[Group] ${group.name} '
            '${e.members.isEmpty ? "deleted by creator" : "kicked us"} '
            '— removed locally');
        if (!_c._groupUpdatePublicCtrl.isClosed) _c._groupUpdatePublicCtrl.add(e);
        _c._scheduleNotify();
        return;
      }

      final memberRemoved = group.members.toSet().difference(e.members.toSet()).isNotEmpty;
      // Merge incoming memberPubkeys with what we already know: the
      // creator may re-issue an update with the same mapping, or extend
      // it for newly-added members. Keep any entry we already have for
      // members still present; replace/add entries from the payload.
      final mergedPubkeys =
          Map<String, String>.from(group.memberPubkeys)
            ..addAll(e.memberPubkeys)
            ..removeWhere((k, _) => !e.members.contains(k));
      // Detect what actually changed so we can emit a Telegram-style
      // in-chat notice. Empty groupName / empty avatar in the signal mean
      // "no change" — only the fields that the sender actually populated
      // are treated as updates.
      final newName = e.groupName.isNotEmpty ? e.groupName : group.name;
      final nameChanged =
          e.groupName.isNotEmpty && e.groupName != group.name;
      final avatarChanged = e.avatar.isNotEmpty;
      // Inherit creator's transport mode + Pulse server, but only when the
      // payload populated them — empty string in the signal means "no
      // change", we keep whatever we already have. Lets the creator switch
      // a group between mesh/pulse after the fact (rare but supported).
      final newTransportMode = e.groupTransportMode.isNotEmpty
          ? e.groupTransportMode : group.groupTransportMode;
      final newServerUrl = e.groupServerUrl.isNotEmpty
          ? e.groupServerUrl : group.groupServerUrl;
      final newServerInvite = e.groupServerInvite.isNotEmpty
          ? e.groupServerInvite : group.groupServerInvite;
      final updated = group.copyWith(
        name: newName,
        members: e.members,
        creatorId: group.creatorId ?? e.creatorId,
        memberPubkeys: mergedPubkeys,
        groupTransportMode: newTransportMode,
        groupServerUrl: newServerUrl,
        groupServerInvite: newServerInvite,
      );
      await _c._contacts.updateContact(updated);
      if (avatarChanged) {
        try {
          await LocalStorageService().saveAvatar(group.id, e.avatar);
        } catch (err) {
          debugPrint('[Group] failed to save avatar: $err');
        }
      }
      _c._invalidateContactIndex();
      await _c._ensurePendingContactsForMembers(
          mergedPubkeys, e.memberAddresses, memberNames: e.memberNames);
      // Same Pulse-pubkey bootstrap as in _c.acceptGroupInvite — group_update
      // is the primary delivery path for "members got added" after the
      // initial invite, so newcomers' pubkeys arrive here.
      if (updated.isPulseGroup &&
          updated.groupServerUrl.isNotEmpty &&
          e.memberPulsePubkeys.isNotEmpty) {
        await _c._seedMemberPulseAddresses(
            e.memberPulsePubkeys, mergedPubkeys, updated.groupServerUrl);
      }
      // Promote any "Member <pubkey>" placeholders to the inviter-provided
      // name. Only renames placeholders — never overwrites a name the user
      // chose locally.
      if (e.memberNames.isNotEmpty) {
        await _c._promotePlaceholderNames(e.memberNames, mergedPubkeys);
      }
      debugPrint('[Group] Membership updated for ${updated.name}: ${e.members.length} members');
      if (memberRemoved && _c._selfId.isNotEmpty) {
        unawaited(_c.rotateGroupSenderKey(updated));
      }
      if (nameChanged || avatarChanged) {
        await _c._insertSystemMessage(updated, {
          '_sys': avatarChanged && nameChanged
              ? 'group_meta_changed'
              : (avatarChanged ? 'group_avatar_changed' : 'group_renamed'),
          if (nameChanged) 'old': group.name,
          if (nameChanged) 'new': newName,
          'by': e.senderId,
        });
      }
      if (!_c._groupUpdatePublicCtrl.isClosed) _c._groupUpdatePublicCtrl.add(e);
      _c._scheduleNotify();
    }));

    _c._dispatcherSubs.add(d.senderKeyDists.listen((e) async {
      try {
        // Reject SKDM from contacts not in the group.
        final sg = _c._contacts.findById(e.groupId);
        final skdmGroup = (sg != null && sg.isGroup) ? sg : null;
        // F5: Reject SKDM for unknown groups (null skdmGroup) AND from non-members.
        // Old guard `skdmGroup != null && !members.contains(...)` accepted all
        // distributions for unknown group IDs (skdmGroup == null → guard skipped).
        // An attacker could inject key material for arbitrary groupIds.
        if (skdmGroup == null ||
            !_c._isSenderInGroup(skdmGroup, e.fromContact)) {
          debugPrint('[SenderKey] Rejected SKDM from non-member '
              '${e.fromContact.name} for group ${e.groupId}');
          return;
        }
        final skdmBytes = base64Decode(e.skdmB64);
        await SenderKeyService.instance.processDistribution(
            e.groupId, e.fromContact.databaseId, skdmBytes);
        debugPrint('[SenderKey] Received distribution from ${e.fromContact.name} for group ${e.groupId}');
      } catch (err) {
        debugPrint('[SenderKey] Failed to process distribution: $err');
      }
    }));
  }
}
