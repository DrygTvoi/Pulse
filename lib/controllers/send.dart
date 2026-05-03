part of 'chat_controller.dart';

/// Core message-send pipeline: encryption (Signal + PQC), transport-
/// priority routing, group fan-out with Sender Key, and Pulse-server
/// delivery. Extracted from ChatController to keep the god file
/// manageable.
///
/// State fields (`_identity`, `_repo`, `_keys`, `_pqcConfirmed`, …)
/// stay on ChatController and are accessed via `_c._field`.
class _SendPipeline {
  final ChatController _c;
  _SendPipeline(this._c);

  // ═══════════════════════════════════════════════════════════════════════════
  // sendMessage — public entry point for UI / media / group sends
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> sendMessage(Contact rawContact, String text, {
    bool noAutoRetry = false,
    Message? replyTo,
  }) async {
    if (_c._identity == null) return;
    // Always route with the freshest Contact record from the repo. The
    // UI layer (ChatScreen) caches the Contact it was opened with and
    // keeps using it for sends; addr_update signals that rewrite
    // transportAddresses / primary relay therefore never reach the send
    // path, and messages keep going to the stale relay the contact
    // migrated away from.
    final contact = _c._contacts.findById(rawContact.id) ?? rawContact;

    if (contact.isGroup) {
      final groupRoom = _c._repo.getOrCreateRoom(contact);
      final localMsg = Message(
        id: ChatController._uuid.v4(), senderId: _c._identity!.id, receiverId: contact.id,
        encryptedPayload: text, timestamp: DateTime.now(),
        adapterType: 'group', isRead: true, status: 'sending',
        replyToId: replyTo?.id,
        replyToText: replyTo?.encryptedPayload.substring(0, replyTo.encryptedPayload.length.clamp(0, 80)),
        replyToSender: replyTo?.senderId,
      );
      groupRoom.messages.add(localMsg);
      _c._repo.trackMessageId(contact.id, localMsg.id);
      _c._scheduleNotify();

      final groupMap = <String, dynamic>{'_group': contact.id, 'text': text};
      if (replyTo != null) {
        groupMap['_replyToId'] = replyTo.id;
        groupMap['_replyToText'] = replyTo.encryptedPayload.length > 80
            ? replyTo.encryptedPayload.substring(0, 80)
            : replyTo.encryptedPayload;
        groupMap['_replyToSender'] = replyTo.senderId;
      }
      final groupPayload = jsonEncode(groupMap);

      // Resolve every group member UUID to a Contact we can actually send
      // to. Members are identified cross-device by their Nostr pubkey
      // (stored in `contact.memberPubkeys[uuid]`) — local UUIDs differ per
      // device so `findById` alone misses every non-self-added peer.
      // Skip our own UUID (no self-send) and any member we can't resolve.
      //
      // `members[]` on the invitee's device does NOT include the creator
      // (creators only list the people they invited), so we pull the
      // creator in separately via `creatorId`.
      final myUuid = _c._identity?.id ?? '';
      final selfId = _c._selfId;
      final ownPubAt = selfId.indexOf('@');
      final ownPub =
          (ownPubAt > 0 ? selfId.substring(0, ownPubAt) : selfId).toLowerCase();
      final recipients = <Contact>[];
      final seenIds = <String>{};
      var dropped = 0;
      final memberIds = <String>[
        if (contact.creatorId != null && contact.creatorId!.isNotEmpty)
          contact.creatorId!,
        ...contact.members,
      ];
      for (final memberId in memberIds) {
        if (memberId == myUuid) continue;
        Contact? mc = _c._contacts.findById(memberId);
        if (mc == null) {
          final pub = contact.memberPubkeys[memberId];
          if (pub != null && pub.isNotEmpty) {
            if (pub.toLowerCase() == ownPub) continue; // pubkey is ours
            mc = _c._contacts.findByPubkey(pub);
          }
        }
        if (mc == null) {
          dropped++;
          debugPrint('[Group] unresolvable member uuid=$memberId '
              'pubkey=${contact.memberPubkeys[memberId] ?? "(missing)"}');
          continue;
        }
        if (!seenIds.add(mc.id)) continue; // dedup (creator also in members)
        recipients.add(mc);
      }

      // For pulse-mode groups, ensure we're connected to the host's Pulse
      // server before fan-out. Fast no-op once warmed up; first call after
      // app start pays ~1-3s for WS auth + PoW. Done up here so both the
      // sender-key and pairwise paths benefit.
      final isPulseRouted =
          contact.isPulseGroup && contact.groupServerUrl.isNotEmpty;
      if (isPulseRouted) {
        await _c.ensureGroupPulseConnection(contact.groupServerUrl);
      }

      // ── Sender Key path: only when every member UUID resolves via
      //    findById on THIS device. Otherwise the SenderKeyService's
      //    UUID-keyed distribution tracking (`markDistributed`,
      //    `allMembersHaveKey`) breaks silently and we'd issue redundant
      //    SKDMs / encrypt with a mismatched identifier domain. The
      //    pairwise fallback below handles mixed-roster groups; a
      //    proper pubkey-keyed SK refactor is a separate task.
      int sent = 0;
      bool usedSenderKey = false;
      final localOnly = contact.members
          .every((id) => id == myUuid || _c._contacts.findById(id) != null);
      if (localOnly) {
        try {
          final sk = SenderKeyService.instance;
          if (!await sk.allMembersHaveKey(contact.id, contact.members)) {
            final skdmBytes = await sk.createDistribution(contact.id, _c._selfId);
            final skdmB64 = base64Encode(skdmBytes);
            for (final memberContact in recipients) {
              final distOk = isPulseRouted
                  ? await _sendSignalToContactViaPulseServer(
                      memberContact, 'sender_key_dist', {
                      'groupId': contact.id,
                      'skdm': skdmB64,
                    }, contact.groupServerUrl)
                  : await _c._sendSignalTo(memberContact, 'sender_key_dist', {
                      'groupId': contact.id,
                      'skdm': skdmB64,
                    });
              if (distOk) await sk.markDistributed(contact.id, memberContact.id);
              // Also send as a _sys message so Pulse stores it for offline
              // recipients. The signal path (above) is real-time only;
              // offline members need a stored copy.
              final skdmSys = jsonEncode({
                '_sys': 'sender_key_dist',
                'p': {'groupId': contact.id, 'skdm': skdmB64},
              });
              unawaited(_sendToContact(memberContact, skdmSys));
            }
          }
          final plainBytes = Uint8List.fromList(utf8.encode(groupPayload));
          final cipherBytes = await sk.encrypt(contact.id, _c._selfId, plainBytes);
          final skEnvelope = jsonEncode({
            '_sk': true,
            '_group': contact.id,
            'ct': base64Encode(cipherBytes),
          });
          for (final memberContact in recipients) {
            final ok = isPulseRouted
                ? await _sendToContactViaPulseServer(
                    memberContact, skEnvelope, contact.groupServerUrl)
                : await _sendToContact(memberContact, skEnvelope,
                    noAutoRetry: noAutoRetry);
            if (ok) sent++;
          }
          usedSenderKey = true;
        } catch (e) {
          debugPrint('[SenderKey] Encrypt failed, falling back to per-member: $e');
        }
      } else {
        debugPrint('[Group] mixed-roster group — using pairwise pathway '
            '(${recipients.length} recipients, $dropped dropped)');
      }
      if (!usedSenderKey) {
        sent = 0;
        for (final memberContact in recipients) {
          final ok = isPulseRouted
              ? await _sendToContactViaPulseServer(
                  memberContact, groupPayload, contact.groupServerUrl)
              : await _sendToContact(memberContact, groupPayload,
                  noAutoRetry: noAutoRetry);
          if (ok) sent++;
        }
      }
      debugPrint('[Group] send id=${localMsg.id} group=${contact.id} '
          'recipients=${recipients.length} sent=$sent dropped=$dropped '
          'sk=$usedSenderKey');

      final finalStatus = sent > 0 ? 'sent' : 'failed';
      final idx = _c._repo.messageIndexById(contact.id, localMsg.id);
      final finalMsg = localMsg.copyWith(status: finalStatus);
      if (idx != -1) groupRoom.messages[idx] = finalMsg;
      await LocalStorageService().saveMessage(contact.id, finalMsg.toJson());
      final ttl = _c._repo.getChatTtlCached(contact.id);
      if (ttl > 0) _c._repo.scheduleTtlDelete(contact, finalMsg, ttl, onDeleted: () { if (!_c._disposed) _c._scheduleNotify(); });
      _c._scheduleNotify();
      return;
    }

    ({String id, String text, String sender})? replyInfo;
    if (replyTo != null) {
      final preview = replyTo.encryptedPayload.length > 80
          ? replyTo.encryptedPayload.substring(0, 80)
          : replyTo.encryptedPayload;
      replyInfo = (id: replyTo.id, text: preview, sender: replyTo.senderId);
    }

    // Create local message FIRST so it appears in UI immediately.
    final msgId = ChatController._uuid.v4();
    final contactAdapterType = contact.provider == 'Nostr' ? 'nostr'
        : contact.provider == 'Session' ? 'session'
        : 'pulse';
    final room = _c._repo.getOrCreateRoom(contact);
    final localMsg = Message(
      id: msgId, senderId: _c._identity!.id, receiverId: contact.id,
      encryptedPayload: text, timestamp: DateTime.now(),
      adapterType: contactAdapterType, isRead: true, status: 'sending',
      replyToId: replyInfo?.id,
      replyToText: replyInfo?.text,
      replyToSender: replyInfo?.sender,
    );
    room.messages.add(localMsg);
    _c._repo.trackMessageId(contact.id, localMsg.id);
    final localTtl = _c._repo.getChatTtlCached(contact.id);
    if (localTtl > 0) _c._repo.scheduleTtlDelete(contact, localMsg, localTtl, onDeleted: () { if (!_c._disposed) _c._scheduleNotify(); });
    _c._scheduleNotify();

    final envelope = MessageEnvelope.wrap(
      _c._selfId.isNotEmpty ? _c._selfId : _c._identity!.id, text,
      msgId: msgId, replyTo: replyInfo,
      senderName: _c._selfName,
      senderAvatar: _c._selfAvatar,
      senderAddresses: _c._buildOwnTransportMap());

    String encryptedText;
    try {
      debugPrint('[Send] Encrypting for ${contact.name} (${contact.databaseId.substring(0, 8)}…)');
      encryptedText = await _c._signalService.encryptMessage(contact.databaseId, envelope);
      debugPrint('[Send] Encrypted OK for ${contact.name}');
    } catch (e) {
      debugPrint('[E2EE] Encrypt failed: $e — rebuilding session');
      try {
        final ourApiKey = _c._identity!.adapterConfig['token'] ?? '';
        InboxReader contactReader;
        String initApiKey = ourApiKey;
        String initDbId = contact.databaseId;
        if (contact.provider == 'Nostr') {
          contactReader = NostrInboxReader();
          initApiKey = '';
          initDbId = contact.databaseId;
        } else if (contact.provider == 'Session') {
          contactReader = SessionInboxReader();
          final prefs = await _c._getPrefs();
          initApiKey = prefs.getString('session_node_url') ?? prefs.getString('oxen_node_url') ?? '';
          initDbId = contact.databaseId;
          unawaited(_c._keys.publishSessionKeysTo(contact, _c._selfId));
        } else if (contact.provider == 'Pulse') {
          contactReader = PulseInboxReader();
          final privkey = await ChatController._secureStorage.read(key: 'pulse_privkey') ?? '';
          final prefs = await _c._getPrefs();
          var serverUrl = prefs.getString('pulse_server_url') ?? '';
          final pAt = contact.databaseId.indexOf('@');
          if (pAt != -1) {
            final s = contact.databaseId.substring(pAt + 1);
            if (s.startsWith('https://') || s.startsWith('http://')) serverUrl = s;
          }
          initApiKey = jsonEncode({'privkey': privkey, 'serverUrl': serverUrl});
          initDbId = contact.databaseId;
        } else {
          throw Exception('Unknown provider: ${contact.provider}');
        }
        debugPrint('[E2EE] Fetching bundle for ${contact.name} via ${contact.provider}');
        debugPrint('[E2EE] transportAddresses=${contact.transportAddresses}');

        // ── Key fetch strategy: Nostr relays first, then other transports ──
        // Session swarm cannot be read by others (requires owner auth), so we
        // push our keys into the contact's Session inbox instead (below).
        Map<String, dynamic>? bundle;

        // Priority 1: Try ALL Nostr relays the contact has.
        final nostrAddrs = contact.transportAddresses['Nostr'] ?? [];
        for (final addr in nostrAddrs) {
          if (bundle != null) break;
          final reader = NostrInboxReader();
          try {
            await reader.initializeReader('', addr);
            debugPrint('[E2EE] Trying Nostr: $addr');
            bundle = await reader.fetchPublicKeys();
            if (bundle != null) {
              debugPrint('[E2EE] Key fetch OK via Nostr ($addr)');
            }
          } catch (e) {
            debugPrint('[E2EE] Nostr key fetch failed ($addr): $e');
          } finally {
            // Close so this temp reader stops intercepting our gift wraps
            // on its orphan _msgCtrl (no listener → silent message drop).
            try { reader.close(); } catch (_) {}
          }
        }

        // Priority 2: contact's primary transport (if not Nostr).
        if (bundle == null && contact.provider != 'Nostr') {
          try {
            await contactReader.initializeReader(initApiKey, initDbId);
            debugPrint('[E2EE] Trying ${contact.provider} primary...');
            bundle = await contactReader.fetchPublicKeys();
          } finally {
            try {
              if (contactReader is NostrInboxReader) contactReader.close();
              else if (contactReader is PulseInboxReader) contactReader.close();
              else if (contactReader is SessionInboxReader) contactReader.close();
            } catch (_) {}
          }
        }

        // Priority 3: well-known Nostr relays (key may exist on a relay we don't know about).
        if (bundle == null) {
          // Extract contact's Nostr pubkey from any Nostr address.
          String contactPubkey = '';
          for (final addr in nostrAddrs) {
            final atIdx = addr.indexOf('@');
            if (atIdx > 0) { contactPubkey = addr.substring(0, atIdx); break; }
          }
          if (contactPubkey.isNotEmpty) {
            final knownRelays = nostrAddrs.map((a) {
              final i = a.indexOf('@');
              return i > 0 ? a.substring(i + 1) : '';
            }).where((r) => r.isNotEmpty).toSet();
            final fallbackRelays = await gatherKnownRelays(
              knownRelays.isNotEmpty ? knownRelays.first : '', limit: 5);
            for (final relay in fallbackRelays) {
              if (knownRelays.contains(relay)) continue;
              final altReader = NostrInboxReader();
              try {
                await altReader.initializeReader('', '$contactPubkey@$relay');
                debugPrint('[E2EE] Trying fallback Nostr relay: $relay');
                final altBundle = await altReader.fetchPublicKeys();
                if (altBundle != null) {
                  debugPrint('[E2EE] Key fetch OK via fallback relay $relay');
                  bundle = altBundle;
                  break;
                }
              } catch (e) {
                debugPrint('[E2EE] Fallback key fetch from $relay failed: $e');
              } finally {
                try { altReader.close(); } catch (_) {}
              }
            }
          }
        }

        // Priority 4: any remaining alternate transport (Pulse).
        if (bundle == null && contact.alternateAddresses.isNotEmpty) {
          for (final alt in contact.alternateAddresses) {
            final altProvider = ChatController._providerFromAddress(alt);
            if (altProvider.isEmpty || altProvider == contact.provider || altProvider == 'Session') continue;
            try {
              final altBundle = await _c._fetchKeysFromAddress(alt, altProvider);
              if (altBundle != null) {
                debugPrint('[E2EE] Fallback key fetch OK via $altProvider');
                bundle = altBundle;
                break;
              }
            } catch (e) {
              debugPrint('[E2EE] Fallback key fetch from $altProvider failed: $e');
            }
          }
        }

        // Push our own keys to contact's Session inbox so they can build a
        // session for replying (Session inbox is write-by-anyone, read-by-owner).
        final sessionAddrs = contact.transportAddresses['Session'] ?? [];
        if (sessionAddrs.isNotEmpty) {
          unawaited(_c._keys.publishSessionKeysTo(contact, _c._selfId));
        }
        debugPrint('[E2EE] fetchPublicKeys: ${bundle != null ? "${bundle.keys.length} keys" : "null"}');
        if (bundle != null) {
          final keyChanged = await _c._signalService.buildSession(contact.databaseId, bundle);
          _c._keys.cacheContactKyberPk(contact.databaseId, bundle);
          if (keyChanged && !_c._keyChangeCtrl.isClosed) {
            _c._keyChangeCtrl.add((contactName: contact.name, contactId: contact.databaseId));
          }
          debugPrint('[E2EE] Session built, re-encrypting...');
          encryptedText = await _c._signalService.encryptMessage(contact.databaseId, envelope);
          debugPrint('[E2EE] Session rebuilt OK');
        } else {
          debugPrint('[E2EE] No key bundle for ${contact.name} — send aborted');
          if (!_c._e2eeFailCtrl.isClosed) _c._e2eeFailCtrl.add(contact.name);
          final idx = _c._repo.messageIndexById(contact.id, msgId);
          if (idx != -1) room.messages[idx] = localMsg.copyWith(status: 'failed');
          await LocalStorageService().saveMessage(contact.id, localMsg.copyWith(status: 'failed').toJson());
          _c._scheduleNotify();
          return;
        }
      } catch (e2) {
        debugPrint('[E2EE] Session build failed for ${contact.name}: $e2 — send aborted');
        sentryBreadcrumb('E2EE session build failed', category: 'encryption');
        if (!_c._e2eeFailCtrl.isClosed) _c._e2eeFailCtrl.add(contact.name);
        final idx = _c._repo.messageIndexById(contact.id, msgId);
        if (idx != -1) room.messages[idx] = localMsg.copyWith(status: 'failed');
        await LocalStorageService().saveMessage(contact.id, localMsg.copyWith(status: 'failed').toJson());
        _c._scheduleNotify();
        return;
      }
    }

    if (encryptedText.startsWith('E2EE||') &&
        _c._pqcConfirmed.contains(contact.databaseId)) {
      encryptedText = await _c._keys.pqcWrap(encryptedText, contact.databaseId);
    }

    final msg = Message(
      id: msgId,
      senderId: _c._selfId.isNotEmpty ? _c._selfId : _c._identity!.id,
      receiverId: contact.databaseId,
      encryptedPayload: encryptedText,
      timestamp: localMsg.timestamp,
      adapterType: contactAdapterType,
    );

    debugPrint('[Send] Routing to ${contact.name}...');
    await _c._addSenderPlugin(contact);
    final _devPrefs = await _c._getPrefs();
    final devModeOn = _devPrefs.getBool('dev_mode_enabled') ?? false;

    // Transport-priority routing: iterate transports in priority order,
    // try each address within a transport before moving to the next transport.
    bool sent = false;

    // P2P shortcut — try direct connection first regardless of transport.
    if (!contact.isGroup && P2PTransportService.instance.isConnected(contact.id)) {
      sent = P2PTransportService.instance.send(contact.id, msg.encryptedPayload);
      if (sent) {
        debugPrint('[P2P] Direct delivery to ${contact.name}');
        _c._lastDeliveryTransport[contact.id] = 'P2P';
      }
    }

    if (!sent) {
      for (final transport in _c._rankedTransportsFor(contact)) {
        if (devModeOn && !(_devPrefs.getBool('dev_adapter_$transport') ?? true)) {
          debugPrint('[Dev] Adapter $transport disabled — skipping');
          continue;
        }
        final addresses = contact.transportAddresses[transport] ?? [];
        for (final addr in addresses) {
          sent = await _deliverEncryptedMessage(addr, msg);
          if (sent) {
            debugPrint('[SmartRouter] Delivered via $transport: $addr');
            _c._lastDeliveryTransport[contact.id] = transport;
            break;
          }
        }
        if (sent) break;
      }
    }

    debugPrint('[Send] Route result: ${sent ? "SENT" : "FAILED"} for ${contact.name}');
    final idx = _c._repo.messageIndexById(contact.id, msg.id);
    final finalMsg = localMsg.copyWith(status: sent ? 'sent' : 'failed');
    if (idx != -1) room.messages[idx] = finalMsg;
    await LocalStorageService().saveMessage(contact.storageKey, finalMsg.toJson());
    _c._scheduleNotify();
    if (!sent && !noAutoRetry) _c._scheduleAutoRetry(contact, finalMsg);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // _deliverEncryptedMessage — adapter-level dispatch for one address
  // ═══════════════════════════════════════════════════════════════════════════

  Future<bool> _deliverEncryptedMessage(String address, Message msg) async {
    if (_c._identity == null) return false;
    final provider = ChatController._providerFromAddress(address);
    // Developer mode: skip disabled adapters.
    final prefs = await _c._getPrefs();
    if ((prefs.getBool('dev_mode_enabled') ?? false) &&
        !(prefs.getBool('dev_adapter_$provider') ?? true)) {
      debugPrint('[Dev] Adapter $provider disabled — skipping deliver to $address');
      return false;
    }
    final sendMsg = Message(
      id: msg.id,
      senderId: msg.senderId,
      receiverId: msg.receiverId,
      encryptedPayload: msg.encryptedPayload,
      timestamp: msg.timestamp,
      adapterType: provider.toLowerCase(),
    );
    final ourApiKey = _c._identity!.adapterConfig['token'] ?? '';
    if (provider == 'Nostr') {
      final privkey = await _c._getNostrPrivkey();
      final prefs = await _c._getPrefs();
      final atIdx = address.indexOf('@');
      final relay = atIdx != -1
          ? address.substring(atIdx + 1)
          : _c._identity?.adapterConfig['relay'] ?? ChatController._kDefaultNostrRelay;
      _c._cachedNostrSender ??= NostrMessageSender();
      await InboxManager().addSenderPlugin('Nostr', _c._cachedNostrSender!,
          jsonEncode({'privkey': privkey, 'relay': relay}));
    } else if (provider == 'Session') {
      final prefs = await _c._getPrefs();
      final nodeUrl = prefs.getString('session_node_url') ?? prefs.getString('oxen_node_url') ?? '';
      await InboxManager().addSenderPlugin('Session', SessionMessageSender(), nodeUrl);
    } else if (provider == 'Pulse') {
      final privkey = await ChatController._secureStorage.read(key: 'pulse_privkey') ?? '';
      final prefs = await _c._getPrefs();
      // Extract server URL from the recipient address
      var serverUrl = prefs.getString('pulse_server_url') ?? '';
      final pAtIdx = address.indexOf('@');
      if (pAtIdx != -1) {
        final addrServer = address.substring(pAtIdx + 1);
        if (addrServer.startsWith('https://') || addrServer.startsWith('http://')) {
          serverUrl = addrServer;
        }
      }
      _c._cachedPulseSender ??= PulseMessageSender();
      await InboxManager().addSenderPlugin('Pulse', _c._cachedPulseSender!,
          jsonEncode({'privkey': privkey, 'serverUrl': serverUrl}));
    } else {
      return false;
    }
    return InboxManager().routeMessage(provider, address, address, sendMsg);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // _sendToContact — encrypt + route to a single 1-on-1 contact
  // ═══════════════════════════════════════════════════════════════════════════

  Future<bool> _sendToContact(Contact rawContact, String plaintext, {bool noAutoRetry = false}) async {
    if (_c._identity == null) return false;
    // Route with the freshest Contact — caller may hold a stale copy.
    final contact = _c._contacts.findById(rawContact.id) ?? rawContact;
    final envelope = MessageEnvelope.wrap(_c._selfId.isNotEmpty ? _c._selfId : _c._identity!.id, plaintext, senderName: _c._selfName, senderAvatar: _c._selfAvatar, senderAddresses: _c._buildOwnTransportMap());
    String encryptedText;
    try {
      encryptedText = await _c._signalService.encryptMessage(contact.databaseId, envelope);
    } catch (e) {
      debugPrint('[E2EE] encryptMessage failed for ${contact.name} — attempting session rebuild: $e');
      try {
        final ourApiKey = _c._identity!.adapterConfig['token'] ?? '';
        InboxReader contactReader;
        String initApiKey = ourApiKey;
        String initDbId = contact.databaseId;
        if (contact.provider == 'Nostr') {
          contactReader = NostrInboxReader();
          initApiKey = '';
        } else if (contact.provider == 'Session') {
          contactReader = SessionInboxReader();
          final prefs = await _c._getPrefs();
          initApiKey = prefs.getString('session_node_url') ?? prefs.getString('oxen_node_url') ?? '';
          unawaited(_c._keys.publishSessionKeysTo(contact, _c._selfId));
        } else if (contact.provider == 'Pulse') {
          contactReader = PulseInboxReader();
          final privkey = await ChatController._secureStorage.read(key: 'pulse_privkey') ?? '';
          final prefs = await _c._getPrefs();
          var serverUrl = prefs.getString('pulse_server_url') ?? '';
          final pAt = contact.databaseId.indexOf('@');
          if (pAt != -1) {
            final s = contact.databaseId.substring(pAt + 1);
            if (s.startsWith('https://') || s.startsWith('http://')) serverUrl = s;
          }
          initApiKey = jsonEncode({'privkey': privkey, 'serverUrl': serverUrl});
        } else {
          return false;
        }
        Map<String, dynamic>? bundle;
        final sessionAddrs = contact.transportAddresses['Session'] ?? [];
        if (sessionAddrs.isNotEmpty) {
          final sr = SessionInboxReader();
          try {
            final prefs = await _c._getPrefs();
            final nodeUrl = prefs.getString('session_node_url') ?? prefs.getString('oxen_node_url') ?? '';
            await sr.initializeReader(nodeUrl, sessionAddrs.first);
            bundle = await sr.fetchPublicKeys();
            if (bundle != null) debugPrint('[E2EE] Group key fetch OK via Session');
          } catch (_) {} finally {
            try { sr.close(); } catch (_) {}
          }
        }
        if (bundle == null) {
          try {
            await contactReader.initializeReader(initApiKey, initDbId);
            bundle = await contactReader.fetchPublicKeys();
          } finally {
            try {
              if (contactReader is NostrInboxReader) contactReader.close();
              else if (contactReader is PulseInboxReader) contactReader.close();
              else if (contactReader is SessionInboxReader) contactReader.close();
            } catch (_) {}
          }
        }
        // Nostr relay fallback for group members
        if (bundle == null && contact.provider == 'Nostr') {
          final atIdx = contact.databaseId.indexOf('@');
          final pk = atIdx > 0 ? contact.databaseId.substring(0, atIdx) : '';
          final pr = atIdx > 0 ? contact.databaseId.substring(atIdx + 1) : '';
          if (pk.isNotEmpty) {
            for (final relay in await gatherKnownRelays(pr, limit: 3)) {
              if (relay == pr) continue;
              final ar = NostrInboxReader();
              try {
                await ar.initializeReader('', '$pk@$relay');
                bundle = await ar.fetchPublicKeys();
                if (bundle != null) break;
              } catch (_) {} finally {
                try { ar.close(); } catch (_) {}
              }
            }
          }
        }
        if (bundle != null) {
          final keyChanged = await _c._signalService.buildSession(contact.databaseId, bundle);
          _c._keys.cacheContactKyberPk(contact.databaseId, bundle);
          if (keyChanged && !_c._keyChangeCtrl.isClosed) {
            _c._keyChangeCtrl.add((contactName: contact.name, contactId: contact.databaseId));
          }
          encryptedText = await _c._signalService.encryptMessage(contact.databaseId, envelope);
        } else {
          debugPrint('[E2EE] No key bundle for ${contact.name} — group send skipped');
          return false;
        }
      } catch (e2) {
        debugPrint('[E2EE] Session build failed for ${contact.name}: $e2 — group send skipped');
        return false;
      }
    }
    if (encryptedText.startsWith('E2EE||') &&
        _c._pqcConfirmed.contains(contact.databaseId)) {
      encryptedText = await _c._keys.pqcWrap(encryptedText, contact.databaseId);
    }
    final routeProvider = ChatController._providerFromAddress(contact.databaseId).isNotEmpty
        ? ChatController._providerFromAddress(contact.databaseId)
        : contact.provider;
    final msg = Message(
      id: ChatController._uuid.v4(),
      senderId: _c._selfId.isNotEmpty ? _c._selfId : _c._identity!.id,
      receiverId: contact.databaseId,
      encryptedPayload: encryptedText,
      timestamp: DateTime.now(),
      adapterType: routeProvider.toLowerCase(),
    );
    await _c._addSenderPlugin(contact);
    final devPrefs = await _c._getPrefs();
    final devModeOn = devPrefs.getBool('dev_mode_enabled') ?? false;

    // Transport-priority routing: iterate transports in priority order,
    // try each address within a transport before moving to the next.
    bool sent = false;

    // P2P shortcut
    if (!contact.isGroup && P2PTransportService.instance.isConnected(contact.id)) {
      sent = P2PTransportService.instance.send(contact.id, msg.encryptedPayload);
      if (sent) {
        debugPrint('[P2P] Direct delivery to ${contact.name}');
        _c._lastDeliveryTransport[contact.id] = 'P2P';
      }
    }

    if (!sent) {
      for (final transport in _c._rankedTransportsFor(contact)) {
        if (devModeOn && !(devPrefs.getBool('dev_adapter_$transport') ?? true)) {
          debugPrint('[Dev] Adapter $transport disabled — skipping');
          continue;
        }
        final addresses = contact.transportAddresses[transport] ?? [];
        for (final addr in addresses) {
          sent = await _deliverEncryptedMessage(addr, msg);
          if (sent) {
            debugPrint('[SmartRouter] Delivered via $transport: $addr');
            _c._lastDeliveryTransport[contact.id] = transport;
            break;
          }
        }
        if (sent) break;
      }
    }

    // LAN last resort
    final lanDisabled = devModeOn &&
        !(devPrefs.getBool('dev_adapter_LAN') ?? true);
    if (!sent && _c._lanSender != null && !lanDisabled) {
      sent = await _c._lanSender!.sendMessage('', '', msg);
      if (sent) {
        debugPrint('[LAN] Delivered via local network multicast');
        _c._lastDeliveryTransport[contact.id] = 'LAN';
        if (!_c._lanModeActive) {
          _c._lanModeActive = true;
          _c._scheduleNotify();
        }
      }
    } else if (sent && _c._lanModeActive) {
      _c._lanModeActive = false;
      _c._scheduleNotify();
    }

    return sent;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // _sendToContactViaPulseServer — route through a specific Pulse server
  // ═══════════════════════════════════════════════════════════════════════════

  /// Send [plaintext] to a single group member through a specific Pulse
  /// server (the group's `groupServerUrl`), bypassing the normal transport-
  /// priority routing. Used for pulse-mode groups so every group message
  /// flows through the host's Pulse server regardless of the recipient's
  /// preferred transport. Returns true on successful queue-to-WS.
  ///
  /// We intentionally do NOT fall back to other transports on failure —
  /// the whole point of a pulse group is that the user picked "always go
  /// through this server"; silently rerouting via Nostr would leak the
  /// group conversation off the chosen server.
  Future<bool> _sendToContactViaPulseServer(
      Contact rawContact, String plaintext, String pulseServerUrl) async {
    if (_c._identity == null) return false;
    final contact = _c._contacts.findById(rawContact.id) ?? rawContact;

    // Resolve recipient's Pulse pubkey. The pubkey is universal (same on
    // every Pulse server), so we only need to know it once — the server
    // we send through is the one that holds the group, regardless of
    // where this recipient's primary Pulse identity normally lives.
    String? recipientPulsePub;
    for (final addr in contact.transportAddresses['Pulse'] ?? const []) {
      final at = addr.indexOf('@');
      if (at > 0) {
        recipientPulsePub = addr.substring(0, at);
        break;
      }
    }
    if (recipientPulsePub == null || recipientPulsePub.isEmpty) {
      debugPrint('[PulseGroup] No Pulse pubkey for ${contact.name} — '
          'cannot route through $pulseServerUrl. Recipient must reconnect '
          'to a Pulse server (any) to advertise their pubkey.');
      return false;
    }

    // Encrypt via existing Signal session. The cipher blob is transport-
    // agnostic — keyed by `contact.databaseId` (whatever transport that
    // session was originally built on); the receiver decrypts on identity,
    // not transport.
    final envelope = MessageEnvelope.wrap(
        _c._selfId.isNotEmpty ? _c._selfId : _c._identity!.id, plaintext,
        senderName: _c._selfName,
        senderAvatar: _c._selfAvatar,
        senderAddresses: _c._buildOwnTransportMap());
    String encryptedText;
    try {
      encryptedText = await _c._signalService.encryptMessage(contact.databaseId, envelope);
    } catch (e) {
      // Stale / missing Signal session (most often InvalidKeyException after
      // the recipient reinstalled and rotated their identity key). Wipe
      // local session and refetch their bundle, preferring their Pulse
      // address on the GROUP's host server — it's where they're definitely
      // online for this group, and it skips Nostr-relay key fetch lottery.
      debugPrint('[PulseGroup] Encrypt failed for ${contact.name}: $e — '
          'rebuilding Signal session');
      try {
        await _c._signalService.deleteContactData(contact.databaseId);
        final pulseKey = await ChatController._secureStorage.read(key: 'pulse_privkey') ?? '';
        if (pulseKey.isEmpty) {
          debugPrint('[PulseGroup] Rebuild aborted: no pulse_privkey');
          return false;
        }
        // Use the existing pool sender to fetch keys via the already-
        // authenticated WebSocket. Creating a standalone PulseInboxReader
        // here would open a second WS on the same pubkey → server kicks
        // the primary reader → ping-pong loop.
        final poolKey = ChatController._canonicalizePulseUrl(pulseServerUrl);
        final poolSender = _c._pulseSendersByServer[poolKey];
        if (poolSender == null) {
          debugPrint('[PulseGroup] Rebuild aborted: no pool sender for $pulseServerUrl');
          return false;
        }
        final bundle = await poolSender.fetchContactKeys(recipientPulsePub);
        if (bundle == null) {
          debugPrint('[PulseGroup] Rebuild aborted: no bundle on $pulseServerUrl');
          return false;
        }
        final keyChanged = await _c._signalService.buildSession(contact.databaseId, bundle);
        _c._keys.cacheContactKyberPk(contact.databaseId, bundle);
        if (keyChanged && !_c._keyChangeCtrl.isClosed) {
          _c._keyChangeCtrl.add((contactName: contact.name, contactId: contact.databaseId));
        }
        encryptedText = await _c._signalService.encryptMessage(contact.databaseId, envelope);
        debugPrint('[PulseGroup] Session rebuilt + re-encrypted for ${contact.name}');
      } catch (e2) {
        debugPrint('[PulseGroup] Session rebuild failed for ${contact.name}: $e2');
        return false;
      }
    }
    if (encryptedText.startsWith('E2EE||') &&
        _c._pqcConfirmed.contains(contact.databaseId)) {
      encryptedText = await _c._keys.pqcWrap(encryptedText, contact.databaseId);
    }

    // Look up the per-server sender. ensureGroupPulseConnection should
    // have populated this when the group was loaded/accepted. If missing,
    // open it on demand — costs ~1-3s the first time (PoW + WS auth) but
    // amortizes across the rest of the chat.
    final key = ChatController._canonicalizePulseUrl(pulseServerUrl);
    if (!_c._pulseSendersByServer.containsKey(key)) {
      debugPrint('[PulseGroup] No pool sender for $pulseServerUrl — '
          'opening on-demand');
      final ok = await _c.ensureGroupPulseConnection(pulseServerUrl);
      if (!ok) return false;
    }
    final activeSender = _c._pulseSendersByServer[key];
    if (activeSender == null) return false;

    final targetDbId = '$recipientPulsePub@$pulseServerUrl';
    final msg = Message(
      id: ChatController._uuid.v4(),
      senderId: _c._selfId.isNotEmpty ? _c._selfId : _c._identity!.id,
      receiverId: targetDbId,
      encryptedPayload: encryptedText,
      timestamp: DateTime.now(),
      adapterType: 'pulse',
      isRead: true,
      status: 'sending',
    );
    final ok = await activeSender.sendMessage(targetDbId, '', msg);
    if (ok) _c._lastDeliveryTransport[contact.id] = 'Pulse';
    return ok;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // _sendSignalToContactViaPulseServer — Pulse-server signal fan-out
  // ═══════════════════════════════════════════════════════════════════════════

  /// Signal-flavoured sibling of [_sendToContactViaPulseServer]. Used for
  /// pulse-group fan-out of typing/read/edit/delete/reaction/group_update/
  /// sender_key_dist/sfu_invite — anything the broadcaster would otherwise
  /// send through the per-transport priority loop.
  ///
  /// Wired into [SignalBroadcaster.pulseGroupSignalSender] during
  /// initialization; broadcaster invokes this when a group method passes
  /// `overridePulseServer`. Returns true on successful sink.add.
  Future<bool> _sendSignalToContactViaPulseServer(Contact rawContact,
      String type, Map<String, dynamic> payload, String pulseServerUrl) async {
    if (_c._identity == null) return false;
    final contact = _c._contacts.findById(rawContact.id) ?? rawContact;

    String? recipientPulsePub;
    for (final addr in contact.transportAddresses['Pulse'] ?? const []) {
      final at = addr.indexOf('@');
      if (at > 0) {
        recipientPulsePub = addr.substring(0, at);
        break;
      }
    }
    if (recipientPulsePub == null || recipientPulsePub.isEmpty) {
      debugPrint('[PulseGroup] Signal $type → ${contact.name}: no Pulse '
          'pubkey known. Recipient must connect to a Pulse server first '
          '(addr_update will then propagate their pubkey).');
      return false;
    }

    final key = ChatController._canonicalizePulseUrl(pulseServerUrl);
    if (!_c._pulseSendersByServer.containsKey(key)) {
      final ok = await _c.ensureGroupPulseConnection(pulseServerUrl);
      if (!ok) return false;
    }
    final sender = _c._pulseSendersByServer[key];
    if (sender == null) return false;

    // Sign the payload before sending — Pulse-transport signals MUST carry
    // `_sig` + `_spk` (HMAC over canonical {t, p}) or the receiver's
    // SignalDispatcher rejects them as "unsigned" via the
    // `_signatureRequiredSignals` gate. Broadcaster's normal `_sendSignalTo`
    // does this for us, but the override callback bypasses that path; we
    // have to replicate the signing locally. Without this, sender_key_dist
    // / group_update / edit / delete / msg_read silently get dropped on the
    // recipient and the chat shows raw "_sk:true ct:..." envelopes
    // because no one ever distributed the sender key.
    Map<String, dynamic> signedPayload = payload;
    if (!payload.containsKey('_sig')) {
      try {
        final privkey = await _c._getNostrPrivkey();
        final selfPubkey =
            privkey.isNotEmpty ? deriveNostrPubkeyHex(privkey) : null;
        signedPayload =
            await _c._keys.signPayload(contact, type, payload, selfPubkey);
      } catch (e) {
        debugPrint('[PulseGroup] Signal $type sign failed: $e');
      }
    }
    final targetDbId = '$recipientPulsePub@$pulseServerUrl';
    final selfId = _c._selfId.isNotEmpty ? _c._selfId : (_c._identity?.id ?? '');
    return sender.sendSignal(targetDbId, targetDbId, selfId, type, signedPayload);
  }
}
