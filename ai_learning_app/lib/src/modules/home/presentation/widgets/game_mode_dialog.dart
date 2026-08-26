import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_learning_app/generated/l10n.dart';
import 'package:ai_learning_app/src/common/theme/color_manager.dart';
import 'package:ai_learning_app/src/core/application/theme_provider.dart';

class GameModeDialog extends StatelessWidget {
  final File file;
  final Function(BuildContext context, File file, String quizType) onSelectMode;

  const GameModeDialog({
    super.key,
    required this.file,
    required this.onSelectMode,
  });

  static void show(
    BuildContext context,
    File file,
    Function(BuildContext context, File file, String quizType) onSelectMode,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => GameModeDialog(
        file: file,
        onSelectMode: onSelectMode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return AlertDialog(
      backgroundColor: isDarkMode ? ColorManager.darkCard : ColorManager.lightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        S.of(context, 'choose_study_mode'),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: ColorManager.primaryGreen,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            S.of(context, 'ai_design_lesson'),
            style: const TextStyle(color: Colors.grey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _buildGameOption(
            context,
            file,
            S.of(context, 'drag_drop_vocab'),
            Icons.drag_indicator,
            "drag_drop",
            isDarkMode,
          ),
          const SizedBox(height: 10),
          _buildGameOption(
            context,
            file,
            S.of(context, 'multiple_choice'),
            Icons.list_alt,
            "multiple_choice",
            isDarkMode,
          ),
          const SizedBox(height: 10),
          _buildGameOption(
            context,
            file,
            S.of(context, 'fill_blank'),
            Icons.keyboard,
            "fill_blank",
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildGameOption(
    BuildContext dialogContext,
    File file,
    String title,
    IconData icon,
    String quizType,
    bool isDarkMode,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: isDarkMode
              ? ColorManager.darkInputBg
              : const Color(0xFFF4FAF5),
          foregroundColor: ColorManager.primaryGreen,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.green[200]!, width: 1),
          ),
        ),
        icon: Icon(icon),
        label: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDarkMode ? ColorManager.darkTextPrimary : ColorManager.lightTextPrimary,
          ),
        ),
        onPressed: () {
          Navigator.pop(dialogContext);
          onSelectMode(dialogContext, file, quizType);
        },
      ),
    );
  }
}
