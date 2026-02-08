import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:html' as html if (kIsWeb) 'dart:async';

class SimpleAudioPlayer extends StatefulWidget {
  final Uint8List audioData;

  const SimpleAudioPlayer({Key? key, required this.audioData})
      : super(key: key);

  @override
  State<SimpleAudioPlayer> createState() => _SimpleAudioPlayerState();
}

class _SimpleAudioPlayerState extends State<SimpleAudioPlayer> {
  late String _audioUrl;

  @override
  void initState() {
    super.initState();
    final base64 = base64Encode(widget.audioData);
    _audioUrl = 'data:audio/mpeg;base64,$base64';
  }

  void _playAudio() {
    if (kIsWeb) {
      try {
        final audio = html.AudioElement()
          ..src = _audioUrl
          ..autoplay = true;
        audio.play();
      } catch (e) {
        _showError('Error playing audio: $e');
      }
    }
  }

  void _downloadAudio() {
    if (kIsWeb) {
      try {
        final parts = _audioUrl.split(',');
        if (parts.length == 2) {
          final bytes = base64Decode(parts[1]);
          final blob = html.Blob([bytes], 'audio/mpeg');
          final url = html.Url.createObjectUrlFromBlob(blob);
          
          html.AnchorElement(href: url)
            ..setAttribute('download', 'audio.mp3')
            ..click();
          
          html.Url.revokeObjectUrl(url);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Audio downloaded'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        _showError('Download failed: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Audio Preview',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (kIsWeb)
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _playAudio,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play'),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.tonalIcon(
                  onPressed: _downloadAudio,
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.blue.withOpacity(0.1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.music_note, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Audio available on web platform',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
