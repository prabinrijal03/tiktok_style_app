import 'dart:io';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/local_video/local_video_model.dart';
import '../models/video_model/video_model.dart';

abstract class LocalVideoDataSource {
  Future<List<VideoModel>> getVideos();
  Future<VideoModel> saveVideo({
    required File videoFile,
    required File thumbnailFile,
    required String description,
    String? audioName,
  });
  Future<void> likeVideo(String videoId);
  Future<void> deleteVideo(String videoId);
}

class LocalVideoDataSourceImpl implements LocalVideoDataSource {
  final Box<LocalVideoModel> _videosBox;

  LocalVideoDataSourceImpl({required Box<LocalVideoModel> videosBox})
      : _videosBox = videosBox;

  @override
  Future<List<VideoModel>> getVideos() async {
    // Get all videos from the box and convert to VideoModel
    final localVideos = _videosBox.values.toList();

    // Sort by creation date (newest first)
    localVideos.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return localVideos
        .map((localVideo) => VideoModel(
              id: localVideo.id,
              videoUrl: localVideo.videoPath,
              thumbnailUrl: localVideo.thumbnailPath,
              description: localVideo.description,
              username: localVideo.username,
              audioName: localVideo.audioName,
              likes: localVideo.likes,
              comments: localVideo.comments,
              shares: localVideo.shares,
              isLiked: localVideo.isLiked,
              isLocalFile: true,
            ))
        .toList();
  }

  @override
  Future<VideoModel> saveVideo({
    required File videoFile,
    required File thumbnailFile,
    required String description,
    String? audioName,
  }) async {
    final uuid = const Uuid().v4();

    // Create a new LocalVideoModel
    final localVideo = LocalVideoModel(
      id: uuid,
      videoPath: videoFile.path,
      thumbnailPath: thumbnailFile.path,
      description: description,
      username: 'current_user',
      audioName: audioName ?? 'Original Sound',
    );

    // Save to Hive
    await _videosBox.put(uuid, localVideo);

    // Return as VideoModel
    return VideoModel(
      id: localVideo.id,
      videoUrl: localVideo.videoPath,
      thumbnailUrl: localVideo.thumbnailPath,
      description: localVideo.description,
      username: localVideo.username,
      audioName: localVideo.audioName,
      likes: localVideo.likes,
      comments: localVideo.comments,
      shares: localVideo.shares,
      isLiked: localVideo.isLiked,
      isLocalFile: true,
    );
  }

  @override
  Future<void> likeVideo(String videoId) async {
    final localVideo = _videosBox.get(videoId);
    if (localVideo != null) {
      localVideo.isLiked = !localVideo.isLiked;
      localVideo.likes =
          localVideo.isLiked ? localVideo.likes + 1 : localVideo.likes - 1;
      await localVideo.save();
    }
  }

  @override
  Future<void> deleteVideo(String videoId) async {
    await _videosBox.delete(videoId);
  }
}
