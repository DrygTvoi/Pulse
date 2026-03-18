import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Privacy Policy',
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heading('Overview'),
            _body(
              'Pulse is a serverless, end-to-end encrypted messenger. '
              'Your privacy is not just a feature — it is the architecture. '
              'There are no Pulse servers. No accounts are stored anywhere. '
              'No data is collected, transmitted to, or stored by the developers.',
            ),
            _heading('Data Collection'),
            _body(
              'Pulse collects zero personal data. Specifically:\n\n'
              '- No email, phone number, or real name is required\n'
              '- No analytics, tracking, or telemetry\n'
              '- No advertising identifiers\n'
              '- No contact list access\n'
              '- No cloud backups (messages exist only on your device)\n'
              '- No metadata is sent to any Pulse server (there are none)',
            ),
            _heading('Encryption'),
            _body(
              'All messages are encrypted using the Signal Protocol (Double Ratchet '
              'with X3DH key agreement). Encryption keys are generated and stored '
              'exclusively on your device. No one — including the developers — can '
              'read your messages.',
            ),
            _heading('Network Architecture'),
            _body(
              'Pulse uses federated transport adapters (Nostr relays, Session/Oxen '
              'service nodes, Waku nodes, Firebase Realtime Database, LAN). '
              'These transports carry only encrypted ciphertext. '
              'Relay operators can see your IP address and traffic volume, '
              'but cannot decrypt message content.\n\n'
              'When Tor is enabled, your IP address is also hidden from relay operators.',
            ),
            _heading('STUN/TURN Servers'),
            _body(
              'Voice and video calls use WebRTC with DTLS-SRTP encryption. '
              'STUN servers (used to discover your public IP for peer-to-peer '
              'connections) and TURN servers (used to relay media when direct '
              'connection fails) can see your IP address and call duration, '
              'but cannot decrypt call content.\n\n'
              'You can configure your own TURN server in Settings for maximum privacy.',
            ),
            _heading('Crash Reporting'),
            _body(
              'If Sentry crash reporting is enabled (via build-time SENTRY_DSN), '
              'anonymous crash reports may be sent. These contain no message content, '
              'no contact information, and no personally identifiable information. '
              'Crash reporting can be disabled at build time by omitting the DSN.',
            ),
            _heading('Password & Keys'),
            _body(
              'Your recovery password is used to derive cryptographic keys via '
              'Argon2id (memory-hard KDF). The password is never transmitted anywhere. '
              'If you lose your password, your account cannot be recovered — '
              'there is no server to reset it.',
            ),
            _heading('Fonts'),
            _body(
              'Pulse bundles all fonts locally. No requests are made to Google Fonts '
              'or any external font service.',
            ),
            _heading('Third-Party Services'),
            _body(
              'Pulse does not integrate with any advertising networks, analytics '
              'providers, social media platforms, or data brokers. '
              'The only network connections are to the transport relays you configure.',
            ),
            _heading('Open Source'),
            _body(
              'Pulse is open-source software. You can audit the complete source code '
              'to verify these privacy claims.',
            ),
            _heading('Contact'),
            _body(
              'For privacy-related questions, open an issue on the project repository.',
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Last updated: March 2026',
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary, fontSize: 11),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _heading(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(text,
          style: GoogleFonts.inter(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700)),
    );
  }

  Widget _body(String text) {
    return Text(text,
        style: GoogleFonts.inter(
            color: AppTheme.textSecondary,
            fontSize: 13,
            height: 1.6));
  }
}
