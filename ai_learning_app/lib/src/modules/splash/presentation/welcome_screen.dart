import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_learning_app/generated/assets.gen.dart';
import 'package:ai_learning_app/generated/l10n.dart';
import 'package:ai_learning_app/src/common/theme/color_manager.dart';
import 'package:ai_learning_app/src/core/application/language/language_cubit.dart';
import 'package:ai_learning_app/src/core/application/theme/theme_cubit.dart';
import 'package:ai_learning_app/src/modules/app/router/app_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> _completeWelcomeAndNavigate(
    BuildContext context,
    String route,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenWelcome', true);

    if (context.mounted) {
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeCubit>().state.isDarkMode;
    final langCode = context.watch<LanguageCubit>().state.languageCode;
    final S s = S(langCode);
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;

    final Color primaryColor = isDarkMode
        ? ColorManager.primaryGreenLight
        : ColorManager.primaryGreen;

    final Color subtitleColor = isDarkMode
        ? Colors.grey[300]!
        : Colors.grey[700]!;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Image.asset(
              const $AssetsImageGen().logo,
              height: 120,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.school,
                size: 100,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "AI Learning App",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              s.translate('welcome_title'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: subtitleColor,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _completeWelcomeAndNavigate(
                        context,
                        AppRoutes.login,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        s.translate('login'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => _completeWelcomeAndNavigate(
                        context,
                        AppRoutes.register,
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        s.translate('register'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
