import 'package:ai_learning_app/src/core/domain/app_exception.dart';
import 'package:ai_learning_app/src/core/domain/entities/dictionary_word.dart';
import 'package:ai_learning_app/src/core/domain/interfaces/i_dictionary_repository.dart';
import 'package:ai_learning_app/src/core/domain/result.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/interfaces/dictionary_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/sqflite_dictionary_dao.dart';

abstract class IDictionaryService {
  Future<Map<String, dynamic>?> lookupWordOffline(String word);
  Future<bool> toggleSaveWord(String word, String meaning);
  Future<bool> isWordSaved(String word);
  Future<List<Map<String, dynamic>>> getGardenWords();
  Future<void> updateWordProgress(String word, int currentLevel, bool isRemembered);
}

class DictionaryServiceImpl implements IDictionaryService {
  DictionaryServiceImpl({DictionaryDao? dictionaryDao})
      : _dictionaryDao = dictionaryDao ?? SqfliteDictionaryDao();

  final DictionaryDao _dictionaryDao;

  @override
  Future<List<Map<String, dynamic>>> getGardenWords() async {
    return _dictionaryDao.getSavedWords();
  }

  @override
  Future<bool> isWordSaved(String word) async {
    final savedWord = await _dictionaryDao.findSavedWordByWord(
      _normalizeWord(word),
    );
    return savedWord != null;
  }

  @override
  Future<Map<String, dynamic>?> lookupWordOffline(String word) async {
    final searchWord = _normalizeWord(word);
    final rawData = await _dictionaryDao.findDictionaryEntryByWord(searchWord);
    if (rawData == null) return null;

    return {
      'word': rawData['word'] ?? searchWord,
      'phonetic': rawData['pronounce'] ?? '',
      'partOfSpeech': '',
      'meaning': rawData['description'] ?? rawData['html'] ?? 'Không có dữ liệu',
      'synonyms': [],
      'antonyms': [],
      'examples': [],
    };
  }

  @override
  Future<bool> toggleSaveWord(String word, String meaning) async {
    final normalizedWord = _normalizeWord(word);
    final savedWord = await _dictionaryDao.findSavedWordByWord(normalizedWord);

    if (savedWord != null) {
      await _dictionaryDao.deleteSavedWord(normalizedWord);
      return false;
    }

    await _dictionaryDao.insertSavedWord(
      word: normalizedWord,
      meaning: meaning,
      level: 0,
      lastReviewed: DateTime.now().millisecondsSinceEpoch,
    );
    return true;
  }

  @override
  Future<void> updateWordProgress(
    String word,
    int currentLevel,
    bool isRemembered,
  ) async {
    var newLevel = currentLevel;
    if (isRemembered) {
      newLevel = currentLevel < 3 ? currentLevel + 1 : 3;
    } else {
      newLevel = currentLevel > 0 ? currentLevel - 1 : 0;
    }

    await _dictionaryDao.updateSavedWordProgress(
      word: _normalizeWord(word),
      level: newLevel,
      lastReviewed: DateTime.now().millisecondsSinceEpoch,
    );
  }

  String _normalizeWord(String word) => word.trim().toLowerCase();
}

class DictionaryRepositoryImpl implements IDictionaryRepository {
  final IDictionaryService _dictionaryService;
  final DictionaryDao _dictionaryDao;

  DictionaryRepositoryImpl({
    IDictionaryService? dictionaryService,
    DictionaryDao? dictionaryDao,
  })  : _dictionaryDao = dictionaryDao ?? SqfliteDictionaryDao(),
        _dictionaryService = dictionaryService ??
            DictionaryServiceImpl(dictionaryDao: dictionaryDao ?? SqfliteDictionaryDao());

  @override
  Future<Result<DictionaryWord?>> lookupWordOffline(String rawWord) async {
    try {
      final map = await _dictionaryService.lookupWordOffline(rawWord);
      if (map == null) return const Success(null);
      return Success(DictionaryWord.fromMap(map));
    } catch (e) {
      return Failure(AppException('Lỗi tra từ: $e'));
    }
  }

  @override
  Future<Result<bool>> toggleSaveWord(String rawWord, String meaning) async {
    try {
      final saved = await _dictionaryService.toggleSaveWord(rawWord, meaning);
      return Success(saved);
    } catch (e) {
      return Failure(AppException('Lỗi lưu từ: $e'));
    }
  }

  @override
  Future<Result<List<DictionaryWord>>> getSavedWords() async {
    try {
      final raw = await _dictionaryDao.getSavedWords();
      final list = raw.map((e) => DictionaryWord.fromMap(e)).toList();
      return Success(list);
    } catch (e) {
      return Failure(AppException('Lỗi tải danh sách từ: $e'));
    }
  }

  @override
  Future<Result<void>> updateWordProgress(String rawWord, int currentLevel, bool isCorrect) async {
    try {
      await _dictionaryService.updateWordProgress(rawWord, currentLevel, isCorrect);
      return const Success(null);
    } catch (e) {
      return Failure(AppException('Lỗi cập nhật từ: $e'));
    }
  }

  @override
  Future<Result<void>> deleteSavedWord(String rawWord) async {
    try {
      await _dictionaryDao.deleteSavedWord(rawWord.trim().toLowerCase());
      return const Success(null);
    } catch (e) {
      return Failure(AppException('Lỗi xóa từ: $e'));
    }
  }
}
