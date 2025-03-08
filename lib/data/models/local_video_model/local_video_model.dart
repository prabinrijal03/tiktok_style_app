import 'package:hive/hive.dart';

part 'local_video_model.g.dart';

@HiveType(typeId: 0)
class LocalVideoModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String videoPath;
  
  @HiveField(2)
  final String thumbnailPath;
  
  @HiveField(3)
  final String description;
  
  @HiveField(4)
  final String username;
  
  @HiveField(5)
  final String? audioName;
  
  @HiveField(6)
  int likes;
  
  @HiveField(7)
  int comments;
  
  @HiveField(8)
  int shares;
  
  @HiveField(9)
  bool isLiked;
  
  @HiveField(10)
  final DateTime createdAt;
  
  @HiveField(11)
  final String? audioId;

  LocalVideoModel({
    required this.id,
    required this.videoPath,
    required this.thumbnailPath,
    required this.description,
    required this.username,
    this.audioName,
    this.audioId,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.isLiked = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

