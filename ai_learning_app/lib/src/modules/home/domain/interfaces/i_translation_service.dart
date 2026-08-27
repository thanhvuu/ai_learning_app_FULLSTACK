abstract class ITranslationService {
  Future<String> translateText({
    required String text,
    required String from,
    required String to,
  });

  Future<void> speak({
    required String text,
    required String languageCode,
  });

  Future<void> stopSpeaking();

  Future<String?> recognizeTextFromImagePath(String imagePath);
}
