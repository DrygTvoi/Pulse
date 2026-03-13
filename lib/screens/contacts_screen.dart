import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/contact.dart';
import 'add_contact_dialog.dart';
import 'create_group_dialog.dart';
import 'chat_screen.dart';
import '../widgets/contact_tile.dart';

class ContactsScreen extends StatefulWidget {
  /// When true, immediately opens the Create Group dialog on launch.
  final bool createGroup;

  const ContactsScreen({super.key, this.createGroup = false});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterProvider = 'All';

  static const _providers = ['All', 'Firebase', 'Nostr'];

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.createGroup) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showCreateGroupDialog());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await ContactManager().loadContacts();
    if (mounted) setState(() {});
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AddContactDialog(
        onAdd: (newContact) async {
          await ContactManager().addContact(newContact);
          if (mounted) _loadData();
        },
      ),
    );
  }

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateGroupDialog(
        onCreate: (group) async {
          await ContactManager().addContact(group);
          if (!context.mounted) return;
          _loadData();
          // Open the group chat immediately after creation
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => ChatScreen(contact: group),
          ));
        },
      ),
    );
  }

  List<Contact> get _filtered {
    final contacts = ContactManager().contacts;
    return contacts.where((c) {
      final matchesProvider = _filterProvider == 'All' || c.provider == _filterProvider;
      final matchesSearch = _searchQuery.isEmpty ||
          c.name.toLowerCase().contains(_searchQuery) ||
          c.databaseId.toLowerCase().contains(_searchQuery);
      return matchesProvider && matchesSearch;
    }).toList();
  }

  void _openChat(Contact contact) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ChatScreen(contact: contact),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final contacts = ContactManager().contacts;
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Text('New chat',
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add_rounded, color: AppTheme.primary),
            onPressed: _showAddDialog,
            tooltip: 'Add contact',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textSecondary, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close_rounded, color: AppTheme.textSecondary, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.surfaceVariant,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // ── Provider filter chips ───────────────────────────────────────
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _providers.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final p = _providers[i];
                final selected = _filterProvider == p;
                return _FilterChip(
                  label: p,
                  selected: selected,
                  onTap: () => setState(() => _filterProvider = p),
                );
              },
            ),
          ),
          const SizedBox(height: 4),

          // ── List ────────────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                // "New group" always at the top
                _ActionTile(
                  icon: Icons.group_add_rounded,
                  color: AppTheme.primary,
                  label: 'New group',
                  onTap: _showCreateGroupDialog,
                ),

                if (contacts.isEmpty)
                  _buildEmpty()
                else if (filtered.isEmpty)
                  _buildNoMatches()
                else ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                    child: Text(
                      '${filtered.length} contact${filtered.length == 1 ? '' : 's'}',
                      style: GoogleFonts.inter(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  ...filtered.map((c) => Dismissible(
                    key: Key(c.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.redAccent.withValues(alpha: 0.15),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: Colors.redAccent, size: 24),
                    ),
                    confirmDismiss: (_) => showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: AppTheme.surface,
                        title: Text('Remove contact',
                            style: GoogleFonts.inter(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w700)),
                        content: Text('Remove ${c.name}?',
                            style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Cancel',
                                style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('Remove',
                                style: GoogleFonts.inter(
                                    color: Colors.redAccent, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    onDismissed: (_) async {
                      await ContactManager().removeContact(c.id);
                      if (mounted) _loadData();
                    },
                    child: ContactTile(
                      contact: c,
                      onTap: () => _openChat(c),
                    ),
                  )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.people_outline_rounded,
              size: 48, color: AppTheme.textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 14),
          Text('No contacts yet',
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text("Tap + to add someone's address",
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondary.withValues(alpha: 0.7), fontSize: 13)),
        ]),
      ),
    );
  }

  Widget _buildNoMatches() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.search_off_rounded,
              size: 36, color: AppTheme.textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text('No contacts match',
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14)),
        ]),
      ),
    );
  }
}

/// A tappable action row shown at the top of the list (New group, etc.)
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  const _ActionTile(
      {required this.icon, required this.color, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppTheme.primary.withValues(alpha: 0.07),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Text(label,
                style: GoogleFonts.inter(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.primary.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: selected ? Colors.white : AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
