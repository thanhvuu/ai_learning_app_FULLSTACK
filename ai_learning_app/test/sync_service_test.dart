import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:ai_learning_app/src/core/domain/app_exception.dart';
import 'package:ai_learning_app/src/core/domain/entities/sync_queue_entity.dart';
import 'package:ai_learning_app/src/core/domain/result.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/sync_queue_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/database_service.dart';
import 'package:ai_learning_app/src/core/infrastructure/network/api_client.dart';
import 'package:ai_learning_app/src/core/infrastructure/sync/sync_service.dart';

class FakeApiClient extends ApiClient {
  bool shouldSucceed = true;
  final List<String> calledPaths = [];

  @override
  Future<Result<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
  }) async {
    calledPaths.add(path);
    return shouldSucceed
        ? const Result.success({'status': 'ok'})
        : const Result.failure(ServerException('Failed', statusCode: 500));
  }

  @override
  Future<Result<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
  }) async {
    calledPaths.add(path);
    return shouldSucceed
        ? const Result.success({'status': 'ok'})
        : const Result.failure(ServerException('Failed', statusCode: 500));
  }
}

class FakeConnectivity implements Connectivity {
  final _controller = StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _controller.stream;

  void emit(List<ConnectivityResult> results) {
    _controller.add(results);
  }

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return [ConnectivityResult.wifi];
  }
}

void main() {
  late Directory tempDir;
  late SyncQueueDao syncQueueDao;
  late FakeApiClient fakeApiClient;
  late FakeConnectivity fakeConnectivity;
  late SyncService syncService;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('sync_service_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(SyncQueueEntityAdapter());
    }
    await Hive.openBox<SyncQueueEntity>(DatabaseService.syncQueueBox);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  setUp(() async {
    await Hive.box<SyncQueueEntity>(DatabaseService.syncQueueBox).clear();
    syncQueueDao = SyncQueueDao();
    fakeApiClient = FakeApiClient();
    fakeConnectivity = FakeConnectivity();
    syncService = SyncService(
      syncQueueDao: syncQueueDao,
      apiClient: fakeApiClient,
      connectivity: fakeConnectivity,
    );
  });

  tearDown(() {
    syncService.dispose();
  });

  group('SyncService Tests', () {
    test('syncPendingActions returns 0 when queue is empty', () async {
      final count = await syncService.syncPendingActions();
      expect(count, 0);
      expect(fakeApiClient.calledPaths, isEmpty);
    });

    test('syncPendingActions executes actions and clears queue on success', () async {
      await syncQueueDao.enqueueAction(
        actionType: 'UPDATE_PROGRESS',
        payload: {'username': 'student1'},
      );
      await syncQueueDao.enqueueAction(
        actionType: 'UPDATE_LESSON_PROGRESS',
        payload: {'lessonId': 'les_1', 'progress': 100},
      );
      await syncQueueDao.enqueueAction(
        actionType: 'ADD_TIME',
        payload: {'username': 'student1', 'minutes': 5},
      );
      await syncQueueDao.enqueueAction(
        actionType: 'UPDATE_PLANTS',
        payload: {'username': 'student1', 'plants': 3},
      );

      final count = await syncService.syncPendingActions();
      expect(count, 4);

      final remaining = await syncQueueDao.getPendingActions();
      expect(remaining, isEmpty);

      expect(fakeApiClient.calledPaths, containsAll([
        '/api/users/update-progress',
        '/api/lessons/update-progress',
        '/api/progress/add-time',
        '/api/users/update-plants',
      ]));
    });

    test('syncPendingActions increments retryCount on failure', () async {
      fakeApiClient.shouldSucceed = false;

      await syncQueueDao.enqueueAction(
        actionType: 'UPDATE_PROGRESS',
        payload: {'username': 'student1'},
      );

      final count = await syncService.syncPendingActions();
      expect(count, 0);

      final pending = await syncQueueDao.getPendingActions();
      expect(pending.length, 1);
      expect(pending.first.retryCount, 1);
    });

    test('syncPendingActions drops action when retryCount reaches 5', () async {
      fakeApiClient.shouldSucceed = false;

      await syncQueueDao.insertOne(
        const SyncQueueEntity(
          id: 'action_max_retries',
          actionType: 'UPDATE_PROGRESS',
          payloadJson: '{"username":"student1"}',
          createdAt: 1000,
          retryCount: 5,
        ),
      );

      final count = await syncService.syncPendingActions();
      expect(count, 0);

      final pending = await syncQueueDao.getPendingActions();
      expect(pending, isEmpty);
    });

    test('init triggers sync when connectivity changes to online', () async {
      await syncQueueDao.enqueueAction(
        actionType: 'ADD_TIME',
        payload: {'username': 'student1', 'minutes': 10},
      );

      syncService.init();

      // Emit disconnected
      fakeConnectivity.emit([ConnectivityResult.none]);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(await syncQueueDao.getPendingActions(), isNotEmpty);

      // Emit connected
      fakeConnectivity.emit([ConnectivityResult.wifi]);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(await syncQueueDao.getPendingActions(), isEmpty);
      expect(fakeApiClient.calledPaths, contains('/api/progress/add-time'));
    });
  });
}
