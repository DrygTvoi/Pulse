import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import '../l10n/l10n_ext.dart';

/// FluffyChat-style theme picker — one seed colour drives the entire palette.
/// The user can pick from a named preset grid, drag an HSL picker to fine-tune
/// a custom seed, switch dark/light/system mode and adjust the global radius.
/// Per-surface and per-bubble pickers are gone — they're derived tonally.
class DynamicThemeScreen extends StatefulWidget {
  const DynamicThemeScreen({super.key});

  @override
  State<DynamicThemeScreen> createState() => _DynamicThemeScreenState();
}

class _DynamicThemeScreenState extends State<DynamicThemeScreen> {
  Timer? _radiusDebounce;
  late double _localRadius;
  bool _radiusDragging = false;
  bool _showCustomPicker = false;

  // Curated seed presets — pulled from popular messengers/IDEs so users have
  // a recognisable starting point. The seed alone determines the entire
  // ColorScheme via Material You tonal generation.
  static const _seedPresets = <_SeedPreset>[
    _SeedPreset('Discord',  Color(0xFF5865F2)),
    _SeedPreset('Sky',      Color(0xFF0EA5E9)),
    _SeedPreset('VS Code',  Color(0xFF007ACC)),
    _SeedPreset('Telegram', Color(0xFF229ED9)),
    _SeedPreset('iMessage', Color(0xFF0A84FF)),
    _SeedPreset('Slack',    Color(0xFF611F69)),
    _SeedPreset('Pulse',    Color(0xFF26A69A)),
    _SeedPreset('WhatsApp', Color(0xFF25D366)),
    _SeedPreset('Sunset',   Color(0xFFFB7185)),
    _SeedPreset('Amber',    Color(0xFFF59E0B)),
    _SeedPreset('Crimson',  Color(0xFFDC2626)),
    _SeedPreset('Mono',     Color(0xFF6B7280)),
  ];

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

  void _applySeed(Color seed) {
    ThemeNotifier.instance.setSeed(seed);
  }

  bool _isCurrentSeed(Color a, Color b) =>
      a.toARGB32() == b.toARGB32();

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeNotifier>();
    final scheme = Theme.of(context).colorScheme;
    if (!_radiusDragging) _localRadius = theme.borderRadius;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.themeEngineTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // ── Live preview chip ─────────────────────────────────────────
          _LivePreviewCard(seed: theme.primary),
          const SizedBox(height: 28),

          // ── Mode ──────────────────────────────────────────────────────
          _sectionLabel(context.l10n.themeDynamicAppearance, scheme),
          const SizedBox(height: 10),
          _ModeToggle(
            mode: theme.themeMode,
            onChanged: (m) => ThemeNotifier.instance.setThemeMode(m),
          ),

          const SizedBox(height: 28),

