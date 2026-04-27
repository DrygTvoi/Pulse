import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../models/contact.dart';
import '../../theme/app_theme.dart';
import 'call_phase.dart';

/// Layer 0 — what fills the entire call surface.
///
/// - In `connectedVideo`: full RTCVideoView (contained, black letterbox).
/// - Otherwise: a heavily blurred avatar wash (or solid hash color when no
///   avatar bytes) + AppTheme gradient. This is what kills the
///   "solid black screen with two buttons" bug — even pre-connect, the
///   user sees something rich.
class CallBackground extends StatelessWidget {
  final Contact contact;
  final CallPhase phase;
  final RTCVideoRenderer remoteRenderer;
  final Uint8List? avatarBytes;

  const CallBackground({
    super.key,
    required this.contact,
    required this.phase,
    required this.remoteRenderer,
    this.avatarBytes,
  });

  @override
  Widget build(BuildContext context) {
    if (phase == CallPhase.connectedVideo) {
      return Positioned.fill(
        child: Container(
          color: AppTheme.background,
          child: RTCVideoView(
            remoteRenderer,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
          ),
        ),
      );
    }

    return Positioned.fill(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Base solid color — never let raw black bleed through.
          Container(color: AppTheme.background),

          // Blurred avatar wash (only when we actually have bytes).
          if (avatarBytes != null && avatarBytes!.isNotEmpty)
            Opacity(
              opacity: 0.30,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Image.memory(
                  avatarBytes!,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),
              ),
            ),

          // Brand gradient on top — gives the screen its primary tint and a
          // smooth fade into background black at the bottom.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primary.withValues(alpha: 0.35),
                  AppTheme.background.withValues(alpha: 0.85),
                  AppTheme.background,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
