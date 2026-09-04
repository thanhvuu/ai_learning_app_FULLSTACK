import 'package:ai_learning_app/src/core/di/injection.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/database_service.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/cached_lesson_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/saved_word_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/sync_queue_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/translation_history_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/user_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/interfaces/dictionary_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/network/api_client.dart';
import 'package:ai_learning_app/src/core/infrastructure/repositories/dictionary_repository_impl.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/data/datasources/leaderboard_remote_data_source.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/domain/repositories/leaderboard_repository.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/domain/usecases/get_leaderboard.dart';

class ServiceLocator {
  ServiceLocator._();

  // Hive Database Service & DAOs
  static DatabaseService get databaseService => getIt<DatabaseService>();
  static UserDao get userDao => getIt<UserDao>();
  static SavedWordDao get savedWordDao => getIt<SavedWordDao>();
  static CachedLessonDao get cachedLessonDao => getIt<CachedLessonDao>();
  static TranslationHistoryDao get translationHistoryDao =>
      getIt<TranslationHistoryDao>();
  static SyncQueueDao get syncQueueDao => getIt<SyncQueueDao>();

  // Legacy/SQLite DAOs & Services
  static DictionaryDao get dictionaryDao => getIt<DictionaryDao>();
  static IDictionaryService get dictionaryService =>
      getIt<IDictionaryService>();

  // Network & Feature UseCases
  static ApiClient get apiClient => getIt<ApiClient>();
  static LeaderboardRemoteDataSource get leaderboardRemoteDataSource =>
      getIt<LeaderboardRemoteDataSource>();
  static LeaderboardRepository get leaderboardRepository =>
      getIt<LeaderboardRepository>();
  static GetLeaderboard get getLeaderboard => getIt<GetLeaderboard>();

  static Future<void> init() async {
    await configureDependencies();
  }
}
