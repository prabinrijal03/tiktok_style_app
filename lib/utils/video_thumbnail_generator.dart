import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class VideoThumbnailGenerator {
  static Future<File?> generateThumbnail({
    required File videoFile,
    Duration position = const Duration(seconds: 1),
  }) async {
    try {
      final controller = VideoPlayerController.file(videoFile);
      await controller.initialize();

      await controller.seekTo(position);

      await Future.delayed(const Duration(milliseconds: 100));

      final tempKey = GlobalKey();
      // ignore: unused_local_variable
      final tempWidget = RepaintBoundary(
        key: tempKey,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      );

      final boundary =
          tempKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      controller.dispose();

      if (byteData != null) {
        final tempDir = await getTemporaryDirectory();
        final thumbnailFile = File(
            '${tempDir.path}/thumbnail_${DateTime.now().millisecondsSinceEpoch}.png');
        await thumbnailFile.writeAsBytes(byteData.buffer.asUint8List());
        return thumbnailFile;
      }

      return null;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }

  static Future<File?> generateSimpleThumbnail(File videoFile) async {
    try {
      final controller = VideoPlayerController.file(videoFile);
      await controller.initialize();

      final position = controller.value.duration > const Duration(seconds: 2)
          ? const Duration(seconds: 1)
          : Duration(
              milliseconds: controller.value.duration.inMilliseconds ~/ 2);

      await controller.seekTo(position);

      await Future.delayed(const Duration(milliseconds: 100));

      final tempDir = await getTemporaryDirectory();
      final thumbnailFile = File(
          '${tempDir.path}/thumbnail_${DateTime.now().millisecondsSinceEpoch}.png');

      final placeholderBytes = await _createPlaceholderImage(
        width: controller.value.size.width.toInt(),
        height: controller.value.size.height.toInt(),
      );

      await thumbnailFile.writeAsBytes(placeholderBytes);

      controller.dispose();

      return thumbnailFile;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }

  static Future<Uint8List> _createPlaceholderImage({
    required int width,
    required int height,
  }) async {
    return Uint8List.fromList(List.generate(width * height * 4, (index) => 0));
  }
}
