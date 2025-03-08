// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../domain/entities/video/video.dart';
import '../providers/audio_providers/audio_providers.dart';
import '../providers/video_providers/video_providers.dart';

class VideoPlayerItem extends ConsumerStatefulWidget {
  final Video video;
  final VoidCallback onLike;
  final VideoPlayerController? preloadedController;

  const VideoPlayerItem({
    super.key,
    required this.video,
    required this.onLike,
    this.preloadedController,
  });

  @override
  ConsumerState<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends ConsumerState<VideoPlayerItem> {
  late VideoPlayerController _videoPlayerController;
  bool _isPlaying = true;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _createdOwnController = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() async {
    try {
      if (widget.preloadedController != null &&
          widget.preloadedController!.value.isInitialized) {
        _videoPlayerController = widget.preloadedController!;
        _isInitialized = true;
        _videoPlayerController.play();
        setState(() {});
        return;
      }

      _createdOwnController = true;

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
    if (_createdOwnController) {
      _videoPlayerController.dispose();
    } else {
      _videoPlayerController.pause();
    }
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

    return VisibilityDetector(
      key: Key(widget.video.id),
      onVisibilityChanged: (info) {
        if (info.visibleFraction == 0) {
          _videoPlayerController.pause();
        } else if (info.visibleFraction == 1) {
          _videoPlayerController.play();
        }
      },
      child: GestureDetector(
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
                          Expanded(
                            child: Text(
                              widget.video.audioName!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

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
                          color:
                              widget.video.isLiked ? Colors.red : Colors.white,
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

                  if (widget.video.audioId != null) ...[
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        _showAudioInfo(context, widget.video.audioId!);
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.5),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.music_note,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Sound',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

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
      ),
    );
  }

  Future<void> _showAudioInfo(BuildContext context, String audioId) async {
    final getAudioByIdUseCase = ref.read(getAudioByIdUseCaseProvider);
    final audio = await getAudioByIdUseCase.execute(audioId);

    if (audio != null && context.mounted) {
      showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      image: DecorationImage(
                        image: NetworkImage(audio.coverUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          audio.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          audio.artist,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '${_formatCount(audio.usageCount)} videos',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.play_circle_filled),
                    onPressed: () {
                      ref
                          .read(audioPlayerControllerProvider.notifier)
                          .playAudio(audio);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Audio feature coming soon in hired version'),
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Use this sound'),
              ),
            ],
          ),
        ),
      );
    }
  }

  ImageProvider _getThumbnailProvider() {
    try {
      if (widget.video.isLocalFile) {
        final thumbnailFile = File(widget.video.thumbnailUrl);
        if (thumbnailFile.existsSync()) {
          return FileImage(thumbnailFile);
        } else {
          return const NetworkImage(
              'https://via.placeholder.com/150/FF5733/FFFFFF?text=Video');
        }
      } else {
        return NetworkImage(widget.video.thumbnailUrl);
      }
    } catch (e) {
      return const NetworkImage(
          'https://via.placeholder.com/150/FF5733/FFFFFF?text=Error');
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
