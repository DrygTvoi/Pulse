import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/contact.dart';

/// Cross-screen channel for `pulse://group?cfg=…` invites that arrive via
/// the OS deep-link API. main.dart pushes incoming URLs here; HomeScreen
/// listens and consumes one invite per change-notification. Using a queue
/// (not a single value) so two link clicks back-to-back both surface — the
/// previous ValueNotifier-only design dropped the second invite if the
/// listener was slow to drain.
class PendingGroupInvite {
  PendingGroupInvite._();
  static final List<GroupInvitePayload> _pending = [];

  /// Notifier ticks every time `offer` is called so listeners can re-poll
  /// the queue. The notifier's value is just the queue length; the real
  /// data is fetched via `consume`.
  static final ValueNotifier<int> notifier = ValueNotifier(0);

  /// Set the pending invite from a raw URL string. Caller is responsible
  /// for clearing via [consume] once the user has acted on it.
  static void offer(String url) {
    final parsed = GroupInviteLink.tryParse(url);
    if (parsed == null) return;
    _pending.add(parsed);
    notifier.value = _pending.length;
  }

  /// Pop the oldest pending invite, or null if the queue is empty.
  static GroupInvitePayload? consume() {
    if (_pending.isEmpty) return null;
    final v = _pending.removeAt(0);
    notifier.value = _pending.length;
    return v;
  }
}

/// Wire format for Pulse group invite links.
///
/// `pulse://group?cfg=<base64(JSON)>` carries:
///   - `gid` — group UUID
///   - `n`   — group display name (utf-8)
///   - `cid` — creator UUID (optional)
///   - `m`   — list of member UUIDs (creator's local-side ids)
///   - `mpk` — `{uuid → nostr-pubkey-hex}` so the receiver can route to each
///             member without needing them in their contact list yet
///   - `ma`  — `{uuid → {transport → [addresses]}}` so each member can be
///             reached on at least one transport
///
/// Keys are short to keep base64 payloads tractable when QR-encoded.
class GroupInviteLink {
  static const _hostJoinGroup = 'group';

  /// Build the shareable URL for [group]. Caller must pass `memberAddresses`
  /// (the same `_buildMemberAddresses` map the broadcaster uses) so receivers
  /// can reach members without needing them already as contacts.
  static String build(
    Contact group, {
    required Map<String, Map<String, List<String>>> memberAddresses,
  }) {
    if (!group.isGroup) {
      throw ArgumentError('GroupInviteLink.build called on non-group contact');
    }
    final cfg = <String, dynamic>{
      'gid': group.id,
      'n': group.name,
      'm': group.members,
      if (group.creatorId != null && group.creatorId!.isNotEmpty)
        'cid': group.creatorId,
      if (group.memberPubkeys.isNotEmpty)
        'mpk': Map<String, String>.from(group.memberPubkeys),
      if (memberAddresses.isNotEmpty) 'ma': memberAddresses,
    };
    final json = jsonEncode(cfg);
    // Hard-cap the JSON before base64 to keep the URL under typical OS
    // share-sheet / clipboard limits. base64 inflates ~4/3, so 18 KiB JSON
    // → ~24 KiB base64 → ~24 KiB URL. Refuse oversize and let the caller
    // drop optional fields (memberAddresses) to fit.
    if (json.length > 18 * 1024) {
      throw ArgumentError(
          'Invite payload too large (${json.length} bytes). Trim memberAddresses or split the group.');
    }
    final b64 = base64Encode(utf8.encode(json));
    return 'pulse://$_hostJoinGroup?cfg=$b64';
  }

  /// Parse a `pulse://group?cfg=…` URI string. Returns null if the URI is
  /// not a group invite or the payload is malformed/oversized.
  static GroupInvitePayload? tryParse(String url) {
    Uri? uri;
    try {
      uri = Uri.parse(url);
    } catch (_) {
      return null;
    }
    if (uri.scheme != 'pulse' || uri.host != _hostJoinGroup) return null;
    final cfg64 = uri.queryParameters['cfg'];
    if (cfg64 == null || cfg64.isEmpty || cfg64.length > 32 * 1024) {
      return null;
    }
    try {
      final raw = utf8.decode(base64Decode(cfg64));
      final json = jsonDecode(raw);
      if (json is! Map) return null;
      return GroupInvitePayload._fromJson(Map<String, dynamic>.from(json));
    } catch (_) {
      return null;
    }
  }
}

class GroupInvitePayload {
  final String groupId;
  final String name;
  final List<String> members;
  final String? creatorId;
  final Map<String, String> memberPubkeys;
  final Map<String, Map<String, List<String>>> memberAddresses;

  const GroupInvitePayload._({
    required this.groupId,
    required this.name,
    required this.members,
    this.creatorId,
    this.memberPubkeys = const {},
    this.memberAddresses = const {},
  });

  static GroupInvitePayload? _fromJson(Map<String, dynamic> j) {
    final gid = j['gid'] as String?;
    final name = j['n'] as String?;
    final rawMembers = j['m'];
    if (gid == null || gid.isEmpty || name == null) return null;
    if (rawMembers is! List) return null;
    if (rawMembers.length > 200) return null;
    final members = rawMembers.whereType<String>().toList();
    final cid = j['cid'] as String?;
    final pubkeys = <String, String>{};
    final rawPub = j['mpk'];
    if (rawPub is Map) {
      for (final e in rawPub.entries) {
        if (e.key is String && e.value is String) {
          pubkeys[e.key as String] = e.value as String;
        }
      }
    }
    final addresses = <String, Map<String, List<String>>>{};
    final rawAddr = j['ma'];
    if (rawAddr is Map) {
      for (final e in rawAddr.entries) {
        if (e.key is! String) continue;
        final v = e.value;
        if (v is! Map) continue;
        final inner = <String, List<String>>{};
        for (final ee in v.entries) {
          if (ee.key is! String) continue;
          if (ee.value is! List) continue;
          inner[ee.key as String] =
              (ee.value as List).whereType<String>().toList();
        }
        addresses[e.key as String] = inner;
      }
    }
    return GroupInvitePayload._(
      groupId: gid,
      name: name,
      members: members,
      creatorId: (cid != null && cid.isNotEmpty) ? cid : null,
      memberPubkeys: pubkeys,
      memberAddresses: addresses,
    );
  }
}
