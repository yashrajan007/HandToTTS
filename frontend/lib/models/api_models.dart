import 'package:dio/dio.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;

  ApiResponse({required this.success, this.data, this.error, this.statusCode});

  factory ApiResponse.fromError(DioException exception) {
    return ApiResponse(
      success: false,
      error: exception.message ?? 'Unknown error occurred',
      statusCode: exception.response?.statusCode,
    );
  }
}

class HealthCheckResponse {
  final String message;
  final String name;
  final String version;

  HealthCheckResponse({
    required this.message,
    required this.name,
    required this.version,
  });

  factory HealthCheckResponse.fromJson(Map<String, dynamic> json) {
    return HealthCheckResponse(
      message: json['message'] as String? ?? '',
      name: json['name'] as String? ?? '',
      version: json['version'] as String? ?? '',
    );
  }
}

class OcrRequest {
  final MultipartFile file;

  OcrRequest({required this.file});
}

class OcrWithPromptRequest {
  final MultipartFile file;
  final String prompt;

  OcrWithPromptRequest({required this.file, required this.prompt});
}

class OcrAudioRequest {
  final MultipartFile file;
  final String language;

  OcrAudioRequest({required this.file, this.language = 'en'});
}

class TextToAudioRequest {
  final String text;
  final String language;

  TextToAudioRequest({required this.text, this.language = 'en'});
}
