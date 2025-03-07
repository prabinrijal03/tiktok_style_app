import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tiktok_style_app/domain/entities/video_entity.dart';

part 'video_model.freezed.dart';
part 'video_model.g.dart';

@freezed
class VideoModel with _$VideoModel {
  const factory VideoModel({
    required String id,
    required String videoUrl,
    required String thumbnailUrl,
    required String description,
    required String username,
    String? audioName,
    @Default(0) int likes,
    @Default(0) int comments,
    @Default(0) int shares,
    @Default(false) bool isLiked,
    // Add a flag to indicate if this is a local file
    @Default(false) bool isLocalFile,
  }) = _VideoModel;

  factory VideoModel.fromJson(Map<String, dynamic> json) =>
      _$VideoModelFromJson(json);

  factory VideoModel.fromEntity(VideoEntity video) => VideoModel(
        id: video.id,
        videoUrl: video.videoUrl,
        thumbnailUrl: video.thumbnailUrl,
        description: video.description,
        username: video.username,
        audioName: video.audioName,
        likes: video.likes,
        comments: video.comments,
        shares: video.shares,
        isLiked: video.isLiked,
        isLocalFile: video.isLocalFile,
      );
}

extension VideoModelX on VideoModel {
  VideoEntity toEntity() => VideoEntity(
        id: id,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        description: description,
        username: username,
        audioName: audioName,
        likes: likes,
        comments: comments,
        shares: shares,
        isLiked: isLiked,
        isLocalFile: isLocalFile,
      );
}
