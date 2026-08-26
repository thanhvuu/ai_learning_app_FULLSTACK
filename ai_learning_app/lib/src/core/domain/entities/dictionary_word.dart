class DictionaryWord {
  final String word;
  final String? phonetic;
  final String meaning;
  final int level;
  final int lastReviewed;

  const DictionaryWord({
    required this.word,
    this.phonetic,
    required this.meaning,
    this.level = 0,
    this.lastReviewed = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'phonetic': phonetic,
      'meaning': meaning,
      'level': level,
      'last_reviewed': lastReviewed,
    };
  }

  factory DictionaryWord.fromMap(Map<String, dynamic> map) {
    return DictionaryWord(
      word: map['word']?.toString() ?? '',
      phonetic: map['pronounce']?.toString() ?? map['phonetic']?.toString(),
      meaning: map['description']?.toString() ?? map['meaning']?.toString() ?? '',
      level: (map['level'] as num?)?.toInt() ?? 0,
      lastReviewed: (map['last_reviewed'] as num?)?.toInt() ?? 0,
    );
  }
}
