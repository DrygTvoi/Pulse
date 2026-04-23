import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../models/contact.dart';
import '../models/contact_repository.dart';
import '../controllers/chat_controller.dart';
import '../l10n/l10n_ext.dart';
import '../widgets/avatar_widget.dart';

/// Hard cap on how many people can sit in a mesh-mode group call. Each
/// participant runs N−1 PeerConnections; CPU + uplink usage scales with
/// this number, so we cap at 4 to keep desktop+mobile usable. SFU groups
/// scale to ~20 thanks to the server doing the fan-out for them.
const int kMeshGroupLimit = 4;
const int kSfuGroupLimit = 20;
const String _kDefaultPulseServer = 'https://duck.azxc.site:443';

class CreateGroupDialog extends StatefulWidget {
  final Function(Contact group) onCreate;
  const CreateGroupDialog({super.key, required this.onCreate});

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  final _serverUrlController = TextEditingController(text: _kDefaultPulseServer);
  final _serverInviteController = TextEditingController();
  final Set<String> _selectedIds = {};
  late List<Contact> _contacts;
  Uint8List? _avatarBytes;
  bool _step2 = false; // false = name+avatar+mode, true = member selection
  String _callMode = 'mesh'; // 'mesh' (default) | 'sfu'
  bool _serverIsClosed = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() { if (mounted) setState(() {}); });
    _searchController.addListener(() { if (mounted) setState(() {}); });
    _serverUrlController.addListener(() { if (mounted) setState(() {}); });
    // Pre-fill the Pulse server URL from the user's own pulse_server_url
    // setting if they have one configured (most likely scenario for SFU).
    SharedPreferences.getInstance().then((prefs) {
      final saved = prefs.getString('pulse_server_url') ?? '';
      if (saved.isNotEmpty && mounted) {
        _serverUrlController.text = saved;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _contacts = context.read<IContactRepository>().contacts.where((c) => !c.isGroup).toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    _serverUrlController.dispose();
    _serverInviteController.dispose();
    super.dispose();
  }

  int get _memberLimit =>
      _callMode == 'mesh' ? kMeshGroupLimit - 1 : kSfuGroupLimit - 1;
  // -1 because the creator counts toward the group total but isn't in
  // _selectedIds (which lists OTHER members the creator picked).

  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final bytes = result.files.first.bytes;
    if (bytes == null) return;
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return;
    final resized = img.copyResizeCropSquare(decoded, size: 256);
    final jpeg = img.encodeJpg(resized, quality: 85);
    if (mounted) setState(() => _avatarBytes = Uint8List.fromList(jpeg));
  }

  /// True iff the user picked SFU but the server URL is empty. Disables
  /// the Next button so we can't accidentally create a broken SFU group.
  bool get _sfuConfigInvalid {
    if (_callMode != 'sfu') return false;
    final url = _serverUrlController.text.trim();
    return !(url.startsWith('https://') || url.startsWith('http://'));
  }

  void _goToStep2() {
    if (_nameController.text.trim().isEmpty) return;
    if (_sfuConfigInvalid) return;
    setState(() => _step2 = true);
  }

  void _goBack() => setState(() => _step2 = false);

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedIds.length < 2) return;
    if (_sfuConfigInvalid) return;

    final myId = context.read<ChatController>().identity?.id ?? '';
    final isSfu = _callMode == 'sfu';
    final group = Contact(
      id: const Uuid().v4(),
      name: name,
      provider: 'group',
      databaseId: '',
      publicKey: '',
      isGroup: true,
      members: _selectedIds.toList(),
      creatorId: myId.isNotEmpty ? myId : null,
      groupCallMode: _callMode,
      groupServerUrl: isSfu ? _serverUrlController.text.trim() : '',
      groupServerInvite:
          isSfu && _serverIsClosed ? _serverInviteController.text.trim() : '',
    );
    widget.onCreate(group);
    Navigator.pop(context);
  }

  List<Contact> get _filteredContacts {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _contacts;
    return _contacts.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: _step2 ? _buildStep2() : _buildStep1(),
        ),
      ),
    );
  }

  // ── Step 1: Group name + avatar ────────────────────────────
  Widget _buildStep1() {
    final name = _nameController.text.trim();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.group_add_rounded, color: AppTheme.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Text(context.l10n.groupNewGroup, style: GoogleFonts.inter(
                color: AppTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
            const Spacer(),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close_rounded, color: AppTheme.textSecondary, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ]),
          const SizedBox(height: 24),

          // Avatar
          GestureDetector(
            onTap: _pickAvatar,
            child: Stack(
              children: [
                if (_avatarBytes != null)
                  AvatarWidget(name: name, size: 80, imageBytes: _avatarBytes)
                else
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(Icons.camera_alt_rounded,
                        color: AppTheme.textSecondary, size: 28),
                  ),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.surface, width: 2),
                    ),
                    child: Icon(Icons.edit_rounded, size: 11, color: AppTheme.onPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Name field
          TextField(
            controller: _nameController,
            autofocus: true,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: context.l10n.groupGroupName,
              hintStyle: GoogleFonts.inter(
                  color: AppTheme.textSecondary.withValues(alpha: 0.5), fontSize: 15),
              filled: true,
              fillColor: AppTheme.surfaceVariant,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onSubmitted: (_) => _goToStep2(),
          ),
          const SizedBox(height: 16),

          // Call-mode picker
          _buildCallModePicker(),

          // Pulse server fields (only visible in SFU mode)
          if (_callMode == 'sfu') ...[
            const SizedBox(height: 12),
            _buildPulseServerFields(),
          ],
          const SizedBox(height: 20),

          // Next button
          SizedBox(
            width: double.infinity, height: 48,
            child: FilledButton(
              onPressed: (name.isNotEmpty && !_sfuConfigInvalid) ? _goToStep2 : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(context.l10n.next, style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.onPrimary)),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 18, color: AppTheme.onPrimary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Two-option segmented control: 🌐 Mesh ⚡ SFU. Each tile shows a short
  /// description so the user understands the trade-off without leaving the
  /// dialog (mesh = no server / small group, sfu = server / bigger group).
  Widget _buildCallModePicker() {
    return Row(
      children: [
        Expanded(child: _modeTile(
          mode: 'mesh',
          icon: Icons.public_rounded,
          title: context.l10n.groupModeMeshTitle,
          subtitle: context.l10n.groupModeMeshSubtitle(kMeshGroupLimit),
        )),
        const SizedBox(width: 8),
        Expanded(child: _modeTile(
          mode: 'sfu',
          icon: Icons.bolt_rounded,
          title: context.l10n.groupModeSfuTitle,
          subtitle: context.l10n.groupModeSfuSubtitle(kSfuGroupLimit),
        )),
      ],
    );
  }

  Widget _modeTile({
    required String mode,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = _callMode == mode;
    return InkWell(
      onTap: () {
        setState(() {
          _callMode = mode;
          // Trim selection if switching from sfu→mesh would exceed limit.
          if (mode == 'mesh' && _selectedIds.length > _memberLimit) {
            final keep = _selectedIds.take(_memberLimit).toSet();
            _selectedIds
              ..clear()
              ..addAll(keep);
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withValues(alpha: 0.15)
              : AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppTheme.primary
                : AppTheme.textSecondary.withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20,
                color: selected ? AppTheme.primary : AppTheme.textSecondary),
            const SizedBox(height: 8),
            Text(title,
                style: GoogleFonts.inter(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildPulseServerFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _serverUrlController,
          style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            hintText: context.l10n.groupPulseServerHint,
            hintStyle: GoogleFonts.inter(
                color: AppTheme.textSecondary.withValues(alpha: 0.5), fontSize: 12),
            prefixIcon: Icon(Icons.dns_rounded,
                color: AppTheme.textSecondary, size: 18),
            isDense: true,
            filled: true,
            fillColor: AppTheme.surfaceVariant,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => setState(() => _serverIsClosed = !_serverIsClosed),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(children: [
              SizedBox(
                width: 18, height: 18,
                child: Checkbox(
                  value: _serverIsClosed,
                  onChanged: (v) => setState(() => _serverIsClosed = v ?? false),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(context.l10n.groupPulseServerClosed,
                    style: GoogleFonts.inter(
                        color: AppTheme.textPrimary, fontSize: 12)),
              ),
            ]),
          ),
        ),
        if (_serverIsClosed) ...[
          const SizedBox(height: 4),
          TextField(
            controller: _serverInviteController,
            style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              hintText: context.l10n.groupPulseInviteHint,
              hintStyle: GoogleFonts.inter(
                  color: AppTheme.textSecondary.withValues(alpha: 0.5), fontSize: 12),
              prefixIcon: Icon(Icons.vpn_key_rounded,
                  color: AppTheme.textSecondary, size: 18),
              isDense: true,
              filled: true,
              fillColor: AppTheme.surfaceVariant,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ],
    );
  }

  // ── Step 2: Select members ────────────────────────────────
  Widget _buildStep2() {
    final filtered = _filteredContacts;
    final name = _nameController.text.trim();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with back button
          Row(children: [
            IconButton(
              onPressed: _goBack,
              icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            // Mini group avatar + name
            AvatarWidget(name: name, size: 28, imageBytes: _avatarBytes),
            const SizedBox(width: 8),
            Expanded(
              child: Text(name, style: GoogleFonts.inter(
                  color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close_rounded, color: AppTheme.textSecondary, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ]),
          const SizedBox(height: 12),

          // Selected member chips
          if (_selectedIds.isNotEmpty) ...[
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _selectedIds.map((id) {
                  final c = _contacts.firstWhere((c) => c.id == id,
                      orElse: () => Contact(id: id, name: '?', provider: '', databaseId: '', publicKey: ''));
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Chip(
                      label: Text(c.name, style: GoogleFonts.inter(
                          color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
                      deleteIcon: Icon(Icons.close_rounded, size: 14, color: AppTheme.textSecondary),
                      onDeleted: () => setState(() => _selectedIds.remove(id)),
                      backgroundColor: AppTheme.surfaceVariant,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Search
          TextField(
            controller: _searchController,
            style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              hintText: context.l10n.groupSearchContactsHint,
              hintStyle: GoogleFonts.inter(
                  color: AppTheme.textSecondary.withValues(alpha: 0.5), fontSize: 13),
              prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textSecondary, size: 18),
              isDense: true,
              filled: true,
              fillColor: AppTheme.surfaceVariant,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 8),

          // Sub-header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              Text(context.l10n.groupSelectMembers,
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
              const Spacer(),
              if (_selectedIds.isNotEmpty)
                Text(context.l10n.groupSelectedCount(_selectedIds.length),
                    style: GoogleFonts.inter(
                        color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w600)),
            ]),
          ),

          // Contact list
          if (_contacts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(context.l10n.groupNoContactsYet,
                  style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final c = filtered[i];
                  final selected = _selectedIds.contains(c.id);
                  final atLimit = !selected && _selectedIds.length >= _memberLimit;
                  return InkWell(
                    onTap: atLimit
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(context.l10n.groupMeshLimitReached(
                                  _callMode == 'mesh'
                                      ? kMeshGroupLimit
                                      : kSfuGroupLimit)),
                              duration: const Duration(seconds: 2),
                            ));
                          }
                        : () => setState(() {
                              if (selected) {
                                _selectedIds.remove(c.id);
                              } else {
                                _selectedIds.add(c.id);
                              }
                            }),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
                      child: Row(children: [
                        AvatarWidget(name: c.name, size: 38),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(c.name,
                              style: GoogleFonts.inter(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                            color: selected ? AppTheme.primary : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected ? AppTheme.primary : AppTheme.textSecondary.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: selected
                              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                              : null,
                        ),
                      ]),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),

          // Create button
          SizedBox(
            width: double.infinity, height: 48,
            child: FilledButton(
              onPressed: _selectedIds.length >= 2 ? _submit : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                '${context.l10n.groupCreate}${_selectedIds.length >= 2 ? ' (${_selectedIds.length})' : ''}',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.onPrimary)),
            ),
          ),
        ],
      ),
    );
  }
}
