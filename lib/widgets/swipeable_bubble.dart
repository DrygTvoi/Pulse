import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';

/// Wraps a message bubble with swipe-right-to-reply gesture.
class SwipeableBubble extends StatefulWidget {
  final Widget child;
  final VoidCallback onLongPress;
  final VoidCallback onSwiped;
  final void Function(Offset)? onSecondaryTapUp;

  const SwipeableBubble({
    super.key,
    required this.child,
    required this.onLongPress,
    required this.onSwiped,
    this.onSecondaryTapUp,
  });

  @override
  State<SwipeableBubble> createState() => _SwipeableBubbleState();
}

class _SwipeableBubbleState extends State<SwipeableBubble>
    with SingleTickerProviderStateMixin {
  double _offset = 0.0;
  bool _triggered = false;
  late AnimationController _springCtrl;
  Animation<double>? _springAnim;

  // Raw pointer tracking for reliable right-click (bypasses gesture arena)
  Offset? _secondaryDownPos;

  static const double _threshold = 72.0;

  @override
  void initState() {
    super.initState();
    _springCtrl = AnimationController(
      vsync: this,
      duration: DesignTokens.durationSlow,
    );
  }

  @override
  void dispose() {
    _springCtrl.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (_springCtrl.isAnimating) return;
    if (d.delta.dx > 0) {
      setState(() => _offset = (_offset + d.delta.dx).clamp(0.0, _threshold + 20.0));
    }
  }

  void _onDragEnd(DragEndDetails d) {
    if (_offset >= _threshold && !_triggered) {
      _triggered = true;
      widget.onSwiped();
    }
    _springBack();
  }

  void _springBack() {
    if (_offset == 0.0) {
      _triggered = false;
      return;
    }
    _springAnim = Tween<double>(begin: _offset, end: 0.0).animate(
      CurvedAnimation(parent: _springCtrl, curve: Curves.elasticOut),
    )..addListener(() {
      if (mounted) setState(() => _offset = _springAnim!.value);
    })..addStatusListener((s) {
      if (s == AnimationStatus.completed) _triggered = false;
    });
    _springCtrl.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final opacity = (_offset / _threshold).clamp(0.0, 1.0);
    return Listener(
      onPointerDown: (event) {
        if (event.buttons == kSecondaryMouseButton) {
          _secondaryDownPos = event.position;
        }
      },
      onPointerUp: (event) {
        final down = _secondaryDownPos;
        _secondaryDownPos = null;
        if (down != null && (event.position - down).distance < 20) {
          widget.onSecondaryTapUp?.call(event.position);
        }
      },
      child: GestureDetector(
      onLongPress: widget.onLongPress,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Transform.translate(
            offset: Offset(_offset, 0),
            child: widget.child,
          ),
          if (_offset > 4)
            Positioned(
              left: 6,
              top: 0,
              bottom: 0,
              child: Center(
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: 0.5 + 0.5 * opacity,
                    child: Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.reply_rounded,
                          size: 16, color: AppTheme.primary),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
    );
  }
}
