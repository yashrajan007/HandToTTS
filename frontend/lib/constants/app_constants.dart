class AppConstants {
  // API Configuration
  // Update this URL to point to your backend server
  // For local development: 'http://localhost:8000'
  // For Android emulator: 'http://10.0.2.2:8000'
  // Production: 'https://handtottsbackend-production.up.railway.app'
  static String get baseUrl =>
      'https://handtottsbackend-production.up.railway.app';

  // Supported Languages for TTS
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'hi': 'Hindi',
    'ja': 'Japanese',
    'ko': 'Korean',
    'pt': 'Portuguese',
    'zh-CN': 'Chinese (Simplified)',
    'zh-TW': 'Chinese (Traditional)',
    'ar': 'Arabic',
    'ru': 'Russian',
    'it': 'Italian',
  };

  // File size limits (in bytes)
  static const int maxFileSize = 20 * 1024 * 1024; // 20 MB

  // Supported file types
  static const List<String> supportedImageTypes = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  ];

  // App info
  static const String appName = 'OCR App';
  static const String appVersion = '1.0.0';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
}
