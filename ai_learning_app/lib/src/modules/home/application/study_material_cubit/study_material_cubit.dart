import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_learning_app/src/modules/home/domain/interfaces/i_study_material_repository.dart';
import 'study_material_state.dart';

class StudyMaterialCubit extends Cubit<StudyMaterialState> {
  final IStudyMaterialRepository _repository;

  StudyMaterialCubit({required IStudyMaterialRepository repository})
      : _repository = repository,
        super(const StudyMaterialState());

  Future<void> generateLesson({
    required File file,
    required String quizType,
    required String username,
  }) async {
    emit(const StudyMaterialState(status: StudyMaterialStatus.loading));

    final result = await _repository.uploadAndGenerateLesson(
      file: file,
      quizType: quizType,
      username: username,
    );

    result.when(
      success: (data) => emit(StudyMaterialState(
        status: StudyMaterialStatus.success,
        generatedLesson: data,
      )),
      failure: (error) => emit(StudyMaterialState(
        status: StudyMaterialStatus.failure,
        errorMessage: error.message,
      )),
    );
  }

  void reset() {
    emit(const StudyMaterialState(status: StudyMaterialStatus.initial));
  }
}
