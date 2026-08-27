import 'package:ai_learning_app/src/core/domain/result.dart';

abstract class LessonRepository {
  Future<Result<List<Map<String, dynamic>>>> fetchMyLessons(String username);

  Future<Result<Map<String, dynamic>>> generateLessonByTopic({
    required String topic,
    required String username,
    required String quizType,
    String? category,
  });
}
