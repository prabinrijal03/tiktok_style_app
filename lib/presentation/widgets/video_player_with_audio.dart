// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

import '../../domain/entities/audio/audio.dart';

class VideoPlayerWithAudio extends StatefulWidget {
  final VideoPlayerController videoController;
  final Audio? audio;
  final bool autoplay;
  final bool looping;
  final bool muted;
  final VoidCallback? onVideoEnd;

  const VideoPlayerWithAudio({
    super.key,
    required this.videoController,
    this.audio,
    this.autoplay = true,
    this.looping = true,
    this.muted = true,
    this.onVideoEnd,
  });

  @override
  State<VideoPlayerWithAudio> createState() => _VideoPlayerWithAudioState();
}

class _VideoPlayerWithAudioState extends State<VideoPlayerWithAudio> {
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  bool _isVideoInitialized = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _setupVideoController();
    _setupAudioPlayer();
  }

  void _setupVideoController() {
    widget.videoController.setVolume(0);

    widget.videoController.setLooping(widget.looping);

    widget.videoController.addListener(_videoListener);

    if (widget.videoController.value.isInitialized) {
      setState(() {
        _isVideoInitialized = true;
      });

      if (widget.autoplay) {
        _playVideo();
      }
    } else {
      widget.videoController.initialize().then((_) {
        if (!_isDisposed) {
          setState(() {
            _isVideoInitialized = true;
          });

          if (widget.autoplay) {
            _playVideo();
          }
        }
      }).catchError((error) {
        print('Error initializing video: $error');
      });
    }
  }

  Future<void> _setupAudioPlayer() async {
    if (widget.audio != null) {
      try {
        _audioPlayer = AudioPlayer();
        await _audioPlayer!.setUrl(widget.audio!.audioUrl);
        await _audioPlayer!
            .setLoopMode(widget.looping ? LoopMode.one : LoopMode.off);

        _audioPlayer!.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            if (widget.looping) {
              _audioPlayer!.seek(Duration.zero);
              _audioPlayer!.play();
            } else if (widget.onVideoEnd != null) {
              widget.onVideoEnd!();
            }
          }
        });

        if (widget.autoplay && _isVideoInitialized) {
          _playAudio();
        }
      } catch (e) {
        print('Error setting up audio player: $e');
      }
    }
  }

  void _videoListener() {
    if (!widget.looping &&
        widget.videoController.value.position >=
            widget.videoController.value.duration -
                const Duration(milliseconds: 300)) {
      if (widget.onVideoEnd != null) {
        widget.onVideoEnd!();
      }
    }
  }

  Future<void> _playVideo() async {
    if (_isDisposed) return;

    try {
      await widget.videoController.play();

      if (!_isDisposed) {
        setState(() {
          _isPlaying = true;
        });
      }
    } catch (e) {
      print('Error playing video: $e');
    }
  }

  Future<void> _playAudio() async {
    if (_isDisposed || _audioPlayer == null) return;

    try {
      await _audioPlayer!.play();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> _pauseVideo() async {
    if (_isDisposed) return;

    try {
      await widget.videoController.pause();

      if (!_isDisposed) {
        setState(() {
          _isPlaying = false;
        });
      }
    } catch (e) {
      print('Error pausing video: $e');
    }
  }

  Future<void> _pauseAudio() async {
    if (_isDisposed || _audioPlayer == null) return;

    try {
      await _audioPlayer!.pause();
    } catch (e) {
      print('Error pausing audio: $e');
    }
  }

  void _togglePlayback() {
    if (_isPlaying) {
      _pauseVideo();
      _pauseAudio();
    } else {
      _playVideo();
      _playAudio();
    }
  }

  @override
  void didUpdateWidget(VideoPlayerWithAudio oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.audio?.id != widget.audio?.id) {
      _disposeAudioPlayer();
      _setupAudioPlayer();
    }

    if (oldWidget.videoController != widget.videoController) {
      oldWidget.videoController.removeListener(_videoListener);
      _isVideoInitialized = false;
      _setupVideoController();
    }
  }

  void _disposeAudioPlayer() {
    if (_audioPlayer != null) {
      _audioPlayer!.dispose();
      _audioPlayer = null;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    widget.videoController.removeListener(_videoListener);
    _disposeAudioPlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVideoInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return GestureDetector(
      onTap: _togglePlayback,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: widget.videoController.value.size.width,
              height: widget.videoController.value.size.height,
              child: VideoPlayer(widget.videoController),
            ),
          ),
          if (!_isPlaying)
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          if (widget.audio != null)
            Positioned(
              bottom: 70,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.music_note, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      widget.audio!.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
