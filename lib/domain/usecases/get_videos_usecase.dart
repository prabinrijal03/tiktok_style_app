import 'package:injectable/injectable.dart';
import '../entities/video/video.dart';
import '../repositories/video_repository.dart';

@injectable
class GetVideosUseCase {
  final VideoRepository repository;

  GetVideosUseCase(this.repository);

  Future<List<Video>> execute() {
    return repository.getVideos();
  }

  Future<List<Video>> executeLocalOnly() {
    return repository.getLocalVideos();
  }

  Future<List<Video>> executeRemoteOnly() {
    return repository.getRemoteVideos();
  }
}

