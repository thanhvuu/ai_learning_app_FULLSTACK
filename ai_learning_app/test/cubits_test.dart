import 'package:flutter_test/flutter_test.dart';
import 'package:ai_learning_app/src/core/domain/result.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/application/major_selection_cubit/major_selection_cubit.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/application/major_selection_cubit/major_selection_state.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/application/quiz_cubit/quiz_cubit.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/application/roadmap_cubit/roadmap_cubit.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/application/roadmap_cubit/roadmap_state.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/domain/repositories/lesson_repository.dart';

void main() {
  group('QuizCubit Tests', () {
    test('QuizCubit evaluates correct/incorrect answers and tracks progress', () {
      final cubit = QuizCubit(totalQuestions: 2);

      expect(cubit.state.currentQuestionIndex, 0);
      expect(cubit.state.correctCount, 0);

      cubit.selectOption('Option A');
      expect(cubit.state.selectedOption, 'Option A');

      cubit.submitAnswer('Option A');
      expect(cubit.state.hasSubmitted, isTrue);
      expect(cubit.state.isCorrect, isTrue);
      expect(cubit.state.correctCount, 1);

      cubit.nextQuestion();
      expect(cubit.state.currentQuestionIndex, 1);
      expect(cubit.state.hasSubmitted, isFalse);
      expect(cubit.state.selectedOption, isNull);

      cubit.selectOption('Option B');
      cubit.submitAnswer('Option C');
      expect(cubit.state.isCorrect, isFalse);
      expect(cubit.state.correctCount, 1);

      cubit.nextQuestion();
      expect(cubit.state.isQuizCompleted, isTrue);
    });
  });

  group('MajorSelectionCubit Tests', () {
    test('Select major emits success state on valid selection', () async {
      final fakeRepo = _FakeLessonRepository();
      final cubit = MajorSelectionCubit(lessonRepository: fakeRepo);

      await cubit.selectMajor(
        username: 'test_user',
        major: 'Information Technology',
      );

      expect(cubit.state.status, MajorSelectionStatus.success);
      expect(cubit.state.selectedMajor, 'Information Technology');
    });
  });

  group('RoadmapCubit Tests', () {
    test('Load roadmap emits loaded state with steps', () async {
      final fakeRepo = _FakeLessonRepository();
      final cubit = RoadmapCubit(lessonRepository: fakeRepo);

      await cubit.loadRoadmap('Information Technology');

      expect(cubit.state.status, RoadmapStatus.loaded);
      expect(cubit.state.steps.length, 2);
    });
  });
}

class _FakeLessonRepository implements LessonRepository {
  @override
  Future<Result<List<dynamic>>> fetchRoadmap(String major) async {
    return const Result.success([
      {'topic': 'Topic 1'},
      {'topic': 'Topic 2'},
    ]);
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> fetchMyLessons(String username) async {
    return const Result.success(<Map<String, dynamic>>[]);
  }

  @override
  Future<Result<Map<String, dynamic>>> generateLessonByTopic({
    required String topic,
    required String username,
    required String major,
    required String quizType,
  }) async {
    return const Result.success(<String, dynamic>{'id': 1, 'questions': [], 'vocabularies': []});
  }

  @override
  Future<Result<void>> updateMajor({
    required String username,
    required String major,
  }) async {
    return const Result.success(null);
  }
}
