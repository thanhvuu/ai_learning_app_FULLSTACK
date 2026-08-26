enum AppThemeMode {
  light,
  dark,
  system;

  bool get isDark => this == AppThemeMode.dark;
}
