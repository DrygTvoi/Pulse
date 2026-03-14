import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme_manager.dart';
import '../theme/app_theme.dart';

/// Reusable theme picker — used on the onboarding screen and in Settings.
/// Shows a Light / Dark / System mode selector + accent color swatches.
class ThemePickerWidget extends StatefulWidget {
  const ThemePickerWidget({super.key});

  @override
  State<ThemePickerWidget> createState() => _ThemePickerWidgetState();
}

class _ThemePickerWidgetState extends State<ThemePickerWidget> {
  static const _accents = [
    Color(0xFF00A884), // WhatsApp green (default)
    Color(0xFF6366F1), // Indigo
    Color(0xFFEC4899), // Pink
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Emerald
    Color(0xFF3B82F6), // Blue
    Color(0xFFA855F7), // Purple
    Color(0xFFEF4444), // Red
  ];

  @override
  Widget build(BuildContext context) {
    final notifier = ThemeNotifier.instance;
    final mode = notifier.themeMode;
    final accent = notifier.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Mode selector ────────────────────────────────────────────────────
        Text('Appearance',
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(children: [
          _ModeCard(
            icon: Icons.light_mode_rounded,
            label: 'Light',
            selected: mode == ThemeMode.light,
            onTap: () => ThemeNotifier.instance.setThemeMode(ThemeMode.light),
          ),
          const SizedBox(width: 10),
          _ModeCard(
            icon: Icons.dark_mode_rounded,
            label: 'Dark',
            selected: mode == ThemeMode.dark,
            onTap: () => ThemeNotifier.instance.setThemeMode(ThemeMode.dark),
          ),
          const SizedBox(width: 10),
          _ModeCard(
            icon: Icons.brightness_auto_rounded,
            label: 'System',
            selected: mode == ThemeMode.system,
            onTap: () => ThemeNotifier.instance.setThemeMode(ThemeMode.system),
          ),
        ]),

        const SizedBox(height: 20),

        // ── Accent color ─────────────────────────────────────────────────────
        Text('Accent Color',
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _accents.map((c) {
            final selected = c.toARGB32() == accent.toARGB32();
            return GestureDetector(
              onTap: () => ThemeNotifier.instance.updateColors(primary: c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? Colors.white : Colors.transparent,
                    width: 2.5,
                  ),
                  boxShadow: selected
                      ? [BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 8)]
                      : null,
                ),
                child: selected
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primary.withValues(alpha: 0.15)
                : AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppTheme.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon,
                color: selected ? AppTheme.primary : AppTheme.textSecondary,
                size: 24),
            const SizedBox(height: 6),
            Text(label,
                style: GoogleFonts.inter(
                    color: selected ? AppTheme.primary : AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
          ]),
        ),
      ),
    );
  }
}
