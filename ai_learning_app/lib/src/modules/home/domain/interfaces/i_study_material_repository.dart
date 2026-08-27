import 'dart:io';
import 'package:ai_learning_app/src/core/domain/result.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/data/models/question_model.dart';

class GeneratedLessonResult {
  final int lessonId;
  final List<QuestionModel> questions;
  final String quizType;

  const GeneratedLessonResult({
    required this.lessonId,
    required this.questions,
    required this.quizType,
  });
}

abstract class IStudyMaterialRepository {
  Future<Result<GeneratedLessonResult>> uploadAndGenerateLesson({
    required File file,
    required String quizType,
    required String username,
  });
}
