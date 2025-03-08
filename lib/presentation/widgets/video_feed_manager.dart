import 'dart:io';

import 'package:video_player/video_player.dart';

import '../../domain/entities/video/video.dart';
import '../../utils/video_cache_manager.dart';

class VideoFeedManager {
  static final VideoFeedManager _instance = VideoFeedManager._internal();
  factory VideoFeedManager() => _instance;
  VideoFeedManager._internal();

  final _cacheManager = VideoCacheManager();
  final Map<String, VideoPlayerController> _controllerCache = {};
  final int _maxCachedControllers = 5;

  Future<void> preloadVideo(Video video) async {
    try {
      if (!video.isLocalFile) {
        final cachedPath = await _cacheManager.precacheVideo(video.videoUrl);

        if (!_controllerCache.containsKey(video.id)) {
          final controller = cachedPath != null
              ? VideoPlayerController.file(File(cachedPath))
              : VideoPlayerController.networkUrl(Uri.parse(video.videoUrl));

          await controller.initialize();

          _controllerCache[video.id] = controller;

          _cleanupControllerCache();
        }
      }
    } catch (e) {
      print('Error preloading video: $e');
    }
  }

  VideoPlayerController? getCachedController(String videoId) {
    return _controllerCache[videoId];
  }

  void _cleanupControllerCache() {
    if (_controllerCache.length > _maxCachedControllers) {
      final keysToRemove = _controllerCache.keys
          .take(_controllerCache.length - _maxCachedControllers);
      for (final key in keysToRemove) {
        final controller = _controllerCache[key];
        controller?.dispose();
        _controllerCache.remove(key);
      }
    }
  }

  void dispose() {
    for (final controller in _controllerCache.values) {
      controller.dispose();
    }
    _controllerCache.clear();
  }
}
