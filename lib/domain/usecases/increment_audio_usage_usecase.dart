import 'package:injectable/injectable.dart';
import '../repositories/audio_repository.dart';

@injectable
class IncrementAudioUsageUseCase {
  final AudioRepository repository;

  IncrementAudioUsageUseCase(this.repository);

  Future<void> execute(String id) {
    return repository.incrementUsageCount(id);
  }
}

