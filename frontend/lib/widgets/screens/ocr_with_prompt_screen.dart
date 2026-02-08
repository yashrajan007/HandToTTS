import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ocr_provider.dart';
import '../image_picker_widget.dart';
import '../result_display_widget.dart';

class OcrWithPromptScreen extends StatefulWidget {
  const OcrWithPromptScreen({Key? key}) : super(key: key);

  @override
  State<OcrWithPromptScreen> createState() => _OcrWithPromptScreenState();
}

class _OcrWithPromptScreenState extends State<OcrWithPromptScreen> {
  late TextEditingController _promptController;

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController(
      text:
          'Extract all text from this image. Preserve the layout and structure as much as possible.',
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
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
            // Image Picker
            ImagePickerWidget(
              selectedImagePath: provider.selectedImagePath,
              onImageSelected: (path) {
                provider.setImagePath(path);
              },
            ),
            const SizedBox(height: 24),

            // Custom Prompt Text Field
            TextFormField(
              controller: _promptController,
              minLines: 4,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: 'Custom Prompt',
                hintText: 'Enter your custom prompt for OCR...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                alignLabelWithHint: true,
              ),
              onChanged: (value) {
                provider.setCustomPrompt(value);
              },
            ),
            const SizedBox(height: 24),

            // Language Selection
            _buildLanguageSelector(context, provider),
            const SizedBox(height: 24),

            // Extract Button with Prompt
            if (provider.selectedImagePath != null)
              ElevatedButton.icon(
                onPressed: provider.isProcessing
                    ? null
                    : () {
                        provider.extractTextWithCustomPrompt();
                      },
                icon: provider.isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.edit),
                label: Text(
                  provider.isProcessing
                      ? 'Processing...'
                      : 'Extract with Prompt',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
