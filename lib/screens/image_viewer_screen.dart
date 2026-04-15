import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_ext.dart';

/// Full-screen image viewer with pinch-to-zoom and save to Downloads.
class ImageViewerScreen extends StatelessWidget {
  final Uint8List imageData;
  final String name;

  const ImageViewerScreen({
    super.key,
    required this.imageData,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.7),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          name,
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            tooltip: context.l10n.imageSaveToDownloads,
            onPressed: () => _saveImage(context),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          maxScale: 6.0,
          child: Image.memory(
            imageData,
            fit: BoxFit.contain,
            gaplessPlayback: true,
          ),
        ),
      ),
    );
  }

  Future<void> _saveImage(BuildContext context) async {
    try {
      final dir = await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      final ext = name.contains('.') ? '' : '.jpg';
      final file = File('${dir.path}/${ts}_$name$ext');
      await file.writeAsBytes(imageData);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            context.l10n.imageSavedToPath(dir.path),
            style: GoogleFonts.inter(fontSize: 13),
          ),
          backgroundColor: AppTheme.surfaceVariant,
          duration: const Duration(seconds: 3),
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.imageSaveFailed(e), style: GoogleFonts.inter(fontSize: 13)),
          backgroundColor: Colors.red.shade900,
        ));
      }
    }
  }
}
