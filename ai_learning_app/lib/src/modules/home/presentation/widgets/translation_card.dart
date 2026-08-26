import 'package:flutter/material.dart';
import 'package:ai_learning_app/generated/l10n.dart';
import 'package:ai_learning_app/src/common/theme/color_manager.dart';

class TranslationCard extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String hint;
  final bool isInput;
  final Color cardColor;
  final Color textColor;
  final bool isDarkMode;
  final bool isListening;
  final VoidCallback? onListen;
  final VoidCallback? onCamera;
  final VoidCallback? onSpeak;
  final ValueChanged<String>? onChanged;

  const TranslationCard({
    super.key,
    required this.title,
    required this.controller,
    required this.hint,
    required this.isInput,
    required this.cardColor,
    required this.textColor,
    required this.isDarkMode,
    this.isListening = false,
    this.onListen,
    this.onCamera,
    this.onSpeak,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = ColorManager.primaryGreen;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isInput
            ? [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black26
                      : ColorManager.primaryGreen.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ]
            : [],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            bottom: -30,
            child: CircleAvatar(
              radius: 70,
              backgroundColor: primaryGreen.withOpacity(
                isDarkMode ? 0.05 : 0.08,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                        letterSpacing: 1,
                      ),
                    ),
                    Row(
                      children: isInput
                          ? [
                              IconButton(
                                icon: Icon(
                                  isListening ? Icons.mic : Icons.mic_none,
                                  color: isListening
                                      ? Colors.red
                                      : primaryGreen,
                                  size: 22,
                                ),
                                onPressed: onListen,
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                              const SizedBox(width: 15),
                              IconButton(
                                icon: const Icon(
                                  Icons.camera_alt_outlined,
                                  color: primaryGreen,
                                  size: 22,
                                ),
                                onPressed: onCamera,
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ]
                          : [
                              IconButton(
                                icon: const Icon(
                                  Icons.volume_up_outlined,
                                  color: primaryGreen,
                                  size: 22,
                                ),
                                onPressed: onSpeak,
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controller,
                  maxLines: 4,
                  minLines: 2,
                  readOnly: !isInput,
                  onChanged: isInput ? onChanged : null,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontStyle: isInput ? FontStyle.normal : FontStyle.italic,
                  ),
                  decoration: InputDecoration(
                    hintText: isListening ? S.of(context, 'listening') : hint,
                    hintStyle: TextStyle(
                      color: isListening ? Colors.red : Colors.grey[500],
                      fontSize: 16,
                      fontStyle: isInput ? FontStyle.normal : FontStyle.italic,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
