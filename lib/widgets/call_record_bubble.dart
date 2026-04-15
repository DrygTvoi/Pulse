import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/l10n_ext.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';

/// Try to parse a call record JSON payload.
/// Returns the decoded map or null if this is not a call record.
Map<String, dynamic>? tryParseCallRecord(String text) {
  if (!text.startsWith('{')) return null;
  try {
    final m = jsonDecode(text) as Map<String, dynamic>;
    if (m['t'] == 'call') return m;
  } catch (_) {}
  return null;
}

/// Formats a DateTime as HH:MM.
String fmtCallTime(DateTime t) {
  return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

/// Renders a WhatsApp-style call history row — no bubble, centered.
class CallRecordBubble extends StatelessWidget {
  final String message;
  final DateTime timestamp;
  final bool isMe;
  final String? contactName;

  const CallRecordBubble({
    super.key,
    required this.message,
    required this.timestamp,
    required this.isMe,
    this.contactName,
  });

  @override
  Widget build(BuildContext context) {
    final record = tryParseCallRecord(message);
    if (record == null) return const SizedBox.shrink();

    final outgoing = record['outgoing'] as bool? ?? true;
    final connected = record['connected'] as bool? ?? false;
    final dur = record['duration'] as int? ?? 0;

    final IconData icon;
    final Color iconColor;
    final String label;

    if (!connected && !outgoing) {
      icon = Icons.call_missed_rounded;
      iconColor = Colors.redAccent;
      label = context.l10n.callMissedCall;
    } else if (outgoing) {
      icon = Icons.call_made_rounded;
      iconColor = connected ? Colors.green : Colors.grey;
      label = context.l10n.callOutgoingCall;
    } else {
      icon = Icons.call_received_rounded;
      iconColor = Colors.green;
      label = context.l10n.callIncomingCall;
    }

    final durationStr = connected && dur > 0
        ? ' \u00b7 ${dur ~/ 60}:${(dur % 60).toString().padLeft(2, '0')}'
        : '';

    final timeStr = fmtCallTime(timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacing4, horizontal: DesignTokens.spacing16),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: DesignTokens.iconSm),
            const SizedBox(width: 5),
            Text(
              '$label$durationStr',
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontSize: DesignTokens.fontBody,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: DesignTokens.spacing8),
            Text(
              timeStr,
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary.withValues(alpha: DesignTokens.opacityHeavy),
                fontSize: DesignTokens.fontSm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
