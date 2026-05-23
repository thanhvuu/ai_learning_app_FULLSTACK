import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_learning_app/presentation/view_models/theme_view_model.dart';

void main() {
  test('ThemeProvider starts in light mode by default', () {
    SharedPreferences.setMockInitialValues({});

    final provider = ThemeProvider();

    expect(provider.themeMode, ThemeMode.light);
  });
}
