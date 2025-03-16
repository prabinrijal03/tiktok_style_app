import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/audio/audio.dart';
import '../../utils/audio_manager.dart';
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

class _AudioSelectionScreenState extends ConsumerState<AudioSelectionScreen>
    with SingleTickerProviderStateMixin {
  String? _searchQuery;
  Audio? _selectedAudio;
  late TabController _tabController;
  final AudioManager _audioManager = AudioManager();
  final String _previewVideoId = 'audio_preview';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialAudio();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Sound'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
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
                      _searchQuery =
                          value.isNotEmpty ? value.toLowerCase() : null;
                    });
                  },
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Trending'),
                  Tab(text: 'Favorites'),
                  Tab(text: 'Discover'),
                ],
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
              ),
            ],
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

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAudioList(
                filteredAudios.where((a) => a.usageCount > 500000).toList()
                  ..sort((a, b) => b.usageCount.compareTo(a.usageCount)),
              ),
              _buildAudioList(
                filteredAudios.where((a) => a.isFavorite).toList(),
              ),
              _buildAudioList(filteredAudios),
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
                  ref.read(audioNotifierProvider.notifier).refreshAudios();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: audiosAsync.maybeWhen(
        data: (audios) => _selectedAudio != null ? _buildBottomBar() : null,
        orElse: () => null,
      ),
    );
  }

  Widget _buildAudioList(List<Audio> audios) {
    if (audios.isEmpty) {
      return const Center(
        child: Text('No sounds found in this category'),
      );
    }

    return ListView.builder(
      itemCount: audios.length,
      itemBuilder: (context, index) {
        final audio = audios[index];
        final isPlaying = _audioManager.isPlaying(audio.id, _previewVideoId);
        final isSelected =
            _selectedAudio?.id == audio.id || widget.initialAudioId == audio.id;

        return _buildAudioListItem(audio, isPlaying, isSelected);
      },
    );
  }

  Widget _buildAudioListItem(Audio audio, bool isPlaying, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedAudio = audio;
        });

        if (isPlaying) {
          _audioManager.pauseAudio();
        } else {
          _audioManager.playAudio(audio, _previewVideoId);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade800,
              width: 0.5,
            ),
          ),
          color: isSelected ? Colors.grey.shade900 : null,
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    image: DecorationImage(
                      image: NetworkImage(audio.coverUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                ),
                Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 30,
                ),
                if (isPlaying)
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    audio.title,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    audio.artist,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatDuration(audio.duration)} | ${_formatCount(audio.usageCount)} uses',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    audio.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: audio.isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    ref
                        .read(audioNotifierProvider.notifier)
                        .favoriteAudio(audio.id);
                  },
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: Colors.blue, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    if (_selectedAudio == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade800,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(_selectedAudio!.coverUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedAudio!.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _selectedAudio!.artist,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Audio feature coming soon in hired version'),
                ),
              );

              _audioManager.stopAudio();

              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Use this sound'),
          ),
        ],
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
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return '$count';
    }
  }
}
