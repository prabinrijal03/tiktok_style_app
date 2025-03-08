// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AudioImpl _$$AudioImplFromJson(Map<String, dynamic> json) => _$AudioImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      audioUrl: json['audioUrl'] as String,
      coverUrl: json['coverUrl'] as String,
      duration: (json['duration'] as num).toInt(),
      usageCount: (json['usageCount'] as num?)?.toInt() ?? 0,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );

Map<String, dynamic> _$$AudioImplToJson(_$AudioImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'artist': instance.artist,
      'audioUrl': instance.audioUrl,
      'coverUrl': instance.coverUrl,
      'duration': instance.duration,
      'usageCount': instance.usageCount,
      'isFavorite': instance.isFavorite,
    };
