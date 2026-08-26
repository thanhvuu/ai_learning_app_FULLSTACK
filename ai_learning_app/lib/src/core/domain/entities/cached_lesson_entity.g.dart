// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_lesson_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedLessonEntityAdapter extends TypeAdapter<CachedLessonEntity> {
  @override
  final int typeId = 3;

  @override
  CachedLessonEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedLessonEntity(
      id: fields[0] as String,
      topic: fields[1] as String,
      major: fields[2] as String,
      content: fields[3] as String,
      quizType: fields[4] as String,
      vocabularies: (fields[5] as List)
          .map((dynamic e) => (e as Map).cast<dynamic, dynamic>())
          .toList(),
      questions: (fields[6] as List)
          .map((dynamic e) => (e as Map).cast<dynamic, dynamic>())
          .toList(),
      progress: fields[7] as double,
      isCompleted: fields[8] as bool,
      createdAt: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CachedLessonEntity obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.topic)
      ..writeByte(2)
      ..write(obj.major)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.quizType)
      ..writeByte(5)
      ..write(obj.vocabularies)
      ..writeByte(6)
      ..write(obj.questions)
      ..writeByte(7)
      ..write(obj.progress)
      ..writeByte(8)
      ..write(obj.isCompleted)
      ..writeByte(9)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedLessonEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
