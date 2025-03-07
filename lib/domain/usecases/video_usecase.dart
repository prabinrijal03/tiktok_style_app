import 'dart:io';
import 'package:tiktok_style_app/domain/repositories/video_repository.dart';
import '../entities/video_entity.dart';

class GetVideosUseCase {
  final VideoRepository repository;

  GetVideosUseCase(this.repository);

  Future<List<VideoEntity>> execute() {
    return repository.getVideos();
  }
  
  Future<List<VideoEntity>> executeLocalOnly() {
    return repository.getLocalVideos();
  }
  
  Future<List<VideoEntity>> executeRemoteOnly() {
    return repository.getRemoteVideos();
  }
}

class LikeVideoUseCase {
  final VideoRepository repository;

  LikeVideoUseCase(this.repository);

  Future<void> execute(String videoId) {
    return repository.likeVideo(videoId);
  }
}

class UploadVideoUseCase {
  final VideoRepository repository;

  UploadVideoUseCase(this.repository);

  Future<VideoEntity> execute({
    required File videoFile,
    required File thumbnailFile,
    required String description,
    String? audioName,
  }) {
    return repository.uploadVideo(
      videoFile: videoFile,
      thumbnailFile: thumbnailFile,
      description: description,
      audioName: audioName,
    );
  }
}
class DeleteVideoUseCase {
  final VideoRepository repository;

  DeleteVideoUseCase(this.repository);

  Future<void> execute(String videoId) {
    return repository.deleteVideo(videoId);
  }
}
