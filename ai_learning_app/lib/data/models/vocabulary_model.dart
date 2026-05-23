class VocabularyModel {
  final String word;
  final String phonetic;
  final String meaning;
  final String example;

  VocabularyModel({
    required this.word,
    required this.phonetic,
    required this.meaning,
    required this.example,
  });

  factory VocabularyModel.fromJson(Map<String, dynamic> json) {
    return VocabularyModel(
      word: json['word'] ?? "",
      phonetic: json['phonetic'] ?? "",
      meaning: json['meaning'] ?? "",
      example: json['example'] ?? "",
    );
  }
}
