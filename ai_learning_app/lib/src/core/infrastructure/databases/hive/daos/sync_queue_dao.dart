import 'dart:convert';
import 'package:ai_learning_app/src/core/domain/entities/sync_queue_entity.dart';
import '../base_dao.dart';
import '../database_service.dart';

class SyncQueueDao extends BaseDao<SyncQueueEntity> {
  SyncQueueDao() : super(DatabaseService.syncQueueBox);

  Future<List<SyncQueueEntity>> getPendingActions() async {
    final list = await getAll();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  Future<void> enqueueAction({
    required String actionType,
    required Map<String, dynamic> payload,
  }) async {
    final id = '${actionType}_${DateTime.now().millisecondsSinceEpoch}';
    final entity = SyncQueueEntity(
      id: id,
      actionType: actionType,
      payloadJson: jsonEncode(payload),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await insertOne(entity);
  }

  Future<void> incrementRetry(String actionId) async {
    final action = await getById(actionId);
    if (action != null) {
      await update(action.copyWith(retryCount: action.retryCount + 1));
    }
  }
}
