import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/feed_providers.dart';
import 'video_player_item.dart';


class VideoFeed extends ConsumerStatefulWidget {
  const VideoFeed({super.key});

  @override
  ConsumerState<VideoFeed> createState() => _VideoFeedState();
}

class _VideoFeedState extends ConsumerState<VideoFeed> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Refresh videos when the widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(videoNotifierProvider.notifier).refreshVideos();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

        return Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: videos.length,
              onPageChanged: (index) {
                ref.read(currentVideoIndexProvider.notifier).setIndex(index);
              },
              itemBuilder: (context, index) {
                final video = videos[index];
                return VideoPlayerItem(
                  video: video,
                  onLike: () {
                    ref.read(videoNotifierProvider.notifier).likeVideo(video.id);
                  },
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

