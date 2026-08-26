// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_history_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TranslationHistoryEntityAdapter
    extends TypeAdapter<TranslationHistoryEntity> {
  @override
  final int typeId = 4;

  @override
  TranslationHistoryEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TranslationHistoryEntity(
      id: fields[0] as String,
      sourceText: fields[1] as String,
      translatedText: fields[2] as String,
      sourceLang: fields[3] as String,
      targetLang: fields[4] as String,
      timestamp: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TranslationHistoryEntity obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sourceText)
      ..writeByte(2)
      ..write(obj.translatedText)
      ..writeByte(3)
      ..write(obj.sourceLang)
      ..writeByte(4)
      ..write(obj.targetLang)
      ..writeByte(5)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslationHistoryEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
