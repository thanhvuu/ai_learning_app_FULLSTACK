import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:ai_learning_app/src/core/domain/app_exception.dart';
import 'package:ai_learning_app/src/core/domain/result.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/cached_lesson_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/sync_queue_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/network/api_client.dart';
import 'package:ai_learning_app/src/core/infrastructure/repositories/dictionary_repository_impl.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/domain/repositories/quiz_repository.dart';

@LazySingleton(as: QuizRepository)
class QuizRepositoryImpl implements QuizRepository {
  final ApiClient _apiClient;
  final CachedLessonDao _cachedLessonDao;
  final SyncQueueDao _syncQueueDao;
  final IDictionaryService _dictionaryService;

  QuizRepositoryImpl({
    required ApiClient apiClient,
    required CachedLessonDao cachedLessonDao,
    required SyncQueueDao syncQueueDao,
    required IDictionaryService dictionaryService,
  })  : _apiClient = apiClient,
        _cachedLessonDao = cachedLessonDao,
        _syncQueueDao = syncQueueDao,
        _dictionaryService = dictionaryService;

  @override
  Future<Result<Map<String, dynamic>>> completeQuizProgress({
    required String username,
  }) async {
    try {
      final result = await _apiClient.put(
        '/api/users/update-progress',
        queryParameters: {'username': username},
      );

      return await result.when(
        success: (data) async {
          if (data is Map<String, dynamic>) {
            return Result.success(data);
          } else if (data is Map) {
            return Result.success(Map<String, dynamic>.from(data));
          }
          return const Result.success({});
        },
        failure: (err) async {
          debugPrint('[QuizRepository] completeQuizProgress failed, enqueuing to syncQueue: ${err.message}');
          await _syncQueueDao.enqueueAction(
            actionType: 'UPDATE_PROGRESS',
            payload: {'username': username},
          );
          return Result.failure(err);
        },
      );
    } catch (e) {
      debugPrint('[QuizRepository] completeQuizProgress exception, enqueuing to syncQueue: $e');
      await _syncQueueDao.enqueueAction(
        actionType: 'UPDATE_PROGRESS',
        payload: {'username': username},
      );
      return Result.failure(AppException.network('Lỗi cập nhật tiến độ: $e'));
    }
  }

  @override
  Future<Result<void>> updateLessonProgress({
    required dynamic lessonId,
    required double progress,
    required bool isCompleted,
  }) async {
    // 1. Cập nhật offline cache trước
    try {
      await _cachedLessonDao.updateLessonProgress(
        lessonId: lessonId,
        progress: progress,
        isCompleted: isCompleted,
      );
    } catch (e) {
      debugPrint('[QuizRepository] Error updating cached lesson: $e');
    }

    // 2. Gửi lên máy chủ
    final int progressPercent = (progress * 100).toInt();
    try {
      final result = await _apiClient.post(
        '/api/lessons/update-progress',
        data: {"lessonId": lessonId, "progress": progressPercent},
      );

      return await result.when(
        success: (_) async => const Result.success(null),
        failure: (err) async {
          debugPrint('[QuizRepository] updateLessonProgress failed, enqueuing: ${err.message}');
          await _syncQueueDao.enqueueAction(
            actionType: 'UPDATE_LESSON_PROGRESS',
            payload: {"lessonId": lessonId, "progress": progressPercent},
          );
          return Result.failure(err);
        },
      );
    } catch (e) {
      debugPrint('[QuizRepository] updateLessonProgress exception, enqueuing: $e');
      await _syncQueueDao.enqueueAction(
        actionType: 'UPDATE_LESSON_PROGRESS',
        payload: {"lessonId": lessonId, "progress": progressPercent},
      );
      return Result.failure(AppException.network('Lỗi cập nhật tiến độ bài học: $e'));
    }
  }

  @override
  Future<Result<void>> addStudyTime({
    required String username,
    required int minutes,
  }) async {
    try {
      final result = await _apiClient.post(
        '/api/progress/add-time',
        data: {"username": username, "minutes": minutes},
      );

      return await result.when(
        success: (_) async => const Result.success(null),
        failure: (err) async {
          debugPrint('[QuizRepository] addStudyTime failed, enqueuing: ${err.message}');
          await _syncQueueDao.enqueueAction(
            actionType: 'ADD_TIME',
            payload: {"username": username, "minutes": minutes},
          );
          return Result.failure(err);
        },
      );
    } catch (e) {
      debugPrint('[QuizRepository] addStudyTime exception, enqueuing: $e');
      await _syncQueueDao.enqueueAction(
        actionType: 'ADD_TIME',
        payload: {"username": username, "minutes": minutes},
      );
      return Result.failure(AppException.network('Lỗi cộng thời gian học: $e'));
    }
  }

  @override
  Future<Result<void>> updateWateredPlants({
    required String username,
    required int plants,
  }) async {
    if (plants <= 0) return const Result.success(null);

    try {
      final result = await _apiClient.post(
        '/api/users/update-plants',
        queryParameters: {'username': username, 'plants': plants},
      );

      return await result.when(
        success: (_) async => const Result.success(null),
        failure: (err) async {
          debugPrint('[QuizRepository] updateWateredPlants failed, enqueuing: ${err.message}');
          await _syncQueueDao.enqueueAction(
            actionType: 'UPDATE_PLANTS',
            payload: {'username': username, 'plants': plants},
          );
          return Result.failure(err);
        },
      );
    } catch (e) {
      debugPrint('[QuizRepository] updateWateredPlants exception, enqueuing: $e');
      await _syncQueueDao.enqueueAction(
        actionType: 'UPDATE_PLANTS',
        payload: {'username': username, 'plants': plants},
      );
      return Result.failure(AppException.network('Lỗi cập nhật số cây tưới: $e'));
    }
  }

  @override
  Future<Result<void>> updateWordReviewProgress({
    required String word,
    required int currentLevel,
    required bool isRemembered,
  }) async {
    try {
      await _dictionaryService.updateWordProgress(
        word,
        currentLevel,
        isRemembered,
      );
      return const Result.success(null);
    } catch (e) {
      return Result.failure(AppException('Lỗi cập nhật tiến trình từ vựng: $e'));
    }
  }
}
