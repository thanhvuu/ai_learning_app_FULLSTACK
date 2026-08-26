import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:ai_learning_app/src/common/constants/api_constants.dart';
import 'package:ai_learning_app/src/common/theme/color_manager.dart';
import 'package:ai_learning_app/src/core/application/theme_provider.dart';
import 'package:ai_learning_app/src/core/infrastructure/network/http_compat.dart' as http;
import 'package:ai_learning_app/src/modules/explore_lessons/data/models/question_model.dart';

class MultipleChoiceScreen extends StatefulWidget {
  final List<QuestionModel> questions;
  final int lessonId;

  const MultipleChoiceScreen({
    super.key,
    required this.questions,
    required this.lessonId,
  });

  @override
  State<MultipleChoiceScreen> createState() => _MultipleChoiceScreenState();
}

class _MultipleChoiceScreenState extends State<MultipleChoiceScreen> {
  int currentIndex = 0;
  int hearts = 3;
  String? selectedAnswer;
  bool hasChecked = false;
  late List<String> currentOptions;
  bool isSavingProgress = false;

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  void _loadQuestion() {
    QuestionModel currentQ = widget.questions[currentIndex];
    currentOptions = [
      currentQ.optionA,
      currentQ.optionB,
      currentQ.optionC,
      currentQ.optionD,
    ];
    currentOptions.removeWhere((item) => item.isEmpty);
    selectedAnswer = null;
    hasChecked = false;
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
          "Bạn đã hết trái tim ❤️. Hãy nghỉ ngơi và thử sức sau nhé!",
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
                Icon(Icons.emoji_events, color: Colors.green, size: 50),
                Text(
                  "Tuyệt vời! 🎉",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: const Text(
              "Bạn đã hoàn thành bài học này.\nTiến độ học tập của bạn đã được lưu lại!",
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
    if (widget.questions.isEmpty) {
      return const Scaffold(body: Center(child: Text("Không có câu hỏi nào!")));
    }
    QuestionModel currentQ = widget.questions[currentIndex];
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color textColor = isDarkMode ? ColorManager.darkTextPrimary : ColorManager.lightTextPrimary;
    final Color cardColor = isDarkMode ? ColorManager.darkCard : ColorManager.lightCard;

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
            padding: const EdgeInsets.only(right: 15.0),
            child: Row(
              children: List.generate(
                3,
                (index) => Icon(
                  index < hearts ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                  size: 26,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: (currentIndex + 1) / widget.questions.length,
            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(ColorManager.primaryGreen),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Chọn đáp án đúng:",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.5,
                      color: textColor,
                    ),
                    children: [
                      TextSpan(text: currentQ.sentenceStart),
                      if (currentQ.sentenceEnd.isNotEmpty) ...[
                        const TextSpan(
                          text: " _______ ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ColorManager.primaryGreen,
                          ),
                        ),
                        TextSpan(text: currentQ.sentenceEnd),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView.separated(
                  itemCount: currentOptions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    String option = currentOptions[index];
                    bool isSelected = selectedAnswer == option;
                    Color btnColor = cardColor;
                    Color borderColor = isDarkMode
                        ? Colors.grey[700]!
                        : Colors.grey[300]!;
                    Color optionTextColor = textColor;
                    if (hasChecked) {
                      if (_isCorrect(option, currentQ)) {
                        btnColor = isDarkMode
                            ? Colors.green[900]!
                            : Colors.green[100]!;
                        borderColor = Colors.green;
                        optionTextColor = isDarkMode
                            ? Colors.white
                            : Colors.green[900]!;
                      } else if (isSelected) {
                        btnColor = isDarkMode
                            ? Colors.red[900]!
                            : Colors.red[100]!;
                        borderColor = Colors.red;
                        optionTextColor = isDarkMode
                            ? Colors.white
                            : Colors.red[900]!;
                      }
                    } else if (isSelected) {
                      btnColor = isDarkMode
                          ? Colors.green[900]!.withOpacity(0.5)
                          : Colors.green[50]!;
                      borderColor = Colors.green;
                      optionTextColor = Colors.green;
                    }
                    return GestureDetector(
                      onTap: () {
                        if (!hasChecked) {
                          setState(() => selectedAnswer = option);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: btnColor,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: borderColor, width: 2),
                        ),
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: optionTextColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (hasChecked)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _isCorrect(selectedAnswer, currentQ)
                        ? (isDarkMode ? Colors.green[900] : Colors.green[50])
                        : (isDarkMode ? Colors.red[900] : Colors.red[50]),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isCorrect(selectedAnswer, currentQ)
                          ? Colors.green
                          : Colors.red,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isCorrect(selectedAnswer, currentQ)
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: _isCorrect(selectedAnswer, currentQ)
                                ? (isDarkMode
                                      ? Colors.greenAccent
                                      : Colors.green)
                                : (isDarkMode ? Colors.redAccent : Colors.red),
                            size: 30,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              _isCorrect(selectedAnswer, currentQ)
                                  ? "Tuyệt vời!"
                                  : "Sai rồi. Đáp án đúng là: ${currentQ.correctAnswer}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _isCorrect(selectedAnswer, currentQ)
                                    ? (isDarkMode
                                          ? Colors.greenAccent
                                          : Colors.green[800])
                                    : (isDarkMode
                                          ? Colors.redAccent
                                          : Colors.red[800]),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (currentQ.explanation.isNotEmpty) ...[
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.lightbulb,
                                color: Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  currentQ.explanation,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: textColor,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: selectedAnswer == null
                      ? null
                      : () {
                          if (hasChecked) {
                            if (hearts > 0) _nextQuestion();
                          } else {
                            setState(() {
                              hasChecked = true;
                              if (!_isCorrect(selectedAnswer, currentQ)) {
                                hearts--;
                                if (hearts == 0) _showGameOverDialog();
                              }
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        hasChecked && _isCorrect(selectedAnswer, currentQ)
                        ? Colors.green
                        : (hasChecked &&
                                  !_isCorrect(selectedAnswer, currentQ) &&
                                  hearts > 0
                              ? Colors.red
                              : ColorManager.primaryGreen),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: Text(
                    hasChecked ? "TIẾP TỤC" : "KIỂM TRA",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: selectedAnswer == null
                          ? Colors.grey[500]
                          : Colors.white,
                    ),
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
