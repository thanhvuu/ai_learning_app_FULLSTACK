import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vocabulary_model.dart';
import '../models/question_model.dart';
import '../providers/theme_provider.dart';
import 'drag_drop_quiz_screen.dart';
import 'multiple_choice_screen.dart';
import 'fill_blank_screen.dart';

class VocabularyScreen extends StatefulWidget {
  final String topic;
  final List<VocabularyModel> vocabularies;
  final List<QuestionModel> questions;
  final String quizType;

  const VocabularyScreen({
    super.key,
    required this.topic,
    required this.vocabularies,
    required this.questions,
    required this.quizType,
  });

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  int currentIndex = 0;
  final PageController _pageController = PageController();

  void _startQuiz() {
    Widget screen;
    if (widget.quizType == "drag_drop") {
      screen = DragDropQuizScreen(questions: widget.questions);
    } else if (widget.quizType == "multiple_choice") {
      screen = MultipleChoiceScreen(questions: widget.questions);
    } else {
      screen = FillBlankScreen(questions: widget.questions);
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: Text("Vocabulary: ${widget.topic}"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "Hãy học các từ vựng then chốt này trước khi bắt đầu bài kiểm tra thực hành nhé!",
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
    );
  }
}
