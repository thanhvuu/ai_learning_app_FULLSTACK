import 'package:ai_learning_app/src/common/utils/app_environment.dart';

class ApiConstants {
  ApiConstants._();

  // Đọc URL động theo file .env nạp vào
  static String get baseUrl => AppEnvironment.apiUrl;

  static String get users => '$baseUrl/api/users';
  static String get lessons => '$baseUrl/api/lessons';
  static String get progress => '$baseUrl/api/progress';
  static String get leaderboard => '$baseUrl/api/leaderboard';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}