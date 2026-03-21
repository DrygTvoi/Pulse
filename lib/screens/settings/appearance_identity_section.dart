// Settings — Appearance section: theme picker and Signal Protocol badge.
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/design_tokens.dart';
import '../../l10n/l10n_ext.dart';
import '../../widgets/theme_picker_widget.dart';
import '../dynamic_theme_screen.dart';
import 'settings_widgets.dart';

class AppearanceIdentitySection extends StatelessWidget {
  const AppearanceIdentitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        settingsSectionDivider(context.l10n.settingsAppearance),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          ),
          child: const ThemePickerWidget(),
        ),
        const SizedBox(height: 12),
        settingsRow(
          icon: Icons.palette_rounded,
          iconColor: const Color(0xFF9B59B6),
          title: context.l10n.settingsThemeEngine,
          subtitle: context.l10n.settingsThemeEngineSubtitle,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DynamicThemeScreen()),
          ),
        ),
      ],
    );
  }
}
