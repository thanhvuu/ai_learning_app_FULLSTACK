import 'package:flutter/material.dart';
import '../api_config.dart';
import 'package:dotted_border/dotted_border.dart';
import '../models/question_model.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart'; // Thêm import Firebase để lấy tên User

class DragDropQuizScreen extends StatefulWidget {
  final List<QuestionModel> questions;

  const DragDropQuizScreen({super.key, required this.questions});

  @override
  State<DragDropQuizScreen> createState() => _DragDropQuizScreenState();
}

class _DragDropQuizScreenState extends State<DragDropQuizScreen> {
  int currentIndex = 0;
  String? droppedWord;
  bool hasChecked = false;
  late List<String> currentOptions;
  bool isSavingProgress = false; // Biến xoay loading khi lưu điểm

  // --- BIẾN TRÁI TIM ---
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

  // --- HÀM KIỂM TRA ĐÁP ÁN ---
  void _checkAnswer() {
    if (droppedWord == null) return;

    setState(() {
      hasChecked = true;
      // Nếu chọn sai thì trừ tim
      if (droppedWord?.trim() != widget.questions[currentIndex].correctAnswer.trim()) {
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

  // --- HÀM CỘNG GIỜ HỌC VÀO SPRING BOOT ---
  Future<void> _addStudyTime() async {
    final String url = "${ApiConfig.progress}/add-time";

    // Lấy tên thật của người dùng từ Firebase (Hoặc dùng tên mặc định nếu lỗi)
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
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Column(
            children: [
              Icon(Icons.heart_broken, color: Colors.red, size: 50),
              SizedBox(height: 10),
              Text("Hết lượt thử!", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text("Bạn đã hết trái tim ❤️. Hãy nghỉ ngơi, ôn tập lại và thử sức sau nhé!", textAlign: TextAlign.center),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.symmetric(vertical: 12)
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("Về trang chủ", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        )
    );
  }

  // --- DIALOG HOÀN THÀNH CHIẾN THẮNG ---
  void _showCompletionDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Text("Tuyệt vời! 🎉", textAlign: TextAlign.center, style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                content: const Text("Bạn đã hoàn thành bài học này.\nTiến độ học tập của bạn đã được lưu lại!", textAlign: TextAlign.center),
                actions: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          padding: const EdgeInsets.symmetric(vertical: 12)
                      ),
                      onPressed: isSavingProgress ? null : () async {
                        setStateDialog(() => isSavingProgress = true);

                        // 1. Gọi API cộng 5 phút học vào Database
                        await _addStudyTime();

                        // 2. Thoát về trang chủ sau khi cộng giờ thành công
                        if (context.mounted) {
                          Navigator.pop(context); // Tắt Dialog
                          Navigator.pop(context); // Tắt màn hình Quiz
                        }
                      },
                      child: isSavingProgress
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Trở về trang chủ", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  )
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
        actions: [
          Padding(padding: const EdgeInsets.only(right: 15.0), child: Row(children: List.generate(3, (index) => Icon(index < hearts ? Icons.favorite : Icons.favorite_border, color: Colors.red, size: 26))))
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(4.0), child: LinearProgressIndicator(value: (currentIndex + 1) / widget.questions.length, backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[300], valueColor: const AlwaysStoppedAnimation<Color>(Colors.green))),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Kéo từ đúng vào chỗ trống:", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 40),

              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center, spacing: 10, runSpacing: 15,
                children: [
                  Text(currentQ.sentenceStart, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: textColor)),
                  DragTarget<String>(
                    onWillAcceptWithDetails: (details) => !hasChecked,
                    onAcceptWithDetails: (details) => setState(() { droppedWord = details.data; hasChecked = false; }),
                    builder: (context, candidateData, rejectedData) {
                      if (droppedWord != null) return GestureDetector(onTap: () { if (!hasChecked) setState(() => droppedWord = null); }, child: _buildWordBlock(droppedWord!, isDropped: true, cardColor: cardColor, textColor: textColor));
                      return DottedBorder(
                        color: candidateData.isNotEmpty ? Colors.green : Colors.grey, strokeWidth: 2, dashPattern: const [6, 4], borderType: BorderType.RRect, radius: const Radius.circular(15),
                        child: Container(width: 80, height: 45, alignment: Alignment.center, color: candidateData.isNotEmpty ? Colors.green.withOpacity(0.1) : Colors.transparent),
                      );
                    },
                  ),
                  Text(currentQ.sentenceEnd, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: textColor)),
                ],
              ),
              const SizedBox(height: 50),

              Wrap(
                spacing: 15, runSpacing: 15, alignment: WrapAlignment.center,
                children: currentOptions.map((word) {
                  if (word == droppedWord) return Container(width: 80, height: 45, decoration: BoxDecoration(color: isDarkMode ? Colors.grey[800] : Colors.grey[300], borderRadius: BorderRadius.circular(15)));
                  return Draggable<String>(
                    data: word, feedback: Material(color: Colors.transparent, child: _buildWordBlock(word, isDragging: true, cardColor: cardColor, textColor: textColor)),
                    childWhenDragging: Container(width: 80, height: 45, decoration: BoxDecoration(color: isDarkMode ? Colors.grey[800] : Colors.grey[300], borderRadius: BorderRadius.circular(15))),
                    child: _buildWordBlock(word, cardColor: cardColor, textColor: textColor),
                  );
                }).toList(),
              ),

              const Spacer(),

              // --- KHUNG HIỂN THỊ KẾT QUẢ KHI KIỂM TRA ---
              if (hasChecked)
                Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: droppedWord?.trim() == currentQ.correctAnswer.trim() ? (isDarkMode ? Colors.green[900] : Colors.green[100]) : (isDarkMode ? Colors.red[900] : Colors.red[100]),
                        borderRadius: BorderRadius.circular(15)
                    ),
                    child: Column(
                        children: [
                          Text(
                              droppedWord?.trim() == currentQ.correctAnswer.trim() ? "Chính xác!" : "Sai rồi! Đáp án đúng: ${currentQ.correctAnswer}",
                              style: TextStyle(
                                  color: droppedWord?.trim() == currentQ.correctAnswer.trim() ? (isDarkMode ? Colors.greenAccent : Colors.green[800]) : (isDarkMode ? Colors.redAccent : Colors.red[800]),
                                  fontWeight: FontWeight.bold, fontSize: 16
                              )
                          ),
                          if (currentQ.explanation.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Text(currentQ.explanation, style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87), textAlign: TextAlign.center),
                          ]
                        ]
                    )
                ),

              const SizedBox(height: 15),

              // --- NÚT BẤM (KIỂM TRA / TIẾP TỤC) ---
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: droppedWord == null ? Colors.grey : const Color(0xFF0F8A50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                  ),
                  onPressed: droppedWord == null ? null : (hasChecked ? _nextQuestion : _checkAnswer),
                  child: Text(
                      hasChecked ? "Tiếp tục" : "Kiểm tra",
                      style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWordBlock(String word, {bool isDragging = false, bool isDropped = false, required Color cardColor, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
            color: isDropped ? Colors.green : (cardColor == Colors.white
                ? Colors.grey[300]!
                : Colors.grey[700]!), width: 2),
      ),
      child: Text(word, style: TextStyle(fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDropped ? Colors.green : textColor,
          decoration: TextDecoration.none)),
    );
  }
}