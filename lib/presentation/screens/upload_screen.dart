// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tiktok_style_app/utils/permission_handler.dart';
import 'package:video_player/video_player.dart';
import '../../domain/entities/audio/audio.dart';
import '../../utils/video_compressor.dart';
import '../providers/audio_providers/audio_providers.dart';
import '../providers/video_providers/video_providers.dart';
import '../widgets/video_player_with_audio.dart';
import 'audio_selection_screen.dart';

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
  File? _compressedVideoFile;
  File? _thumbnailFile;
  String _description = '';
  Audio? _selectedAudio;
  bool _isUploading = false;
  bool _isGeneratingThumbnail = false;
  bool _isCompressingVideo = false;
  double _compressionProgress = 0.0;
  VideoPlayerController? _videoPlayerController;

  bool _hasVideoError = false;
  final VideoCompressor _videoCompressor = VideoCompressor();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioNotifierProvider.notifier).refreshAudios();
    });
    requestStorage();
  }

  void requestStorage() async {
    bool hasPermission = await checkAndRequestStoragePermission();
    if (hasPermission) {
      print("Storage permission granted!");
    } else {
      print("Storage permission denied!");
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.pause();
    _videoPlayerController?.dispose();

    try {
      ref.read(audioPlayerControllerProvider.notifier).stopAudio();
    } catch (e) {
      print('Error stopping audio: $e');
    }

    try {
      _videoCompressor.cancelCompression();
    } catch (e) {
      print('Error canceling compression: $e');
    }

    super.dispose();
  }

  Future<void> _pickVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);

        final fileSize = await file.length();
        final fileSizeInMb = fileSize / (1024 * 1024);
        const maxSizeInMb = 10.0;

        if (fileSizeInMb > maxSizeInMb) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Video must be less than 10MB. Please select a smaller file.'),
            ),
          );
          return;
        }

        setState(() {
          _videoFile = file;
          _hasVideoError = false;
          _compressedVideoFile = null;
        });

        _initializeVideoPlayer(file);

        _generateThumbnailFromVideo(file);
      }
    } catch (e) {
      print('Error picking video: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting video: $e')),
      );
    }
  }

  Future<void> _compressVideo(File file) async {
    setState(() {
      _isCompressingVideo = true;
      _compressionProgress = 0.0;
    });

    try {
      final shouldCompress = await _videoCompressor.shouldCompressVideo(file);

      if (!shouldCompress) {
        setState(() {
          _isCompressingVideo = false;
          _compressedVideoFile = file;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video is already optimized')),
        );
        return;
      }

      final compressedFile = await _videoCompressor.compressVideo(
        file,
        onProgress: (progress) {
          setState(() {
            _compressionProgress = progress;
          });
        },
      );

      if (compressedFile != null) {
        setState(() {
          _compressedVideoFile = compressedFile;
        });

        _initializeVideoPlayer(compressedFile);

        _generateThumbnailFromVideo(compressedFile);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video compressed successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to compress video, using original')),
        );

        setState(() {
          _compressedVideoFile = file;
        });
      }
    } catch (e) {
      print('Error during compression: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error compressing video: $e')),
      );

      setState(() {
        _compressedVideoFile = file;
      });
    } finally {
      setState(() {
        _isCompressingVideo = false;
      });
    }
  }

  void _initializeVideoPlayer(File file) {
    _videoPlayerController?.dispose();

    try {
      _videoPlayerController = VideoPlayerController.file(file)
        ..initialize().then((_) {
          setState(() {});
        }).catchError((error) {
          print('Error initializing video player: $error');
          setState(() {
            _hasVideoError = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading video: $error')),
          );
        });
    } catch (e) {
      print('Error creating video player: $e');
      setState(() {
        _hasVideoError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading video: $e')),
      );
    }
  }

  Future<void> _generateThumbnailFromVideo(File videoFile) async {
    setState(() {
      _isGeneratingThumbnail = true;
    });

    try {
      final thumbnailFile =
          await _videoCompressor.getThumbnailFromVideo(videoFile);

      if (thumbnailFile != null) {
        setState(() {
          _thumbnailFile = thumbnailFile;
        });
      } else {
        await _generateThumbnail();
      }
    } catch (e) {
      await _generateThumbnail();
    } finally {
      setState(() {
        _isGeneratingThumbnail = false;
      });
    }
  }

  Future<void> _generateThumbnail() async {
    if (_videoPlayerController == null ||
        !_videoPlayerController!.value.isInitialized) {
      return;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnailFile = File(
          '${tempDir.path}/thumbnail_${DateTime.now().millisecondsSinceEpoch}.jpg');

      final placeholderImage = await _createPlaceholderImage();
      await thumbnailFile.writeAsBytes(placeholderImage);

      setState(() {
        _thumbnailFile = thumbnailFile;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate thumbnail: $e')),
      );
    }
  }

  Future<Uint8List> _createPlaceholderImage() async {
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

  Future<void> _selectAudio() async {
    final audiosAsync = ref.read(audioNotifierProvider);
    if (audiosAsync is AsyncError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error loading audio data. Please try again.')),
      );
      return;
    }

    ref.read(audioPlayerControllerProvider.notifier).stopAudio();

    final result = await Navigator.push<Audio>(
      context,
      MaterialPageRoute(
        builder: (context) => AudioSelectionScreen(
          onAudioSelected: (audio) => audio,
          initialAudioId: _selectedAudio?.id,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedAudio = result;
      });

      if (_selectedAudio != null) {
        ref
            .read(audioNotifierProvider.notifier)
            .incrementUsageCount(_selectedAudio!.id);
      }
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

    final videoToUpload = _compressedVideoFile ?? _videoFile!;
    final videoSize = await videoToUpload.length();
    const maxSize = 10 * 1024 * 1024;

    if (videoSize > maxSize) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose a video less than 10MB'),
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      await ref.read(videoNotifierProvider.notifier).uploadVideo(
            videoFile: videoToUpload,
            thumbnailFile: _thumbnailFile!,
            description: _description,
            audioName: _selectedAudio?.title ?? 'Original Sound',
            audioId: _selectedAudio?.id,
          );

      setState(() {
        _videoFile = null;
        _compressedVideoFile = null;
        _thumbnailFile = null;
        _description = '';
        _selectedAudio = null;
        _videoPlayerController?.dispose();
        _videoPlayerController = null;
      });

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
    final audiosAsync = ref.watch(audioNotifierProvider);

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
                if (_isCompressingVideo)
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.black,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: _compressionProgress,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Compressing video: ${(_compressionProgress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_hasVideoError)
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
                  Container(
                    height: 300,
                    width: double.infinity,
                    color: Colors.black,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: _videoPlayerController!.value.aspectRatio,
                        child: VideoPlayerWithAudio(
                          videoController: _videoPlayerController!,
                          audio: _selectedAudio,
                          autoplay: true,
                          looping: true,
                          muted: _selectedAudio != null,
                        ),
                      ),
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
                if (_compressedVideoFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 16),
                        const SizedBox(width: 4),
                        const Text('Video compressed',
                            style: TextStyle(color: Colors.green)),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _compressVideo(_videoFile!),
                          child: const Text('Recompress'),
                        ),
                      ],
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
                              onPressed: () => _generateThumbnailFromVideo(
                                  _compressedVideoFile ?? _videoFile!),
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
                  textInputAction: TextInputAction.done,
                  onChanged: (value) {
                    setState(() {
                      _description = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Sound',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                audiosAsync.when(
                  data: (audios) {
                    return GestureDetector(
                      onTap: _selectAudio,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: _selectedAudio != null
                                  ? Colors.blue
                                  : Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          color: _selectedAudio != null
                              ? Colors.blue.withOpacity(0.1)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.music_note,
                              color: _selectedAudio != null
                                  ? Colors.blue
                                  : Colors.grey,
                              size: 30,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedAudio?.title ?? 'Select Sound',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: _selectedAudio != null
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                  ),
                                  if (_selectedAudio != null)
                                    Text(
                                      _selectedAudio!.artist,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right,
                                color: Colors.grey, size: 30),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stackTrace) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Error loading audio data: $error'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(audioNotifierProvider.notifier)
                              .refreshAudios();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
