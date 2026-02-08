import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'simple_audio_player.dart';

class ResultDisplayWidget extends StatefulWidget {
  final String text;
  final Uint8List? audioData;

  const ResultDisplayWidget({Key? key, required this.text, this.audioData})
      : super(key: key);

  @override
  State<ResultDisplayWidget> createState() => _ResultDisplayWidgetState();
}

class _ResultDisplayWidgetState extends State<ResultDisplayWidget> {
  bool _isCopied = false;

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.text)).then((_) {
      setState(() => _isCopied = true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Text copied to clipboard!'),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green.shade600,
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isCopied = false);
        }
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Text('Failed to copy text'),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red.shade600,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Extracted Text',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              FilledButton.icon(
                onPressed: () => _copyToClipboard(context),
                icon: Icon(_isCopied ? Icons.check : Icons.copy),
                label: Text(
                  _isCopied ? 'Copied!' : 'Copy',
                ),
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.withOpacity(0.1),
            ),
            constraints: const BoxConstraints(maxHeight: 300),
            child: SingleChildScrollView(
              child: SelectableText(
                widget.text,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
          ),
          if (widget.audioData != null) ...[
            const SizedBox(height: 24),
            SimpleAudioPlayer(audioData: widget.audioData!),
          ],
        ],
      ),
    );
  }
}
