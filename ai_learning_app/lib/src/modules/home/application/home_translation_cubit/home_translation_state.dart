import 'package:equatable/equatable.dart';

class HomeTranslationState extends Equatable {
  final String sourceLangCode;
  final String targetLangCode;
  final String inputText;
  final String outputText;
  final bool isTranslating;
  final bool isListening;
  final String? errorMessage;

  const HomeTranslationState({
    this.sourceLangCode = 'en',
    this.targetLangCode = 'vi',
    this.inputText = '',
    this.outputText = '',
    this.isTranslating = false,
    this.isListening = false,
    this.errorMessage,
  });

  HomeTranslationState copyWith({
    String? sourceLangCode,
    String? targetLangCode,
    String? inputText,
    String? outputText,
    bool? isTranslating,
    bool? isListening,
    String? errorMessage,
  }) {
    return HomeTranslationState(
      sourceLangCode: sourceLangCode ?? this.sourceLangCode,
      targetLangCode: targetLangCode ?? this.targetLangCode,
      inputText: inputText ?? this.inputText,
      outputText: outputText ?? this.outputText,
      isTranslating: isTranslating ?? this.isTranslating,
      isListening: isListening ?? this.isListening,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        sourceLangCode,
        targetLangCode,
        inputText,
        outputText,
        isTranslating,
        isListening,
        errorMessage,
      ];
}
