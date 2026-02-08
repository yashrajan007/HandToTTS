import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../services/api_service.dart';

class OcrProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Loading states
  final bool _isLoading = false;
  bool _isProcessing = false;

  // Data states
  String? _extractedText;
  Uint8List? _audioData;
  String? _selectedImagePath;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  String? _selectedImageMimeType;
  String _selectedLanguage = 'en';
  String _customPrompt =
      'Extract all text from this image. Preserve the layout and structure as much as possible.';

  // Error handling
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get extractedText => _extractedText;
  Uint8List? get audioData => _audioData;
  String? get selectedImagePath => _selectedImagePath;
  Uint8List? get selectedImageBytes => _selectedImageBytes;
  String get selectedLanguage => _selectedLanguage;
  String get customPrompt => _customPrompt;
  String? get error => _error;

  // Setters
  void setImagePath(String? path) {
    _selectedImagePath = path;
    _error = null;
    notifyListeners();
  }

  void setImageBytes(Uint8List? bytes, {String? name, String? mimeType}) {
    _selectedImageBytes = bytes;
    _selectedImageName = name;
    _selectedImageMimeType = mimeType;
    _error = null;
    notifyListeners();
  }

  void setLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  void setCustomPrompt(String prompt) {
    _customPrompt = prompt;
  }

  void clearAll() {
    _extractedText = null;
    _audioData = null;
    _selectedImagePath = null;
    _selectedImageBytes = null;
    _selectedImageName = null;
    _selectedImageMimeType = null;
    _error = null;
    _selectedLanguage = 'en';
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // API Methods
  Future<bool> healthCheck() async {
    try {
      final response = await _apiService.healthCheck();
      if (!response.success) {
        _error = response.error;
        notifyListeners();
        return false;
      }
      return true;
    } catch (e) {
      _error = 'Health check failed: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> extractTextFromImage() async {
    if (_selectedImagePath == null && _selectedImageBytes == null) {
      _error = 'No image selected';
      notifyListeners();
      return;
    }

    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      MultipartFile file;

      if (_selectedImageBytes != null) {
        // Web platform: use bytes with correct content type
        file = MultipartFile.fromBytes(
          _selectedImageBytes!,
          filename: _selectedImageName ?? 'image.jpg',
          contentType: _selectedImageMimeType != null
              ? MediaType.parse(_selectedImageMimeType!)
              : MediaType('image', 'jpeg'),
        );
      } else {
        // Mobile platform: use file path
        file = await MultipartFile.fromFile(_selectedImagePath!);
      }

      final response = await _apiService.ocrExtractText(file);

      if (response.success) {
        _extractedText = response.data;
        _error = null;
      } else {
        _error = response.error ?? 'Failed to extract text';
        _extractedText = null;
      }
    } catch (e) {
      _error = 'Error extracting text: $e';
      _extractedText = null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> extractTextWithCustomPrompt() async {
    if (_selectedImagePath == null && _selectedImageBytes == null) {
      _error = 'No image selected';
      notifyListeners();
      return;
    }

    if (_customPrompt.isEmpty) {
      _error = 'Custom prompt cannot be empty';
      notifyListeners();
      return;
    }

    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      MultipartFile file;

      if (_selectedImageBytes != null) {
        file = MultipartFile.fromBytes(
          _selectedImageBytes!,
          filename: _selectedImageName ?? 'image.jpg',
          contentType: _selectedImageMimeType != null
              ? MediaType.parse(_selectedImageMimeType!)
              : MediaType('image', 'jpeg'),
        );
      } else {
        file = await MultipartFile.fromFile(_selectedImagePath!);
      }

      final response = await _apiService.ocrWithPrompt(file, _customPrompt);

      if (response.success) {
        _extractedText = response.data;
        _error = null;
      } else {
        _error = response.error ?? 'Failed to extract text with prompt';
        _extractedText = null;
      }
    } catch (e) {
      _error = 'Error extracting text: $e';
      _extractedText = null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> convertImageToAudio() async {
    if (_selectedImagePath == null && _selectedImageBytes == null) {
      _error = 'No image selected';
      notifyListeners();
      return;
    }

    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      MultipartFile file;

      if (_selectedImageBytes != null) {
        file = MultipartFile.fromBytes(
          _selectedImageBytes!,
          filename: _selectedImageName ?? 'image.jpg',
          contentType: _selectedImageMimeType != null
              ? MediaType.parse(_selectedImageMimeType!)
              : MediaType('image', 'jpeg'),
        );
      } else {
        file = await MultipartFile.fromFile(_selectedImagePath!);
      }

      final response = await _apiService.ocrAudio(
        file,
        language: _selectedLanguage,
      );

      if (response.success) {
        _audioData = Uint8List.fromList(response.data ?? []);
        _error = null;
      } else {
        _error = response.error ?? 'Failed to convert image to audio';
        _audioData = null;
      }
    } catch (e) {
      _error = 'Error converting to audio: $e';
      _audioData = null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> convertTextToAudio(String text) async {
    if (text.isEmpty) {
      _error = 'Text cannot be empty';
      notifyListeners();
      return;
    }

    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.textToAudio(
        text,
        language: _selectedLanguage,
      );

      if (response.success) {
        _audioData = Uint8List.fromList(response.data ?? []);
        _error = null;
      } else {
        _error = response.error ?? 'Failed to convert text to audio';
        _audioData = null;
      }
    } catch (e) {
      _error = 'Error converting text to audio: $e';
      _audioData = null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
