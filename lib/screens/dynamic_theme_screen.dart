import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme_manager.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import 'package:provider/provider.dart';

class DynamicThemeScreen extends StatefulWidget {
  const DynamicThemeScreen({super.key});

  @override
  State<DynamicThemeScreen> createState() => _DynamicThemeScreenState();
}

class _DynamicThemeScreenState extends State<DynamicThemeScreen> {
  final List<String> _fonts = ['Outfit', 'Inter', 'Roboto', 'Fira Code'];

  static const _presets = [
    ('Cyberpunk', Color(0xFF00FF9D), Color(0xFFFF3864), 0.0, 'Fira Code'),
    ('Minimalist', Color(0xFF6366F1), Color(0xFFF43F5E), 16.0, 'Outfit'),
    ('Midnight', Color(0xFF818CF8), Color(0xFFC084FC), 24.0, 'Inter'),
    ('Neon Pink', Color(0xFFFF007F), Color(0xFF00E5FF), 12.0, 'Outfit'),
  ];

  static const _paletteColors = [
    Colors.redAccent, Colors.pinkAccent, Colors.purpleAccent,
    Colors.deepPurpleAccent, Colors.indigoAccent, Colors.blueAccent,
    Colors.cyanAccent, Colors.tealAccent, Colors.greenAccent,
    Colors.orangeAccent, Colors.deepOrangeAccent, Colors.amberAccent,
  ];

  void _applyPreset(int index) {
    final p = _presets[index];
    ThemeNotifier.instance.applyPreset(
      primary: p.$2,
      accent: p.$3,
      radius: p.$4,
      font: p.$5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeNotifier>();
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.themeEngineTitle, style: GoogleFonts.inter(
            color: theme.textPrimary, fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Presets ────────────────────────────────────────────────────
          _sectionLabel('Presets', theme),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(_presets.length, (i) {
              final p = _presets[i];
              final isActive = theme.primary.toARGB32() == p.$2.toARGB32();
              return GestureDetector(
                onTap: () => _applyPreset(i),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive
                        ? theme.primary.withValues(alpha: 0.15)
                        : AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: p.$2,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(p.$1,
                          style: GoogleFonts.inter(
                              color: isActive
                                  ? theme.primary
                                  : AppTheme.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                      if (isActive) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.check_rounded,
                            size: 14, color: theme.primary),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 28),
          Divider(color: AppTheme.surfaceVariant, height: 1),
          const SizedBox(height: 24),

          // ── Primary color ─────────────────────────────────────────────
          _sectionLabel('Primary Color', theme),
          const SizedBox(height: 12),
          _buildColorGrid(theme.primary, (c) =>
              ThemeNotifier.instance.updateColors(primary: c)),

          const SizedBox(height: 24),

          // ── Accent color ──────────────────────────────────────────────
          _sectionLabel('Accent Color', theme),
          const SizedBox(height: 12),
          _buildColorGrid(theme.accent, (c) =>
              ThemeNotifier.instance.updateColors(accent: c)),

          const SizedBox(height: 24),

          // ── Border radius ─────────────────────────────────────────────
          _sectionLabel('Border Radius', theme),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: theme.primary,
              inactiveTrackColor: AppTheme.surfaceVariant,
              thumbColor: theme.primary,
              overlayColor: theme.primary.withValues(alpha: 0.12),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: theme.borderRadius,
              min: 0,
              max: 32,
              onChanged: (val) => ThemeNotifier.instance.updateRadius(val),
            ),
          ),

          const SizedBox(height: 20),

          // ── Typography ────────────────────────────────────────────────
          _sectionLabel('Typography', theme),
          const SizedBox(height: 12),
          _buildFontSelector(theme),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, ThemeNotifier theme) {
    return Text(text,
        style: GoogleFonts.inter(
            color: theme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600));
  }

  Widget _buildColorGrid(Color current, ValueChanged<Color> onSelect) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _paletteColors.map((c) {
        final isSelected = c.toARGB32() == current.toARGB32();
        return GestureDetector(
          onTap: () => onSelect(c),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 14)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFontSelector(ThemeNotifier theme) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Row(
        children: _fonts.map((f) {
          final isSelected = theme.fontFamily == f;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => ThemeNotifier.instance.updateFont(f),
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isSelected ? theme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(f,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : AppTheme.textSecondary)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
