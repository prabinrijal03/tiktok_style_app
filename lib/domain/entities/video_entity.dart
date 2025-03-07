class VideoEntity {
  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final String description;
  final String username;
  final String? audioName;
  final int likes;
  final int comments;
  final int shares;
  final bool isLiked;
  final bool isLocalFile;
  VideoEntity({
    required this.id,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.description,
    required this.username,
    this.audioName,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.isLiked,
    required this.isLocalFile,
  });
}
