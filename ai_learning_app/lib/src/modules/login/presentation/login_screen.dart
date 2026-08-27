import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_learning_app/src/common/extensions/build_context_ext.dart';
import 'package:ai_learning_app/src/common/theme/color_manager.dart';
import 'package:ai_learning_app/src/common/utils/validator.dart';
import 'package:ai_learning_app/src/common/widgets/custom_button.dart';
import 'package:ai_learning_app/src/common/widgets/custom_text_field.dart';
import 'package:ai_learning_app/src/core/application/auth/auth_cubit.dart';
import 'package:ai_learning_app/src/core/application/auth/auth_state.dart';
import 'package:ai_learning_app/src/modules/app/router/app_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authCubit = context.read<AuthCubit>();
    final success = await authCubit.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      final user = authCubit.state.user;
      final username = user?.username.isNotEmpty == true
          ? user!.username
          : _emailController.text.trim().split('@')[0];
      final major = user?.major;

      if (major != null && major.isNotEmpty) {
        context.go(
          AppRoutes.main,
          extra: {
            'username': username,
            'major': major,
          },
        );
      } else {
        context.go(
          AppRoutes.majorSelection,
          extra: username,
        );
      }
    } else if (mounted && authCubit.state.errorMessage != null) {
      context.showErrorSnackBar(authCubit.state.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cardColor = isDark ? ColorManager.darkCard : ColorManager.lightCard;
    final textColor = isDark ? ColorManager.darkTextPrimary : ColorManager.lightTextPrimary;
    final subtitleColor = isDark ? Colors.grey[400]! : Colors.grey[700]!;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF121212),
                    const Color(0xFF1A2620),
                    const Color(0xFF121212),
                  ]
                : [
                    const Color(0xFFE8F6EF),
                    const Color(0xFFF4FAF5),
                    Colors.white,
                  ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ColorManager.primaryGreen.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        size: 64,
                        color: ColorManager.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Chào mừng trở lại!",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Đăng nhập để tiếp tục hành trình học tiếng Anh",
                      style: TextStyle(
                        fontSize: 14,
                        color: subtitleColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Email",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 5),
                          CustomTextField(
                            controller: _emailController,
                            hintText: 'example@email.com',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validator.validateEmail,
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Mật khẩu",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: textColor,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.push(
                                    AppRoutes.forgotPassword,
                                    extra: _emailController.text.trim(),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                ),
                                child: Text(
                                  "Quên mật khẩu?",
                                  style: TextStyle(
                                    color: isDark ? Colors.greenAccent : ColorManager.purpleAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          CustomTextField(
                            controller: _passwordController,
                            hintText: '••••••••',
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                            validator: Validator.validatePassword,
                          ),
                          const SizedBox(height: 25),
                          BlocBuilder<AuthCubit, AuthState>(
                            builder: (context, state) {
                              return CustomButton(
                                text: 'Đăng nhập',
                                onPressed: _handleLogin,
                                isLoading: state.isLoading,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Chưa có tài khoản? ",
                          style: TextStyle(color: subtitleColor),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.go(AppRoutes.register);
                          },
                          child: Text(
                            "Đăng ký ngay",
                            style: TextStyle(
                              color: isDark ? Colors.greenAccent : ColorManager.primaryGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
