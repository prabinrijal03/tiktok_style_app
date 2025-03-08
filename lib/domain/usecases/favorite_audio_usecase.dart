import 'package:injectable/injectable.dart';

import '../repositories/audio_repository.dart';

@injectable
class FavoriteAudioUseCase {
  final AudioRepository repository;

  FavoriteAudioUseCase(this.repository);

  Future<void> execute(String id) {
    return repository.favoriteAudio(id);
  }
}

