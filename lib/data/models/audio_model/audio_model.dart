import 'package:hive/hive.dart';

import '../../../domain/entities/audio/audio.dart';

part 'audio_model.g.dart';

@HiveType(typeId: 1)
class AudioModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String artist;
  
  @HiveField(3)
  final String audioUrl;
  
  @HiveField(4)
  final String coverUrl;
  
  @HiveField(5)
  final int duration;
  
  @HiveField(6)
  final int usageCount;
  
  @HiveField(7)
   bool isFavorite;

  AudioModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.audioUrl,
    required this.coverUrl,
    required this.duration,
    this.usageCount = 0,
    this.isFavorite = false,
  });
  
  Audio toEntity() => Audio(
    id: id,
    title: title,
    artist: artist,
    audioUrl: audioUrl,
    coverUrl: coverUrl,
    duration: duration,
    usageCount: usageCount,
    isFavorite: isFavorite,
  );
  
  factory AudioModel.fromEntity(Audio audio) => AudioModel(
    id: audio.id,
    title: audio.title,
    artist: audio.artist,
    audioUrl: audio.audioUrl,
    coverUrl: audio.coverUrl,
    duration: audio.duration,
    usageCount: audio.usageCount,
    isFavorite: audio.isFavorite,
  );
}

