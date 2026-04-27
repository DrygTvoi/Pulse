import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../theme/app_theme.dart';
import '../../theme/design_tokens.dart';

enum _PipCorner { topLeft, topRight, bottomLeft, bottomRight }

/// Floating draggable PiP for the local video preview.
///
/// Snaps to the nearest of the 4 corners on pan-end. Hidden when [visible]
/// is false (e.g. audio call or camera off + not screen sharing).
class CallLocalPiP extends StatefulWidget {
  final RTCVideoRenderer renderer;
  final bool visible;
  final bool mirror;
  final Color borderColor;
  final EdgeInsets safeInsets;

  const CallLocalPiP({
    super.key,
    required this.renderer,
    required this.visible,
    this.mirror = true,
    this.borderColor = const Color(0xFF26A69A),
    this.safeInsets = const EdgeInsets.fromLTRB(12, 96, 12, 160),
  });

  @override
  State<CallLocalPiP> createState() => _CallLocalPiPState();
}

class _CallLocalPiPState extends State<CallLocalPiP> {
  static const double _w = 110;
  static const double _h = 150;

  _PipCorner _corner = _PipCorner.topRight;
  Offset? _drag; // active drag offset (top-left within parent)

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final parentSize = constraints.biggest;
        final cornerPos = _cornerPosition(parentSize);
        final pos = _drag ?? cornerPos;

        return Positioned(
          left: pos.dx,
          top: pos.dy,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (d) {
              setState(() => _drag = pos);
            },
            onPanUpdate: (d) {
              if (_drag == null) return;
              final next = _drag! + d.delta;
              final clamped = Offset(
                next.dx.clamp(0.0, parentSize.width - _w),
                next.dy.clamp(0.0, parentSize.height - _h),
              );
              setState(() => _drag = clamped);
            },
            onPanEnd: (_) {
              if (_drag == null) return;
              final center = Offset(
                _drag!.dx + _w / 2,
                _drag!.dy + _h / 2,
              );
              final isLeft = center.dx < parentSize.width / 2;
              final isTop = center.dy < parentSize.height / 2;
              setState(() {
                _corner = isTop
                    ? (isLeft ? _PipCorner.topLeft : _PipCorner.topRight)
                    : (isLeft
                        ? _PipCorner.bottomLeft
                        : _PipCorner.bottomRight);
                _drag = null;
              });
            },
            child: Container(
              width: _w,
              height: _h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                border: Border.all(
                  color: widget.borderColor.withValues(alpha: 0.85),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.background.withValues(alpha: 0.6),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(DesignTokens.radiusXl - 1),
                child: RTCVideoView(
                  widget.renderer,
                  mirror: widget.mirror,
                  objectFit:
                      RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            ).animate().scale(
                  duration: 240.ms,
                  curve: Curves.easeOutBack,
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                ),
          ),
        );
      },
    );
  }

  Offset _cornerPosition(Size parent) {
    final ins = widget.safeInsets;
    switch (_corner) {
      case _PipCorner.topLeft:
        return Offset(ins.left, ins.top);
      case _PipCorner.topRight:
        return Offset(parent.width - _w - ins.right, ins.top);
      case _PipCorner.bottomLeft:
        return Offset(ins.left, parent.height - _h - ins.bottom);
      case _PipCorner.bottomRight:
        return Offset(parent.width - _w - ins.right,
            parent.height - _h - ins.bottom);
    }
  }
}
