// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VideoImpl _$$VideoImplFromJson(Map<String, dynamic> json) => _$VideoImpl(
      id: json['id'] as String,
      videoUrl: json['videoUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      description: json['description'] as String,
      username: json['username'] as String,
      audioName: json['audioName'] as String?,
      audioId: json['audioId'] as String?,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
      shares: (json['shares'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isLocalFile: json['isLocalFile'] as bool? ?? false,
    );

Map<String, dynamic> _$$VideoImplToJson(_$VideoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'videoUrl': instance.videoUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'description': instance.description,
      'username': instance.username,
      'audioName': instance.audioName,
      'audioId': instance.audioId,
      'likes': instance.likes,
      'comments': instance.comments,
      'shares': instance.shares,
      'isLiked': instance.isLiked,
      'isLocalFile': instance.isLocalFile,
    };
