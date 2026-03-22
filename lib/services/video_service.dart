import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'media_validator.dart';

const int _maxVideoNoteBytes = 15 * 1024 * 1024; // 15 MB

class VideoService {
  static final VideoService _instance = VideoService._();
  factory VideoService() => _instance;
  VideoService._();

  /// Pick a video file and return an encoded video_note payload, or null.
  Future<String?> pickAndCreatePayload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return null;

    final check = MediaValidator.validateVideo(bytes);
    if (!check.isValid) {
      debugPrint('[VideoService] Rejected: ${check.reason}');
      return null;
    }

    if (bytes.length > _maxVideoNoteBytes) {
      debugPrint('[VideoService] Video too large: ${bytes.length}');
      return null;
    }

    final b64 = base64Encode(bytes);
    return jsonEncode({
      't': 'video_note',
      'd': b64,
      'n': file.name,
      'sz': bytes.length,
    });
  }

  /// Write video bytes to a temp file for playback.
  static Future<String> writeTempVideo(Uint8List data) async {
    final dir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/pulse_vid_$ts.mp4');
    await file.writeAsBytes(data);
    return file.path;
  }
}
