
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/quiz_provider.dart';


//import '../fdata.dart'; // Nhớ import file dữ liệu giả ở trên

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0; // Câu hỏi hiện tại
  String? selectedOption; // Đáp án người dùng chọn
  bool hasSubmitted = false; // Đã bấm nút "Kiểm tra" chưa?
  bool isCorrect = false; // Trả lời đúng hay sai?

  // Hàm xử lý khi chọn một đáp án
  void selectOption(String option) {
    if (!hasSubmitted) {
      setState(() {
        selectedOption = option;
      });
    }
  }

  // Hàm xử lý khi bấm nút "Kiểm tra" hoặc "Tiếp tục"
 Future<void> checkAnswer(BuildContext context, QuizProvider quizState) async {
    if (!hasSubmitted) {
      // KIỂM TRA ĐÁP ÁN
      if (selectedOption != null) {
        // Lấy đáp án chuẩn từ AI (Ví dụ: "C")
        String correctAns = quizState.questions[currentQuestionIndex]['correctAnswer'].toString();
        // Kiểm tra xem đáp án mình chọn (Ví dụ: "C. Ba trang") có bắt đầu bằng chữ "C" không
        bool correct = selectedOption!.startsWith(correctAns) || selectedOption == correctAns;
        setState(() {
          hasSubmitted = true;
          isCorrect = correct;
        });

        // Cập nhật State Management
        if (correct) {
          // Trả lời ĐÚNG -> Tăng thanh tiến trình
          double currentProgress = (currentQuestionIndex + 1) / quizState.questions.length;
          quizState.updateProgress(currentProgress);
        } else {
          // Trả lời SAI -> Trừ một tim
          quizState.decreaseLive();
          if (quizState.lives == 0) {
            // Hết tim -> Show thông báo Game Over (tự thêm logic này)
            _showGameOverDialog(context);
          }
        }
      }
    } else {
      //chuyen sang cau hoi tip theo
      if(currentQuestionIndex < quizState.questions.length-1) {
        setState((){
          currentQuestionIndex++;
          hasSubmitted = false;
          isCorrect = false;
          selectedOption = null;
        });
      } else {
        //hoan thanh
        quizState.updateProgress(1.0);

        final String username = "Đặng Thanh Vũ";
        final String updateUrl = "http://10.0.2.2:8080/api/users/update-progress?username=$username";

        try{
          //gui yeu cau put den sv springboot
          var reponse = await http.put(Uri.parse(updateUrl));

          if(reponse.statusCode == 200){
            //json sv tra ve
            var data = jsonDecode(utf8.decode(reponse.bodyBytes));
            int newXp =data['totalXp'];
            int newStreak = data['streak'];

            //thong bao
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
        }
        catch(e){
          print('lỗi lưu tiến độ');
        }

        //tro ve homescreen
        if(context.mounted){
          Navigator.pop(context);
        }
      }
    }
  }

  // Dialog Game Over khi hết tim
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
              Navigator.pop(context); // Đóng Dialog
              Navigator.pop(context); // Về màn hình Home
            },
            child: const Text("Quay về"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe dữ liệu từ "Tổng đài"
    final quizState = context.watch<QuizProvider>();
    // THÊM ĐOẠN NÀY ĐỂ BẢO VỆ APP:
    // Nếu chưa có câu hỏi nào thì hiện vòng xoay chờ
    if (quizState.questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // SỬA DÒNG NÀY: Lấy câu hỏi từ quizState thay vì dummyQuestions
    final currentQuestion = quizState.questions[currentQuestionIndex];

    // Cấu trúc UI:
    // Bottom: Nút confirmation / Feedback
    // Body: Giao diện câu hỏi và thanh tiến trình
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // 1. Thanh Tiến Trình (Progress Bar) Gamification
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context), // Nút thoát
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: quizState.progress, // Dữ liệu từ Provider
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
            // 2. Nội dung Câu hỏi (big, bold text)
            Text(
              currentQuestion['prompt'],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const Spacer(flex: 2),

            // 3. Danh sách các Đáp án (Options Buttons) Duolingo Style
            Column(
              children: (currentQuestion['options'] as List).map<Widget>((option) {
                // Logic màu sắc cho các nút đáp án (Default, Selected, Correct, Wrong)
                Color buttonColor = Colors.white;
                Color textColor = Colors.black87;
                Color borderColor = Colors.grey[300]!;

                if (option == selectedOption) {
                  buttonColor = const Color(0xFFE8F6F3); // Màu xanh nhạt Duolingo
                  borderColor = Colors.greenAccent;
                }

                if (hasSubmitted) {
                  // Lấy đáp án chuẩn (Ví dụ: "C")
                  String correctAns = currentQuestion['correctAnswer'].toString();

                  // Kiểm tra linh hoạt: Nếu text của nút (Ví dụ: "C. Ba trang") bắt đầu bằng "C" -> Tô xanh
                  if (option.toString().startsWith(correctAns) || option.toString() == correctAns) {
                    borderColor = Colors.greenAccent; // Show màu xanh cho đáp án đúng
                  } else if (option == selectedOption) {
                    borderColor = Colors.redAccent; // Show màu đỏ nếu chọn sai
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
      // 4. Màn hình Feedback / Bottom Button (Gamification)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: hasSubmitted ? (isCorrect ? Colors.lightGreen[100] : Colors.red[100]) : Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
        ), // <--- LỖI NẰM Ở ĐÂY: Bạn bị thiếu dấu đóng ngoặc và dấu phẩy này
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hiển thị kết quả đúng/sai (Duolingo Style)
            if (hasSubmitted)
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // Đẩy icon lên ngang hàng với dòng chữ đầu tiên
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
                          if (!isCorrect)
                            const SizedBox(height: 5), // Thêm chút khoảng cách cho đẹp
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

            // Nút bấm "Kiểm tra" hoặc "Tiếp tục" Duolingo style
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasSubmitted ? (isCorrect ? Colors.green : Colors.red) : Colors.lightGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: hasSubmitted ? 0 : 5, // Có bóng đổ giống Duolingo nút mặc định
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