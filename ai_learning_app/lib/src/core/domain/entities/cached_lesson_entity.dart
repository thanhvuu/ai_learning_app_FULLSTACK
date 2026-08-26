import 'package:hive/hive.dart';
import 'base_entity.dart';

part 'cached_lesson_entity.g.dart';

@HiveType(typeId: 3)
class CachedLessonEntity extends BaseEntity {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  final String topic;

  @HiveField(2)
  final String major;

  @HiveField(3)
  final String content;

  @HiveField(4)
  final String quizType;

  @HiveField(5)
  final List<Map<dynamic, dynamic>> vocabularies;

  @HiveField(6)
  final List<Map<dynamic, dynamic>> questions;

  @HiveField(7)
  final double progress;

  @HiveField(8)
  final bool isCompleted;

  @HiveField(9)
  final int createdAt;

  const CachedLessonEntity({
    required this.id,
    required this.topic,
    required this.major,
    required this.content,
    required this.quizType,
    required this.vocabularies,
    required this.questions,
    this.progress = 0.0,
    this.isCompleted = false,
    required this.createdAt,
  });

  CachedLessonEntity copyWith({
    String? id,
    String? topic,
    String? major,
    String? content,
    String? quizType,
    List<Map<dynamic, dynamic>>? vocabularies,
    List<Map<dynamic, dynamic>>? questions,
    double? progress,
    bool? isCompleted,
    int? createdAt,
  }) {
    return CachedLessonEntity(
      id: id ?? this.id,
      topic: topic ?? this.topic,
      major: major ?? this.major,
      content: content ?? this.content,
      quizType: quizType ?? this.quizType,
      vocabularies: vocabularies ?? this.vocabularies,
      questions: questions ?? this.questions,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topic': topic,
      'major': major,
      'content': content,
      'quizType': quizType,
      'vocabularies': vocabularies,
      'questions': questions,
      'progress': progress,
      'isCompleted': isCompleted,
      'createdAt': createdAt,
    };
  }

  factory CachedLessonEntity.fromJson(Map<String, dynamic> json) {
    return CachedLessonEntity(
      id: json['id']?.toString() ?? '',
      topic: json['topic']?.toString() ?? '',
      major: json['major']?.toString() ?? json['category']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      quizType: json['quizType']?.toString() ?? 'multiple_choice',
      vocabularies: (json['vocabularies'] as List<dynamic>?)
              ?.map((e) => e is Map ? Map<dynamic, dynamic>.from(e) : <dynamic, dynamic>{})
              .toList() ??
          [],
      questions: (json['questions'] as List<dynamic>?)
              ?.map((e) => e is Map ? Map<dynamic, dynamic>.from(e) : <dynamic, dynamic>{})
              .toList() ??
          [],
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['isCompleted'] == true || json['is_completed'] == 1,
      createdAt: (json['createdAt'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}
