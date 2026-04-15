// TURN Servers configuration screen — self-contained.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/l10n_ext.dart';
import '../../services/ice_server_config.dart';
import '../../theme/app_theme.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/turn_config_section.dart';

class TurnScreen extends StatefulWidget {
  const TurnScreen({super.key});

  @override
  State<TurnScreen> createState() => _TurnScreenState();
}

class _TurnScreenState extends State<TurnScreen> {
  List<String> _enabledPresets = ['openrelay'];
  final _turnUrlController = TextEditingController();
  final _turnUsernameController = TextEditingController();
  final _turnPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _turnUrlController.dispose();
    _turnUsernameController.dispose();
    _turnPasswordController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final presets = await IceServerConfig.loadEnabledPresets();
    final custom = await IceServerConfig.loadCustomTurn();
    if (!mounted) return;
    setState(() {
      _enabledPresets = presets;
      _turnUrlController.text = custom.url;
      _turnUsernameController.text = custom.username;
      _turnPasswordController.text = custom.password;
    });
  }

  Future<void> _save() async {
    final url = _turnUrlController.text.trim();
    if (url.isNotEmpty) {
      final validScheme = url.startsWith('turn:') || url.startsWith('turns:');
      if (!validScheme || url.length > 512) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.turnUrlValidation)),
          );
        }
        return;
      }
    }
    await IceServerConfig.saveEnabledPresets(_enabledPresets);
    await IceServerConfig.saveCustomTurn(
      url: url,
      username: _turnUsernameController.text.trim(),
      password: _turnPasswordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(context.l10n.settingsTurnServers,
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(DesignTokens.spacing16, DesignTokens.spacing16, DesignTokens.spacing16, DesignTokens.spacing40),
        children: [
          TurnConfigSection(
            enabledPresets: _enabledPresets,
            turnUrlController: _turnUrlController,
            turnUsernameController: _turnUsernameController,
            turnPasswordController: _turnPasswordController,
            onPresetsChanged: (presets) {
              setState(() => _enabledPresets = presets);
              _save();
            },
          ),
        ],
      ),
    );
  }
}
