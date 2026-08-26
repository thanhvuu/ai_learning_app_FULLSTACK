import 'package:flutter/material.dart';
import 'package:ai_learning_app/src/common/theme/color_manager.dart';

class CustomLoading extends StatelessWidget {
  final String? message;
  final Color color;

  const CustomLoading({
    super.key,
    this.message,
    this.color = ColorManager.primaryGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: color),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
