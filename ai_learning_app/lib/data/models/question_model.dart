class QuestionModel {
  final String sentenceStart;
  final String sentenceEnd;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer;
  final String explanation;

  QuestionModel({
    required this.sentenceStart,
    required this.sentenceEnd,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    required this.explanation,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      sentenceStart: json['sentence_start'] ?? json['sentenceStart'] ?? "",
      sentenceEnd: json['sentence_end'] ?? json['sentenceEnd'] ?? "",
      optionA: json['optiona'] ?? json['optionA'] ?? "",
      optionB: json['optionb'] ?? json['optionB'] ?? "",
      optionC: json['optionc'] ?? json['optionC'] ?? "",
      optionD: json['optiond'] ?? json['optionD'] ?? "",
      correctAnswer: json['correct_answer'] ?? json['correctAnswer'] ?? "",
      explanation: json['explanation'] ?? "",
    );
  }
}
