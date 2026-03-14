import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_status.dart';

/// Full-screen status viewer. Pass a list of (contactId, Contact, UserStatus)
/// entries and an optional initial index. Auto-advances after 5 seconds.
class StatusViewerScreen extends StatefulWidget {
  final List<({String contactId, String contactName, UserStatus status})> entries;
  final int initialIndex;

  const StatusViewerScreen({
    super.key,
    required this.entries,
    this.initialIndex = 0,
  });

  @override
  State<StatusViewerScreen> createState() => _StatusViewerScreenState();
}

class _StatusViewerScreenState extends State<StatusViewerScreen>
    with SingleTickerProviderStateMixin {
  late int _current;
  late AnimationController _progressCtrl;
  Timer? _advanceTimer;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex.clamp(0, widget.entries.length - 1);
    _progressCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _startProgress();
  }

  void _startProgress() {
    _advanceTimer?.cancel();
    _progressCtrl.reset();
    _progressCtrl.forward();
    _advanceTimer = Timer(const Duration(seconds: 5), _advance);
  }

  void _advance() {
    if (_current < widget.entries.length - 1) {
      setState(() => _current++);
      _startProgress();
    } else {
      if (mounted) Navigator.pop(context);
    }
  }

  void _goTo(int index) {
    if (index < 0 || index >= widget.entries.length) return;
    setState(() => _current = index);
    _startProgress();
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entries[_current];
    final status = entry.status;
    final initial = entry.contactName.isNotEmpty ? entry.contactName[0].toUpperCase() : '?';
    final hue = entry.contactName.isNotEmpty
        ? (entry.contactName.codeUnitAt(0) * 17 + entry.contactName.length * 31) % 360
        : 180;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: (details) {
          final width = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < width / 2) {
            _goTo(_current - 1);
          } else {
            _goTo(_current + 1);
          }
        },
        child: Stack(
          children: [
            // Background
            if (status.hasMedia) _buildMediaBackground(status.mediaPayload!)
            else Container(color: Colors.black87),

            // Overlay gradient for text readability
            if (!status.hasMedia || status.text.isNotEmpty)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.5),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
              ),

            // Progress bars (top)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8, right: 8,
              child: Row(
                children: List.generate(widget.entries.length, (i) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: SizedBox(
                          height: 3,
                          child: i < _current
                              ? Container(color: Colors.white)
                              : i == _current
                                  ? AnimatedBuilder(
                                      animation: _progressCtrl,
                                      builder: (context, _) => LinearProgressIndicator(
                                        value: _progressCtrl.value,
                                        backgroundColor: Colors.white38,
                                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                                        minHeight: 3,
                                      ),
                                    )
                                  : Container(color: Colors.white38),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Header: contact name + close button
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 12, right: 12,
              child: Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        HSLColor.fromAHSL(1, hue.toDouble(), 0.55, 0.42).toColor(),
                        HSLColor.fromAHSL(1, hue.toDouble(), 0.5, 0.30).toColor(),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(initial,
                        style: GoogleFonts.inter(
                            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.contactName,
                          style: GoogleFonts.inter(
                              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                      Text(_formatAgo(status.createdAt),
                          style: GoogleFonts.inter(
                              color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ]),
            ),

            // Text content (center or bottom)
            if (status.text.isNotEmpty)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 48,
                left: 24, right: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.text,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            else if (!status.hasMedia)
              Center(
                child: Text(
                  status.text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaBackground(String mediaPayload) {
    try {
      final bytes = base64Decode(mediaPayload.contains(',')
          ? mediaPayload.split(',').last
          : mediaPayload);
      return Positioned.fill(
        child: Image.memory(bytes, fit: BoxFit.cover),
      );
    } catch (_) {
      return Container(color: Colors.black87);
    }
  }

  String _formatAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}
