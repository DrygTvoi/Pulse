import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/l10n_ext.dart';
import '../models/contact.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';

/// Persistent yellow banner shown at the top of a Pulse-routed group chat
/// when the group's `groupServerUrl` doesn't match the user's own
/// `pulse_server_url` setting. The user explicitly chose to join a group
/// hosted on a third-party Pulse server — show them which one, so a
/// glance is enough to know "my messages here flow through someone
/// else's box".
///
/// Self-hides when:
///   - contact is not a group, or not pulse-routed
///   - group's server matches the user's own setting
///   - user has no own Pulse server (then everything they touch is
///     third-party by definition; the banner would just be noise)
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
  bool _isForeign = false;
  String? _ownServer;

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
      if (mounted) setState(() { _checking = false; _isForeign = false; });
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final own = (prefs.getString('pulse_server_url') ?? '').trim();
    final groupUrl = _canon(c.groupServerUrl);
    final ownUrl = _canon(own);
    if (!mounted) return;
    setState(() {
      _checking = false;
      _ownServer = own;
      // No own Pulse → user is implicitly OK with hosted services; the
      // banner adds noise without information. Only flag when their own
      // Pulse setting genuinely differs from the group's.
      _isForeign = own.isNotEmpty && groupUrl != ownUrl;
    });
  }

  String _canon(String url) {
    var u = url.trim().toLowerCase();
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    return u;
  }

  @override
  Widget build(BuildContext context) {
    if (_checking || !_isForeign) return const SizedBox.shrink();
    final groupUrl = widget.contact.groupServerUrl;
    final hostShort = _shortUrl(groupUrl);
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
