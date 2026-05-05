import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart'; // Đảm bảo đường dẫn này đúng với project của bạn
import 'package:flutter_tts/flutter_tts.dart';
import '../services/dictionary_helper.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class DictionaryBottomSheet {
  static void show(BuildContext context, Map<String, dynamic> initialData, String searchWord) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _DictionarySheetContent(initialData: initialData, searchWord: searchWord);
      },
    );
  }
}

// Chuyển thành StatefulWidget để màn hình có thể tự cập nhật dữ liệu AI
class _DictionarySheetContent extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final String searchWord;

  const _DictionarySheetContent({required this.initialData, required this.searchWord});

  @override
  State<_DictionarySheetContent> createState() => _DictionarySheetContentState();
}

class _DictionarySheetContentState extends State<_DictionarySheetContent> {
  late Map<String, dynamic> wordData;
  bool _isLoadingAI = true; // Trạng thái đang tải AI
  final FlutterTts flutterTts = FlutterTts();

  bool _isSaved = false; // THÊM BIẾN KIỂM TRA TRẠNG THÁI LƯU

  @override
  void initState() {
    super.initState();
    // Gán dữ liệu ban đầu từ SQLite
    wordData = Map<String, dynamic>.from(widget.initialData);
    // Gọi AI ngầm dưới nền
    _fetchAdvancedDataFromAI();
    //GỌI HÀM CẤU HÌNH GIỌNG ĐỌC KHI MỞ BẢNG LÊN
    _initTts();
    // KIỂM TRA XEM TỪ ĐÃ LƯU TRONG VƯỜN ƯƠM CHƯA
    _checkSavedStatus();
  }

  // HÀM KIỂM TRA TRẠNG THÁI LƯU
  Future<void> _checkSavedStatus() async {
    String word = wordData['word'] ?? widget.searchWord;
    bool saved = await DictionaryHelper.isWordSaved(word);
    if (mounted) {
      setState(() => _isSaved = saved);
    }
  }

