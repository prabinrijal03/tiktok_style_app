import 'package:injectable/injectable.dart';

import '../repositories/video_repository.dart';

@injectable
class DeleteVideoUseCase {
  final VideoRepository repository;

  DeleteVideoUseCase(this.repository);

  Future<void> execute(String videoId) {
    return repository.deleteVideo(videoId);
  }
}

