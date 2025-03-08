import 'package:freezed_annotation/freezed_annotation.dart';

part 'audio.freezed.dart';
part 'audio.g.dart';

@freezed
class Audio with _$Audio {
  const factory Audio({
    required String id,
    required String title,
    required String artist,
    required String audioUrl,
    required String coverUrl,
    required int duration,
    @Default(0) int usageCount,
    @Default(false) bool isFavorite,
  }) = _Audio;

  factory Audio.fromJson(Map<String, dynamic> json) => _$AudioFromJson(json);
}

