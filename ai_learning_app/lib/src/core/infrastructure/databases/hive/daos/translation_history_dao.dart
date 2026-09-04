import 'package:injectable/injectable.dart';
import 'package:ai_learning_app/src/core/domain/entities/translation_history_entity.dart';
import '../base_dao.dart';
import '../database_service.dart';

@lazySingleton
class TranslationHistoryDao extends BaseDao<TranslationHistoryEntity> {
  TranslationHistoryDao() : super(DatabaseService.translationHistoryBox);

  Future<List<TranslationHistoryEntity>> getRecentTranslations({int limit = 30}) async {
    final list = await getAll();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (list.length > limit) {
      return list.sublist(0, limit);
    }
    return list;
  }

  Future<void> addTranslation(TranslationHistoryEntity item) async {
    await insertOne(item);
  }
}
