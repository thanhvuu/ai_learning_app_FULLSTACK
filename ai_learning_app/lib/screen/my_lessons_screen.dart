import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../l10n/app_localizations.dart';
import '../models/vocabulary_model.dart';
import '../models/question_model.dart';
import 'vocabulary_screen.dart';

class MyLessonsScreen extends StatefulWidget {
  // Thêm biến username để biết lấy bài học của ai
  final String username;
  const MyLessonsScreen({super.key, required this.username});

  @override
  State<MyLessonsScreen> createState() => _MyLessonsScreenState();
}

class _MyLessonsScreenState extends State<MyLessonsScreen> {
  List<Map<String, dynamic>> activeCourses = [];
  bool isLoading = true; // Biến trạng thái loading
  int minutesLearned = 0;
  int dailyGoal = 45;
  int streakCount = 0;

  @override
  void initState() {
    super.initState();
    fetchMyLessons(); // Gọi API ngay khi mở màn hình
    fetchProgress();
  }

  // --- HÀM GỌI API LẤY DANH SÁCH BÀI HỌC TỪ SPRING BOOT ---
  Future<void> fetchMyLessons() async {
    // Sửa lại URL này theo đúng API backend của bạn nhé
    final String url = "${ApiConfig.lessons}/my-lessons?username=${widget.username}";

    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

        setState(() {
          // Map dữ liệu từ Backend về đúng chuẩn của giao diện
          activeCourses = data.map((item) {
            String type = item['quizType'] ?? 'unknown';

            // Parse vocabularies và questions từ JSON backend
            List<dynamic> vocabJson = item['vocabularies'] ?? [];
            List<dynamic> questionsJson = item['questions'] ?? [];

            return {
              "title": item['title'] ?? "Bài học mới",
              "subtitle": _getSubtitleForType(type),
              "progress": (item['progress'] ?? 0) / 100.0,
              "isCompleted": item['progress'] == 100,
              "gradient": _getGradientForType(type),
              "icon": _getIconForType(type),
              "quizType": type,
              "vocabularies": vocabJson.map((v) => VocabularyModel.fromJson(v)).toList(),
              "questions": questionsJson.map((q) => QuestionModel.fromJson(q)).toList(),
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        print("Lỗi server: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Lỗi kết nối: $e");

      // Nếu lỗi API (do chưa code Backend), tạm thời nạp lại dữ liệu giả để bạn test giao diện
      _loadDummyData();
    }
  }

  //ham call api lay progress
   Future<void> fetchProgress() async{
    final String url = "${ApiConfig.progress}/today?username=${widget.username}";
    try{
      var response = await http.get(Uri.parse(url));
      if(response.statusCode == 200){
        var data = jsonDecode(utf8.decode(response.bodyBytes));
        if(mounted){
          setState(() {
            minutesLearned = data['minutesLearned'] ?? 0;
            dailyGoal = data['dailyGoal'] ?? 45;
            streakCount = data['streakCount'] ?? 0;
          });
        }
      }
    }catch(e){
      print("Lỗi kết nối: $e");
    }
   }


  // --- CÁC HÀM HỖ TRỢ LÀM ĐẸP GIAO DIỆN DỰA VÀO LOẠI BÀI HỌC ---
  String _getSubtitleForType(String type) {
    final t = AppLocalizations(LanguageProvider.safeOf(context, listen: false).languageCode);
    if (type == 'drag_drop') return t.translate('drag_drop_type');
    if (type == 'multiple_choice') return t.translate('multiple_choice_type');
    if (type == 'fill_blank') return t.translate('fill_blank_type');
    return t.translate('study_material_type');
  }

  List<Color> _getGradientForType(String type) {
    if (type == 'drag_drop') return const [Color(0xFF2E86C1), Color(0xFF85C1E9)]; // Xanh biển
    if (type == 'multiple_choice') return const [Color(0xFF935116), Color(0xFFE59866)]; // Cam gỗ
    if (type == 'fill_blank') return const [Color(0xFF17202A), Color(0xFF5D6D7E)]; // Xám công nghệ
    return const [Color(0xFF6A4CFF), Color(0xFFB39DDB)]; // Tím mặc định
  }

  IconData _getIconForType(String type) {
    if (type == 'drag_drop') return Icons.drag_indicator;
    if (type == 'multiple_choice') return Icons.list_alt;
    if (type == 'fill_blank') return Icons.keyboard;
    return Icons.menu_book;
  }

  void _loadDummyData() {
    setState(() {
      activeCourses = [
        {"title": "Business English", "subtitle": "Mẫu (Đang lỗi API)", "progress": 0.75, "isCompleted": false, "gradient": const [Color(0xFF2E86C1), Color(0xFF85C1E9)], "icon": Icons.business_center},
        {"title": "IT Vocabulary", "subtitle": "Mẫu (Đang lỗi API)", "progress": 0.40, "isCompleted": false, "gradient": const [Color(0xFF17202A), Color(0xFF5D6D7E)], "icon": Icons.memory},
      ];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final langProvider = LanguageProvider.safeOf(context);
    final t = AppLocalizations(langProvider.languageCode);
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B2A22);
    final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color subtitleColor = isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;
    const Color greenAccent = Color(0xFF0F8A50);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,

        title: Text(t.translate('my_lessons'), style: const TextStyle(fontWeight: FontWeight.bold, color: greenAccent, fontSize: 20)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: CircleAvatar(radius: 18, backgroundColor: isDarkMode ? Colors.grey[800] : Colors.blue[100], child: const Icon(Icons.person, color: Colors.white)),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: greenAccent))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDailyGoalCard(cardColor, textColor, greenAccent, isDarkMode),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t.translate('active_courses'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                TextButton(onPressed: () {}, child: Text(t.translate('view_all'), style: const TextStyle(color: greenAccent, fontWeight: FontWeight.bold, fontSize: 14)))
              ],
            ),
            const SizedBox(height: 10),

            if (activeCourses.isEmpty)
              Center(child: Padding(padding: const EdgeInsets.all(20.0), child: Text(t.translate('no_lessons'), style: TextStyle(color: subtitleColor)))),

            ...activeCourses.map((course) => _buildCourseCard(course, cardColor, textColor, subtitleColor, greenAccent, isDarkMode)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- CÁC HÀM BUILD WIDGET (GIỮ NGUYÊN NHƯ CŨ) ---
  Widget _buildDailyGoalCard(Color cardColor, Color textColor, Color greenAccent, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: isDarkMode ? Colors.black54 : Colors.grey.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.of(context, 'daily_goal'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic,
                children: [
                  Text("$minutesLearned", style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: greenAccent)),
                  Text("/${dailyGoal} min", style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.grey[400] : Colors.grey[600], fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: isDarkMode ? Colors.deepPurple.withOpacity(0.2) : const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(15)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 16, color: isDarkMode ? Colors.deepPurpleAccent : Colors.deepPurple),
                    const SizedBox(width: 5),
                    Text("$streakCount ${S.of(context, 'day_streak')}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDarkMode ? Colors.deepPurpleAccent : Colors.deepPurple)),
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            width: 90, height: 90,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(value: minutesLearned / dailyGoal, strokeWidth: 10, backgroundColor: isDarkMode ? Colors.grey[800] : const Color(0xFFE8F6EF), valueColor: AlwaysStoppedAnimation<Color>(greenAccent), strokeCap: StrokeCap.round),
                Center(child: Text("${((minutesLearned / dailyGoal) * 100).toInt()}%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: textColor))),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course, Color cardColor, Color textColor, Color subtitleColor, Color greenAccent, bool isDarkMode) {
    bool isCompleted = course['isCompleted'];
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => VocabularyScreen(
            topic: course['title'],
            vocabularies: List<VocabularyModel>.from(course['vocabularies']),
            questions: List<QuestionModel>.from(course['questions']),
            quizType: course['quizType'],
          ),
        ));
      },
      borderRadius: BorderRadius.circular(25),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20), padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: isDarkMode ? Colors.black54 : Colors.grey.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))]),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 65, height: 65,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: course['gradient'])),
                  child: Icon(course['icon'], color: Colors.white.withOpacity(0.8), size: 30),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
                      const SizedBox(height: 5),
                      Text(course['subtitle'], style: TextStyle(color: subtitleColor, fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Container(
                  width: 45, height: 45,
                  decoration: BoxDecoration(color: greenAccent, shape: BoxShape.circle, boxShadow: [BoxShadow(color: greenAccent.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]),
                  child: Icon(isCompleted ? Icons.check : Icons.play_arrow_rounded, color: Colors.white, size: 28),
                )
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(S.of(context, 'progress'), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: textColor)),
                Text("${(course['progress'] * 100).toInt()}%", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: greenAccent)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: course['progress'], minHeight: 8, backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200], valueColor: AlwaysStoppedAnimation<Color>(greenAccent), borderRadius: BorderRadius.circular(10)),
          ],
        ),
      ),
    );
  }
}