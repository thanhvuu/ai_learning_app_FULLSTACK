import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_learning_app/src/common/constants/api_constants.dart';
import 'package:ai_learning_app/src/common/theme/color_manager.dart';
import 'package:ai_learning_app/src/core/infrastructure/network/http_compat.dart' as http;
import 'package:ai_learning_app/src/modules/app/router/app_router.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/data/models/question_model.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/data/models/vocabulary_model.dart';

class RoadmapScreen extends StatefulWidget {
  final String major;
  final String username;

  const RoadmapScreen({super.key, required this.major, required this.username});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  List<dynamic> steps = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRoadmap();
  }

  Future<void> fetchRoadmap() async {
    try {
      const String path = "/api/lessons/roadmap";
      final String fullUrl =
          "${ApiConstants.baseUrl}$path?major=${Uri.encodeComponent(widget.major)}";

      var response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode == 200) {
        var data = jsonDecode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            steps = data['steps'] ?? [];
            isLoading = false;
          });
        }
      } else {
        _handleFetchError("Lỗi server (${response.statusCode})");
      }
    } catch (e) {
      _handleFetchError("Lỗi kết nối: Hãy kiểm tra IP Backend của bạn");
      debugPrint("Roadmap Error: $e");
    }
  }

  void _handleFetchError(String message) {
    if (mounted) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
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
                CircularProgressIndicator(color: ColorManager.primaryGreen),
                SizedBox(height: 15),
                Text(
                  "AI đang soạn bài học riêng cho bạn...",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.lessons}/generate-by-topic"),
        body: {
          "topic": topic,
          "username": widget.username,
          "category": widget.major,
          "quizType": "multiple_choice",
        },
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (response.statusCode == 200) {
        var jsonResult = jsonDecode(utf8.decode(response.bodyBytes));
        int lessonId = jsonResult['id'] ?? 0;
        String lessonContent = jsonResult['content'] ?? "";
        List<dynamic> vocabJson = jsonResult['vocabularies'] ?? [];
        List<dynamic> questionsJson = jsonResult['questions'] ?? [];

        List<VocabularyModel> vocabs = vocabJson
            .map((v) => VocabularyModel.fromJson(v))
            .toList();
        List<QuestionModel> questions = questionsJson
            .map((q) => QuestionModel.fromJson(q))
            .toList();

        context.push(
          AppRoutes.vocabulary,
          extra: {
            'lessonId': lessonId,
            'topic': topic,
            'content': lessonContent,
            'vocabularies': vocabs,
            'questions': questions,
            'quizType': 'multiple_choice',
          },
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lộ trình: ${widget.major}"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard_rounded),
            onPressed: () {
              context.go(
                AppRoutes.main,
                extra: {
                  'username': widget.username,
                  'major': widget.major,
                },
              );
            },
            tooltip: "Vào Trang chủ",
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 40),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                double offset = 40.0 * math.sin(index * 1.0);

                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => _startLesson(steps[index]),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ColorManager.primaryGreen,
                            boxShadow: [
                              BoxShadow(
                                color: ColorManager.primaryGreen.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "${index + 1}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 140,
                        child: Text(
                          steps[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (index < steps.length - 1) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: 4,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}
