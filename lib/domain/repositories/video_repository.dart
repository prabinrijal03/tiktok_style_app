import 'dart:io';

import '../entities/video/video.dart';


abstract class VideoRepository {
  Future<List<Video>> getVideos();
  Future<List<Video>> getLocalVideos();
  Future<List<Video>> getRemoteVideos();
  Future<Video> uploadVideo({
    required File videoFile,
    required File thumbnailFile,
    required String description,
    String? audioName,
    String? audioId,
  });
  Future<void> likeVideo(String videoId);
  Future<void> deleteVideo(String videoId);
}

