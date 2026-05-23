import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get ipAddress {
    if (kIsWeb) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2';
    return '192.168.1.30';
  }

  static String get baseUrl => 'http://$ipAddress:8080';

  static String get users => '$baseUrl/api/users';
  static String get lessons => '$baseUrl/api/lessons';
  static String get progress => '$baseUrl/api/progress';
}
