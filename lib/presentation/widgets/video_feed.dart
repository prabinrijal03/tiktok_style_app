import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

import '../../domain/entities/video/video.dart';
import '../providers/video_providers/video_providers.dart';
import 'video_player_item.dart';

class VideoFeed extends ConsumerStatefulWidget {
  const VideoFeed({super.key});

  @override
  ConsumerState<VideoFeed> createState() => _VideoFeedState();
}

class _VideoFeedState extends ConsumerState<VideoFeed> {
  final PageController _pageController = PageController();

  final Map<int, VideoPlayerController> _preloadedControllers = {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(videoNotifierProvider.notifier).refreshVideos();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();

    for (final controller in _preloadedControllers.values) {
      controller.dispose();
    }
    _preloadedControllers.clear();
    super.dispose();
  }

  void _preloadVideos(List<Video> videos, int currentIndex) {
    if (currentIndex < videos.length - 1) {
      _preloadVideo(videos[currentIndex + 1], currentIndex + 1);
    }

    if (currentIndex > 0) {
      _preloadVideo(videos[currentIndex - 1], currentIndex - 1);
    }

    _preloadedControllers.keys.toList().forEach((index) {
      if ((index < currentIndex - 1) || (index > currentIndex + 1)) {
        _preloadedControllers[index]?.dispose();
        _preloadedControllers.remove(index);
      }
    });
  }

  void _preloadVideo(Video video, int index) {
    if (_preloadedControllers.containsKey(index)) {
      return;
    }

    try {
      VideoPlayerController controller;

      if (video.isLocalFile) {
        controller = VideoPlayerController.file(File(video.videoUrl));
      } else {
        controller =
            VideoPlayerController.networkUrl(Uri.parse(video.videoUrl));
      }

      _preloadedControllers[index] = controller;

      controller.initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
      }).catchError((error) {
        print('Error preloading video $index: $error');
        _preloadedControllers.remove(index);
      });
    } catch (e) {
      print('Error creating controller for video $index: $e');
    }
  }

  VideoPlayerController? getPreloadedController(int index) {
    return _preloadedControllers[index];
  }

  @override
  Widget build(BuildContext context) {
    final videosAsync = ref.watch(videoNotifierProvider);
    final currentIndex = ref.watch(currentVideoIndexProvider);

    return videosAsync.when(
      data: (videos) {
        if (videos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No videos available'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.read(videoNotifierProvider.notifier).refreshVideos();
                  },
                  child: const Text('Refresh'),
                ),
              ],
            ),
          );
        }

        _preloadVideos(videos, currentIndex);

        return Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: videos.length,
              onPageChanged: (index) {
                ref.read(currentVideoIndexProvider.notifier).setIndex(index);

                _preloadVideos(videos, index);
              },
              itemBuilder: (context, index) {
                final video = videos[index];
                return VideoPlayerItem(
                  video: video,
                  onLike: () {
                    ref
                        .read(videoNotifierProvider.notifier)
                        .likeVideo(video.id);
                  },
                  preloadedController: getPreloadedController(index),
                );
              },
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Following',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white60,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'For You',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(videoNotifierProvider.notifier).refreshVideos();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
