import 'package:ai_learning_app/data/dao/interfaces/dictionary_dao.dart';
import 'package:ai_learning_app/data/services/implements/dictionary_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DictionaryServiceImpl', () {
    test(
      'toggleSaveWord saves normalized word and removes it on next toggle',
      () async {
        final dao = _FakeDictionaryDao();
        final service = DictionaryServiceImpl(dictionaryDao: dao);

        final saved = await service.toggleSaveWord(' Apple ', 'A fruit');
        final removed = await service.toggleSaveWord('apple', 'A fruit');

        expect(saved, isTrue);
        expect(removed, isFalse);
        expect(dao.savedWords, isEmpty);
        expect(dao.insertedWords, ['apple']);
        expect(dao.deletedWords, ['apple']);
      },
    );

    test('lookupWordOffline maps raw DAO row for UI usage', () async {
      final dao = _FakeDictionaryDao()
        ..dictionaryEntries['hello'] = {
          'word': 'hello',
          'pronounce': '/heˈloʊ/',
          'description': 'xin chao',
        };
      final service = DictionaryServiceImpl(dictionaryDao: dao);

      final result = await service.lookupWordOffline('Hello');

      expect(result, isNotNull);
      expect(result?['word'], 'hello');
      expect(result?['phonetic'], '/heˈloʊ/');
      expect(result?['meaning'], 'xin chao');
    });

    test('updateWordProgress keeps level between 0 and 3', () async {
      final dao = _FakeDictionaryDao();
      final service = DictionaryServiceImpl(dictionaryDao: dao);

      await service.updateWordProgress('Word', 3, true);
      await service.updateWordProgress('Word', 0, false);

      expect(dao.updatedLevels, [3, 0]);
      expect(dao.updatedWords, ['word', 'word']);
    });
  });
}

class _FakeDictionaryDao implements DictionaryDao {
  final Map<String, Map<String, dynamic>> savedWords = {};
  final Map<String, Map<String, dynamic>> dictionaryEntries = {};
  final List<String> insertedWords = [];
  final List<String> deletedWords = [];
  final List<String> updatedWords = [];
  final List<int> updatedLevels = [];

  @override
  Future<void> deleteSavedWord(String word) async {
    deletedWords.add(word);
    savedWords.remove(word);
  }

  @override
  Future<Map<String, dynamic>?> findDictionaryEntryByWord(String word) async {
    return dictionaryEntries[word];
  }

  @override
  Future<Map<String, dynamic>?> findSavedWordByWord(String word) async {
    return savedWords[word];
  }

  @override
  Future<List<Map<String, dynamic>>> getSavedWords() async {
    return savedWords.values.toList();
  }

  @override
  Future<void> insertSavedWord({
    required String word,
    required String meaning,
    required int level,
    required int lastReviewed,
  }) async {
    insertedWords.add(word);
    savedWords[word] = {
      'word': word,
      'meaning': meaning,
      'level': level,
      'last_reviewed': lastReviewed,
    };
  }

  @override
  Future<void> updateSavedWordProgress({
    required String word,
    required int level,
    required int lastReviewed,
  }) async {
    updatedWords.add(word);
    updatedLevels.add(level);
  }
}
