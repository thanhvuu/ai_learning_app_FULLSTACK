import 'package:flutter/material.dart';
import 'package:ai_learning_app/src/common/extensions/build_context_ext.dart';
import 'package:ai_learning_app/src/common/theme/color_manager.dart';
import 'package:ai_learning_app/src/common/widgets/custom_button.dart';
import 'package:ai_learning_app/src/common/widgets/custom_text_field.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _messageController.text.trim().isEmpty) {
      context.showErrorSnackBar('Vui lòng điền đầy đủ các thông tin!');
      return;
    }

    setState(() => _isSending = true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() => _isSending = false);
        context.showSuccessSnackBar('Cảm ơn bạn! Ý kiến đóng góp đã được gửi đi thành công.');
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cardColor = isDark ? ColorManager.darkCard : ColorManager.lightCard;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liên hệ hỗ trợ'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      controller: _nameController,
                      hintText: 'Họ và tên của bạn',
                      labelText: 'Họ tên',
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'email@example.com',
                      labelText: 'Email liên hệ',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _messageController,
                      hintText: 'Nhập nội dung cần hỗ trợ hoặc góp ý...',
                      labelText: 'Nội dung',
                      prefixIcon: Icons.message_outlined,
                      maxLines: 4,
                      minLines: 3,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Gửi tin nhắn',
                      onPressed: _sendMessage,
                      isLoading: _isSending,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.email, color: ColorManager.primaryGreen),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Email hỗ trợ: support@ailearningapp.com',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
