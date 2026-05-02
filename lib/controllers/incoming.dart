part of 'chat_controller.dart';

/// Incoming-message processing pipeline: PQC unwrap → E2EE decrypt →
/// envelope validation → Sender Key unwrap → chunk assembly → room
/// insertion → notification dispatch.
///
/// Extracted from ChatController. All state fields live on ChatController
/// and are accessed via `_c._field`.
class _IncomingHandler {
  final ChatController _c;
  _IncomingHandler(this._c);

  Future<void> handleIncomingMessages(List<Message> newMessages) async {
    bool hasUpdates = false;
    var contactByDbId = _c._getContactIndex();
    bool anyContactUpdated = false;
    final pendingSaves = <String, List<Map<String, dynamic>>>{};

    for (var msg in newMessages) {
      try {
        if (_c._seenMsgIds.contains(msg.id)) continue;
        if (_c._seenMsgIds.length >= 10000) {
          // Atomic eviction: rebuild both structures from remaining entries
          // to avoid Set/List desync across microtask boundaries.
          final evictCount = 5000.clamp(0, _c._seenMsgIdsList.length);
          final remaining = _c._seenMsgIdsList.sublist(evictCount);
          _c._seenMsgIdsList
            ..clear()
            ..addAll(remaining);
          _c._seenMsgIds
            ..clear()
            ..addAll(remaining);
        }
        _c._seenMsgIds.add(msg.id);
        _c._seenMsgIdsList.add(msg.id);

        // Normalise to pubkey prefix so a sender using multiple transports
        // (nostr, firebase) shares one rate-limit bucket rather than
        // getting a fresh 30-token bucket per transport address.
        final rlKey = msg.senderId.split('@').first;
        if (!_c._allAddresses.contains(msg.senderId) &&
            msg.senderId != _c._selfId &&
            !_c._msgRateLimiter.allow(rlKey)) {
          debugPrint('[Chat] Rate limited message from: ${msg.senderId}');
          continue;
        }

        // Block list check BEFORE decryption — saves CPU against spam.
        final senderPubKey = msg.senderId.split('@').first;
        if (ContactManager().isBlocked(senderPubKey) || ContactManager().isBlocked(msg.senderId)) {
          continue;
        }

        String rawPayload = msg.encryptedPayload;
        if (rawPayload.startsWith('PQC2||')) {
          try {
            rawPayload = await CryptoLayer.unwrap(rawPayload);
            // PQC succeeded — mark sender as confirmed so we PQC-wrap replies.
            _c._pqcConfirmed.add(msg.senderId);
            final senderPub = msg.senderId.split('@').first;
            for (final c in _c._contacts.contacts) {
              if (c.databaseId.split('@').first == senderPub) {
                _c._pqcConfirmed.add(c.databaseId);
                break;
              }
            }
          } catch (e) {
            debugPrint('[PQC] Unwrap failed for ${msg.id}: $e — dropping message');
            // PQC-wrapped message is irrecoverable — clear sender's cached
            // Kyber pk so our replies go Signal-only (they'll work).
            _c._keys.clearContactKyberPk(msg.senderId);
            continue; // skip this message entirely — don't show gibberish
          }
        }

        // All real messages must be E2EE-wrapped (plaintext fallback removed).
        // Non-E2EE payloads are server chaff or invalid — drop silently.
        if (!rawPayload.startsWith('E2EE||')) {
          debugPrint('[Chat] ⏭ Non-E2EE payload from ${msg.senderId.substring(0, 12)}…: ${rawPayload.substring(0, 30.clamp(0, rawPayload.length))}…');
          continue;
        }

        String decryptedRaw = rawPayload;
        Contact? _fallbackDecryptContact;
        // Set when ANY decrypt attempt hits InvalidKeyIdException / missing
        // prekey — indicates the sender is using a stale bundle, not a
        // corrupted session. Needs a different recovery: push our fresh
        // bundle to them so their next session build uses current prekeys.
        bool sawStalePrekey = false;
        bool isStalePrekeyError(Object e) {
          final s = e.toString();
          // The classic "you used a prekey that no longer exists" cases.
          if (s.contains('InvalidKeyIdException') ||
              s.contains('No such prekeyrecord')) return true;
          // Pulse-group key-rotation case: when both sides rebuild their
          // own session against the OTHER side's freshly-fetched bundle
          // (e.g. after the send-pipeline rebuild path fired on Linux,
          // the resulting message either lands as a PreKey type that
          // Android can't decode against its existing identity, or as a
          // Whisper without any matching session). Both manifest as "Bad
          // Mac" / "No valid sessions" — treat the same as stale-prekey.
          if (s.contains('No valid sessions') ||
              s.contains('Bad Mac') ||
              s.contains('InvalidMessageException')) return true;
          return false;
        }
        if (rawPayload.startsWith('E2EE||')) {
          final fastContact = contactByDbId[msg.senderId]
              ?? contactByDbId[msg.senderId.split('@').first];
          debugPrint('[Chat] Contact lookup for ${msg.senderId.substring(0, 16)}…: ${fastContact?.name ?? "NOT FOUND"} (index has ${contactByDbId.length} entries)');
          if (fastContact != null) {
            try {
              decryptedRaw = await _c._signalService.decryptMessage(fastContact.databaseId, rawPayload);
            } catch (e) {
              if (isStalePrekeyError(e)) sawStalePrekey = true;
              debugPrint('[Chat] E2EE fast-path decrypt failed for ${fastContact.databaseId}: $e');
              sentryBreadcrumb('E2EE fast-path decrypt failed', category: 'signal');
            }
          }
          // If fast-path failed, try ALL known addresses for this contact as
          // session keys.  After addr_update the databaseId changes but the Signal
          // session may still be keyed by an older address.
          if (decryptedRaw == rawPayload && fastContact != null) {
            final tryAddrs = <String>{
              msg.senderId, // raw sender address from transport
              ...fastContact.alternateAddresses,
            };
            tryAddrs.remove(fastContact.databaseId); // already tried
            for (final addr in tryAddrs) {
              try {
                decryptedRaw = await _c._signalService.decryptMessage(addr, rawPayload);
                debugPrint('[Chat] Decrypt OK via alt session key: $addr');
                break;
              } catch (e) {
                if (isStalePrekeyError(e)) sawStalePrekey = true;
                debugPrint('[Chat] Alt-key decrypt failed for $addr: $e');
              }
            }
          }
          // Fallback: search all contacts by sender pubkey prefix
          if (decryptedRaw == rawPayload && fastContact == null) {
            final senderPubPrefix = msg.senderId.split('@').first;
            for (final c in _c._contacts.contacts) {
              if (c.databaseId.split('@').first == senderPubPrefix ||
                  c.alternateAddresses.any((a) => a.split('@').first == senderPubPrefix)) {
                final tryAddrs = <String>[c.databaseId, msg.senderId, ...c.alternateAddresses];
                for (final addr in tryAddrs) {
                  try {
                    decryptedRaw = await _c._signalService.decryptMessage(addr, rawPayload);
                    debugPrint('[Chat] Decrypt OK via contact ${c.name} key: $addr');
                    _fallbackDecryptContact = c;
                    break;
                  } catch (e) { /* try next */ }
                }
                if (decryptedRaw != rawPayload) break;
              }
            }
          }
          // Last resort: unknown sender — try decrypt with raw senderId.
          // Signal PreKeyMessage can be decrypted using only our own keys.
          if (decryptedRaw == rawPayload && fastContact == null) {
            try {
              decryptedRaw = await _c._signalService.decryptMessage(msg.senderId, rawPayload);
              debugPrint('[Chat] Decrypt OK for unknown sender via raw senderId: ${msg.senderId}');
            } catch (e) {
              debugPrint('[Chat] Unknown sender decrypt failed for ${msg.senderId}: $e');
            }
          }
        }

        // Reset fail counter on successful decrypt.
        if (!decryptedRaw.startsWith('E2EE||')) {
          final okKey = contactByDbId[msg.senderId]?.databaseId
              ?? contactByDbId[msg.senderId.split('@').first]?.databaseId
              ?? msg.senderId;
          _c._e2eeFailCount.remove(okKey);
        }

        // If E2EE decryption failed entirely, drop the message (don't show
        // ciphertext). Track consecutive failures per contact — only delete the
        // session after 3+ failures to avoid nuking a valid session due to
        // stale replayed events from the relay's since window.
        if (decryptedRaw.startsWith('E2EE||')) {
          final failContact = contactByDbId[msg.senderId]
              ?? contactByDbId[msg.senderId.split('@').first];
          final failKey = failContact?.databaseId ?? msg.senderId;
          _c._e2eeFailCount[failKey] = (_c._e2eeFailCount[failKey] ?? 0) + 1;
          final failN = _c._e2eeFailCount[failKey]!;
          // Stale-prekey failures: sender is using an outdated bundle. Reset
          // our session immediately (don't wait 3 fails) and push our
          // current bundle back so their next send rebuilds the session
          // against fresh prekeys. Rate-limited to once per 60s per contact.
          if (sawStalePrekey && failContact != null) {
            debugPrint('[Chat] Stale prekey detected for ${failContact.name} — '
                'resetting session and pushing fresh bundle');
            unawaited(_c._signalService.deleteContactData(failContact.databaseId));
            _c._e2eeFailCount.remove(failKey);
            final last = _c._lastStaleKeyPush[failContact.id];
            if (last == null ||
                DateTime.now().difference(last) > const Duration(seconds: 60)) {
              _c._lastStaleKeyPush[failContact.id] = DateTime.now();
              unawaited(_c._pushOwnBundleTo(failContact));
            }
          } else if (failContact != null && failN >= 3) {
            debugPrint('[Chat] E2EE decrypt failed ${failN}x for ${failContact.name} — '
                'deleting stale session to force rebuild');
            unawaited(_c._signalService.deleteContactData(failContact.databaseId));
            _c._e2eeFailCount.remove(failKey);
          } else {
            debugPrint('[Chat] E2EE decrypt failed (${failN}x) for ${failContact?.name ?? msg.senderId} — dropping');
          }
          continue;
        }

        final env = MessageEnvelope.tryUnwrap(decryptedRaw);
        // Validate envelope's claimed sender matches transport-layer sender.
        // env.from may use a different transport address (e.g. Firebase vs Nostr)
        // but the pubkey prefix must always agree. If they differ, an attacker
        // forged the inner envelope — fall back to transport sender.
        // Exception: sealed sender messages have transport ID "sealed" —
        // the real sender is only known from the encrypted envelope.
        String canonicalSenderId;
        final isSealed = msg.senderId == 'sealed';
        if (env?.from != null && env!.from.isNotEmpty) {
          if (isSealed) {
            // Sealed sender: transport ID is anonymous, trust envelope.
            canonicalSenderId = env.from;
          } else {
            final envPrefix = env.from.split('@').first;
            final transportPrefix = msg.senderId.split('@').first;
            if (envPrefix == transportPrefix) {
              canonicalSenderId = env.from;
            } else {
              // Different key formats (e.g. Session 05-prefix vs Pulse Ed25519)
              // may belong to the same contact. Check if both resolve to the
              // same contact before raising a tamper warning.
              final envContact = contactByDbId[env.from]
                  ?? contactByDbId[envPrefix];
              final transportContact = contactByDbId[msg.senderId]
                  ?? contactByDbId[transportPrefix];
              if (envContact != null && transportContact != null &&
                  envContact.id == transportContact.id) {
                // Same contact, different address format — use envelope.
                canonicalSenderId = env.from;
              } else {
                debugPrint('[Chat] Envelope sender mismatch: '
                    'envelope=$envPrefix transport=$transportPrefix — using transport');
                if (!_c._tamperWarningCtrl.isClosed) {
                  _c._tamperWarningCtrl.add('Authenticity warning from ${msg.senderId}');
                }
                canonicalSenderId = msg.senderId;
              }
            }
          }
        } else {
          canonicalSenderId = msg.senderId;
        }
        final bodyText = env?.body ?? decryptedRaw;

        Contact? senderContact = contactByDbId[canonicalSenderId]
            ?? contactByDbId[canonicalSenderId.split('@').first];
        senderContact ??= contactByDbId[msg.senderId]
            ?? contactByDbId[msg.senderId.split('@').first];
        // Try matching by any of the sender's known transport addresses in
        // the envelope. Prevents a duplicate pending contact being created
        // when the sender's current canonicalSenderId was unknown to us
        // (e.g. they just added a new Pulse/Session transport).
        if (senderContact == null && env?.senderAddresses != null) {
          for (final addrs in env!.senderAddresses!.values) {
            for (final addr in addrs) {
              final hit = contactByDbId[addr] ?? contactByDbId[addr.split('@').first];
              if (hit != null) { senderContact = hit; break; }
            }
            if (senderContact != null) break;
          }
        }
        // Use contact found during fallback decrypt (sender used different relay).
        senderContact ??= _fallbackDecryptContact;

        if (senderContact != null) {
          // Sender is provably online — update status.
          _c._broadcaster.updateLastSeen(senderContact.id);
          // Message arrived — clear typing indicator immediately (1-on-1).
          _c._broadcaster.clearTyping(senderContact.id, (id) {
            if (!_c._typingStreamCtrl.isClosed) _c._typingStreamCtrl.add(id);
            _c._scheduleNotify();
          });
          // Learn sender's transport addresses from envelope and incoming msg.
          {
            var didUpdate = false;
            var ta = Map<String, List<String>>.from(
              senderContact.transportAddresses.map((k, v) => MapEntry(k, List<String>.from(v))),
            );
            // Merge full address map from envelope (all sender transports).
            final envAddrs = env?.senderAddresses;
            if (envAddrs != null) {
              for (final entry in envAddrs.entries) {
                final existing = ta[entry.key] ?? <String>[];
                for (final addr in entry.value) {
                  if (!existing.contains(addr)) {
                    existing.add(addr);
                    didUpdate = true;
                  }
                }
                if (existing.isNotEmpty) ta[entry.key] = existing;
              }
            }
            // Also learn the single incoming transport address.
            final incomingAddr = msg.senderId;
            if (incomingAddr.contains('@') &&
                !senderContact.alternateAddresses.contains(incomingAddr)) {
              final transport = Contact.providerFromAddress(incomingAddr);
              final existing = ta[transport] ?? <String>[];
              if (!existing.contains(incomingAddr)) {
                existing.add(incomingAddr);
                ta[transport] = existing;
                didUpdate = true;
              }
            }
            if (didUpdate) {
              final updated = senderContact.copyWith(transportAddresses: ta);
              await _c._contacts.updateContact(updated);
              anyContactUpdated = true;
              senderContact = updated;
              debugPrint('[Chat] Learned new routes for ${senderContact.name}: ${ta.keys.join(', ')}');
            }
          }
          _c._repo.getOrCreateRoomWithId(senderContact, msg.senderId, senderContact.provider);
          final room = _c._repo.getRoomForContact(senderContact.id)!;

          if (!_c._repo.roomHasMessage(senderContact.id, msg.id)) {
            try {
              String displayText = bodyText;
              Contact targetContact = senderContact;
              String finalText = displayText;
              String? groupReplyToId, groupReplyToText, groupReplyToSender;
              bool skipMessage = false;
              try { if (displayText.startsWith('{')) {
                var parsed = jsonDecode(displayText) as Map<String, dynamic>;
                // ── System message: signal-in-message for offline delivery ──
                // Pulse stores messages but not signals; critical signals
                // (group_invite, sender_key_dist) are also sent as _sys
                // messages so offline recipients receive them via the
                // stored-message path instead of losing them forever.
                final sysType = parsed['_sys'] as String?;
                if (sysType != null && sysType.isNotEmpty) {
                  final sysPayload = parsed['p'] as Map<String, dynamic>?;
                  if (sysPayload != null) {
                    skipMessage = await _handleSystemMessage(
                        senderContact, sysType, sysPayload);
                  } else {
                    skipMessage = true;
                  }
                }
                // ── Sender Key decrypt: unwrap _sk envelope ──
                if (!skipMessage && parsed['_sk'] == true) {
                  final skGroupId = parsed['_group'] as String?;
                  final ct = parsed['ct'] as String?;
                  if (skGroupId != null && ct != null) {
                    // Check membership BEFORE decrypting to prevent
                    // removed members from advancing the ratchet or leaking plaintext.
                    final skg = _c._contacts.findById(skGroupId);
                    final skGroup = (skg != null && skg.isGroup) ? skg : null;
                    if (skGroup == null ||
                        !_c._isSenderInGroup(skGroup, senderContact)) {
                      debugPrint('[SenderKey] Rejected SK message from non-member '
                          '${senderContact.name} for group $skGroupId');
                    } else {
                      try {
                        final cipherBytes = base64Decode(ct);
                        final plainBytes = await SenderKeyService.instance
                            .decrypt(skGroupId, senderContact.databaseId, cipherBytes);
                        final innerJson = utf8.decode(plainBytes);
                        parsed = jsonDecode(innerJson) as Map<String, dynamic>;
                        displayText = innerJson;
                      } catch (skErr) {
                        debugPrint('[SenderKey] Decrypt failed from ${senderContact.name}: $skErr');
                        // Fall through — parsed still has _sk envelope.
                      }
                    }
                  }
                }
                final groupId = parsed['_group'] as String?;
                if (groupId != null) {
                  final gcl = _c._contacts.findById(groupId);
                  final groupContact = (gcl != null && gcl.isGroup) ? gcl : null;
                  if (groupContact == null) {
                    // Group doesn't exist yet — the _sys group_invite
                    // hasn't arrived or was processed out of order.
                    // Drop silently rather than displaying raw JSON
                    // gibberish in the DM list.
                    debugPrint('[Group] Dropping message for unknown group $groupId');
                    skipMessage = true;
                  } else {
                    final isMember = _c._isSenderInGroup(groupContact, senderContact);
                    debugPrint('[Group] recv groupId=$groupId sender=${senderContact.name} '
                        'found=true isMember=$isMember');
                    if (isMember) {
                      targetContact = groupContact;
                      // Clear group-specific typing for this member.
                      _c._broadcaster.clearTyping(senderContact.id, (id) {
                        if (!_c._typingStreamCtrl.isClosed) _c._typingStreamCtrl.add(id);
                        _c._scheduleNotify();
                      }, groupId: groupId);
                      finalText = parsed['text'] as String? ?? displayText;
                      groupReplyToId = parsed['_replyToId'] as String?;
                      groupReplyToText = parsed['_replyToText'] as String?;
                      groupReplyToSender = parsed['_replyToSender'] as String?;
                      _c._repo.getOrCreateRoomWithId(groupContact, groupContact.id, 'group');
                    }
                  }
                }
              } } catch (e) { debugPrint('[Chat] Signal JSON parse (treating as plain text): $e'); }

              // P2P file header: initiates binary file transfer (not stored as message)
              if (finalText.startsWith('{') && finalText.contains('"p2p_file"')) {
                try {
                  final hdr = jsonDecode(finalText) as Map<String, dynamic>;
                  if (hdr['p2p_file'] == true) {
                    _c._handleP2PFileHeader(senderContact.id, hdr);
                    skipMessage = true;
                  }
                } catch (_) {}
              }

              if (!skipMessage && MediaService.isChunkPayload(finalText)) {
                // Track which contact is sending this file (F7 fix: stall
                // chunk_req should only go to the actual sender).
                try {
                  final chunkMap = jsonDecode(finalText) as Map<String, dynamic>;
                  final chunkFid = chunkMap['fid'] as String?;
                  if (chunkFid != null && chunkFid.isNotEmpty) {
                    _c._chunkSenderIds[chunkFid] = senderContact.id;
                  }
                } catch (_) {}
                final assembled = _c._chunkAssembler.handleChunk(finalText);
                if (assembled == null) {
                  skipMessage = true;
                } else {
                  // Transfer complete — clean up sender tracking.
                  try {
                    final chunkMap = jsonDecode(finalText) as Map<String, dynamic>;
                    _c._chunkSenderIds.remove(chunkMap['fid']);
                  } catch (_) {}
                  finalText = assembled;
                }
              }

              if (!skipMessage &&
                  !MediaService.isMediaPayload(finalText) &&
                  !MediaService.isChunkPayload(finalText) &&
                  !BlossomPayloadHelpers.isBlossomPayload(finalText) &&
                  finalText.length > 65536) {
                debugPrint('[ChatController] Dropped oversized message (${finalText.length} bytes)');
                skipMessage = true;
              }

              if (!skipMessage) {
                final targetRoom = _c._repo.getRoomForContact(targetContact.id) ?? room;
                // Use sender's local UUID from envelope (_id field) if present,
                // so reactions/deletes use the same ID on both devices.
                // Fall back to transport-level ID (Nostr event hash, etc.).
                final resolvedId = env?.msgId ?? msg.id;
                if (!targetRoom.messages.any((m) => m.id == resolvedId)) {
                  final decryptedMsg = Message(
                    id: resolvedId,
                    senderId: msg.senderId,
                    receiverId: msg.receiverId,
                    encryptedPayload: finalText,
                    timestamp: msg.timestamp,
                    adapterType: msg.adapterType,
                    isRead: false,
                    replyToId: groupReplyToId ?? env?.replyTo?.id,
                    replyToText: groupReplyToText ?? env?.replyTo?.text,
                    replyToSender: groupReplyToSender ?? env?.replyTo?.sender,
                  );
                  ChatController._insertMessageSorted(targetRoom.messages, decryptedMsg);
                  _c._repo.trackMessageId(targetContact.id, decryptedMsg.id);
                  pendingSaves.putIfAbsent(targetContact.storageKey, () => []).add(decryptedMsg.toJson());
                  hasUpdates = true;
                  if (!_c._newMsgController.isClosed) {
                    _c._newMsgController.add((contactId: targetContact.id, message: decryptedMsg));
                  }
                  // Increment unread count if this chat is not currently open
                  if (_c._activeRoomId != targetContact.id) {
                    _c._unreadCounts[targetContact.id] = (_c._unreadCounts[targetContact.id] ?? 0) + 1;
                    if (!_c._unreadChangedCtrl.isClosed) {
                      _c._unreadChangedCtrl.add(targetContact.id);
                    }
                  }
                  unawaited(_c._broadcaster.sendDeliveryAck(senderContact, decryptedMsg.id,
                      groupId: targetContact.isGroup ? targetContact.id : null,
                      group: targetContact.isGroup ? targetContact : null));
                  if (targetContact.isGroup && _c._activeRoomId == targetContact.id) {
                    unawaited(_c._broadcaster.sendGroupReadReceipt(
                        senderContact, targetContact.id, decryptedMsg.id,
                        group: targetContact));
                  }
                  final ttl = _c._repo.getChatTtlCached(targetContact.id);
                  if (ttl > 0) {
                    _c._repo.scheduleTtlDelete(targetContact, decryptedMsg, ttl,
                        onDeleted: () { if (!_c._disposed) _c._scheduleNotify(); });
                  }
                }
                // Save sender avatar from envelope if we don't have one yet.
                if (env?.senderAvatar != null && env!.senderAvatar!.isNotEmpty) {
                  final existing = await LocalStorageService().loadAvatar(senderContact.id);
                  if (existing == null || existing.isEmpty) {
                    unawaited(LocalStorageService().saveAvatar(senderContact.id, env.senderAvatar!));
                  }
                }
                // Promote routing-only auto-pending contacts to a real name
                // from the envelope. Without this, members the local user
                // first learnt about via group fan-out keep their placeholder
                // "Member abc12345" name forever — so every group bubble from
                // them shows that label instead of the real display name.
                final envSenderName = env?.senderName;
                if (envSenderName != null &&
                    envSenderName.isNotEmpty &&
                    (senderContact.isHidden ||
                        senderContact.name.startsWith('Member ') ||
                        senderContact.name.startsWith('Group: ')) &&
                    senderContact.name != envSenderName) {
                  final updated = senderContact.copyWith(
                      name: envSenderName, isHidden: false);
                  await _c._contacts.updateContact(updated);
                  anyContactUpdated = true;
                  senderContact = updated;
                  debugPrint(
                      '[Chat] Promoted hidden contact ${senderContact.id.substring(0, 8)} → "$envSenderName"');
                }
              }
            } catch (e) {
              debugPrint("Decryption failed for message ${msg.id}: $e");
            }
          }
        } else {
          // Unknown sender — auto-create pending contact (message request).
          final envName = env?.senderName;
          final fallbackName = canonicalSenderId.split('@').first;
          final pendingName = (envName != null && envName.isNotEmpty)
              ? envName
              : (fallbackName.length > 8 ? '${fallbackName.substring(0, 8)}...' : fallbackName);
          // Use the fullest address available for routing replies.
          // canonicalSenderId (from envelope) often has pubkey@wss://relay,
          // while msg.senderId from Nostr is bare pubkey.
          final pendingAddress = canonicalSenderId.contains('@')
              ? canonicalSenderId
              : (msg.senderId.contains('@') ? msg.senderId : canonicalSenderId);
          final pendingContact = await ContactManager().createPendingContact(
            senderId: canonicalSenderId,
            senderName: pendingName,
            address: pendingAddress,
            transportAddresses: env?.senderAddresses,
          );
          if (pendingContact != null) {
            _c._invalidateContactIndex();
            contactByDbId = _c._getContactIndex();
            _c._repo.getOrCreateRoomWithId(pendingContact, msg.senderId, pendingContact.provider);
            final room = _c._repo.getRoomForContact(pendingContact.id)!;
            final resolvedId = env?.msgId ?? msg.id;
            if (!room.messages.any((m) => m.id == resolvedId)) {
              final decryptedMsg = Message(
                id: resolvedId,
                senderId: msg.senderId,
                receiverId: msg.receiverId,
                encryptedPayload: bodyText,
                timestamp: msg.timestamp,
                adapterType: msg.adapterType,
                isRead: false,
              );
              ChatController._insertMessageSorted(room.messages, decryptedMsg);
              _c._repo.trackMessageId(pendingContact.id, decryptedMsg.id);
              pendingSaves.putIfAbsent(pendingContact.storageKey, () => []).add(decryptedMsg.toJson());
              hasUpdates = true;
              if (!_c._newMsgController.isClosed) {
                _c._newMsgController.add((contactId: pendingContact.id, message: decryptedMsg));
              }
              _c._unreadCounts[pendingContact.id] = (_c._unreadCounts[pendingContact.id] ?? 0) + 1;
              if (!_c._unreadChangedCtrl.isClosed) {
                _c._unreadChangedCtrl.add(pendingContact.id);
              }
            }
            debugPrint('[Chat] Created pending contact for unknown sender: ${pendingContact.name}');
            // Save avatar from envelope if present.
            if (env?.senderAvatar != null && env!.senderAvatar!.isNotEmpty) {
              unawaited(LocalStorageService().saveAvatar(pendingContact.id, env.senderAvatar!));
              debugPrint('[Chat] Saved avatar from envelope for ${pendingContact.name}');
            } else {
              // Fallback: fetch Nostr avatar from sender's relay.
              final nostrAddrs = pendingContact.transportAddresses['Nostr'];
              if (nostrAddrs != null && nostrAddrs.isNotEmpty) {
                final parts = nostrAddrs.first.split('@');
                if (parts.length == 2) {
                  unawaited(_c._fetchNostrAvatarForContact(pendingContact.id, parts[0], parts[1]));
                }
              }
            }
          } else {
            debugPrint('[Chat] Pending contact limit reached — dropping message from ${msg.senderId}');
          }
        }
      } catch (e) {
        debugPrint('[ChatController] Skipping malformed message ${msg.id}: $e');
      }
    }

    // Batch-persist all messages saved during this loop in a single
    // transaction per room instead of N individual INSERTs.
    final storage = LocalStorageService();
    for (final entry in pendingSaves.entries) {
      await storage.saveMessagesBatch(entry.key, entry.value);
    }
    if (anyContactUpdated) {
      _c._invalidateContactIndex();
    }

    if (hasUpdates) _c._scheduleNotify();
  }

