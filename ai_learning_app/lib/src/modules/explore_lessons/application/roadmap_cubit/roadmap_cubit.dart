import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/domain/repositories/lesson_repository.dart';
import 'roadmap_state.dart';

class RoadmapCubit extends Cubit<RoadmapState> {
  final LessonRepository _lessonRepository;

  RoadmapCubit({required LessonRepository lessonRepository})
      : _lessonRepository = lessonRepository,
        super(const RoadmapState());

  Future<void> loadRoadmap(String major) async {
    emit(state.copyWith(status: RoadmapStatus.loading, errorMessage: null));

    final result = await _lessonRepository.fetchRoadmap(major);
    result.when(
      success: (steps) => emit(state.copyWith(
        status: RoadmapStatus.loaded,
        steps: steps,
      )),
      failure: (error) => emit(state.copyWith(
        status: RoadmapStatus.failure,
        errorMessage: error.message,
      )),
    );
  }

  Future<void> startLesson({
    required String topic,
    required String username,
    required String major,
    String quizType = 'multiple_choice',
  }) async {
    emit(state.copyWith(
      status: RoadmapStatus.generatingLesson,
      errorMessage: null,
    ));

    final result = await _lessonRepository.generateLessonByTopic(
      topic: topic,
      username: username,
      major: major,
      quizType: quizType,
    );

    result.when(
      success: (lesson) => emit(state.copyWith(
        status: RoadmapStatus.lessonReady,
        generatedLesson: lesson,
      )),
      failure: (error) => emit(state.copyWith(
        status: RoadmapStatus.failure,
        errorMessage: error.message,
      )),
    );
  }

  void resetLessonStatus() {
    emit(state.copyWith(
      status: RoadmapStatus.loaded,
      generatedLesson: null,
    ));
  }
}
