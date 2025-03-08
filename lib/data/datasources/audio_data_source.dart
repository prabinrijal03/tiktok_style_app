import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../models/audio_model/audio_model.dart';

abstract class AudioDataSource {
  Future<List<AudioModel>> getAudios();
  Future<AudioModel?> getAudioById(String id);
  Future<void> favoriteAudio(String id);
  Future<void> incrementUsageCount(String id);
  Future<bool> checkAudioAvailability();
}

@LazySingleton(as: AudioDataSource)
class AudioDataSourceImpl implements AudioDataSource {
  final Box<AudioModel> _audiosBox;

  AudioDataSourceImpl(@Named("audiosBox") this._audiosBox) {
    _initMockAudios();
  }

  Future<void> _initMockAudios() async {
    if (_audiosBox.isEmpty) {
      print('Initializing mock audio data...');
      final mockAudios = _getMockAudios();
      for (var audio in mockAudios) {
        await _audiosBox.put(audio.id, audio);
      }
      print('Added ${mockAudios.length} mock audio items');
    } else {
      print('Audio box already contains ${_audiosBox.length} items');
    }
  }

  @override
  Future<List<AudioModel>> getAudios() async {
    try {
      final audios = _audiosBox.values.toList();
      print('Retrieved ${audios.length} audios from storage');
      return audios;
    } catch (e) {
      print('Error getting audios: $e');
      await _initMockAudios();
      return _getMockAudios();
    }
  }

  @override
  Future<AudioModel?> getAudioById(String id) async {
    try {
      final audio = _audiosBox.get(id);
      if (audio == null) {
        print('Audio with ID $id not found');
      }
      return audio;
    } catch (e) {
      print('Error getting audio by ID: $e');
      return null;
    }
  }

  @override
  Future<void> favoriteAudio(String id) async {
    try {
      final audio = _audiosBox.get(id);
      if (audio != null) {
        audio.isFavorite = !audio.isFavorite;
        await audio.save();
      }
    } catch (e) {
      print('Error favoriting audio: $e');
    }
  }

  @override
  Future<void> incrementUsageCount(String id) async {
    try {
      final audio = _audiosBox.get(id);
      if (audio != null) {
        final updatedAudio = AudioModel(
          id: audio.id,
          title: audio.title,
          artist: audio.artist,
          audioUrl: audio.audioUrl,
          coverUrl: audio.coverUrl,
          duration: audio.duration,
          usageCount: audio.usageCount + 1,
          isFavorite: audio.isFavorite,
        );
        await _audiosBox.put(id, updatedAudio);
      }
    } catch (e) {
      print('Error incrementing usage count: $e');
    }
  }

  @override
  Future<bool> checkAudioAvailability() async {
    try {
      final audios = await getAudios();
      print('Audio availability check: ${audios.length} audios found');
      return audios.isNotEmpty;
    } catch (e) {
      print('Error checking audio availability: $e');
      return false;
    }
  }

  // Enhanced mock data for TikTok-like experience
  List<AudioModel> _getMockAudios() {
    return [
      AudioModel(
        id: const Uuid().v4(),
        title: 'Original Sound',
        artist: 'TikTok',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        coverUrl: 'https://via.placeholder.com/150/FF5733/FFFFFF?text=Original',
        duration: 30,
        usageCount: 1000000,
      ),
      AudioModel(
        id: const Uuid().v4(),
        title: 'Summer Vibes',
        artist: 'DJ Cool',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        coverUrl: 'https://via.placeholder.com/150/33FF57/FFFFFF?text=Summer',
        duration: 15,
        usageCount: 500000,
      ),
      AudioModel(
        id: const Uuid().v4(),
        title: 'Dance Pop',
        artist: 'Music Master',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
        coverUrl: 'https://via.placeholder.com/150/5733FF/FFFFFF?text=Dance',
        duration: 20,
        usageCount: 750000,
      ),
      AudioModel(
        id: const Uuid().v4(),
        title: 'Chill Lofi',
        artist: 'Lofi Beats',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
        coverUrl: 'https://via.placeholder.com/150/FF33A8/FFFFFF?text=Chill',
        duration: 25,
        usageCount: 300000,
      ),
      AudioModel(
        id: const Uuid().v4(),
        title: 'Hip Hop Classic',
        artist: 'Beat Maker',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
        coverUrl: 'https://via.placeholder.com/150/33A8FF/FFFFFF?text=HipHop',
        duration: 18,
        usageCount: 450000,
      ),
      AudioModel(
        id: const Uuid().v4(),
        title: 'Trending Beat #1',
        artist: 'Viral Sounds',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
        coverUrl: 'https://via.placeholder.com/150/A833FF/FFFFFF?text=Trending',
        duration: 22,
        usageCount: 900000,
      ),
      AudioModel(
        id: const Uuid().v4(),
        title: 'Viral TikTok Sound',
        artist: 'TikTok Creator',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
        coverUrl: 'https://via.placeholder.com/150/33FFC1/FFFFFF?text=Viral',
        duration: 12,
        usageCount: 2500000,
      ),
      AudioModel(
        id: const Uuid().v4(),
        title: 'Funny Voice Over',
        artist: 'Comedy King',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
        coverUrl: 'https://via.placeholder.com/150/FF3333/FFFFFF?text=Funny',
        duration: 8,
        usageCount: 1200000,
      ),
      AudioModel(
        id: const Uuid().v4(),
        title: 'Dramatic Effect',
        artist: 'Sound Designer',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',
        coverUrl: 'https://via.placeholder.com/150/FFDD33/FFFFFF?text=Drama',
        duration: 5,
        usageCount: 800000,
      ),
      AudioModel(
        id: const Uuid().v4(),
        title: 'Remix Challenge',
        artist: 'DJ Remix',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',
        coverUrl: 'https://via.placeholder.com/150/33FFDD/FFFFFF?text=Remix',
        duration: 28,
        usageCount: 1800000,
      ),
    ];
  }
}

