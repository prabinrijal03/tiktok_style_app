import 'package:freezed_annotation/freezed_annotation.dart';

part 'video.freezed.dart';
part 'video.g.dart';

@freezed
class Video with _$Video {
  const factory Video({
    required String id,
    required String videoUrl,
    required String thumbnailUrl,
    required String description,
    required String username,
    String? audioName,
    String? audioId,
    @Default(0) int likes,
    @Default(0) int comments,
    @Default(0) int shares,
    @Default(false) bool isLiked,
    @Default(false) bool isLocalFile,
  }) = _Video;

  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);
}

