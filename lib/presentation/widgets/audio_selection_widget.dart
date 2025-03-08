// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/audio/audio.dart';
import '../providers/audio_providers/audio_providers.dart';

class AudioSelectionScreen extends ConsumerStatefulWidget {
  final Function(Audio) onAudioSelected;
  final String? initialAudioId;

  const AudioSelectionScreen({
    super.key,
    required this.onAudioSelected,
    this.initialAudioId,
  });

  @override
  ConsumerState<AudioSelectionScreen> createState() =>
      _AudioSelectionScreenState();
}

class _AudioSelectionScreenState extends ConsumerState<AudioSelectionScreen> {
  String? _searchQuery;
  Audio? _selectedAudio;

  @override
  void initState() {
    super.initState();
    _loadInitialAudio();
  }

  Future<void> _loadInitialAudio() async {
    setState(() {});

    try {
      if (widget.initialAudioId != null) {
        final audioUseCase = ref.read(getAudioByIdUseCaseProvider);
        final audio = await audioUseCase.execute(widget.initialAudioId!);
        setState(() {
          _selectedAudio = audio;
        });
      }
    } catch (e) {
      print('Error loading initial audio: $e');
    } finally {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final audiosAsync = ref.watch(audioNotifierProvider);
    final audioPlayer = ref.watch(audioPlayerControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Sound'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              ref.read(audioNotifierProvider.notifier).debugAudios();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search sounds',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.grey[800],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.isNotEmpty ? value.toLowerCase() : null;
                });
              },
            ),
          ),
        ),
      ),
      body: audiosAsync.when(
        data: (audios) {
          final filteredAudios = _searchQuery != null
              ? audios
                  .where((audio) =>
                      audio.title.toLowerCase().contains(_searchQuery!) ||
                      audio.artist.toLowerCase().contains(_searchQuery!))
                  .toList()
              : audios;

          if (filteredAudios.isEmpty) {
            return const Center(
              child: Text('No sounds found'),
            );
          }

          return ListView.builder(
            itemCount: filteredAudios.length,
            itemBuilder: (context, index) {
              final audio = filteredAudios[index];
              final isPlaying = audioPlayer.isPlaying(audio.id);
              final isSelected = _selectedAudio?.id == audio.id ||
                  widget.initialAudioId == audio.id;

              return ListTile(
                leading: Stack(
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
                    GestureDetector(
                      onTap: () {
                        if (audioPlayer.isPlaying(audio.id)) {
                          audioPlayer.stopAudio();
                        } else {
                          audioPlayer.playAudio(audio);
                        }
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
                title: Text(
                  audio.title,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(audio.artist),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_formatDuration(audio.duration)} | ${_formatCount(audio.usageCount)}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isSelected)
                      const Icon(Icons.check_circle, color: Colors.blue),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _selectedAudio = audio;
                  });

                  if (audioPlayer.isPlaying(audio.id)) {
                    audioPlayer.stopAudio();
                  } else {
                    audioPlayer.playAudio(audio);
                  }
                },
                onLongPress: () {
                  audioPlayer.stopAudio();
                  widget.onAudioSelected(audio);
                  Navigator.pop(context, audio);
                },
              );
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
      bottomNavigationBar: audiosAsync.maybeWhen(
        data: (audios) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _selectedAudio != null
                ? () {
                    audioPlayer.stopAudio();
                    widget.onAudioSelected(_selectedAudio!);
                    Navigator.pop(context, _selectedAudio);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Use Selected Sound'),
          ),
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M uses';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K uses';
    } else {
      return '$count uses';
    }
  }
}
