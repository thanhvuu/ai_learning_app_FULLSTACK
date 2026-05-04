import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart'; // THÊM IMPORT NÀY

import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:translator/translator.dart';

import '../api_config.dart';
import '../providers/theme_provider.dart';
// import '../providers/quiz_provider.dart'; // Mở lại nếu có dùng
import 'discover_screen.dart';
import '../models/question_model.dart';
import 'drag_drop_quiz_screen.dart';
import 'multiple_choice_screen.dart';
import 'fill_blank_screen.dart';
import 'profile_screen.dart';
import 'my_lessons_screen.dart';
import '../widgets/dictionary_bottom_sheet.dart';
import '../services/dictionary_helper.dart';
import 'vocabulary_garden_screen.dart'; // Thêm dòng này

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
  // BIẾN CHO CHỨC NĂNG DỊCH THUẬT & TÌM KIẾM
  // ==========================================
  final GoogleTranslator _translator = GoogleTranslator();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  Timer? _debounce;

  // --- BIẾN CHO MIC, LOA, CAMERA ---
  final FlutterTts _flutterTts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final ImagePicker _picker = ImagePicker(); // Biến để gọi camera/thư viện ảnh
  bool _isListening = false;

  @override
  void dispose() {
    _textRecognizer.close(); // Giải phóng bộ nhớ camera khi tắt app
    super.dispose();
  }

  String sourceLangName = "TIẾNG ANH";
  String targetLangName = "TIẾNG VIỆT";
  String sourceLangCode = "en";
  String targetLangCode = "vi";

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

  // --- 1. HÀM PHÁT ÂM (LOA) ---
  Future<void> _speakTranslation() async {
    if (_outputController.text.isNotEmpty) {
      // Chỉnh ngôn ngữ đọc theo Tab đích (vi-VN hoặc en-US)
      await _flutterTts.setLanguage(targetLangCode == 'vi' ? 'vi-VN' : 'en-US');
      await _flutterTts.speak(_outputController.text);
    }
  }

  // --- 2. HÀM NHẬN DIỆN GIỌNG NÓI (MIC) ---
  void _listenToSpeech() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          // Chỉnh ngôn ngữ nghe theo Tab nguồn
          localeId: sourceLangCode == 'vi' ? 'vi_VN' : 'en_US',
          onResult: (val) => setState(() {
            _inputController.text = val.recognizedWords;
            _onInputTextChanged(val.recognizedWords); // Gọi dịch tự động
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speechToText.stop();
    }
  }

  // --- 3. HÀM QUÉT CHỮ TỪ ẢNH (CAMERA / THƯ VIỆN) ---
  Future<void> _processImageForText(ImageSource source) async {
    Navigator.pop(context); // Tắt menu sheet đi

    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;

    final inputImage = InputImage.fromFilePath(image.path);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

    setState(() {
      _inputController.text = recognizedText.text;
    });
    _onInputTextChanged(recognizedText.text); // Gọi dịch tự động
  }

  // --- HÀM TÌM KIẾM TỪ ĐIỂN OFFLINE + AI HYBRID ---
  Future<void> _handleSearchSubmit(String text) async {
    String searchWord = text.trim();
    if (searchWord.isEmpty) return;

    try {
      Map<String, dynamic>? wordData = await DictionaryHelper.lookupWordOffline(searchWord);

      if (mounted) {
        if (wordData != null) {
          DictionaryBottomSheet.show(context, wordData, searchWord);
          _searchController.clear();
        } else {
          Map<String, dynamic> emptyData = {
            "word": searchWord,
            "meaning": "Đang nhờ AI phân tích cụm từ này...",
          };
          DictionaryBottomSheet.show(context, emptyData, searchWord);
          _searchController.clear();
        }
      }
    } catch (e) {
      if (mounted) _showError(context, "Lỗi đọc từ điển: $e");
    }
  }

  // --- HÀM ĐẢO NGÔN NGỮ ---
  void _swapLanguage() {
    setState(() {
      String tempName = sourceLangName;
      sourceLangName = targetLangName;
      targetLangName = tempName;

      String tempCode = sourceLangCode;
      sourceLangCode = targetLangCode;
      targetLangCode = tempCode;

      String tempText = _inputController.text;
      _inputController.text = _outputController.text;
      _outputController.text = tempText;
    });
    if (_inputController.text.isNotEmpty) {
      _onInputTextChanged(_inputController.text);
    }
  }

  // --- MENU CHỌN ẢNH (Gắn hàm _processImageForText) ---
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
              onTap: () => _processImageForText(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF0F8A50)),
              title: const Text('Chọn từ thư viện'),
              onTap: () => _processImageForText(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // CÁC HÀM UPLOAD PDF BÀI HỌC CŨ
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
      context: context,
      barrierDismissible: false,
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
      if (context.mounted) {
        Navigator.pop(context);
        _showError(context, "Lỗi kết nối: $e");
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
  }

  // ==========================================
  // XÂY DỰNG GIAO DIỆN
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    final Color bgColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF4F9F4);
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B2A22);
    final Color cardWhite = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    const Color primaryGreen = Color(0xFF0F8A50);

    return Scaffold(
      backgroundColor: bgColor,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // --- TAB 0: HOME ---
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. APP BAR
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0, top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('AI Learning App', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: primaryGreen)),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: const NetworkImage("https://i.pravatar.cc/150?img=11"),
                        ),
                      ],
                    ),
                  ),

                  // 2. Ô TÌM KIẾM (SEARCH BAR)
                  Container(
                    decoration: BoxDecoration(
                      color: cardWhite,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: isDarkMode ? Colors.black26 : Colors.green.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: _handleSearchSubmit,
                      style: TextStyle(color: textColor, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: "Tìm kiếm từ vựng (Anh-Việt, V...",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: const Icon(Icons.search, color: primaryGreen),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 3 & 4. KHỐI TRANSLATE ĐƯỢC GỘP LẠI (Có nút Swap nổi lên ở giữa)
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        children: [
                          _buildTranslationCard(
                            title: sourceLangName,
                            controller: _inputController,
                            hint: "Nhập văn bản cần dịch...",
                            isInput: true,
                            cardColor: cardWhite,
                            textColor: textColor,
                            isDarkMode: isDarkMode,
                            context: context,
                          ),
                          const SizedBox(height: 15),
                          _buildTranslationCard(
                            title: targetLangName,
                            controller: _outputController,
                            hint: "Bản dịch sẽ xuất hiện ở đây...",
                            isInput: false,
                            cardColor: isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFE8F3ED),
                            textColor: textColor,
                            isDarkMode: isDarkMode,
                            context: context,
                          ),
                        ],
                      ),

                      // NÚT ĐẢO CHIỀU NGÔN NGỮ (SWAP) FLOAT Ở GIỮA
                      Container(
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[800] : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode ? Colors.black54 : Colors.green.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: IconButton(
                          onPressed: _swapLanguage,
                          icon: const Icon(Icons.swap_vert, color: primaryGreen, size: 28),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),

                  // 5. TÀI LIỆU HỌC TẬP (STUDY MATERIALS)
                  Text("Tài liệu học tập", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 4),
                  Text("Phân tích tài liệu PDF với AI của bạn", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  const SizedBox(height: 15),

                  GestureDetector(
                    onTap: () => pickPDFAndChooseGame(context),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A7055),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: const Color(0xFF2A7055).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -30,
                            top: -20,
                            child: Icon(Icons.article, size: 180, color: Colors.white.withOpacity(0.1)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(25.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(15)),
                                  child: const Icon(Icons.upload_file, color: Colors.white, size: 28),
                                ),
                                const SizedBox(height: 20),
                                const Text("Upload PDF Document", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 8),
                                Text(
                                  "Tải lên giáo trình hoặc tài liệu để tạo\nbộ thẻ ghi nhớ và bài tập tự động.",
                                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9), height: 1.4),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: const [
                                    Text("Bắt đầu ngay", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),

                  // 6. KHỐI TÍNH NĂNG MỚI: VƯỜN ƯƠM TỪ VỰNG
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFE4EEE8),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: const Color(0xFFBBE5CE), borderRadius: BorderRadius.circular(20)),
                          child: const Text("TÍNH NĂNG MỚI", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF17633D), letterSpacing: 1)),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "Vườn ươm từ vựng\ncủa bạn",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: textColor, height: 1.2),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "Theo dõi sự tiến bộ hàng ngày. Mỗi\ntừ vựng bạn học được sẽ giúp khu\nvườn tri thức của bạn nở rộ hơn.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const VocabularyGardenScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: 0,
                          ),
                          child: const Text("Khám phá ngay", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 25),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            "https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?q=80&w=400&auto=format&fit=crop",
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // --- CÁC TAB CÒN LẠI ---
          MyLessonsScreen(username: widget.username),
          DiscoverScreen(username: widget.username),
          ProfileScreen(username: widget.username, xp: _xp, streak: _streak),
        ],
      ),

      // --- BOTTOM NAVIGATION BAR MỚI ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 10, bottom: 25, left: 15, right: 15),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [BoxShadow(color: isDarkMode ? Colors.black54 : Colors.black12, blurRadius: 15, offset: const Offset(0, -2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, Icons.home_outlined, "Home", 0, primaryGreen, isDarkMode),
            _buildNavItem(Icons.school, Icons.school_outlined, "Lessons", 1, primaryGreen, isDarkMode),
            _buildNavItem(Icons.explore, Icons.explore_outlined, "Discover", 2, primaryGreen, isDarkMode),
            _buildNavItem(Icons.person, Icons.person_outline, "Profile", 3, primaryGreen, isDarkMode),
          ],
        ),
      ),
    );
  }

  // --- HÀM HỖ TRỢ VẼ CARD DỊCH THUẬT (Đã gắn Logic Mic, Loa, Camera) ---
  Widget _buildTranslationCard({
    required String title,
    required TextEditingController controller,
    required String hint,
    required bool isInput,
    required Color cardColor,
    required Color textColor,
    required bool isDarkMode,
    required BuildContext context
  }) {
    const Color primaryGreen = Color(0xFF0F8A50);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isInput ? [BoxShadow(color: isDarkMode ? Colors.black26 : Colors.green.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))] : [],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            bottom: -30,
            child: CircleAvatar(
              radius: 70,
              backgroundColor: primaryGreen.withOpacity(isDarkMode ? 0.05 : 0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryGreen, letterSpacing: 1)),
                    Row(
                      children: isInput
                          ? [
                        // NÚT MIC
                        IconButton(
                            icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : primaryGreen, size: 22),
                            onPressed: _listenToSpeech, constraints: const BoxConstraints(), padding: EdgeInsets.zero
                        ),
                        const SizedBox(width: 15),
                        // NÚT CAMERA
                        IconButton(
                            icon: const Icon(Icons.camera_alt_outlined, color: primaryGreen, size: 22),
                            onPressed: () => _showImageSourceActionSheet(context), constraints: const BoxConstraints(), padding: EdgeInsets.zero
                        ),
                      ]
                          : [
                        // NÚT LOA
                        IconButton(
                            icon: const Icon(Icons.volume_up_outlined, color: primaryGreen, size: 22),
                            onPressed: _speakTranslation, constraints: const BoxConstraints(), padding: EdgeInsets.zero
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controller,
                  maxLines: 4, minLines: 2,
                  readOnly: !isInput,
                  onChanged: isInput ? _onInputTextChanged : null,
                  style: TextStyle(color: textColor, fontSize: 18, fontStyle: isInput ? FontStyle.normal : FontStyle.italic),
                  decoration: InputDecoration(
                    hintText: _isListening ? "Đang nghe..." : hint,
                    hintStyle: TextStyle(color: _isListening ? Colors.red : Colors.grey[500], fontSize: 16, fontStyle: isInput ? FontStyle.normal : FontStyle.italic),
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- HÀM VẼ BOTTOM NAV ---
  Widget _buildNavItem(IconData activeIcon, IconData inactiveIcon, String label, int index, Color activeColor, bool isDarkMode) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            color: isActive ? const Color(0xFFD3EFE0) : Colors.transparent,
            borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : inactiveIcon, color: isActive ? activeColor : (isDarkMode ? Colors.grey[500] : Colors.grey[600]), size: 26),
            if (isActive) const SizedBox(height: 4),
            if (isActive) Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: activeColor)),
          ],
        ),
      ),
    );
  }
}