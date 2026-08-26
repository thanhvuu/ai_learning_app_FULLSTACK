// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_queue_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyncQueueEntityAdapter extends TypeAdapter<SyncQueueEntity> {
  @override
  final int typeId = 5;

  @override
  SyncQueueEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncQueueEntity(
      id: fields[0] as String,
      actionType: fields[1] as String,
      payloadJson: fields[2] as String,
      createdAt: fields[3] as int,
      retryCount: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SyncQueueEntity obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.actionType)
      ..writeByte(2)
      ..write(obj.payloadJson)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.retryCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncQueueEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
