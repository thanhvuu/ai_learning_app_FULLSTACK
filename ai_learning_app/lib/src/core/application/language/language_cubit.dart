import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_learning_app/src/common/constants/app_constants.dart';
import 'package:ai_learning_app/src/common/enum/language_code.dart';
import 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(const LanguageState()) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(AppConstants.prefKeyLanguage) ?? 'vi';
      emit(LanguageState(language: LanguageCode.fromString(code)));
    } catch (_) {}
  }

  Future<void> setLanguage(String code) async {
    final language = LanguageCode.fromString(code);
    emit(LanguageState(language: language));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.prefKeyLanguage, code);
    } catch (_) {}
  }

  Future<void> setLanguageCode(LanguageCode language) async {
    emit(LanguageState(language: language));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.prefKeyLanguage, language.code);
    } catch (_) {}
  }
}
