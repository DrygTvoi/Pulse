// Settings — Developer section: adapter toggles for testing.
// Unlocked by tapping the version row 7 times in About.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/l10n_ext.dart';
import '../../theme/app_theme.dart';
import '../../theme/design_tokens.dart';
import 'settings_widgets.dart';

/// SharedPreferences key prefix for per-adapter dev toggles.
/// e.g. 'dev_adapter_Nostr' = true (enabled) / false (disabled).
const _kAdapterKeyPrefix = 'dev_adapter_';

/// Returns true if [provider] is currently enabled for sending/receiving.
/// Defaults to true (all adapters on by default).
Future<bool> isAdapterEnabled(String provider) async {
  final prefs = await SharedPreferences.getInstance();
  // If dev mode is off, all adapters are enabled.
  if (!(prefs.getBool('dev_mode_enabled') ?? false)) return true;
  return prefs.getBool('$_kAdapterKeyPrefix$provider') ?? true;
}

/// Synchronous version for hot-path use (reads cached prefs).
/// Call after await SharedPreferences.getInstance() is already done.
bool isAdapterEnabledSync(SharedPreferences prefs, String provider) {
  if (!(prefs.getBool('dev_mode_enabled') ?? false)) return true;
  return prefs.getBool('$_kAdapterKeyPrefix$provider') ?? true;
}

class DeveloperSection extends StatefulWidget {
  const DeveloperSection({super.key});

  @override
  State<DeveloperSection> createState() => _DeveloperSectionState();
}

class _DeveloperSectionState extends State<DeveloperSection> {
  static const _adapterMeta = [
    ('Nostr',    Icons.flash_on_outlined),
    ('Firebase', Icons.cloud_outlined),
    ('Session',  Icons.security_outlined),
    ('Pulse',    Icons.hub_outlined),
    ('LAN',      Icons.lan_outlined),
  ];

  List<(String, IconData, String)> _adapters(BuildContext context) => [
    ('Nostr',    Icons.flash_on_outlined,    context.l10n.devNostrRelays),
    ('Firebase', Icons.cloud_outlined,       context.l10n.devFirebaseDb),
    ('Session',  Icons.security_outlined,    context.l10n.devSessionNetwork),
    ('Pulse',    Icons.hub_outlined,         context.l10n.devPulseRelay),
    ('LAN',      Icons.lan_outlined,         context.l10n.devLanNetwork),
  ];

  final Map<String, bool> _enabled = {};
  bool _forceRelay = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, bool>{};
    for (final (name, _) in _adapterMeta) {
      map[name] = prefs.getBool('$_kAdapterKeyPrefix$name') ?? true;
    }
    final forceRelay = prefs.getBool('dev_force_relay') ?? false;
    if (mounted) setState(() { _enabled.addAll(map); _forceRelay = forceRelay; _loaded = true; });
  }

  Future<void> _toggle(String name, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_kAdapterKeyPrefix$name', value);
    setState(() => _enabled[name] = value);
  }

  Future<void> _disableAll() async {
    for (final (name, _) in _adapterMeta) {
      await _toggle(name, false);
    }
  }

  Future<void> _enableAll() async {
    for (final (name, _) in _adapterMeta) {
      await _toggle(name, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        settingsSectionDivider(context.l10n.devSectionDeveloper),
        const SizedBox(height: DesignTokens.spacing8),
        Padding(
          padding: const EdgeInsets.only(left: DesignTokens.spacing4, bottom: DesignTokens.spacing10),
          child: Text(
            context.l10n.devAdapterChannelsHint,
            style: TextStyle(fontSize: DesignTokens.fontBody, color: AppTheme.textSecondary),
          ),
        ),
        settingsGroup(children: [
          for (final (name, icon, subtitle) in _adapters(context))
            settingsGroupRow(
              icon: icon,
              iconColor: (_enabled[name] ?? true)
                  ? AppTheme.primary
                  : AppTheme.textSecondary,
              title: name,
              subtitle: subtitle,
              trailing: Switch.adaptive(
                value: _enabled[name] ?? true,
                activeThumbColor: AppTheme.primary,
                onChanged: (v) => _toggle(name, v),
              ),
            ),
        ]),
        const SizedBox(height: DesignTokens.spacing8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.check_box_outlined, size: DesignTokens.iconSm),
                label: Text(context.l10n.devEnableAll),
                onPressed: _enableAll,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.5)),
                ),
              ),
            ),
            const SizedBox(width: DesignTokens.spacing10),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.check_box_outline_blank, size: DesignTokens.iconSm),
                label: Text(context.l10n.devDisableAll),
                onPressed: _disableAll,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.spacing16),
        settingsSectionDivider(context.l10n.devSectionCalls),
        const SizedBox(height: DesignTokens.spacing8),
        settingsGroup(children: [
          settingsGroupRow(
            icon: Icons.cell_tower_rounded,
            iconColor: _forceRelay ? Colors.orange : AppTheme.textSecondary,
            title: context.l10n.devForceTurnRelay,
            subtitle: context.l10n.devForceTurnRelaySubtitle,
            trailing: Switch.adaptive(
              value: _forceRelay,
              activeThumbColor: Colors.orange,
              onChanged: (v) async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('dev_force_relay', v);
                setState(() => _forceRelay = v);
              },
            ),
          ),
        ]),
        const SizedBox(height: DesignTokens.spacing8),
        Text(
          context.l10n.devRestartWarning,
          style: TextStyle(fontSize: DesignTokens.fontSm, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
