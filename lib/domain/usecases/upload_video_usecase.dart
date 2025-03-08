import 'dart:io';
import 'package:injectable/injectable.dart';

import '../entities/video/video.dart';
import '../repositories/video_repository.dart';

@injectable
class UploadVideoUseCase {
  final VideoRepository repository;

  UploadVideoUseCase(this.repository);

  Future<Video> execute({
    required File videoFile,
    required File thumbnailFile,
    required String description,
    String? audioName,
    String? audioId,
  }) {
    return repository.uploadVideo(
      videoFile: videoFile,
      thumbnailFile: thumbnailFile,
      description: description,
      audioName: audioName,
      audioId: audioId,
    );
  }
}

