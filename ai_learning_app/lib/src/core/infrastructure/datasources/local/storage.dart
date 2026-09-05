import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:ai_learning_app/src/common/utils/service_locator.dart';
import 'package:ai_learning_app/src/core/domain/entities/user_entity.dart';

class Storage {
  Storage._();

  static const _secureStorage = FlutterSecureStorage();
  static const _keyAccessToken = 'access_token';
  static const _keyDeviceId = 'device_id';

  static SharedPreferences? _prefs;

  static Future<void> setup() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Đọc Access Token bảo mật từ Keychain (iOS) / Keystore (Android)
  static Future<String?> get accessToken =>
      _secureStorage.read(key: _keyAccessToken);

  /// Ghi hoặc xóa Access Token bảo mật
  static Future<void> setAccessToken(String? token) async {
    if (token == null) {
      await _secureStorage.delete(key: _keyAccessToken);
    } else {
      await _secureStorage.write(key: _keyAccessToken, value: token);
    }
  }

  /// Lấy thông tin user hiện tại từ Hive cache
  static Future<UserEntity?> getUser() async {
    try {
      return await ServiceLocator.userDao.getCurrentUser();
    } catch (_) {
      return null;
    }
  }

  /// Lưu hoặc xóa thông tin user trong Hive cache
  static Future<void> setUser(UserEntity? user) async {
    if (user == null) {
      await ServiceLocator.userDao.clearUser();
    } else {
      await ServiceLocator.userDao.saveUser(user);
    }
  }

  /// Lấy Device ID duy nhất của thiết bị
  static Future<String> get deviceId async {
    _prefs ??= await SharedPreferences.getInstance();
    String? id = _prefs!.getString(_keyDeviceId);
    if (id == null) {
      id = const Uuid().v4();
      await _prefs!.setString(_keyDeviceId, id);
    }
    return id;
  }

  /// Xóa sạch phiên đăng nhập (token + user session)
  static Future<void> clearAuth() async {
    await setAccessToken(null);
    try {
      await ServiceLocator.userDao.clearUser();
    } catch (_) {}
  }
}
