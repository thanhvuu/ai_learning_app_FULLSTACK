import 'package:hive_ce/hive.dart';
import 'base_entity.dart';

part 'sync_queue_entity.g.dart';

@HiveType(typeId: 5)
class SyncQueueEntity extends BaseEntity {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  final String actionType; // 'UPDATE_XP', 'COMPLETE_LESSON', 'UPDATE_MAJOR'

  @HiveField(2)
  final String payloadJson;

  @HiveField(3)
  final int createdAt;

  @HiveField(4)
  final int retryCount;

  const SyncQueueEntity({
    required this.id,
    required this.actionType,
    required this.payloadJson,
    required this.createdAt,
    this.retryCount = 0,
  });

  SyncQueueEntity copyWith({
    String? id,
    String? actionType,
    String? payloadJson,
    int? createdAt,
    int? retryCount,
  }) {
    return SyncQueueEntity(
      id: id ?? this.id,
      actionType: actionType ?? this.actionType,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'actionType': actionType,
      'payloadJson': payloadJson,
      'createdAt': createdAt,
      'retryCount': retryCount,
    };
  }

  factory SyncQueueEntity.fromJson(Map<String, dynamic> json) {
    return SyncQueueEntity(
      id: json['id']?.toString() ?? '',
      actionType: json['actionType']?.toString() ?? '',
      payloadJson: json['payloadJson']?.toString() ?? '{}',
      createdAt: (json['createdAt'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
    );
  }
}
