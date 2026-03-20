// Settings — About section: privacy policy link + crash reporting opt-in.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/l10n_ext.dart';
import '../privacy_policy_screen.dart';
import 'settings_widgets.dart';

class AboutSection extends StatefulWidget {
  const AboutSection({super.key});

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection> {
  bool _sentryOptIn = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _sentryOptIn = prefs.getBool('sentry_opt_in') ?? false);
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        settingsSectionDivider(context.l10n.settingsAbout),
        const SizedBox(height: 14),
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
        SwitchListTile(
          secondary: const Icon(Icons.bug_report_outlined, color: Colors.grey),
          title: Text(context.l10n.settingsCrashReporting, style: const TextStyle(color: Colors.white, fontSize: 14)),
          subtitle: Text(
            context.l10n.settingsCrashReportingSubtitle,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          value: _sentryOptIn,
          onChanged: _toggle,
          activeTrackColor: const Color(0xFF1ABC9C),
        ),
      ],
    );
  }
}
