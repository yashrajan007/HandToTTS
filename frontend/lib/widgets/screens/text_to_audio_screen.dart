import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ocr_provider.dart';
import '../simple_audio_player.dart';

class TextToAudioScreen extends StatefulWidget {
  const TextToAudioScreen({Key? key}) : super(key: key);

  @override
  State<TextToAudioScreen> createState() => _TextToAudioScreenState();
}

class _TextToAudioScreenState extends State<TextToAudioScreen> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    }  
    
    @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OcrProvider>(
      builder: (context, provider, _) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Text Input Field
            TextFormField(
              controller: _textController,
              minLines: 6,
              maxLines: 10,
              decoration: InputDecoration(
                labelText: 'Enter Text',
                hintText: 'Enter the text you want to convert to audio...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            // Language Selection
            _buildLanguageSelector(context, provider),
            const SizedBox(height: 24),

            // Convert Button
            FilledButton.icon(
              onPressed: provider.isProcessing || _textController.text.isEmpty
                  ? null
                  : () {
                      provider.convertTextToAudio(_textController.text);
                    },
              icon: provider.isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Icon(Icons.volume_up),
              label: Text(
                provider.isProcessing ? 'Processing...' : 'Convert to Audio',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Error Display
            if (provider.error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  provider.error!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),

            const SizedBox(height: 24),

            // Audio Player
            if (provider.audioData != null)
              SimpleAudioPlayer(audioData: provider.audioData!),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, OcrProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Language',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: provider.selectedLanguage,
          isExpanded: true,
          items: {
            'en': 'English',
            'es': 'Spanish',
            'fr': 'French',
            'de': 'German',
            'hi': 'Hindi',
            'ja': 'Japanese',
            'ko': 'Korean',
          }
              .entries
              .map(
                (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              provider.setLanguage(value);
            }
          },
        ),
      ],
    );
  }
}
