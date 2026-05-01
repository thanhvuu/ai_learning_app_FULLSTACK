import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // Thay đổi IP máy tính của bạn ở đây nếu dùng máy thật
  static const String _pcIp = "192.168.1.5"; 

  static String get baseUrl {
    // KHI DÙNG MÁY THẬT (IPHONE/ANDROID): 
    // Bạn phải dùng IP nội bộ của máy tính.
    // Đảm bảo điện thoại và máy tính dùng chung 1 mạng Wi-Fi.
    return "http://192.168.1.23:8080";
  }

  // Các đầu mục API cụ thể
  static String get users => "$baseUrl/api/users";
  static String get lessons => "$baseUrl/api/lessons";
  static String get progress => "$baseUrl/api/progress";
}