          // ── Seed presets ──────────────────────────────────────────────
          _sectionLabel(context.l10n.themeDynamicPresets, scheme),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _seedPresets.map((p) {
              final active = _isCurrentSeed(p.seed, theme.primary);
              return _SeedChip(
                preset: p,
                active: active,
                onTap: () => _applySeed(p.seed),
              );
            }).toList(),
          ),

          const SizedBox(height: 28),

          // ── Custom seed (collapsible HSL picker) ──────────────────────
          _sectionLabel(context.l10n.themeColors, scheme),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => setState(() => _showCustomPicker = !_showCustomPicker),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: theme.primary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: scheme.onSurface.withValues(alpha: 0.15)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(context.l10n.themePrimaryAccent,
                        style: GoogleFonts.inter(
                            color: scheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                  ),
                  Text(
                    '#${(theme.primary.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}',
                    style: GoogleFonts.jetBrainsMono(
                        color: scheme.onSurfaceVariant, fontSize: 11),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _showCustomPicker ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.expand_more_rounded,
                        size: 20, color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _showCustomPicker
                ? Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 12),
                    child: _HslColorPicker(
                      color: theme.primary,
                      onChanged: _applySeed,
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 16),

          // ── Shape (border radius) ─────────────────────────────────────
          _sectionLabel(context.l10n.themeShape, scheme),
          _RadiusSlider(
            value: _localRadius,
            onChanged: (v) {
              setState(() {
                _radiusDragging = true;
                _localRadius = v;
              });
              _radiusDebounce?.cancel();
              _radiusDebounce = Timer(const Duration(milliseconds: 80), () {
                ThemeNotifier.instance.updateRadius(v);
                _radiusDragging = false;
              });
            },
            onChangeEnd: (v) {
              _radiusDebounce?.cancel();
              ThemeNotifier.instance.updateRadius(v);
              _radiusDragging = false;
            },
          ),

          const SizedBox(height: 32),

          // ── Reset ─────────────────────────────────────────────────────
          Center(
            child: TextButton.icon(
              onPressed: () {
                ThemeNotifier.instance.resetCustom();
                setState(() {
                  _localRadius = ThemeNotifier.instance.borderRadius;
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, ColorScheme scheme) => Padding(
        padding: const EdgeInsets.only(left: 4, top: 4, bottom: 4),
        child: Text(
          text.toUpperCase(),
          style: GoogleFonts.inter(
            color: scheme.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      );
}

// ── Preset model ───────────────────────────────────────────────────────────
class _SeedPreset {
  final String name;
  final Color seed;
  const _SeedPreset(this.name, this.seed);
}

// ── Seed chip — large color square + name, tinted if active ────────────────
class _SeedChip extends StatelessWidget {
  final _SeedPreset preset;
  final bool active;
  final VoidCallback onTap;

  const _SeedChip(
      {required this.preset, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: active
          ? preset.seed.withValues(alpha: 0.18)
          : scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: active ? preset.seed : Colors.transparent,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: preset.seed,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                preset.name,
                style: GoogleFonts.inter(
                  color: scheme.onSurface,
                  fontSize: 13,
                  fontWeight:
                      active ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Mode toggle ────────────────────────────────────────────────────────────
class _ModeToggle extends StatelessWidget {
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget seg(ThemeMode m, IconData icon, String label) {
      final selected = m == mode;
      return Expanded(
        child: Material(
          color: selected ? scheme.secondaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => onChanged(m),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon,
                      size: 20,
                      color: selected
                          ? scheme.onSecondaryContainer
                          : scheme.onSurfaceVariant),
                  const SizedBox(height: 4),
                  Text(label,
                      style: GoogleFonts.inter(
                        color: selected
                            ? scheme.onSecondaryContainer
                            : scheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                      )),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          seg(ThemeMode.dark, Icons.dark_mode_rounded,
              context.l10n.themeModeDark),
          seg(ThemeMode.light, Icons.light_mode_rounded,
              context.l10n.themeModeLight),
          seg(ThemeMode.system, Icons.brightness_auto_rounded,
              context.l10n.themeModeSystem),
        ],
      ),
    );
  }
}

// ── Live preview card — shows the seed applied to a faux chat row ──────────
class _LivePreviewCard extends StatelessWidget {
  final Color seed;
  const _LivePreviewCard({required this.seed});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Incoming
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 240),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text('Hey, how does this look?',
                  style: GoogleFonts.inter(
                      color: scheme.onSurface, fontSize: 14)),
            ),
          ),
          const SizedBox(height: 6),
          // Outgoing
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 240),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text('Looking sharp ✨',
                  style: GoogleFonts.inter(
                      color: scheme.onPrimaryContainer, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Radius slider ──────────────────────────────────────────────────────────
class _RadiusSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  const _RadiusSlider({
    required this.value,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(Icons.crop_square_rounded,
              size: 18, color: scheme.onSurfaceVariant),
          Expanded(
            child: Slider(
              value: value,
              min: 4,
              max: 28,
              divisions: 24,
              activeColor: scheme.primary,
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
            ),
          ),
          Icon(Icons.circle, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Container(
            width: 36,
            alignment: Alignment.centerRight,
            child: Text('${value.round()}',
                style: GoogleFonts.jetBrainsMono(
                    color: scheme.onSurfaceVariant, fontSize: 12)),
          ),
        ],
      ),
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
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _sliderRow(
            label: 'H',
            value: _hue,
            min: 0,
            max: 359,
            gradient: _hueGradient(),
            onChanged: (v) {
              setState(() => _hue = v);
              _emitDebounced();
            },
            onDragStart: () => _dragging = true,
            onDragEnd: () {
              _dragging = false;
              _emitFinal();
            },
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
            onChanged: (v) {
              setState(() => _saturation = v);
              _emitDebounced();
            },
            onDragStart: () => _dragging = true,
            onDragEnd: () {
              _dragging = false;
              _emitFinal();
            },
          ),
          const SizedBox(height: 10),
          _sliderRow(
            label: 'L',
            value: _lightness,
            min: 0,
            max: 1,
            gradient: LinearGradient(colors: [
              HSLColor.fromAHSL(1, _hue, _saturation, 0).toColor(),
              HSLColor.fromAHSL(1, _hue, _saturation, 0.5).toColor(),
              HSLColor.fromAHSL(1, _hue, _saturation, 1).toColor(),
            ]),
            onChanged: (v) {
              setState(() => _lightness = v);
              _emitDebounced();
            },
            onDragStart: () => _dragging = true,
            onDragEnd: () {
              _dragging = false;
              _emitFinal();
            },
          ),
        ],
      ),
    );
  }

  static LinearGradient _hueGradient() => const LinearGradient(colors: [
        Color(0xFFFF0000),
        Color(0xFFFFFF00),
        Color(0xFF00FF00),
        Color(0xFF00FFFF),
        Color(0xFF0000FF),
        Color(0xFFFF00FF),
        Color(0xFFFF0000),
      ]);

  Widget _sliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required Gradient gradient,
    required ValueChanged<double> onChanged,
    required VoidCallback onDragStart,
    required VoidCallback onDragEnd,
  }) {
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
                    gradient: gradient,
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
                  value: value.clamp(min, max),
                  min: min,
                  max: max,
                  onChangeStart: (_) => onDragStart(),
                  onChanged: onChanged,
                  onChangeEnd: (_) => onDragEnd(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
