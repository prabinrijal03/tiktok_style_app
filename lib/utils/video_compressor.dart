import 'dart:io';
import 'package:video_compress/video_compress.dart';

class VideoCompressor {
  static final VideoCompressor _instance = VideoCompressor._internal();
  factory VideoCompressor() => _instance;
  VideoCompressor._internal();

  Future<bool> shouldCompressVideo(File videoFile, {int maxSizeMB = 50}) async {
    try {
      final fileSize = await videoFile.length();
      final fileSizeMB = fileSize / (1024 * 1024);
      return fileSizeMB > maxSizeMB;
    } catch (e) {
      print('Error checking video size: $e');
      return true;
    }
  }

  Future<Map<String, dynamic>> getVideoInfo(File videoFile) async {
    try {
      final mediaInfo = await VideoCompress.getMediaInfo(videoFile.path);
      return {
        'width': mediaInfo.width,
        'height': mediaInfo.height,
        'duration': mediaInfo.duration,
        'filesize': mediaInfo.filesize,
        'path': mediaInfo.path,
      };
    } catch (e) {
      print('Error getting video info: $e');
      return {};
    }
  }

  Future<File?> compressVideo(
    File videoFile, {
    Function(double)? onProgress,
  }) async {
    try {
      final fileSize = await videoFile.length();
      final fileSizeMB = fileSize / (1024 * 1024);

      VideoQuality quality;
      if (fileSizeMB > 100) {
        quality = VideoQuality.LowQuality;
      } else if (fileSizeMB > 50) {
        quality = VideoQuality.MediumQuality;
      } else {
        quality = VideoQuality.DefaultQuality;
      }

      final subscription =
          VideoCompress.compressProgress$.subscribe((progress) {
        if (onProgress != null) {
          onProgress(progress);
        }
      });

      final mediaInfo = await VideoCompress.compressVideo(
        videoFile.path,
        quality: quality,
        deleteOrigin: false,
        includeAudio: true,
      );

      subscription.unsubscribe;

      if (mediaInfo != null && mediaInfo.file != null) {
        return mediaInfo.file;
      }
      return null;
    } catch (e) {
      print('Error compressing video: $e');
      await VideoCompress.cancelCompression();
      return null;
    }
  }

  Future<void> cancelCompression() async {
    await VideoCompress.cancelCompression();
  }

  Future<void> deleteAllCache() async {
    await VideoCompress.deleteAllCache();
  }

  Future<File?> getThumbnailFromVideo(File videoFile) async {
    try {
      final thumbnailFile = await VideoCompress.getFileThumbnail(
        videoFile.path,
        quality: 50,
        position: -1,
      );
      return thumbnailFile;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }
}
