import 'package:json_annotation/json_annotation.dart';

part 'video_response.g.dart';

@JsonSerializable()
class VideoResponse {
  final int id;
  final int albumId;
  final String title;
  final String url;
  final String thumbnailUrl;

  VideoResponse({
    required this.id,
    required this.albumId,
    required this.title,
    required this.url,
    required this.thumbnailUrl,
  });

  factory VideoResponse.fromJson(Map<String, dynamic> json) => 
      _$VideoResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$VideoResponseToJson(this);
}

