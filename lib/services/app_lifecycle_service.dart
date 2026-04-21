import 'package:flutter/foundation.dart';

/// Singleton broadcasting whether the app is currently in the foreground or
/// has been paused (Android: home button / app switcher / locked screen).
///
/// Wired from `_PulseAppState.didChangeAppLifecycleState` in main.dart.
/// Background-tolerant services (heartbeat, probe, network monitor) listen
/// here and stop their periodic work while paused — the inbox readers
/// stay alive so messages still arrive while the OS keeps the process.
class AppLifecycleService extends ChangeNotifier {
  static final AppLifecycleService instance = AppLifecycleService._();
  AppLifecycleService._();

  bool _isPaused = false;
  bool get isPaused => _isPaused;
  bool get isForeground => !_isPaused;

  void setPaused(bool paused) {
    if (_isPaused == paused) return;
    _isPaused = paused;
    debugPrint('[AppLifecycle] ${paused ? "paused (background)" : "resumed (foreground)"}');
    notifyListeners();
  }
}
