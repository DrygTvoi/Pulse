import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages an Android foreground service that keeps the app process alive
/// so WebSocket connections continue receiving messages in the background.
///
/// On non-Android platforms this is a no-op.
class BackgroundService {
  static final BackgroundService instance = BackgroundService._();
  BackgroundService._();

  static const _kEnabledKey = 'background_service_enabled';
  bool _running = false;

  bool get isRunning => _running;

  /// Initialize the foreground task configuration (call once at startup).
  void init() {
    if (!Platform.isAndroid) return;
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'pulse_bg_service',
        channelName: 'Background Service',
        channelDescription: 'Keeps message delivery active in the background',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        enableVibration: false,
        playSound: false,
        showWhen: false,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(60000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  /// Start the foreground service if enabled in user preferences.
  Future<void> startIfEnabled() async {
    if (!Platform.isAndroid) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kEnabledKey) ?? false) {
      await start();
    }
  }

  /// Start the foreground service.
  Future<void> start() async {
    if (!Platform.isAndroid || _running) return;
    _running = true;

    final result = await FlutterForegroundTask.startService(
      notificationTitle: 'Pulse',
      notificationText: 'Message delivery active',
      callback: _taskCallback,
    );
    debugPrint('[BackgroundService] Start result: $result');
  }

  /// Stop the foreground service.
  Future<void> stop() async {
    if (!Platform.isAndroid || !_running) return;
    _running = false;
    await FlutterForegroundTask.stopService();
    debugPrint('[BackgroundService] Stopped');
  }

  /// Toggle the service and persist the preference.
  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabledKey, enabled);
    if (enabled) {
      await start();
    } else {
      await stop();
    }
  }

  /// Check if the service is enabled in preferences.
  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kEnabledKey) ?? false;
  }
}

/// Top-level callback for the foreground task.
/// Runs in the same isolate — keeps the process alive so existing
/// WebSocket connections continue receiving messages.
@pragma('vm:entry-point')
void _taskCallback() {
  FlutterForegroundTask.setTaskHandler(_KeepAliveHandler());
}

class _KeepAliveHandler extends TaskHandler {
  int _ticks = 0;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    debugPrint('[BackgroundService] Task started');
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    _ticks++;
    // Update the notification text so Android does not kill the service
    // for appearing idle, and so the user can see it is still active.
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    FlutterForegroundTask.updateService(
      notificationText: 'Active · last checked $h:$m',
    );
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool byUser) async {
    debugPrint('[BackgroundService] Task destroyed (byUser=$byUser, ticks=$_ticks)');
  }
}
