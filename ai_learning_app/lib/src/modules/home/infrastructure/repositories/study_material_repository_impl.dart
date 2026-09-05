import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:ai_learning_app/src/common/utils/service_locator.dart';
import 'package:ai_learning_app/src/core/domain/app_exception.dart';
import 'package:ai_learning_app/src/core/domain/entities/cached_lesson_entity.dart';
import 'package:ai_learning_app/src/core/domain/result.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/cached_lesson_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/network/api_client.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/data/models/question_model.dart';
import 'package:ai_learning_app/src/modules/home/domain/interfaces/i_study_material_repository.dart';

class StudyMaterialRepositoryImpl implements IStudyMaterialRepository {
  final CachedLessonDao _lessonDao;
  final ApiClient _apiClient;

  StudyMaterialRepositoryImpl({
    required CachedLessonDao lessonDao,
    ApiClient? apiClient,
  })  : _lessonDao = lessonDao,
        _apiClient = apiClient ?? ServiceLocator.apiClient;

  @override
  Future<Result<GeneratedLessonResult>> uploadAndGenerateLesson({
    required File file,
    required String quizType,
    required String username,
  }) async {
    try {
      final fileName = file.path.split(Platform.pathSeparator).last;
      final formData = dio.FormData.fromMap({
        'quizType': quizType,
        'username': username,
        'file': await dio.MultipartFile.fromFile(file.path, filename: fileName),
      });

      final result = await _apiClient.post(
        '/api/lessons/upload',
        data: formData,
      );

      return await result.when(
        success: (data) async {
          if (data is Map) {
            final jsonResult = Map<String, dynamic>.from(data);
            int lessonId = (jsonResult['id'] as num?)?.toInt() ?? 0;
            List<dynamic> questionsJson = jsonResult['questions'] ?? [];

            List<QuestionModel> generatedQuestions = questionsJson
                .map((q) => QuestionModel.fromJson(Map<String, dynamic>.from(q as Map)))
                .toList();

            // Cache lesson into Hive
            await _lessonDao.insertOne(
              CachedLessonEntity(
                id: '$lessonId',
                topic: fileName,
                major: 'General',
                content: jsonResult['content']?.toString() ?? '',
                quizType: quizType,
                vocabularies: [],
                questions: questionsJson.cast<Map<dynamic, dynamic>>(),
                createdAt: DateTime.now().millisecondsSinceEpoch,
              ),
            );

            return Result.success(
              GeneratedLessonResult(
                lessonId: lessonId,
                questions: generatedQuestions,
                quizType: quizType,
              ),
            );
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
}
