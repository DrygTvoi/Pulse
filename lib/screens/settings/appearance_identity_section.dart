// Settings — Appearance section: theme engine + language picker.
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_manager.dart';
import '../../l10n/l10n_ext.dart';
import '../../services/locale_notifier.dart';
import '../../utils/platform_utils.dart';
import '../dynamic_theme_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/design_tokens.dart';
import 'settings_widgets.dart';

class AppearanceIdentitySection extends StatelessWidget {
  const AppearanceIdentitySection({super.key});

  /// Detect active preset name by matching current SEED to known presets.
  /// Surfaces are now seed-derived via HSL so we only need the seed match.
  /// Same hex list as `_seedPresets` in `dynamic_theme_screen.dart` —
  /// keep them in sync.
  static String _activePresetLabel() {
    final seed = ThemeNotifier.instance.primary.toARGB32() & 0xFFFFFFFF;
    const presets = <int, String>{
      0xFF5288C1: 'Ocean',
      0xFF5A8C6B: 'Forest',
      0xFF9079B5: 'Lavender',
      0xFFC97B95: 'Rose',
      0xFFC8995C: 'Amber',
      0xFFB85B5B: 'Crimson',
      0xFF6F829A: 'Slate',
      0xFF7FA68D: 'Sage',
    };
    return presets[seed] ?? 'Custom';
  }

  @override
  Widget build(BuildContext context) {
    final presetLabel = _activePresetLabel();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        settingsSectionDivider(context.l10n.settingsAppearance),
        const SizedBox(height: DesignTokens.spacing14),
        settingsGroup(children: [
          settingsGroupRow(
            icon: Icons.palette_rounded,
            iconColor: const Color(0xFF9B59B6),
            title: context.l10n.settingsThemeEngine,
            subtitle: presetLabel,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DynamicThemeScreen()),
            ),
          ),
          _buildLanguageRow(context),
        ]),
      ],
    );
  }

  Widget _buildLanguageRow(BuildContext context) {
    final current = LocaleNotifier.instance.locale;
    final name = current == null
        ? context.l10n.settingsLanguageSystem
        : LocaleNotifier.nativeNames[current.languageCode] ??
            current.languageCode;

    return settingsGroupRow(
      icon: Icons.language_rounded,
      iconColor: const Color(0xFF009688),
      title: context.l10n.settingsLanguage,
      subtitle: name,
      onTap: () => showLanguagePicker(context),
    );
  }

  static void showLanguagePicker(BuildContext context) {
    final current = LocaleNotifier.instance.locale;

    Widget languageList(BuildContext ctx, {ScrollController? scrollController}) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!PlatformUtils.isDesktop) ...[
            const SizedBox(height: DesignTokens.spacing12),
            Container(
              width: 36,
              height: DesignTokens.spacing4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withValues(alpha: DesignTokens.opacityMedium),
                borderRadius: BorderRadius.circular(DesignTokens.radiusXs),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(DesignTokens.spacing16),
            child: Text(
              context.l10n.settingsLanguage,
              style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: DesignTokens.fontXl,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              children: [
                // System default option
                _LanguageTile(
                  title: context.l10n.settingsLanguageSystem,
                  selected: current == null,
                  onTap: () {
                    LocaleNotifier.instance.setLocale(null);
                    Navigator.pop(ctx);
                  },
                ),
                const Divider(height: 1),
                // All supported languages
                ...LocaleNotifier.nativeNames.entries.map((e) {
                  final locale = Locale(e.key);
                  return _LanguageTile(
                    title: e.value,
                    selected: current?.languageCode == e.key,
                    onTap: () {
                      LocaleNotifier.instance.setLocale(locale);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        ],
      );
    }

    if (PlatformUtils.isDesktop) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.buttonRadius),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: DesignTokens.dialogMaxWidth, maxHeight: 500),
            child: languageList(ctx),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.dialogRadius)),
        ),
        isScrollControlled: true,
        builder: (ctx) {
          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 0.85,
            minChildSize: 0.4,
            expand: false,
            builder: (_, scrollController) {
              return languageList(ctx, scrollController: scrollController);
            },
          );
        },
      );
    }
  }
}

class _LanguageTile extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: AppTheme.textPrimary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          fontSize: DesignTokens.fontLg,
        ),
      ),
      trailing: selected
          ? Icon(Icons.check_rounded, color: AppTheme.primary, size: 22)
          : null,
      onTap: onTap,
    );
  }
}
