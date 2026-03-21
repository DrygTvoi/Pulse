import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Custom proxy & CF Worker relay configuration section for Settings.
///
/// Two features:
///   1. Custom SOCKS5 proxy — route traffic through V2Ray/Xray/Shadowsocks/etc.
///      Sits BETWEEN uTLS+ECH and Tor in the connection chain for fast fallback.
///   2. CF Worker relay — deploy a 10-line CF Worker as personal relay proxy.
///      GFW sees *.workers.dev (CF CDN), not the real Nostr relay hostname.
class CustomProxySection extends StatefulWidget {
  const CustomProxySection({
    super.key,
    required this.proxyEnabled,
    required this.proxyHostController,
    required this.proxyPortController,
    required this.onProxyEnabledChanged,
    required this.workerRelayController,
  });

  final bool proxyEnabled;
  final TextEditingController proxyHostController;
  final TextEditingController proxyPortController;
  final ValueChanged<bool> onProxyEnabledChanged;
  final TextEditingController workerRelayController;

  @override
  State<CustomProxySection> createState() => _CustomProxySectionState();
}

class _CustomProxySectionState extends State<CustomProxySection> {
  bool _workerHelpExpanded = false;

  static const _accent = Color(0xFF5C6BC0); // indigo

  static const _workerScript = '''export default {
  async fetch(request) {
    const url = new URL(request.url);
    const relay = url.searchParams.get('r');
    if (!relay) {
      return new Response('Pulse relay proxy.\\n'
        + 'Usage: wss://YOUR.workers.dev/?r=wss://relay.url',
        { status: 200 });
    }
    return fetch(relay, request);
  }
};''';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfo(),
        const SizedBox(height: 14),
        _sectionLabel('Custom Proxy (SOCKS5)'),
        const SizedBox(height: 10),
        _buildProxyToggle(),
        if (widget.proxyEnabled) ...[
          const SizedBox(height: 10),
          _buildProxyFields(),
          const SizedBox(height: 8),
          _hint('V2Ray/Xray: 127.0.0.1:10808  \u2022  Shadowsocks: 127.0.0.1:1080'),
        ],
        const SizedBox(height: 18),
        _sectionLabel('CF Worker Relay'),
        const SizedBox(height: 10),
        _buildWorkerField(),
        const SizedBox(height: 8),
        _buildWorkerHelp(),
      ],
    );
  }

  Widget _buildInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_rounded, size: 15, color: _accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Custom proxy routes traffic through your V2Ray/Xray/Shadowsocks. '
              'CF Worker acts as a personal relay proxy on Cloudflare CDN \u2014 '
              'GFW sees *.workers.dev, not the real relay.',
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondary, fontSize: 11, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProxyToggle() {
    return GestureDetector(
      onTap: () => widget.onProxyEnabledChanged(!widget.proxyEnabled),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: widget.proxyEnabled
              ? _accent.withValues(alpha: 0.08)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.proxyEnabled
                ? _accent.withValues(alpha: 0.4)
                : AppTheme.surfaceVariant,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.alt_route_rounded, color: _accent, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Custom SOCKS5 Proxy',
                      style: GoogleFonts.inter(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  Text(
                      widget.proxyEnabled
                          ? 'Active \u2014 traffic routed via SOCKS5'
                          : 'Disabled',
                      style: GoogleFonts.inter(
                          color: widget.proxyEnabled ? _accent : AppTheme.textSecondary,
                          fontSize: 12)),
                ],
              ),
            ),
            Switch.adaptive(
              value: widget.proxyEnabled,
              onChanged: (v) => widget.onProxyEnabledChanged(v),
              activeThumbColor: _accent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProxyFields() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _field(
            controller: widget.proxyHostController,
            hint: '127.0.0.1',
            label: 'Proxy Host',
            icon: Icons.router_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: _field(
            controller: widget.proxyPortController,
            hint: '10808',
            label: 'Port',
            icon: Icons.electrical_services_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkerField() {
    return _field(
      controller: widget.workerRelayController,
      hint: 'my-relay.username.workers.dev',
      label: 'Worker Domain (optional)',
      icon: Icons.cloud_queue_rounded,
    );
  }

  Widget _buildWorkerHelp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _workerHelpExpanded = !_workerHelpExpanded),
          child: Row(
            children: [
              Icon(
                _workerHelpExpanded
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                size: 16, color: _accent,
              ),
              const SizedBox(width: 4),
              Text(
                'How to deploy a CF Worker relay (free)',
                style: GoogleFonts.inter(
                    color: _accent, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        if (_workerHelpExpanded) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.surfaceVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1. Go to dash.cloudflare.com \u2192 Workers & Pages\n'
                  '2. Create Worker \u2192 paste this script:\n',
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: 11, height: 1.5),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(const ClipboardData(text: _workerScript));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Script copied!', style: GoogleFonts.inter()),
                        backgroundColor: _accent,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        Text(
                          _workerScript,
                          style: GoogleFonts.firaCode(
                              color: AppTheme.textSecondary, fontSize: 10, height: 1.4),
                        ),
                        Positioned(
                          top: 0, right: 0,
                          child: Icon(Icons.copy_rounded,
                              size: 14, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '3. Deploy \u2192 copy domain (e.g. my-relay.user.workers.dev)\n'
                  '4. Paste domain above \u2192 Save\n\n'
                  'App auto-connects: wss://domain/?r=relay_url\n'
                  'GFW sees: connection to *.workers.dev (CF CDN)',
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: 11, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Shared helpers ──────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Text(text.toUpperCase(),
        style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11,
            fontWeight: FontWeight.w700, letterSpacing: 0.8));
  }

  Widget _hint(String text) {
    return Row(children: [
      Icon(Icons.info_outline_rounded, size: 13, color: AppTheme.textSecondary),
      const SizedBox(width: 6),
      Expanded(
        child: Text(text,
            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
      ),
    ]);
  }

  Widget _field({required TextEditingController controller, required String hint,
      required String label, required IconData icon}) {
    return TextField(
      controller: controller,
      style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        labelStyle: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 18),
        filled: true,
        fillColor: AppTheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
