// Settings — About section: privacy policy link + crash reporting opt-in.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/l10n_ext.dart';
import '../../theme/app_theme.dart';
import '../privacy_policy_screen.dart';
import 'settings_widgets.dart';

const kAppVersion = '1.0.0';

class AboutSection extends StatefulWidget {
  final VoidCallback? onDevModeUnlocked;
  const AboutSection({super.key, this.onDevModeUnlocked});

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection> {
  bool _sentryOptIn = false;
  int _tapCount = 0;
  bool _devModeAlreadyEnabled = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sentryOptIn = prefs.getBool('sentry_opt_in') ?? false;
      _devModeAlreadyEnabled = prefs.getBool('dev_mode_enabled') ?? false;
    });
  }

  Future<void> _toggle(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sentry_opt_in', value);
    setState(() => _sentryOptIn = value);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(value
            ? context.l10n.settingsCrashReportingEnabled
            : context.l10n.settingsCrashReportingDisabled),
        duration: const Duration(seconds: 3),
      ));
    }
  }

  Future<void> _onVersionTap() async {
    if (_devModeAlreadyEnabled) return;
    setState(() => _tapCount++);
    final remaining = 7 - _tapCount;
    if (_tapCount < 7) {
      if (remaining <= 3) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$remaining more taps to enable developer mode'),
          duration: const Duration(milliseconds: 800),
        ));
      }
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dev_mode_enabled', true);
    setState(() => _devModeAlreadyEnabled = true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Developer mode enabled'),
      duration: Duration(seconds: 2),
    ));
    widget.onDevModeUnlocked?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        settingsSectionDivider(context.l10n.settingsAbout),
        const SizedBox(height: 14),
        // Version row — tap 7 times to unlock dev mode
        GestureDetector(
          onTap: _onVersionTap,
          child: settingsRow(
            icon: Icons.info_outline,
            iconColor: const Color(0xFF1ABC9C),
            title: 'Pulse',
            subtitle: _devModeAlreadyEnabled
                ? 'v$kAppVersion · Developer mode active'
                : 'v$kAppVersion',
            trailing: _devModeAlreadyEnabled
                ? Icon(Icons.code, size: 18, color: AppTheme.primary)
                : null,
          ),
        ),
        const SizedBox(height: 12),
        settingsRow(
          icon: Icons.privacy_tip_outlined,
          iconColor: const Color(0xFF1ABC9C),
          title: context.l10n.settingsPrivacyPolicy,
          subtitle: context.l10n.settingsPrivacyPolicySubtitle,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
          ),
        ),
        const SizedBox(height: 12),
        settingsRow(
          icon: Icons.bug_report_outlined,
          iconColor: const Color(0xFF1ABC9C),
          title: context.l10n.settingsCrashReporting,
          subtitle: context.l10n.settingsCrashReportingSubtitle,
          trailing: Switch.adaptive(
            value: _sentryOptIn,
            activeThumbColor: const Color(0xFF1ABC9C),
            onChanged: _toggle,
          ),
        ),
      ],
    );
  }
}
