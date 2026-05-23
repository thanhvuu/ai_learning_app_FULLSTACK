import 'dart:convert';

import 'package:ai_learning_app/core/config/api_config.dart';
import 'package:ai_learning_app/core/error/app_exception.dart';
import 'package:ai_learning_app/core/result/result.dart';
import 'package:dio/dio.dart' as dio;

class ApiClient {
  ApiClient({dio.Dio? dioClient})
    : _dio =
          dioClient ??
          dio.Dio(
            dio.BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 20),
              sendTimeout: const Duration(seconds: 20),
              responseType: dio.ResponseType.json,
              headers: const {'Accept': 'application/json'},
            ),
          );

  final dio.Dio _dio;

  Future<Result<List<dynamic>>> getList(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        path,
        queryParameters: queryParameters,
      );

      if (!_isSuccessful(response.statusCode)) {
        return Failure(
          ServerException(
            'Server returned status ${response.statusCode ?? 'unknown'}',
            statusCode: response.statusCode,
          ),
        );
      }

      final data = _decodeJson(response.data);
      if (data is List) return Success(data);

      return const Failure(
        DataParsingException('Expected a JSON list from server'),
      );
    } on dio.DioException catch (error, stackTrace) {
      return Failure(_mapDioException(error, stackTrace));
    } on FormatException catch (error, stackTrace) {
      return Failure(
        DataParsingException(
          'Response is not valid JSON',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    } catch (error, stackTrace) {
      return Failure(
        AppException(
          'Unexpected API error',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  bool _isSuccessful(int? statusCode) {
    return statusCode != null && statusCode >= 200 && statusCode < 300;
  }

  Object? _decodeJson(Object? data) {
    if (data is String) return jsonDecode(data);
    return data;
  }

  AppException _mapDioException(dio.DioException error, StackTrace stackTrace) {
    final statusCode = error.response?.statusCode;
    if (statusCode != null) {
      return ServerException(
        'Server returned status $statusCode',
        statusCode: statusCode,
        cause: error,
      );
    }

    return NetworkException(
      'Cannot connect to server. Please check your network.',
      cause: error,
      stackTrace: stackTrace,
    );
  }
}
