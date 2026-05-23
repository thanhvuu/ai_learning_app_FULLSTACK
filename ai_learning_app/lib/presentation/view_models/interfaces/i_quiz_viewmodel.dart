abstract class IQuizViewModel {
  int get lives;
  double get progress;
  List<dynamic> get questions;

  void decreaseLive();
  void updateProgress(double progress);
  void resetQuiz();
  void setQuestions(List<dynamic> apiQuestions);
}
