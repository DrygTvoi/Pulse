import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme_manager.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';
import 'package:provider/provider.dart';

// ── Preset definition ────────────────────────────────────────────────────────
class _Preset {
  final String name;
  final Color primary;
  final Color accent;
  final Color bg;
  final Color surf;
  final Color surfVar;
  final Color textPrimary;
  final Color textSecondary;
  final ThemeMode mode;
  final double radius;
  final String font;

  const _Preset({
    required this.name,
    required this.primary,
    required this.accent,
    required this.bg,
    required this.surf,
    required this.surfVar,
    required this.textPrimary,
    required this.textSecondary,
    required this.mode,
    required this.radius,
    required this.font,
  });
}

const _presets = [
  // Default WhatsApp-style dark green
  _Preset(
    name: 'Pulse',
    primary:       Color(0xFF00A884),
    accent:        Color(0xFF53BDEB),
    bg:            Color(0xFF111B21),
    surf:          Color(0xFF202C33),
    surfVar:       Color(0xFF2A3942),
    textPrimary:   Color(0xFFE9EDEF),
    textSecondary: Color(0xFF8696A0),
    mode:   ThemeMode.dark,
    radius: 12,
    font:   'Inter',
  ),
  // Telegram-style dark blue
  _Preset(
    name: 'Telegram',
    primary:       Color(0xFF5288C1),
    accent:        Color(0xFF64B5F6),
    bg:            Color(0xFF17212B),
    surf:          Color(0xFF232E3C),
    surfVar:       Color(0xFF2B3C4E),
    textPrimary:   Color(0xFFEEF0F1),
    textSecondary: Color(0xFF7A8E9B),
    mode:   ThemeMode.dark,
    radius: 14,
    font:   'Inter',
  ),
  // Signal-style minimal dark
  _Preset(
    name: 'Signal',
    primary:       Color(0xFF3A76F0),
    accent:        Color(0xFF5E97F6),
    bg:            Color(0xFF1B1B1B),
    surf:          Color(0xFF262626),
    surfVar:       Color(0xFF303030),
    textPrimary:   Color(0xFFEFEFEF),
    textSecondary: Color(0xFF888888),
    mode:   ThemeMode.dark,
    radius: 18,
    font:   'Roboto',
  ),
  // AMOLED pure black + purple
  _Preset(
    name: 'Midnight',
    primary:       Color(0xFFBB86FC),
    accent:        Color(0xFF03DAC6),
    bg:            Color(0xFF000000),
    surf:          Color(0xFF121212),
    surfVar:       Color(0xFF1E1E1E),
    textPrimary:   Color(0xFFFFFFFF),
    textSecondary: Color(0xFF9E9E9E),
    mode:   ThemeMode.dark,
    radius: 8,
    font:   'Roboto',
  ),
  // Light mode — clean white
  _Preset(
    name: 'Light',
    primary:       Color(0xFF00A884),
    accent:        Color(0xFF027EB5),
    bg:            Color(0xFFF0F2F5),
    surf:          Color(0xFFFFFFFF),
    surfVar:       Color(0xFFE9ECEF),
    textPrimary:   Color(0xFF111B21),
    textSecondary: Color(0xFF667781),
    mode:   ThemeMode.light,
    radius: 12,
    font:   'Inter',
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────
class DynamicThemeScreen extends StatefulWidget {
  const DynamicThemeScreen({super.key});

  @override
  State<DynamicThemeScreen> createState() => _DynamicThemeScreenState();
}

class _DynamicThemeScreenState extends State<DynamicThemeScreen> {
  static const _fonts = ['Inter'];

  static const _paletteColors = [
    Color(0xFF00A884), Color(0xFF5288C1), Color(0xFF3A76F0),
    Color(0xFFBB86FC), Color(0xFFFF6B6B), Color(0xFFFF9800),
    Color(0xFF4CAF50), Color(0xFF00BCD4), Color(0xFFE91E63),
    Color(0xFF9C27B0), Color(0xFFFF5722), Color(0xFF607D8B),
  ];

  void _applyPreset(_Preset p) {
    ThemeNotifier.instance.applyPreset(
      primary: p.primary, accent: p.accent,
      bg: p.bg, surf: p.surf, surfVar: p.surfVar,
      textPrimary: p.textPrimary, textSecondary: p.textSecondary,
      mode: p.mode, radius: p.radius, font: p.font,
    );
  }

  bool _isActivePreset(_Preset p, ThemeNotifier t) =>
      t.primary.toARGB32() == p.primary.toARGB32() &&
      t.background.toARGB32() == p.bg.toARGB32();

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeNotifier>();
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.themeEngineTitle,
            style: GoogleFonts.inter(color: theme.textPrimary, fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Presets ────────────────────────────────────────────────────
          _label('Presets', theme),
          const SizedBox(height: 12),
          _buildPresetGrid(theme),

          const SizedBox(height: 28),
          Divider(color: AppTheme.surfaceVariant, height: 1),
          const SizedBox(height: 24),

          // ── Primary colour ─────────────────────────────────────────────
          _label('Primary Color', theme),
          const SizedBox(height: 12),
          _buildColorGrid(theme.primary,
              (c) => ThemeNotifier.instance.updateColors(primary: c)),

          const SizedBox(height: 24),
          Divider(color: AppTheme.surfaceVariant, height: 1),
          const SizedBox(height: 24),

          // ── Border radius ──────────────────────────────────────────────
          _label('Border Radius', theme),
          const SizedBox(height: 4),
          _buildRadiusSlider(theme),

          const SizedBox(height: 24),
          Divider(color: AppTheme.surfaceVariant, height: 1),
          const SizedBox(height: 24),

          // ── Typography ─────────────────────────────────────────────────
          _label('Font', theme),
          const SizedBox(height: 12),
          _buildFontSelector(theme),

          const SizedBox(height: 24),
          Divider(color: AppTheme.surfaceVariant, height: 1),
          const SizedBox(height: 24),

          // ── Dark / Light ───────────────────────────────────────────────
          _label('Appearance', theme),
          const SizedBox(height: 12),
          _buildModeToggle(theme),

          const SizedBox(height: 24),
          Divider(color: AppTheme.surfaceVariant, height: 1),
          const SizedBox(height: 24),

          // ── UI Style ───────────────────────────────────────────────────
          _label('UI Style', theme),
          const SizedBox(height: 4),
          Text('Controls how dialogs, switches and indicators look.',
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 12),
          _buildPlatformToggle(theme),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Preset grid ───────────────────────────────────────────────────────────
  Widget _buildPresetGrid(ThemeNotifier theme) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _presets.map((p) {
        final active = _isActivePreset(p, theme);
        return GestureDetector(
          onTap: () => _applyPreset(p),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: active ? p.primary.withValues(alpha: 0.18) : AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active ? p.primary : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mini colour preview
                _miniPalette(p),
                const SizedBox(width: 10),
                Text(p.name,
                    style: GoogleFonts.inter(
                        color: active ? p.primary : AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                if (active) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.check_rounded, size: 14, color: p.primary),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _miniPalette(_Preset p) {
    return SizedBox(
      width: 30,
      height: 16,
      child: Stack(children: [
        Positioned(left: 0, child: _dot(p.bg, 16)),
        Positioned(left: 7, child: _dot(p.surf, 16)),
        Positioned(left: 14, child: _dot(p.primary, 16)),
      ]),
    );
  }

  Widget _dot(Color c, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: c,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 0.5),
        ),
      );

  // ── Colour grid ───────────────────────────────────────────────────────────
  Widget _buildColorGrid(Color current, ValueChanged<Color> onSelect) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _paletteColors.map((c) {
        final selected = c.toARGB32() == current.toARGB32();
        return GestureDetector(
          onTap: () => onSelect(c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: selected ? Border.all(color: Colors.white, width: 2.5) : null,
              boxShadow: selected
                  ? [BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 8)]
                  : null,
            ),
            child: selected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                : null,
          ),
        );
      }).toList(),
    );
  }

  // ── Radius slider ─────────────────────────────────────────────────────────
  Widget _buildRadiusSlider(ThemeNotifier theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            onChanged: (v) => ThemeNotifier.instance.updateRadius(v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sharp', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
              Text('${theme.borderRadius.round()}px',
                  style: GoogleFonts.inter(color: theme.primary, fontSize: 11, fontWeight: FontWeight.w600)),
              Text('Round', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Font selector ─────────────────────────────────────────────────────────
  Widget _buildFontSelector(ThemeNotifier theme) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: _fonts.map((f) {
          final selected = theme.fontFamily == f;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => ThemeNotifier.instance.updateFont(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: selected ? theme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(17),
                ),
                alignment: Alignment.center,
                child: Text(f,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: selected ? Colors.white : AppTheme.textSecondary)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Dark / Light toggle ───────────────────────────────────────────────────
  Widget _buildModeToggle(ThemeNotifier theme) {
    final modes = [
      (ThemeMode.dark,   Icons.dark_mode_rounded,   'Dark'),
      (ThemeMode.light,  Icons.light_mode_rounded,  'Light'),
      (ThemeMode.system, Icons.brightness_auto_rounded, 'Auto'),
    ];
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: modes.map((m) {
          final selected = theme.themeMode == m.$1;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => ThemeNotifier.instance.setThemeMode(m.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: selected ? theme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(m.$2,
                        size: 15,
                        color: selected ? Colors.white : AppTheme.textSecondary),
                    const SizedBox(width: 5),
                    Text(m.$3,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: selected ? Colors.white : AppTheme.textSecondary)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Platform (UI style) toggle ────────────────────────────────────────────
  Widget _buildPlatformToggle(ThemeNotifier theme) {
    final options = [
      (null,                   Icons.android_rounded,        'Auto'),
      (TargetPlatform.android, Icons.smartphone_rounded,     'Android'),
      (TargetPlatform.iOS,     Icons.phone_iphone_rounded,   'iOS'),
    ];
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: options.map((o) {
          final selected = theme.customPlatform == o.$1;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => ThemeNotifier.instance.updatePlatform(o.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: selected ? theme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(o.$2,
                        size: 15,
                        color: selected ? Colors.white : AppTheme.textSecondary),
                    const SizedBox(width: 5),
                    Text(o.$3,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: selected ? Colors.white : AppTheme.textSecondary)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _label(String text, ThemeNotifier theme) => Text(text,
      style: GoogleFonts.inter(
          color: theme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600));
}
