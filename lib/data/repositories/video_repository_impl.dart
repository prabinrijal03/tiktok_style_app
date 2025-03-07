import 'dart:io';

import 'package:tiktok_style_app/data/models/video_model/video_model.dart';
import 'package:tiktok_style_app/domain/entities/video_entity.dart';

import '../../domain/repositories/video_repository.dart';
import '../data_sources/local_data_source.dart';
import '../data_sources/remote_data_source.dart';



class VideoRepositoryImpl implements VideoRepository {
  final VideoRemoteDataSource remoteDataSource;
  final LocalVideoDataSource localDataSource;

  VideoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<VideoEntity>> getVideos() async {
    // Get both local and remote videos
    final localVideos = await localDataSource.getVideos();
    final remoteVideos = await remoteDataSource.getVideos();
    
    // Combine and return (local videos first)
    return [
      ...localVideos.map((model) => model.toEntity()),
      ...remoteVideos.map((model) => model.toEntity()),
    ];
  }
  
  @override
  Future<List<VideoEntity>> getLocalVideos() async {
    final localVideos = await localDataSource.getVideos();
    return localVideos.map((model) => model.toEntity()).toList();
  }
  
  @override
  Future<List<VideoEntity>> getRemoteVideos() async {
    final remoteVideos = await remoteDataSource.getVideos();
    return remoteVideos.map((model) => model.toEntity()).toList();
  }

  @override
  Future<VideoEntity> uploadVideo({
    required File videoFile,
    required File thumbnailFile,
    required String description,
    String? audioName,
  }) async {
    // Save video to local storage
    final videoModel = await localDataSource.saveVideo(
      videoFile: videoFile,
      thumbnailFile: thumbnailFile,
      description: description,
      audioName: audioName,
    );
    
    return videoModel.toEntity();
  }

  @override
  Future<void> likeVideo(String videoId) async {
    try {
      // Try to like local video first
      await localDataSource.likeVideo(videoId);
    } catch (e) {
      // If not found locally, try remote
      await remoteDataSource.likeVideo(videoId);
    }
  }
  
  @override
  Future<void> deleteVideo(String videoId) async {
    await localDataSource.deleteVideo(videoId);
  }
}

