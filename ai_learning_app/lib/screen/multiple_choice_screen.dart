import 'package:flutter/material.dart';
import '../models/question_model.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase

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
  bool isSavingProgress = false; // Biến trạng thái khi đang lưu điểm

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
      _showCompletionDialog();
    }
  }

  // --- HÀM CỘNG GIỜ HỌC VÀO SPRING BOOT ---
  Future<void> _addStudyTime() async {
    const String url = "http://10.0.2.2:8080/api/progress/add-time";

    String username = FirebaseAuth.instance.currentUser?.displayName ?? "Đặng Thanh Vũ";

    try {
      await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "minutes": 5 // Thưởng 5 phút học cho mỗi bài hoàn thành
        }),
      );
    } catch (e) {
      print("Lỗi cộng giờ học: $e");
    }
  }

  // --- DIALOG HẾT TIM ---
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
          content: const Text("Bạn đã hết trái tim ❤️. Hãy nghỉ ngơi và thử sức sau nhé!", textAlign: TextAlign.center),
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

  // --- DIALOG HOÀN THÀNH CHIẾN THẮNG ---
  void _showCompletionDialog() {
    showDialog(
        context: context, barrierDismissible: false,
        builder: (context) => StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Column(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.green, size: 50),
                    Text("Tuyệt vời! 🎉", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
                content: const Text("Bạn đã hoàn thành bài học này.\nTiến độ học tập của bạn đã được lưu lại!", textAlign: TextAlign.center),
                actions: [
                  SizedBox(width: double.infinity, child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(vertical: 12)
                    ),
                    onPressed: isSavingProgress ? null : () async {
                      setStateDialog(() => isSavingProgress = true);

                      // Gọi API lưu tiến độ
                      await _addStudyTime();

                      if (context.mounted) {
                        Navigator.pop(context); // Đóng Dialog
                        Navigator.pop(context); // Thoát về Home
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
    if (widget.questions.isEmpty) return const Scaffold(body: Center(child: Text("Không có câu hỏi nào!")));
    QuestionModel currentQ = widget.questions[currentIndex];

    // BÍ KÍP MÀU ĐỘNG
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Câu ${currentIndex + 1}/${widget.questions.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        backgroundColor: Colors.transparent, elevation: 0, iconTheme: IconThemeData(color: textColor),
        actions: [ Padding(padding: const EdgeInsets.only(right: 15.0), child: Row(children: List.generate(3, (index) => Icon(index < hearts ? Icons.favorite : Icons.favorite_border, color: Colors.red, size: 26))))],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(4.0), child: LinearProgressIndicator(value: (currentIndex + 1) / widget.questions.length, backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[300], valueColor: const AlwaysStoppedAnimation<Color>(Colors.green))),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Chọn đáp án đúng:", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 20),

              // KHUNG CÂU HỎI
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(15), border: Border.all(color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!)),
                child: Text(currentQ.sentenceStart, style: TextStyle(fontSize: 18, height: 1.5, color: textColor)),
              ),
              const SizedBox(height: 30),

              // CÁC NÚT ĐÁP ÁN
              Expanded(
                child: ListView.separated(
                  itemCount: currentOptions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    String option = currentOptions[index];
                    bool isSelected = selectedAnswer == option;

                    Color btnColor = cardColor;
                    Color borderColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
                    Color optionTextColor = textColor;

                    if (hasChecked) {
                      if (option == currentQ.correctAnswer) { btnColor = isDarkMode ? Colors.green[900]! : Colors.green[100]!; borderColor = Colors.green; optionTextColor = isDarkMode ? Colors.white : Colors.green[900]!; }
                      else if (isSelected) { btnColor = isDarkMode ? Colors.red[900]! : Colors.red[100]!; borderColor = Colors.red; optionTextColor = isDarkMode ? Colors.white : Colors.red[900]!; }
                    } else if (isSelected) { btnColor = isDarkMode ? Colors.green[900]!.withOpacity(0.5) : Colors.green[50]!; borderColor = Colors.green; optionTextColor = Colors.green; }

                    return GestureDetector(
                      onTap: () { if (!hasChecked) setState(() => selectedAnswer = option); },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                        decoration: BoxDecoration(color: btnColor, borderRadius: BorderRadius.circular(15), border: Border.all(color: borderColor, width: 2)),
                        child: Text(option, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: optionTextColor)),
                      ),
                    );
                  },
                ),
              ),

              // ========================================================
              // ĐOẠN CODE HIỂN THỊ KẾT QUẢ VÀ GIẢI THÍCH (ĐÃ CẬP NHẬT MÀU ĐỘNG)
              // ========================================================
              if (hasChecked)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: selectedAnswer == currentQ.correctAnswer ? (isDarkMode ? Colors.green[900] : Colors.green[50]) : (isDarkMode ? Colors.red[900] : Colors.red[50]),
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
                            color: selectedAnswer == currentQ.correctAnswer ? (isDarkMode ? Colors.greenAccent : Colors.green) : (isDarkMode ? Colors.redAccent : Colors.red),
                            size: 30,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              selectedAnswer == currentQ.correctAnswer ? "Tuyệt vời!" : "Sai rồi. Đáp án đúng là: ${currentQ.correctAnswer}",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: selectedAnswer == currentQ.correctAnswer ? (isDarkMode ? Colors.greenAccent : Colors.green[800]) : (isDarkMode ? Colors.redAccent : Colors.red[800])),
                            ),
                          )
                        ],
                      ),

                      // Hàng 2: Hiện lời giải thích của AI
                      if (currentQ.explanation.isNotEmpty) ...[
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cardColor, // Đổi màu nền hộp giải thích theo Theme
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.lightbulb, color: Colors.orange, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  currentQ.explanation,
                                  style: TextStyle(fontSize: 14, color: textColor, height: 1.5),
                                ),
                              ),
                            ],
                          ),
                        )
                      ]
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
                          if (hearts == 0) _showGameOverDialog(); // Đã sửa thành hàm báo hết tim
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