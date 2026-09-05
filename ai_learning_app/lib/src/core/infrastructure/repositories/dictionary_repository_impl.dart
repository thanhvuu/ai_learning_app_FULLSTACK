import 'package:injectable/injectable.dart';
import 'package:ai_learning_app/src/common/utils/service_locator.dart';
import 'package:ai_learning_app/src/core/domain/app_exception.dart';
import 'package:ai_learning_app/src/core/domain/entities/dictionary_word.dart';
import 'package:ai_learning_app/src/core/domain/entities/saved_word_entity.dart';
import 'package:ai_learning_app/src/core/domain/interfaces/i_dictionary_repository.dart';
import 'package:ai_learning_app/src/core/domain/result.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/saved_word_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/interfaces/dictionary_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/sqflite_dictionary_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/network/api_client.dart';

abstract class IDictionaryService {
  Future<Map<String, dynamic>?> lookupWordOffline(String word);
  Future<bool> toggleSaveWord(String word, String meaning);
  Future<bool> isWordSaved(String word);
  Future<List<Map<String, dynamic>>> getGardenWords();
  Future<void> updateWordProgress(String word, int currentLevel, bool isRemembered);
  Future<Result<Map<String, dynamic>>> lookupWordAdvanced(String word);
}

@LazySingleton(as: IDictionaryService)
class DictionaryServiceImpl implements IDictionaryService {
  DictionaryServiceImpl({
    DictionaryDao? dictionaryDao,
    SavedWordDao? savedWordDao,
    ApiClient? apiClient,
  })  : _dictionaryDao = dictionaryDao ?? SqfliteDictionaryDao(),
        _savedWordDao = savedWordDao ?? SavedWordDao(),
        _providedApiClient = apiClient;

  final DictionaryDao _dictionaryDao;
  final SavedWordDao _savedWordDao;
  final ApiClient? _providedApiClient;

  ApiClient get _apiClient => _providedApiClient ?? ServiceLocator.apiClient;

  @override
  Future<List<Map<String, dynamic>>> getGardenWords() async {
    final words = await _savedWordDao.getAll();
    return words
        .map((w) => {
              'id': w.id,
              'word': w.word,
              'meaning': w.meaning,
              'level': w.level,
              'last_reviewed': w.lastReviewed,
            })
        .toList();
  }

  @override
  Future<bool> isWordSaved(String word) async {
    return _savedWordDao.isWordSaved(_normalizeWord(word));
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
    final isSaved = await _savedWordDao.isWordSaved(normalizedWord);

    if (isSaved) {
      await _savedWordDao.delete(normalizedWord);
      return false;
    }

    await _savedWordDao.insertOne(
      SavedWordEntity(
        id: normalizedWord,
        word: normalizedWord,
        meaning: meaning,
        level: 0,
        lastReviewed: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    return true;
  }

  @override
  Future<void> updateWordProgress(
    String word,
    int currentLevel,
    bool isRemembered,
  ) async {
    await _savedWordDao.updateWordProgress(
      word: _normalizeWord(word),
      currentLevel: currentLevel,
      isRemembered: isRemembered,
    );
  }

  @override
  Future<Result<Map<String, dynamic>>> lookupWordAdvanced(String word) async {
    try {
      final result = await _apiClient.get(
        '/api/dictionary/lookup',
        queryParameters: {'word': word},
      );
      return result.when(
        success: (data) {
          if (data is Map<String, dynamic>) {
            return Result.success(data);
          } else if (data is Map) {
            return Result.success(Map<String, dynamic>.from(data));
          }
          return const Result.failure(
            AppException('Dữ liệu từ điển không hợp lệ'),
          );
        },
        failure: (err) => Result.failure(err),
      );
    } catch (e) {
      return Result.failure(
        AppException.network('Lỗi gọi AI từ điển: $e'),
      );
    }
  }

  String _normalizeWord(String word) => word.trim().toLowerCase();
}

class DictionaryRepositoryImpl implements IDictionaryRepository {
  final IDictionaryService _dictionaryService;
  final SavedWordDao _savedWordDao;

  DictionaryRepositoryImpl({
    IDictionaryService? dictionaryService,
    SavedWordDao? savedWordDao,
  })  : _savedWordDao = savedWordDao ?? SavedWordDao(),
        _dictionaryService = dictionaryService ??
            DictionaryServiceImpl(savedWordDao: savedWordDao);

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
      final raw = await _dictionaryService.getGardenWords();
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
      await _savedWordDao.delete(rawWord.trim().toLowerCase());
      return const Success(null);
    } catch (e) {
      return Failure(AppException('Lỗi xóa từ: $e'));
    }
  }
}
