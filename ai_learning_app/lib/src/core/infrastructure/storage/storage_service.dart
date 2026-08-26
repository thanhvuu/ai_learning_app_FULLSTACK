import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError('StorageService has not been initialized. Call StorageService.init() first.');
    }
    return _prefs!;
  }

  static Future<bool> setBool(String key, bool value) async {
    return prefs.setBool(key, value);
  }

  static bool? getBool(String key) {
    return prefs.getBool(key);
  }

  static Future<bool> setString(String key, String value) async {
    return prefs.setString(key, value);
  }

  static String? getString(String key) {
    return prefs.getString(key);
  }

  static Future<bool> setInt(String key, int value) async {
    return prefs.setInt(key, value);
  }

  static int? getInt(String key) {
    return prefs.getInt(key);
  }

  static Future<bool> remove(String key) async {
    return prefs.remove(key);
  }

  static Future<bool> clear() async {
    return prefs.clear();
  }
}
