import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ai_learning_app/src/common/utils/service_locator.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('injection_test_');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (methodCall) async => tempDir.path,
    );

    await configureDependencies();
  });

  tearDownAll(() async {
    await getIt.reset();
    await Hive.close();
    try {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  group('Injectable & ServiceLocator Integration Tests', () {
    test('getIt resolves core singletons and factories', () {
      expect(getIt<DatabaseService>(), isNotNull);
      expect(getIt<ApiClient>(), isNotNull);
      expect(getIt<DictionaryDao>(), isNotNull);
      expect(getIt<IDictionaryService>(), isNotNull);
      expect(getIt<LeaderboardRemoteDataSource>(), isNotNull);
      expect(getIt<LeaderboardRepository>(), isNotNull);
      expect(getIt<GetLeaderboard>(), isNotNull);
    });

    test('ServiceLocator facade delegates correctly to getIt', () {
      expect(ServiceLocator.databaseService, equals(getIt<DatabaseService>()));
      expect(ServiceLocator.userDao, equals(getIt<UserDao>()));
      expect(ServiceLocator.savedWordDao, equals(getIt<SavedWordDao>()));
      expect(ServiceLocator.cachedLessonDao, equals(getIt<CachedLessonDao>()));
      expect(ServiceLocator.translationHistoryDao, equals(getIt<TranslationHistoryDao>()));
      expect(ServiceLocator.syncQueueDao, equals(getIt<SyncQueueDao>()));
      expect(ServiceLocator.dictionaryDao, equals(getIt<DictionaryDao>()));
      expect(ServiceLocator.dictionaryService, equals(getIt<IDictionaryService>()));
      expect(ServiceLocator.apiClient, equals(getIt<ApiClient>()));
      expect(ServiceLocator.leaderboardRemoteDataSource, equals(getIt<LeaderboardRemoteDataSource>()));
      expect(ServiceLocator.leaderboardRepository, equals(getIt<LeaderboardRepository>()));
      expect(ServiceLocator.getLeaderboard, isA<GetLeaderboard>());
    });
  });
}
