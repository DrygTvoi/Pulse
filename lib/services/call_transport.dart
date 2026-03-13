import 'ice_server_config.dart';

/// Defines the ICE-transport strategy for a WebRTC call.
///
/// Pluggable like message adapters — swap profiles to handle different
/// network environments without touching call logic:
///
///   AutoProfile       — tries direct P2P first, TURN fallback (default)
///   RestrictedProfile — relay-only over TLS/TCP port 443
///                       (GFW, Iran, strict corporate firewalls)
///
/// Future profiles can add obfuscation layers (uTLS, WebSocket-TURN tunnel)
/// by implementing [peerConfig] differently.
abstract class CallTransportProfile {
  const CallTransportProfile();

  String get id;
  String get displayName;

  /// True when this profile forces relay-only (no direct P2P UDP).
  bool get isRestricted;

  /// Full RTCPeerConnection config map: iceServers + iceTransportPolicy.
  Future<Map<String, dynamic>> peerConfig();

  static const CallTransportProfile auto       = _AutoProfile();
  static const CallTransportProfile restricted = _RestrictedProfile();
}

// ─── Auto ─────────────────────────────────────────────────────────────────────

/// Normal operation.
/// ICE tries STUN (direct P2P) first; falls back to TURN if needed.
class _AutoProfile extends CallTransportProfile {
  const _AutoProfile();

  @override String get id           => 'auto';
  @override String get displayName  => 'Auto';
  @override bool   get isRestricted => false;

  @override
  Future<Map<String, dynamic>> peerConfig() async => {
    'iceServers':          await IceServerConfig.load(),
    'iceTransportPolicy':  'all',
  };
}

// ─── Restricted ───────────────────────────────────────────────────────────────

/// Censored / heavily-firewalled network.
///
/// Forces relay-only (policy='relay') and uses only TURN servers that
/// communicate over TLS/TCP port 443 — the one port almost never blocked.
/// UDP and plain-TCP TURN are skipped entirely.
///
/// If no TLS TURN server is configured the call will fail with a clear
/// message so the user knows to add a TURN server in Settings.
class _RestrictedProfile extends CallTransportProfile {
  const _RestrictedProfile();

  @override String get id           => 'restricted';
  @override String get displayName  => 'Restricted Network';
  @override bool   get isRestricted => true;

  @override
  Future<Map<String, dynamic>> peerConfig() async => {
    'iceServers':          await IceServerConfig.loadRelay(),
    'iceTransportPolicy':  'relay',
  };
}
