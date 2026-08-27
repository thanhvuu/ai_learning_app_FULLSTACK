import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_learning_app/src/core/application/theme/theme_cubit.dart';
import 'package:ai_learning_app/src/core/application/language/language_cubit.dart';

void main() {
  test('ThemeCubit starts in light mode by default', () {
    SharedPreferences.setMockInitialValues({});
    final cubit = ThemeCubit();
    expect(cubit.state.themeMode, ThemeMode.light);
  });

  test('LanguageCubit toggles languages correctly', () async {
    SharedPreferences.setMockInitialValues({});
    final cubit = LanguageCubit();
    expect(cubit.state.languageCode, 'vi');

    await cubit.setLanguage('en');
    expect(cubit.state.languageCode, 'en');
  });
}
