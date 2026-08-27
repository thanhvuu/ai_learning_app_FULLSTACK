import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ai_learning_app/src/common/enum/app_theme_mode.dart';

class ThemeState extends Equatable {
  final AppThemeMode mode;

  const ThemeState({this.mode = AppThemeMode.light});

  bool get isDarkMode => mode == AppThemeMode.dark;
  ThemeMode get themeMode => mode.themeMode;

  ThemeState copyWith({AppThemeMode? mode}) {
    return ThemeState(mode: mode ?? this.mode);
  }

  @override
  List<Object?> get props => [mode];
}
