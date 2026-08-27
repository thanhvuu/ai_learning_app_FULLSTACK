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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authCubit = context.read<AuthCubit>();
    final success = await authCubit.register(
      username: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      context.go(
        AppRoutes.majorSelection,
        extra: _nameController.text.trim(),
      );
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
                        Icons.person_add_rounded,
                        size: 64,
                        color: ColorManager.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Tạo tài khoản mới",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Bắt đầu hành trình chinh phục tiếng Anh cùng AI",
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
                            "Họ và tên",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 5),
                          CustomTextField(
                            controller: _nameController,
                            hintText: 'Nguyễn Văn A',
                            prefixIcon: Icons.badge_outlined,
                            validator: (v) => Validator.validateRequired(v, 'Họ và tên'),
                          ),
                          const SizedBox(height: 18),
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
                          Text(
                            "Mật khẩu",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textColor,
                            ),
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
                                text: 'Đăng ký',
                                onPressed: _handleRegister,
                                isLoading: state.isLoading,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Đã có tài khoản? ",
                          style: TextStyle(color: subtitleColor),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.go(AppRoutes.login);
                          },
                          child: Text(
                            "Đăng nhập",
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
