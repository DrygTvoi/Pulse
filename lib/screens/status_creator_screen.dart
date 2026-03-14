import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/user_status.dart';
import '../services/status_service.dart';
import '../services/media_service.dart';
import '../controllers/chat_controller.dart';
import '../theme/app_theme.dart';

class StatusCreatorScreen extends StatefulWidget {
  const StatusCreatorScreen({super.key});

  @override
  State<StatusCreatorScreen> createState() => _StatusCreatorScreenState();
}

class _StatusCreatorScreenState extends State<StatusCreatorScreen> {
  final TextEditingController _textCtrl = TextEditingController();
  String? _mediaPayload; // base64-encoded photo
  bool _publishing = false;

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final result = await MediaService().pickImage();
      if (result == null) return;
      // Extract the raw base64 data from the media payload JSON
      final decoded = result.payload;
      String? base64data;
      try {
        final map = jsonDecode(decoded) as Map<String, dynamic>;
        base64data = map['d'] as String?;
      } catch (_) {
        base64data = decoded;
      }
      setState(() => _mediaPayload = base64data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick photo: $e'),
              backgroundColor: AppTheme.error),
        );
      }
    }
  }

  Future<void> _publish() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter some text for your status.',
              style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _publishing = true);
    try {
      final status = UserStatus.create(
        id: const Uuid().v4(),
        text: text,
        mediaPayload: _mediaPayload,
      );
      await StatusService.instance.setOwnStatus(status);
      await ChatController().broadcastStatus(status);
      if (mounted) Navigator.pop(context, true); // true = published
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to publish: $e'),
              backgroundColor: AppTheme.error),
        );
        setState(() => _publishing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: AppTheme.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('New Status',
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        actions: [
          _publishing
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : TextButton(
                  onPressed: _publish,
                  child: Text('Publish',
                      style: GoogleFonts.inter(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Text input
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _textCtrl,
                maxLines: 5,
                maxLength: 280,
                style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'What\'s on your mind?',
                  hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary),
                  contentPadding: const EdgeInsets.all(16),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  counterStyle: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Photo button
            OutlinedButton.icon(
              icon: Icon(
                _mediaPayload != null
                    ? Icons.check_circle_rounded
                    : Icons.add_photo_alternate_rounded,
                color: AppTheme.primary,
                size: 20,
              ),
              label: Text(
                _mediaPayload != null ? 'Photo attached' : 'Attach photo (optional)',
                style: GoogleFonts.inter(color: AppTheme.primary, fontWeight: FontWeight.w500),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _pickPhoto,
            ),

            // Photo preview
            if (_mediaPayload != null) ...[
              const SizedBox(height: 16),
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Builder(builder: (_) {
                      try {
                        final bytes = base64Decode(_mediaPayload!);
                        return Image.memory(bytes, height: 200, width: double.infinity, fit: BoxFit.cover);
                      } catch (_) {
                        return Container(height: 200, color: AppTheme.surface);
                      }
                    }),
                  ),
                  Positioned(
                    top: 8, right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _mediaPayload = null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54, shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // Status duration info
            Row(children: [
              Icon(Icons.access_time_rounded, size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 6),
              Text('Status expires in 24 hours',
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: 12)),
            ]),
          ],
        ),
      ),
    );
  }
}
