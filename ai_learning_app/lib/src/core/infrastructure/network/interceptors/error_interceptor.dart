import 'package:dio/dio.dart';
import 'package:ai_learning_app/src/core/infrastructure/datasources/local/storage.dart';

/// Bắt lỗi 401 Unauthorized để xóa token và hỗ trợ callback tự động đăng xuất
class ErrorInterceptor extends InterceptorsWrapper {
  final Future<void> Function()? onUnauthorized;

  ErrorInterceptor({this.onUnauthorized});

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await Storage.clearAuth();
      if (onUnauthorized != null) {
        try {
          await onUnauthorized!();
        } catch (_) {}
      }
    }
    return handler.next(err);
  }
}
