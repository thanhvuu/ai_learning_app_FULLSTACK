class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;
  final Object? cause;
  final StackTrace? stackTrace;

  const AppException(
    this.message, {
    this.statusCode,
    this.details,
    this.cause,
    this.stackTrace,
  });

  const factory AppException.server(
    String message, {
    int? statusCode,
    dynamic details,
    Object? cause,
    StackTrace? stackTrace,
  }) = ServerException;

  const factory AppException.network(
    String message, {
    int? statusCode,
    dynamic details,
    Object? cause,
    StackTrace? stackTrace,
  }) = NetworkException;

  const factory AppException.auth(
    String message, {
    int? statusCode,
    dynamic details,
    String? code,
    Object? cause,
    StackTrace? stackTrace,
  }) = AuthException;

  const factory AppException.unknown(
    String message, {
    int? statusCode,
    dynamic details,
    Object? cause,
    StackTrace? stackTrace,
  }) = AppException;

  @override
  String toString() => message;
}

class ServerException extends AppException {
  const ServerException(
    super.message, {
    super.statusCode,
    super.details,
    super.cause,
    super.stackTrace,
  });
}

class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.statusCode,
    super.details,
    super.cause,
    super.stackTrace,
  });
}

class DataParsingException extends AppException {
  const DataParsingException(
    super.message, {
    super.statusCode,
    super.details,
    super.cause,
    super.stackTrace,
  });
}

class CacheException extends AppException {
  const CacheException(
    super.message, {
    super.statusCode,
    super.details,
    super.cause,
    super.stackTrace,
  });
}

class AuthException extends AppException {
  const AuthException(
    super.message, {
    super.statusCode,
    super.details,
    String? code,
    super.cause,
    super.stackTrace,
  });
}
