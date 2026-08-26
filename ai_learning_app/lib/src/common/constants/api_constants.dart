import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  ApiConstants._();

  static String get ipAddress {
    if (kIsWeb) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2';
    return '192.168.1.30';
  }

  static String get baseUrl => 'http://$ipAddress:8080';

  static String get users => '$baseUrl/api/users';
  static String get lessons => '$baseUrl/api/lessons';
  static String get progress => '$baseUrl/api/progress';
  static String get leaderboard => '$baseUrl/api/leaderboard';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
