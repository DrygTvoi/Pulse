import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../theme/app_theme.dart';
import '../models/contact.dart';

class CreateGroupDialog extends StatefulWidget {
  final Function(Contact group) onCreate;
  const CreateGroupDialog({super.key, required this.onCreate});

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final _nameController = TextEditingController();
  final Set<String> _selectedIds = {};
  final _contacts = ContactManager().contacts.where((c) => !c.isGroup).toList();

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('New Group',
          style: GoogleFonts.inter(
              color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group name
            TextField(
              controller: _nameController,
              style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Group name',
                hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary),
                prefixIcon: Icon(Icons.group_rounded, color: AppTheme.textSecondary, size: 18),
                filled: true,
                fillColor: AppTheme.surfaceVariant,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            Text('Select members (min 2)',
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (_contacts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('No contacts yet. Add contacts first.',
                    style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
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
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                        child: Row(children: [
                          _buildAvatar(c.name, 38),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(c.name,
                                  style: GoogleFonts.inter(
                                      color: AppTheme.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              Text(c.provider,
                                  style: GoogleFonts.inter(
                                      color: AppTheme.textSecondary, fontSize: 12)),
                            ]),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 22, height: 22,
                            decoration: BoxDecoration(
                              color: selected ? AppTheme.primary : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected ? AppTheme.primary : AppTheme.textSecondary.withValues(alpha: 0.4),
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _nameController.text.trim().isNotEmpty && _selectedIds.length >= 2
              ? _submit
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: Text('Create', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
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
