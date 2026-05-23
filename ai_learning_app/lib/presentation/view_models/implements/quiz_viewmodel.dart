import 'package:ai_learning_app/presentation/view_models/interfaces/i_quiz_viewmodel.dart';
import 'package:flutter/material.dart';

class QuizViewModel extends ChangeNotifier implements IQuizViewModel {
  int _lives = 3;
  double _progress = 0.0;
  List<dynamic> _questions = [];

  @override
  int get lives => _lives;

  @override
  double get progress => _progress;

  @override
  List<dynamic> get questions => _questions;

  @override
  void decreaseLive() {
    if (_lives > 0) {
      _lives--;
      notifyListeners();
    }
  }

  @override
  void resetQuiz() {
    _lives = 3;
    _progress = 0.0;
    notifyListeners();
  }

  @override
  void setQuestions(List<dynamic> apiQuestions) {
    _questions = List<Map<String, dynamic>>.from(apiQuestions);
    notifyListeners();
  }

  @override
  void updateProgress(double progress) {
    _progress = progress;
    notifyListeners();
  }
}
