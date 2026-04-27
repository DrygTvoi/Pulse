/// Lifecycle phase of a 1-on-1 call from the UI's perspective.
///
/// Decoupled from raw [RTCIceConnectionState] / signaling state so the UI
/// layer can render the same overlay/background for "we're waiting on the
/// other side" regardless of which transport is currently active.
enum CallPhase {
  /// Caller, not yet connected.
  dialing,

  /// Callee, not yet connected (rarely shown — incoming_call_screen handles
  /// the pre-accept ringing UI).
  ringing,

  /// ICE checking / not yet stable, but past dialing.
  connecting,

  /// ICE connected, remote stream contains audio only.
  connectedAudio,

  /// ICE connected, remote stream contains video.
  connectedVideo,

  /// Was connected, ICE failed/disconnected, attempting to recover.
  reconnecting,

  /// Hangup initiated — UI is fading out.
  ended,
}

extension CallPhaseX on CallPhase {
  bool get isConnected =>
      this == CallPhase.connectedAudio || this == CallPhase.connectedVideo;
  bool get isPreConnect =>
      this == CallPhase.dialing ||
      this == CallPhase.ringing ||
      this == CallPhase.connecting;
}
