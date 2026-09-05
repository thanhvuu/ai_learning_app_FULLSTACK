// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_word_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedWordEntityAdapter extends TypeAdapter<SavedWordEntity> {
  @override
  final int typeId = 2;

  @override
  SavedWordEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedWordEntity(
      id: fields[0] as String,
      word: fields[1] as String,
      phonetic: fields[2] as String?,
      meaning: fields[3] as String,
      example: fields[4] as String?,
      level: (fields[5] as num).toInt(),
      lastReviewed: (fields[6] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, SavedWordEntity obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.word)
      ..writeByte(2)
      ..write(obj.phonetic)
      ..writeByte(3)
      ..write(obj.meaning)
      ..writeByte(4)
      ..write(obj.example)
      ..writeByte(5)
      ..write(obj.level)
      ..writeByte(6)
      ..write(obj.lastReviewed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedWordEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
