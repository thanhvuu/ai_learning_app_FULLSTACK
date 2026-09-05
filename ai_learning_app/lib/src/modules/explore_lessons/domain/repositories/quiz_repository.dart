import 'package:ai_learning_app/src/core/domain/result.dart';

abstract class QuizRepository {
  /// Complete quiz and update XP / streak for the user
  Future<Result<Map<String, dynamic>>> completeQuizProgress({
    required String username,
  });

  /// Update lesson completion and progress percentage
  Future<Result<void>> updateLessonProgress({
    required dynamic lessonId,
    required double progress,
    required bool isCompleted,
  });

  /// Add study time in minutes
  Future<Result<void>> addStudyTime({
    required String username,
    required int minutes,
  });

  /// Push watered plants count to server (Flashcard vocabulary garden)
  Future<Result<void>> updateWateredPlants({
    required String username,
    required int plants,
  });

  /// Update spaced repetition word level in local dictionary
  Future<Result<void>> updateWordReviewProgress({
    required String word,
    required int currentLevel,
    required bool isRemembered,
  });
}
