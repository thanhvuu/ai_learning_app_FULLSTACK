import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/sync_queue_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/network/api_client.dart';

@lazySingleton
class SyncService {
  final SyncQueueDao _syncQueueDao;
  final ApiClient _apiClient;
  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isSyncing = false;

  SyncService({
    required SyncQueueDao syncQueueDao,
    required ApiClient apiClient,
    Connectivity? connectivity,
  })  : _syncQueueDao = syncQueueDao,
        _apiClient = apiClient,
        _connectivity = connectivity ?? Connectivity();

  void init() {
    _subscription?.cancel();
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection) {
        syncPendingActions();
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<int> syncPendingActions() async {
    if (_isSyncing) return 0;
    _isSyncing = true;
    int syncedCount = 0;

    try {
      final pendingActions = await _syncQueueDao.getPendingActions();
      if (pendingActions.isEmpty) {
        return 0;
      }

      debugPrint('[SyncService] Found ${pendingActions.length} pending action(s) to sync');

      for (final action in pendingActions) {
        if (action.retryCount >= 5) {
          debugPrint('[SyncService] Dropping action ${action.id} due to excessive retries');
          await _syncQueueDao.delete(action.id);
          continue;
        }

        try {
          final payload = jsonDecode(action.payloadJson) as Map<String, dynamic>;
          final success = await _executeAction(action.actionType, payload);

          if (success) {
            debugPrint('[SyncService] Synced action ${action.id} successfully');
            await _syncQueueDao.delete(action.id);
            syncedCount++;
          } else {
            debugPrint('[SyncService] Failed to sync action ${action.id}, incrementing retry');
            await _syncQueueDao.incrementRetry(action.id);
          }
        } catch (e) {
          debugPrint('[SyncService] Error executing action ${action.id}: $e');
          await _syncQueueDao.incrementRetry(action.id);
        }
      }
      return syncedCount;
    } finally {
      _isSyncing = false;
    }
  }

  Future<bool> _executeAction(String actionType, Map<String, dynamic> payload) async {
    switch (actionType) {
      case 'UPDATE_PROGRESS':
        final username = payload['username'] as String?;
        if (username == null || username.isEmpty) return true;
        final result = await _apiClient.put(
          '/api/users/update-progress',
          queryParameters: {'username': username},
        );
        return result.when(success: (_) => true, failure: (_) => false);

      case 'UPDATE_LESSON_PROGRESS':
        final lessonId = payload['lessonId'];
        final progress = payload['progress'] ?? 100;
        final result = await _apiClient.post(
          '/api/lessons/update-progress',
          data: {'lessonId': lessonId, 'progress': progress},
        );
        return result.when(success: (_) => true, failure: (_) => false);

      case 'ADD_TIME':
        final username = payload['username'] as String?;
        final minutes = payload['minutes'] ?? 5;
        final result = await _apiClient.post(
          '/api/progress/add-time',
          data: {'username': username, 'minutes': minutes},
        );
        return result.when(success: (_) => true, failure: (_) => false);

      case 'UPDATE_PLANTS':
        final username = payload['username'] as String?;
        final plants = payload['plants'] ?? 0;
        final result = await _apiClient.post(
          '/api/users/update-plants',
          queryParameters: {'username': username, 'plants': plants},
        );
        return result.when(success: (_) => true, failure: (_) => false);

      default:
        debugPrint('[SyncService] Unknown action type: $actionType');
        return true;
    }
  }
}
