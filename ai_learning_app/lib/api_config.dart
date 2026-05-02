import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // TỪ NAY VỀ SAU, CÓ ĐỔI IP THÌ CHỈ CẦN SỬA ĐÚNG DÒNG SỐ 3 NÀY THÔI NHÉ
  static const String ipAddress = "10.0.2.2";

  // Tự động ghép IP vào link
  static String get baseUrl => "http://$ipAddress:8080";

  // Các đường dẫn API cụ thể
  static String get users => "$baseUrl/api/users";
  static String get lessons => "$baseUrl/api/lessons";
  static String get progress => "$baseUrl/api/progress";
}
