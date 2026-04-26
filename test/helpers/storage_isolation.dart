/// Per-test storage isolation helpers for the integration test harness.
///
/// Two responsibilities:
///   1. Mock `FlutterSecureStorage` with per-prefix routing so every
///      [TestClient] gets a fully isolated keyring even though they all
///      share a single `MethodChannel`.
///   2. Provide a temporary directory factory for tests that need their
///      own SQLCipher database.
library;

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// FlutterSecureStorage's actual platform-channel name (the existing
/// `test_mocks.dart` uses a stale Flutter-IO name that no longer matches
/// the current plugin — we use the up-to-date one here).
const String _kSecureStorageChannel =
    'plugins.it_nomads.com/flutter_secure_storage';

/// Reserved bucket name for any FlutterSecureStorage call that arrives
/// without a `preferencesKeyPrefix` option (i.e. plain default-constructed
/// storage). Stays empty unless production code instantiates a default
/// `FlutterSecureStorage()` during a test — which we don't want, but we
/// store it somewhere instead of crashing.
const String _kDefaultBucket = '__default__';

/// Per-prefix in-memory secure-storage buckets, owned by this library and
/// shared by every [TestClient] instance. Routing key = `preferencesKeyPrefix`.
final Map<String, Map<String, String>> _buckets = <String, Map<String, String>>{};

bool _handlerInstalled = false;

/// Install the per-prefix routed FlutterSecureStorage mock.
///
/// Safe to call multiple times — the second and later calls are no-ops.
/// Each [TestClient] should construct its `FlutterSecureStorage` with a
/// unique `AndroidOptions(preferencesKeyPrefix: 'pulse_test_<name>')`,
/// which this handler uses as a routing key.
void installSecureStorageRouter() {
  if (_handlerInstalled) return;
  _handlerInstalled = true;
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel(_kSecureStorageChannel),
    (MethodCall call) async {
      final args = (call.arguments as Map?) ?? const {};
      final options = (args['options'] as Map?) ?? const {};
      final prefix = (options['preferencesKeyPrefix'] as String?) ?? '';
      final bucketKey = prefix.isEmpty ? _kDefaultBucket : prefix;
      final bucket = _buckets.putIfAbsent(bucketKey, () => <String, String>{});

      switch (call.method) {
        case 'read':
          return bucket[args['key'] as String];
        case 'readAll':
          return Map<String, String>.from(bucket);
        case 'write':
          bucket[args['key'] as String] = args['value'] as String;
          return null;
        case 'delete':
          bucket.remove(args['key'] as String);
          return null;
        case 'deleteAll':
          bucket.clear();
          return null;
        case 'containsKey':
          return bucket.containsKey(args['key'] as String);
        case 'isProtectedDataAvailable':
          return true;
        default:
          return null;
      }
    },
  );
}

/// Tear the router down. Tests rarely need this — installing the same
/// handler twice is idempotent — but it lets a test return the binary
/// messenger to its pristine state.
void uninstallSecureStorageRouter() {
  if (!_handlerInstalled) return;
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel(_kSecureStorageChannel),
    null,
  );
  _handlerInstalled = false;
}

/// Reset every per-client secure-storage bucket. Call from `setUp()` to
/// guarantee a clean slate when a single test file spawns many harnesses.
void resetSecureStorageBuckets() {
  _buckets.clear();
}

/// Get a snapshot of the in-memory secure-storage state for [prefix],
/// useful when a test wants to assert on persisted material.
Map<String, String> dumpBucket(String prefix) {
  final b = _buckets[prefix];
  return b == null ? const {} : Map<String, String>.unmodifiable(b);
}

/// Erase a single bucket — handy when a test needs to simulate "wipe
/// the device" semantics without touching its peer's keyring.
void clearBucket(String prefix) {
  _buckets[prefix]?.clear();
}

/// Convenience wrapper that calls [SharedPreferences.setMockInitialValues]
/// with an empty map. Should be invoked inside `setUp()` to reset
/// SharedPreferences between tests.
void resetSharedPreferences() {
  SharedPreferences.setMockInitialValues(<String, Object>{});
}

/// Allocate a unique temp directory for SQLCipher per-test. The caller is
/// responsible for cleanup (preferably via `addTearDown`).
///
/// Example:
/// ```dart
/// final dir = await withTempDbDir();
/// addTearDown(() async { if (dir.existsSync()) await dir.delete(recursive: true); });
/// ```
Future<Directory> withTempDbDir({String prefix = 'pulse_test_db_'}) async {
  final root = Directory.systemTemp;
  return root.createTemp(prefix);
}
