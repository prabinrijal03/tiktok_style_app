import 'package:injectable/injectable.dart';
import '../repositories/video_repository.dart';

@injectable
class LikeVideoUseCase {
  final VideoRepository repository;

  LikeVideoUseCase(this.repository);

  Future<void> execute(String videoId) {
    return repository.likeVideo(videoId);
  }
}

