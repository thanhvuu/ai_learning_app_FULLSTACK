import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/domain/repositories/quiz_repository.dart';
import 'quiz_state.dart';

class QuizCubit extends Cubit<QuizState> {
  final int totalQuestions;
  final QuizRepository? _quizRepository;

  QuizCubit({
    required this.totalQuestions,
    QuizRepository? quizRepository,
  })  : _quizRepository = quizRepository,
        super(const QuizState());

  void selectOption(String option) {
    if (state.hasSubmitted) return;
    emit(state.copyWith(selectedOption: option));
  }

  void submitAnswer(String correctAnswer) {
    if (state.hasSubmitted || state.selectedOption == null) return;

    final isCorrect = state.selectedOption!.trim().toLowerCase() ==
        correctAnswer.trim().toLowerCase();

    emit(state.copyWith(
      hasSubmitted: true,
      isCorrect: isCorrect,
      correctCount: isCorrect ? state.correctCount + 1 : state.correctCount,
    ));
  }

  void nextQuestion() {
    final nextIndex = state.currentQuestionIndex + 1;
    if (nextIndex >= totalQuestions) {
      emit(state.copyWith(isQuizCompleted: true));
    } else {
      emit(state.copyWith(
        currentQuestionIndex: nextIndex,
        clearSelectedOption: true,
        hasSubmitted: false,
        isCorrect: false,
      ));
    }
  }

  void reset() {
    emit(const QuizState());
  }

  /// Complete quiz and update XP & streak on server and local database
  Future<Map<String, dynamic>?> completeUserProgress({required String username}) async {
    if (_quizRepository == null) return null;
    emit(state.copyWith(isSubmitting: true));

    final result = await _quizRepository.completeQuizProgress(username: username);
    return result.when(
      success: (data) {
        emit(state.copyWith(
          isSubmitting: false,
          submissionSuccess: true,
          submissionResult: data,
        ));
        return data;
      },
      failure: (err) {
        emit(state.copyWith(
          isSubmitting: false,
          submissionSuccess: false,
          errorMessage: err.message,
        ));
        return null;
      },
    );
  }

  /// Complete a specific lesson by ID, updating progress to 100% and adding study time
  Future<void> completeLesson({
    required String username,
    required dynamic lessonId,
    int minutes = 5,
  }) async {
    if (_quizRepository == null) return;
    emit(state.copyWith(isSubmitting: true));

    await _quizRepository.updateLessonProgress(
      lessonId: lessonId,
      progress: 1.0,
      isCompleted: true,
    );

    await _quizRepository.addStudyTime(
      username: username,
      minutes: minutes,
    );

    emit(state.copyWith(isSubmitting: false, submissionSuccess: true));
  }

  /// Update vocabulary review progress in flashcard
  Future<void> updateWordReview({
    required String word,
    required int currentLevel,
    required bool isRemembered,
  }) async {
    if (_quizRepository == null) return;
    await _quizRepository.updateWordReviewProgress(
      word: word,
      currentLevel: currentLevel,
      isRemembered: isRemembered,
    );
  }

  /// Send watered plants count to server
  Future<void> finishWateringGarden({
    required String username,
    required int plants,
  }) async {
    if (_quizRepository == null) return;
    emit(state.copyWith(isSubmitting: true));

    await _quizRepository.updateWateredPlants(
      username: username,
      plants: plants,
    );

    emit(state.copyWith(isSubmitting: false, submissionSuccess: true));
  }
}
