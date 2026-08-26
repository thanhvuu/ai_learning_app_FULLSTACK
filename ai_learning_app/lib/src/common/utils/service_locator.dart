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

  static final DictionaryDao dictionaryDao = SqfliteDictionaryDao();
  static final IDictionaryService dictionaryService = DictionaryServiceImpl(
    dictionaryDao: dictionaryDao,
  );
  static final ApiClient apiClient = ApiClient();
  static final LeaderboardRemoteDataSource leaderboardRemoteDataSource =
      LeaderboardRemoteDataSourceImpl(apiClient);
  static final LeaderboardRepository leaderboardRepository =
      LeaderboardRepositoryImpl(leaderboardRemoteDataSource);
  static final GetLeaderboard getLeaderboard =
      GetLeaderboard(leaderboardRepository);

  static Future<void> init() async {
    // Place for any pre-run async setup if needed
  }
}
