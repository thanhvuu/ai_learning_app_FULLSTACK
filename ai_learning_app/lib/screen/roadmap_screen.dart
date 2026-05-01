import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import '../api_config.dart';
import '../models/question_model.dart';
import '../models/vocabulary_model.dart';
import 'vocabulary_screen.dart';

class RoadmapScreen extends StatefulWidget {
  final String major;
  final String username;

  const RoadmapScreen({super.key, required this.major, required this.username});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  List<String> steps = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRoadmap();
  }

  Future<void> fetchRoadmap() async {
    try {
      final response = await http.get(Uri.parse("${ApiConfig.lessons}/roadmap?major=${widget.major}"));
      if (response.statusCode == 200) {
        setState(() {
          steps = List<String>.from(jsonDecode(utf8.decode(response.bodyBytes)));
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching roadmap: $e");
    }
  }

  Future<void> _startLesson(String topic) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.green),
                SizedBox(height: 15),
                Text("AI đang thiết kế bài giảng...", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.lessons}/generate-by-topic"),
        body: {
          "topic": topic,
          "username": widget.username,
          "category": widget.major,
          "quizType": "multiple_choice",
        },
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      if (response.statusCode == 200) {
        var jsonResult = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> vocabJson = jsonResult['vocabularies'] ?? [];
        List<dynamic> questionsJson = jsonResult['questions'] ?? [];

        List<VocabularyModel> vocabs = vocabJson.map((v) => VocabularyModel.fromJson(v)).toList();
        List<QuestionModel> questions = questionsJson.map((q) => QuestionModel.fromJson(q)).toList();

        Navigator.push(context, MaterialPageRoute(
          builder: (_) => VocabularyScreen(
            topic: topic,
            vocabularies: vocabs,
            questions: questions,
            quizType: "multiple_choice",
          ),
        ));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lộ trình: ${widget.major}"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 40),
        itemCount: steps.length,
        itemBuilder: (context, index) {
          // Tạo hiệu ứng Zig-zag như Duolingo
          double offset = 40.0 * math.sin(index * 1.0);
          
          return Padding(
            padding: EdgeInsets.only(left: 50 + offset, right: 50 - offset, bottom: 30),
            child: _buildStepNode(steps[index], index + 1),
          );
        },
      ),
    );
  }

  Widget _buildStepNode(String title, int stepNumber) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _startLesson(title),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))
              ],
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: Center(
              child: Text(
                "$stepNumber",
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}
