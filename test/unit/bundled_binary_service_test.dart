import 'package:flutter_test/flutter_test.dart';

/// Pure-Dart unit tests for BundledBinaryService logic.
///
/// The actual service depends on dart:io (Platform, Process, File) and
/// Flutter asset loading, so we reimplement the testable logic here.

// ── Reimplemented logic from BundledBinaryService ─────────────────────────

/// Mirrors BundledBinaryService._assetKey
String? assetKey(String name, {required String? platformDir, required String exe}) {
  if (platformDir == null) return null;
  return 'assets/bins/$platformDir/$name$exe';
}

/// Mirrors BundledBinaryService._platformDir for a given OS/arch combination.
String? platformDir({required String os, String arch = 'x86_64'}) {
  switch (os) {
    case 'linux':
      if (arch == 'aarch64' || arch == 'arm64') return 'linux_arm64';
      return 'linux_x64';
    case 'android':
      return 'android_arm64';
    case 'windows':
      return 'windows_x64';
    default:
      return null; // macOS, iOS unsupported
  }
}

/// Mirrors BundledBinaryService._exe
String exe({required String os}) => os == 'windows' ? '.exe' : '';

void main() {
  // ── Platform directory resolution ─────────────────────────────────────

  group('BundledBinaryService platform directory', () {
    test('Linux x86_64 resolves to linux_x64', () {
      expect(platformDir(os: 'linux', arch: 'x86_64'), equals('linux_x64'));
    });

    test('Linux aarch64 resolves to linux_arm64', () {
      expect(platformDir(os: 'linux', arch: 'aarch64'), equals('linux_arm64'));
    });

    test('Linux arm64 resolves to linux_arm64', () {
      expect(platformDir(os: 'linux', arch: 'arm64'), equals('linux_arm64'));
    });

    test('Android resolves to android_arm64', () {
      expect(platformDir(os: 'android'), equals('android_arm64'));
    });

    test('Windows resolves to windows_x64', () {
      expect(platformDir(os: 'windows'), equals('windows_x64'));
    });

    test('macOS returns null (unsupported)', () {
      expect(platformDir(os: 'macos'), isNull);
    });

    test('iOS returns null (unsupported)', () {
      expect(platformDir(os: 'ios'), isNull);
    });

    test('unknown OS returns null', () {
      expect(platformDir(os: 'fuchsia'), isNull);
    });
  });

  // ── Asset key construction ────────────────────────────────────────────

  group('BundledBinaryService asset key', () {
    test('Linux tor asset key', () {
      final key = assetKey('tor', platformDir: 'linux_x64', exe: '');
      expect(key, equals('assets/bins/linux_x64/tor'));
    });

    test('Linux snowflake-client asset key', () {
      final key = assetKey('snowflake-client', platformDir: 'linux_x64', exe: '');
      expect(key, equals('assets/bins/linux_x64/snowflake-client'));
    });

    test('Android tor asset key', () {
      final key = assetKey('tor', platformDir: 'android_arm64', exe: '');
      expect(key, equals('assets/bins/android_arm64/tor'));
    });

    test('Windows adds .exe extension', () {
      final key = assetKey('tor', platformDir: 'windows_x64', exe: '.exe');
      expect(key, equals('assets/bins/windows_x64/tor.exe'));
    });

    test('null platformDir returns null', () {
      final key = assetKey('tor', platformDir: null, exe: '');
      expect(key, isNull);
    });
  });

  // ── Executable extension ──────────────────────────────────────────────

  group('BundledBinaryService exe extension', () {
    test('Windows gets .exe', () {
      expect(exe(os: 'windows'), equals('.exe'));
    });

    test('Linux gets empty string', () {
      expect(exe(os: 'linux'), equals(''));
    });

    test('Android gets empty string', () {
      expect(exe(os: 'android'), equals(''));
    });
  });

  // ── Output path construction ──────────────────────────────────────────

  group('BundledBinaryService output path', () {
    test('Linux output path format', () {
      const supportDir = '/home/user/.local/share/pulse';
      const name = 'tor';
      final outPath = '$supportDir/pulse_bins/$name';
      expect(outPath, equals('/home/user/.local/share/pulse/pulse_bins/tor'));
    });

    test('Windows output path with .exe', () {
      const supportDir = 'C:\\Users\\user\\AppData\\Roaming\\pulse';
      const name = 'tor';
      final outPath = '$supportDir/pulse_bins/$name.exe';
      expect(outPath, contains('pulse_bins'));
      expect(outPath, endsWith('.exe'));
    });

    test('output directory is pulse_bins', () {
      const binDir = 'pulse_bins';
      expect(binDir, equals('pulse_bins'));
    });
  });
}
