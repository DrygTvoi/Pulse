import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// One Nostr kind:0 profile snapshot for a pubkey.
class NostrProfile {
  final String pubkey;
  final String? name;
  final String? pictureUrl;
  final DateTime fetchedAt;

  NostrProfile({
    required this.pubkey,
    this.name,
    this.pictureUrl,
    DateTime? fetchedAt,
  }) : fetchedAt = fetchedAt ?? DateTime.now();
}

/// Process-wide cache of Nostr kind:0 profiles.
///
/// Used to surface a display name (and eventually an avatar) for pubkeys
/// we encounter via group rosters but have NOT added as direct
/// contacts. Lookups are non-blocking: callers ask for a profile, get
/// either the cached value or null, and rebuild on `notifyListeners` if
/// the underlying fetch returned later.
///
/// Misses kick off one fetch per pubkey across the supplied relay hints
/// (tried sequentially) and de-duplicate concurrent requests.
class NostrProfileCache extends ChangeNotifier {
  NostrProfileCache._();
  static final NostrProfileCache instance = NostrProfileCache._();

  final Map<String, NostrProfile> _cache = {};
  final Set<String> _inFlight = {};
  /// pubkey → time of last failed fetch, used to back off.
  final Map<String, DateTime> _lastFailed = {};
  static const _failBackoff = Duration(minutes: 10);
  static const _hex64 = r'^[0-9a-f]{64}$';

  /// Return the cached profile for [pubkey], or null if we don't have
  /// one yet. Does not trigger a fetch.
  NostrProfile? get(String pubkey) => _cache[pubkey];

  /// Ensure a fetch is in flight for [pubkey]. Returns immediately;
  /// subscribers should rebuild on `notifyListeners`. The first relay
  /// in [relayHints] that returns a kind:0 event wins.
  void requestFetch(String pubkey, List<String> relayHints) {
    debugPrint('[Profile] requestFetch ${pubkey.substring(0, 8)}… '
        'cached=${_cache.containsKey(pubkey)} inFlight=${_inFlight.contains(pubkey)} '
        'hints=${relayHints.length}');
    if (pubkey.isEmpty || !RegExp(_hex64).hasMatch(pubkey)) return;
    if (_cache.containsKey(pubkey)) return;
    if (_inFlight.contains(pubkey)) return;
    final lastFail = _lastFailed[pubkey];
    if (lastFail != null && DateTime.now().difference(lastFail) < _failBackoff) {
      debugPrint('[Profile] backoff active for ${pubkey.substring(0, 8)}…');
      return;
    }
    if (relayHints.isEmpty) {
      debugPrint('[Profile] no relay hints for ${pubkey.substring(0, 8)}…');
      return;
    }
    _inFlight.add(pubkey);
    unawaited(_fetch(pubkey, relayHints));
  }

  Future<void> _fetch(String pubkey, List<String> relayHints) async {
    debugPrint('[Profile] _fetch start ${pubkey.substring(0, 8)}… '
        'over ${relayHints.length} relay(s)');
    try {
      for (final hint in relayHints) {
        final relayUrl = hint.startsWith('ws://') || hint.startsWith('wss://')
            ? hint
            : 'wss://$hint';
        try {
          final profile = await _fetchOne(pubkey, relayUrl)
              .timeout(const Duration(seconds: 6));
          debugPrint('[Profile] $relayUrl → '
              '${profile == null ? "null" : "name=${profile.name}"}');
          if (profile != null) {
            _cache[pubkey] = profile;
            _lastFailed.remove(pubkey);
            notifyListeners();
            return;
          }
        } catch (e) {
          // Try the next relay.
          debugPrint('[Profile] $relayUrl failed for '
              '${pubkey.substring(0, 8)}…: $e');
        }
      }
      debugPrint('[Profile] all relays exhausted for ${pubkey.substring(0, 8)}…');
      _lastFailed[pubkey] = DateTime.now();
    } finally {
      _inFlight.remove(pubkey);
    }
  }

  Future<NostrProfile?> _fetchOne(String pubkey, String relayUrl) async {
    WebSocketChannel? channel;
    try {
      channel = WebSocketChannel.connect(Uri.parse(relayUrl));
      final subId = 'profile_${Random().nextInt(0x7fffffff)}';
      channel.sink.add(jsonEncode([
        'REQ',
        subId,
        {'kinds': [0], 'authors': [pubkey], 'limit': 1},
      ]));
      String? foundName;
      String? pictureUrl;
      await for (final raw in channel.stream
          .timeout(const Duration(seconds: 6))) {
        try {
          final msg = jsonDecode(raw as String);
          if (msg is! List || msg.isEmpty) continue;
          if (msg[0] == 'EVENT' && msg.length >= 3) {
            final event = msg[2];
            if (event is! Map) continue;
            if (event['kind'] != 0) continue;
            final raw = event['content'];
            if (raw is! String) continue;
            try {
              final parsed = jsonDecode(raw);
              if (parsed is! Map) continue;
              final name = (parsed['display_name'] as String?)?.trim();
              final altName = (parsed['name'] as String?)?.trim();
              foundName = (name?.isNotEmpty ?? false)
                  ? name
                  : (altName?.isNotEmpty ?? false ? altName : null);
              final pic = (parsed['picture'] as String?)?.trim();
              if (pic != null && pic.isNotEmpty && pic.length <= 2048) {
                pictureUrl = pic;
              }
            } catch (_) {/* malformed content — ignore */}
          } else if (msg[0] == 'EOSE') {
            break;
          }
        } catch (_) {/* parse error — keep listening */}
      }
      if (foundName == null && pictureUrl == null) return null;
      return NostrProfile(
          pubkey: pubkey, name: foundName, pictureUrl: pictureUrl);
    } finally {
      try { await channel?.sink.close(); } catch (_) {}
    }
  }
}
