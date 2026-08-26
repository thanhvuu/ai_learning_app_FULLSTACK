import 'package:ai_learning_app/src/core/domain/entities/saved_word_entity.dart';
import '../base_dao.dart';
import '../database_service.dart';

class SavedWordDao extends BaseDao<SavedWordEntity> {
  SavedWordDao() : super(DatabaseService.savedWordsBox);

  Future<SavedWordEntity?> findWord(String word) async {
    return getById(word.trim().toLowerCase());
  }

  Future<bool> isWordSaved(String word) async {
    final entry = await findWord(word);
    return entry != null;
  }

  Future<void> toggleSaveWord(SavedWordEntity word) async {
    final key = word.word.trim().toLowerCase();
    if (await isWordSaved(key)) {
      await delete(key);
    } else {
      await insertOne(word.copyWith(id: key));
    }
  }

  Future<List<SavedWordEntity>> getWordsDueForReview() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    return getAll(filter: (word) {
      int intervalHours;
      switch (word.level) {
        case 1:
          intervalHours = 24;
          break;
        case 2:
          intervalHours = 72;
          break;
        case 3:
          intervalHours = 168;
          break;
        default:
          intervalHours = 0;
      }
      final diffHours = (now - word.lastReviewed) / (1000 * 60 * 60);
      return diffHours >= intervalHours;
    });
  }

  Future<void> updateWordProgress({
    required String word,
    required int currentLevel,
    required bool isRemembered,
  }) async {
    final key = word.trim().toLowerCase();
    final existing = await findWord(key);
    int newLevel = isRemembered ? currentLevel + 1 : currentLevel - 1;
    if (newLevel < 0) newLevel = 0;
    if (newLevel > 3) newLevel = 3;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (existing != null) {
      await update(
        existing.copyWith(level: newLevel, lastReviewed: now),
      );
    } else {
      await insertOne(
        SavedWordEntity(
          id: key,
          word: word,
          meaning: '',
          level: newLevel,
          lastReviewed: now,
        ),
      );
    }
  }
}
