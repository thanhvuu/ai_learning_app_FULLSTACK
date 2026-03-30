import 'package:flutter/material.dart';

class QuizProvider extends ChangeNotifier{
  int lives = 3; // so mang con lai
  double progress = 0.0; //tien trinh mac dinh
  // 1. Chỗ giấu dữ liệu (có dấu gạch dưới _ là private)
  List<dynamic> _questions = [];

  // 2. THÊM DÒNG NÀY: Mở cửa (getter) để màn hình khác lấy được dữ liệu ra đọc
  List<dynamic> get questions => _questions;

  //ham tru khi lam sai
void decreaseLive(){
  if(lives > 0){
    lives--;
    notifyListeners();//goi lai ham build de giao dien ve lai so mang
  }
}

  //ham cap nhat tien trinh
void updateProgress(double p) {
  progress = p;
  notifyListeners();
}

//ham rs lai bai moi
void resetQuiz(){
  lives = 3;
  progress = 0.0;
  notifyListeners();
}

// Hàm này dùng để nhận dữ liệu thật từ Server ném vào
  void setQuestions(List<dynamic> apiQuestions) {
    // Ép kiểu dữ liệu API cho khớp với định dạng List<Map<String, dynamic>> của app
      _questions = List<Map<String, dynamic>>.from(apiQuestions);
    notifyListeners(); // bao cho giao diện biết là có câu hỏi mới rồi, vẽ lại
  }

}