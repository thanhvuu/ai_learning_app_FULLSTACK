import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_learning_app/src/common/constants/api_constants.dart';
import 'package:ai_learning_app/src/common/theme/color_manager.dart';
import 'package:ai_learning_app/src/core/application/theme/theme_cubit.dart';
import 'package:ai_learning_app/src/core/infrastructure/network/http_compat.dart' as http;
import 'package:ai_learning_app/src/modules/explore_lessons/data/models/question_model.dart';

class FillBlankScreen extends StatefulWidget {
  final List<QuestionModel> questions;
  final int lessonId;

  const FillBlankScreen({
    super.key,
    required this.questions,
    required this.lessonId,
  });

  @override
  State<FillBlankScreen> createState() => _FillBlankScreenState();
}

class _FillBlankScreenState extends State<FillBlankScreen> {
  int currentIndex = 0;
  int hearts = 3;
  bool hasChecked = false;
  bool isSavingProgress = false;
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _answerController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadQuestion() {
    setState(() {
      _answerController.clear();
      hasChecked = false;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      _focusNode.requestFocus();
    });
  }

  bool _isCorrect(String? selected, QuestionModel q) {
    if (selected == null) return false;
    String cleanSelected = selected.trim().toLowerCase();
    String cleanCorrect = q.correctAnswer.trim().toLowerCase();

    if (cleanSelected == cleanCorrect) return true;
    if (cleanCorrect == "a" && cleanSelected == q.optionA.trim().toLowerCase()) return true;
    if (cleanCorrect == "b" && cleanSelected == q.optionB.trim().toLowerCase()) return true;
    if (cleanCorrect == "c" && cleanSelected == q.optionC.trim().toLowerCase()) return true;
    if (cleanCorrect == "d" && cleanSelected == q.optionD.trim().toLowerCase()) return true;

    return false;
  }

  void _checkAnswer() {
    String userAnswer = _answerController.text.trim();

    setState(() {
      hasChecked = true;
      if (!_isCorrect(userAnswer, widget.questions[currentIndex])) {
        hearts--;
        if (hearts == 0) {
          _showGameOverDialog();
        }
      }
    });
  }

  void _nextQuestion() {
    if (currentIndex < widget.questions.length - 1) {
      setState(() {
        currentIndex++;
        _loadQuestion();
      });
    } else {
      _showCompletionDialog();
    }
  }

  Future<void> _updateLessonProgress() async {
    final String url = "${ApiConstants.lessons}/update-progress";
    try {
      await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"lessonId": widget.lessonId, "progress": 100}),
      );
    } catch (e) {
      debugPrint("Lỗi cập nhật tiến độ bài học: $e");
    }
  }

  Future<void> _addStudyTime() async {
    final String url = "${ApiConstants.progress}/add-time";
    String username =
        FirebaseAuth.instance.currentUser?.displayName ?? "Đặng Thanh Vũ";

    try {
      await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "minutes": 5}),
      );
    } catch (e) {
      debugPrint("Lỗi cộng giờ học: $e");
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.heart_broken, color: Colors.red, size: 50),
            Text(
              "Hết lượt thử!",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          "Đừng bỏ cuộc, hãy nghỉ ngơi một chút và thử lại nhé!",
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                "Về trang chủ",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Column(
              children: [
                Icon(Icons.stars, color: Colors.orange, size: 50),
                Text(
                  "Hoàn thành! 🎉",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: const Text(
              "Bạn thật là một thiên tài ngôn ngữ!\nTiến độ học tập của bạn đã được lưu lại.",
              textAlign: TextAlign.center,
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: isSavingProgress
                      ? null
                      : () async {
                          setStateDialog(() => isSavingProgress = true);
                          await _addStudyTime();
                          await _updateLessonProgress();
                          if (context.mounted) {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          }
                        },
                  child: isSavingProgress
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Về trang chủ",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    QuestionModel currentQ = widget.questions[currentIndex];
    bool isCorrect =
        _answerController.text.trim().toLowerCase() ==
        currentQ.correctAnswer.trim().toLowerCase();
    final isDarkMode = context.watch<ThemeCubit>().state.isDarkMode;
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color textColor = isDarkMode ? ColorManager.darkTextPrimary : ColorManager.lightTextPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Câu ${currentIndex + 1}/${widget.questions.length}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: ColorManager.primaryGreen,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Row(
              children: List.generate(
                3,
                (i) => Icon(
                  i < hearts ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Gõ từ đúng vào chỗ trống:",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 30),
            Wrap(
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  currentQ.sentenceStart,
                  style: TextStyle(fontSize: 18, height: 1.5, color: textColor),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _answerController,
                    focusNode: _focusNode,
                    enabled: !hasChecked,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColorManager.primaryGreen,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      isDense: true,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.green[300]!,
                          width: 2,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: ColorManager.primaryGreen, width: 3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  currentQ.sentenceEnd,
                  style: TextStyle(fontSize: 18, height: 1.5, color: textColor),
                ),
              ],
            ),
            if (hasChecked) ...[
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? (isDarkMode ? Colors.green[900] : Colors.green[50])
                      : (isDarkMode ? Colors.red[900] : Colors.red[50]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCorrect
                          ? "Chính xác! 🥳"
                          : "Chưa đúng rồi! Đáp án là: ${currentQ.correctAnswer}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isCorrect
                            ? (isDarkMode
                                  ? Colors.greenAccent
                                  : Colors.green[800])
                            : (isDarkMode ? Colors.redAccent : Colors.red[800]),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currentQ.explanation,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed: _answerController.text.isEmpty
                ? null
                : (hasChecked ? _nextQuestion : _checkAnswer),
            style: ElevatedButton.styleFrom(
              backgroundColor: hasChecked
                  ? (isCorrect ? Colors.green : Colors.red)
                  : ColorManager.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: Text(
              hasChecked ? "TIẾP TỤC" : "KIỂM TRA",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _answerController.text.isEmpty
                    ? Colors.grey[500]
                    : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
