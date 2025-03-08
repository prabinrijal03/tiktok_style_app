import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/video/video.dart';

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
    String? audioId,
    @Default(0) int likes,
    @Default(0) int comments,
    @Default(0) int shares,
    @Default(false) bool isLiked,
    @Default(false) bool isLocalFile,
  }) = _VideoModel;

  factory VideoModel.fromJson(Map<String, dynamic> json) => _$VideoModelFromJson(json);

  factory VideoModel.fromEntity(Video video) => VideoModel(
        id: video.id,
        videoUrl: video.videoUrl,
        thumbnailUrl: video.thumbnailUrl,
        description: video.description,
        username: video.username,
        audioName: video.audioName,
        audioId: video.audioId,
        likes: video.likes,
        comments: video.comments,
        shares: video.shares,
        isLiked: video.isLiked,
        isLocalFile: video.isLocalFile,
      );
}

extension VideoModelX on VideoModel {
  Video toEntity() => Video(
        id: id,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        description: description,
        username: username,
        audioName: audioName,
        audioId: audioId,
        likes: likes,
        comments: comments,
        shares: shares,
        isLiked: isLiked,
        isLocalFile: isLocalFile,
      );
}

