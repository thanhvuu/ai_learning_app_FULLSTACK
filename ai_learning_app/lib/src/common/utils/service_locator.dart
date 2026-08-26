import 'package:ai_learning_app/src/core/infrastructure/databases/hive/database_service.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/cached_lesson_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/saved_word_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/sync_queue_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/translation_history_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/user_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/interfaces/dictionary_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/sqflite_dictionary_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/network/api_client.dart';
import 'package:ai_learning_app/src/core/infrastructure/repositories/dictionary_repository_impl.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/data/datasources/leaderboard_remote_data_source.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/data/repositories/leaderboard_repository_impl.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/domain/repositories/leaderboard_repository.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/domain/usecases/get_leaderboard.dart';

class ServiceLocator {
  ServiceLocator._();

  // Hive Database Service & DAOs
  static final DatabaseService databaseService = DatabaseService.instance;
  static final UserDao userDao = UserDao();
  static final SavedWordDao savedWordDao = SavedWordDao();
  static final CachedLessonDao cachedLessonDao = CachedLessonDao();
  static final TranslationHistoryDao translationHistoryDao = TranslationHistoryDao();
  static final SyncQueueDao syncQueueDao = SyncQueueDao();

  // Legacy/SQLite DAOs & Services
  static final DictionaryDao dictionaryDao = SqfliteDictionaryDao();
  static final IDictionaryService dictionaryService = DictionaryServiceImpl(
    dictionaryDao: dictionaryDao,
  );

  // Network & Feature UseCases
  static final ApiClient apiClient = ApiClient();
  static final LeaderboardRemoteDataSource leaderboardRemoteDataSource =
      LeaderboardRemoteDataSourceImpl(apiClient);
  static final LeaderboardRepository leaderboardRepository =
      LeaderboardRepositoryImpl(leaderboardRemoteDataSource);
  static final GetLeaderboard getLeaderboard =
      GetLeaderboard(leaderboardRepository);

  static Future<void> init() async {
    await databaseService.initialize();
  }
}
