import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_learning_app/generated/l10n.dart';

extension BuildContextExt on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  String tr(String key) => S.of(this, key);

  void showSnackBar(
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor ?? const Color(0xFF0F8A50),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void showErrorSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.red);
  }

  void showSuccessSnackBar(String message) {
    showSnackBar(message, backgroundColor: const Color(0xFF0F8A50));
  }

  void showInfoSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.blueGrey);
  }

  void safePop<T>([T? result]) {
    if (GoRouter.of(this).canPop()) {
      GoRouter.of(this).pop<T>(result);
    } else {
      Navigator.of(this).maybePop(result);
    }
  }
}
