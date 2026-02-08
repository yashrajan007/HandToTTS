import 'package:dio/dio.dart';
import 'dart:convert';
import '../constants/app_constants.dart';
import '../models/api_models.dart';

class ApiService {
  late Dio _dio;

  ApiService() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        validateStatus: (status) => status != null && status < 600,
      ),
    );
  }

  String _extractErrorDetail(dynamic data) {
    try {
      if (data is String) {
        final json = jsonDecode(data);
        if (json is Map && json.containsKey('detail')) {
          return json['detail'].toString();
        }
        return data;
      } else if (data is List<int>) {
        final str = utf8.decode(data);
        final json = jsonDecode(str);
        if (json is Map && json.containsKey('detail')) {
          return json['detail'].toString();
        }
        return str;
      }
      return data.toString();
    } catch (_) {
      return data?.toString() ?? 'Unknown server error';
    }
  }

  Future<ApiResponse<HealthCheckResponse>> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return ApiResponse(
        success: true,
        data: HealthCheckResponse.fromJson(response.data),
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.fromError(e);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<String>> ocrExtractText(MultipartFile file) async {
    try {
      FormData formData = FormData.fromMap({'file': file});

      final response = await _dio.post(
        '/ocr',
        data: formData,
        options: Options(
          responseType: ResponseType.plain,
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode != null && response.statusCode! >= 400) {
        final detail = _extractErrorDetail(response.data);
        return ApiResponse(
          success: false,
          error: detail,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse(
        success: true,
        data: response.data as String,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.fromError(e);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<String>> ocrWithPrompt(
    MultipartFile file,
    String prompt,
  ) async {
    try {
      FormData formData = FormData.fromMap({'file': file, 'prompt': prompt});

      final response = await _dio.post(
        '/ocr-with-prompt',
        data: formData,
        options: Options(
          responseType: ResponseType.plain,
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode != null && response.statusCode! >= 400) {
        final detail = _extractErrorDetail(response.data);
        return ApiResponse(
          success: false,
          error: detail,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse(
        success: true,
        data: response.data as String,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.fromError(e);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<List<int>>> ocrAudio(
    MultipartFile file, {
    String language = 'en',
  }) async {
    try {
      FormData formData = FormData.fromMap({'file': file, 'lang': language});

      final response = await _dio.post(
        '/ocr-audio',
        data: formData,
        options: Options(
          responseType: ResponseType.bytes,
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode != null && response.statusCode! >= 400) {
        final detail = _extractErrorDetail(response.data);
        return ApiResponse<List<int>>(
          success: false,
          error: detail,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse(
        success: true,
        data: response.data as List<int>,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.fromError(e);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<List<int>>> textToAudio(
    String text, {
    String language = 'en',
  }) async {
    try {
      FormData formData = FormData.fromMap({'text': text, 'lang': language});

      final response = await _dio.post(
        '/text-to-audio',
        data: formData,
        options: Options(
          responseType: ResponseType.bytes,
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode != null && response.statusCode! >= 400) {
        final detail = _extractErrorDetail(response.data);
        return ApiResponse<List<int>>(
          success: false,
          error: detail,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse(
        success: true,
        data: response.data as List<int>,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.fromError(e);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }
}
