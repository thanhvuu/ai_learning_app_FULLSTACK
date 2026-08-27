import 'package:equatable/equatable.dart';
import 'package:ai_learning_app/src/core/domain/entities/saved_word_entity.dart';

enum GardenStatus { initial, loading, success, failure }

class VocabularyGardenState extends Equatable {
  final GardenStatus status;
  final List<SavedWordEntity> gardenWords;
  final List<SavedWordEntity> wordsToReview;
  final String? errorMessage;

  const VocabularyGardenState({
    this.status = GardenStatus.initial,
    this.gardenWords = const [],
    this.wordsToReview = const [],
    this.errorMessage,
  });

  bool get isLoading => status == GardenStatus.loading;
  bool get isEmpty => gardenWords.isEmpty;

  VocabularyGardenState copyWith({
    GardenStatus? status,
    List<SavedWordEntity>? gardenWords,
    List<SavedWordEntity>? wordsToReview,
    String? errorMessage,
  }) {
    return VocabularyGardenState(
      status: status ?? this.status,
      gardenWords: gardenWords ?? this.gardenWords,
      wordsToReview: wordsToReview ?? this.wordsToReview,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, gardenWords, wordsToReview, errorMessage];
}
