enum QuizType {
  dragDrop('drag_drop', 'Kéo thả từ vựng', 'Drag & Drop'),
  multipleChoice('multiple_choice', 'Trắc nghiệm', 'Multiple Choice'),
  fillBlank('fill_blank', 'Bài đục lỗ', 'Fill in the blanks'),
  flashcard('flashcard', 'Lật thẻ từ vựng', 'Flashcard');

  final String value;
  final String labelVi;
  final String labelEn;

  const QuizType(this.value, this.labelVi, this.labelEn);

  static QuizType fromString(String? type) {
    switch (type) {
      case 'drag_drop':
        return QuizType.dragDrop;
      case 'multiple_choice':
        return QuizType.multipleChoice;
      case 'fill_blank':
        return QuizType.fillBlank;
      case 'flashcard':
        return QuizType.flashcard;
      default:
        return QuizType.multipleChoice;
    }
  }
}
