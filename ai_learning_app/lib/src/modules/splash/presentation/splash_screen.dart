import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_learning_app/generated/assets.gen.dart';
import 'package:ai_learning_app/src/common/constants/app_constants.dart';
import 'package:ai_learning_app/src/common/theme/color_manager.dart';
import 'package:ai_learning_app/src/modules/app/router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(AppConstants.splashDelay);
    if (mounted) {
      context.go(AppRoutes.initial);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.lightBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              const $AssetsImageGen().logo,
              width: 100,
              height: 100,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.school,
                size: 80,
                color: ColorManager.primaryGreen,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: ColorManager.primaryGreen,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: ColorManager.primaryGreen),
          ],
        ),
      ),
    );
  }
}
