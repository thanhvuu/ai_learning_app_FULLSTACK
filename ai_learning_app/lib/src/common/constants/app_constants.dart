class AppConstants {
  AppConstants._();

  static const String appName = 'AI Learning App';
  static const String appVersion = '1.0.0';

  // Storage / Prefs Keys
  static const String prefKeyFirstTime = 'first_time';
  static const String prefKeyThemeMode = 'theme_mode';
  static const String prefKeyLanguage = 'language_code';
  static const String prefKeyAuthToken = 'auth_token';
  static const String prefKeyUsername = 'username';
  static const String prefKeyMajor = 'user_major';

  // Animation & Delay constants
  static const Duration defaultDebounceTime = Duration(milliseconds: 1000);
  static const Duration splashDelay = Duration(milliseconds: 1500);
  static const Duration snackBarDuration = Duration(seconds: 3);
}
