import 'package:injectable/injectable.dart';

import '../entities/audio/audio.dart';
import '../repositories/audio_repository.dart';

@injectable
class GetAudioByIdUseCase {
  final AudioRepository repository;

  GetAudioByIdUseCase(this.repository);

  Future<Audio?> execute(String id) async {
    try {
      return await repository.getAudioById(id);
    } catch (e) {
      print('Error getting audio by ID: $e');
      return null;
    }
  }
}

