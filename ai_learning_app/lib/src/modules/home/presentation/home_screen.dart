import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:ai_learning_app/generated/l10n.dart';
import 'package:ai_learning_app/src/common/extensions/build_context_ext.dart';
import 'package:ai_learning_app/src/common/theme/color_manager.dart';
import 'package:ai_learning_app/src/common/utils/service_locator.dart';
import 'package:ai_learning_app/src/common/widgets/dictionary_bottom_sheet.dart';
import 'package:ai_learning_app/src/core/application/language/language_cubit.dart';
import 'package:ai_learning_app/src/core/application/theme/theme_cubit.dart';
import 'package:ai_learning_app/src/modules/app/router/app_router.dart';
import 'package:ai_learning_app/src/modules/home/application/home_translation_cubit/home_translation_cubit.dart';
import 'package:ai_learning_app/src/modules/home/application/home_translation_cubit/home_translation_state.dart';
import 'package:ai_learning_app/src/modules/home/application/study_material_cubit/study_material_cubit.dart';
import 'package:ai_learning_app/src/modules/home/application/study_material_cubit/study_material_state.dart';
import 'package:ai_learning_app/src/modules/home/infrastructure/repositories/study_material_repository_impl.dart';
import 'package:ai_learning_app/src/modules/home/infrastructure/services/translation_service_impl.dart';
import 'widgets/game_mode_dialog.dart';
import 'widgets/study_material_card.dart';
import 'widgets/translation_card.dart';

class HomeScreen extends StatelessWidget {
  final String username;

  const HomeScreen({
    super.key,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => HomeTranslationCubit(
            translationService: TranslationServiceImpl(),
            historyDao: ServiceLocator.translationHistoryDao,
          ),
        ),
        BlocProvider(
          create: (_) => StudyMaterialCubit(
            repository: StudyMaterialRepositoryImpl(
              lessonDao: ServiceLocator.cachedLessonDao,
            ),
          ),
        ),
      ],
      child: _HomeView(username: username),
    );
  }
}

class _HomeView extends StatefulWidget {
  final String username;

  const _HomeView({required this.username});

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _searchController.dispose();
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _onSearchWord(String word) async {
    if (word.trim().isEmpty) return;
    final row = await ServiceLocator.dictionaryService.lookupWordOffline(word.trim());
    if (mounted) {
      DictionaryBottomSheet.show(
        context,
        row ?? {'word': word.trim()},
        word.trim(),
      );
    }
  }

  void _listenSpeech() async {
    final translationCubit = context.read<HomeTranslationCubit>();
    if (!translationCubit.state.isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        translationCubit.setListening(true);
        _speechToText.listen(
          onResult: (result) {
            _inputController.text = result.recognizedWords;
            translationCubit.onInputChanged(result.recognizedWords);
            if (result.finalResult) {
              translationCubit.setListening(false);
            }
          },
          localeId: translationCubit.state.sourceLangCode == 'vi'
              ? 'vi_VN'
              : 'en_US',
        );
      }
    } else {
      translationCubit.setListening(false);
      _speechToText.stop();
    }
  }

  void _openCameraOCR() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null && mounted) {
      context.read<HomeTranslationCubit>().processImageForText(photo.path);
    }
  }

  void _pickPDFAndChooseGame() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null && mounted) {
      File file = File(result.files.single.path!);
      GameModeDialog.show(context, file, (dialogCtx, selectedFile, quizType) {
        context.read<StudyMaterialCubit>().generateLesson(
              file: selectedFile,
              quizType: quizType,
              username: widget.username,
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeCubit>().state.isDarkMode;
    final langCode = context.watch<LanguageCubit>().state.languageCode;
    final S s = S(langCode);

    final Color primaryGreen = isDarkMode
        ? ColorManager.primaryGreenLight
        : ColorManager.primaryGreen;
    final Color textColor = isDarkMode
        ? ColorManager.darkTextPrimary
        : ColorManager.lightTextPrimary;
    final Color cardColor = isDarkMode ? ColorManager.darkCard : ColorManager.lightCard;

    return BlocListener<StudyMaterialCubit, StudyMaterialState>(
      listener: (context, state) {
        if (state.isLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: ColorManager.primaryGreen),
                      SizedBox(height: 15),
                      Text(
                        "AI đang phân tích tài liệu và tạo câu hỏi...",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else if (state.isSuccess) {
          Navigator.of(context, rootNavigator: true).pop(); // Close dialog
          final lesson = state.generatedLesson!;
          String route;
          if (lesson.quizType == "drag_drop") {
            route = AppRoutes.dragDropQuiz;
          } else if (lesson.quizType == "multiple_choice") {
            route = AppRoutes.multipleChoiceQuiz;
          } else {
            route = AppRoutes.fillBlankQuiz;
          }
          context.push(
            route,
            extra: {
              'questions': lesson.questions,
              'lessonId': lesson.lessonId,
            },
          );
          context.read<StudyMaterialCubit>().reset();
        } else if (state.status == StudyMaterialStatus.failure) {
          Navigator.of(context, rootNavigator: true).pop(); // Close dialog
          context.showErrorSnackBar(state.errorMessage ?? 'Có lỗi xảy ra');
          context.read<StudyMaterialCubit>().reset();
        }
      },
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: _onSearchWord,
                    decoration: InputDecoration(
                      hintText: s.translate('search_hint'),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.search),
                  onPressed: () => _onSearchWord(_searchController.text),
                  style: IconButton.styleFrom(backgroundColor: primaryGreen),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Text(
              s.translate('smart_translation'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 15),
            BlocConsumer<HomeTranslationCubit, HomeTranslationState>(
              listener: (context, state) {
                if (_inputController.text != state.inputText) {
                  _inputController.text = state.inputText;
                }
                if (_outputController.text != state.outputText) {
                  _outputController.text = state.outputText;
                }
                if (state.errorMessage != null) {
                  context.showErrorSnackBar(state.errorMessage!);
                }
              },
              builder: (context, state) {
                final sourceLangName =
                    state.sourceLangCode == 'en' ? 'English' : 'Tiếng Việt';
                final targetLangName =
                    state.targetLangCode == 'vi' ? 'Tiếng Việt' : 'English';

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      children: [
                        TranslationCard(
                          title: sourceLangName,
                          controller: _inputController,
                          hint: s.translate('input_hint'),
                          isInput: true,
                          cardColor: cardColor,
                          textColor: textColor,
                          isDarkMode: isDarkMode,
                          isListening: state.isListening,
                          onListen: _listenSpeech,
                          onCamera: _openCameraOCR,
                          onSpeak: () => context
                              .read<HomeTranslationCubit>()
                              .speakSource(),
                          onChanged: (val) => context
                              .read<HomeTranslationCubit>()
                              .onInputChanged(val),
                        ),
                        const SizedBox(height: 15),
                        TranslationCard(
                          title: targetLangName,
                          controller: _outputController,
                          hint: s.translate('output_hint'),
                          isInput: false,
                          cardColor: cardColor,
                          textColor: textColor,
                          isDarkMode: isDarkMode,
                          onSpeak: () => context
                              .read<HomeTranslationCubit>()
                              .speakTranslation(),
                        ),
                      ],
                    ),
                    Positioned(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
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
                          onPressed: () => context
                              .read<HomeTranslationCubit>()
                              .swapLanguages(),
                          icon: Icon(
                            Icons.swap_vert,
                            color: primaryGreen,
                            size: 28,
                          ),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 35),
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
              onTap: _pickPDFAndChooseGame,
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
