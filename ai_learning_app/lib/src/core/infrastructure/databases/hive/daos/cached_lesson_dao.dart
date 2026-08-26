import 'package:ai_learning_app/src/core/domain/entities/cached_lesson_entity.dart';
import '../base_dao.dart';
import '../database_service.dart';

class CachedLessonDao extends BaseDao<CachedLessonEntity> {
  CachedLessonDao() : super(DatabaseService.cachedLessonsBox);

  Future<List<CachedLessonEntity>> getLessonsByMajor(String major) async {
    return getAll(filter: (lesson) => lesson.major.toLowerCase() == major.toLowerCase());
  }

  Future<CachedLessonEntity?> getLessonByTopic(String topic) async {
    final list = await getAll(
      filter: (lesson) => lesson.topic.toLowerCase() == topic.toLowerCase(),
    );
    return list.isNotEmpty ? list.first : null;
  }

  Future<void> updateLessonProgress({
    required String lessonId,
    required double progress,
    required bool isCompleted,
  }) async {
    final existing = await getById(lessonId);
    if (existing != null) {
      await update(
        existing.copyWith(
          progress: progress,
          isCompleted: isCompleted,
        ),
      );
    }
  }
}
