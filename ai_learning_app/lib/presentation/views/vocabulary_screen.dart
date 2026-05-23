import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_learning_app/data/models/vocabulary_model.dart';
import 'package:ai_learning_app/data/models/question_model.dart';
import 'package:ai_learning_app/presentation/view_models/theme_view_model.dart';
import 'drag_drop_quiz_screen.dart';
import 'multiple_choice_screen.dart';
import 'fill_blank_screen.dart';

class VocabularyScreen extends StatefulWidget {
  final int lessonId;
  final String topic;
  final String content;
  final List<VocabularyModel> vocabularies;
  final List<QuestionModel> questions;
  final String quizType;

  const VocabularyScreen({
    super.key,
    required this.lessonId,
    required this.topic,
    required this.content,
    required this.vocabularies,
    required this.questions,
    required this.quizType,
  });

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  final PageController _pageController = PageController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _startQuiz() {
    Widget screen;
    if (widget.quizType == "drag_drop") {
      screen = DragDropQuizScreen(lessonId: widget.lessonId, questions: widget.questions);
    } else if (widget.quizType == "multiple_choice") {
      screen = MultipleChoiceScreen(lessonId: widget.lessonId, questions: widget.questions);
    } else {
      screen = FillBlankScreen(lessonId: widget.lessonId, questions: widget.questions);
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color bgColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF4F9F4);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(widget.topic),
        centerTitle: true,
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.green,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.menu_book), text: "BÀI ĐỌC"),
            Tab(icon: Icon(Icons.style), text: "TỪ VỰNG"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: BÀI ĐỌC (READING PASSAGE)
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.orange, size: 30),
                      const SizedBox(height: 15),
                      Text(
                        widget.content.isNotEmpty ? widget.content : "Đang tải nội dung...",
                        style: TextStyle(fontSize: 18, height: 1.8, color: textColor, letterSpacing: 0.5),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _tabController.animateTo(1),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text("HỌC TỪ VỰNG"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),

          // TAB 2: TỪ VỰNG (VOCABULARY)
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "Hãy học các từ vựng then chốt này trước khi bắt đầu bài thực hành nhé!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.vocabularies.length,
                  onPageChanged: (index) => setState(() => currentIndex = index),
                  itemBuilder: (context, index) {
                    final vocab = widget.vocabularies[index];
                    return Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                vocab.word,
                                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                vocab.phonetic,
                                style: TextStyle(fontSize: 18, color: Colors.blueGrey[400], fontStyle: FontStyle.italic),
                              ),
                              const Divider(height: 50),
                              Text(
                                "Ý nghĩa:",
                                style: TextStyle(fontSize: 14, color: Colors.grey[500], fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                vocab.meaning,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 22, color: textColor, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 30),
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(Icons.lightbulb_outline, color: Colors.orange),
                                    const SizedBox(height: 10),
                                    Text(
                                      vocab.example,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 15, height: 1.5, color: isDarkMode ? Colors.greenAccent : Colors.green[800]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${currentIndex + 1}/${widget.vocabularies.length}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ElevatedButton(
                      onPressed: currentIndex == widget.vocabularies.length - 1 ? _startQuiz : () {
                        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text(
                        currentIndex == widget.vocabularies.length - 1 ? "THỰC HÀNH NGAY" : "TỪ TIẾP THEO",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}
