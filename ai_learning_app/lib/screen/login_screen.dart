import 'package:flutter/material.dart';
import '../api_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

import 'major_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool showLoginFirst;

  const LoginScreen({super.key, this.showLoginFirst = true});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late bool isLogin;
  bool isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    isLogin = widget.showLoginFirst;
  }

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _submitAuth() async {
    setState(() => isLoading = true);

    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        _goToMajorSelection();
      } else {
        if (_passwordController.text != _confirmPasswordController.text) {
          _showError("Mật khẩu xác nhận không khớp!");
          setState(() => isLoading = false);
          return;
        }

        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await userCredential.user?.updateDisplayName(_nameController.text.trim());

        final String springBootApiUrl = "${ApiConfig.users}/register";
        var response = await http.post(
          Uri.parse(springBootApiUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "username": _nameController.text.trim(),
            "email": _emailController.text.trim(),
            "password": _passwordController.text.trim(),
          }),
        );

        if (response.statusCode == 200) {
          _showSuccess("Đăng ký thành công! Đang chuyển vào ứng dụng...");
          _goToMajorSelection();
        } else {
          _showError("Firebase OK nhưng lỗi đồng bộ Spring Boot: ${response.body}");
        }
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Lỗi xác thực từ Firebase");
    } catch (e) {
      _showError("Có lỗi xảy ra: $e");
    }

    setState(() => isLoading = false);
  }

  void _goToMajorSelection() {
    if (!mounted) return;
    String currentName = FirebaseAuth.instance.currentUser?.displayName ?? "Học viên";
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MajorSelectionScreen(username: currentName)),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.green));
  }

  void _showForgotPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController(text: _emailController.text);
    final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final inputBgColor = isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFF2F7F4);

    showDialog(
        context: context,
        builder: (context) {
          bool isSending = false;
          return StatefulBuilder(
              builder: (context, setStateDialog) {
                return AlertDialog(
                  backgroundColor: cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text("Khôi phục mật khẩu", style: TextStyle(color: Color(0xFF0F8A50), fontWeight: FontWeight.bold)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Nhập email của bạn để nhận liên kết đặt lại mật khẩu an toàn từ LingoBloom.", style: TextStyle(color: textColor)),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(color: inputBgColor, borderRadius: BorderRadius.circular(15)),
                        child: TextField(
                          controller: resetEmailController,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: "name@example.com",
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Hủy", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F8A50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: isSending ? null : () async {
                        final email = resetEmailController.text.trim();
                        if (email.isEmpty) {
                          _showError("Vui lòng nhập email!");
                          return;
                        }
                        setStateDialog(() => isSending = true);
                        try {
                          await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                          if (context.mounted) {
                            Navigator.pop(context);
                            _showSuccess("Đã gửi link khôi phục! Vui lòng kiểm tra hộp thư Email.");
                          }
                        } on FirebaseAuthException catch (e) {
                          if (context.mounted) {
                            Navigator.pop(context);
                            _showError(e.message ?? "Lỗi khi gửi email. Vui lòng thử lại.");
                          }
                        }
                      },
                      child: isSending
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Gửi link", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    )
                  ],
                );
              }
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color subtitleColor = isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;
    final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color inputBgColor = isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFF2F7F4);
    final Color titleColor = isDarkMode ? Colors.greenAccent : Colors.green[900]!;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [const Color(0xFF121212), const Color(0xFF1A2620), const Color(0xFF121212)]
                : [const Color(0xFFE8F6EF), const Color(0xFFF4FAF5), Colors.white],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.eco, color: titleColor, size: 30),
                      const SizedBox(width: 8),
                      const Text(
                        "LingoBloom",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F8A50)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Text(
                    isLogin ? "Chào mừng trở lại" : "Tạo tài khoản mới",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isLogin
                        ? "Hành trình chinh phục ngôn ngữ tiếp tục tại đây."
                        : "Bắt đầu hành trình học tập thông minh với AI của bạn ngay hôm nay.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: subtitleColor, height: 1.5),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                            color: isDarkMode ? Colors.black54 : Colors.green.withOpacity(0.05),
                            blurRadius: 20,
                            spreadRadius: 5,
                            offset: const Offset(0, 10)
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isLogin) ...[
                          _buildLabel("Họ tên", textColor),
                          _buildTextField(_nameController, "Đặng Thanh Vũ", Icons.person_outline, inputBgColor, textColor),
                          const SizedBox(height: 15),
                        ],
                        _buildLabel("Email", textColor),
                        _buildTextField(_emailController, "name@example.com", Icons.email_outlined, inputBgColor, textColor),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildLabel("Mật khẩu", textColor),
                            if (isLogin)
                              TextButton(
                                onPressed: _showForgotPasswordDialog,
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                                child: Text("Quên mật khẩu?", style: TextStyle(color: isDarkMode ? Colors.greenAccent : Colors.deepPurple, fontSize: 12, fontWeight: FontWeight.bold)),
                              )
                          ],
                        ),
                        const SizedBox(height: 5),
                        _buildPasswordField(_passwordController, "••••••••", inputBgColor, textColor),
                        const SizedBox(height: 15),
                        if (!isLogin) ...[
                          _buildLabel("Xác nhận", textColor),
                          _buildPasswordField(_confirmPasswordController, "••••••••", inputBgColor, textColor, isConfirm: true),
                          const SizedBox(height: 25),
                        ],
                        if (isLogin) const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submitAuth,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F8A50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                              isLogin ? "Đăng nhập" : "Đăng ký ngay",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLogin ? "Chưa có tài khoản? " : "Đã có tài khoản? ",
                        style: TextStyle(color: subtitleColor),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isLogin = !isLogin;
                            _nameController.clear();
                            _passwordController.clear();
                            _confirmPasswordController.clear();
                          });
                        },
                        child: Text(
                          isLogin ? "Đăng ký ngay" : "Đăng nhập",
                          style: TextStyle(color: isDarkMode ? Colors.greenAccent : const Color(0xFF0F8A50), fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.security, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 5),
                      Text("SECURE ACCESS", style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold)),
                      const SizedBox(width: 20),
                      Icon(Icons.auto_awesome, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 5),
                      Text("AI POWERED", style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 2),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, Color bgColor, Color textColor) {
    return Container(
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(15)),
      child: TextField(
        controller: controller,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hint, Color bgColor, Color textColor, {bool isConfirm = false}) {
    return Container(
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(15)),
      child: TextField(
        controller: controller,
        obscureText: _obscurePassword,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(isConfirm ? Icons.verified_user_outlined : Icons.lock_outline, color: Colors.grey[600]),
          suffixIcon: !isConfirm
              ? IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
