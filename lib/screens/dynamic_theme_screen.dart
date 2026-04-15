import 'dart:async';
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
  final Color outgoingBubble;
  final Color incomingBubble;
  final ThemeMode mode;
  final double radius;

  const _Preset({
    required this.name,
    required this.primary,
    required this.accent,
    required this.bg,
    required this.surf,
    required this.surfVar,
    required this.textPrimary,
    required this.textSecondary,
    required this.outgoingBubble,
    required this.incomingBubble,
    required this.mode,
    required this.radius,
  });
}

const _presets = [
  _Preset(
    name: 'Ocean',
    primary:       Color(0xFF5288C1),
    accent:        Color(0xFF64B5F6),
    bg:            Color(0xFF17212B),
    surf:          Color(0xFF232E3C),
    surfVar:       Color(0xFF2B3C4E),
    textPrimary:   Color(0xFFEEF0F1),
    textSecondary: Color(0xFF7A8E9B),
    outgoingBubble: Color(0xFF2B5278),
    incomingBubble: Color(0xFF182533),
    mode:   ThemeMode.dark,
    radius: 14,
  ),
  _Preset(
    name: 'Jade',
    primary:       Color(0xFF00A884),
    accent:        Color(0xFF53BDEB),
    bg:            Color(0xFF111B21),
    surf:          Color(0xFF202C33),
    surfVar:       Color(0xFF2A3942),
    textPrimary:   Color(0xFFE9EDEF),
    textSecondary: Color(0xFF8696A0),
    outgoingBubble: Color(0xFF005C4B),
    incomingBubble: Color(0xFF2A3942),
    mode:   ThemeMode.dark,
    radius: 12,
  ),
  _Preset(
    name: 'Cobalt',
    primary:       Color(0xFF3A76F0),
    accent:        Color(0xFF5E97F6),
    bg:            Color(0xFF1B1B1B),
    surf:          Color(0xFF262626),
    surfVar:       Color(0xFF303030),
    textPrimary:   Color(0xFFEFEFEF),
    textSecondary: Color(0xFF888888),
    outgoingBubble: Color(0xFF2C6BED),
    incomingBubble: Color(0xFF303030),
    mode:   ThemeMode.dark,
    radius: 18,
  ),
  _Preset(
    name: 'Midnight',
    primary:       Color(0xFFBB86FC),
    accent:        Color(0xFF03DAC6),
    bg:            Color(0xFF000000),
    surf:          Color(0xFF121212),
    surfVar:       Color(0xFF1E1E1E),
    textPrimary:   Color(0xFFFFFFFF),
    textSecondary: Color(0xFF9E9E9E),
    outgoingBubble: Color(0xFF3700B3),
    incomingBubble: Color(0xFF1E1E1E),
    mode:   ThemeMode.dark,
    radius: 8,
  ),
  _Preset(
    name: 'Light',
    primary:       Color(0xFF00A884),
    accent:        Color(0xFF027EB5),
    bg:            Color(0xFFF0F2F5),
    surf:          Color(0xFFFFFFFF),
    surfVar:       Color(0xFFE9ECEF),
    textPrimary:   Color(0xFF111B21),
    textSecondary: Color(0xFF667781),
    outgoingBubble: Color(0xFFD9FDD3),
    incomingBubble: Color(0xFFFFFFFF),
    mode:   ThemeMode.light,
    radius: 12,
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────
class DynamicThemeScreen extends StatefulWidget {
  const DynamicThemeScreen({super.key});

  @override
  State<DynamicThemeScreen> createState() => _DynamicThemeScreenState();
}

class _DynamicThemeScreenState extends State<DynamicThemeScreen> {
  Timer? _radiusDebounce;
  late double _localRadius;
  bool _radiusDragging = false;

  // Track which color row is expanded
  String? _expandedColorKey;

  @override
  void initState() {
    super.initState();
    _localRadius = ThemeNotifier.instance.borderRadius;
  }

  @override
  void dispose() {
    _radiusDebounce?.cancel();
    super.dispose();
  }

  void _applyPreset(_Preset p) {
    ThemeNotifier.instance.applyPreset(
      primary: p.primary, accent: p.accent,
      bg: p.bg, surf: p.surf, surfVar: p.surfVar,
      textPrimary: p.textPrimary, textSecondary: p.textSecondary,
      outgoingBubble: p.outgoingBubble, incomingBubble: p.incomingBubble,
      mode: p.mode, radius: p.radius,
    );
    setState(() => _localRadius = p.radius);
  }

  bool _isActivePreset(_Preset p, ThemeNotifier t) =>
      t.primary.toARGB32() == p.primary.toARGB32() &&
      t.background.toARGB32() == p.bg.toARGB32();

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeNotifier>();
    // Only sync from theme when not actively dragging
    if (!_radiusDragging) _localRadius = theme.borderRadius;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.themeEngineTitle,
            style: GoogleFonts.inter(color: theme.textPrimary, fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Presets ────────────────────────────────────────────────────
          _sectionLabel(context.l10n.themeDynamicPresets, theme),
          const SizedBox(height: 12),
          _buildPresetChips(theme),

          const SizedBox(height: 28),
          Divider(color: AppTheme.surfaceVariant, height: 1),
          const SizedBox(height: 24),

          // ── Mode ───────────────────────────────────────────────────────
          _sectionLabel(context.l10n.themeDynamicAppearance, theme),
          const SizedBox(height: 12),
          _buildModeToggle(theme),

          const SizedBox(height: 28),
          Divider(color: AppTheme.surfaceVariant, height: 1),
          const SizedBox(height: 24),

          // ── Colors ─────────────────────────────────────────────────────
          _sectionLabel(context.l10n.themeColors, theme),
          const SizedBox(height: 12),
          _ColorRow(
            label: context.l10n.themePrimaryAccent,
            color: theme.primary,
            expanded: _expandedColorKey == 'primary',
            onToggle: () => _toggleExpand('primary'),
            onChanged: (c) => ThemeNotifier.instance.updateColors(primary: c),
          ),
          _ColorRow(
            label: context.l10n.themeSecondaryAccent,
            color: theme.accent,
            expanded: _expandedColorKey == 'accent',
            onToggle: () => _toggleExpand('accent'),
            onChanged: (c) => ThemeNotifier.instance.updateColors(accent: c),
          ),
          _ColorRow(
            label: context.l10n.themeBackground,
            color: theme.background,
            expanded: _expandedColorKey == 'bg',
            onToggle: () => _toggleExpand('bg'),
            onChanged: (c) => ThemeNotifier.instance.updateBackground(c),
          ),
          _ColorRow(
            label: context.l10n.themeSurface,
            color: theme.surface,
            expanded: _expandedColorKey == 'surf',
            onToggle: () => _toggleExpand('surf'),
            onChanged: (c) => ThemeNotifier.instance.updateSurface(c),
          ),

          const SizedBox(height: 24),
          Divider(color: AppTheme.surfaceVariant, height: 1),
          const SizedBox(height: 24),

          // ── Chat Bubbles ───────────────────────────────────────────────
          _sectionLabel(context.l10n.themeChatBubbles, theme),
          const SizedBox(height: 12),
          _ColorRow(
            label: context.l10n.themeOutgoingMessage,
            color: theme.outgoingBubble,
            expanded: _expandedColorKey == 'bubbleOut',
            onToggle: () => _toggleExpand('bubbleOut'),
            onChanged: (c) => ThemeNotifier.instance.updateBubbleColors(outgoing: c),
          ),
          _ColorRow(
            label: context.l10n.themeIncomingMessage,
            color: theme.incomingBubble,
            expanded: _expandedColorKey == 'bubbleIn',
            onToggle: () => _toggleExpand('bubbleIn'),
            onChanged: (c) => ThemeNotifier.instance.updateBubbleColors(incoming: c),
          ),

          const SizedBox(height: 24),
          Divider(color: AppTheme.surfaceVariant, height: 1),
          const SizedBox(height: 24),

          // ── Shape ──────────────────────────────────────────────────────
          _sectionLabel(context.l10n.themeShape, theme),
          const SizedBox(height: 4),
          _buildRadiusSlider(theme),

          const SizedBox(height: 32),

          // ── Reset ──────────────────────────────────────────────────────
          Center(
            child: TextButton.icon(
              onPressed: () {
                ThemeNotifier.instance.resetCustom();
                setState(() {
                  _localRadius = 12.0;
                  _expandedColorKey = null;
                });
              },
              icon: Icon(Icons.restart_alt_rounded, size: 18, color: AppTheme.textSecondary),
              label: Text(context.l10n.themeResetToDefaults,
                  style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _toggleExpand(String key) {
    setState(() {
      _expandedColorKey = _expandedColorKey == key ? null : key;
    });
  }

  // ── Preset chips ──────────────────────────────────────────────────────────
  Widget _buildPresetChips(ThemeNotifier theme) {
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

  // ── Mode toggle ────────────────────────────────────────────────────────────
  Widget _buildModeToggle(ThemeNotifier theme) {
    final l = context.l10n;
    final modes = [
      (ThemeMode.dark,   Icons.dark_mode_rounded,   l.themeDynamicModeDark),
      (ThemeMode.light,  Icons.light_mode_rounded,   l.themeDynamicModeLight),
      (ThemeMode.system, Icons.brightness_auto_rounded, l.themeDynamicModeAuto),
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

  // ── Radius slider (debounced) ──────────────────────────────────────────────
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
            value: _localRadius,
            min: 0,
            max: 32,
            onChangeStart: (_) => _radiusDragging = true,
            onChangeEnd: (_) {
              _radiusDragging = false;
              _radiusDebounce?.cancel();
              ThemeNotifier.instance.updateRadius(_localRadius);
            },
            onChanged: (v) {
              setState(() => _localRadius = v);
              _radiusDebounce?.cancel();
              _radiusDebounce = Timer(const Duration(milliseconds: 120), () {
                ThemeNotifier.instance.updateRadius(v);
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.l10n.themeDynamicSharp,
                  style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
              Text('${_localRadius.round()}px',
                  style: GoogleFonts.inter(color: theme.primary, fontSize: 11, fontWeight: FontWeight.w600)),
              Text(context.l10n.themeDynamicRound,
                  style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text, ThemeNotifier theme) => Text(text,
      style: GoogleFonts.inter(
          color: theme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600));
}

// ── Color row with expandable HSL picker ─────────────────────────────────────
class _ColorRow extends StatelessWidget {
  final String label;
  final Color color;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<Color> onChanged;

  const _ColorRow({
    required this.label,
    required this.color,
    required this.expanded,
    required this.onToggle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hex = '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(label,
                      style: GoogleFonts.inter(
                          color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w400)),
                ),
                Text(hex,
                    style: GoogleFonts.jetBrainsMono(
                        color: AppTheme.textSecondary, fontSize: 11)),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.expand_more_rounded, size: 20, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: expanded
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _HslColorPicker(
                    color: color,
                    onChanged: onChanged,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ── HSL color picker (debounced output) ──────────────────────────────────────
class _HslColorPicker extends StatefulWidget {
  final Color color;
  final ValueChanged<Color> onChanged;

  const _HslColorPicker({required this.color, required this.onChanged});

  @override
  State<_HslColorPicker> createState() => _HslColorPickerState();
}

class _HslColorPickerState extends State<_HslColorPicker> {
  late double _hue;
  late double _saturation;
  late double _lightness;
  Timer? _debounce;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _syncFromColor(widget.color);
  }

  @override
  void didUpdateWidget(_HslColorPicker old) {
    super.didUpdateWidget(old);
    // Only sync from parent when not actively dragging
    if (!_dragging && old.color != widget.color) {
      _syncFromColor(widget.color);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _syncFromColor(Color c) {
    final hsl = HSLColor.fromColor(c);
    _hue = hsl.hue;
    _saturation = hsl.saturation;
    _lightness = hsl.lightness;
  }

  void _emitDebounced() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 60), () {
      widget.onChanged(HSLColor.fromAHSL(1.0, _hue, _saturation, _lightness).toColor());
    });
  }

  void _emitFinal() {
    _debounce?.cancel();
    widget.onChanged(HSLColor.fromAHSL(1.0, _hue, _saturation, _lightness).toColor());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _sliderRow(
            label: 'H',
            value: _hue,
            min: 0,
            max: 359,
            gradient: _hueGradient(),
            onChanged: (v) { setState(() => _hue = v); _emitDebounced(); },
            onDragStart: () => _dragging = true,
            onDragEnd: () { _dragging = false; _emitFinal(); },
          ),
          const SizedBox(height: 10),
          _sliderRow(
            label: 'S',
            value: _saturation,
            min: 0,
            max: 1,
            gradient: LinearGradient(colors: [
              HSLColor.fromAHSL(1, _hue, 0, _lightness).toColor(),
              HSLColor.fromAHSL(1, _hue, 1, _lightness).toColor(),
            ]),
            onChanged: (v) { setState(() => _saturation = v); _emitDebounced(); },
            onDragStart: () => _dragging = true,
            onDragEnd: () { _dragging = false; _emitFinal(); },
          ),
          const SizedBox(height: 10),
          _sliderRow(
            label: 'L',
            value: _lightness,
            min: 0,
            max: 1,
            gradient: LinearGradient(colors: [
              Colors.black,
              HSLColor.fromAHSL(1, _hue, _saturation, 0.5).toColor(),
              Colors.white,
            ]),
            onChanged: (v) { setState(() => _lightness = v); _emitDebounced(); },
            onDragStart: () => _dragging = true,
            onDragEnd: () { _dragging = false; _emitFinal(); },
          ),
        ],
      ),
    );
  }

  LinearGradient _hueGradient() {
    return LinearGradient(
      colors: List.generate(7, (i) =>
        HSLColor.fromAHSL(1, (i * 60.0).clamp(0, 359), 1, 0.5).toColor()),
    );
  }

  Widget _sliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required LinearGradient gradient,
    required ValueChanged<double> onChanged,
    required VoidCallback onDragStart,
    required VoidCallback onDragEnd,
  }) {
    final displayVal = max > 1 ? '${value.round()}' : '${(value * 100).round()}%';
    return Row(
      children: [
        SizedBox(
          width: 16,
          child: Text(label,
              style: GoogleFonts.jetBrainsMono(
                  color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 28,
            child: _GradientSlider(
              value: value,
              min: min,
              max: max,
              gradient: gradient,
              onChanged: onChanged,
              onDragStart: onDragStart,
              onDragEnd: onDragEnd,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 36,
          child: Text(displayVal,
              textAlign: TextAlign.right,
              style: GoogleFonts.jetBrainsMono(
                  color: AppTheme.textSecondary, fontSize: 11)),
        ),
      ],
    );
  }
}

// ── Custom gradient slider ───────────────────────────────────────────────────
class _GradientSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final LinearGradient gradient;
  final ValueChanged<double> onChanged;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;

  const _GradientSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.gradient,
    required this.onChanged,
    required this.onDragStart,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final trackWidth = constraints.maxWidth;
      if (trackWidth <= 0) return const SizedBox.shrink();

      final range = max - min;
      final fraction = range > 0 ? ((value - min) / range).clamp(0.0, 1.0) : 0.0;
      final thumbX = fraction * trackWidth;

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) => onDragStart(),
        onHorizontalDragUpdate: (d) => _handleDrag(d.localPosition.dx, trackWidth),
        onHorizontalDragEnd: (_) => onDragEnd(),
        onTapDown: (d) {
          onDragStart();
          _handleDrag(d.localPosition.dx, trackWidth);
          onDragEnd();
        },
        child: SizedBox(
          height: 28,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              Positioned(
                left: (thumbX - 8).clamp(0.0, (trackWidth - 16).clamp(0.0, double.infinity)),
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black26, width: 1),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 1)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _handleDrag(double localX, double trackWidth) {
    if (trackWidth <= 0) return;
    final fraction = (localX / trackWidth).clamp(0.0, 1.0);
    onChanged(min + fraction * (max - min));
  }
}
