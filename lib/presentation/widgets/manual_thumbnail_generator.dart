import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class ManualThumbnailGenerator extends StatefulWidget {
  final VideoPlayerController controller;
  final Function(File thumbnailFile) onThumbnailGenerated;

  const ManualThumbnailGenerator({
    super.key,
    required this.controller,
    required this.onThumbnailGenerated,
  });

  @override
  State<ManualThumbnailGenerator> createState() =>
      _ManualThumbnailGeneratorState();
}

class _ManualThumbnailGeneratorState extends State<ManualThumbnailGenerator> {
  double _sliderValue = 0.0;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _sliderValue = 0.0;
  }

  Future<void> _generateThumbnail() async {
    if (!widget.controller.value.isInitialized) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      final Duration position = Duration(
        milliseconds:
            (widget.controller.value.duration.inMilliseconds * _sliderValue)
                .round(),
      );

      await widget.controller.seekTo(position);

      await widget.controller.pause();

      await Future.delayed(const Duration(milliseconds: 100));

      final Uint8List? bytes = await _captureVideoFrame();

      if (bytes != null) {
        final tempDir = await getTemporaryDirectory();
        final thumbnailFile = File(
            '${tempDir.path}/thumbnail_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await thumbnailFile.writeAsBytes(bytes);

        widget.onThumbnailGenerated(thumbnailFile);

        await widget.controller.play();
      }
    } catch (e) {
      print('Error generating thumbnail: $e');
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  Future<Uint8List?> _captureVideoFrame() async {
    return Uint8List.fromList([]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Frame for Thumbnail',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _sliderValue,
          onChanged: (value) {
            setState(() {
              _sliderValue = value;
            });

            final position = Duration(
              milliseconds:
                  (widget.controller.value.duration.inMilliseconds * value)
                      .round(),
            );
            widget.controller.seekTo(position);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(Duration(
                milliseconds: (widget.controller.value.duration.inMilliseconds *
                        _sliderValue)
                    .round(),
              )),
            ),
            Text(
              _formatDuration(widget.controller.value.duration),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isGenerating ? null : _generateThumbnail,
          child: _isGenerating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Use This Frame as Thumbnail'),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }
}
