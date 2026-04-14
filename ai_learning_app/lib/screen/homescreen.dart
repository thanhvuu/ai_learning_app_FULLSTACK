import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/quiz_provider.dart';
import 'quiz_screen.dart';
import 'discover_screen.dart';
import '../models/question_model.dart';
import 'drag_drop_quiz_screen.dart';
import 'multiple_choice_screen.dart';
import 'fill_blank_screen.dart';

// Chuyển sang StatefulWidget để xử lý thao tác bấm ở thanh điều hướng dưới cùng
class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // CẤU HÌNH ĐỊA CHỈ SERVER
  final String apiUrl = "http://10.0.2.2:8080/api/lessons/upload";

  int _selectedIndex = 0; // Quản lý tab đang chọn ở dưới cùng

  //bien du lieu
  int _streak = 0;
  int _xp = 0;

  //ham tu dong chay khi home bat
  @override
  void initState(){
    super.initState();
    fetchUserData();
  }

  //ham fetch api BE
  Future<void> fetchUserData() async{
    final String username = widget.username;
    final String url = "http://10.0.2.2:8080/api/users/profile?username=$username";

    try{
      var response = await http.get(Uri.parse(url));
      if(response.statusCode == 200){
        var data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _streak = data['streak'];
          _xp = data['totalXp'];
        });
      }
    } catch(e){
      print('Lỗi lấy dữ liệu: $e');
    }
  }



  // --- 1. HÀM CHỈ CHỌN FILE VÀ MỞ POPUP ---
  Future<void> pickPDFAndChooseGame(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      if (context.mounted) {
        _showGameModeDialog(context, file); // Mở Popup
      }
    }
  }

  // --- 2. HÀM VẼ CÁI POPUP CHỌN TRÒ CHƠI ---
  void _showGameModeDialog(BuildContext context, File file) {
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("Chọn chế độ học", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF0F8A50), fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("AI sẽ thiết kế bài học theo cách bạn muốn!", style: TextStyle(color: Colors.grey, fontSize: 13), textAlign: TextAlign.center),
                const SizedBox(height: 20),

                _buildGameOption(dialogContext, file, "Kéo thả từ vựng", Icons.drag_indicator, "drag_drop"),
                const SizedBox(height: 10),
                _buildGameOption(dialogContext, file, "Trắc nghiệm (A,B,C,D)", Icons.list_alt, "multiple_choice"),
                const SizedBox(height: 10),
                _buildGameOption(dialogContext, file, "Bài đục lỗ (Tự gõ)", Icons.keyboard, "fill_blank"),
              ],
            ),
          );
        }
    );
  }

  // Giao diện của từng nút bấm trong Popup
  Widget _buildGameOption(BuildContext dialogContext, File file, String title, IconData icon, String quizType) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: const Color(0xFFF4FAF5),
          foregroundColor: const Color(0xFF0F8A50),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.green[200]!, width: 1)),
        ),
        icon: Icon(icon),
        label: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        onPressed: () {
          Navigator.pop(dialogContext); // Đóng popup
          uploadFileAndGetQuiz(context, file, quizType); // Bắt đầu gửi API
        },
      ),
    );
  }

  // --- 3. HÀM GỬI API CÓ KÈM THEO LOẠI TRÒ CHƠI ---
  Future<void> uploadFileAndGetQuiz(BuildContext context, File file, String quizType) async {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (BuildContext context) => const Center(
        child: Card(child: Padding(padding: EdgeInsets.all(20.0), child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(color: Colors.green), SizedBox(height: 15), Text("AI đang soạn bài học...", style: TextStyle(fontWeight: FontWeight.bold))]))),
      ),
    );

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      // BÍ KÍP Ở ĐÂY: Gửi kèm cái quizType mà user vừa chọn lên cho Spring Boot
      request.fields['quizType'] = quizType;

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (context.mounted) Navigator.pop(context); // Tắt loading

      if (response.statusCode == 200) {
        var jsonResult = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> questionsJson = jsonResult['questions'] ?? [];

        if (questionsJson.isNotEmpty && context.mounted) {
          List<QuestionModel> generatedQuestions = questionsJson.map((q) => QuestionModel.fromJson(q)).toList();

          // KIỂM TRA LOẠI TRÒ CHƠI ĐỂ MỞ ĐÚNG MÀN HÌNH
          if (quizType == "drag_drop") {
            Navigator.push(context, MaterialPageRoute(builder: (_) => DragDropQuizScreen(questions: generatedQuestions))).then((_) => fetchUserData());
          } else if (quizType == "multiple_choice") {
            Navigator.push(context, MaterialPageRoute(builder: (_) => MultipleChoiceScreen(questions: generatedQuestions))).then((_) => fetchUserData());
          } else if (quizType == "fill_blank") { // <--- THÊM NHÁNH NÀY
            Navigator.push(context, MaterialPageRoute(builder: (_) => FillBlankScreen(questions: generatedQuestions))).then((_) => fetchUserData());
          }
        }
      } else {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi server: ${response.statusCode}"), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi kết nối: $e"), backgroundColor: Colors.red));
      }
    }
  }

  // Hàm phụ hiển thị thông báo lỗi
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
  }



  @override
  Widget build(BuildContext context) {
    // Màu chủ đạo theo thiết kế mới
    const Color bgColor = Color(0xFFF4FAF5);
    const Color darkGreen = Color(0xFF0F8A50);
    const Color lightGreen = Color(0xFF18C070);

    return Scaffold(
      backgroundColor: bgColor,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
// Tab 0: Nội dung màn hình Home cũ (Bạn bọc cái SafeArea cũ vào đây)
       SafeArea(
        child: Column(
          children: [
            // --- PHẦN 1: CUSTOM APP BAR (Avatar, Tiêu đề, Streak) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nhóm bên trái: Avatar + Tên App
                  // Nhóm bên trái: Avatar + Tên App + XP
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Learning App',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[900]),
                          ),
                          // Dòng hiển thị XP thật nè:
                          Text(
                            'Tổng điểm: $_xp XP',
                            style: TextStyle(fontSize: 13, color: Colors.green[700], fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Nhóm bên phải: Streak + Chuông thông báo
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "$_streak", // Tạm thời hardcode theo ảnh, sau này bạn gọi biến streak từ DB vào đây
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800]),
                            ),
                            const SizedBox(width: 4),
                            const Text("🔥", style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Icon(Icons.notifications, color: Colors.grey[800]),
                    ],
                  )
                ],
              ),
            ),

            // --- PHẦN 2: THẺ CARD GRADIENT Ở GIỮA ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [darkGreen, lightGreen], // Đổ bóng màu xanh
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: lightGreen.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Tiêu đề
                        const Text(
                          "Transform any PDF\ninto an\nInteractive\nLesson.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Mô tả
                        const Text(
                          "Our AI analyzes your\ndocuments to create\npersonalized vocabulary,\nquizzes, and speaking\nexercises.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // --- NÚT UPLOAD PDF (CHÍNH) ---
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton.icon(
                            onPressed: () => pickPDFAndChooseGame(context),// GỌI HÀM CỦA BẠN TẠI ĐÂY
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: darkGreen, // Màu chữ và icon
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.upload_file),
                            label: const Text(
                              'Upload PDF & Create\nLesson',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // --- NÚT BROWSE SAMPLES (PHỤ) ---
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: OutlinedButton(
                            onPressed: () {
                              // Chức năng Browse mẫu (Làm sau)
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white, width: 2),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Browse Samples',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      //tab1: My Lessons (Chưa làm)
        const Center(child: Text("Loading")),

      //tab2 Discover
        const DiscoverScreen(),

      //tab3 profile
        const Center(child: Text("Loading")),
       ],
      ),

      // --- PHẦN 3: BOTTOM NAVIGATION BAR CUSTOM ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 15, bottom: 25, left: 10, right: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_filled, "Home", 0, lightGreen),
            _buildNavItem(Icons.menu_book_rounded, "My Lessons", 1, lightGreen),
            _buildNavItem(Icons.explore, "Discover", 2, lightGreen),
            _buildNavItem(Icons.person, "Profile", 3, lightGreen),
          ],
        ),
      ),
    );
  }

  // Hàm hỗ trợ vẽ nút bấm ở thanh Bottom Navigation
  Widget _buildNavItem(IconData icon, String label, int index, Color activeColor) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? activeColor : Colors.grey[500],
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? activeColor : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}