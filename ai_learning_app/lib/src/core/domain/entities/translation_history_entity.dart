import 'package:hive/hive.dart';
import 'base_entity.dart';

part 'translation_history_entity.g.dart';

@HiveType(typeId: 4)
class TranslationHistoryEntity extends BaseEntity {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  final String sourceText;

  @HiveField(2)
  final String translatedText;

  @HiveField(3)
  final String sourceLang;

  @HiveField(4)
  final String targetLang;

  @HiveField(5)
  final int timestamp;

  const TranslationHistoryEntity({
    required this.id,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
    required this.timestamp,
  });

  TranslationHistoryEntity copyWith({
    String? id,
    String? sourceText,
    String? translatedText,
    String? sourceLang,
    String? targetLang,
    int? timestamp,
  }) {
    return TranslationHistoryEntity(
      id: id ?? this.id,
      sourceText: sourceText ?? this.sourceText,
      translatedText: translatedText ?? this.translatedText,
      sourceLang: sourceLang ?? this.sourceLang,
      targetLang: targetLang ?? this.targetLang,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceText': sourceText,
      'translatedText': translatedText,
      'sourceLang': sourceLang,
      'targetLang': targetLang,
      'timestamp': timestamp,
    };
  }

  factory TranslationHistoryEntity.fromJson(Map<String, dynamic> json) {
    return TranslationHistoryEntity(
      id: json['id']?.toString() ?? '',
      sourceText: json['sourceText']?.toString() ?? '',
      translatedText: json['translatedText']?.toString() ?? '',
      sourceLang: json['sourceLang']?.toString() ?? 'en',
      targetLang: json['targetLang']?.toString() ?? 'vi',
      timestamp: (json['timestamp'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}
