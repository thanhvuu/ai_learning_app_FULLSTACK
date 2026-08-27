import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/saved_word_dao.dart';
import 'vocabulary_garden_state.dart';

class VocabularyGardenCubit extends Cubit<VocabularyGardenState> {
  final SavedWordDao _savedWordDao;

  VocabularyGardenCubit({required SavedWordDao savedWordDao})
      : _savedWordDao = savedWordDao,
        super(const VocabularyGardenState());

  Future<void> loadGarden() async {
    emit(state.copyWith(status: GardenStatus.loading, errorMessage: null));

    try {
      final words = await _savedWordDao.getAll();
      final wordsToReview = await _savedWordDao.getWordsDueForReview();

      emit(state.copyWith(
        status: GardenStatus.success,
        gardenWords: words,
        wordsToReview: wordsToReview,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GardenStatus.failure,
        errorMessage: 'Lỗi tải vườn từ vựng: $e',
      ));
    }
  }

  Future<void> updateWordProgress({
    required String word,
    required int currentLevel,
    required bool isRemembered,
  }) async {
    try {
      await _savedWordDao.updateWordProgress(
        word: word,
        currentLevel: currentLevel,
        isRemembered: isRemembered,
      );
      await loadGarden();
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Lỗi cập nhật tiến trình: $e'));
    }
  }
}
