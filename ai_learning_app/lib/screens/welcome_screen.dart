import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart'; // <--- Thêm import
import '../providers/theme_provider.dart'; // <--- Thêm import
import '../providers/language_provider.dart';
import '../l10n/app_localizations.dart';

// Import màn hình
import 'login_screen.dart';
import 'homescreen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // Viết một hàm dùng chung để đánh dấu "Đã xem" và chuyển trang
  Future<void> _completeWelcomeAndNavigate(BuildContext context, Widget nextScreen) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenWelcome', true); // Lưu cờ vào máy

    if (context.mounted) {
      // Dùng pushReplacement để user không back lại màn hình Welcome được
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ==========================================
    // BÍ KÍP MÀU ĐỘNG CHO MÀN HÌNH WELCOME
    // ==========================================
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final langProvider = LanguageProvider.safeOf(context);
    final t = AppLocalizations(langProvider.languageCode);
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;

    // Màu chủ đạo: Ban đêm dùng xanh dạ quang, ban ngày dùng xanh lá đậm
    final Color primaryColor = isDarkMode ? Colors.greenAccent : const Color(0xFF0F8A50);

    // Màu chữ phụ: Ban đêm màu xám sáng, ban ngày màu xám tối
    final Color subtitleColor = isDarkMode ? Colors.grey[300]! : Colors.grey[700]!;

    return Scaffold(
      backgroundColor: bgColor, // <--- Nền tự đổi màu
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // LOGO (Có thêm errorBuilder để không bị lỗi đỏ màn hình nếu chưa có ảnh)
            Image.asset(
              'assets/image/logo.png',
              height: 120,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.school, size: 100, color: primaryColor), // Icon dự phòng
            ),

            const SizedBox(height: 20),
            Text(
              "AI Learning App", // Hoặc "ai_learning_app"
              style: TextStyle(color: primaryColor, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              t.translate('learn_free'),
              style: TextStyle(color: subtitleColor, fontSize: 16), // <--- Chữ không còn bị tàng hình nữa
            ),

            const Spacer(),

            // BUTTON 1: BẮT ĐẦU NGAY (Chuyển sang Đăng Ký)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor, // Tự đổi màu
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () {
                  _completeWelcomeAndNavigate(context, const LoginScreen(showLoginFirst: false));
                },
                child: Text(
                    t.translate('get_started'),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.black : Colors.white)
                ),
              ),
            ),
            const SizedBox(height: 15),

            // BUTTON 2: ĐÃ CÓ TÀI KHOẢN (Chuyển sang Đăng Nhập)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primaryColor, width: 2), // Viền tự đổi màu
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () {
                  _completeWelcomeAndNavigate(context, const LoginScreen(showLoginFirst: true));
                },
                child: Text(
                    t.translate('have_account'),
                    style: TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.bold)
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