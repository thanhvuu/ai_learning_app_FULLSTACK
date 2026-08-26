import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:ai_learning_app/src/common/constants/api_constants.dart';
import 'package:ai_learning_app/src/core/domain/app_exception.dart';
import 'package:ai_learning_app/src/core/domain/result.dart';

class ApiClient {
  ApiClient({dio.Dio? dioClient})
      : _dio = dioClient ??
            dio.Dio(
              dio.BaseOptions(
                baseUrl: ApiConstants.baseUrl,
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

  Future<Result<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return Success(response.data);
    } on dio.DioException catch (e, st) {
      return Failure(_mapDioException(e, st));
    } catch (e, st) {
      return Failure(AppException(e.toString(), cause: e, stackTrace: st));
    }
  }

  Future<Result<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return Success(response.data);
    } on dio.DioException catch (e, st) {
      return Failure(_mapDioException(e, st));
    } catch (e, st) {
      return Failure(AppException(e.toString(), cause: e, stackTrace: st));
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
        stackTrace: stackTrace,
      );
    }

    return NetworkException(
      'Cannot connect to server. Please check your network.',
      cause: error,
      stackTrace: stackTrace,
    );
  }
}
