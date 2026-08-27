import 'package:equatable/equatable.dart';

class QuizState extends Equatable {
  final int currentQuestionIndex;
  final String? selectedOption;
  final bool hasSubmitted;
  final bool isCorrect;
  final int correctCount;
  final bool isQuizCompleted;

  const QuizState({
    this.currentQuestionIndex = 0,
    this.selectedOption,
    this.hasSubmitted = false,
    this.isCorrect = false,
    this.correctCount = 0,
    this.isQuizCompleted = false,
  });

  QuizState copyWith({
    int? currentQuestionIndex,
    String? selectedOption,
    bool clearSelectedOption = false,
    bool? hasSubmitted,
    bool? isCorrect,
    int? correctCount,
    bool? isQuizCompleted,
  }) {
    return QuizState(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedOption: clearSelectedOption ? null : (selectedOption ?? this.selectedOption),
      hasSubmitted: hasSubmitted ?? this.hasSubmitted,
      isCorrect: isCorrect ?? this.isCorrect,
      correctCount: correctCount ?? this.correctCount,
      isQuizCompleted: isQuizCompleted ?? this.isQuizCompleted,
    );
  }

  @override
  List<Object?> get props => [
        currentQuestionIndex,
        selectedOption,
        hasSubmitted,
        isCorrect,
        correctCount,
        isQuizCompleted,
      ];
}
