import 'package:equatable/equatable.dart';

enum RoadmapStatus { initial, loading, loaded, generatingLesson, lessonReady, failure }

class RoadmapState extends Equatable {
  final RoadmapStatus status;
  final List<dynamic> steps;
  final Map<String, dynamic>? generatedLesson;
  final String? errorMessage;

  const RoadmapState({
    this.status = RoadmapStatus.initial,
    this.steps = const [],
    this.generatedLesson,
    this.errorMessage,
  });

  bool get isLoading => status == RoadmapStatus.loading;
  bool get isGeneratingLesson => status == RoadmapStatus.generatingLesson;

  RoadmapState copyWith({
    RoadmapStatus? status,
    List<dynamic>? steps,
    Map<String, dynamic>? generatedLesson,
    String? errorMessage,
  }) {
    return RoadmapState(
      status: status ?? this.status,
      steps: steps ?? this.steps,
      generatedLesson: generatedLesson ?? this.generatedLesson,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, steps, generatedLesson, errorMessage];
}
