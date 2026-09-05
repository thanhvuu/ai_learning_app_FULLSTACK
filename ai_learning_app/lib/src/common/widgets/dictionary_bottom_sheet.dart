import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_learning_app/src/common/theme/color_manager.dart';
import 'package:ai_learning_app/src/core/application/theme/theme_cubit.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/application/dictionary_cubit/dictionary_cubit.dart';

class DictionaryBottomSheet {
  static void show(
    BuildContext context,
    Map<String, dynamic> initialData,
    String searchWord,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BlocProvider(
          create: (_) => DictionaryCubit(
            initialData: initialData,
            searchWord: searchWord,
          ),
          child: _DictionarySheetContent(
            searchWord: searchWord,
          ),
        );
      },
    );
  }
}

class _DictionarySheetContent extends StatefulWidget {
  final String searchWord;

  const _DictionarySheetContent({
    required this.searchWord,
  });

  @override
  State<_DictionarySheetContent> createState() => _DictionarySheetContentState();
}

class _DictionarySheetContentState extends State<_DictionarySheetContent> {
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _speakWord(String textToSpeak) async {
    if (textToSpeak.isNotEmpty) {
      await flutterTts.speak(textToSpeak);
    }
  }

  Future<void> _toggleSave(String word) async {
    final newState = await context.read<DictionaryCubit>().toggleSave(widget.searchWord);

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newState
                ? "🌱 Đã gieo mầm từ '$word' vào vườn!"
                : "Đã nhổ từ '$word' khỏi vườn.",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: ColorManager.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.8,
            left: 20,
            right: 20,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeCubit>().state.isDarkMode;
    final dictState = context.watch<DictionaryCubit>().state;
    final wordData = dictState.wordData;
    final isLoadingAI = dictState.isLoadingAI;
    final isSaved = dictState.isSaved;
    final currentWord = wordData['word'] ?? widget.searchWord;

    final Color bgColor = isDarkMode ? ColorManager.darkCard : ColorManager.lightCard;
    final Color textColor = isDarkMode ? ColorManager.darkTextPrimary : ColorManager.lightTextPrimary;
    final Color exampleBgColor = isDarkMode ? ColorManager.darkInputBg : ColorManager.lightCardAlt;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentWord,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: ColorManager.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "/${wordData['phonetic'] ?? '...'} /  •  ${wordData['partOfSpeech'] ?? ''}",
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: isSaved
                          ? ColorManager.primaryGreen
                          : ColorManager.primaryGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isSaved ? Icons.eco : Icons.eco_outlined,
                        color: isSaved ? Colors.white : ColorManager.primaryGreen,
                        size: 24,
                      ),
                      onPressed: () => _toggleSave(currentWord),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: ColorManager.primaryGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.volume_up,
                        color: ColorManager.primaryGreen,
                        size: 24,
                      ),
                      onPressed: () => _speakWord(currentWord),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Divider(
            height: 30,
            thickness: 1,
            color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Nghĩa tiếng Việt"),
                  Text(
                    _cleanHtml(
                      wordData['meaning'] ?? "Đang cập nhật...",
                    ),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 25),
                  if (isLoadingAI) ...[
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          const CircularProgressIndicator(
                            color: ColorManager.primaryGreen,
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "AI đang phân tích ví dụ và từ đồng nghĩa...",
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey[500] : Colors.grey,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    if (wordData['examples'] != null &&
                        (wordData['examples'] as List).isNotEmpty) ...[
                      _buildSectionTitle("Ví dụ (Examples)"),
                      ...(wordData['examples'] as List<dynamic>).map(
                        (ex) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: exampleBgColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ex['en'] ?? "",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  ex['vn'] ?? "",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[700],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (wordData['synonyms'] != null &&
                            (wordData['synonyms'] as List).isNotEmpty)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle("Đồng nghĩa"),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      (wordData['synonyms'] as List<dynamic>)
                                          .map(
                                            (s) => Chip(
                                              label: Text(s.toString()),
                                              backgroundColor: isDarkMode
                                                  ? Colors.blue.withOpacity(0.2)
                                                  : Colors.blue[50],
                                              side: BorderSide.none,
                                              labelStyle: TextStyle(
                                                color: isDarkMode
                                                    ? Colors.blue[200]
                                                    : Colors.blue,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(width: 10),
                        if (wordData['antonyms'] != null &&
                            (wordData['antonyms'] as List).isNotEmpty)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle("Trái nghĩa"),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      (wordData['antonyms'] as List<dynamic>)
                                          .map(
                                            (a) => Chip(
                                              label: Text(a.toString()),
                                              backgroundColor: isDarkMode
                                                  ? Colors.red.withOpacity(0.2)
                                                  : Colors.red[50],
                                              side: BorderSide.none,
                                              labelStyle: TextStyle(
                                                color: isDarkMode
                                                    ? Colors.red[200]
                                                    : Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _cleanHtml(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '').trim();
  }
}
