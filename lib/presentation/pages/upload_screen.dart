import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../providers/feed_providers.dart';

class UploadScreen extends ConsumerStatefulWidget {
  final VoidCallback onVideoUploaded;

  const UploadScreen({
    super.key,
    required this.onVideoUploaded,
  });

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  File? _videoFile;
  File? _thumbnailFile;
  String _description = '';
  String? _audioName;
  bool _isUploading = false;
  bool _isGeneratingThumbnail = false;
  VideoPlayerController? _videoPlayerController;
  final GlobalKey _videoPlayerKey = GlobalKey();
  bool _hasVideoError = false;

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _videoFile = File(result.files.first.path!);
        _hasVideoError = false;
      });

      try {
        _videoPlayerController = VideoPlayerController.file(_videoFile!)
          ..initialize().then((_) {
            setState(() {});
            _videoPlayerController!.play();
            _videoPlayerController!.setLooping(true);
            // Generate thumbnail after video is initialized
            _generateThumbnail();
          });
      } catch (e) {
        setState(() {
          _hasVideoError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading video: $e')),
        );
      }
    }
  }

  Future<void> _generateThumbnail() async {
    if (_videoPlayerController == null ||
        !_videoPlayerController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isGeneratingThumbnail = true;
    });

    try {
      // Create a placeholder thumbnail
      final tempDir = await getTemporaryDirectory();
      final thumbnailFile = File(
          '${tempDir.path}/thumbnail_${DateTime.now().millisecondsSinceEpoch}.jpg');

      // For simplicity, we'll use a placeholder image
      // In a real app, you would capture a frame from the video
      final placeholderImage = await _createPlaceholderImage();
      await thumbnailFile.writeAsBytes(placeholderImage);

      setState(() {
        _thumbnailFile = thumbnailFile;
        _isGeneratingThumbnail = false;
      });
    } catch (e) {
      setState(() {
        _isGeneratingThumbnail = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate thumbnail: $e')),
      );
    }
  }

  Future<Uint8List> _createPlaceholderImage() async {
    // Create a simple colored image as a placeholder
    // In a real app, you would capture a frame from the video

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = Colors.blue;

    canvas.drawRect(Rect.fromLTWH(0, 0, 320, 240), paint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(320, 240);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  Future<void> _pickThumbnail() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _thumbnailFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadVideo() async {
    if (_videoFile == null || _thumbnailFile == null || _description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      await ref.read(videoNotifierProvider.notifier).uploadVideo(
            videoFile: _videoFile!,
            thumbnailFile: _thumbnailFile!,
            description: _description,
            audioName: _audioName,
          );

      // Clear the form
      setState(() {
        _videoFile = null;
        _thumbnailFile = null;
        _description = '';
        _audioName = null;
        _videoPlayerController?.dispose();
        _videoPlayerController = null;
      });

      // Call the callback to navigate back and refresh videos
      widget.onVideoUploaded();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video uploaded successfully!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload video: $e'),
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Video'),
        actions: [
          if (_videoFile != null)
            TextButton(
              onPressed: _isUploading ? null : _uploadVideo,
              child: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Post',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_videoFile == null) ...[
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _pickVideo,
                    icon: const Icon(Icons.video_library),
                    label: const Text('Select Video'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                if (_hasVideoError)
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.black,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          const Text(
                            'Failed to load video',
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _pickVideo,
                            child: const Text('Select Another Video'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_videoPlayerController != null &&
                    _videoPlayerController!.value.isInitialized)
                  RepaintBoundary(
                    key: _videoPlayerKey,
                    child: AspectRatio(
                      aspectRatio: _videoPlayerController!.value.aspectRatio,
                      child: VideoPlayer(_videoPlayerController!),
                    ),
                  )
                else
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _pickThumbnail,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _isGeneratingThumbnail
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : _thumbnailFile != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _thumbnailFile!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Center(
                                    child: Text('Select Thumbnail'),
                                  ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cover',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Select a cover image for your video',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (!_hasVideoError && _thumbnailFile != null)
                            TextButton(
                              onPressed: _generateThumbnail,
                              child: const Text('Generate New Thumbnail'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Describe your video...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: (value) {
                    setState(() {
                      _description = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Audio',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Original Sound (optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.music_note),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _audioName = value.isEmpty ? null : value;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
