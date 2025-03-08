import 'package:injectable/injectable.dart';
import '../entities/audio/audio.dart';
import '../repositories/audio_repository.dart';

@injectable
class GetAudiosUseCase {
  final AudioRepository repository;

  GetAudiosUseCase(this.repository);

  Future<List<Audio>> execute() {
    return repository.getAudios();
  }
}

