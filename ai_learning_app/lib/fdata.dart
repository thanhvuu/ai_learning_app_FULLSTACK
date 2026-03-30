// lib/dummy_data.dart

class Question {
  final String prompt;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  Question({
    required this.prompt,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });
}

// Giả lập 3 câu hỏi trắc nghiệm giống AI tạo ra từ PDF
List<Question> dummyQuestions = [
  Question(
    prompt: "A large, friendly parrot mascot is called:",
    options: ["An Owl", "A Penguin", "A Vẹt"],
    correctAnswer: "A Vẹt",
    explanation: "Vẹt (Parrot) is a large, colorful bird, often friendly. You might remember Duo, the green owl, but the example uses a parrot.",
  ),
  Question(
    prompt: "Choose the correct translation for: 'Xin chào!'",
    options: ["Goodbye!", "Hello!", "Thank you!"],
    correctAnswer: "Hello!",
    explanation: "'Xin chào!' is the most standard and widely used Vietnamese greeting, meaning 'Hello!'.",
  ),
  Question(
    prompt: "A 'Large Green Owl' that makes you study every day is:",
    options: ["Friendly", "Frightening", "A useful study companion"],
    correctAnswer: "A useful study companion",
    explanation: "Duo the owl uses reminders and a streak system, making him a unique and effective 'study companion' rather than terrifying (mostly!).",
  ),
];