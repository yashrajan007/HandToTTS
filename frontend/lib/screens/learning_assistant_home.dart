import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import '../providers/ocr_provider.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/web_camera_capture.dart';
import '../widgets/platform_audio_player.dart';

class TextScannerScreen extends StatefulWidget {
  const TextScannerScreen({Key? key}) : super(key: key);

  @override
  State<TextScannerScreen> createState() => _TextScannerScreenState();
}

class _TextScannerScreenState extends State<TextScannerScreen> {
  final ImagePicker _picker = ImagePicker();

  // Audio player state
  final PlatformAudioPlayer _audioPlayer = PlatformAudioPlayer();
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void dispose() {
    _disposeAudio();
    super.dispose();
  }

  void _disposeAudio() {
    _audioPlayer.dispose();
  }

  void _initAudio(Uint8List data) {
    _disposeAudio();

    _audioPlayer.init(
      data,
      onCanPlay: () {
        if (mounted) setState(() {});
      },
      onPlay: () {
        if (mounted) setState(() => _isPlaying = true);
      },
      onPause: () {
        if (mounted) setState(() => _isPlaying = false);
      },
      onEnded: () {
        if (mounted) setState(() => _isPlaying = false);
      },
      onTimeUpdate: (currentTime, duration) {
        if (!mounted) return;
        setState(() {
          _position = Duration(milliseconds: (currentTime * 1000).toInt());
          if (duration > 0) {
            _duration = Duration(milliseconds: (duration * 1000).toInt());
          }
        });
      },
    );
  }

