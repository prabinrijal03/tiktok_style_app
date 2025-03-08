import 'dart:io';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import 'package:uuid/uuid.dart';

import '../models/local_video_model/local_video_model.dart';
import '../models/video_model/video_model.dart';

abstract class LocalVideoDataSource {
  Future<List<VideoModel>> getVideos();
  Future<VideoModel> saveVideo({
    required File videoFile,
    required File thumbnailFile,
    required String description,
    String? audioName,
    String? audioId,
  });
  Future<void> likeVideo(String videoId);
  Future<void> deleteVideo(String videoId);
}

@LazySingleton(as: LocalVideoDataSource)
class LocalVideoDataSourceImpl implements LocalVideoDataSource {
  final Box<LocalVideoModel> _videosBox;
  
  LocalVideoDataSourceImpl(this._videosBox);
  
  @override
  Future<List<VideoModel>> getVideos() async {
    final localVideos = _videosBox.values.toList();
    
    localVideos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return localVideos.map((localVideo) => VideoModel(
      id: localVideo.id,
      videoUrl: localVideo.videoPath,
      thumbnailUrl: localVideo.thumbnailPath,
      description: localVideo.description,
      username: localVideo.username,
      audioName: localVideo.audioName,
      audioId: localVideo.audioId,
      likes: localVideo.likes,
      comments: localVideo.comments,
      shares: localVideo.shares,
      isLiked: localVideo.isLiked,
      isLocalFile: true,
    )).toList();
  }
  
  @override
  Future<VideoModel> saveVideo({
    required File videoFile,
    required File thumbnailFile,
    required String description,
    String? audioName,
    String? audioId,
  }) async {
    final uuid = const Uuid().v4();
    
    final localVideo = LocalVideoModel(
      id: uuid,
      videoPath: videoFile.path,
      thumbnailPath: thumbnailFile.path,
      description: description,
      username: 'current_user',
      audioName: audioName ?? 'Original Sound',
      audioId: audioId,
    );
    
    await _videosBox.put(uuid, localVideo);
    
    return VideoModel(
      id: localVideo.id,
      videoUrl: localVideo.videoPath,
      thumbnailUrl: localVideo.thumbnailPath,
      description: localVideo.description,
      username: localVideo.username,
      audioName: localVideo.audioName,
      audioId: localVideo.audioId,
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
      localVideo.likes = localVideo.isLiked ? localVideo.likes + 1 : localVideo.likes - 1;
      await localVideo.save();
    }
  }
  
  @override
  Future<void> deleteVideo(String videoId) async {
    await _videosBox.delete(videoId);
  }
}

