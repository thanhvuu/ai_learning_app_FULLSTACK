import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // Tự động nhận diện thiết bị để chọn IP đúng
  static String get ipAddress {
    if (kIsWeb) return "localhost";
    try {
      if (Platform.isAndroid) return "10.0.2.2"; // Cho Android Emulator
    } catch (e) {}
    
    // IP của máy Macbook của bạn trong mạng nội bộ
    return "192.168.1.30"; 
  }

  // Tự động ghép IP vào link
  static String get baseUrl => "http://$ipAddress:8080";

  // Các đường dẫn API cụ thể
  static String get users => "$baseUrl/api/users";
  static String get lessons => "$baseUrl/api/lessons";
  static String get progress => "$baseUrl/api/progress";
}
