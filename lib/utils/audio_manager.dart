import 'dart:async';
import 'package:just_audio/just_audio.dart';
import '../domain/entities/audio/audio.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  AudioPlayer? _audioPlayer;

  String? _currentAudioId;

  String? _currentVideoId;

  bool _isPlaying = false;

  bool _lowMemoryMode = false;

  final List<Function(bool)> _playStateListeners = [];

  Future<void> _initializePlayer() async {
    if (_audioPlayer == null) {
      _audioPlayer = AudioPlayer();

      _audioPlayer!.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _isPlaying = false;
          _notifyListeners();
        }
      });
    }
  }

  Future<void> playAudio(Audio audio, String videoId) async {
    try {
      await _initializePlayer();

      if (_currentAudioId == audio.id &&
          _currentVideoId == videoId &&
          _isPlaying) {
        await pauseAudio();
        return;
      }

      _currentAudioId = audio.id;
      _currentVideoId = videoId;

      await _audioPlayer?.stop();

      try {
        await _audioPlayer?.setAudioSource(
          AudioSource.uri(Uri.parse(audio.audioUrl)),
          preload: !_lowMemoryMode,
        );

        await _audioPlayer?.play();
        _isPlaying = true;
        _notifyListeners();
      } catch (e) {
        print('Error playing audio URL: $e');

        await _audioPlayer?.setUrl(
          audio.audioUrl,
          preload: !_lowMemoryMode,
        );
        await _audioPlayer?.play();
        _isPlaying = true;
        _notifyListeners();
      }
    } catch (e) {
      print('Error playing audio: $e');
      _currentAudioId = null;
      _currentVideoId = null;
      _isPlaying = false;
      _notifyListeners();
    }
  }

  Future<void> pauseAudio() async {
    try {
      await _audioPlayer?.pause();
      _isPlaying = false;
      _notifyListeners();
    } catch (e) {
      print('Error pausing audio: $e');
    }
  }

  Future<void> resumeAudio() async {
    try {
      if (_audioPlayer != null && _currentAudioId != null) {
        await _audioPlayer!.play();
        _isPlaying = true;
        _notifyListeners();
      }
    } catch (e) {
      print('Error resuming audio: $e');
    }
  }

  Future<void> stopAudio() async {
    try {
      await _audioPlayer?.stop();
      _currentAudioId = null;
      _currentVideoId = null;
      _isPlaying = false;
      _notifyListeners();
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  bool isPlaying(String audioId, String videoId) {
    return _currentAudioId == audioId &&
        _currentVideoId == videoId &&
        _isPlaying;
  }

  bool isPlayingForVideo(String videoId) {
    return _currentVideoId == videoId && _isPlaying;
  }

  String? getCurrentAudioId() {
    return _currentAudioId;
  }

  String? getCurrentVideoId() {
    return _currentVideoId;
  }

  void setLowMemoryMode(bool enabled) {
    _lowMemoryMode = enabled;

    if (enabled && _isPlaying) {
      stopAudio();
    }
  }

  void addPlayStateListener(Function(bool) listener) {
    if (!_playStateListeners.contains(listener)) {
      _playStateListeners.add(listener);
    }
  }

  void removePlayStateListener(Function(bool) listener) {
    _playStateListeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _playStateListeners) {
      listener(_isPlaying);
    }
  }

  Timer? _inactivityTimer;

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(minutes: 5), () {
      stopAudio();
    });
  }

  Future<void> dispose() async {
    try {
      await _audioPlayer?.dispose();
      _audioPlayer = null;
      _currentAudioId = null;
      _currentVideoId = null;
      _isPlaying = false;
      _playStateListeners.clear();
      _resetInactivityTimer();
    } catch (e) {
      print('Error disposing audio player: $e');
    }
  }
}
