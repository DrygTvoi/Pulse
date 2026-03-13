import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Public STUN servers — diverse providers/regions so at least one responds
/// regardless of location.  WebRTC's ICE agent queries them all in parallel
/// and uses the first binding response, so a large list has minimal overhead.
///
/// Servers are kept in a single RTCIceServer object (one 'urls' array) so the
/// agent treats them as a pool rather than independent servers.
const _kStunUrls = [
  // Google — fast globally, blocked in mainland China
  'stun:stun.l.google.com:19302',
  'stun:stun1.l.google.com:19302',
  'stun:stun2.l.google.com:19302',

  // Cloudflare — privacy-friendly, global CDN
  'stun:stun.cloudflare.com:3478',

  // Twilio — global CDN with PoPs in Asia; accessible from China
  'stun:global.stun.twilio.com:3478',

  // Community / open-source
  'stun:stun.nextcloud.com:3478',
  'stun:stun.stunprotocol.org:3478',
  'stun:stun.services.mozilla.com:3478',

  // European providers (stable, non-blocked)
  'stun:stun.1und1.de:3478',
  'stun:stun.ekiga.net:3478',
  'stun:stun.bluesip.net:3478',
  'stun:stun.dus.net:3478',

  // VoIP / miscellaneous
  'stun:stun.ideasip.com:3478',
  'stun:stun.antisip.com:1024',
];

/// Community TURN presets — free, no registration.
///
/// IMPORTANT: TURN servers relay already-encrypted WebRTC streams (DTLS-SRTP).
/// A TURN operator can see your IP and traffic volume but CANNOT decrypt call
/// content.  No additional trust is required for confidentiality.
///
/// Each entry has at least one 'turns:' (TLS over TCP) URL so it can be used
/// by RestrictedProfile even when UDP is blocked.
const kTurnPresets = [
  {
    'id': 'openrelay',
    'name': 'Open Relay',
    'host': 'openrelay.metered.ca',
    'servers': [
      {
        'urls': 'turn:openrelay.metered.ca:80',
        'username': 'openrelayproject',
        'credential': 'openrelayproject',
      },
      {
        'urls': 'turn:openrelay.metered.ca:443',
        'username': 'openrelayproject',
        'credential': 'openrelayproject',
      },
      // TLS over TCP — works through strict firewalls
      {
        'urls': 'turns:openrelay.metered.ca:443?transport=tcp',
        'username': 'openrelayproject',
        'credential': 'openrelayproject',
      },
    ],
  },
  {
    'id': 'metered',
    'name': 'Metered.ca (50 GB/mo free)',
    'host': 'relay.metered.ca',
    'servers': [
      {
        'urls': 'stun:relay.metered.ca:80',
      },
      {
        'urls': 'turn:relay.metered.ca:80',
        'username': 'free',
        'credential': 'free',
      },
      {
        'urls': 'turn:relay.metered.ca:443',
        'username': 'free',
        'credential': 'free',
      },
      // TLS over TCP — works through strict firewalls
      {
        'urls': 'turns:relay.metered.ca:443?transport=tcp',
        'username': 'free',
        'credential': 'free',
      },
    ],
  },
];

/// SharedPreferences keys
const _kEnabledPresets  = 'turn_presets_enabled';
const _kCustomUrl       = 'turn_custom_url';
const _kCustomUsername  = 'turn_custom_username';
const _kCustomPassword  = 'turn_custom_password';
const _kProbeTurnKey    = 'probe_turn_servers';

class IceServerConfig {
  /// Full ICE server list: all STUN + enabled TURN presets + optional custom TURN.
  /// Used by AutoProfile (iceTransportPolicy = 'all').
  static Future<List<Map<String, dynamic>>> load() async {
    final prefs = await SharedPreferences.getInstance();

    final servers = <Map<String, dynamic>>[
      // All STUN servers in one object — queried in parallel
      {'urls': _kStunUrls},
    ];

    // Community presets — 'openrelay' enabled by default
    final enabled = prefs.getStringList(_kEnabledPresets) ?? ['openrelay'];
    for (final preset in kTurnPresets) {
      if (!enabled.contains(preset['id'] as String)) continue;
      for (final s in preset['servers'] as List) {
        servers.add(Map<String, dynamic>.from(s as Map));
      }
    }

    // Probe-discovered TURN servers (auto-found by ConnectivityProbeService)
    final probeTurnRaw = prefs.getString(_kProbeTurnKey);
    if (probeTurnRaw != null) {
      try {
        final list = jsonDecode(probeTurnRaw) as List;
        for (final s in list) {
          servers.add(Map<String, dynamic>.from(s as Map));
        }
      } catch (_) {}
    }

    // Custom TURN server (BYOD — highest priority, added last so WebRTC tries it first)
    final url  = prefs.getString(_kCustomUrl)     ?? '';
    final user = prefs.getString(_kCustomUsername) ?? '';
    final pass = prefs.getString(_kCustomPassword) ?? '';
    if (url.isNotEmpty) {
      servers.add({
        'urls': url,
        if (user.isNotEmpty) 'username': user,
        if (pass.isNotEmpty) 'credential': pass,
      });
    }

    return servers;
  }

  /// Returns only TURN servers that use TLS over TCP (turns: scheme).
  ///
  /// Used by RestrictedProfile (iceTransportPolicy = 'relay') — these are the
  /// only relay transports that reliably pass through GFW / Iranian DPI.
  /// Plain UDP and plain TCP TURN are excluded.
  static Future<List<Map<String, dynamic>>> loadRelay() async {
    final all = await load();
    final result = <Map<String, dynamic>>[];

    for (final server in all) {
      final urls = server['urls'];
      if (urls is String) {
        if (urls.startsWith('turns:')) result.add(server);
      } else if (urls is List) {
        final tls = urls.where((u) => u.toString().startsWith('turns:')).toList();
        if (tls.isNotEmpty) {
          // Preserve username/credential, replace urls with TLS-only subset
          result.add({
            ...server,
            'urls': tls.length == 1 ? tls.first as String : tls,
          });
        }
      }
      // STUN entries (no username/credential, urls starting with 'stun:') are skipped —
      // they're irrelevant when iceTransportPolicy = 'relay'.
    }

    return result;
  }

  // ── Persistence helpers ──────────────────────────────────────────────────

  static Future<List<String>> loadEnabledPresets() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kEnabledPresets) ?? ['openrelay'];
  }

  static Future<void> saveEnabledPresets(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kEnabledPresets, ids);
  }

  static Future<({String url, String username, String password})> loadCustomTurn() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      url:      prefs.getString(_kCustomUrl)      ?? '',
      username: prefs.getString(_kCustomUsername)  ?? '',
      password: prefs.getString(_kCustomPassword)  ?? '',
    );
  }

  static Future<void> saveProbeTurnServers(
      List<Map<String, dynamic>> servers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kProbeTurnKey, jsonEncode(servers));
  }

  static Future<void> saveCustomTurn({
    required String url,
    required String username,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (url.isEmpty) {
      await prefs.remove(_kCustomUrl);
      await prefs.remove(_kCustomUsername);
      await prefs.remove(_kCustomPassword);
    } else {
      await prefs.setString(_kCustomUrl, url);
      await prefs.setString(_kCustomUsername, username);
      await prefs.setString(_kCustomPassword, password);
    }
  }
}
