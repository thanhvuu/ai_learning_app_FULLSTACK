import 'package:flutter_bloc/flutter_bloc.dart';
import 'quiz_state.dart';

class QuizCubit extends Cubit<QuizState> {
  final int totalQuestions;

  QuizCubit({required this.totalQuestions}) : super(const QuizState());

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
}
