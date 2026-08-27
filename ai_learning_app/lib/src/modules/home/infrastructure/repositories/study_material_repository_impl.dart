import 'dart:convert';
import 'dart:io';
import 'package:ai_learning_app/src/common/constants/api_constants.dart';
import 'package:ai_learning_app/src/core/domain/app_exception.dart';
import 'package:ai_learning_app/src/core/domain/entities/cached_lesson_entity.dart';
import 'package:ai_learning_app/src/core/domain/result.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/cached_lesson_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/network/http_compat.dart' as http;
import 'package:ai_learning_app/src/modules/explore_lessons/data/models/question_model.dart';
import 'package:ai_learning_app/src/modules/home/domain/interfaces/i_study_material_repository.dart';

class StudyMaterialRepositoryImpl implements IStudyMaterialRepository {
  final CachedLessonDao _lessonDao;

  StudyMaterialRepositoryImpl({required CachedLessonDao lessonDao})
      : _lessonDao = lessonDao;

  @override
  Future<Result<GeneratedLessonResult>> uploadAndGenerateLesson({
    required File file,
    required String quizType,
    required String username,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${ApiConstants.lessons}/upload"),
      );

      request.fields['quizType'] = quizType;
      request.fields['username'] = username;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonResult = jsonDecode(utf8.decode(response.bodyBytes));
        int lessonId = jsonResult['id'] ?? 0;
        List<dynamic> questionsJson = jsonResult['questions'] ?? [];

        List<QuestionModel> generatedQuestions = questionsJson
            .map((q) => QuestionModel.fromJson(q))
            .toList();

        // Cache lesson into Hive
        await _lessonDao.insertOne(
          CachedLessonEntity(
            id: '$lessonId',
            topic: file.path.split(Platform.pathSeparator).last,
            major: 'General',
            content: jsonResult['content'] ?? '',
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
}
