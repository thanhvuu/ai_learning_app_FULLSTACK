import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:ai_learning_app/src/common/constants/app_constants.dart';

class LanguageProvider extends ChangeNotifier {
  static final LanguageProvider _instance = LanguageProvider._internal();
  factory LanguageProvider() => _instance;
  static LanguageProvider get instance => _instance;

  LanguageProvider._internal() {
    _loadFromPrefs();
  }

  String _languageCode = 'vi';

  String get languageCode => _languageCode;
  Locale get locale => Locale(_languageCode);
  bool get isVietnamese => _languageCode == 'vi';
  String get languageName => _languageCode == 'vi' ? 'Tiếng Việt' : 'English';

  static LanguageProvider safeOf(BuildContext context, {bool listen = true}) {
    try {
      return Provider.of<LanguageProvider>(context, listen: listen);
    } catch (_) {
      return _instance;
    }
  }

  void setLanguage(String code) {
    if (_languageCode == code) return;
    _languageCode = code;
    notifyListeners();
    _saveToPrefs(code);
  }

  Future<void> _saveToPrefs(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefKeyLanguage, code);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(AppConstants.prefKeyLanguage) ?? 'vi';
    _languageCode = code;
    notifyListeners();
  }
}
