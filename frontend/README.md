# 📱 Student Helper - OCR & Text-to-Speech App

A powerful Flutter application for Optical Character Recognition (OCR) and text-to-speech conversion. Scan documents, extract text, and listen to it in 13+ languages.

## ✨ Features

- 🔤 **Extract Text from Images** - Scan documents, whiteboards, or handwritten text
- 🎯 **Custom OCR Prompts** - Guide text extraction with your own instructions
- 🔊 **Text-to-Speech** - Convert extracted text to natural-sounding audio
- 🌍 **Multi-language Support** - 13 languages including English, Spanish, Hindi, Chinese, Arabic
- 📱 **Dual Camera/Gallery** - Capture photos or upload from device storage
- ▶️ **Audio Player** - Full playback controls with speed adjustment (0.5x - 1.5x)
- 📊 **Clean Modern UI** - Material Design 3 with light/dark theme support
- 🚀 **Production Ready** - Optimized for performance and stability

## 🎯 Use Cases

- 📝 **Students**: Digitize notes and study materials
- 📄 **Document Scanning**: Extract text from printed documents
- ♿ **Accessibility**: Convert text to speech for visually impaired users
- 🌐 **Multi-language Learning**: Practice language listening skills
- 📋 **Data Entry**: Quickly digitize handwritten forms

## 🔧 Prerequisites

- **Flutter SDK** 3.0.0 or higher
- **Dart SDK** (included with Flutter)
- **Android SDK** for mobile development
- **Backend Server** running (see configuration)

## 🚀 Quick Start

### 1. Clone & Setup

```bash
cd frontend
flutter pub get
```

### 2. Configure Backend

Edit `lib/constants/app_constants.dart`:

```dart
static String get baseUrl => 'https://your-backend-url.com';
```

### 3. Run the App

```bash
# Debug mode (development)
flutter run

# Release mode (production)
flutter run --release
```

## 📦 Building for Production

### Build APK (Android)

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Build Bundle (Google Play)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### Build iOS

```bash
flutter build ios --release
```

## 📂 Project Structure

```
lib/
├── main.dart                       # App entry point
├── screens/
│   ├── learning_assistant_home.dart  # Main screen (tabs)
│   └── home_screen.dart
├── providers/
│   └── ocr_provider.dart          # State management (Provider)
├── services/
│   └── api_service.dart           # API client (Dio)
├── models/
│   └── api_models.dart            # Data models
├── widgets/
│   ├── tab_navigation.dart
│   ├── platform_audio_player.dart
│   ├── platform_audio_player_web.dart
│   ├── web_camera_capture.dart
│   └── ...
├── constants/
│   └── app_constants.dart         # Config & constants
└── utils/
    └── text_parser.dart           # Utilities
```

## 🔌 API Integration

The app connects to a backend API with these endpoints:

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/health` | Server health check |
| POST | `/ocr` | Extract text from image |
| POST | `/ocr-with-prompt` | Extract with custom prompt |
| POST | `/ocr-audio` | Extract text + audio |
| POST | `/text-to-audio` | Convert text to audio |

## 🌐 Supported Languages

| Code | Language |
|------|----------|
| en | English |
| es | Spanish |
| fr | French |
| de | German |
| hi | Hindi |
| ja | Japanese |
| ko | Korean |
| pt | Portuguese |
| zh-CN | Chinese (Simplified) |
| zh-TW | Chinese (Traditional) |
| ar | Arabic |
| ru | Russian |
| it | Italian |

## 📚 Key Dependencies

```yaml
provider: ^6.0.0          # State management
dio: ^5.0.0               # HTTP client
image_picker: ^0.8.0      # Camera/Gallery picker
just_audio: ^0.9.0        # Audio playback
google_fonts: ^6.0.0      # Typography
path_provider: ^2.0.0     # File access
```

## 🛠️ Troubleshooting

### "Failed host lookup" Error
- Ensure device has internet connection
- Check backend URL configuration
- Verify backend server is running and accessible

### Audio Playback Issues
- Ensure device volume is not muted
- Check audio file format compatibility (MP3/WAV)
- Try restarting the app

### Image Picker Not Working
- Grant camera/gallery permissions (Android/iOS)
- Restart app after granting permissions
- Check device storage has available space

### Slider Assertion Error
- Fixed in latest version - update app
- If issue persists, clear app cache

## 📋 Configuration

### Android Manifest Permissions

The app requires these permissions (already configured):

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

### API Configuration

Backend URL can be changed in:
- `lib/constants/app_constants.dart` - `baseUrl` variable

## 🔐 Environment Setup

For development:
```bash
export FLUTTER_ENV=development
flutter run
```

For production:
```bash
export FLUTTER_ENV=production
flutter build apk --release
```

## 📱 Platform Support

- ✅ **Android** 5.0+ (API level 21+)
- ✅ **iOS** 11.0+
- ✅ **Web** (Chrome, Firefox, Safari)
- ✅ **macOS** 10.12+
- ✅ **Windows** 10+
- ✅ **Linux** (Ubuntu 18.04+)

## 🎨 Customization

### Change Theme Colors

Edit `lib/main.dart`:

```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: const Color(0xFF6366F1), // Change this
  brightness: Brightness.light,
),
```

### Add Languages

Edit `lib/constants/app_constants.dart`:

```dart
static const Map<String, String> supportedLanguages = {
  'en': 'English',
  'ur': 'Urdu',  // Add new language
  // ...
};
```

## 💡 Tips & Best Practices

1. **Image Quality**: Use well-lit, clear photos for best OCR results
2. **Text Extraction**: Experiment with custom prompts for better accuracy
3. **Audio**: Adjust playback speed based on comprehension level
4. **Permissions**: Always grant required permissions when prompted

## 📄 License

This project is part of the Electrathon initiative and is distributed under an open license.

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

For issues and questions:
- Check the [Troubleshooting](#-troubleshooting) section
- Review backend server logs
- Open an issue on GitHub

## ✅ Checklist Before Release

- [ ] API endpoint is configured correctly
- [ ] All permissions are granted on device
- [ ] Backend server is running and accessible
- [ ] Test OCR with various image types
- [ ] Test audio playback in different languages
- [ ] Test on both light and dark themes
- [ ] Build successfully for target platform

---

Built with ❤️ for the Electrathon community

- **permission_handler**: Runtime permissions

## Building for Release

### Android
```bash
flutter build apk
# or for bundle:
flutter build appbundle
```

### iOS
```bash
flutter build ios
```

## Troubleshooting

### API Connection Issues
- Ensure backend server is running
- Check if `baseUrl` in `lib/constants/app_constants.dart` matches your server address
- For Android emulator accessing localhost: use `http://10.0.2.2:8000` instead

### Image Picker Issues
- Grant camera and gallery permissions when prompted
- Check permissions in app settings on your device

### Audio Playback Issues
- Ensure device volume is not muted
- Check if internet is available for TTS generation
- Grant microphone permission if needed

## License

Proprietary - Electrathon Project

## Support

For issues and feature requests, please contact the development team.
