class AppException implements Exception {
  const AppException(this.message, {this.cause, this.stackTrace});

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.cause, super.stackTrace});
}

class ServerException extends AppException {
  const ServerException(super.message, {this.statusCode, super.cause});

  final int? statusCode;
}

class DataParsingException extends AppException {
  const DataParsingException(super.message, {super.cause, super.stackTrace});
}
