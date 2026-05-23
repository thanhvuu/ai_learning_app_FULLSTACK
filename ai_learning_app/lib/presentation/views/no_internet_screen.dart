import 'package:flutter/material.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF5),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.wifi_off_rounded, size: 88, color: Color(0xFF0F8A50)),
              SizedBox(height: 16),
              Text(
                'Không có kết nối Internet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B2A22),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Vui lòng bật Wi-Fi hoặc dữ liệu di động để tiếp tục học.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF5A6A63)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
