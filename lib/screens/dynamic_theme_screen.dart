import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme_manager.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DynamicThemeScreen extends StatefulWidget {
  const DynamicThemeScreen({super.key});

  @override
  State<DynamicThemeScreen> createState() => _DynamicThemeScreenState();
}

class _DynamicThemeScreenState extends State<DynamicThemeScreen> {
  final List<String> _fonts = ['Outfit', 'Inter', 'Roboto', 'Fira Code'];

  void _applyPreset(String name) {
    switch (name) {
      case 'Cyberpunk':
        ThemeNotifier.instance.updateColors(
          primary: const Color(0xFF00FF9D),
          background: const Color(0xFF0D0221),
          surface: const Color(0xFF261447),
          accent: const Color(0xFFFF3864),
        );
        ThemeNotifier.instance.updateFont('Fira Code');
        ThemeNotifier.instance.updateRadius(0.0);
        break;
      case 'Minimalist Default':
        ThemeNotifier.instance.updateColors(
          primary: const Color(0xFF6366F1),
          background: const Color(0xFF0F172A),
          surface: const Color(0xFF1E293B),
          accent: const Color(0xFFF43F5E),
        );
        ThemeNotifier.instance.updateFont('Outfit');
        ThemeNotifier.instance.updateRadius(16.0);
        break;
      case 'Midnight Indigo':
        ThemeNotifier.instance.updateColors(
          primary: const Color(0xFF818CF8),
          background: const Color(0xFF050505),
          surface: const Color(0xFF171717),
          accent: const Color(0xFFC084FC),
        );
        ThemeNotifier.instance.updateFont('Inter');
        ThemeNotifier.instance.updateRadius(24.0);
        break;
      case 'Neon Pink':
        ThemeNotifier.instance.updateColors(
          primary: const Color(0xFFFF007F),
          background: const Color(0xFF1A0010),
          surface: const Color(0xFF330022),
          accent: const Color(0xFF00E5FF),
        );
        ThemeNotifier.instance.updateFont('Outfit');
        ThemeNotifier.instance.updateRadius(12.0);
        break;
    }
  }

  Widget _buildColorPicker(String label, Color currentColor, Function(Color) onSelect) {
    // A simple palette for the prototype
    final colors = [
      Colors.redAccent, Colors.pinkAccent, Colors.purpleAccent,
      Colors.deepPurpleAccent, Colors.indigoAccent, Colors.blueAccent,
      Colors.cyanAccent, Colors.tealAccent, Colors.greenAccent,
      Colors.orangeAccent, Colors.deepOrangeAccent, Colors.amberAccent
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              final isSelected = color.toARGB32() == currentColor.toARGB32();
              return GestureDetector(
                onTap: () => onSelect(color),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                  ),
                ),
              ).animate().scale(delay: Duration(milliseconds: 50 * index));
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Note: Since main.dart rebuilds the whole app, this screen will automatically refresh on changes
    // But we still watch it here to be explicit
    final theme = context.watch<ThemeNotifier>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Theme Engine Sandbox', style: GoogleFonts.outfit(color: theme.textPrimary)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Presets', style: GoogleFonts.outfit(fontSize: 24, color: theme.textPrimary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildPresetButton('Cyberpunk', const Color(0xFF00FF9D)),
              _buildPresetButton('Minimalist Default', const Color(0xFF6366F1)),
              _buildPresetButton('Midnight Indigo', const Color(0xFF818CF8)),
              _buildPresetButton('Neon Pink', const Color(0xFFFF007F)),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(color: Colors.white24),
          const SizedBox(height: 24),
          
          Text('Custom Properties', style: GoogleFonts.outfit(fontSize: 24, color: theme.textPrimary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          _buildColorPicker('Primary Color', theme.primary, (c) => ThemeNotifier.instance.updateColors(primary: c)),
          const SizedBox(height: 24),
          _buildColorPicker('Accent Color', theme.accent, (c) => ThemeNotifier.instance.updateColors(accent: c)),
          const SizedBox(height: 24),

          Text('Border Radius', style: GoogleFonts.inter(color: theme.textPrimary, fontWeight: FontWeight.bold)),
          Slider(
            value: theme.borderRadius,
            min: 0,
            max: 32,
            activeColor: theme.primary,
            onChanged: (val) => ThemeNotifier.instance.updateRadius(val),
          ),
          const SizedBox(height: 24),

          Text('Typography', style: GoogleFonts.inter(color: theme.textPrimary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: _fonts.map((f) => ChoiceChip(
              label: Text(f, style: GoogleFonts.inter(color: theme.textPrimary)),
              selected: theme.fontFamily == f,
              onSelected: (selected) {
                if(selected) ThemeNotifier.instance.updateFont(f);
              },
              selectedColor: theme.primary,
              backgroundColor: theme.surface,
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButton(String name, Color badgeColor) {
    return InkWell(
      onTap: () => _applyPreset(name),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(ThemeNotifier.instance.borderRadius),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 6, backgroundColor: badgeColor),
            const SizedBox(width: 8),
            Text(name, style: GoogleFonts.inter(color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }
}
