import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_learning_app/src/common/constants/app_constants.dart';
import 'package:ai_learning_app/src/common/enum/app_theme_mode.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState()) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(AppConstants.prefKeyDarkMode) ?? false;
      emit(ThemeState(mode: isDark ? AppThemeMode.dark : AppThemeMode.light));
    } catch (_) {}
  }

  Future<void> toggleTheme(bool isDark) async {
    final mode = isDark ? AppThemeMode.dark : AppThemeMode.light;
    emit(ThemeState(mode: mode));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.prefKeyDarkMode, isDark);
    } catch (_) {}
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    emit(ThemeState(mode: mode));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.prefKeyDarkMode, mode == AppThemeMode.dark);
    } catch (_) {}
  }
}
