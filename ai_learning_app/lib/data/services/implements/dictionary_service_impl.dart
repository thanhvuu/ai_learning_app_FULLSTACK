import 'package:ai_learning_app/data/dao/implements/sqflite_dictionary_dao.dart';
import 'package:ai_learning_app/data/dao/interfaces/dictionary_dao.dart';
import 'package:ai_learning_app/data/services/interfaces/dictionary_service.dart';

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
      'meaning':
          rawData['description'] ?? rawData['html'] ?? 'Không có dữ liệu',
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
