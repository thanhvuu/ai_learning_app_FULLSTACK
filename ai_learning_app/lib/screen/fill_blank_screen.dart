import 'package:flutter/material.dart';
import '../api_config.dart';
import '../models/question_model.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class FillBlankScreen extends StatefulWidget {
  final List<QuestionModel> questions;
  const FillBlankScreen({super.key, required this.questions});

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

  void _checkAnswer() {
    String userAnswer = _answerController.text.trim().toLowerCase();
    String correctAnswer = widget.questions[currentIndex].correctAnswer.trim().toLowerCase();

    setState(() {
      hasChecked = true;
      if (userAnswer != correctAnswer) {
        hearts--;
        if (hearts == 0) {
          _showGameOverDialog();
        }
      }
    });
  }

  Future<void> _addStudyTime() async {
    final String url = "${ApiConfig.progress}/add-time";
    String username = FirebaseAuth.instance.currentUser?.displayName ?? "Đặng Thanh Vũ";

    try {
      await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "minutes": 5
        }),
      );
    } catch (e) {
      print("Lỗi cộng giờ học: $e");
    }
  }

  void _showGameOverDialog() {
    showDialog(
        context: context, barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Column(
            children: [
              Icon(Icons.heart_broken, color: Colors.red, size: 50),
              Text("Hết lượt thử!", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text("Đừng bỏ cuộc, hãy nghỉ ngơi một chút và thử lại nhé!", textAlign: TextAlign.center),
          actions: [
            SizedBox(width: double.infinity, child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              child: const Text("Về trang chủ", style: TextStyle(color: Colors.white)),
            ))
          ],
        )
    );
  }

  void _showCompletionDialog() {
    showDialog(
        context: context, barrierDismissible: false,
        builder: (context) => StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Column(
                  children: [
                    Icon(Icons.stars, color: Colors.orange, size: 50),
                    Text("Hoàn thành! 🎉", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
                content: const Text("Bạn thật là một thiên tài ngôn ngữ!\nTiến độ học tập của bạn đã được lưu lại.", textAlign: TextAlign.center),
                actions: [
                  SizedBox(width: double.infinity, child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(vertical: 12)
                    ),
                    onPressed: isSavingProgress ? null : () async {
                      setStateDialog(() => isSavingProgress = true);
                      await _addStudyTime();
                      if (context.mounted) {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    },
                    child: isSavingProgress
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Về trang chủ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ))
                ],
              );
            }
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    QuestionModel currentQ = widget.questions[currentIndex];
    bool isCorrect = _answerController.text.trim().toLowerCase() == currentQ.correctAnswer.trim().toLowerCase();
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Câu ${currentIndex + 1}/${widget.questions.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        backgroundColor: Colors.transparent, elevation: 0, iconTheme: IconThemeData(color: textColor),
        actions: [ Padding(padding: const EdgeInsets.only(right: 15), child: Row(children: List.generate(3, (i) => Icon(i < hearts ? Icons.favorite : Icons.favorite_border, color: Colors.red))))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Gõ từ đúng vào chỗ trống:", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 30),
            Wrap(
              runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(currentQ.sentenceStart, style: TextStyle(fontSize: 18, height: 1.5, color: textColor)),
                const SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _answerController, focusNode: _focusNode, enabled: !hasChecked, textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8), isDense: true,
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green[300]!, width: 2)),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.green, width: 3)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(currentQ.sentenceEnd, style: TextStyle(fontSize: 18, height: 1.5, color: textColor)),
              ],
            ),
            if (hasChecked) ...[
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isCorrect ? (isDarkMode ? Colors.green[900] : Colors.green[50]) : (isDarkMode ? Colors.red[900] : Colors.red[50]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isCorrect ? Colors.green : Colors.red),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isCorrect ? "Chính xác! 🥳" : "Chưa đúng rồi! Đáp án là: ${currentQ.correctAnswer}",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isCorrect ? (isDarkMode ? Colors.greenAccent : Colors.green[800]) : (isDarkMode ? Colors.redAccent : Colors.red[800]))),
                    const SizedBox(height: 10),
                    Text(currentQ.explanation, style: TextStyle(fontSize: 15, height: 1.4, color: textColor)),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed: _answerController.text.isEmpty ? null : (hasChecked ? _nextQuestion : _checkAnswer),
            style: ElevatedButton.styleFrom(
              backgroundColor: hasChecked ? (isCorrect ? Colors.green : Colors.red) : const Color(0xFF0F8A50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: Text(hasChecked ? "TIẾP TỤC" : "KIỂM TRA", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _answerController.text.isEmpty ? Colors.grey[500] : Colors.white)),
          ),
        ),
      ),
    );
  }
}
