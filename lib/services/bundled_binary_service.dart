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

  /// Extracts [name] from assets and returns its absolute path.
  /// Returns null if the current platform is unsupported or the asset
  /// is missing (binary not yet downloaded — see scripts/download_bins.sh).
  static Future<String?> extract(String name) async {
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
