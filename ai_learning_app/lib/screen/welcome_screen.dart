import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'register_screen.dart'; // Tí nữa mình tạo file này

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
    return Scaffold(
      backgroundColor: Colors.white, // Nền trắng
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            
            //  LOGO (Tạm thời dùng Icon nếu bạn chưa có hình thật)

             Image.asset('assets/logo.png', height: 120), // Khi nào có ảnh thì mở comment dòng này, xóa dòng Icon trên đi

            const SizedBox(height: 20),
            const Text(
              "ai_learning_app",
              style: TextStyle(color: Colors.greenAccent, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Học miễn phí. Suốt đời.",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            
            const Spacer(),

            //  BUTTON 1: BẮT ĐẦU NGAY (Chuyển sang Đăng Ký)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () {
                  _completeWelcomeAndNavigate(context, const RegisterScreen());
                },
                child: const Text("BẮT ĐẦU NGAY", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
            ),
            const SizedBox(height: 15),

            //  BUTTON 2: ĐÃ CÓ TÀI KHOẢN (Chuyển sang Đăng Nhập)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.greenAccent, width: 2),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () {
                  _completeWelcomeAndNavigate(context, const LoginScreen());
                },
                child: const Text("TÔI ĐÃ CÓ TÀI KHOẢN", style: TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}