import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:translator/translator.dart';
import 'package:ai_learning_app/src/modules/home/domain/interfaces/i_translation_service.dart';

class TranslationServiceImpl implements ITranslationService {
  final GoogleTranslator _translator;
  final FlutterTts _flutterTts;
  final TextRecognizer _textRecognizer;

  TranslationServiceImpl({
    GoogleTranslator? translator,
    FlutterTts? flutterTts,
    TextRecognizer? textRecognizer,
  })  : _translator = translator ?? GoogleTranslator(),
        _flutterTts = flutterTts ?? FlutterTts(),
        _textRecognizer = textRecognizer ??
            TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<String> translateText({
    required String text,
    required String from,
    required String to,
  }) async {
    if (text.trim().isEmpty) return "";
    final result = await _translator.translate(text, from: from, to: to);
    return result.text;
  }

  @override
  Future<void> speak({
    required String text,
    required String languageCode,
  }) async {
    if (text.trim().isEmpty) return;
    await _flutterTts.setLanguage(languageCode == 'vi' ? 'vi-VN' : 'en-US');
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  @override
  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }

  @override
  Future<String?> recognizeTextFromImagePath(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
