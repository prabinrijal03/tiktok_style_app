import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiktok_style_app/domain/entities/video_entity.dart';
import 'package:video_player/video_player.dart';

import '../providers/feed_providers.dart';

class VideoPlayerItem extends ConsumerStatefulWidget {
  final VideoEntity video;
  final VoidCallback onLike;

  const VideoPlayerItem({
    super.key,
    required this.video,
    required this.onLike,
  });

  @override
  ConsumerState<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends ConsumerState<VideoPlayerItem> {
  late VideoPlayerController _videoPlayerController;
  bool _isPlaying = true;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() async {
    try {
      // Check if this is a local file or a remote URL
      if (widget.video.isLocalFile) {
        final videoFile = File(widget.video.videoUrl);
        if (await videoFile.exists()) {
          _videoPlayerController = VideoPlayerController.file(videoFile);
        } else {
          throw Exception(
              'Video file does not exist: ${widget.video.videoUrl}');
        }
      } else {
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(widget.video.videoUrl),
        );
      }

      await _videoPlayerController.initialize();
      _videoPlayerController.setLooping(true);
      _videoPlayerController.play();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        print('Video player error: $e');
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _videoPlayerController.play();
      } else {
        _videoPlayerController.pause();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Failed to load video',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            if (widget.video.isLocalFile) ...[
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(videoNotifierProvider.notifier)
                      .deleteVideo(widget.video.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Delete Video'),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                  });
                  _initializeVideoPlayer();
                },
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video Player
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _videoPlayerController.value.size.width,
              height: _videoPlayerController.value.size.height,
              child: VideoPlayer(_videoPlayerController),
            ),
          ),

          // Play/Pause Indicator
          if (!_isPlaying)
            Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),

          // Video Info Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '@${widget.video.username}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.video.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.video.audioName != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.music_note,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.video.audioName!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Right Side Actions
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                // Profile Picture
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    image: DecorationImage(
                      image: _getThumbnailProvider(),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Like Button
                Column(
                  children: [
                    GestureDetector(
                      onTap: widget.onLike,
                      child: Icon(
                        widget.video.isLiked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: widget.video.isLiked ? Colors.red : Colors.white,
                        size: 35,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCount(widget.video.likes),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Comment Button
                Column(
                  children: [
                    const Icon(
                      Icons.comment,
                      color: Colors.white,
                      size: 35,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCount(widget.video.comments),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Share Button
                Column(
                  children: [
                    const Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 35,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCount(widget.video.shares),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                // Delete Button (only for local videos)
                if (widget.video.isLocalFile) ...[
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(videoNotifierProvider.notifier)
                          .deleteVideo(widget.video.id);
                    },
                    child: const Column(
                      children: [
                        Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 35,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider _getThumbnailProvider() {
    try {
      if (widget.video.isLocalFile) {
        final thumbnailFile = File(widget.video.thumbnailUrl);
        if (thumbnailFile.existsSync()) {
          return FileImage(thumbnailFile);
        } else {
          // Fallback to a placeholder if the thumbnail file doesn't exist
          return const AssetImage('assets/placeholder.png');
        }
      } else {
        return NetworkImage(widget.video.thumbnailUrl);
      }
    } catch (e) {
      // Fallback to a placeholder if there's an error
      return const AssetImage('assets/placeholder.png');
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }
}
