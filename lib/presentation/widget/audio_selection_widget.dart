import 'package:flutter/material.dart';

class AudioSelectionWidget extends StatefulWidget {
  final Function(String?) onAudioSelected;
  final String? initialAudio;

  const AudioSelectionWidget({
    super.key,
    required this.onAudioSelected,
    this.initialAudio,
  });

  @override
  State<AudioSelectionWidget> createState() => _AudioSelectionWidgetState();
}

class _AudioSelectionWidgetState extends State<AudioSelectionWidget> {
  final List<String> _popularAudios = [
    'Original Sound',
    'Trending Beat #1',
    'Summer Vibes',
    'Chill Lofi',
    'Dance Pop',
    'Hip Hop Classic',
  ];

  String? _selectedAudio;

  @override
  void initState() {
    super.initState();
    _selectedAudio = widget.initialAudio;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Audio',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _popularAudios.length,
          itemBuilder: (context, index) {
            final audio = _popularAudios[index];
            final isSelected = _selectedAudio == audio;
            
            return ListTile(
              leading: const Icon(Icons.music_note),
              title: Text(audio),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Colors.blue)
                  : null,
              onTap: () {
                setState(() {
                  _selectedAudio = audio;
                });
                widget.onAudioSelected(_selectedAudio);
              },
            );
          },
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _selectedAudio = null;
            });
            widget.onAudioSelected(null);
          },
          icon: const Icon(Icons.mic_off),
          label: const Text('No Audio'),
        ),
      ],
    );
  }
}