  // HÀM BẤM NÚT GIEO MẦM (LƯU TỪ)
  Future<void> _toggleSave() async {
    String word = wordData['word'] ?? widget.searchWord;
    String meaning = wordData['meaning'] ?? "Không có nghĩa";
    bool newState = await DictionaryHelper.toggleSaveWord(word, meaning);

    if (mounted) {
      setState(() => _isSaved = newState);

      // Xóa thông báo cũ (nếu bấm liên tục)
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // HIỆN THÔNG BÁO NỔI LÊN TRÊN CÙNG MÀN HÌNH
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newState ? "🌱 Đã gieo mầm từ '$word' vào vườn!" : "Đã nhổ từ '$word' khỏi vườn.",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFF0F8A50),
            behavior: SnackBarBehavior.floating, // Bắt buộc để làm nó nổi lên
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Bo góc cho đẹp
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.8, // Đẩy nó nổi tít lên trên Bottom Sheet
              left: 20,
              right: 20,
            ),
          )
      );
    }
  }
  // HÀM CẤU HÌNH GIỌNG ĐỌC TIẾNG ANH (MỸ)
  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-US"); // Đọc tiếng Anh Mỹ
    await flutterTts.setSpeechRate(0.5);   // Tốc độ đọc (0.5 là vừa nghe, 1.0 hơi nhanh)
    await flutterTts.setVolume(1.0);       // Âm lượng tối đa
    await flutterTts.setPitch(1.0);        // Độ trầm bổng
  }

  // HÀM PHÁT ÂM KHI BẤM NÚT
  Future<void> _speakWord() async {
    String textToSpeak = wordData['word'] ?? widget.searchWord;
    if (textToSpeak.isNotEmpty) {
      await flutterTts.speak(textToSpeak);
    }
  }

  Future<void> _fetchAdvancedDataFromAI() async {
    try {
      final String searchUrl = "${ApiConfig.baseUrl}/api/dictionary/lookup?word=${Uri.encodeComponent(widget.searchWord)}";
      var response = await http.get(Uri.parse(searchUrl));

      if (response.statusCode == 200) {
        var aiData = jsonDecode(utf8.decode(response.bodyBytes));

        // Cập nhật lại giao diện với dữ liệu mới từ AI
        if (mounted) {
          setState(() {
            // Đắp thêm các trường AI vào data hiện tại
            wordData['examples'] = aiData['examples'];
            wordData['synonyms'] = aiData['synonyms'];
            wordData['antonyms'] = aiData['antonyms'];

            //Nếu nghĩa đang là câu chờ thì lấy nghĩa của AI đắp vào
            if (wordData['meaning'] == "Đang nhờ AI phân tích cụm từ này..." ||
                wordData['meaning'] == null ||
                wordData['meaning'].toString().isEmpty) {
              wordData['meaning'] = aiData['meaning'];
            }

            // Nếu SQLite thiếu phiên âm hoặc loại từ, lấy luôn của AI bù vào
            if (wordData['phonetic'] == null || wordData['phonetic'].toString().isEmpty) {
              wordData['phonetic'] = aiData['phonetic'];
            }
            if (wordData['partOfSpeech'] == null || wordData['partOfSpeech'].toString().isEmpty) {
              wordData['partOfSpeech'] = aiData['partOfSpeech'];
            }

            _isLoadingAI = false; // Tắt vòng xoay loading
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingAI = false);
      }
    } catch (e) {
      print("Lỗi gọi AI: $e");
      if (mounted) setState(() => _isLoadingAI = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final Color bgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B2A22);
    final Color exampleBgColor = isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFF0F7F4);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thanh kéo
          Center(
            child: Container(
              width: 50, height: 5,
              decoration: BoxDecoration(color: isDarkMode ? Colors.grey[700] : Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 20),

          // TỪ VỰNG & PHIÊN ÂM
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wordData['word'] ?? widget.searchWord,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0F8A50)),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "/${wordData['phonetic'] ?? '...'} /  •  ${wordData['partOfSpeech'] ?? ''}",
                      style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.grey[400] : Colors.grey[600], fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),

              // KHU VỰC CHỨA NÚT GIEO MẦM VÀ NÚT LOA
              Row(
                children: [
                  // Nút Gieo Mầm / Lưu từ vựng
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                        color: _isSaved ? const Color(0xFF0F8A50) : const Color(0xFF0F8A50).withOpacity(0.1),
                        shape: BoxShape.circle
                    ),
                    child: IconButton(
                      icon: Icon(
                          _isSaved ? Icons.eco : Icons.eco_outlined,
                          color: _isSaved ? Colors.white : const Color(0xFF0F8A50),
                          size: 24
                      ),
                      onPressed: _toggleSave,
                    ),
                  ),
                  // Nút Loa
                  Container(
                    decoration: BoxDecoration(color: const Color(0xFF0F8A50).withOpacity(0.1), shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.volume_up, color: Color(0xFF0F8A50), size: 24),
                      onPressed: _speakWord,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Divider(height: 30, thickness: 1, color: isDarkMode ? Colors.grey[800] : Colors.grey[200]),

          // CHI TIẾT BÊN DƯỚI
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. NGHĨA CƠ BẢN (Từ SQLite - Có ngay lập tức)
                  _buildSectionTitle("Nghĩa tiếng Việt"),
                  Text(
                    _cleanHtml(wordData['meaning'] ?? "Đang cập nhật..."), // Hàm dọn sạch thẻ HTML nếu có
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, height: 1.4, color: textColor),
                  ),
                  const SizedBox(height: 25),

                  // NẾU ĐANG TẢI AI -> HIỆN LOADING
                  if (_isLoadingAI) ...[
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          const CircularProgressIndicator(color: Color(0xFF0F8A50), strokeWidth: 3),
                          const SizedBox(height: 10),
                          Text("AI đang phân tích ví dụ và từ đồng nghĩa...", style: TextStyle(color: isDarkMode ? Colors.grey[500] : Colors.grey, fontSize: 13, fontStyle: FontStyle.italic))
                        ],
                      ),
                    )
                  ]
                  // NẾU TẢI XONG -> HIỆN VÍ DỤ VÀ ĐỒNG NGHĨA
                  else ...[
                    // 2. VÍ DỤ (EXAMPLES)
                    if (wordData['examples'] != null && (wordData['examples'] as List).isNotEmpty) ...[
                      _buildSectionTitle("Ví dụ (Examples)"),
                      ...(wordData['examples'] as List<dynamic>).map((ex) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(color: exampleBgColor, borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ex['en'] ?? "", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
                              const SizedBox(height: 6),
                              Text(ex['vn'] ?? "", style: TextStyle(fontSize: 15, color: isDarkMode ? Colors.grey[400] : Colors.grey[700], fontStyle: FontStyle.italic)),
                            ],
                          ),
                        ),
                      )),
                      const SizedBox(height: 15),
                    ],

                    // 3. TỪ ĐỒNG NGHĨA & TRÁI NGHĨA
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (wordData['synonyms'] != null && (wordData['synonyms'] as List).isNotEmpty)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle("Đồng nghĩa"),
                                Wrap(
                                  spacing: 8, runSpacing: 8,
                                  children: (wordData['synonyms'] as List<dynamic>).map((s) => Chip(
                                    label: Text(s.toString()),
                                    backgroundColor: isDarkMode ? Colors.blue.withOpacity(0.2) : Colors.blue[50], side: BorderSide.none,
                                    labelStyle: TextStyle(color: isDarkMode ? Colors.blue[200] : Colors.blue, fontWeight: FontWeight.bold),
                                  )).toList(),
                                )
                              ],
                            ),
                          ),
                        const SizedBox(width: 10),
                        if (wordData['antonyms'] != null && (wordData['antonyms'] as List).isNotEmpty)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle("Trái nghĩa"),
                                Wrap(
                                  spacing: 8, runSpacing: 8,
                                  children: (wordData['antonyms'] as List<dynamic>).map((a) => Chip(
                                    label: Text(a.toString()),
                                    backgroundColor: isDarkMode ? Colors.red.withOpacity(0.2) : Colors.red[50], side: BorderSide.none,
                                    labelStyle: TextStyle(color: isDarkMode ? Colors.red[200] : Colors.red, fontWeight: FontWeight.bold),
                                  )).toList(),
                                )
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
    );
  }

  // Hàm phụ dọn dẹp các thẻ HTML (như <ul>, <li>, <br>) hay bị lẫn trong SQLite database
  String _cleanHtml(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '').trim();
  }
}
