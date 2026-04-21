import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Manages extraction of bundled native binaries from Flutter assets.
///
/// Binaries are stored in assets/bins/[platform]/ and extracted to the app's
/// support directory on first use (or when the file size changes, indicating
/// an update). The extraction directory is stable across launches so tor/
/// snowflake-client can reference each other by path.
///
/// Usage:
///   final torPath = await BundledBinaryService.extract('tor');
///   if (torPath != null) Process.start(torPath, [...]);
class BundledBinaryService {
  BundledBinaryService._();

  /// Extracts [name] from assets (Android) or resolves its bundle path
  /// (Linux). Returns the absolute path on disk, or null if the platform
  /// is unsupported / the binary is missing.
  ///
  /// Android: binaries ship via `rootBundle` (assets/bins/android_arm64/)
  /// and get extracted into the app's support directory on first use.
  ///
  /// Linux: binaries ship via the CMake install step into
  /// `<bundle>/data/bins/linux_x64/` — we return that path directly,
  /// no extraction needed. Keeping Linux binaries out of rootBundle
  /// saves 77 MB from every Android APK.
  static Future<String?> extract(String name) async {
    if (Platform.isLinux) return _resolveLinuxBundlePath(name);
    final assetKey = _assetKey(name);
    if (assetKey == null) return null;

    try {
      final data = await rootBundle.load(assetKey);
      // .keep placeholder is 0 bytes — binary not downloaded yet
      if (data.lengthInBytes == 0) return null;

      final dir = await getApplicationSupportDirectory();
      final binDir = Directory('${dir.path}/pulse_bins');
      await binDir.create(recursive: true);

      final outPath = '${binDir.path}/$name$_exe';
      final outFile = File(outPath);

      // Re-extract if missing or size changed (app update)
      final bytes = data.buffer.asUint8List();
      if (!outFile.existsSync() || outFile.lengthSync() != bytes.length) {
        await outFile.writeAsBytes(bytes, flush: true);
        if (!Platform.isWindows) {
          await Process.run('chmod', ['+x', outPath]);
        }
        debugPrint('[Bins] Extracted $name → $outPath (${bytes.length} bytes)');
      }

      return outPath;
    } catch (e) {
      debugPrint('[Bins] Could not extract $name: $e');
      return null;
    }
  }

  /// Resolves a binary path inside the Linux bundle:
  /// `<executable-dir>/data/bins/<arch>/<name>`. The binary is installed
  /// by linux/CMakeLists.txt with the original executable permissions,
  /// so no chmod or copy is needed — return the path verbatim.
  static String? _resolveLinuxBundlePath(String name) {
    final platformDir = _platformDir;
    if (platformDir == null) return null;
    try {
      final exe = File(Platform.resolvedExecutable);
      final bundleDir = exe.parent.path;
      final path = '$bundleDir/data/bins/$platformDir/$name$_exe';
      if (!File(path).existsSync()) {
        debugPrint('[Bins] Not bundled on Linux: $path');
        return null;
      }
      return path;
    } catch (e) {
      debugPrint('[Bins] Linux path resolve failed for $name: $e');
      return null;
    }
  }

  /// Returns the asset key for [name] on the current platform, or null.
  static String? _assetKey(String name) {
    final platformDir = _platformDir;
    if (platformDir == null) return null;
    return 'assets/bins/$platformDir/$name$_exe';
  }

  static String? get _platformDir {
    if (Platform.isLinux) {
      // Detect CPU architecture
      try {
        final result = Process.runSync('uname', ['-m']);
        final arch = (result.stdout as String).trim();
        if (arch == 'aarch64' || arch == 'arm64') return 'linux_arm64';
        return 'linux_x64';
      } catch (_) {
        return 'linux_x64';
      }
    }
    if (Platform.isAndroid) {
      // flutter_webrtc already requires arm64; default to arm64
      // TODO: detect at runtime via sysinfo if needed
      return 'android_arm64';
    }
    if (Platform.isWindows) return 'windows_x64';
    // macOS: not yet bundled (requires notarisation)
    // iOS: cannot run subprocess — handled via library FFI
    return null;
  }

  static String get _exe => Platform.isWindows ? '.exe' : '';
}
