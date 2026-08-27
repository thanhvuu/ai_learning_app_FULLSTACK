import 'package:equatable/equatable.dart';
import 'package:ai_learning_app/src/modules/home/domain/interfaces/i_study_material_repository.dart';

enum StudyMaterialStatus { initial, loading, success, failure }

class StudyMaterialState extends Equatable {
  final StudyMaterialStatus status;
  final GeneratedLessonResult? generatedLesson;
  final String? errorMessage;

  const StudyMaterialState({
    this.status = StudyMaterialStatus.initial,
    this.generatedLesson,
    this.errorMessage,
  });

  bool get isLoading => status == StudyMaterialStatus.loading;
  bool get isSuccess => status == StudyMaterialStatus.success;

  StudyMaterialState copyWith({
    StudyMaterialStatus? status,
    GeneratedLessonResult? generatedLesson,
    String? errorMessage,
  }) {
    return StudyMaterialState(
      status: status ?? this.status,
      generatedLesson: generatedLesson ?? this.generatedLesson,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, generatedLesson, errorMessage];
}
