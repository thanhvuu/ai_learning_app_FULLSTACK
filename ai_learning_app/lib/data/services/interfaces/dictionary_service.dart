abstract class IDictionaryService {
  Future<Map<String, dynamic>?> lookupWordOffline(String word);
  Future<bool> isWordSaved(String word);
  Future<bool> toggleSaveWord(String word, String meaning);
  Future<List<Map<String, dynamic>>> getGardenWords();
  Future<void> updateWordProgress(String word, int currentLevel, bool isRemembered);
}