  /// Process a system message (_sys) that was sent as an E2EE message
  /// alongside the real-time signal.  Pulse stores messages but not
  /// signals; this path ensures offline recipients still receive
  /// group_invite and sender_key_dist via the stored-message mechanism.
  /// Returns true if the message should be skipped (not displayed).
  Future<bool> _handleSystemMessage(
      Contact sender, String type, Map<String, dynamic> payload) async {
    debugPrint('[Chat] _sys message: type=$type from=${sender.name}');
    if (type == 'group_invite') {
      final groupId = payload['groupId'] as String?;
      final groupName = payload['name'] as String? ?? '';
      final rawMembers = payload['members'];
      final creatorId = payload['creatorId'] as String?;
      final memberPubkeys = _extractMemberPubkeysSys(payload['memberPubkeys']);
      final memberAddresses = _extractMemberAddressesSys(payload['memberAddresses']);
      final memberNames = _extractMemberNamesSys(payload['memberNames']);
      final memberPulsePubkeys = _extractMemberPulsePubkeysSys(payload['memberPulsePubkeys']);
      final groupTransportMode =
          (payload['groupTransportMode'] as String?)?.trim() ?? '';
      final groupServerUrl =
          (payload['groupServerUrl'] as String?)?.trim() ?? '';
      final groupServerInvite =
          (payload['groupServerInvite'] as String?)?.trim() ?? '';
      if (groupId != null && rawMembers is List && rawMembers.length <= 200) {
        final event = SignalGroupInviteEvent(
            sender, groupId, groupName,
            rawMembers.whereType<String>().toList(),
            creatorId: creatorId,
            memberPubkeys: memberPubkeys,
            memberAddresses: memberAddresses,
            memberNames: memberNames,
            memberPulsePubkeys: memberPulsePubkeys,
            groupTransportMode: groupTransportMode,
            groupServerUrl: groupServerUrl,
            groupServerInvite: groupServerInvite);
        // Accept the group synchronously within this message batch so
        // subsequent messages in the same batch see the group exists.
        // Emitting to the stream alone is not enough — its async listener
        // hasn't run acceptGroupInvite yet, so the next message in the
        // for loop sees a non-existent group and gets dropped.
        await _c.acceptGroupInvite(event);
        if (!_c._groupInviteCtrl.isClosed) {
          _c._groupInviteCtrl.add(event);
          debugPrint('[Chat] _sys group_invite emitted for "$groupName"');
        }
      }
      return true;
    }
    if (type == 'sender_key_dist') {
      final groupId = payload['groupId'] as String? ?? '';
      final skdmB64 = payload['skdm'] as String? ?? '';
      if (groupId.isNotEmpty && skdmB64.isNotEmpty) {
        try {
          final skdmBytes = base64Decode(skdmB64);
          await SenderKeyService.instance.processDistribution(
              groupId, sender.databaseId, skdmBytes);
          debugPrint('[Chat] _sys sender_key_dist processed for $groupId');
        } catch (e) {
          debugPrint('[Chat] _sys sender_key_dist failed: $e');
        }
      }
      return true;
    }
    if (type == 'group_update') {
      // Pulse stores messages but not signals — the _sys mirror ensures
      // offline members receive tombstones, kicks, and roster changes.
      final groupId = payload['groupId'] as String?;
      final members = (payload['members'] as List?)?.whereType<String>().toList() ?? [];
      if (groupId != null) {
        final existing = _c._contacts.findById(groupId);
        if (existing != null && existing.isGroup) {
          if (members.isEmpty) {
            // Tombstone — group deleted.
            await _c._contacts.removeContact(groupId);
            _c._invalidateContactIndex();
            debugPrint('[Chat] _sys group_update tombstone: removed $groupId');
          } else {
            // Member removal / kick — check if WE were removed.
            final atIdx = _c._selfId.indexOf('@');
            final ourPubkey = atIdx > 0 ? _c._selfId.substring(0, atIdx).toLowerCase() : '';
            final memberPubkeys = _extractMemberPubkeysSys(payload['memberPubkeys']);
            final weStillMember = ourPubkey.isNotEmpty &&
                memberPubkeys.values.any((p) => p.toLowerCase() == ourPubkey);
            if (!weStillMember) {
              await _c._contacts.removeContact(groupId);
              _c._invalidateContactIndex();
              debugPrint('[Chat] _sys group_update kick: removed $groupId');
            } else {
              // Roster change — update members.
              final updated = existing.copyWith(
                members: members,
                memberPubkeys: Map<String, String>.from(existing.memberPubkeys)
                  ..addAll(memberPubkeys),
              );
              await _c._contacts.updateContact(updated);
              _c._invalidateContactIndex();
              debugPrint('[Chat] _sys group_update roster: updated $groupId with ${members.length} members');
            }
          }
          _c._scheduleNotify();
          if (!_c._groupUpdatePublicCtrl.isClosed) {
            _c._groupUpdatePublicCtrl.add(SignalGroupUpdateEvent(
                groupId, payload['name'] as String? ?? '', members,
                creatorId: payload['creatorId'] as String?,
                senderId: sender.id));
          }
        }
      }
      return true;
    }
    debugPrint('[Chat] _sys message unknown type: $type');
    return true; // skip unknown sys messages
  }

  // ── Helpers that mirror SignalDispatcher extraction ──────────────────

  static Map<String, String> _extractMemberPubkeysSys(dynamic raw) {
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), v.toString()));
    }
    return {};
  }

  static Map<String, Map<String, List<String>>> _extractMemberAddressesSys(dynamic raw) {
    if (raw is! Map) return {};
    final out = <String, Map<String, List<String>>>{};
    for (final entry in raw.entries) {
      final memberId = entry.key.toString();
      final perTransport = entry.value;
      if (perTransport is! Map) continue;
      final transportMap = <String, List<String>>{};
      for (final te in perTransport.entries) {
        final transport = te.key.toString();
        final addrs = te.value;
        if (addrs is List) {
          transportMap[transport] = addrs.whereType<String>().toList();
        }
      }
      if (transportMap.isNotEmpty) out[memberId] = transportMap;
    }
    return out;
  }

  static Map<String, String> _extractMemberNamesSys(dynamic raw) {
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), v.toString()));
    }
    return {};
  }

  static Map<String, String> _extractMemberPulsePubkeysSys(dynamic raw) {
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), v.toString()));
    }
    return {};
  }
}
