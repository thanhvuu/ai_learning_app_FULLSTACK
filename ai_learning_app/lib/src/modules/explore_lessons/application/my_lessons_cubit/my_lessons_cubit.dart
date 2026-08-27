import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/domain/repositories/lesson_repository.dart';
import 'my_lessons_state.dart';

class MyLessonsCubit extends Cubit<MyLessonsState> {
  final LessonRepository _lessonRepository;

  MyLessonsCubit({required LessonRepository lessonRepository})
      : _lessonRepository = lessonRepository,
        super(const MyLessonsState());

  Future<void> loadLessons(String username) async {
    emit(state.copyWith(status: MyLessonsStatus.loading, errorMessage: null));

    final result = await _lessonRepository.fetchMyLessons(username);

    result.when(
      success: (lessons) => emit(state.copyWith(
        status: MyLessonsStatus.success,
        lessons: lessons,
      )),
      failure: (error) => emit(state.copyWith(
        status: MyLessonsStatus.failure,
        errorMessage: error.message,
      )),
    );
  }
}
