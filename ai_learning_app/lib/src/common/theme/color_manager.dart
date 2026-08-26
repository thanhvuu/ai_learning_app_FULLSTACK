import 'package:flutter/material.dart';

class ColorManager {
  ColorManager._();

  static const Color primaryGreen = Color(0xFF0F8A50);
  static const Color primaryGreenLight = Color(0xFF18C070);
  static const Color primaryGreenDark = Color(0xFF0B633A);

  // Background
  static const Color lightBackground = Color(0xFFF4FAF5);
  static const Color darkBackground = Color(0xFF121212);

  // Cards & Surfaces
  static const Color lightCard = Colors.white;
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color lightCardAlt = Color(0xFFE8F3ED);
  static const Color darkCardAlt = Color(0xFF2A2A2A);
  static const Color lightInputBg = Color(0xFFF2F7F4);
  static const Color darkInputBg = Color(0xFF2C2C2C);

  // Text
  static const Color lightTextPrimary = Color(0xFF1B2A22);
  static const Color darkTextPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);

  // Accent & Feedback
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFFFA000);
  static const Color info = Color(0xFF1976D2);
  static const Color purpleAccent = Color(0xFF6A4CFF);
  static const Color orangeAccent = Color(0xFFFF5722);
  static const Color tealAccent = Color(0xFF00BFA5);

  // Gradients
  static const LinearGradient greenGradient = LinearGradient(
    colors: [primaryGreen, primaryGreenLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
