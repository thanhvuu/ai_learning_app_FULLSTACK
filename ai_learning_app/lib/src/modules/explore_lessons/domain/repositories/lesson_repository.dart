import 'package:ai_learning_app/src/core/domain/result.dart';

abstract class LessonRepository {
  Future<Result<List<dynamic>>> fetchRoadmap(String major);

  Future<Result<Map<String, dynamic>>> generateLessonByTopic({
    required String topic,
    required String username,
    required String major,
    required String quizType,
  });

  Future<Result<List<Map<String, dynamic>>>> fetchMyLessons(String username);

  Future<Result<void>> updateMajor({
    required String username,
    required String major,
  });
}
