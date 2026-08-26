import 'package:ai_learning_app/src/core/domain/result.dart';
import 'package:ai_learning_app/src/core/domain/entities/dictionary_word.dart';

abstract class IDictionaryRepository {
  Future<Result<DictionaryWord?>> lookupWordOffline(String rawWord);
  Future<Result<bool>> toggleSaveWord(String rawWord, String meaning);
  Future<Result<List<DictionaryWord>>> getSavedWords();
  Future<Result<void>> updateWordProgress(String rawWord, int currentLevel, bool isCorrect);
  Future<Result<void>> deleteSavedWord(String rawWord);
}
