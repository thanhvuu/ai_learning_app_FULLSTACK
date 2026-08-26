import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_learning_app/src/common/extensions/build_context_ext.dart';
import 'package:ai_learning_app/src/common/theme/color_manager.dart';
import 'package:ai_learning_app/src/common/utils/validator.dart';
import 'package:ai_learning_app/src/common/widgets/custom_button.dart';
import 'package:ai_learning_app/src/common/widgets/custom_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        context.showErrorSnackBar('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
        return;
      }
      await user.updatePassword(_newPasswordController.text.trim());
      if (mounted) {
        context.showSuccessSnackBar('Đổi mật khẩu thành công!');
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        context.showErrorSnackBar(e.message ?? 'Lỗi khi đổi mật khẩu');
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Có lỗi xảy ra: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cardColor = isDark ? ColorManager.darkCard : ColorManager.lightCard;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _newPasswordController,
                        hintText: '••••••••',
                        labelText: 'Mật khẩu mới',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        validator: Validator.validatePassword,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _confirmPasswordController,
                        hintText: '••••••••',
                        labelText: 'Xác nhận mật khẩu mới',
                        prefixIcon: Icons.lock_reset,
                        isPassword: true,
                        validator: (val) => Validator.validateConfirmPassword(
                          val,
                          _newPasswordController.text,
                        ),
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Cập nhật mật khẩu',
                        onPressed: _handleChangePassword,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
