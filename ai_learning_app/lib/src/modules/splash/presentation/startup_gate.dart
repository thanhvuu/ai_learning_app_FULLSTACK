import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_learning_app/src/common/constants/app_constants.dart';
import 'package:ai_learning_app/src/common/theme/color_manager.dart';
import 'package:ai_learning_app/src/modules/login/presentation/login_screen.dart';
import 'welcome_screen.dart';

class StartupGate extends StatelessWidget {
  const StartupGate({super.key});

  Future<bool> checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.prefKeyFirstTime) ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkFirstTime(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: ColorManager.primaryGreen),
            ),
          );
        }

        final isFirstTime = snapshot.data ?? true;
        return isFirstTime ? const WelcomeScreen() : const LoginScreen();
      },
    );
  }
}
