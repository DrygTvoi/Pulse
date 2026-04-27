import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/l10n_ext.dart';
import '../models/contact.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';

/// Yellow banner shown at the top of every pulse-routed group chat
/// telling the user which Pulse server is carrying their messages.
/// Dismissible per-group: once the user closes it for a specific
/// group, it stays hidden for that group via SharedPreferences flag
/// `pulse_banner_dismissed_<groupId>`.
///
/// Self-hides when:
///   - contact is not a group, or not pulse-routed
///   - the group has no `groupServerUrl` (legacy or invalid)
///   - the user has previously dismissed the banner for this group
class PulseGroupForeignServerBanner extends StatefulWidget {
  final Contact contact;
  const PulseGroupForeignServerBanner({super.key, required this.contact});

  @override
  State<PulseGroupForeignServerBanner> createState() =>
      _PulseGroupForeignServerBannerState();
}

class _PulseGroupForeignServerBannerState
    extends State<PulseGroupForeignServerBanner> {
  bool _checking = true;
  bool _hidden = false;

  static String _dismissKey(String groupId) =>
      'pulse_banner_dismissed_$groupId';

  @override
  void initState() {
    super.initState();
    _evaluate();
  }

  @override
  void didUpdateWidget(covariant PulseGroupForeignServerBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contact.id != widget.contact.id ||
        oldWidget.contact.groupServerUrl != widget.contact.groupServerUrl) {
      _evaluate();
    }
  }

  Future<void> _evaluate() async {
    final c = widget.contact;
    if (!c.isGroup || !c.isPulseGroup || c.groupServerUrl.isEmpty) {
      if (mounted) setState(() { _checking = false; _hidden = true; });
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final dismissed = prefs.getBool(_dismissKey(c.id)) ?? false;
    if (!mounted) return;
    setState(() {
      _checking = false;
      _hidden = dismissed;
    });
  }

  Future<void> _dismiss() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dismissKey(widget.contact.id), true);
    if (mounted) setState(() => _hidden = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_checking || _hidden) return const SizedBox.shrink();
    final hostShort = _shortUrl(widget.contact.groupServerUrl);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing12, vertical: DesignTokens.spacing8),
      color: const Color(0xFF3A2F0B), // muted amber/dark — matches dark theme
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: Color(0xFFFFC107), size: 18),
          const SizedBox(width: DesignTokens.spacing8),
          Expanded(
            child: Text(
              context.l10n.pulseGroupForeignServerBanner(hostShort),
              style: GoogleFonts.inter(
                  color: const Color(0xFFFFE082),
                  fontSize: DesignTokens.fontSm,
                  fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: DesignTokens.spacing8),
          InkWell(
            onTap: _dismiss,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.spacing4),
              child: Icon(Icons.close_rounded,
                  color: const Color(0xFFFFE082).withValues(alpha: 0.85),
                  size: 18),
            ),
          ),
        ],
      ),
    );
  }

  String _shortUrl(String url) {
    var u = url.trim();
    if (u.startsWith('https://')) u = u.substring(8);
    if (u.startsWith('http://')) u = u.substring(7);
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    return u;
  }
}
