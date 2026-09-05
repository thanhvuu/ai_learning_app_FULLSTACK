import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_learning_app/src/common/theme/color_manager.dart';
import 'package:ai_learning_app/src/common/utils/user_session_helper.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/application/quiz_cubit/quiz_cubit.dart';

class FlashcardScreen extends StatefulWidget {
  final List<Map<String, dynamic>> reviewWords;

  const FlashcardScreen({super.key, required this.reviewWords});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int _currentIndex = 0;
  bool _isFlipped = false;
  int _wateredCount = 0;

  void _nextCard(bool isRemembered) async {
    final currentWord = widget.reviewWords[_currentIndex];
    final quizCubit = context.read<QuizCubit>();
    final username = UserSessionHelper.getUsername(context);

    await quizCubit.updateWordReview(
      word: currentWord['word'],
      currentLevel: currentWord['level'] ?? 0,
      isRemembered: isRemembered,
    );

    if (isRemembered) {
      _wateredCount++;
    }

    if (!mounted) return;

    if (_currentIndex < widget.reviewWords.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
    } else {
      if (_wateredCount > 0) {
        await quizCubit.finishWateringGarden(
          username: username,
          plants: _wateredCount,
        );
      }
      if (mounted) {
        _showCompletionDialog();
      }
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "🎉 Tuyệt vời!",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: ColorManager.primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Bạn đã tưới nước xong cho toàn bộ khu vườn hôm nay. Các mầm cây đang lớn lên rất nhanh!",
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              child: const Text(
                "Quay lại Vườn",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reviewWords.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Không có từ nào để ôn!")),
      );
    }

    var currentWord = widget.reviewWords[_currentIndex];

    return Scaffold(
      backgroundColor: ColorManager.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text(
          "Đang tưới nước: ${_currentIndex + 1}/${widget.reviewWords.length}",
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / widget.reviewWords.length,
              backgroundColor: Colors.green[100],
              color: ColorManager.primaryGreen,
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 50),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (!_isFlipped) setState(() => _isFlipped = true);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: ColorManager.primaryGreen.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: _isFlipped
                        ? Border.all(
                            color: ColorManager.primaryGreen.withOpacity(0.5),
                            width: 2,
                          )
                        : null,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentWord['word'],
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: _isFlipped
                                ? ColorManager.primaryGreen
                                : ColorManager.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_isFlipped) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              currentWord['meaning'] ?? "",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ] else ...[
                          Text(
                            "Chạm để xem nghĩa",
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
            AnimatedOpacity(
              opacity: _isFlipped ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _isFlipped ? () => _nextCard(false) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Chưa nhớ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isFlipped ? () => _nextCard(true) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Đã thuộc!",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
