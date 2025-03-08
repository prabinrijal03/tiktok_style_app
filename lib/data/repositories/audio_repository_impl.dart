import 'package:injectable/injectable.dart';

import '../../domain/entities/audio/audio.dart';
import '../../domain/repositories/audio_repository.dart';
import '../datasources/audio_data_source.dart';

@LazySingleton(as: AudioRepository)
class AudioRepositoryImpl implements AudioRepository {
  final AudioDataSource audioDataSource;
  
  AudioRepositoryImpl(this.audioDataSource);
  
  @override
  Future<List<Audio>> getAudios() async {
    final audioModels = await audioDataSource.getAudios();
    return audioModels.map((model) => model.toEntity()).toList();
  }
  
  @override
  Future<Audio?> getAudioById(String id) async {
    final audioModel = await audioDataSource.getAudioById(id);
    return audioModel?.toEntity();
  }
  
  @override
  Future<void> favoriteAudio(String id) async {
    await audioDataSource.favoriteAudio(id);
  }
  
  @override
  Future<void> incrementUsageCount(String id) async {
    await audioDataSource.incrementUsageCount(id);
  }
}

