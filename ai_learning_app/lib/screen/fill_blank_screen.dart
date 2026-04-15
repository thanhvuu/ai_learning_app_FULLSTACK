import 'package:flutter/material.dart';
import '../models/question_model.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

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
    // Tự động mở bàn phím khi sang câu mới
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
      _showResultDialog("Hoàn thành! 🎉", "Bạn thật là một thiên tài ngôn ngữ!", true);
    }
  }

  void _checkAnswer() {
    String userAnswer = _answerController.text.trim().toLowerCase();
    String correctAnswer = widget.questions[currentIndex].correctAnswer.toLowerCase();

    setState(() {
      hasChecked = true;
      if (userAnswer != correctAnswer) {
        hearts--;
        if (hearts == 0) {
          _showResultDialog("Hết lượt thử!", "Đừng bỏ cuộc, hãy thử lại nhé!", false);
        }
      }
    });
  }

  void _showResultDialog(String title, String content, bool isSuccess) {
    showDialog(
        context: context, barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Icon(isSuccess ? Icons.stars : Icons.heart_broken, color: isSuccess ? Colors.orange : Colors.red, size: 60),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(content, textAlign: TextAlign.center),
            ],
          ),
          actions: [
            SizedBox(width: double.infinity, child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: isSuccess ? Colors.green : Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              child: const Text("Về trang chủ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ))
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    QuestionModel currentQ = widget.questions[currentIndex];
    bool isCorrect = _answerController.text.trim().toLowerCase() == currentQ.correctAnswer.toLowerCase();

    // BÍ KÍP MÀU ĐỘNG
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

            // --- GIẢI THÍCH (CHỈ HIỆN KHI ĐÃ CHECK) ---
            if (hasChecked)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isCorrect ? Colors.green : Colors.red),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isCorrect ? "Chính xác! 🥳" : "Chưa đúng rồi! Đáp án là: ${currentQ.correctAnswer}",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isCorrect ? Colors.green[800] : Colors.red[800])),
                    const SizedBox(height: 10),
                    Text(currentQ.explanation, style: const TextStyle(fontSize: 15, height: 1.4)),
                  ],
                ),
              ),
          ],
        ),
      ),

      // Nút bấm cố định ở dưới
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed: _answerController.text.isEmpty ? null : (hasChecked ? _nextQuestion : _checkAnswer),
            style: ElevatedButton.styleFrom(
              backgroundColor: hasChecked ? (isCorrect ? Colors.green : Colors.red) : const Color(0xFF0F8A50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: Text(hasChecked ? "TIẾP TỤC" : "KIỂM TRA", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}