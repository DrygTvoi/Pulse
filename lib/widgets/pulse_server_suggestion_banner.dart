import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/chat_controller.dart';
import '../l10n/l10n_ext.dart';
import '../models/contact.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';

/// Small banner shown at the top of a chat when [contact] advertises a
/// Pulse server in their transport addresses and the local user has no
/// Pulse inbox configured yet. Tap prompts a confirmation popup, then
/// dispatches to [ChatController.joinPulseServer]. User can snooze (7d)
/// or permanently dismiss.
///
/// The widget self-hides when: we already have Pulse, the contact has no
/// Pulse address, or the banner was dismissed for this (contact, server)
/// pair.
class PulseServerSuggestionBanner extends StatefulWidget {
  final Contact contact;
  const PulseServerSuggestionBanner({super.key, required this.contact});

  @override
  State<PulseServerSuggestionBanner> createState() =>
      _PulseServerSuggestionBannerState();
}

class _PulseServerSuggestionBannerState
    extends State<PulseServerSuggestionBanner> {
  bool _checking = true;
  bool _dismissed = false;
  bool _busy = false;
  String? _serverUrl;
  ChatController? _ctrl;

  @override
  void initState() {
    super.initState();
    _refresh();
    // Re-evaluate when contact transport map changes (addr_update arrives
    // while chat is open) or when local Pulse gets configured.
    _ctrl = ChatController();
    _ctrl!.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _ctrl?.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    _refresh();
  }

  @override
  void didUpdateWidget(covariant PulseServerSuggestionBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contact.id != widget.contact.id) {
      _refresh();
    }
  }

  Future<void> _refresh() async {
    final ctrl = context.read<ChatController>();
    if (ctrl.hasPulseConfigured) {
      if (mounted) setState(() { _checking = false; _serverUrl = null; });
      return;
    }
    final suggested = ctrl.suggestedPulseServerForContact(widget.contact);
    if (suggested == null) {
      if (mounted) setState(() { _checking = false; _serverUrl = null; });
      return;
    }
    final dismissed =
        await ctrl.isPulseSuggestionDismissed(widget.contact.id, suggested);
    if (!mounted) return;
    setState(() {
      _checking = false;
      _serverUrl = suggested;
      _dismissed = dismissed;
    });
  }

  String _displayHost(String url) {
    final u = Uri.tryParse(url);
    if (u == null) return url;
    return u.host + (u.hasPort ? ':${u.port}' : '');
  }

  Future<void> _onTap() async {
    final server = _serverUrl;
    if (server == null || _busy) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.spacing16)),
        title: Text(context.l10n.pulseUseServerTitle,
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        content: Text(
          context.l10n.pulseUseServerBody(
              widget.contact.name, _displayHost(server)),
          style: GoogleFonts.inter(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.pulseNotNow,
                style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
            child: Text(context.l10n.pulseJoin,
                style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _busy = true);
    final ctrl = context.read<ChatController>();
    final error = await ctrl.joinPulseServer(server);
    if (!mounted) return;
    setState(() => _busy = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    // Success — hide the banner. addr_update is fired by reconnectInbox.
    setState(() { _serverUrl = null; _dismissed = true; });
  }

  Future<void> _snooze({bool permanent = false}) async {
    final server = _serverUrl;
    if (server == null) return;
    final ctrl = context.read<ChatController>();
    await ctrl.dismissPulseSuggestion(widget.contact.id, server,
        permanent: permanent);
    if (mounted) setState(() => _dismissed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_checking || _dismissed || _serverUrl == null) {
      return const SizedBox.shrink();
    }
    final server = _serverUrl!;
    return Material(
      color: AppTheme.surface,
      child: InkWell(
        onTap: _busy ? null : _onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacing14, vertical: DesignTokens.spacing10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppTheme.textSecondary.withValues(alpha: 0.12),
              ),
            ),
          ),
          child: Row(children: [
            Icon(Icons.flash_on_rounded,
                size: DesignTokens.iconMd, color: AppTheme.primary),
            const SizedBox(width: DesignTokens.spacing10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.pulseContactUsesPulse(widget.contact.name),
                    style: GoogleFonts.inter(
                        fontSize: DesignTokens.fontMd,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary),
                  ),
                  Text(
                    context.l10n.pulseJoinForFaster(_displayHost(server)),
                    style: GoogleFonts.inter(
                        fontSize: DesignTokens.fontSm,
                        color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            if (_busy)
              const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              PopupMenuButton<String>(
                icon: Icon(Icons.close_rounded,
                    size: DesignTokens.iconMd, color: AppTheme.textSecondary),
                tooltip: context.l10n.pulseDismiss,
                onSelected: (v) {
                  if (v == 'snooze') _snooze();
                  if (v == 'never') _snooze(permanent: true);
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                      value: 'snooze',
                      child: Text(ctx.l10n.pulseHide7Days)),
                  PopupMenuItem(
                      value: 'never',
                      child: Text(ctx.l10n.pulseNeverAskAgain)),
                ],
              ),
          ]),
        ),
      ),
    );
  }
}
