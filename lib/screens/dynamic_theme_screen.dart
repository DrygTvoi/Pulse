import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import '../l10n/l10n_ext.dart';

/// Compact theme picker — small preset chips on top, then a stack of
/// fine-tune sliders (surface tint, surface depth, accent depth, border
/// radius). The mode toggle lives as an icon action in the AppBar.
/// Custom seed picker (HSL) sits below the chips and unfolds on tap.
class DynamicThemeScreen extends StatefulWidget {
  const DynamicThemeScreen({super.key});

  @override
  State<DynamicThemeScreen> createState() => _DynamicThemeScreenState();
}

class _DynamicThemeScreenState extends State<DynamicThemeScreen> {
  Timer? _debounce;
  late double _localRadius;
  late double _localSurfaceTint;
  late double _localSurfaceDepth;
  late double _localAccentDepth;
  bool _dragging = false;
  bool _showCustomPicker = false;

  static const _seedPresets = <_SeedPreset>[
    _SeedPreset('Ocean',    Color(0xFF5288C1)),
    _SeedPreset('Forest',   Color(0xFF5A8C6B)),
    _SeedPreset('Lavender', Color(0xFF9079B5)),
    _SeedPreset('Rose',     Color(0xFFC97B95)),
    _SeedPreset('Amber',    Color(0xFFC8995C)),
    _SeedPreset('Crimson',  Color(0xFFB85B5B)),
    _SeedPreset('Slate',    Color(0xFF6F829A)),
    _SeedPreset('Sage',     Color(0xFF7FA68D)),
  ];

  @override
  void initState() {
    super.initState();
    final tn = ThemeNotifier.instance;
    _localRadius = tn.borderRadius;
    _localSurfaceTint = tn.surfaceTint;
    _localSurfaceDepth = tn.surfaceDepth;
    _localAccentDepth = tn.accentDepth;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _applySeed(Color seed) => ThemeNotifier.instance.setSeed(seed);

  bool _eq(Color a, Color b) => a.toARGB32() == b.toARGB32();

  IconData _modeIcon(ThemeMode m) => m == ThemeMode.light
      ? Icons.light_mode_rounded
      : (m == ThemeMode.system
          ? Icons.brightness_auto_rounded
          : Icons.dark_mode_rounded);

  ThemeMode _nextMode(ThemeMode m) => m == ThemeMode.dark
      ? ThemeMode.light
      : (m == ThemeMode.light ? ThemeMode.system : ThemeMode.dark);

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeNotifier>();
    final scheme = Theme.of(context).colorScheme;
    if (!_dragging) {
      _localRadius = theme.borderRadius;
      _localSurfaceTint = theme.surfaceTint;
      _localSurfaceDepth = theme.surfaceDepth;
      _localAccentDepth = theme.accentDepth;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.themeEngineTitle),
        actions: [
          IconButton(
            tooltip: context.l10n.themeDynamicAppearance,
            icon: Icon(_modeIcon(theme.themeMode)),
            onPressed: () => ThemeNotifier.instance
                .setThemeMode(_nextMode(theme.themeMode)),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // ── Preset row — small color chips ────────────────────────────
          _GroupCard(
            title: context.l10n.themeDynamicPresets,
            scheme: scheme,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final p in _seedPresets)
                  _PresetChip(
                    preset: p,
                    active: _eq(p.seed, theme.primary),
                    onTap: () => _applySeed(p.seed),
                  ),
                _CustomChip(
                  active: !_seedPresets.any((p) => _eq(p.seed, theme.primary)),
                  expanded: _showCustomPicker,
                  onTap: () =>
                      setState(() => _showCustomPicker = !_showCustomPicker),
                ),
              ],
            ),
          ),

          // ── Custom HSL picker (collapsible) ───────────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _showCustomPicker
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _HslColorPicker(
                      color: theme.primary,
                      onChanged: _applySeed,
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 14),

