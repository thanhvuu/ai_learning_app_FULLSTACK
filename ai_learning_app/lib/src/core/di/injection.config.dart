// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../modules/explore_lessons/data/datasources/leaderboard_remote_data_source.dart'
    as _i134;
import '../../modules/explore_lessons/data/repositories/leaderboard_repository_impl.dart'
    as _i835;
import '../../modules/explore_lessons/domain/repositories/leaderboard_repository.dart'
    as _i969;
import '../../modules/explore_lessons/domain/usecases/get_leaderboard.dart'
    as _i585;
import '../infrastructure/databases/hive/daos/cached_lesson_dao.dart' as _i213;
import '../infrastructure/databases/hive/daos/saved_word_dao.dart' as _i614;
import '../infrastructure/databases/hive/daos/sync_queue_dao.dart' as _i478;
import '../infrastructure/databases/hive/daos/translation_history_dao.dart'
    as _i730;
import '../infrastructure/databases/hive/daos/user_dao.dart' as _i477;
import '../infrastructure/databases/hive/database_service.dart' as _i936;
import '../infrastructure/databases/interfaces/dictionary_dao.dart' as _i281;
import '../infrastructure/databases/sqflite_dictionary_dao.dart' as _i256;
import '../infrastructure/network/api_client.dart' as _i450;
import '../infrastructure/repositories/dictionary_repository_impl.dart'
    as _i185;
import 'modules/app_module.dart' as _i349;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final appModule = _$AppModule();
    await gh.factoryAsync<_i936.DatabaseService>(
      () => appModule.databaseService,
      preResolve: true,
    );
    gh.lazySingleton<_i361.Dio>(() => appModule.dio);
    gh.lazySingleton<_i213.CachedLessonDao>(() => _i213.CachedLessonDao());
    gh.lazySingleton<_i614.SavedWordDao>(() => _i614.SavedWordDao());
    gh.lazySingleton<_i478.SyncQueueDao>(() => _i478.SyncQueueDao());
    gh.lazySingleton<_i730.TranslationHistoryDao>(
        () => _i730.TranslationHistoryDao());
    gh.lazySingleton<_i477.UserDao>(() => _i477.UserDao());
    gh.lazySingleton<_i281.DictionaryDao>(() => _i256.SqfliteDictionaryDao());
    gh.lazySingleton<_i185.IDictionaryService>(() =>
        _i185.DictionaryServiceImpl(dictionaryDao: gh<_i281.DictionaryDao>()));
    gh.lazySingleton<_i450.ApiClient>(
        () => _i450.ApiClient(dioClient: gh<_i361.Dio>()));
    gh.lazySingleton<_i134.LeaderboardRemoteDataSource>(
        () => _i134.LeaderboardRemoteDataSourceImpl(gh<_i450.ApiClient>()));
    gh.lazySingleton<_i969.LeaderboardRepository>(() =>
        _i835.LeaderboardRepositoryImpl(
            gh<_i134.LeaderboardRemoteDataSource>()));
    gh.factory<_i585.GetLeaderboard>(
        () => _i585.GetLeaderboard(gh<_i969.LeaderboardRepository>()));
    return this;
  }
}

class _$AppModule extends _i349.AppModule {}
