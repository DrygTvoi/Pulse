import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../controllers/chat_controller.dart';
import '../models/contact.dart';
import '../models/message.dart';
import '../services/media_service.dart';
import '../theme/app_theme.dart';
import 'image_viewer_screen.dart';

class MediaGalleryScreen extends StatelessWidget {
  final Contact contact;
  const MediaGalleryScreen({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    final messages =
        context.watch<ChatController>().getRoomForContact(contact.id)?.messages ?? [];

    final images = <Message>[];
    final files = <Message>[];
    for (final m in messages) {
      final p = MediaService.parse(m.encryptedPayload);
      if (p == null) continue;
      if (p.isImage) {
        images.add(m);
      } else if (!p.isVoice) {
        files.add(m);
      }
    }
    // Newest first
    images.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    files.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.surface,
          elevation: 0,
          iconTheme: IconThemeData(color: AppTheme.textSecondary),
          title: Text('Media',
              style: GoogleFonts.inter(
                  color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
          bottom: TabBar(
            indicatorColor: AppTheme.primary,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: [
              Tab(text: 'Photos (${images.length})'),
              Tab(text: 'Files (${files.length})'),
            ],
          ),
        ),
        body: TabBarView(children: [
          _PhotosGrid(images: images),
          _FilesList(files: files),
        ]),
      ),
    );
  }
}

// ─── Photos grid ──────────────────────────────────────────────────────────────

class _PhotosGrid extends StatelessWidget {
  final List<Message> images;
  const _PhotosGrid({required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.photo_library_outlined,
              size: 56, color: AppTheme.textSecondary.withValues(alpha: 0.25)),
          const SizedBox(height: 14),
          Text('No photos yet',
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14)),
        ]),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: images.length,
      itemBuilder: (ctx, i) {
        final media = MediaService.parse(images[i].encryptedPayload)!;
        return GestureDetector(
          onTap: () => Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => ImageViewerScreen(
                imageData: media.data,
                name: media.name,
              ),
            ),
          ),
          child: Hero(
            tag: 'gallery_img_${images[i].id}',
            child: Image.memory(media.data, fit: BoxFit.cover),
          ),
        );
      },
    );
  }
}

// ─── Files list ───────────────────────────────────────────────────────────────

class _FilesList extends StatelessWidget {
  final List<Message> files;
  const _FilesList({required this.files});

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.folder_open_rounded,
              size: 56, color: AppTheme.textSecondary.withValues(alpha: 0.25)),
          const SizedBox(height: 14),
          Text('No files yet',
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14)),
        ]),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: files.length,
      separatorBuilder: (context, index) =>
          Divider(color: AppTheme.surfaceVariant, height: 1, indent: 70),
      itemBuilder: (ctx, i) {
        final msg = files[i];
        final media = MediaService.parse(msg.encryptedPayload)!;
        final ext = media.name.contains('.')
            ? media.name.split('.').last.toUpperCase()
            : 'FILE';
        return ListTile(
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.insert_drive_file_rounded,
                    color: AppTheme.primary, size: 18),
                if (ext.isNotEmpty)
                  Text(
                    ext.length > 4 ? ext.substring(0, 4) : ext,
                    style: GoogleFonts.inter(
                        color: AppTheme.primary,
                        fontSize: 8,
                        fontWeight: FontWeight.w700),
                  ),
              ],
            ),
          ),
          title: Text(
            media.name,
            style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${media.sizeLabel}  •  ${_fmtDate(msg.timestamp)}',
            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12),
          ),
          trailing: IconButton(
            icon: Icon(Icons.download_rounded, color: AppTheme.textSecondary),
            tooltip: 'Save',
            onPressed: () => _saveFile(ctx, media),
          ),
        );
      },
    );
  }

  String _fmtDate(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}/${dt.month}/${dt.year % 100}';
  }

  Future<void> _saveFile(BuildContext ctx, MediaPayload media) async {
    try {
      final dir = await getDownloadsDirectory() ?? await getTemporaryDirectory();
      final path = '${dir.path}/${media.name}';
      await File(path).writeAsBytes(media.data);
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text('Saved to Downloads/${media.name}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('Failed to save file')),
        );
      }
    }
  }
}
