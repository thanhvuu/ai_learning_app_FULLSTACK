import 'dart:io';
import 'dart:async'; // Dùng cho chức năng delay dịch thuật

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:translator/translator.dart'; // Thư viện dịch thuật

import '../api_config.dart';
import '../providers/theme_provider.dart';
import '../providers/quiz_provider.dart';
import 'discover_screen.dart';
import '../models/question_model.dart';
import 'drag_drop_quiz_screen.dart';
import 'multiple_choice_screen.dart';
import 'fill_blank_screen.dart';
import 'profile_screen.dart';
import 'my_lessons_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String apiUrl = "${ApiConfig.lessons}/upload";
  int _selectedIndex = 0;
  int _streak = 0;
  int _xp = 0;

  // ==========================================
  // BIẾN CHO CHỨC NĂNG DỊCH THUẬT
  // ==========================================
  final GoogleTranslator _translator = GoogleTranslator();
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  Timer? _debounce; // Biến để hẹn giờ dịch (gõ xong mới dịch)

  String sourceLangName = "English";
  String targetLangName = "Vietnamese";
  String sourceLangCode = "en";
  String targetLangCode = "vi";

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final String url = "${ApiConfig.users}/profile?username=${widget.username}";
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = jsonDecode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            _streak = data['streak'];
            _xp = data['totalXp'];
          });
        }
      }
    } catch (e) {
      print('Lỗi lấy dữ liệu: $e');
    }
  }

  // --- HÀM DỊCH THUẬT TỰ ĐỘNG ---
  void _onInputTextChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Đợi người dùng ngừng gõ 1 giây rồi mới dịch để đỡ lag
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      if (text.trim().isEmpty) {
        setState(() => _outputController.text = "");
        return;
      }
      try {
        var translation = await _translator.translate(text, from: sourceLangCode, to: targetLangCode);
        setState(() {
          _outputController.text = translation.text;
        });
      } catch (e) {
        setState(() => _outputController.text = "Lỗi dịch thuật...");
      }
    });
  }

  // --- HÀM ĐẢO NGÔN NGỮ ---
  void _swapLanguage() {
    setState(() {
      // Đảo tên
      String tempName = sourceLangName;
      sourceLangName = targetLangName;
      targetLangName = tempName;
      // Đảo mã code
      String tempCode = sourceLangCode;
      sourceLangCode = targetLangCode;
      targetLangCode = tempCode;
      // Đảo chữ
      String tempText = _inputController.text;
      _inputController.text = _outputController.text;
      _outputController.text = tempText;
    });
    // Dịch lại sau khi đảo
    if (_inputController.text.isNotEmpty) {
      _onInputTextChanged(_inputController.text);
    }
  }

  // --- MENU CHỌN ẢNH (GIAO DIỆN) ---
  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF0F8A50)),
              title: const Text('Chụp ảnh mới'),
              onTap: () { Navigator.pop(context); /* TODO: Gọi hàm OCR */ },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF0F8A50)),
              title: const Text('Chọn từ thư viện'),
              onTap: () { Navigator.pop(context); /* TODO: Gọi hàm OCR */ },
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // CÁC HÀM UPLOAD PDF BÀI HỌC CŨ (GIỮ NGUYÊN)
  // ==========================================
  Future<void> pickPDFAndChooseGame(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      if (context.mounted) _showGameModeDialog(context, file);
    }
  }

  void _showGameModeDialog(BuildContext context, File file) {
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          final isDarkMode = Provider.of<ThemeProvider>(dialogContext, listen: false).isDarkMode;
          return AlertDialog(
            backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("Chọn chế độ học", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF0F8A50), fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("AI sẽ thiết kế bài học theo cách bạn muốn!", style: TextStyle(color: Colors.grey, fontSize: 13), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                _buildGameOption(dialogContext, file, "Kéo thả từ vựng", Icons.drag_indicator, "drag_drop", isDarkMode),
                const SizedBox(height: 10),
                _buildGameOption(dialogContext, file, "Trắc nghiệm", Icons.list_alt, "multiple_choice", isDarkMode),
                const SizedBox(height: 10),
                _buildGameOption(dialogContext, file, "Bài đục lỗ", Icons.keyboard, "fill_blank", isDarkMode),
              ],
            ),
          );
        }
    );
  }

  Widget _buildGameOption(BuildContext dialogContext, File file, String title, IconData icon, String quizType, bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFF4FAF5),
          foregroundColor: const Color(0xFF0F8A50),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.green[200]!, width: 1)),
        ),
        icon: Icon(icon),
        label: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDarkMode ? Colors.white : Colors.black87)),
        onPressed: () {
          Navigator.pop(dialogContext);
          uploadFileAndGetQuiz(context, file, quizType);
        },
      ),
    );
  }

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
      request.fields['quizType'] = quizType;
      request.fields['username'] = widget.username;

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (context.mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        var jsonResult = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> questionsJson = jsonResult['questions'] ?? [];

        if (questionsJson.isNotEmpty && context.mounted) {
          List<QuestionModel> generatedQuestions = questionsJson.map((q) => QuestionModel.fromJson(q)).toList();
          if (quizType == "drag_drop") Navigator.push(context, MaterialPageRoute(builder: (_) => DragDropQuizScreen(questions: generatedQuestions))).then((_) => fetchUserData());
          else if (quizType == "multiple_choice") Navigator.push(context, MaterialPageRoute(builder: (_) => MultipleChoiceScreen(questions: generatedQuestions))).then((_) => fetchUserData());
          else if (quizType == "fill_blank") Navigator.push(context, MaterialPageRoute(builder: (_) => FillBlankScreen(questions: generatedQuestions))).then((_) => fetchUserData());
        }
      } else {
        if (context.mounted) _showError(context, "Lỗi server: ${response.statusCode}");
      }
    } catch (e) {
      if (context.mounted) { Navigator.pop(context); _showError(context, "Lỗi kết nối: $e"); }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    // MÀU SẮC CHUẨN THEO THIẾT KẾ LUMINA AI
    final Color bgColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF0F7F4);
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B2A22);
    final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color inputBgColor = isDarkMode ? Colors.grey[800]! : const Color(0xFFF4F8F5);
    const Color primaryGreen = Color(0xFF0F8A50);

    return Scaffold(
      backgroundColor: bgColor,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // --- TAB 0: HOME (GIAO DIỆN LUMINA AI) ---
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. APP BAR
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: isDarkMode ? Colors.grey[700] : const Color(0xFF1B2A22),
                              radius: 18,
                              child: const Icon(Icons.person, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text('AI Learning App', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textColor)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 2. KHỐI TRANSLATE
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor, borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: isDarkMode ? Colors.black54 : Colors.grey.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      children: [
                        // Đổi ngôn ngữ
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(sourceLangName, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: primaryGreen, fontSize: 15))),
                            IconButton(icon: const Icon(Icons.swap_horiz, color: primaryGreen), onPressed: _swapLanguage),
                            Expanded(child: Text(targetLangName, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 15))),
                          ],
                        ),
                        Divider(height: 20, color: isDarkMode ? Colors.grey[700] : Colors.grey[200]),

                        // Khung nhập văn bản
                        Container(
                          decoration: BoxDecoration(color: inputBgColor, borderRadius: BorderRadius.circular(15)),
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              TextField(
                                controller: _inputController,
                                maxLines: 3,
                                onChanged: _onInputTextChanged, // Gọi hàm dịch khi gõ
                                style: TextStyle(color: textColor, fontSize: 16),
                                decoration: InputDecoration(hintText: "Enter text to translate...", hintStyle: TextStyle(color: Colors.grey[400]), border: InputBorder.none),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(icon: Icon(Icons.camera_alt_outlined, color: Colors.grey[600], size: 20), onPressed: () => _showImageSourceActionSheet(context)),
                                  IconButton(icon: Icon(Icons.mic_none, color: Colors.grey[600], size: 20), onPressed: () {}),
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Khung hiển thị kết quả
                        Container(
                          decoration: BoxDecoration(color: inputBgColor, borderRadius: BorderRadius.circular(15)),
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                controller: _outputController,
                                maxLines: 3,
                                readOnly: true,
                                style: TextStyle(fontStyle: FontStyle.italic, color: textColor, fontSize: 16),
                                decoration: InputDecoration(hintText: "Translation will appear here...", hintStyle: TextStyle(color: Colors.grey[400], fontStyle: FontStyle.italic), border: InputBorder.none),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(icon: Icon(Icons.camera_alt_outlined, color: Colors.grey[600], size: 20), onPressed: () {}),
                                  IconButton(icon: Icon(Icons.copy, color: Colors.grey[600], size: 20), onPressed: () {}),
                                  IconButton(icon: Icon(Icons.volume_up_outlined, color: Colors.grey[600], size: 20), onPressed: () {}),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),

                  // 3. KHỐI STUDY MATERIALS (UPLOAD PDF)
                  Text("Study Materials", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 15),

                  DottedBorder(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                    strokeWidth: 2, dashPattern: const [8, 6],
                    borderType: BorderType.RRect, radius: const Radius.circular(20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        children: [
                          CircleAvatar(radius: 25, backgroundColor: inputBgColor, child: const Icon(Icons.upload_file, size: 25, color: primaryGreen)),
                          const SizedBox(height: 15),
                          Text("Upload PDF Document", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                          const SizedBox(height: 10),
                          Text(
                            "Upload your lecture notes or readings\nto generate smart summaries and\nflashcards.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
                          ),
                          const SizedBox(height: 25),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            ),
                            onPressed: () => pickPDFAndChooseGame(context),
                            child: const Text("Select File", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // --- CÁC TAB CÒN LẠI GIỮ NGUYÊN ---
          MyLessonsScreen(username: widget.username),
          const DiscoverScreen(),
          ProfileScreen(username: widget.username, xp: _xp, streak: _streak),
        ],
      ),

      // --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 15, bottom: 25, left: 10, right: 10),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [BoxShadow(color: isDarkMode ? Colors.black54 : Colors.black12, blurRadius: 10)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_filled, "Home", 0, primaryGreen, isDarkMode),
            _buildNavItem(Icons.menu_book_rounded, "Lessons", 1, primaryGreen, isDarkMode),
            _buildNavItem(Icons.explore, "Discover", 2, primaryGreen, isDarkMode),
            _buildNavItem(Icons.person, "Profile", 3, primaryGreen, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, Color activeColor, bool isDarkMode) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: isActive ? activeColor.withOpacity(0.15) : Colors.transparent, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? activeColor : (isDarkMode ? Colors.grey[500] : Colors.grey[400]), size: 26),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.w600, color: isActive ? activeColor : (isDarkMode ? Colors.grey[500] : Colors.grey[400]))),
          ],
        ),
      ),
    );
  }
}