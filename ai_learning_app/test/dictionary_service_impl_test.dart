import 'package:flutter_test/flutter_test.dart';
import 'package:ai_learning_app/src/core/domain/entities/saved_word_entity.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/saved_word_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/interfaces/dictionary_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/repositories/dictionary_repository_impl.dart';

void main() {
  group('DictionaryServiceImpl', () {
    test(
      'toggleSaveWord saves normalized word and removes it on next toggle via SavedWordDao',
      () async {
        final dao = _FakeDictionaryDao();
        final savedWordDao = _FakeSavedWordDao();
        final service = DictionaryServiceImpl(
          dictionaryDao: dao,
          savedWordDao: savedWordDao,
        );

        final saved = await service.toggleSaveWord(' Apple ', 'A fruit');
        expect(saved, isTrue);
        expect(savedWordDao.insertedWords, ['apple']);
        expect(await service.isWordSaved('apple'), isTrue);

        final removed = await service.toggleSaveWord('apple', 'A fruit');
        expect(removed, isFalse);
        expect(savedWordDao.deletedWords, ['apple']);
        expect(await service.isWordSaved('apple'), isFalse);
      },
    );

    test('lookupWordOffline maps raw DAO row for UI usage', () async {
      final dao = _FakeDictionaryDao()
        ..dictionaryEntries['hello'] = {
          'word': 'hello',
          'pronounce': '/heˈloʊ/',
          'description': 'xin chao',
        };
      final service = DictionaryServiceImpl(
        dictionaryDao: dao,
        savedWordDao: _FakeSavedWordDao(),
      );

      final result = await service.lookupWordOffline('Hello');

      expect(result, isNotNull);
      expect(result?['word'], 'hello');
      expect(result?['phonetic'], '/heˈloʊ/');
      expect(result?['meaning'], 'xin chao');
    });

    test('updateWordProgress delegates to SavedWordDao and respects limits', () async {
      final savedWordDao = _FakeSavedWordDao();
      final service = DictionaryServiceImpl(
        dictionaryDao: _FakeDictionaryDao(),
        savedWordDao: savedWordDao,
      );

      await service.updateWordProgress('Word', 3, true);
      await service.updateWordProgress('Word', 0, false);

      expect(savedWordDao.updatedLevels, [3, 0]);
      expect(savedWordDao.updatedWords, ['word', 'word']);
    });
  });
}

class _FakeDictionaryDao implements DictionaryDao {
  final Map<String, Map<String, dynamic>> dictionaryEntries = {};

  @override
  Future<Map<String, dynamic>?> findDictionaryEntryByWord(String word) async {
    return dictionaryEntries[word];
  }
}

class _FakeSavedWordDao extends SavedWordDao {
  final Map<String, SavedWordEntity> words = {};
  final List<String> insertedWords = [];
  final List<String> deletedWords = [];
  final List<String> updatedWords = [];
  final List<int> updatedLevels = [];

  @override
  Future<SavedWordEntity?> findWord(String word) async => words[word];

  @override
  Future<bool> isWordSaved(String word) async => words.containsKey(word);

  @override
  Future<List<SavedWordEntity>> getAll({bool Function(SavedWordEntity item)? filter}) async {
    final list = words.values.toList();
    return filter != null ? list.where(filter).toList() : list;
  }

  @override
  Future<void> insertOne(SavedWordEntity entity) async {
    insertedWords.add(entity.word);
    words[entity.word] = entity;
  }

  @override
  Future<void> delete(String id) async {
    deletedWords.add(id);
    words.remove(id);
  }

  @override
  Future<void> updateWordProgress({
    required String word,
    required int currentLevel,
    required bool isRemembered,
  }) async {
    int newLevel = isRemembered ? currentLevel + 1 : currentLevel - 1;
    if (newLevel < 0) newLevel = 0;
    if (newLevel > 3) newLevel = 3;
    updatedWords.add(word);
    updatedLevels.add(newLevel);
    if (words.containsKey(word)) {
      words[word] = words[word]!.copyWith(level: newLevel);
    }
  }
}
