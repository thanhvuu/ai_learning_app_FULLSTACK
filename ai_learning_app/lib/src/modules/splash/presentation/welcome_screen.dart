import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:ai_learning_app/generated/assets.gen.dart';
import 'package:ai_learning_app/generated/l10n.dart';
import 'package:ai_learning_app/src/common/theme/color_manager.dart';
import 'package:ai_learning_app/src/core/application/language_provider.dart';
import 'package:ai_learning_app/src/core/application/theme_provider.dart';
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
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final langProvider = LanguageProvider.safeOf(context);
    final S s = S(langProvider.languageCode);
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
                color: primaryColor,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              s.translate('learn_free'),
              style: TextStyle(
                color: subtitleColor,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  _completeWelcomeAndNavigate(
                    context,
                    AppRoutes.register,
                  );
                },
                child: Text(
                  s.translate('get_started'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: primaryColor,
                    width: 2,
                  ),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  _completeWelcomeAndNavigate(
                    context,
                    AppRoutes.login,
                  );
                },
                child: Text(
                  s.translate('have_account'),
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
