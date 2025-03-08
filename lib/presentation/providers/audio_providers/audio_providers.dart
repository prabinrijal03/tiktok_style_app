// ignore_for_file: deprecated_member_use_from_same_package

import 'package:audioplayers/audioplayers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../di/injection.dart';
import '../../../domain/entities/audio/audio.dart';
import '../../../domain/usecases/favorite_audio_usecase.dart';
import '../../../domain/usecases/get_audio_by_id_usecase.dart';
import '../../../domain/usecases/get_audios_usecase.dart';
import '../../../domain/usecases/increment_audio_usage_usecase.dart';


part 'audio_providers.g.dart';

@riverpod
GetAudiosUseCase getAudiosUseCase(GetAudiosUseCaseRef ref) {
  return getIt<GetAudiosUseCase>();
}

@riverpod
GetAudioByIdUseCase getAudioByIdUseCase(GetAudioByIdUseCaseRef ref) {
  return getIt<GetAudioByIdUseCase>();
}

@riverpod
FavoriteAudioUseCase favoriteAudioUseCase(FavoriteAudioUseCaseRef ref) {
  return getIt<FavoriteAudioUseCase>();
}

@riverpod
IncrementAudioUsageUseCase incrementAudioUsageUseCase(IncrementAudioUsageUseCaseRef ref) {
  return getIt<IncrementAudioUsageUseCase>();
}

@riverpod
class AudioNotifier extends _$AudioNotifier {
  @override
  Future<List<Audio>> build() async {
    final audios = await _fetchAudios();
    if (audios.isEmpty) {
      print('Warning: No audios found in AudioNotifier build');
    }
    return audios;
  }

  Future<List<Audio>> _fetchAudios() async {
    final getAudiosUseCase = ref.read(getAudiosUseCaseProvider);
    return await getAudiosUseCase.execute();
  }

  Future<void> refreshAudios() async {
    state = const AsyncValue.loading();
    try {
      final audios = await _fetchAudios();
      state = AsyncValue.data(audios);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> favoriteAudio(String id) async {
    final favoriteAudioUseCase = ref.read(favoriteAudioUseCaseProvider);
    
    
    state = AsyncValue.data(
      state.value?.map((audio) {
        if (audio.id == id) {
          return audio.copyWith(isFavorite: !audio.isFavorite);
        }
        return audio;
      }).toList() ?? [],
    );
    
    
    await favoriteAudioUseCase.execute(id);
  }

  Future<void> incrementUsageCount(String id) async {
    final incrementAudioUsageUseCase = ref.read(incrementAudioUsageUseCaseProvider);
    await incrementAudioUsageUseCase.execute(id);
    
    
    state = AsyncValue.data(
      state.value?.map((audio) {
        if (audio.id == id) {
          return audio.copyWith(usageCount: audio.usageCount + 1);
        }
        return audio;
      }).toList() ?? [],
    );
  }

  Future<void> debugAudios() async {
    final getAudiosUseCase = ref.read(getAudiosUseCaseProvider);
    final audios = await getAudiosUseCase.execute();
    print('Debug audios: ${audios.length} audios found');
    for (var audio in audios) {
      print('Audio: ${audio.id} - ${audio.title} by ${audio.artist}');
    }
  }
}

@riverpod
class AudioPlayerController extends _$AudioPlayerController {
  final _audioPlayer = AudioPlayer();
  Audio? _currentAudio;
  
  @override
  Future<void> build() async {
    ref.onDispose(() {
      _audioPlayer.dispose();
    });
  }
  
  Future<void> playAudio(Audio audio) async {
  try {
    
    if (_currentAudio?.id == audio.id && _audioPlayer.state == PlayerState.playing) {
      await _audioPlayer.pause();
      state = const AsyncValue.data(null);
      return;
    }
    
    
    _currentAudio = audio;
    
    
    await _audioPlayer.stop();
    
    
    _audioPlayer.onPlayerComplete.listen((_) {
      _currentAudio = null;
      state = const AsyncValue.data(null);
    });
    
    
    await _audioPlayer.play(UrlSource(audio.audioUrl));
    
    state = const AsyncValue.data(null);
  } catch (e) {
    print('Error playing audio: $e');
    _currentAudio = null;
    state = AsyncValue.error(e, StackTrace.current);
  }
}

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    _currentAudio = null;
    state = const AsyncValue.data(null);
  }

  Future<Audio?> getCurrentAudio() async {
    return _currentAudio;
  }
  
  bool isPlaying(String audioId) {
    return _currentAudio?.id == audioId && _audioPlayer.state == PlayerState.playing;
  }
}