          // ── Surface customization ─────────────────────────────────────
          _GroupCard(
            title: context.l10n.themeBackground,
            scheme: scheme,
            child: Column(
              children: [
                _NamedSlider(
                  label: 'Tint strength',
                  hint: 'Grey ↔ Tinted',
                  value: _localSurfaceTint,
                  min: 0.0,
                  max: 0.45,
                  divisions: 45,
                  format: (v) => v.toStringAsFixed(2),
                  onChanged: (v) {
                    setState(() {
                      _dragging = true;
                      _localSurfaceTint = v;
                    });
                    _debouncedApply(() => ThemeNotifier.instance.setSurfaceTint(v));
                  },
                  onChangeEnd: (v) {
                    _debounce?.cancel();
                    ThemeNotifier.instance.setSurfaceTint(v);
                    _dragging = false;
                  },
                ),
                _NamedSlider(
                  label: 'Depth',
                  hint: 'Lighter ↔ Deeper',
                  value: _localSurfaceDepth,
                  min: -0.05,
                  max: 0.05,
                  divisions: 20,
                  format: (v) =>
                      (v >= 0 ? '+' : '') + v.toStringAsFixed(2),
                  onChanged: (v) {
                    setState(() {
                      _dragging = true;
                      _localSurfaceDepth = v;
                    });
                    _debouncedApply(() => ThemeNotifier.instance.setSurfaceDepth(v));
                  },
                  onChangeEnd: (v) {
                    _debounce?.cancel();
                    ThemeNotifier.instance.setSurfaceDepth(v);
                    _dragging = false;
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Accent customization ──────────────────────────────────────
          _GroupCard(
            title: context.l10n.themePrimaryAccent,
            scheme: scheme,
            child: _NamedSlider(
              label: 'Bubble depth',
              hint: 'Deep ↔ Loud',
              value: _localAccentDepth,
              min: 0.10,
              max: 0.40,
              divisions: 30,
              format: (v) => v.toStringAsFixed(2),
              onChanged: (v) {
                setState(() {
                  _dragging = true;
                  _localAccentDepth = v;
                });
                _debouncedApply(() => ThemeNotifier.instance.setAccentDepth(v));
              },
              onChangeEnd: (v) {
                _debounce?.cancel();
                ThemeNotifier.instance.setAccentDepth(v);
                _dragging = false;
              },
            ),
          ),

          const SizedBox(height: 14),

          // ── Shape (border radius) ─────────────────────────────────────
          _GroupCard(
            title: context.l10n.themeShape,
            scheme: scheme,
            child: _NamedSlider(
              label: 'Corner radius',
              hint: 'Sharp ↔ Round',
              value: _localRadius,
              min: 4,
              max: 28,
              divisions: 24,
              format: (v) => '${v.round()} px',
              onChanged: (v) {
                setState(() {
                  _dragging = true;
                  _localRadius = v;
                });
                _debouncedApply(() => ThemeNotifier.instance.updateRadius(v));
              },
              onChangeEnd: (v) {
                _debounce?.cancel();
                ThemeNotifier.instance.updateRadius(v);
                _dragging = false;
              },
            ),
          ),

          const SizedBox(height: 18),

          // ── Reset ─────────────────────────────────────────────────────
          Center(
            child: TextButton.icon(
              onPressed: () {
                ThemeNotifier.instance.resetCustom();
                setState(() {
                  final tn = ThemeNotifier.instance;
                  _localRadius = tn.borderRadius;
                  _localSurfaceTint = tn.surfaceTint;
                  _localSurfaceDepth = tn.surfaceDepth;
                  _localAccentDepth = tn.accentDepth;
                  _showCustomPicker = false;
                });
              },
              icon: Icon(Icons.restart_alt_rounded,
                  size: 18, color: scheme.onSurfaceVariant),
              label: Text(context.l10n.themeResetToDefaults,
                  style: GoogleFonts.inter(
                      color: scheme.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }

  void _debouncedApply(VoidCallback fn) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 60), () {
      fn();
      _dragging = false;
    });
  }
}

// ── Section card with title ────────────────────────────────────────────────
class _GroupCard extends StatelessWidget {
  final String title;
  final Widget child;
  final ColorScheme scheme;
  const _GroupCard(
      {required this.title, required this.child, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.inter(
                color: scheme.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              )),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// ── Preset model ───────────────────────────────────────────────────────────
class _SeedPreset {
  final String name;
  final Color seed;
  const _SeedPreset(this.name, this.seed);
}

// ── Small preset chip — coloured circle + name ─────────────────────────────
class _PresetChip extends StatelessWidget {
  final _SeedPreset preset;
  final bool active;
  final VoidCallback onTap;
  const _PresetChip(
      {required this.preset, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: active
          ? preset.seed.withValues(alpha: 0.18)
          : scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: active ? preset.seed : Colors.transparent,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                    color: preset.seed, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                preset.name,
                style: GoogleFonts.inter(
                  color: scheme.onSurface,
                  fontSize: 12,
                  fontWeight:
                      active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Custom chip — opens HSL picker ─────────────────────────────────────────
class _CustomChip extends StatelessWidget {
  final bool active;
  final bool expanded;
  final VoidCallback onTap;
  const _CustomChip(
      {required this.active,
      required this.expanded,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: active
          ? scheme.primary.withValues(alpha: 0.15)
          : scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: active ? scheme.primary : Colors.transparent,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(colors: [
                    Color(0xFFFF0000),
                    Color(0xFFFFFF00),
                    Color(0xFF00FF00),
                    Color(0xFF00FFFF),
                    Color(0xFF0000FF),
                    Color(0xFFFF00FF),
                    Color(0xFFFF0000),
                  ]),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Custom',
                style: GoogleFonts.inter(
                  color: scheme.onSurface,
                  fontSize: 12,
                  fontWeight:
                      active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                expanded
                    ? Icons.expand_less_rounded
                    : Icons.tune_rounded,
                size: 14,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Labelled slider with hint and live value ───────────────────────────────
class _NamedSlider extends StatelessWidget {
  final String label;
  final String hint;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String Function(double) format;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  const _NamedSlider({
    required this.label,
    required this.hint,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.format,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label,
                  style: GoogleFonts.inter(
                    color: scheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  )),
            ),
            Text(format(value),
                style: GoogleFonts.jetBrainsMono(
                    color: scheme.onSurfaceVariant, fontSize: 11)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            activeColor: scheme.primary,
            inactiveColor: scheme.surfaceContainerHighest,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 2),
          child: Text(hint,
              style: GoogleFonts.inter(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                  fontSize: 10)),
        ),
      ],
    );
  }
}

// ── HSL color picker (debounced output) ────────────────────────────────────
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
    if (!_dragging && old.color != widget.color) _syncFromColor(widget.color);
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
      widget.onChanged(
          HSLColor.fromAHSL(1.0, _hue, _saturation, _lightness).toColor());
    });
  }

  void _emitFinal() {
    _debounce?.cancel();
    widget.onChanged(
        HSLColor.fromAHSL(1.0, _hue, _saturation, _lightness).toColor());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _row('H', _hue, 0, 359, _hueGrad(),
              (v) => setState(() => _hue = v)),
          const SizedBox(height: 8),
          _row(
            'S',
            _saturation,
            0,
            1,
            LinearGradient(colors: [
              HSLColor.fromAHSL(1, _hue, 0, _lightness).toColor(),
              HSLColor.fromAHSL(1, _hue, 1, _lightness).toColor(),
            ]),
            (v) => setState(() => _saturation = v),
          ),
          const SizedBox(height: 8),
          _row(
            'L',
            _lightness,
            0,
            1,
            LinearGradient(colors: [
              HSLColor.fromAHSL(1, _hue, _saturation, 0).toColor(),
              HSLColor.fromAHSL(1, _hue, _saturation, 0.5).toColor(),
              HSLColor.fromAHSL(1, _hue, _saturation, 1).toColor(),
            ]),
            (v) => setState(() => _lightness = v),
          ),
        ],
      ),
    );
  }

  static LinearGradient _hueGrad() => const LinearGradient(colors: [
        Color(0xFFFF0000),
        Color(0xFFFFFF00),
        Color(0xFF00FF00),
        Color(0xFF00FFFF),
        Color(0xFF0000FF),
        Color(0xFFFF00FF),
        Color(0xFFFF0000),
      ]);

  Widget _row(String label, double v, double min, double max, Gradient g,
      ValueChanged<double> apply) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        SizedBox(
          width: 14,
          child: Text(label,
              style: GoogleFonts.jetBrainsMono(
                  color: scheme.onSurfaceVariant, fontSize: 11)),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              IgnorePointer(
                child: Container(
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    gradient: g,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 0,
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                  thumbColor: Colors.white,
                  overlayShape: SliderComponentShape.noOverlay,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 8),
                ),
                child: Slider(
                  value: v.clamp(min, max),
                  min: min,
                  max: max,
                  onChangeStart: (_) => _dragging = true,
                  onChanged: (val) {
                    apply(val);
                    _emitDebounced();
                  },
                  onChangeEnd: (_) {
                    _dragging = false;
                    _emitFinal();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
