import 'package:dio/dio.dart';
import 'package:ai_learning_app/src/core/infrastructure/datasources/local/storage.dart';

/// Tự động tiêm Bearer token vào HTTP Authorization Header
class AuthInterceptor extends QueuedInterceptorsWrapper {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await Storage.accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {}
    return super.onRequest(options, handler);
  }
}
