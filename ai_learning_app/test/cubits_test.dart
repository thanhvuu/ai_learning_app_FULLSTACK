import 'package:flutter_test/flutter_test.dart';
import 'package:ai_learning_app/src/core/domain/result.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/application/my_lessons_cubit/my_lessons_cubit.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/application/my_lessons_cubit/my_lessons_state.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/application/quiz_cubit/quiz_cubit.dart';
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

  group('MyLessonsCubit Tests', () {
    test('Load lessons emits success state on valid fetch', () async {
      final fakeRepo = _FakeLessonRepository();
      final cubit = MyLessonsCubit(lessonRepository: fakeRepo);

      await cubit.loadLessons('test_user');

      expect(cubit.state.status, MyLessonsStatus.success);
      expect(cubit.state.lessons.length, 1);
      expect(cubit.state.lessons.first['topic'], 'Flutter Basics');
    });
  });
}

class _FakeLessonRepository implements LessonRepository {
  @override
  Future<Result<List<Map<String, dynamic>>>> fetchMyLessons(String username) async {
    return const Result.success(<Map<String, dynamic>>[
      {'id': 1, 'topic': 'Flutter Basics', 'content': 'Learn widgets'},
    ]);
  }

  @override
  Future<Result<Map<String, dynamic>>> generateLessonByTopic({
    required String topic,
    required String username,
    required String quizType,
    String? category,
  }) async {
    return const Result.success(<String, dynamic>{'id': 1, 'questions': [], 'vocabularies': []});
  }
}
