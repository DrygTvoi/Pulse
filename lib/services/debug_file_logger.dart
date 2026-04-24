import 'dart:io';
import 'package:flutter/foundation.dart';

/// Debug-only tee of debugPrint + Flutter errors to a file. Lets us collect
/// logs even when the user launches via a shortcut (no stdout redirect).
///
/// Path:
///   Windows : %TEMP%\pulse.log
///   Linux   : /tmp/pulse.log
///   Other   : no-op (Android: use `adb logcat`)
///
/// Truncates on every app start — the file only holds the current run.
/// No-op in release builds.
class DebugFileLogger {
  static File? _file;
  static bool _initialized = false;

  static String? path() {
    if (Platform.isWindows) {
      final tmp = Platform.environment['TEMP'] ??
          Platform.environment['TMP'] ??
          Platform.environment['LOCALAPPDATA'];
      if (tmp == null) return null;
      return '$tmp\\pulse.log';
    }
    if (Platform.isLinux || Platform.isMacOS) return '/tmp/pulse.log';
    return null;
  }

  static void init() {
    if (_initialized || kReleaseMode) return;
    _initialized = true;
    final p = path();
    if (p == null) return;
    try {
      _file = File(p);
      _file!.writeAsStringSync(
          '=== Pulse debug log — ${DateTime.now().toIso8601String()} ===\n');
    } catch (_) {
      _file = null;
      return;
    }

    final originalPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      originalPrint(message, wrapWidth: wrapWidth);
      if (message != null) _write(message);
    };

    final originalError = FlutterError.onError;
    FlutterError.onError = (details) {
      originalError?.call(details);
      _write('[FlutterError] ${details.exceptionAsString()}');
      if (details.stack != null) _write(details.stack.toString());
    };
  }

  static void _write(String msg) {
    final f = _file;
    if (f == null) return;
    try {
      final ts = DateTime.now().toIso8601String();
      f.writeAsStringSync('[$ts] $msg\n', mode: FileMode.append);
    } catch (_) {}
  }
}
