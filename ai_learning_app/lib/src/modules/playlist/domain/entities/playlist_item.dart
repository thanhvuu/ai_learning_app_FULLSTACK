class PlaylistItem {
  final int id;
  final String title;
  final String description;
  final String quizType;
  final int questionCount;
  final DateTime createdAt;

  const PlaylistItem({
    required this.id,
    required this.title,
    required this.description,
    required this.quizType,
    required this.questionCount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'quizType': quizType,
      'questionCount': questionCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PlaylistItem.fromMap(Map<String, dynamic> map) {
    return PlaylistItem(
      id: (map['id'] as num?)?.toInt() ?? 0,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      quizType: map['quizType']?.toString() ?? 'multiple_choice',
      questionCount: (map['questionCount'] as num?)?.toInt() ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
