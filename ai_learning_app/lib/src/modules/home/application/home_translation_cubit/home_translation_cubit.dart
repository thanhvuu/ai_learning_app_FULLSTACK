import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_learning_app/src/core/domain/entities/translation_history_entity.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/translation_history_dao.dart';
import 'package:ai_learning_app/src/modules/home/domain/interfaces/i_translation_service.dart';
import 'home_translation_state.dart';

class HomeTranslationCubit extends Cubit<HomeTranslationState> {
  final ITranslationService _translationService;
  final TranslationHistoryDao _historyDao;
  Timer? _debounce;

  HomeTranslationCubit({
    required ITranslationService translationService,
    required TranslationHistoryDao historyDao,
  })  : _translationService = translationService,
        _historyDao = historyDao,
        super(const HomeTranslationState());

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  void onInputChanged(String text) {
    emit(state.copyWith(inputText: text));
    _debounce?.cancel();

    if (text.trim().isEmpty) {
      emit(state.copyWith(outputText: '', isTranslating: false));
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 600), () {
      translate();
    });
  }

  Future<void> translate() async {
    if (state.inputText.trim().isEmpty) return;

    emit(state.copyWith(isTranslating: true, errorMessage: null));
    try {
      final translated = await _translationService.translateText(
        text: state.inputText,
        from: state.sourceLangCode,
        to: state.targetLangCode,
      );

      emit(state.copyWith(
        outputText: translated,
        isTranslating: false,
      ));

      // Lưu lịch sử dịch tự động
      await _historyDao.addTranslation(
        TranslationHistoryEntity(
          id: '${DateTime.now().millisecondsSinceEpoch}',
          sourceText: state.inputText.trim(),
          translatedText: translated.trim(),
          sourceLang: state.sourceLangCode,
          targetLang: state.targetLangCode,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } catch (e) {
      emit(state.copyWith(
        isTranslating: false,
        errorMessage: 'Lỗi dịch thuật: $e',
      ));
    }
  }

  void swapLanguages() {
    final newSource = state.targetLangCode;
    final newTarget = state.sourceLangCode;
    final newOutput = state.inputText;
    final newInput = state.outputText;

    emit(state.copyWith(
      sourceLangCode: newSource,
      targetLangCode: newTarget,
      inputText: newInput,
      outputText: newOutput,
    ));

    if (newInput.isNotEmpty) {
      translate();
    }
  }

  Future<void> speakSource() async {
    await _translationService.speak(
      text: state.inputText,
      languageCode: state.sourceLangCode,
    );
  }

  Future<void> speakTranslation() async {
    await _translationService.speak(
      text: state.outputText,
      languageCode: state.targetLangCode,
    );
  }

  void setListening(bool isListening) {
    emit(state.copyWith(isListening: isListening));
  }

  Future<void> processImageForText(String imagePath) async {
    emit(state.copyWith(isTranslating: true));
    final text = await _translationService.recognizeTextFromImagePath(imagePath);
    if (text != null && text.trim().isNotEmpty) {
      emit(state.copyWith(inputText: text));
      translate();
    } else {
      emit(state.copyWith(
        isTranslating: false,
        errorMessage: 'Không tìm thấy chữ trong hình ảnh',
      ));
    }
  }
}
