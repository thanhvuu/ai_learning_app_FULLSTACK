import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  // Mặc định là giao diện sáng
  ThemeMode _themeMode = ThemeMode.light;

  // Lấy trạng thái hiện tại
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Khi khởi tạo app, tự động tải lại lựa chọn cũ của người dùng
  ThemeProvider() {
    _loadFromPrefs();
  }

  // Hàm chuyển đổi Sáng/Tối
  void toggleTheme(bool isOn) async {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Báo cho toàn app biết để vẽ lại giao diện
    _saveToPrefs(isOn); // Lưu vào bộ nhớ
  }

  // Lưu lựa chọn vào bộ nhớ điện thoại
  _saveToPrefs(bool isDark) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('theme_mode', isDark);
  }

  // Đọc lựa chọn từ bộ nhớ khi mở app
  _loadFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDark = prefs.getBool('theme_mode') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}