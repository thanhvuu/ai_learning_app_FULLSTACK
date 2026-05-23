abstract class DictionaryDao {
  Future<List<Map<String, dynamic>>> getSavedWords();

  Future<Map<String, dynamic>?> findSavedWordByWord(String word);

  Future<Map<String, dynamic>?> findDictionaryEntryByWord(String word);

  Future<void> insertSavedWord({
    required String word,
    required String meaning,
    required int level,
    required int lastReviewed,
  });

  Future<void> deleteSavedWord(String word);

  Future<void> updateSavedWordProgress({
    required String word,
    required int level,
    required int lastReviewed,
  });
}
