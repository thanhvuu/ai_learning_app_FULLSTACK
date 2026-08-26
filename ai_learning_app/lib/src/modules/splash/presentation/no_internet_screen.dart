import 'package:flutter/material.dart';
import 'package:ai_learning_app/src/common/theme/color_manager.dart';

class NoInternetScreen extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetScreen({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? ColorManager.darkBackground : ColorManager.lightBackground;
    final textColor = isDarkMode ? ColorManager.darkTextPrimary : ColorManager.lightTextPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 88,
                color: ColorManager.primaryGreen,
              ),
              const SizedBox(height: 16),
              Text(
                'Không có kết nối Internet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Vui lòng bật Wi-Fi hoặc dữ liệu di động để tiếp tục học.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF5A6A63)),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
