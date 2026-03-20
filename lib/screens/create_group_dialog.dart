import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../models/contact.dart';
import '../models/contact_repository.dart';
import '../l10n/l10n_ext.dart';

class CreateGroupDialog extends StatefulWidget {
  final Function(Contact group) onCreate;
  const CreateGroupDialog({super.key, required this.onCreate});

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final _nameController = TextEditingController();
  final Set<String> _selectedIds = {};
  late List<Contact> _contacts;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _contacts = context.read<IContactRepository>().contacts.where((c) => !c.isGroup).toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedIds.length < 2) return;

    final group = Contact(
      id: const Uuid().v4(),
      name: name,
      provider: 'group',
      databaseId: '',
      publicKey: '',
      isGroup: true,
      members: _selectedIds.toList(),
    );
    widget.onCreate(group);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.dialogRadius)),
      title: Text(context.l10n.groupNewGroup,
          style: GoogleFonts.inter(
              color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: DesignTokens.fontHeading)),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group name
            TextField(
              controller: _nameController,
              style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: DesignTokens.fontLg),
              decoration: InputDecoration(
                hintText: context.l10n.groupGroupName,
                hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary),
                prefixIcon: Icon(Icons.group_rounded, color: AppTheme.textSecondary, size: DesignTokens.fontHeading),
                filled: true,
                fillColor: AppTheme.surfaceVariant,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMedium), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                  borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: DesignTokens.cardPadding, vertical: DesignTokens.spacing12),
              ),
            ),
            const SizedBox(height: DesignTokens.spacing16),
            Text(context.l10n.groupSelectMembers,
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary, fontSize: DesignTokens.fontBody, fontWeight: FontWeight.w600)),
            const SizedBox(height: DesignTokens.spacing8),
            if (_contacts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacing12),
                child: Text(context.l10n.groupNoContactsYet,
                    style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd)),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _contacts.length,
                  itemBuilder: (_, i) {
                    final c = _contacts[i];
                    final selected = _selectedIds.contains(c.id);
                    return InkWell(
                      onTap: () => setState(() {
                        if (selected) { _selectedIds.remove(c.id); }
                        else { _selectedIds.add(c.id); }
                      }),
                      borderRadius: BorderRadius.circular(DesignTokens.spacing10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing4, vertical: DesignTokens.spacing6),
                        child: Row(children: [
                          _buildAvatar(c.name, 38),
                          const SizedBox(width: DesignTokens.spacing12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(c.name,
                                  style: GoogleFonts.inter(
                                      color: AppTheme.textPrimary,
                                      fontSize: DesignTokens.fontLg,
                                      fontWeight: FontWeight.w600)),
                              Text(c.provider,
                                  style: GoogleFonts.inter(
                                      color: AppTheme.textSecondary, fontSize: DesignTokens.fontBody)),
                            ]),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: DesignTokens.fontDisplay, height: DesignTokens.fontDisplay,
                            decoration: BoxDecoration(
                              color: selected ? AppTheme.primary : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected ? AppTheme.primary : AppTheme.textSecondary.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                            ),
                            child: selected
                                ? const Icon(Icons.check_rounded, size: DesignTokens.fontLg, color: Colors.white)
                                : null,
                          ),
                        ]),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel, style: GoogleFonts.inter(color: AppTheme.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _nameController.text.trim().isNotEmpty && _selectedIds.length >= 2
              ? _submit
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMedium)),
            elevation: 0,
          ),
          child: Text(context.l10n.groupCreate, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildAvatar(String name, double size) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final hue = (name.codeUnitAt(0) * 17 + name.length * 31) % 360;
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            HSLColor.fromAHSL(1, hue.toDouble(), 0.55, 0.42).toColor(),
            HSLColor.fromAHSL(1, hue.toDouble(), 0.5, 0.32).toColor(),
          ],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: Center(child: Text(initial,
          style: GoogleFonts.inter(color: Colors.white, fontSize: size * 0.42, fontWeight: FontWeight.w700))),
    );
  }
}
