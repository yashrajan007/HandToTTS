import 'package:ocr_app/widgets/enhanced_audio_player.dart';

class TextParser {
  /// Segments text into paragraphs
  static List<ParagraphSegment> segmentIntoParagraphs(String text) {
    // Split by double newlines or significant breaks
    List<String> rawParagraphs = text.split(RegExp(r'\n\s*\n+'));

    List<ParagraphSegment> segments = [];

    for (int i = 0; i < rawParagraphs.length; i++) {
      String para = rawParagraphs[i].trim();

      // Skip empty paragraphs
      if (para.isEmpty) continue;

      // Further split long paragraphs by sentences if needed
      List<String> sentences = _splitBySentences(para);

      for (String sentence in sentences) {
        if (sentence.trim().isNotEmpty) {
          segments.add(
            ParagraphSegment(
              text: sentence.trim(),
              index: segments.length,
            ),
          );
        }
      }
    }

    // If no segments found, treat entire text as one segment
    if (segments.isEmpty) {
      segments.add(ParagraphSegment(text: text, index: 0));
    }

    return segments;
  }

  /// Splits text into sentences
  static List<String> _splitBySentences(String text) {
    // Split by sentence-ending punctuation followed by space
    List<String> sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
    return sentences;
  }

  /// Segments text into paragraphs only (no sentence splitting)
  static List<ParagraphSegment> segmentIntoParagraphsOnly(String text) {
    List<String> rawParagraphs = text.split(RegExp(r'\n\s*\n+'));

    List<ParagraphSegment> segments = [];

    for (int i = 0; i < rawParagraphs.length; i++) {
      String para = rawParagraphs[i].trim();

      if (para.isNotEmpty) {
        segments.add(
          ParagraphSegment(
            text: para,
            index: segments.length,
          ),
        );
      }
    }

    if (segments.isEmpty) {
      segments.add(ParagraphSegment(text: text, index: 0));
    }

    return segments;
  }

  /// Formats text for better readability
  static String formatText(String text) {
    // Remove extra whitespace
    String formatted = text.replaceAll(RegExp(r' +'), ' ').trim();

    // Capitalize sentences
    List<String> sentences = _splitBySentences(formatted);
    List<String> capitalizedSentences = sentences.map((s) {
      String trimmed = s.trim();
      if (trimmed.isEmpty) return trimmed;
      return trimmed[0].toUpperCase() + trimmed.substring(1);
    }).toList();

    return capitalizedSentences.join(' ');
  }

  /// Gets a summary/preview of text
  static String getSummary(String text, {int maxLines = 3}) {
    List<String> lines =
        text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    return lines.take(maxLines).join('\n');
  }
}
