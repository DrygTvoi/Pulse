// Settings — Developer section: adapter toggles for testing.
// Unlocked by tapping the version row 7 times in About.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
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
  static const _adapters = [
    ('Nostr',    Icons.flash_on_outlined,    'Nostr relays (wss://)'),
    ('Firebase', Icons.cloud_outlined,       'Firebase Realtime DB'),
    ('Session',  Icons.security_outlined,    'Session Network'),
    ('Pulse',    Icons.hub_outlined,         'Pulse self-hosted relay'),
    ('LAN',      Icons.lan_outlined,         'Local network (UDP/TCP)'),
  ];

  final Map<String, bool> _enabled = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, bool>{};
    for (final (name, _, _) in _adapters) {
      map[name] = prefs.getBool('$_kAdapterKeyPrefix$name') ?? true;
    }
    if (mounted) setState(() { _enabled.addAll(map); _loaded = true; });
  }

  Future<void> _toggle(String name, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_kAdapterKeyPrefix$name', value);
    setState(() => _enabled[name] = value);
  }

  Future<void> _disableAll() async {
    for (final (name, _, _) in _adapters) {
      await _toggle(name, false);
    }
  }

  Future<void> _enableAll() async {
    for (final (name, _, _) in _adapters) {
      await _toggle(name, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        settingsSectionDivider('Developer'),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'Adapter channels — disable to test specific transports.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ),
        for (final (name, icon, subtitle) in _adapters) ...[
          settingsRow(
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
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.check_box_outlined, size: 16),
                label: const Text('Enable all'),
                onPressed: _enableAll,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.5)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.check_box_outline_blank, size: 16),
                label: const Text('Disable all'),
                onPressed: _disableAll,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '⚠ Changes take effect on next send. Restart app to apply to incoming.',
          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
