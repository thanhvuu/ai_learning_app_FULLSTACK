import 'package:equatable/equatable.dart';

class DictionaryState extends Equatable {
  final Map<String, dynamic> wordData;
  final bool isLoadingAI;
  final bool isSaved;
  final String? errorMessage;

  const DictionaryState({
    required this.wordData,
    this.isLoadingAI = true,
    this.isSaved = false,
    this.errorMessage,
  });

  DictionaryState copyWith({
    Map<String, dynamic>? wordData,
    bool? isLoadingAI,
    bool? isSaved,
    String? errorMessage,
  }) {
    return DictionaryState(
      wordData: wordData ?? this.wordData,
      isLoadingAI: isLoadingAI ?? this.isLoadingAI,
      isSaved: isSaved ?? this.isSaved,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [wordData, isLoadingAI, isSaved, errorMessage];
}
