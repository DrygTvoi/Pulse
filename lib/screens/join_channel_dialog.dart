import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../l10n/l10n_ext.dart';
import '../models/channel.dart';
import '../services/channel_service.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';

class JoinChannelDialog extends StatefulWidget {
  final void Function(Channel channel) onJoined;
  const JoinChannelDialog({super.key, required this.onJoined});

  @override
  State<JoinChannelDialog> createState() => _JoinChannelDialogState();
}

class _JoinChannelDialogState extends State<JoinChannelDialog> {
  final _urlController = TextEditingController();
  Timer? _debounce;
  bool _fetching = false;
  Channel? _channel;
  String? _error;
  bool _alreadyJoined = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _urlController.dispose();
    super.dispose();
  }

  void _onUrlChanged(String value) {
    _debounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      setState(() { _channel = null; _error = null; _alreadyJoined = false; });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 600), () => _fetchMetadata(trimmed));
  }

  Future<void> _fetchMetadata(String rawUrl) async {
    if (!mounted) return;
    setState(() { _fetching = true; _channel = null; _error = null; _alreadyJoined = false; });

    // Normalise: ensure https:// prefix, strip trailing slash
    var url = rawUrl;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    url = url.replaceAll(RegExp(r'/+$'), '');

    try {
      final uri = Uri.parse('$url/.well-known/pulse-channel');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final name = json['name'] as String? ?? '';
        if (name.isEmpty) {
          setState(() { _fetching = false; _error = context.l10n.joinChannelNotFound; });
          return;
        }
        final channel = Channel.fromWellKnown(json, url);
        // Check for duplicate
        final duplicate = ChannelService().channels.any((c) => c.url == url);
        setState(() {
          _fetching = false;
          _channel = channel;
          _alreadyJoined = duplicate;
        });
      } else {
        setState(() { _fetching = false; _error = context.l10n.joinChannelNotFound; });
      }
    } on TimeoutException {
      if (mounted) setState(() { _fetching = false; _error = context.l10n.joinChannelNetworkError; });
    } catch (e) {
      if (mounted) setState(() { _fetching = false; _error = context.l10n.joinChannelNetworkError; });
    }
  }

  Future<void> _join() async {
    final channel = _channel;
    if (channel == null || _alreadyJoined) return;
    await ChannelService().addChannel(channel);
    if (!mounted) return;
    widget.onJoined(channel);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.cell_tower_rounded, color: AppTheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(context.l10n.joinChannelTitle, style: GoogleFonts.inter(
                    color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close_rounded, color: AppTheme.textSecondary, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ]),
              const SizedBox(height: 20),

              // URL input
              Text(context.l10n.joinChannelDescription, style: GoogleFonts.inter(
                  color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    onChanged: _onUrlChanged,
                    style: GoogleFonts.jetBrainsMono(color: AppTheme.textPrimary, fontSize: 12),
                    decoration: InputDecoration(
                      hintText: context.l10n.joinChannelUrlHint,
                      hintStyle: GoogleFonts.inter(
                          color: AppTheme.textSecondary.withValues(alpha: 0.5), fontSize: 12),
                      filled: true, fillColor: AppTheme.surfaceVariant,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Paste',
                  child: InkWell(
                    onTap: () async {
                      final data = await Clipboard.getData(Clipboard.kTextPlain);
                      if (data?.text != null) {
                        _urlController.text = data!.text!.trim();
                        _onUrlChanged(_urlController.text);
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 42, height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.content_paste_rounded,
                          color: AppTheme.onPrimary, size: 18),
                    ),
                  ),
                ),
              ]),

              // Loading
              if (_fetching) ...[
                const SizedBox(height: 12),
                Row(children: [
                  SizedBox(width: 14, height: 14,
                      child: CircularProgressIndicator(strokeWidth: 1.5, color: AppTheme.primary)),
                  const SizedBox(width: 8),
                  Text(context.l10n.joinChannelFetching,
                      style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
                ]),
              ],

              // Error
              if (_error != null) ...[
                const SizedBox(height: 12),
                Row(children: [
                  Icon(Icons.error_outline_rounded, size: 14, color: Colors.redAccent),
                  const SizedBox(width: 6),
                  Expanded(child: Text(_error!,
                      style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 12))),
                ]),
              ],

              // Preview card
              if (_channel != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.cell_tower_rounded, color: AppTheme.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_channel!.name, style: GoogleFonts.inter(
                            color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                        if (_channel!.description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(_channel!.description, style: GoogleFonts.inter(
                              color: AppTheme.textSecondary, fontSize: 12),
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ],
                    )),
                    Icon(Icons.check_circle_rounded, size: 18, color: AppTheme.primary),
                  ]),
                ),
              ],
              const SizedBox(height: 20),

              // Join button
              SizedBox(
                width: double.infinity, height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: (_channel != null && !_alreadyJoined)
                        ? AppTheme.primary
                        : AppTheme.surfaceVariant,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: (_channel != null && !_alreadyJoined) ? _join : null,
                  child: Text(
                    _alreadyJoined
                        ? context.l10n.joinChannelAlreadyJoined
                        : context.l10n.joinChannelButton,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: (_channel != null && !_alreadyJoined)
                            ? AppTheme.onPrimary
                            : AppTheme.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
