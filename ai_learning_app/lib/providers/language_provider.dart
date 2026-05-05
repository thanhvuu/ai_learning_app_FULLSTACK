import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class LanguageProvider extends ChangeNotifier {
  // ====== SINGLETON — CHỈ CÓ DUY NHẤT 1 BẢN TRONG TOÀN APP ======
  static final LanguageProvider _instance = LanguageProvider._internal();
  factory LanguageProvider() => _instance;
  static LanguageProvider get instance => _instance;

  LanguageProvider._internal() {
    _loadFromPrefs();
  }

  // Mặc định là Tiếng Việt
  String _languageCode = 'vi';

  // Lấy trạng thái hiện tại
  String get languageCode => _languageCode;
  bool get isVietnamese => _languageCode == 'vi';
  String get languageName => _languageCode == 'vi' ? 'Tiếng Việt' : 'English';

  /// Truy cập an toàn từ context — luôn trả về cùng 1 instance
  static LanguageProvider safeOf(BuildContext context, {bool listen = true}) {
    try {
      return Provider.of<LanguageProvider>(context, listen: listen);
    } catch (_) {
      return _instance; // Trả về singleton, KHÔNG tạo instance mới
    }
  }

  // Hàm chuyển đổi ngôn ngữ
  void setLanguage(String code) {
    if (_languageCode == code) return; // Không đổi nếu trùng
    _languageCode = code;
    notifyListeners(); // Báo cho toàn app biết để vẽ lại giao diện
    _saveToPrefs(code); // Lưu vào bộ nhớ
  }

  // Lưu lựa chọn vào bộ nhớ điện thoại
  Future<void> _saveToPrefs(String code) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', code);
  }

  // Đọc lựa chọn từ bộ nhớ khi mở app
  Future<void> _loadFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String code = prefs.getString('language_code') ?? 'vi';
    _languageCode = code;
    notifyListeners();
  }
}
