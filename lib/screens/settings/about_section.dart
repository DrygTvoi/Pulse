// Settings — About section: privacy policy link.
import 'package:flutter/material.dart';
import '../privacy_policy_screen.dart';
import 'settings_widgets.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        settingsSectionDivider('About'),
        const SizedBox(height: 14),
        settingsRow(
          icon: Icons.privacy_tip_outlined,
          iconColor: const Color(0xFF1ABC9C),
          title: 'Privacy Policy',
          subtitle: 'How Pulse protects your data',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
          ),
        ),
      ],
    );
  }
}
