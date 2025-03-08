
import '../entities/audio/audio.dart';

abstract class AudioRepository {
  Future<List<Audio>> getAudios();
  Future<Audio?> getAudioById(String id);
  Future<void> favoriteAudio(String id);
  Future<void> incrementUsageCount(String id);
}

