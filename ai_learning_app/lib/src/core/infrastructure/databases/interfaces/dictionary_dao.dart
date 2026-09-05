abstract class DictionaryDao {
  Future<Map<String, dynamic>?> findDictionaryEntryByWord(String word);
}
