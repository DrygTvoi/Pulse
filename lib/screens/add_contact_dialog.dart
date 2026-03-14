import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/contact.dart';
import '../theme/app_theme.dart';

class AddContactDialog extends StatefulWidget {
  final Function(Contact) onAdd;
  const AddContactDialog({super.key, required this.onAdd});

  @override
  State<AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  final _nameController = TextEditingController();
  final _manualAddressController = TextEditingController();

  List<String> _detectedAddresses = [];
  bool _showManual = false;
  bool _fetchingProfile = false;
  String? _profileFetchStatus;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _nameController.dispose();
    _manualAddressController.dispose();
    super.dispose();
  }

  static String _detectProvider(String address) {
    final lower = address.toLowerCase();
    if (lower.startsWith('05') && lower.length == 66 &&
        RegExp(r'^[0-9a-f]{66}$').hasMatch(lower)) { return 'Oxen'; }
    if (lower.contains('@wss://') || lower.contains('@ws://') ||
        RegExp(r'^[0-9a-f]{64}$').hasMatch(lower)) { return 'Nostr'; }
    if (lower.contains('@https://')) { return 'Firebase'; }
    if (lower.contains('@http://')) { return 'Waku'; }
    return 'Nostr';
  }

  void _onInput(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    if (trimmed.startsWith('pulse://') || trimmed.startsWith('messenger://')) {
      _parsePulseLink(trimmed);
    } else {
      setState(() => _detectedAddresses = [trimmed]);
      if (_detectProvider(trimmed) == 'Nostr') _tryScheduleNostrFetch(trimmed);
    }
  }

  void _parsePulseLink(String link) {
    try {
      final uri = Uri.parse(link);
      final cfg64 = uri.queryParameters['cfg'];
      if (cfg64 == null) return;
      final json = jsonDecode(utf8.decode(base64Decode(cfg64))) as Map<String, dynamic>;

      final dynamic rawA = json['a'];
      final List<String> addresses;
      if (rawA is List) {
        addresses = rawA.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
      } else if (rawA is String && rawA.isNotEmpty) {
        addresses = [rawA];
      } else {
        return;
      }
      if (addresses.isEmpty) return;

      final name = (json['n'] as String?)?.trim() ?? '';
      setState(() {
        _detectedAddresses = addresses;
        if (name.isNotEmpty && _nameController.text.isEmpty) {
          _nameController.text = name;
        }
      });
      if (_nameController.text.isEmpty && _detectProvider(addresses.first) == 'Nostr') {
        _tryScheduleNostrFetch(addresses.first);
      }
    } catch (_) {
      _onInput(link);
    }
  }

  void _tryScheduleNostrFetch(String address) {
    _debounceTimer?.cancel();
    final lower = address.toLowerCase();
    String pubkey;
    String relayWs;
    if (lower.contains('@wss://') || lower.contains('@ws://')) {
      final atIdx = address.indexOf('@');
      if (atIdx < 0) return;
      pubkey = address.substring(0, atIdx).toLowerCase();
      relayWs = address.substring(atIdx + 1);
    } else if (RegExp(r'^[0-9a-f]{64}$').hasMatch(lower)) {
      pubkey = lower;
      relayWs = 'wss://relay.damus.io';
    } else {
      return;
    }
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(pubkey)) return;
    _debounceTimer = Timer(const Duration(milliseconds: 600), () => _fetchNostrProfile(pubkey, relayWs));
  }

  Future<void> _fetchNostrProfile(String pubkey, String relayWs) async {
    if (!mounted) return;
    setState(() { _fetchingProfile = true; _profileFetchStatus = 'Fetching profile…'; });
    WebSocketChannel? channel;
    try {
      channel = WebSocketChannel.connect(Uri.parse(relayWs));
      final subId = 'meta_${Random().nextInt(999999)}';
      channel.sink.add(jsonEncode(['REQ', subId, {'kinds': [0], 'authors': [pubkey], 'limit': 1}]));
      String? foundName;
      await for (final raw in channel.stream.timeout(const Duration(seconds: 6))) {
        final msg = jsonDecode(raw as String) as List<dynamic>;
        if (msg.isEmpty) continue;
        if (msg[0] == 'EVENT' && msg.length >= 3) {
          final event = msg[2] as Map<String, dynamic>;
          if (event['kind'] == 0) {
            try {
              final content = jsonDecode(event['content'] as String) as Map<String, dynamic>;
              final n = (content['display_name'] as String?)?.trim() ??
                  (content['name'] as String?)?.trim();
              if (n != null && n.isNotEmpty) foundName = n;
            } catch (_) {}
          }
        } else if (msg[0] == 'EOSE') { break; }
      }
      if (!mounted) return;
      if (foundName != null) {
        setState(() { _fetchingProfile = false; _profileFetchStatus = 'Found: $foundName'; });
        if (_nameController.text.isEmpty) _nameController.text = foundName;
      } else {
        setState(() { _fetchingProfile = false; _profileFetchStatus = 'No profile found'; });
      }
    } catch (_) {
      if (mounted) setState(() { _fetchingProfile = false; _profileFetchStatus = null; });
    } finally {
      channel?.sink.close();
    }
  }

  void _addManualAddress() {
    final addr = _manualAddressController.text.trim();
    if (addr.isEmpty) return;
    if (!_detectedAddresses.contains(addr)) {
      setState(() => _detectedAddresses.add(addr));
    }
    _manualAddressController.clear();
  }

  void _submit() {
    if (_detectedAddresses.isEmpty) return;
    final primaryAddr = _detectedAddresses.first;
    final alternates = _detectedAddresses.length > 1 ? _detectedAddresses.sublist(1) : <String>[];
    final provider = _detectProvider(primaryAddr);
    String name = _nameController.text.trim();
    if (name.isEmpty) {
      final atIdx = primaryAddr.indexOf('@');
      final raw = atIdx > 0 ? primaryAddr.substring(0, atIdx) : primaryAddr;
      name = raw.length > 12 ? raw.substring(0, 12) : raw;
    }
    widget.onAdd(Contact(
      id: const Uuid().v4(),
      name: name,
      provider: provider,
      databaseId: primaryAddr,
      publicKey: '',
      alternateAddresses: alternates,
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final hasAddresses = _detectedAddresses.isNotEmpty;

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
              // ── Header ──────────────────────────────────────
              Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.person_add_rounded, color: AppTheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text('Add Contact', style: GoogleFonts.inter(
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

              // ── Paste area ───────────────────────────────────
              _label('Invite Link or Address'),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final data = await Clipboard.getData(Clipboard.kTextPlain);
                      if (data?.text != null) _onInput(data!.text!.trim());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: hasAddresses
                              ? AppTheme.primary.withValues(alpha: 0.4)
                              : Colors.transparent,
                        ),
                      ),
                      child: hasAddresses
                          ? Text(
                              _detectedAddresses.first.length > 44
                                  ? '${_detectedAddresses.first.substring(0, 42)}…'
                                  : _detectedAddresses.first,
                              style: GoogleFonts.jetBrainsMono(
                                  color: AppTheme.textPrimary, fontSize: 11),
                            )
                          : Row(children: [
                              Icon(Icons.link_rounded, color: AppTheme.textSecondary, size: 16),
                              const SizedBox(width: 8),
                              Text('Tap to paste invite link',
                                  style: GoogleFonts.inter(
                                      color: AppTheme.textSecondary.withValues(alpha: 0.6),
                                      fontSize: 13)),
                            ]),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Paste from clipboard',
                  child: InkWell(
                    onTap: () async {
                      final data = await Clipboard.getData(Clipboard.kTextPlain);
                      if (data?.text != null) _onInput(data!.text!.trim());
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 42, height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.content_paste_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ]),

              // ── Detected routes summary ──────────────────────
              if (_detectedAddresses.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(children: [
                    Icon(Icons.shuffle_rounded, size: 14, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _detectedAddresses.length == 1
                            ? 'Contact address detected'
                            : '${_detectedAddresses.length} routes detected — SmartRouter picks the fastest',
                        style: GoogleFonts.inter(
                            color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Icon(Icons.check_circle_rounded, size: 14, color: AppTheme.primary),
                  ]),
                ),
              ],

              // ── Nostr fetch status ───────────────────────────
              if (_profileFetchStatus != null) ...[
                const SizedBox(height: 6),
                Row(children: [
                  if (_fetchingProfile)
                    SizedBox(width: 11, height: 11,
                        child: CircularProgressIndicator(strokeWidth: 1.5, color: AppTheme.primary))
                  else
                    Icon(
                      _profileFetchStatus!.startsWith('Found')
                          ? Icons.check_circle_outline_rounded
                          : Icons.info_outline_rounded,
                      size: 13,
                      color: _profileFetchStatus!.startsWith('Found')
                          ? const Color(0xFF4CAF50)
                          : AppTheme.textSecondary,
                    ),
                  const SizedBox(width: 5),
                  Text(_profileFetchStatus!,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: _profileFetchStatus!.startsWith('Found')
                              ? const Color(0xFF4CAF50)
                              : AppTheme.textSecondary)),
                ]),
              ],
              const SizedBox(height: 16),

              // ── Name field ───────────────────────────────────
              _label('Display Name'),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'What do you want to call them?',
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),

              // ── Manual address entry ─────────────────────────
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => setState(() => _showManual = !_showManual),
                child: Row(children: [
                  Icon(_showManual ? Icons.expand_less : Icons.expand_more,
                      size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text('Add address manually',
                      style: GoogleFonts.inter(
                          color: AppTheme.textSecondary, fontSize: 12)),
                ]),
              ),
              if (_showManual) ...[
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _manualAddressController,
                      style: GoogleFonts.jetBrainsMono(
                          color: AppTheme.textPrimary, fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'pubkey@wss://relay  ·  05hex…  ·  id@https://...',
                        hintStyle: GoogleFonts.inter(
                            color: AppTheme.textSecondary.withValues(alpha: 0.4),
                            fontSize: 11),
                        filled: true, fillColor: AppTheme.surfaceVariant,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppTheme.primary, width: 1),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onSubmitted: (_) => _addManualAddress(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _addManualAddress,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.add, size: 16, color: AppTheme.primary),
                    ),
                  ),
                ]),
              ],
              const SizedBox(height: 20),

              // ── Add button ───────────────────────────────────
              SizedBox(
                width: double.infinity, height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: hasAddresses ? AppTheme.primary : AppTheme.surfaceVariant,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: hasAddresses ? _submit : null,
                  child: Text('Add Contact',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: GoogleFonts.inter(
          color: AppTheme.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5));
}
