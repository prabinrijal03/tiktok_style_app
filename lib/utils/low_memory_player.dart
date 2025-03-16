import 'dart:io';
import 'package:video_player/video_player.dart';

class LowMemoryVideoPlayer {
  static final LowMemoryVideoPlayer _instance =
      LowMemoryVideoPlayer._internal();
  factory LowMemoryVideoPlayer() => _instance;
  LowMemoryVideoPlayer._internal();
  VideoPlayerController? _sharedController;
  String? _currentVideoId;
  bool _isInitialized = false;
  final List<Function(VideoPlayerController)> _onReadyCallbacks = [];
  static const int _maxActiveControllers = 1;
  final Map<String, VideoPlayerController> _controllers = {};
  final List<String> _preloadQueue = [];
  bool _lowMemoryMode = false;

  Future<VideoPlayerController?> getController({
    required String videoId,
    required String videoUrl,
    required bool isLocalFile,
    bool autoInitialize = true,
  }) async {
    if (_controllers.containsKey(videoId)) {
      return _controllers[videoId];
    }

    if (_lowMemoryMode && _controllers.isNotEmpty) {
      if (_sharedController != null) {
        return _sharedController;
      }

      await _cleanupAllControllers();
    }

    if (_controllers.length >= _maxActiveControllers) {
      await _cleanupOldestController();
    }

    VideoPlayerController controller;
    try {
      if (isLocalFile) {
        controller = VideoPlayerController.file(
          File(videoUrl),
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: true,
            allowBackgroundPlayback: false,
          ),
        );
      } else {
        controller = VideoPlayerController.networkUrl(
          Uri.parse(videoUrl),
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: true,
            allowBackgroundPlayback: false,
          ),
        );
      }

      if (autoInitialize) {
        await controller.initialize();
      }

      await controller.setVolume(0);

      _controllers[videoId] = controller;

      if (_sharedController == null) {
        _sharedController = controller;
        _currentVideoId = videoId;
        _isInitialized = true;

        for (final callback in _onReadyCallbacks) {
          callback(controller);
        }
        _onReadyCallbacks.clear();
      }

      return controller;
    } catch (e) {
      print('Error creating video controller: $e');
      return null;
    }
  }

  Future<void> _cleanupOldestController() async {
    if (_controllers.isEmpty) return;

    try {
      final oldestKey = _controllers.keys.first;

      if (oldestKey == _currentVideoId) {
        if (_controllers.length <= 1) return;

        final secondOldestKey = _controllers.keys.elementAt(1);
        await _cleanupController(secondOldestKey);
        return;
      }

      await _cleanupController(oldestKey);
    } catch (e) {
      print('Error cleaning up oldest controller: $e');
    }
  }

  Future<void> _cleanupController(String videoId) async {
    try {
      final controller = _controllers[videoId];
      if (controller != null) {
        await controller.pause();
        await controller.dispose();
        _controllers.remove(videoId);

        if (_currentVideoId == videoId) {
          _sharedController = null;
          _currentVideoId = null;
          _isInitialized = false;
        }
      }
    } catch (e) {
      print('Error cleaning up controller: $e');
    }
  }

  Future<void> _cleanupAllControllers() async {
    try {
      final keys = _controllers.keys.toList();

      for (final key in keys) {
        await _cleanupController(key);
      }

      _sharedController = null;
      _currentVideoId = null;
      _isInitialized = false;
    } catch (e) {
      print('Error cleaning up all controllers: $e');
    }
  }

  Future<void> preloadVideo({
    required String videoId,
    required String videoUrl,
    required bool isLocalFile,
  }) async {
    if (_lowMemoryMode) return;

    if (_controllers.containsKey(videoId)) return;

    if (_controllers.length >= _maxActiveControllers) {
      if (!_preloadQueue.contains(videoId)) {
        _preloadQueue.add(videoId);
      }
      return;
    }

    try {
      await getController(
        videoId: videoId,
        videoUrl: videoUrl,
        isLocalFile: isLocalFile,
        autoInitialize: false,
      );
    } catch (e) {
      print('Error preloading video: $e');
    }
  }

  void setLowMemoryMode(bool enabled) {
    _lowMemoryMode = enabled;

    if (enabled) {
      _cleanupExcessControllers();
    }
  }

  Future<void> _cleanupExcessControllers() async {
    try {
      final keys = _controllers.keys.toList();

      for (final key in keys) {
        if (key != _currentVideoId) {
          await _cleanupController(key);
        }
      }

      _preloadQueue.clear();
    } catch (e) {
      print('Error cleaning up excess controllers: $e');
    }
  }

  Future<void> pauseAllVideos() async {
    try {
      for (final controller in _controllers.values) {
        if (controller.value.isPlaying) {
          await controller.pause();
        }
      }
    } catch (e) {
      print('Error pausing all videos: $e');
    }
  }

  Future<void> resumeVideo(String videoId) async {
    try {
      final controller = _controllers[videoId];
      if (controller != null && !controller.value.isPlaying) {
        await controller.play();
      }
    } catch (e) {
      print('Error resuming video: $e');
    }
  }

  void onReady(Function(VideoPlayerController) callback) {
    if (_isInitialized && _sharedController != null) {
      callback(_sharedController!);
    } else {
      _onReadyCallbacks.add(callback);
    }
  }

  Future<void> dispose() async {
    await _cleanupAllControllers();
    _onReadyCallbacks.clear();
    _preloadQueue.clear();
  }
}
