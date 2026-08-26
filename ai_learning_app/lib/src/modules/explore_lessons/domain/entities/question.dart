class Question {
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;

  const Question({
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });
}
