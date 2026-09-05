import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_learning_app/src/common/theme/color_manager.dart';
import 'package:ai_learning_app/src/common/utils/user_session_helper.dart';
import 'package:ai_learning_app/src/core/application/theme/theme_cubit.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/application/quiz_cubit/quiz_cubit.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/data/models/question_model.dart';

class DragDropQuizScreen extends StatefulWidget {
  final List<QuestionModel> questions;
  final int lessonId;

  const DragDropQuizScreen({
    super.key,
    required this.questions,
    required this.lessonId,
  });

  @override
  State<DragDropQuizScreen> createState() => _DragDropQuizScreenState();
}

class _DragDropQuizScreenState extends State<DragDropQuizScreen> {
  int currentIndex = 0;
  String? droppedWord;
  bool hasChecked = false;
  late List<String> currentOptions;
  bool isSavingProgress = false;
  int hearts = 3;

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
    currentOptions.shuffle();

    droppedWord = null;
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

  void _checkAnswer() {
    if (droppedWord == null) return;

    setState(() {
      hasChecked = true;
      if (!_isCorrect(droppedWord, widget.questions[currentIndex])) {
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

  Future<void> _completeLessonAndProgress() async {
    final String username = UserSessionHelper.getUsername(context);
    await context.read<QuizCubit>().completeLesson(
      username: username,
      lessonId: widget.lessonId,
      minutes: 5,
    );
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
            SizedBox(height: 10),
            Text(
              "Hết lượt thử!",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          "Bạn đã hết trái tim ❤️. Hãy nghỉ ngơi, ôn tập lại và thử sức sau nhé!",
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                "Về trang chủ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
            title: const Text(
              "Tuyệt vời! 🎉",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
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
                          await _completeLessonAndProgress();
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
                          "Trở về trang chủ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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

    final isDarkMode = context.watch<ThemeCubit>().state.isDarkMode;
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
                "Kéo từ đúng vào chỗ trống:",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 40),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 15,
                children: [
                  Text(
                    currentQ.sentenceStart,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  DragTarget<String>(
                    onWillAcceptWithDetails: (details) => !hasChecked,
                    onAcceptWithDetails: (details) => setState(() {
                      droppedWord = details.data;
                      hasChecked = false;
                    }),
                    builder: (context, candidateData, rejectedData) {
                      if (droppedWord != null) {
                        return GestureDetector(
                          onTap: () {
                            if (!hasChecked) setState(() => droppedWord = null);
                          },
                          child: _buildWordBlock(
                            droppedWord!,
                            isDropped: true,
                            cardColor: cardColor,
                            textColor: textColor,
                          ),
                        );
                      }
                      return DottedBorder(
                        color: candidateData.isNotEmpty
                            ? ColorManager.primaryGreen
                            : Colors.grey,
                        strokeWidth: 2,
                        dashPattern: const [6, 4],
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(15),
                        child: Container(
                          width: 80,
                          height: 45,
                          alignment: Alignment.center,
                          color: candidateData.isNotEmpty
                              ? ColorManager.primaryGreen.withOpacity(0.1)
                              : Colors.transparent,
                        ),
                      );
                    },
                  ),
                  Text(
                    currentQ.sentenceEnd,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Wrap(
                spacing: 15,
                runSpacing: 15,
                alignment: WrapAlignment.center,
                children: currentOptions.map((word) {
                  if (word == droppedWord) {
                    return Container(
                      width: 80,
                      height: 45,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                      ),
                    );
                  }
                  return Draggable<String>(
                    data: word,
                    feedback: Material(
                      color: Colors.transparent,
                      child: _buildWordBlock(
                        word,
                        isDragging: true,
                        cardColor: cardColor,
                        textColor: textColor,
                      ),
                    ),
                    childWhenDragging: Container(
                      width: 80,
                      height: 45,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _buildWordBlock(
                      word,
                      cardColor: cardColor,
                      textColor: textColor,
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              if (hasChecked)
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: _isCorrect(droppedWord, currentQ)
                        ? (isDarkMode ? Colors.green[900] : Colors.green[100])
                        : (isDarkMode ? Colors.red[900] : Colors.red[100]),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _isCorrect(droppedWord, currentQ)
                            ? "Chính xác!"
                            : "Sai rồi! Đáp án đúng: ${currentQ.correctAnswer}",
                        style: TextStyle(
                          color: _isCorrect(droppedWord, currentQ)
                              ? (isDarkMode
                                    ? Colors.greenAccent
                                    : Colors.green[800])
                              : (isDarkMode
                                    ? Colors.redAccent
                                    : Colors.red[800]),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (currentQ.explanation.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(
                          currentQ.explanation,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 15),
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: droppedWord == null
                        ? Colors.grey
                        : ColorManager.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: droppedWord == null
                      ? null
                      : (hasChecked ? _nextQuestion : _checkAnswer),
                  child: Text(
                    hasChecked ? "Tiếp tục" : "Kiểm tra",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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

  Widget _buildWordBlock(
    String word, {
    bool isDragging = false,
    bool isDropped = false,
    required Color cardColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDropped
              ? ColorManager.primaryGreen
              : (cardColor == Colors.white
                    ? Colors.grey[300]!
                    : Colors.grey[700]!),
          width: 2,
        ),
      ),
      child: Text(
        word,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDropped ? ColorManager.primaryGreen : textColor,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
