import 'package:flutter/material.dart';
import 'color_manager.dart';
import 'text_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: ColorManager.primaryGreen,
      scaffoldBackgroundColor: ColorManager.lightBackground,
      cardColor: ColorManager.lightCard,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ColorManager.primaryGreen,
        brightness: Brightness.light,
        primary: ColorManager.primaryGreen,
        surface: ColorManager.lightCard,
      ),
      textTheme: AppTextTheme.lightTextTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: ColorManager.lightTextPrimary),
        titleTextStyle: TextStyle(
          color: ColorManager.lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: ColorManager.primaryGreenLight,
      scaffoldBackgroundColor: ColorManager.darkBackground,
      cardColor: ColorManager.darkCard,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ColorManager.primaryGreenLight,
        brightness: Brightness.dark,
        primary: ColorManager.primaryGreenLight,
        surface: ColorManager.darkCard,
      ),
      textTheme: AppTextTheme.darkTextTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: ColorManager.darkTextPrimary),
        titleTextStyle: TextStyle(
          color: ColorManager.darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
