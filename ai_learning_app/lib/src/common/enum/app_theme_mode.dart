import 'package:flutter/material.dart';

enum AppThemeMode {
  light,
  dark,
  system;

  bool get isDark => this == AppThemeMode.dark;

  ThemeMode get themeMode => switch (this) {
    AppThemeMode.dark => ThemeMode.dark,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.system => ThemeMode.system,
  };
}
