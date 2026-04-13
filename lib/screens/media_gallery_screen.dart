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
import '../l10n/l10n_ext.dart';
import 'image_viewer_screen.dart';

/// Pre-parsed media item: message + its already-decoded MediaPayload.
typedef _MediaItem = ({Message msg, MediaPayload media});

class MediaGalleryScreen extends StatefulWidget {
  final Contact contact;
  const MediaGalleryScreen({super.key, required this.contact});

  @override
  State<MediaGalleryScreen> createState() => _MediaGalleryScreenState();
}

class _MediaGalleryScreenState extends State<MediaGalleryScreen> {
  List<_MediaItem> _images = const [];
  List<_MediaItem> _files = const [];
  int _lastMessageCount = -1;

  void _parseMedia(List<Message> messages) {
    final images = <_MediaItem>[];
    final files = <_MediaItem>[];
    for (final m in messages) {
      final p = MediaService.parse(m.encryptedPayload);
      if (p == null) continue;
      if (p.isImage) {
        images.add((msg: m, media: p));
      } else if (!p.isVoice) {
        files.add((msg: m, media: p));
      }
    }
    // Newest first
    images.sort((a, b) => b.msg.timestamp.compareTo(a.msg.timestamp));
    files.sort((a, b) => b.msg.timestamp.compareTo(a.msg.timestamp));
    _images = images;
    _files = files;
  }

  @override
  Widget build(BuildContext context) {
    // Select on message count so we only re-parse when messages change.
    final msgCount = context.select<ChatController, int>(
        (c) => c.getRoomForContact(widget.contact.id)?.messages.length ?? 0);

    if (msgCount != _lastMessageCount) {
      _lastMessageCount = msgCount;
      final messages = context
              .read<ChatController>()
              .getRoomForContact(widget.contact.id)
              ?.messages ??
          [];
      _parseMedia(messages);
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.surface,
          elevation: 0,
          iconTheme: IconThemeData(color: AppTheme.textSecondary),
          title: Text(context.l10n.mediaTitle,
              style: GoogleFonts.inter(
                  color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
          bottom: TabBar(
            indicatorColor: AppTheme.primary,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: [
              Tab(text: context.l10n.mediaPhotosTab(_images.length)),
              Tab(text: context.l10n.mediaFilesTab(_files.length)),
            ],
          ),
        ),
        body: TabBarView(children: [
          _PhotosGrid(images: _images),
          _FilesList(files: _files),
        ]),
      ),
    );
  }
}

// ─── Photos grid ──────────────────────────────────────────────────────────────

class _PhotosGrid extends StatelessWidget {
  final List<_MediaItem> images;
  const _PhotosGrid({required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.photo_library_outlined,
              size: 56, color: AppTheme.textSecondary.withValues(alpha: 0.25)),
          const SizedBox(height: 14),
          Text(context.l10n.mediaNoPhotos,
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
        final item = images[i];
        return GestureDetector(
          onTap: () => Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => ImageViewerScreen(
                imageData: item.media.data,
                name: item.media.name,
              ),
            ),
          ),
          child: Hero(
            tag: 'gallery_img_${item.msg.id}',
            child: Image.memory(item.media.data, fit: BoxFit.cover, cacheWidth: 300),
          ),
        );
      },
    );
  }
}

// ─── Files list ───────────────────────────────────────────────────────────────

class _FilesList extends StatelessWidget {
  final List<_MediaItem> files;
  const _FilesList({required this.files});

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.folder_open_rounded,
              size: 56, color: AppTheme.textSecondary.withValues(alpha: 0.25)),
          const SizedBox(height: 14),
          Text(context.l10n.mediaNoFiles,
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
        final item = files[i];
        final media = item.media;
        final ext = media.name.contains('.')
            ? media.name.split('.').last.toUpperCase()
            : ctx.l10n.mediaFileLabel;
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
            '${media.sizeLabel}  •  ${_fmtDate(item.msg.timestamp)}',
            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12),
          ),
          trailing: IconButton(
            icon: Icon(Icons.download_rounded, color: AppTheme.textSecondary),
            tooltip: context.l10n.save,
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
            content: Text(ctx.l10n.mediaSavedToDownloads(media.name)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text(ctx.l10n.mediaFailedToSave)),
        );
      }
    }
  }
}
