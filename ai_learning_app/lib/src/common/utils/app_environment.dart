import 'package:injectable/injectable.dart';

class AppEnvironment {
  AppEnvironment._();

  static Future<void> setup() async {
    // Không cần runtime setup khi dùng dart-define-from-file
  }

  // Khai báo các định danh môi trường
  static const alpha = 'ALPHA';
  static const dev = 'DEV';
  static const prg = 'PRG';
  static const uat = 'UAT';
  static const prd = 'PRD';

  static const environments = [alpha, dev, prg, uat, prd];

  // Đọc cấu hình từ file .env (hỗ trợ linh hoạt cả FLAVOR hoặc ENV)
  static const flavor = String.fromEnvironment('FLAVOR', defaultValue: String.fromEnvironment('ENV', defaultValue: dev),);
  static const packageName = String.fromEnvironment('PACKAGE_NAME', defaultValue: 'org.ai_learning.app');
  static const bundleId = String.fromEnvironment('BUNDLE_ID', defaultValue: 'org.ai_learning.app');
  static const apiUrl = String.fromEnvironment('API_URL', defaultValue: String.fromEnvironment('BASE_URL', defaultValue: 'http://10.0.2.2:8080'),);
  static const appName = String.fromEnvironment('APP_NAME', defaultValue: String.fromEnvironment('APP_TITLE', defaultValue: 'AI Learning App'),);
  static const googleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
  static const iosClientId = String.fromEnvironment('IOS_CLIENT_ID');
  static const appleServiceId = String.fromEnvironment('APPLE_SERVICE_ID');
  static const appleRedirectUri = String.fromEnvironment('APPLE_REDIRECT_URI');

  // Helper kiểm tra nhanh môi trường
  static bool get isAlpha => flavor.toUpperCase() == alpha;
  static bool get isDev => flavor.toUpperCase() == dev;
  static bool get isPrg => flavor.toUpperCase() == prg;
  static bool get isUat => flavor.toUpperCase() == uat;
  static bool get isPrd => flavor.toUpperCase() == prd;
}

// Khai báo Environment của Injectable để dùng cho việc phân chia Service theo môi trường
const alpha = Environment(AppEnvironment.alpha);
const dev = Environment(AppEnvironment.dev);
const prg = Environment(AppEnvironment.prg);
const uat = Environment(AppEnvironment.uat);
const prd = Environment(AppEnvironment.prd);