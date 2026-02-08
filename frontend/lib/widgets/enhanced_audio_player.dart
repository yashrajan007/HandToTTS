import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:html' as html if (kIsWeb) 'dart:async';

class ParagraphSegment {
  final String text;
  final int index;

  ParagraphSegment({required this.text, required this.index});
}

class EnhancedAudioPlayer extends StatefulWidget {
  final Uint8List audioData;
  final List<ParagraphSegment> paragraphs;
  final String extractedText;

  const EnhancedAudioPlayer({
    Key? key,
    required this.audioData,
    required this.paragraphs,
    required this.extractedText,
  }) : super(key: key);

  @override
  State<EnhancedAudioPlayer> createState() => _EnhancedAudioPlayerState();
}

class _EnhancedAudioPlayerState extends State<EnhancedAudioPlayer> {
  late String _audioUrl;
  late html.AudioElement _audioElement;
  bool isPlaying = false;
  bool isInitialized = false;
  int currentParagraphIndex = 0;
  double playbackSpeed = 1.0;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
  }

  void _initializeAudio() {
    if (kIsWeb) {
      final base64 = base64Encode(widget.audioData);
      _audioUrl = 'data:audio/mpeg;base64,$base64';
      
      _audioElement = html.AudioElement()..src = _audioUrl;
      
      // Listen for audio events
      _audioElement.onPlay.listen((_) {
        if (mounted) setState(() => isPlaying = true);
      });
      
      _audioElement.onPause.listen((_) {
        if (mounted) setState(() => isPlaying = false);
      });
      
      _audioElement.onEnded.listen((_) {
        if (mounted) setState(() => isPlaying = false);
        _moveToNextParagraph();
      });
      
      _audioElement.onTimeUpdate.listen((_) {
        if (!mounted) return;
        setState(() {
          currentPosition = Duration(milliseconds: (_audioElement.currentTime * 1000).toInt());
          totalDuration = Duration(milliseconds: (_audioElement.duration * 1000).toInt());
        });
      });
      
      isInitialized = true;
    }
  }

  void _playAudio() {
    if (kIsWeb && isInitialized) {
      try {
        _audioElement.play();
      } catch (e) {
        _showError('Error playing audio: $e');
      }
    }
  }

  void _pauseAudio() {
    if (kIsWeb && isInitialized) {
      try {
        _audioElement.pause();
      } catch (e) {
        _showError('Error pausing audio: $e');
      }
    }
  }

  void _moveToNextParagraph() {
    if (currentParagraphIndex < widget.paragraphs.length - 1) {
      setState(() => currentParagraphIndex++);
      // In a real implementation, you'd seek to the next paragraph's timestamp
      // For now, just continue playing
    }
  }

  void _moveToPreviousParagraph() {
    if (currentParagraphIndex > 0) {
      setState(() => currentParagraphIndex--);
      // In a real implementation, you'd seek to the previous paragraph's timestamp
      // For now, restart from beginning
      if (kIsWeb && isInitialized) {
        _audioElement.currentTime = 0;
      }
    }
  }

  void _changePlaybackSpeed(double speed) {
    if (kIsWeb && isInitialized) {
      setState(() => playbackSpeed = speed);
      _audioElement.playbackRate = speed;
    }
  }

  void _seek(double newPosition) {
    if (kIsWeb && isInitialized) {
      _audioElement.currentTime = newPosition;
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
            ..setAttribute('download', 'study_notes.mp3')
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
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.15),
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            '🎧 Audio Learning',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          if (kIsWeb && isInitialized) ...[
            // Progress Bar
            Column(
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: Theme.of(context).colorScheme.primary,
                    inactiveTrackColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    thumbColor: Theme.of(context).colorScheme.primary,
                    overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                  child: Slider(
                    value: currentPosition.inMilliseconds.toDouble(),
                    max: totalDuration.inMilliseconds.toDouble() > 0
                        ? totalDuration.inMilliseconds.toDouble()
                        : 1.0,
                    onChanged: (value) {
                      _seek(value / 1000);
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(currentPosition),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      _formatDuration(totalDuration),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Main Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Backtrack
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  tooltip: 'Previous (Backtrack)',
                  onPressed: _moveToPreviousParagraph,
                  color: Theme.of(context).colorScheme.primary,
                )
                    .withBadge(currentParagraphIndex > 0 ? '' : null),
                const SizedBox(width: 12),

                // Play/Pause
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 28,
                    ),
                    tooltip: isPlaying ? 'Pause' : 'Play',
                    onPressed: isPlaying ? _pauseAudio : _playAudio,
                    iconSize: 32,
                  ),
                ),
                const SizedBox(width: 12),

                // Next
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  tooltip: 'Next',
                  onPressed: _moveToNextParagraph,
                  color: Theme.of(context).colorScheme.primary,
                )
                    .withBadge(currentParagraphIndex < widget.paragraphs.length - 1 ? '' : null),
              ],
            ),
            const SizedBox(height: 16),

            // Secondary Controls
            Row(
              children: [
                // Speed Control
                Expanded(
                  child: PopupMenuButton<double>(
                    initialValue: playbackSpeed,
                    onSelected: _changePlaybackSpeed,
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 0.5, child: Text('0.5x')),
                      const PopupMenuItem(value: 0.75, child: Text('0.75x')),
                      const PopupMenuItem(value: 1.0, child: Text('1.0x (Normal)')),
                      const PopupMenuItem(value: 1.25, child: Text('1.25x')),
                      const PopupMenuItem(value: 1.5, child: Text('1.5x')),
                      const PopupMenuItem(value: 2.0, child: Text('2.0x')),
                    ],
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.speed),
                      label: Text('${playbackSpeed}x'),
                      onPressed: null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Download
                Expanded(
                  child: FilledButton.tonalIcon(
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                    onPressed: _downloadAudio,
                  ),
                ),
              ],
            ),

            // Paragraph Info
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue.withOpacity(0.08),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.description,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Section ${currentParagraphIndex + 1} of ${widget.paragraphs.length}',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.blue.withOpacity(0.1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Audio playback available on web platform',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (kIsWeb && isInitialized) {
      _audioElement.pause();
      _audioElement.src = '';
    }
    super.dispose();
  }
}

extension on Widget {
  Widget withBadge(String? badge) {
    if (badge == null) return this;
    return Stack(
      children: [
        this,
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Text(
              '✓',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }
}
