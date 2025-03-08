// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/audio/audio.dart';
import '../providers/audio_providers/audio_providers.dart';

class AudioDebugScreen extends ConsumerWidget {
  const AudioDebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audiosAsync = ref.watch(audioNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(audioNotifierProvider.notifier).refreshAudios();
            },
          ),
        ],
      ),
      body: audiosAsync.when(
        data: (audios) {
          if (audios.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No audio data found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _reinitializeAudioData(context, ref);
                    },
                    child: const Text('Reinitialize Audio Data'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: audios.length,
            itemBuilder: (context, index) {
              final audio = audios[index];
              return _buildAudioItem(context, audio, ref);
            },
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
                  ref.read(audioNotifierProvider.notifier).refreshAudios();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _reinitializeAudioData(context, ref);
        },
        child: const Icon(Icons.restart_alt),
      ),
    );
  }

  Widget _buildAudioItem(BuildContext context, Audio audio, WidgetRef ref) {
    final audioPlayer = ref.watch(audioPlayerControllerProvider.notifier);
    final isPlaying = audioPlayer.isPlaying(audio.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            if (isPlaying) {
              audioPlayer.stopAudio();
            } else {
              audioPlayer.playAudio(audio);
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  image: DecorationImage(
                    image: NetworkImage(audio.coverUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.black.withOpacity(0.5),
                ),
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        title: Text(audio.title),
        subtitle: Text('${audio.artist} • ${_formatDuration(audio.duration)}'),
        trailing: Text('${_formatCount(audio.usageCount)} uses'),
        onTap: () {
          _showAudioDetails(context, audio);
        },
      ),
    );
  }

  void _showAudioDetails(BuildContext context, Audio audio) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(audio.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${audio.id}'),
            const SizedBox(height: 8),
            Text('Artist: ${audio.artist}'),
            const SizedBox(height: 8),
            Text('Duration: ${_formatDuration(audio.duration)}'),
            const SizedBox(height: 8),
            Text('Usage Count: ${audio.usageCount}'),
            const SizedBox(height: 8),
            Text('Favorite: ${audio.isFavorite ? 'Yes' : 'No'}'),
            const SizedBox(height: 8),
            Text('Audio URL: ${audio.audioUrl}'),
            const SizedBox(height: 8),
            Text('Cover URL: ${audio.coverUrl}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _reinitializeAudioData(
      BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('Reinitializing Audio Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Please wait...'),
          ],
        ),
      ),
    );

    try {
      await ref.read(audioNotifierProvider.notifier).refreshAudios();

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio data reinitialized')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
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
