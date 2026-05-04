import 'package:flutter/material.dart';
import '../services/dictionary_helper.dart';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlashcardScreen extends StatefulWidget {
  final List<Map<String, dynamic>> reviewWords;

  const FlashcardScreen({super.key, required this.reviewWords});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int _currentIndex = 0;
  bool _isFlipped = false;

  // BIẾN ĐẾM SỐ CÂY ĐÃ TƯỚI (CHỈ TÍNH NHỮNG TỪ BẤM "ĐÃ NHỚ")
  int _wateredCount = 0;

  void _nextCard(bool isRemembered) async {
    var currentWord = widget.reviewWords[_currentIndex];

    // Cập nhật SQLite (Offline)
    await DictionaryHelper.updateWordProgress(
        currentWord['word'],
        currentWord['level'] ?? 0,
        isRemembered
    );

    // Nếu nhớ từ, cộng vào biến đếm
    if (isRemembered) {
      _wateredCount++;
    }

    if (_currentIndex < widget.reviewWords.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
    } else {
      // HẾT TỪ -> ĐẨY THÀNH TÍCH LÊN SERVER TRƯỚC KHI HIỆN THÔNG BÁO
      await _pushWateredPlantsToServer();
      _showCompletionDialog();
    }
  }

  // HÀM BẮN API LÊN SPRING BOOT
  Future<void> _pushWateredPlantsToServer() async {
    if (_wateredCount == 0) return; // Không tưới được cây nào thì thôi

    try {
      // LƯU Ý: Bạn cần truyền username vào đây (có thể lấy từ SharedPreferences)
      String username = "vucumu191"; // SỬA LẠI ĐỂ LẤY USERNAME ĐỘNG CỦA BẠN

      // Giả sử API của bạn là: /api/users/update-plants
      final String url = "${ApiConfig.baseUrl}/api/users/update-plants?username=$username&plants=$_wateredCount";

      await http.post(Uri.parse(url)); // Gửi báo cáo lên server
      print("Đã cộng $_wateredCount cây lên server!");
    } catch (e) {
      print("Lỗi khi gửi thành tích lên server: $e");
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("🎉 Tuyệt vời!", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF0F8A50), fontWeight: FontWeight.bold)),
        content: const Text("Bạn đã tưới nước xong cho toàn bộ khu vườn hôm nay. Các mầm cây đang lớn lên rất nhanh!", textAlign: TextAlign.center),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F8A50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              onPressed: () {
                Navigator.pop(context); // Tắt Dialog
                Navigator.pop(context, true); // Thoát về Vườn Ươm & báo load lại
              },
              child: const Text("Quay lại Vườn", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reviewWords.isEmpty) return const Scaffold(body: Center(child: Text("Không có từ nào để ôn!")));

    var currentWord = widget.reviewWords[_currentIndex];
    const Color primaryGreen = Color(0xFF0F8A50);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context, true)),
        title: Text("Đang tưới nước: ${_currentIndex + 1}/${widget.reviewWords.length}", style: const TextStyle(color: Colors.grey, fontSize: 16)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // THANH TIẾN ĐỘ
            LinearProgressIndicator(
              value: (_currentIndex + 1) / widget.reviewWords.length,
              backgroundColor: Colors.green[100],
              color: primaryGreen,
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 50),

            // THẺ FLASHCARD
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (!_isFlipped) setState(() => _isFlipped = true);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: primaryGreen.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                    border: _isFlipped ? Border.all(color: primaryGreen.withOpacity(0.5), width: 2) : null,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentWord['word'],
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: _isFlipped ? primaryGreen : const Color(0xFF1B2A22)),
                        ),
                        const SizedBox(height: 20),

                        // Nếu lật rồi thì hiện nghĩa, chưa lật thì kêu "Chạm để lật"
                        if (_isFlipped) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              currentWord['meaning'] ?? "",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                            ),
                          )
                        ] else ...[
                          Text("Chạm để xem nghĩa", style: TextStyle(color: Colors.grey[400], fontStyle: FontStyle.italic)),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),

            // NÚT BẤM (CHỈ HIỆN KHI ĐÃ LẬT THẺ)
            AnimatedOpacity(
              opacity: _isFlipped ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // NÚT QUÊN
                  ElevatedButton(
                    onPressed: _isFlipped ? () => _nextCard(false) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    child: const Text("Chưa nhớ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),

                  // NÚT ĐÃ NHỚ
                  ElevatedButton(
                    onPressed: _isFlipped ? () => _nextCard(true) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    child: const Text("Đã thuộc!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}