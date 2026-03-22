import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/ice_server_config.dart';
import '../l10n/l10n_ext.dart';

/// Extracted TURN server configuration section from SettingsScreen.
/// Displays community TURN preset checkboxes and custom TURN input fields.
class TurnConfigSection extends StatelessWidget {
  const TurnConfigSection({
    super.key,
    required this.enabledPresets,
    required this.turnUrlController,
    required this.turnUsernameController,
    required this.turnPasswordController,
    required this.onPresetsChanged,
  });

  final List<String> enabledPresets;
  final TextEditingController turnUrlController;
  final TextEditingController turnUsernameController;
  final TextEditingController turnPasswordController;
  final ValueChanged<List<String>> onPresetsChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTurnInfo(context),
        const SizedBox(height: 14),
        _sectionLabel(l.turnCommunityServers),
        const SizedBox(height: 10),
        _buildTurnPresets(context),
        const SizedBox(height: 20),
        _sectionLabel(l.turnCustomServer),
        const SizedBox(height: 10),
        _buildCustomTurn(context),
      ],
    );
  }

  Widget _buildTurnInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_rounded, size: 15, color: AppTheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.turnInfoDescription,
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTurnPresets(BuildContext context) {
    final l = context.l10n;
    return Column(
      children: kTurnPresets.map((preset) {
        final id = preset['id'] as String;
        final name = preset['name'] as String;
        final host = preset['host'] as String;
        final enabled = enabledPresets.contains(id);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () {
              final updated = List<String>.from(enabledPresets);
              if (enabled) {
                updated.remove(id);
              } else {
                updated.add(id);
              }
              onPresetsChanged(updated);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: enabled
                    ? AppTheme.primary.withValues(alpha: 0.08)
                    : AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: enabled ? AppTheme.primary.withValues(alpha: 0.4) : AppTheme.surfaceVariant,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    enabled ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    size: 18,
                    color: enabled ? AppTheme.primary : AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: GoogleFonts.inter(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                        Text(host,
                            style: GoogleFonts.jetBrainsMono(
                                color: AppTheme.textSecondary, fontSize: 10)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2ECC71).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(l.turnFreeLabel,
                        style: GoogleFonts.inter(
                            color: const Color(0xFF2ECC71),
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomTurn(BuildContext context) {
    final l = context.l10n;
    return Column(
      children: [
        _field(
          controller: turnUrlController,
          hint: l.turnServerUrlHint,
          label: l.turnServerUrlLabel,
          icon: Icons.dns_rounded,
        ),
        const SizedBox(height: 10),
        _field(
          controller: turnUsernameController,
          hint: l.turnOptionalHint,
          label: l.turnUsernameLabel,
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 10),
        _field(
          controller: turnPasswordController,
          hint: l.turnOptionalHint,
          label: l.turnPasswordLabel,
          icon: Icons.password_rounded,
          obscure: true,
        ),
        const SizedBox(height: 8),
        Row(children: [
          Icon(Icons.info_outline_rounded, size: 13, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              l.turnCustomInfo,
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11),
            ),
          ),
        ]),
      ],
    );
  }

  // ── Shared helpers ──────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Text(text.toUpperCase(),
        style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11,
            fontWeight: FontWeight.w700, letterSpacing: 0.8));
  }

  Widget _field({required TextEditingController controller, required String hint,
      required String label, required IconData icon, bool obscure = false}) {
    return TextField(
      controller: controller,
      style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        labelStyle: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 18),
        filled: true,
        fillColor: AppTheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
