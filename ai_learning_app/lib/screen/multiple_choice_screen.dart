import 'package:flutter/material.dart';
import '../models/question_model.dart';

class MultipleChoiceScreen extends StatefulWidget {
  final List<QuestionModel> questions;
  const MultipleChoiceScreen({super.key, required this.questions});

  @override
  State<MultipleChoiceScreen> createState() => _MultipleChoiceScreenState();
}

class _MultipleChoiceScreenState extends State<MultipleChoiceScreen> {
  int currentIndex = 0;
  int hearts = 3;
  String? selectedAnswer;
  bool hasChecked = false;
  late List<String> currentOptions;

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  void _loadQuestion() {
    QuestionModel currentQ = widget.questions[currentIndex];
    currentOptions = [currentQ.optionA, currentQ.optionB, currentQ.optionC, currentQ.optionD];
    currentOptions.removeWhere((item) => item.isEmpty);
    selectedAnswer = null;
    hasChecked = false;
  }

  void _nextQuestion() {
    if (currentIndex < widget.questions.length - 1) {
      setState(() {
        currentIndex++;
        _loadQuestion();
      });
    } else {
      _showDialog("Tuyệt vời! 🎉", "Bạn đã hoàn thành xuất sắc bài học này.", true);
    }
  }

  void _showDialog(String title, String content, bool isSuccess) {
    showDialog(
        context: context, barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            children: [
              Icon(isSuccess ? Icons.emoji_events : Icons.heart_broken, color: isSuccess ? Colors.green : Colors.red, size: 50),
              Text(title, style: TextStyle(color: isSuccess ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(content, textAlign: TextAlign.center),
          actions: [
            SizedBox(width: double.infinity, child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: isSuccess ? Colors.green : Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              child: const Text("Về trang chủ", style: TextStyle(color: Colors.white)),
            ))
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) return const Scaffold(body: Center(child: Text("Không có câu hỏi nào!")));
    QuestionModel currentQ = widget.questions[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF5),
      appBar: AppBar(
        title: Text('Câu ${currentIndex + 1}/${widget.questions.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.green),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Row(children: List.generate(3, (index) => Icon(index < hearts ? Icons.favorite : Icons.favorite_border, color: Colors.red, size: 26))),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(value: (currentIndex + 1) / widget.questions.length, backgroundColor: Colors.grey[300], valueColor: const AlwaysStoppedAnimation<Color>(Colors.green)),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Chọn đáp án đúng:", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 20),
              // Hiển thị câu hỏi
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[300]!)),
                child: Text(currentQ.sentenceStart, style: const TextStyle(fontSize: 18, height: 1.5)),
              ),
              const SizedBox(height: 30),

              // Các nút đáp án
              Expanded(
                child: ListView.separated(
                  itemCount: currentOptions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    String option = currentOptions[index];
                    bool isSelected = selectedAnswer == option;

                    Color btnColor = Colors.white;
                    Color borderColor = Colors.grey[300]!;
                    if (hasChecked) {
                      if (option == currentQ.correctAnswer) {
                        btnColor = Colors.green[100]!; borderColor = Colors.green;
                      } else if (isSelected) {
                        btnColor = Colors.red[100]!; borderColor = Colors.red;
                      }
                    } else if (isSelected) {
                      btnColor = Colors.green[50]!; borderColor = Colors.green;
                    }

                    return GestureDetector(
                      onTap: () { if (!hasChecked) setState(() => selectedAnswer = option); },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                        decoration: BoxDecoration(color: btnColor, borderRadius: BorderRadius.circular(15), border: Border.all(color: borderColor, width: 2)),
                        child: Text(option, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
              ),

              // ========================================================
              // ĐOẠN CODE HIỂN THỊ KẾT QUẢ VÀ GIẢI THÍCH
              // ========================================================
              if (hasChecked)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: selectedAnswer == currentQ.correctAnswer ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selectedAnswer == currentQ.correctAnswer ? Colors.green : Colors.red, width: 2)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hàng 1: Icon và chữ Tuyệt vời/Sai rồi
                      Row(
                        children: [
                          Icon(
                            selectedAnswer == currentQ.correctAnswer ? Icons.check_circle : Icons.cancel,
                            color: selectedAnswer == currentQ.correctAnswer ? Colors.green : Colors.red,
                            size: 30,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              selectedAnswer == currentQ.correctAnswer ? "Tuyệt vời!" : "Sai rồi. Đáp án đúng là: ${currentQ.correctAnswer}",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: selectedAnswer == currentQ.correctAnswer ? Colors.green[800] : Colors.red[800]),
                            ),
                          )
                        ],
                      ),

                      // Hàng 2: Hiện lời giải thích của AI
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb, color: Colors.orange, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                currentQ.explanation, // Lời giải thích từ Database
                                style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              // ========================================================

              // Nút Kiểm Tra
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: selectedAnswer == null ? null : () {
                    if (hasChecked) {
                      if (hearts > 0) _nextQuestion();
                    } else {
                      setState(() {
                        hasChecked = true;
                        if (selectedAnswer != currentQ.correctAnswer) {
                          hearts--;
                          if (hearts == 0) _showDialog("Hết lượt thử!", "Bạn đã hết trái tim ❤️. Hãy nghỉ ngơi và thử sức sau nhé!", false);
                        }
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasChecked && selectedAnswer == currentQ.correctAnswer ? Colors.green : (hasChecked && selectedAnswer != currentQ.correctAnswer && hearts > 0 ? Colors.red : const Color(0xFF0F8A50)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: Text(hasChecked ? "TIẾP TỤC" : "KIỂM TRA", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: selectedAnswer == null ? Colors.grey[500] : Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}