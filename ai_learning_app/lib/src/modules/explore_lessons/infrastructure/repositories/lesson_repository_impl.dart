import 'package:injectable/injectable.dart';
import 'package:ai_learning_app/src/common/utils/service_locator.dart';
import 'package:ai_learning_app/src/core/domain/app_exception.dart';
import 'package:ai_learning_app/src/core/domain/entities/cached_lesson_entity.dart';
import 'package:ai_learning_app/src/core/domain/result.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/cached_lesson_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/network/api_client.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/domain/repositories/lesson_repository.dart';

@LazySingleton(as: LessonRepository)
class LessonRepositoryImpl implements LessonRepository {
  final CachedLessonDao _lessonDao;
  final ApiClient _apiClient;

  LessonRepositoryImpl({
    required CachedLessonDao lessonDao,
    ApiClient? apiClient,
  })  : _lessonDao = lessonDao,
        _apiClient = apiClient ?? ServiceLocator.apiClient;

  @override
  Future<Result<List<Map<String, dynamic>>>> fetchMyLessons(String username) async {
    try {
      final result = await _apiClient.getList(
        '/api/lessons/user',
        queryParameters: {'username': username},
      );

      return await result.when(
        success: (list) async {
          final lessons = list.map((e) => e as Map<String, dynamic>).toList();
          return Result.success(lessons);
        },
        failure: (err) async {
          // Fallback to local cached lessons if offline
          final cached = await _lessonDao.getAll();
          if (cached.isNotEmpty) {
            final list = cached.map((c) => c.toJson()).toList();
            return Result.success(list);
          }
          return Result.failure(err);
        },
      );
    } catch (e) {
      // Offline fallback
      final cached = await _lessonDao.getAll();
      if (cached.isNotEmpty) {
        final list = cached.map((c) => c.toJson()).toList();
        return Result.success(list);
      }
      return Result.failure(AppException.network('Lỗi kết nối: $e'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> generateLessonByTopic({
    required String topic,
    required String username,
    required String quizType,
    String? category,
  }) async {
    try {
      final result = await _apiClient.post(
        '/api/lessons/generate-by-topic',
        data: {
          "topic": topic,
          "username": username,
          "category": category ?? "General",
          "quizType": quizType,
        },
      );

      return await result.when(
        success: (data) async {
          if (data is Map) {
            final jsonResult = Map<String, dynamic>.from(data);
            final lessonId = jsonResult['id'] ?? 0;
            await _lessonDao.insertOne(
              CachedLessonEntity(
                id: '$lessonId',
                topic: topic,
                major: category ?? "General",
                content: jsonResult['content']?.toString() ?? '',
                quizType: quizType,
                vocabularies: ((jsonResult['vocabularies'] as List<dynamic>?) ?? [])
                    .cast<Map<dynamic, dynamic>>(),
                questions: ((jsonResult['questions'] as List<dynamic>?) ?? [])
                    .cast<Map<dynamic, dynamic>>(),
                createdAt: DateTime.now().millisecondsSinceEpoch,
              ),
            );
            return Result.success(jsonResult);
          }
          return const Result.failure(
            DataParsingException('Dữ liệu bài học không đúng định dạng'),
          );
        },
        failure: (err) async => Result.failure(err),
      );
    } catch (e) {
      return Result.failure(AppException.network('Lỗi kết nối: $e'));
    }
  }

  @override
  Future<int> getCachedLessonCount() async {
    try {
      final cached = await _lessonDao.getAll();
      return cached.length;
    } catch (_) {
      return 0;
    }
  }
}
