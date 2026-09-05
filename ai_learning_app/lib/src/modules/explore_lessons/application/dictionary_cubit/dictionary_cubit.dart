import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_learning_app/src/common/utils/service_locator.dart';
import 'package:ai_learning_app/src/core/infrastructure/repositories/dictionary_repository_impl.dart';
import 'dictionary_state.dart';

class DictionaryCubit extends Cubit<DictionaryState> {
  final IDictionaryService _dictionaryService;

  DictionaryCubit({
    required Map<String, dynamic> initialData,
    required String searchWord,
    IDictionaryService? dictionaryService,
  })  : _dictionaryService = dictionaryService ?? ServiceLocator.dictionaryService,
        super(DictionaryState(wordData: initialData, isLoadingAI: true, isSaved: false)) {
    init(searchWord);
  }

  Future<void> init(String searchWord) async {
    await checkSavedStatus(searchWord);
    await fetchAdvancedData(searchWord);
  }

  Future<void> checkSavedStatus(String searchWord) async {
    final word = state.wordData['word'] ?? searchWord;
    final saved = await _dictionaryService.isWordSaved(word);
    emit(state.copyWith(isSaved: saved));
  }

  Future<bool> toggleSave(String searchWord) async {
    final word = state.wordData['word'] ?? searchWord;
    final meaning = state.wordData['meaning'] ?? "Không có nghĩa";
    final newState = await _dictionaryService.toggleSaveWord(word, meaning);
    emit(state.copyWith(isSaved: newState));
    return newState;
  }

  Future<void> fetchAdvancedData(String searchWord) async {
    emit(state.copyWith(isLoadingAI: true));
    final result = await _dictionaryService.lookupWordAdvanced(searchWord);
    result.when(
      success: (data) {
        final updatedData = Map<String, dynamic>.from(state.wordData);
        updatedData['examples'] = data['examples'];
        updatedData['synonyms'] = data['synonyms'];
        updatedData['antonyms'] = data['antonyms'];

        if (updatedData['meaning'] == "Đang nhờ AI phân tích cụm từ này..." ||
            updatedData['meaning'] == null ||
            updatedData['meaning'].toString().isEmpty) {
          updatedData['meaning'] = data['meaning'];
        }

        if (updatedData['phonetic'] == null ||
            updatedData['phonetic'].toString().isEmpty) {
          updatedData['phonetic'] = data['phonetic'];
        }
        if (updatedData['partOfSpeech'] == null ||
            updatedData['partOfSpeech'].toString().isEmpty) {
          updatedData['partOfSpeech'] = data['partOfSpeech'];
        }

        emit(state.copyWith(
          wordData: updatedData,
          isLoadingAI: false,
        ));
      },
      failure: (err) {
        emit(state.copyWith(
          isLoadingAI: false,
          errorMessage: err.message,
        ));
      },
    );
  }
}
