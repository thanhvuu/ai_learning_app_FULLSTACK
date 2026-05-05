import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';
import '../providers/quiz_provider.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  String? selectedOption;
  bool hasSubmitted = false;
  bool isCorrect = false;

  void selectOption(String option) {
    if (!hasSubmitted) {
      setState(() {
        selectedOption = option;
      });
    }
  }

  Future<void> checkAnswer(BuildContext context, QuizProvider quizState) async {
    if (!hasSubmitted) {
      if (selectedOption != null) {
        String correctAns = quizState.questions[currentQuestionIndex]['correctAnswer'].toString().trim();
        bool correct = selectedOption!.trim().startsWith(correctAns) || selectedOption!.trim() == correctAns;
        setState(() {
          hasSubmitted = true;
          isCorrect = correct;
        });

        if (correct) {
          double currentProgress = (currentQuestionIndex + 1) / quizState.questions.length;
          quizState.updateProgress(currentProgress);
        } else {
          quizState.decreaseLive();
          if (quizState.lives == 0) {
            _showGameOverDialog(context);
          }
        }
      }
    } else {
      if(currentQuestionIndex < quizState.questions.length-1) {
        setState((){
          currentQuestionIndex++;
          hasSubmitted = false;
          isCorrect = false;
          selectedOption = null;
        });
      } else {
        quizState.updateProgress(1.0);
        final String username = "Đặng Thanh Vũ";
        final String updateUrl = "${ApiConfig.users}/update-progress?username=$username";

        try{
          var reponse = await http.put(Uri.parse(updateUrl));
          if(reponse.statusCode == 200){
            var data = jsonDecode(utf8.decode(reponse.bodyBytes));
            int newXp = data['totalXp'];
            int newStreak = data['streak'];
            if(context.mounted){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:Text("🎉 Tuyệt vời! Bạn được +20 XP.\nTổng: $newXp XP | Chuỗi: 🔥 $newStreak ngày"),
                  duration: const Duration(seconds: 5),
                  backgroundColor: Colors.green,
                )
              );
            }
          }
        } catch(e){
          print('lỗi lưu tiến độ');
        }

        if(context.mounted){
          Navigator.pop(context);
        }
      }
    }
  }

  void _showGameOverDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Hết lượt!"),
        content: const Text("Bạn đã hết tim. Hãy thử lại sau!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Quay về"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizState = context.watch<QuizProvider>();
    if (quizState.questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = quizState.questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: quizState.progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                    minHeight: 15,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.red),
                  const SizedBox(width: 5),
                  Text("${quizState.lives}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Spacer(flex: 1),
            Text(
              currentQuestion['prompt'],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const Spacer(flex: 2),
            Column(
              children: (currentQuestion['options'] as List).map<Widget>((option) {
                Color buttonColor = Colors.white;
                Color textColor = Colors.black87;
                Color borderColor = Colors.grey[300]!;

                if (option == selectedOption) {
                  buttonColor = const Color(0xFFE8F6F3);
                  borderColor = Colors.greenAccent;
                }

                if (hasSubmitted) {
                  String correctAns = currentQuestion['correctAnswer'].toString().trim();
                  if (option.toString().trim().startsWith(correctAns) || option.toString().trim() == correctAns) {
                    borderColor = Colors.greenAccent;
                  } else if (option == selectedOption) {
                    borderColor = Colors.redAccent;
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: buttonColor,
                        side: BorderSide(color: borderColor, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () => selectOption(option),
                      child: Text(option, style: TextStyle(fontSize: 18, color: textColor)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: hasSubmitted ? (isCorrect ? Colors.lightGreen[100] : Colors.red[100]) : Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasSubmitted)
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.error,
                      color: isCorrect ? Colors.green : Colors.red,
                      size: 30,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCorrect ? "Rất tuyệt!" : "Chưa chính xác!",
                            style: TextStyle(
                              color: isCorrect ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          if (!isCorrect) const SizedBox(height: 5),
                          if (!isCorrect)
                            Text(
                              "Giải thích: ${currentQuestion['explanation']}",
                              style: TextStyle(color: Colors.red[700], fontSize: 14),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasSubmitted ? (isCorrect ? Colors.green : Colors.red) : Colors.lightGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: hasSubmitted ? 0 : 5,
                ),
                onPressed: selectedOption == null ? null : () => checkAnswer(context, quizState),
                child: Text(
                  hasSubmitted ? "TIẾP TỤC" : "KIỂM TRA",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
