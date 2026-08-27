import 'dart:convert';
import 'package:ai_learning_app/src/common/constants/api_constants.dart';
import 'package:ai_learning_app/src/core/domain/app_exception.dart';
import 'package:ai_learning_app/src/core/domain/entities/cached_lesson_entity.dart';
import 'package:ai_learning_app/src/core/domain/result.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/cached_lesson_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/network/http_compat.dart' as http;
import 'package:ai_learning_app/src/modules/explore_lessons/domain/repositories/lesson_repository.dart';

class LessonRepositoryImpl implements LessonRepository {
  final CachedLessonDao _lessonDao;

  LessonRepositoryImpl({required CachedLessonDao lessonDao})
      : _lessonDao = lessonDao;

  @override
  Future<Result<List<dynamic>>> fetchRoadmap(String major) async {
    try {
      const String path = "/api/lessons/roadmap";
      final String fullUrl =
          "${ApiConstants.baseUrl}$path?major=${Uri.encodeComponent(major)}";

      var response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode == 200) {
        var data = jsonDecode(utf8.decode(response.bodyBytes));
        return Result.success((data['steps'] as List<dynamic>?) ?? []);
      } else {
        return Result.failure(
          AppException.server(
            'Lỗi server (${response.statusCode})',
            statusCode: response.statusCode,
          ),
        );
      }
    } catch (e) {
      return Result.failure(AppException.network('Lỗi kết nối: $e'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> generateLessonByTopic({
    required String topic,
    required String username,
    required String major,
    required String quizType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.lessons}/generate-by-topic"),
        body: {
          "topic": topic,
          "username": username,
          "category": major,
          "quizType": quizType,
        },
      );

      if (response.statusCode == 200) {
        var jsonResult = jsonDecode(utf8.decode(response.bodyBytes));

        // Cache into Hive
        final lessonId = jsonResult['id'] ?? 0;
        await _lessonDao.insertOne(
          CachedLessonEntity(
            id: '$lessonId',
            topic: topic,
            major: major,
            content: jsonResult['content'] ?? '',
            quizType: quizType,
            vocabularies: ((jsonResult['vocabularies'] as List<dynamic>?) ?? [])
                .cast<Map<dynamic, dynamic>>(),
            questions: ((jsonResult['questions'] as List<dynamic>?) ?? [])
                .cast<Map<dynamic, dynamic>>(),
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );

        return Result.success(jsonResult as Map<String, dynamic>);
      } else {
        return Result.failure(
          AppException.server(
            'Lỗi server: ${response.statusCode}',
            statusCode: response.statusCode,
          ),
        );
      }
    } catch (e) {
      return Result.failure(AppException.network('Lỗi kết nối: $e'));
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> fetchMyLessons(String username) async {
    try {
      final String fullUrl =
          "${ApiConstants.lessons}/user?username=${Uri.encodeComponent(username)}";
      var response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        final lessons = jsonList.map((e) => e as Map<String, dynamic>).toList();
        return Result.success(lessons);
      } else {
        // Fallback to local cached lessons if offline
        final cached = await _lessonDao.getAll();
        if (cached.isNotEmpty) {
          final list = cached.map((c) => c.toJson()).toList();
          return Result.success(list);
        }
        return Result.failure(
          AppException.server(
            'Lỗi server (${response.statusCode})',
            statusCode: response.statusCode,
          ),
        );
      }
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
  Future<Result<void>> updateMajor({
    required String username,
    required String major,
  }) async {
    try {
      final String url =
          "${ApiConstants.users}/update-major?username=${Uri.encodeComponent(username)}&major=${Uri.encodeComponent(major)}";
      var response = await http.post(Uri.parse(url));

      if (response.statusCode == 200) {
        return const Result.success(null);
      } else {
        return Result.failure(
          AppException.server('Không thể lưu chuyên ngành (${response.statusCode})'),
        );
      }
    } catch (e) {
      return Result.failure(AppException.network('Lỗi kết nối: $e'));
    }
  }
}