  void _togglePlay() {
    if (!_audioPlayer.isInitialized) return;
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void _seek(double ms) {
    _audioPlayer.seekTo(ms / 1000);
  }

  void _setSpeed(double speed) {
    setState(() => _playbackSpeed = speed);
    _audioPlayer.setPlaybackRate(speed);
  }

  void _rewind10() {
    if (!_audioPlayer.isInitialized) return;
    _audioPlayer
        .seekTo((_audioPlayer.currentTime - 10).clamp(0, double.infinity));
  }

  void _forward10() {
    if (!_audioPlayer.isInitialized) return;
    final dur = _audioPlayer.duration;
    if (dur > 0) {
      _audioPlayer.seekTo((_audioPlayer.currentTime + 10).clamp(0, dur));
    }
  }

  void _downloadAudio() {
    if (!_audioPlayer.isInitialized) return;
    webDownloadAudio(_audioPlayer);
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60);
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  // ─── Image picking ───

  Future<void> _pickImage(ImageSource source) async {
    final provider = context.read<OcrProvider>();
    final image = await _picker.pickImage(source: source);
    if (image != null && mounted) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        provider.setImageBytes(bytes,
            name: image.name, mimeType: image.mimeType ?? 'image/jpeg');
      } else {
        provider.setImagePath(image.path);
      }
      await _scanImage(provider);
    }
  }

  Future<void> _captureFromCamera() async {
    if (kIsWeb) {
      final bytes = await WebCameraCapture.capture(context);
      if (bytes != null && mounted) {
        final provider = context.read<OcrProvider>();
        provider.setImageBytes(bytes,
            name: 'capture.jpg', mimeType: 'image/jpeg');
        await _scanImage(provider);
      }
    } else {
      _pickImage(ImageSource.camera);
    }
  }

  Future<void> _scanImage(OcrProvider provider) async {
    _disposeAudio();
    if (mounted) setState(() {});
    await provider.extractTextFromImage();
  }

  Future<void> _readAloud(OcrProvider provider) async {
    await provider.convertTextToAudio(provider.extractedText ?? '');
    if (provider.audioData != null && provider.audioData!.isNotEmpty) {
      _initAudio(provider.audioData!);
    }
  }

  // ─── BUILD ───

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Consumer<OcrProvider>(
        builder: (context, provider, _) {
          final hasText = (provider.extractedText ?? '').isNotEmpty;
          final hasImage = provider.selectedImagePath != null ||
              provider.selectedImageBytes != null;
          final hasAudio = _audioPlayer.isInitialized;

          return CustomScrollView(
            slivers: [
              // ─── App Bar ───
              SliverAppBar(
                floating: true,
                pinned: true,
                expandedHeight: 100,
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                flexibleSpace: FlexibleSpaceBar(
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.document_scanner,
                          size: 20, color: cs.onPrimary),
                      const SizedBox(width: 8),
                      const Text('Student Helper'),
                    ],
                  ),
                  centerTitle: true,
                ),
                actions: [
                  if (hasImage || hasText)
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'New Scan',
                      onPressed: () {
                        provider.clearAll();
                        _disposeAudio();
                        setState(() {});
                      },
                    ),
                ],
              ),

              // ─── Body ───
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Error
                    if (provider.error != null) ...[
                      _buildError(provider.error!),
                      const SizedBox(height: 16),
                    ],

                    // ── Scan Buttons (shown when no text yet) ──
                    if (!hasText && !provider.isProcessing) ...[
                      _buildScanArea(cs, provider),
                      const SizedBox(height: 16),
                      _buildLangChip(provider, cs),
                    ],

                    // ── Processing ──
                    if (provider.isProcessing) _buildProcessing(cs),

                    // ── Scanned Result ──
                    if (hasText && !provider.isProcessing) ...[
                      _buildResultCard(provider, cs),
                      const SizedBox(height: 12),

                      // Read Aloud button
                      if (!hasAudio && !provider.isProcessing)
                        _buildReadAloudButton(provider, cs),

                      // Audio Player
                      if (hasAudio) ...[
                        const SizedBox(height: 12),
                        _buildPlayer(cs),
                      ],

                      const SizedBox(height: 12),
                      _buildLangChip(provider, cs),
                    ],
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── Scan Area ───

  Widget _buildScanArea(ColorScheme cs, OcrProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.primary.withOpacity(0.3),
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
        color: cs.primary.withOpacity(0.04),
      ),
      child: Column(
        children: [
          Icon(Icons.document_scanner_outlined,
              size: 64, color: cs.primary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'Scan your text',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w600, color: cs.onSurface),
          ),
          const SizedBox(height: 6),
          Text(
            'Take a photo or upload an image of printed or handwritten text',
            textAlign: TextAlign.center,
            style:
                TextStyle(fontSize: 13, color: cs.onSurface.withOpacity(0.6)),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.camera_alt, size: 20),
                  label: const Text('Camera'),
                  onPressed: _captureFromCamera,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.photo_library, size: 20),
                  label: const Text('Gallery'),
                  onPressed: () => _pickImage(ImageSource.gallery),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Processing ───

  Widget _buildProcessing(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text('Scanning...',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface)),
          const SizedBox(height: 4),
          Text('Extracting text from your image',
              style: TextStyle(
                  fontSize: 13, color: cs.onSurface.withOpacity(0.5))),
        ],
      ),
    );
  }

  // ─── Result Card ───

  Widget _buildResultCard(OcrProvider provider, ColorScheme cs) {
    final text = provider.extractedText ?? '';
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.text_snippet, size: 20, color: cs.primary),
                const SizedBox(width: 8),
                Text('Scanned Text',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: cs.onSurface)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('$words words',
                      style: TextStyle(
                          fontSize: 11, color: cs.onPrimaryContainer)),
                ),
              ],
            ),
            const Divider(height: 24),

            // Text content
            SelectableText(
              text,
              style: TextStyle(fontSize: 14, height: 1.6, color: cs.onSurface),
              maxLines: 12,
            ),
            if (text.length > 500) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.expand_more, size: 18),
                label: const Text('Show all'),
                onPressed: () => _showFullText(text),
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact),
              ),
            ],

            const SizedBox(height: 12),

            // Action row
            Row(
              children: [
                _actionChip(Icons.copy, 'Copy', () {
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Copied to clipboard'),
                        duration: Duration(seconds: 1)),
                  );
                }, cs),
                const SizedBox(width: 8),
                _actionChip(Icons.camera_alt, 'Rescan', () {
                  provider.clearAll();
                  _disposeAudio();
                  setState(() {});
                }, cs),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionChip(
      IconData icon, String label, VoidCallback onTap, ColorScheme cs) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
    );
  }

  // ─── Read Aloud Button ───

  Widget _buildReadAloudButton(OcrProvider provider, ColorScheme cs) {
    return FilledButton.icon(
      icon: provider.isProcessing
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: cs.onPrimary))
          : const Icon(Icons.volume_up),
      label: Text(provider.isProcessing ? 'Generating audio...' : 'Read Aloud'),
      onPressed: provider.isProcessing ? null : () => _readAloud(provider),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─── Audio Player ───

  Widget _buildPlayer(ColorScheme cs) {
    return Card(
      elevation: 0,
      color: cs.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.primary.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Progress
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                activeTrackColor: cs.primary,
                inactiveTrackColor: cs.primary.withOpacity(0.15),
                thumbColor: cs.primary,
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              ),
              child: Slider(
                value: _position.inMilliseconds
                    .toDouble()
                    .clamp(0, _duration.inMilliseconds.toDouble()),
                max: _duration.inMilliseconds > 0
                    ? _duration.inMilliseconds.toDouble()
                    : 1,
                onChanged: _seek,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_fmt(_position),
                      style: TextStyle(
                          fontSize: 11, color: cs.onSurface.withOpacity(0.6))),
                  Text(_fmt(_duration),
                      style: TextStyle(
                          fontSize: 11, color: cs.onSurface.withOpacity(0.6))),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Speed
                PopupMenuButton<double>(
                  initialValue: _playbackSpeed,
                  onSelected: _setSpeed,
                  tooltip: 'Playback speed',
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 0.5, child: Text('0.5x')),
                    PopupMenuItem(value: 0.75, child: Text('0.75x')),
                    PopupMenuItem(value: 1.0, child: Text('1x')),
                    PopupMenuItem(value: 1.25, child: Text('1.25x')),
                    PopupMenuItem(value: 1.5, child: Text('1.5x')),
                    PopupMenuItem(value: 2.0, child: Text('2x')),
                  ],
                  child: Chip(
                    label: Text('${_playbackSpeed}x',
                        style: const TextStyle(fontSize: 12)),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(width: 8),

                // Rewind 10s
                IconButton(
                  icon: const Icon(Icons.replay_10),
                  onPressed: _rewind10,
                  tooltip: 'Rewind 10s',
                  color: cs.primary,
                ),

                // Play / Pause
                FilledButton(
                  onPressed: _togglePlay,
                  style: FilledButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(14),
                  ),
                  child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 28),
                ),

                // Forward 10s
                IconButton(
                  icon: const Icon(Icons.forward_10),
                  onPressed: _forward10,
                  tooltip: 'Forward 10s',
                  color: cs.primary,
                ),
                const SizedBox(width: 8),

                // Download
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: _downloadAudio,
                  tooltip: 'Download MP3',
                  color: cs.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Language Chip ───

  Widget _buildLangChip(OcrProvider provider, ColorScheme cs) {
    const langs = {
      'en': 'English',
      'hi': 'Hindi',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
    };

    return Row(
      children: [
        Icon(Icons.language, size: 18, color: cs.onSurface.withOpacity(0.5)),
        const SizedBox(width: 8),
        Text('Language:',
            style:
                TextStyle(fontSize: 13, color: cs.onSurface.withOpacity(0.6))),
        const SizedBox(width: 8),
        ...langs.entries.map((e) {
          final selected = provider.selectedLanguage == e.key;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(e.value, style: const TextStyle(fontSize: 12)),
              selected: selected,
              onSelected: (_) => provider.setLanguage(e.key),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            ),
          );
        }),
      ],
    );
  }

  // ─── Error ───

  Widget _buildError(String msg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(msg,
                style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // ─── Full text dialog ───

  void _showFullText(String text) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Full Text'),
        content: SingleChildScrollView(child: SelectableText(text)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
  }
}
