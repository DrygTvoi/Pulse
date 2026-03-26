// Settings — Language section: app display language picker.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../theme/design_tokens.dart';
import '../../l10n/l10n_ext.dart';
import '../../services/locale_notifier.dart';
import 'settings_widgets.dart';

class LanguageSection extends StatelessWidget {
  const LanguageSection({super.key});

  @override
  Widget build(BuildContext context) {
    final current = LocaleNotifier.instance.locale;
    final name = current == null
        ? context.l10n.settingsLanguageSystem
        : LocaleNotifier.nativeNames[current.languageCode] ??
            current.languageCode;

    return settingsRow(
      icon: Icons.language_rounded,
      iconColor: const Color(0xFF009688),
      title: context.l10n.settingsLanguage,
      subtitle: name,
      onTap: () => _showLanguagePicker(context),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final current = LocaleNotifier.instance.locale;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.85,
          minChildSize: 0.4,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
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
          },
        );
      },
    );
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
