import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';

/// Reusable theme picker — used on the onboarding screen and in Settings.
/// Shows a Light / Dark / System mode selector + accent color swatches.
class ThemePickerWidget extends StatelessWidget {
  const ThemePickerWidget({super.key});

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
    final notifier = context.watch<ThemeNotifier>();
    final mode = notifier.themeMode;
    final accent = notifier.primary;
    final l = context.l10n;

    final modes = [
      (ThemeMode.light, Icons.light_mode_rounded, l.themeModeLight),
      (ThemeMode.dark, Icons.dark_mode_rounded, l.themeModeDark),
      (ThemeMode.system, Icons.brightness_auto_rounded, l.themeModeSystem),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Mode selector ──────────────────────────────────────────────
        Text(l.themePickerAppearance,
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        _SegmentedPill(
          items: modes.map((m) => (m.$1, m.$2, m.$3)).toList(),
          selected: mode,
          onTap: (m) => ThemeNotifier.instance.setThemeMode(m),
        ),

        const SizedBox(height: 20),

        // ── Accent color ───────────────────────────────────────────────
        Text(l.themePickerAccentColor,
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
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                ),
                child: selected
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 16)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Telegram-style segmented pill control.
class _SegmentedPill extends StatelessWidget {
  final List<(ThemeMode, IconData, String)> items;
  final ThemeMode selected;
  final ValueChanged<ThemeMode> onTap;

  const _SegmentedPill({
    required this.items,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(22),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / items.length;
          final selectedIndex =
              items.indexWhere((item) => item.$1 == selected);

          return Stack(
            children: [
              // Sliding indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                left: selectedIndex * segmentWidth + 3,
                top: 3,
                bottom: 3,
                width: segmentWidth - 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(19),
                  ),
                ),
              ),
              // Segments
              Row(
                children: items.map((item) {
                  final isSelected = item.$1 == selected;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTap(item.$1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(item.$2,
                              size: 16,
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textSecondary),
                          const SizedBox(width: 5),
                          Text(item.$3,
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
