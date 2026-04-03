import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/contact.dart';
import 'signaling_service.dart';

/// Singleton that holds an active call when the CallScreen is minimized.
///
/// While minimized the call continues running — SignalingService is kept alive
/// and an elapsed-time timer ticks every second so the banner updates.
class ActiveCallService extends ChangeNotifier {
  ActiveCallService._();
  static final ActiveCallService instance = ActiveCallService._();

  SignalingService? _signaling;
  Contact? _contact;
  String? _myId;
  bool? _isCaller;
  Duration _elapsed = Duration.zero;
  bool _minimized = false;

  Timer? _timer;

  bool get isMinimized => _minimized;
  Contact? get contact => _contact;
  String? get myId => _myId;
  bool? get isCaller => _isCaller;
  Duration get elapsed => _elapsed;
  SignalingService? get signaling => _signaling;

  /// Take ownership of a running call and start showing the minimized banner.
  ///
  /// [onRemoteHangUp] is called (before [endCall]) if the remote peer hangs up
  /// while the call is minimized — use it to save the call history record.
  void minimize({
    required SignalingService sig,
    required Contact contact,
    required String myId,
    required bool isCaller,
    required Duration elapsed,
    required VoidCallback onRemoteHangUp,
  }) {
    _signaling = sig;
    _contact = contact;
    _myId = myId;
    _isCaller = isCaller;
    _elapsed = elapsed;
    _minimized = true;

    // Continue incrementing elapsed while minimized so the banner stays live.
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed += const Duration(seconds: 1);
      notifyListeners();
    });

    // If the remote peer hangs up while we are minimized, invoke the provided
    // callback (which saves the call record), hang up properly, then clean up.
    _signaling!.onRemoteHangUp = () {
      onRemoteHangUp();
      // hangUp() without notify=true since remote already hung up.
      _signaling?.hangUp(notify: false);
      endCall();
    };

    notifyListeners();
  }

  /// Called when the user taps the banner to restore the full CallScreen.
  /// Stops the internal timer; the new CallScreen will start its own.
  void restore() {
    _minimized = false;
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  /// Called when the call ends (normal hang-up or remote hang-up while minimized).
  void endCall() {
    _minimized = false;
    _timer?.cancel();
    _timer = null;
    _signaling = null;
    _contact = null;
    _myId = null;
    _isCaller = null;
    _elapsed = Duration.zero;
    notifyListeners();
  }
}
