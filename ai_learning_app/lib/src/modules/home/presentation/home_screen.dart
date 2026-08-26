import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';
import 'package:ai_learning_app/generated/l10n.dart';
import 'package:ai_learning_app/src/common/constants/api_constants.dart';
import 'package:ai_learning_app/src/common/theme/color_manager.dart';
import 'package:ai_learning_app/src/common/utils/service_locator.dart';
import 'package:ai_learning_app/src/common/widgets/dictionary_bottom_sheet.dart';
import 'package:ai_learning_app/src/core/application/language_provider.dart';
import 'package:ai_learning_app/src/core/application/theme_provider.dart';
import 'package:ai_learning_app/src/core/infrastructure/network/http_compat.dart' as http;
import 'package:ai_learning_app/src/modules/app/router/app_router.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/data/models/question_model.dart';
import 'widgets/game_mode_dialog.dart';
import 'widgets/study_material_card.dart';
import 'widgets/translation_card.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  final String? major;

  const HomeScreen({
    super.key,
    required this.username,
    this.major,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String apiUrl = "${ApiConstants.lessons}/upload";

  final GoogleTranslator _translator = GoogleTranslator();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  Timer? _debounce;

  final FlutterTts _flutterTts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );
  final ImagePicker _picker = ImagePicker();
  bool _isListening = false;

  late String sourceLangName;
  late String targetLangName;
  String sourceLangCode = "en";
  String targetLangCode = "vi";

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _inputController.dispose();
    _outputController.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  void _onInputTextChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      if (text.trim().isEmpty) {
        setState(() => _outputController.text = "");
        return;
      }
      try {
        var translation = await _translator.translate(
          text,
          from: sourceLangCode,
          to: targetLangCode,
        );
        setState(() {
          _outputController.text = translation.text;
        });
      } catch (e) {
        setState(
          () => _outputController.text = S.of(context, 'translation_error'),
        );
      }
    });
  }

  Future<void> _speakTranslation() async {
    if (_outputController.text.isNotEmpty) {
      await _flutterTts.setLanguage(targetLangCode == 'vi' ? 'vi-VN' : 'en-US');
      await _flutterTts.speak(_outputController.text);
    }
  }

  void _listenToSpeech() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          localeId: sourceLangCode == 'vi' ? 'vi_VN' : 'en_US',
          onResult: (val) => setState(() {
            _inputController.text = val.recognizedWords;
            _onInputTextChanged(val.recognizedWords);
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speechToText.stop();
    }
  }

  Future<void> _processImageForText(ImageSource source) async {
    Navigator.pop(context);

    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;

    final inputImage = InputImage.fromFilePath(image.path);
    final RecognizedText recognizedText = await _textRecognizer.processImage(
      inputImage,
    );

    setState(() {
      _inputController.text = recognizedText.text;
    });
    _onInputTextChanged(recognizedText.text);
  }

  Future<void> _handleSearchSubmit(String text) async {
    String searchWord = text.trim();
    if (searchWord.isEmpty) return;

    try {
      Map<String, dynamic>? wordData = await ServiceLocator.dictionaryService
          .lookupWordOffline(searchWord);

      if (mounted) {
        if (wordData != null) {
          DictionaryBottomSheet.show(context, wordData, searchWord);
          _searchController.clear();
        } else {
          Map<String, dynamic> emptyData = {
            "word": searchWord,
            "meaning": S.of(context, 'ai_analyzing'),
          };
          DictionaryBottomSheet.show(context, emptyData, searchWord);
          _searchController.clear();
        }
      }
    } catch (e) {
      if (mounted) _showError(context, "${S.of(context, 'dict_error')}: $e");
    }
  }

  void _swapLanguage() {
    setState(() {
      String tempName = sourceLangName;
      sourceLangName = targetLangName;
      targetLangName = tempName;

      String tempCode = sourceLangCode;
      sourceLangCode = targetLangCode;
      targetLangCode = tempCode;

      String tempText = _inputController.text;
      _inputController.text = _outputController.text;
      _outputController.text = tempText;
    });
    if (_inputController.text.isNotEmpty) {
      _onInputTextChanged(_inputController.text);
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: ColorManager.primaryGreen),
              title: Text(S.of(context, 'take_new_photo')),
              onTap: () => _processImageForText(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: ColorManager.primaryGreen,
              ),
              title: Text(S.of(context, 'choose_from_gallery')),
              onTap: () => _processImageForText(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickPDFAndChooseGame(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      if (context.mounted) {
        GameModeDialog.show(context, file, (ctx, f, type) {
          uploadFileAndGetQuiz(context, f, type);
        });
      }
    }
  }

  Future<void> uploadFileAndGetQuiz(
    BuildContext context,
    File file,
    String quizType,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Colors.green),
                const SizedBox(height: 15),
                Text(
                  S.of(context, 'ai_preparing'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      request.fields['quizType'] = quizType;
      request.fields['username'] = widget.username;

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (context.mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        var jsonResult = jsonDecode(utf8.decode(response.bodyBytes));
        int lessonId = jsonResult['id'] ?? 0;
        List<dynamic> questionsJson = jsonResult['questions'] ?? [];

        if (questionsJson.isNotEmpty && context.mounted) {
          List<QuestionModel> generatedQuestions = questionsJson
              .map((q) => QuestionModel.fromJson(q))
              .toList();
          String route;
          if (quizType == "drag_drop") {
            route = AppRoutes.dragDropQuiz;
          } else if (quizType == "multiple_choice") {
            route = AppRoutes.multipleChoiceQuiz;
          } else {
            route = AppRoutes.fillBlankQuiz;
          }
          context.push(
            route,
            extra: {
              'questions': generatedQuestions,
              'lessonId': lessonId,
            },
          );
        }
      } else {
        if (context.mounted) {
          _showError(context, "Lỗi server: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        _showError(context, "Lỗi kết nối: $e");
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final langProvider = LanguageProvider.safeOf(context);
    final S s = S(langProvider.languageCode);

    sourceLangName = sourceLangCode == 'en'
        ? s.translate('english_lang')
        : s.translate('vietnamese_lang');
    targetLangName = targetLangCode == 'en'
        ? s.translate('english_lang')
        : s.translate('vietnamese_lang');

    final Color textColor = isDarkMode ? ColorManager.darkTextPrimary : ColorManager.lightTextPrimary;
    final Color cardWhite = isDarkMode ? ColorManager.darkCard : ColorManager.lightCard;
    const Color primaryGreen = ColorManager.primaryGreen;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'AI Learning App',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: primaryGreen,
                    ),
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: const NetworkImage(
                      "https://i.pravatar.cc/150?img=11",
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: cardWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black26
                        : primaryGreen.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onSubmitted: _handleSearchSubmit,
                style: TextStyle(color: textColor, fontSize: 16),
                decoration: InputDecoration(
                  hintText: s.translate('search_hint'),
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: primaryGreen,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    TranslationCard(
                      title: sourceLangName,
                      controller: _inputController,
                      hint: s.translate('enter_text'),
                      isInput: true,
                      cardColor: cardWhite,
                      textColor: textColor,
                      isDarkMode: isDarkMode,
                      isListening: _isListening,
                      onListen: _listenToSpeech,
                      onCamera: () => _showImageSourceActionSheet(context),
                      onChanged: _onInputTextChanged,
                    ),
                    const SizedBox(height: 15),
                    TranslationCard(
                      title: targetLangName,
                      controller: _outputController,
                      hint: s.translate('translation_result'),
                      isInput: false,
                      cardColor: isDarkMode
                          ? ColorManager.darkInputBg
                          : const Color(0xFFE8F3ED),
                      textColor: textColor,
                      isDarkMode: isDarkMode,
                      onSpeak: _speakTranslation,
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode
                            ? Colors.black54
                            : primaryGreen.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _swapLanguage,
                    icon: const Icon(
                      Icons.swap_vert,
                      color: primaryGreen,
                      size: 28,
                    ),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 35),
            if (widget.major != null) ...[
              Text(
                "Lộ trình học tập",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () {
                  context.push(
                    AppRoutes.roadmap,
                    extra: {
                      'major': widget.major!,
                      'username': widget.username,
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F8A50), Color(0xFF18C070)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFF0F8A50,
                        ).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.map_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.major!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Tiếp tục hành trình học tập của bạn",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 35),
            ],
            Text(
              s.translate('study_materials'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              s.translate('study_materials_desc'),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 15),
            StudyMaterialCard(
              onTap: () => pickPDFAndChooseGame(context),
              isDarkMode: isDarkMode,
              textColor: textColor,
            ),
            const SizedBox(height: 35),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? ColorManager.darkCard
                    : const Color(0xFFE4EEE8),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBBE5CE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      s.translate('new_feature'),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF17633D),
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    s.translate('vocabulary_garden_title'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    s.translate('vocabulary_garden_desc'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.push(AppRoutes.vocabularyGarden);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      s.translate('explore_now'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      "https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?q=80&w=400&auto=format&fit=crop",
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
