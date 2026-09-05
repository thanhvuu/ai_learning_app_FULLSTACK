import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:ai_learning_app/src/common/constants/api_constants.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/database_service.dart';
import 'package:ai_learning_app/src/core/infrastructure/network/interceptors/auth_interceptor.dart';
import 'package:ai_learning_app/src/core/infrastructure/network/interceptors/error_interceptor.dart';

@module
abstract class AppModule {
  @preResolve
  Future<DatabaseService> get databaseService async {
    final service = DatabaseService.instance;
    await service.initialize();
    return service;
  }

  @lazySingleton
  Dio get dio {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        responseType: ResponseType.json,
        headers: const {'Accept': 'application/json'},
      ),
    );
    dio.interceptors.addAll([
      AuthInterceptor(),
      ErrorInterceptor(),
    ]);
    return dio;
  }

  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  Connectivity get connectivity => Connectivity();
}
