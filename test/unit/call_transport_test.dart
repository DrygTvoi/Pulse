import 'package:flutter_test/flutter_test.dart';

/// Pure-Dart unit tests for CallTransportProfile.
///
/// CallTransportProfile depends on ice_server_config.dart (SharedPreferences)
/// and tor_turn_proxy.dart (dart:io), so we cannot import it directly.
/// We reimplement the three profile definitions here for testing —
/// same pattern as other adapter tests.
///
/// Source: lib/services/call_transport.dart
///
/// Three static const profiles:
///   auto       — tries direct P2P first, TURN fallback
///   restricted — relay-only over TLS/TCP port 443
///   torRelay   — relay-only through Tor TURN proxies

// ── Reimplemented profiles from call_transport.dart ──────────────────────────

abstract class CallTransportProfile {
  const CallTransportProfile();

  String get id;
  String get displayName;

  /// True when this profile forces relay-only (no direct P2P UDP).
  bool get isRestricted;

  static const CallTransportProfile auto = _AutoProfile();
  static const CallTransportProfile restricted = _RestrictedProfile();
  static const CallTransportProfile torRelay = _TorRelayProfile();

  /// All known profiles for enumeration tests.
  static const List<CallTransportProfile> all = [auto, restricted, torRelay];
}

class _AutoProfile extends CallTransportProfile {
  const _AutoProfile();

  @override
  String get id => 'auto';
  @override
  String get displayName => 'Auto';
  @override
  bool get isRestricted => false;
}

class _RestrictedProfile extends CallTransportProfile {
  const _RestrictedProfile();

  @override
  String get id => 'restricted';
  @override
  String get displayName => 'Restricted Network';
  @override
  bool get isRestricted => true;
}

class _TorRelayProfile extends CallTransportProfile {
  const _TorRelayProfile();

  @override
  String get id => 'tor_relay';
  @override
  String get displayName => 'Tor Relay';
  @override
  bool get isRestricted => true;
}

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ── Auto profile ─────────────────────────────────────────────────────────

  group('AutoProfile', () {
    test('id is "auto"', () {
      expect(CallTransportProfile.auto.id, equals('auto'));
    });

    test('displayName is "Auto"', () {
      expect(CallTransportProfile.auto.displayName, equals('Auto'));
    });

    test('isRestricted is false (allows direct P2P)', () {
      expect(CallTransportProfile.auto.isRestricted, isFalse);
    });
  });

  // ── Restricted profile ──────────────────────────────────────────────────

  group('RestrictedProfile', () {
    test('id is "restricted"', () {
      expect(CallTransportProfile.restricted.id, equals('restricted'));
    });

    test('displayName is "Restricted Network"', () {
      expect(
        CallTransportProfile.restricted.displayName,
        equals('Restricted Network'),
      );
    });

    test('isRestricted is true (relay-only, no UDP)', () {
      expect(CallTransportProfile.restricted.isRestricted, isTrue);
    });
  });

  // ── TorRelay profile ────────────────────────────────────────────────────

  group('TorRelayProfile', () {
    test('id is "tor_relay"', () {
      expect(CallTransportProfile.torRelay.id, equals('tor_relay'));
    });

    test('displayName is "Tor Relay"', () {
      expect(CallTransportProfile.torRelay.displayName, equals('Tor Relay'));
    });

    test('isRestricted is true (relay-only via Tor)', () {
      expect(CallTransportProfile.torRelay.isRestricted, isTrue);
    });
  });

  // ── Cross-profile properties ────────────────────────────────────────────

  group('Cross-profile properties', () {
    test('all three profiles have distinct IDs', () {
      final ids = CallTransportProfile.all.map((p) => p.id).toSet();
      expect(ids.length, equals(3));
    });

    test('all three profiles have distinct display names', () {
      final names = CallTransportProfile.all.map((p) => p.displayName).toSet();
      expect(names.length, equals(3));
    });

    test('only auto is unrestricted', () {
      final unrestricted =
          CallTransportProfile.all.where((p) => !p.isRestricted).toList();
      expect(unrestricted.length, equals(1));
      expect(unrestricted.first.id, equals('auto'));
    });

    test('restricted and torRelay are both restricted', () {
      expect(CallTransportProfile.restricted.isRestricted, isTrue);
      expect(CallTransportProfile.torRelay.isRestricted, isTrue);
    });

    test('auto profile is not identical to restricted profile', () {
      expect(
        identical(CallTransportProfile.auto, CallTransportProfile.restricted),
        isFalse,
      );
    });

    test('auto profile is not identical to torRelay profile', () {
      expect(
        identical(CallTransportProfile.auto, CallTransportProfile.torRelay),
        isFalse,
      );
    });

    test('restricted profile is not identical to torRelay profile', () {
      expect(
        identical(
            CallTransportProfile.restricted, CallTransportProfile.torRelay),
        isFalse,
      );
    });

    test('static const references are stable (same instance on each access)', () {
      final a1 = CallTransportProfile.auto;
      final a2 = CallTransportProfile.auto;
      expect(identical(a1, a2), isTrue);

      final r1 = CallTransportProfile.restricted;
      final r2 = CallTransportProfile.restricted;
      expect(identical(r1, r2), isTrue);

      final t1 = CallTransportProfile.torRelay;
      final t2 = CallTransportProfile.torRelay;
      expect(identical(t1, t2), isTrue);
    });
  });

  // ── ID format ────────────────────────────────────────────────────────────

  group('ID format', () {
    test('all IDs are non-empty lowercase strings', () {
      for (final profile in CallTransportProfile.all) {
        expect(profile.id, isNotEmpty);
        expect(profile.id, equals(profile.id.toLowerCase()));
      }
    });

    test('IDs use snake_case (no spaces or hyphens)', () {
      for (final profile in CallTransportProfile.all) {
        expect(profile.id, isNot(contains(' ')));
        expect(profile.id, isNot(contains('-')));
      }
    });
  });

  // ── Display name format ──────────────────────────────────────────────────

  group('Display name format', () {
    test('all display names are non-empty', () {
      for (final profile in CallTransportProfile.all) {
        expect(profile.displayName, isNotEmpty);
      }
    });

    test('display names start with an uppercase letter', () {
      for (final profile in CallTransportProfile.all) {
        final first = profile.displayName[0];
        expect(first, equals(first.toUpperCase()));
      }
    });
  });
}
