import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http; // BẮT BUỘC THÊM DÒNG NÀY ĐỂ GỌI API
import 'dart:convert'; // Để dùng hàm jsonDecode
import '../providers/quiz_provider.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // --- CẤU HÌNH ĐỊA CHỈ SERVER ---
  // Nếu bạn chạy máy ảo Android (Emulator), phải dùng 10.0.2.2
  // Nếu bạn chạy Chrome (Web) hoặc Windows App, thì đổi thành localhost
  final String apiUrl = "http://10.0.2.2:8080/api/lessons/upload";

  // Hàm mở bộ nhớ để chọn file pdf và gửi lên AI
  Future<void> pickPDF(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    // Kiểm tra xem user có chọn file và file đó có đường dẫn (path) không
    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;
      String fileName = result.files.single.name;

      // 1. Báo cho user biết đang xử lý (vì AI cần 3-5 giây)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đang gửi $fileName cho AI phân tích. Vui lòng đợi...")),
      );

      try {
        // 2. Gói hàng (File PDF)
        var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
        request.files.add(await http.MultipartFile.fromPath('file', filePath));

        print("Đang gửi file lên Server...");

        // 3. Gửi đi và chờ Spring Boot trả lời
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          // 4. Mở hộp quà JSON (Giải mã)
          List<dynamic> quizData = jsonDecode(utf8.decode(response.bodyBytes));
          print("Nhận được câu hỏi từ AI: $quizData");

          // BƠM DỮ LIỆU VÀO PROVIDER Ở ĐÂY
          if (context.mounted) {
            // 1. Dọn dẹp nhà cửa (điểm số, tim) TRƯỚC
            context.read<QuizProvider>().resetQuiz();

            // 2. Mới rước đồ nội thất (câu hỏi mới) vào SAU
            context.read<QuizProvider>().setQuestions(quizData);

            // Chuyển sang màn hình Quiz
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QuizScreen()),
            );
          }
        } else {
          print("Lỗi Server: ${response.statusCode}");
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Lỗi Server: ${response.statusCode}")),
            );
          }
        }
      } catch (e) {
        print("Lỗi kết nối: $e");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Không thể kết nối đến Server!")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe dữ liệu từ provider
    final quizState = context.watch<QuizProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Learning App'),
        backgroundColor: Colors.green,
        actions: [
          // Hiển thị số tim
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.red),
                const SizedBox(width: 5),
                Text(
                  "${quizState.lives}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => pickPDF(context),
          icon: const Icon(Icons.file_upload),
          label: const Text('Chọn file PDF & tạo bài học'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}