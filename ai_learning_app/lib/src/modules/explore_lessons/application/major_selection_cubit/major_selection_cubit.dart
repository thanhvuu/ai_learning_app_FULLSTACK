import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/domain/repositories/lesson_repository.dart';
import 'major_selection_state.dart';

class MajorSelectionCubit extends Cubit<MajorSelectionState> {
  final LessonRepository _lessonRepository;

  MajorSelectionCubit({required LessonRepository lessonRepository})
      : _lessonRepository = lessonRepository,
        super(const MajorSelectionState());

  Future<void> selectMajor({
    required String username,
    required String major,
  }) async {
    emit(state.copyWith(
      status: MajorSelectionStatus.loading,
      selectedMajor: major,
      errorMessage: null,
    ));

    final result = await _lessonRepository.updateMajor(
      username: username,
      major: major,
    );

    result.when(
      success: (_) => emit(state.copyWith(
        status: MajorSelectionStatus.success,
        selectedMajor: major,
      )),
      failure: (error) => emit(state.copyWith(
        status: MajorSelectionStatus.failure,
        errorMessage: error.message,
      )),
    );
  }
}
