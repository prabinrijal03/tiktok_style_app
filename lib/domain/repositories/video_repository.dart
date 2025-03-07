import 'dart:io';

import 'package:tiktok_style_app/domain/entities/video_entity.dart';

abstract class VideoRepository {
  Future<List<VideoEntity>> getVideos();
  Future<List<VideoEntity>> getLocalVideos();
  Future<List<VideoEntity>> getRemoteVideos();
  Future<VideoEntity> uploadVideo({
    required File videoFile,
    required File thumbnailFile,
    required String description,
    String? audioName,
  });
  Future<void> likeVideo(String videoId);
  Future<void> deleteVideo(String videoId);
}

