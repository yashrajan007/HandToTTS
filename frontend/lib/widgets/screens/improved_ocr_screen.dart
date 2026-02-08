import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ocr_provider.dart';
import '../image_picker_widget.dart';
import '../result_display_widget.dart';
import '../status_widgets.dart' as status;

class ImprovedOcrScreen extends StatelessWidget {
  const ImprovedOcrScreen({Key? key}) : super(key: key);

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
              FilledButton.icon(
                onPressed: provider.isProcessing
                    ? null
                    : () {
                        provider.extractTextFromImage();
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
                    : const Icon(Icons.text_fields),
                label: Text(
                  provider.isProcessing ? 'Processing...' : 'Extract Text',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ).withPadding(),

            // Convert to Audio Button
            if (provider.extractedText != null && !provider.isProcessing)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: FilledButton.tonalIcon(
                  onPressed: () {
                    provider.convertImageToAudio();
                  },
                  icon: const Icon(Icons.volume_up),
                  label: const Text(
                    'Convert Text to Audio',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Processing state
            if (provider.isProcessing)
              const status.ProcessingWidget(
                message: 'Extracting text from image...',
              ),

            // Error Display
            if (provider.error != null)
              status.ErrorWidget(
                error: provider.error!,
                onDismiss: () => provider.clearError(),
              ),

            const SizedBox(height: 24),

            // Result Display
            if (provider.extractedText != null && !provider.isProcessing)
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
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
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
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    provider.setLanguage(value);
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

extension on Widget {
  Widget withPadding() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: this,
      );
}
