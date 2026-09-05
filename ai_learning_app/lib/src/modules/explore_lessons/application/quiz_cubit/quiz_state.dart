import 'package:equatable/equatable.dart';

class QuizState extends Equatable {
  final int currentQuestionIndex;
  final String? selectedOption;
  final bool hasSubmitted;
  final bool isCorrect;
  final int correctCount;
  final bool isQuizCompleted;
  final bool isSubmitting;
  final bool? submissionSuccess;
  final Map<String, dynamic>? submissionResult;
  final String? errorMessage;

  const QuizState({
    this.currentQuestionIndex = 0,
    this.selectedOption,
    this.hasSubmitted = false,
    this.isCorrect = false,
    this.correctCount = 0,
    this.isQuizCompleted = false,
    this.isSubmitting = false,
    this.submissionSuccess,
    this.submissionResult,
    this.errorMessage,
  });

  QuizState copyWith({
    int? currentQuestionIndex,
    String? selectedOption,
    bool clearSelectedOption = false,
    bool? hasSubmitted,
    bool? isCorrect,
    int? correctCount,
    bool? isQuizCompleted,
    bool? isSubmitting,
    bool? submissionSuccess,
    Map<String, dynamic>? submissionResult,
    String? errorMessage,
  }) {
    return QuizState(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedOption: clearSelectedOption ? null : (selectedOption ?? this.selectedOption),
      hasSubmitted: hasSubmitted ?? this.hasSubmitted,
      isCorrect: isCorrect ?? this.isCorrect,
      correctCount: correctCount ?? this.correctCount,
      isQuizCompleted: isQuizCompleted ?? this.isQuizCompleted,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionSuccess: submissionSuccess ?? this.submissionSuccess,
      submissionResult: submissionResult ?? this.submissionResult,
      errorMessage: errorMessage ?? this.errorMessage,
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
        isSubmitting,
        submissionSuccess,
        submissionResult,
        errorMessage,
      ];
}
