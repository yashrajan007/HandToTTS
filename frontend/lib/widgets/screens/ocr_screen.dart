import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ocr_provider.dart';
import '../image_picker_widget.dart';
import '../result_display_widget.dart';

class OcrScreen extends StatelessWidget {
  const OcrScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OcrProvider>(
      builder: (context, provider, _) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Picker
            ImagePickerWidget(
              selectedImagePath: provider.selectedImagePath,
              onImageSelected: (path) {
                provider.setImagePath(path);
              },
            ),
            const SizedBox(height: 24),

            // Language Selection
            _buildLanguageSelector(context, provider),
            const SizedBox(height: 24),

            // Extract Button
            if (provider.selectedImagePath != null)
              ElevatedButton.icon(
                onPressed: provider.isProcessing
                    ? null
                    : () {
                        provider.extractTextFromImage();
                      },
                icon: provider.isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.text_fields),
                label: Text(
                  provider.isProcessing ? 'Processing...' : 'Extract Text',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

            // Convert to Audio Button
            if (provider.extractedText != null && !provider.isProcessing)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: OutlinedButton.icon(
                  onPressed: () {
                    provider.convertImageToAudio();
                  },
                  icon: const Icon(Icons.volume_up),
                  label: const Text(
                    'Convert Text to Audio',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
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

            // Result Display
            if (provider.extractedText != null)
              ResultDisplayWidget(
                text: provider.extractedText!,
                audioData: provider.audioData,
              ),
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
          'Audio Language',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: provider.selectedLanguage,
          isExpanded: true,
          items:
              {
                    'en': 'English',
                    'es': 'Spanish',
                    'fr': 'French',
                    'de': 'German',
                    'hi': 'Hindi',
                    'ja': 'Japanese',
                    'ko': 'Korean',
                  }.entries
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
