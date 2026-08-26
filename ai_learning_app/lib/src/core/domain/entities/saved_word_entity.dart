import 'package:hive/hive.dart';
import 'base_entity.dart';

part 'saved_word_entity.g.dart';

@HiveType(typeId: 2)
class SavedWordEntity extends BaseEntity {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  final String word;

  @HiveField(2)
  final String? phonetic;

  @HiveField(3)
  final String meaning;

  @HiveField(4)
  final String? example;

  @HiveField(5)
  final int level;

  @HiveField(6)
  final int lastReviewed;

  const SavedWordEntity({
    required this.id,
    required this.word,
    this.phonetic,
    required this.meaning,
    this.example,
    this.level = 0,
    this.lastReviewed = 0,
  });

  SavedWordEntity copyWith({
    String? id,
    String? word,
    String? phonetic,
    String? meaning,
    String? example,
    int? level,
    int? lastReviewed,
  }) {
    return SavedWordEntity(
      id: id ?? this.id,
      word: word ?? this.word,
      phonetic: phonetic ?? this.phonetic,
      meaning: meaning ?? this.meaning,
      example: example ?? this.example,
      level: level ?? this.level,
      lastReviewed: lastReviewed ?? this.lastReviewed,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'phonetic': phonetic,
      'meaning': meaning,
      'example': example,
      'level': level,
      'last_reviewed': lastReviewed,
    };
  }

  factory SavedWordEntity.fromJson(Map<String, dynamic> json) {
    return SavedWordEntity(
      id: json['id']?.toString() ?? json['word']?.toString() ?? '',
      word: json['word']?.toString() ?? '',
      phonetic: json['phonetic']?.toString() ?? json['pronounce']?.toString(),
      meaning: json['meaning']?.toString() ?? json['description']?.toString() ?? '',
      example: json['example']?.toString(),
      level: (json['level'] as num?)?.toInt() ?? 0,
      lastReviewed: (json['last_reviewed'] as num?)?.toInt() ??
          (json['lastReviewed'] as num?)?.toInt() ??
          0,
    );
  }
}
