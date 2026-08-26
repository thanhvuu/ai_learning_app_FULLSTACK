import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ai_learning_app/generated/l10n.dart';
import 'package:ai_learning_app/src/common/theme/color_manager.dart';
import 'package:ai_learning_app/src/common/utils/service_locator.dart';
import 'package:ai_learning_app/src/core/application/language_provider.dart';
import 'package:ai_learning_app/src/core/application/theme_provider.dart';
import 'package:ai_learning_app/src/modules/app/router/app_router.dart';

class VocabularyGardenScreen extends StatefulWidget {
  const VocabularyGardenScreen({super.key});

  @override
  State<VocabularyGardenScreen> createState() => _VocabularyGardenScreenState();
}

class _VocabularyGardenScreenState extends State<VocabularyGardenScreen> {
  List<Map<String, dynamic>> _gardenWords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGarden();
  }

  void _loadGarden() async {
    setState(() => _isLoading = true);
    final words = await ServiceLocator.dictionaryService.getGardenWords();
    if (mounted) {
      setState(() {
        _gardenWords = words;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _wordsToReview {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _gardenWords.where((word) {
      final level = word['level'] ?? 0;
      final lastReviewed = word['last_reviewed'] ?? 0;
      int intervalHours = 0;
      if (level == 0) intervalHours = 0;
      if (level == 1) intervalHours = 24;
      if (level == 2) intervalHours = 72;
      if (level == 3) intervalHours = 168;

      final diffHours = (now - lastReviewed) / (1000 * 60 * 60);
      return diffHours >= intervalHours;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final langProvider = LanguageProvider.safeOf(context);
    final S s = S(langProvider.languageCode);
    const Color primaryGreen = ColorManager.primaryGreen;
    final Color bgColor = isDarkMode
        ? ColorManager.darkBackground
        : ColorManager.lightBackground;
    final Color textColor = isDarkMode ? ColorManager.darkTextPrimary : ColorManager.lightTextPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          s.translate('garden_title'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: ColorManager.primaryGreen))
          : _gardenWords.isEmpty
              ? _buildEmptyGarden(context, textColor)
              : _buildGardenList(isDarkMode, textColor),
      floatingActionButton: _gardenWords.isEmpty
          ? null
          : _wordsToReview.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () async {
                    final result = await context.push(
                      AppRoutes.flashcardQuiz,
                      extra: _wordsToReview,
                    );
                    if (result == true) _loadGarden();
                  },
                  backgroundColor: primaryGreen,
                  icon: const Icon(Icons.water_drop, color: Colors.white),
                  label: Text(
                    "${s.translate('water_trees')} ${_wordsToReview.length} ${s.translate('trees_unit')}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
    );
  }

  Widget _buildEmptyGarden(BuildContext context, Color textColor) {
    final langProvider = LanguageProvider.safeOf(context);
    final S s = S(langProvider.languageCode);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.eco_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 15),
          Text(
            s.translate('empty_garden'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.translate('save_word_instruction'),
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildGardenList(bool isDarkMode, Color textColor) {
    final langProvider = LanguageProvider.safeOf(context);
    final S s = S(langProvider.languageCode);
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: _gardenWords.length,
      itemBuilder: (context, index) {
        final item = _gardenWords[index];
        final level = item['level'] ?? 0;

        String plantState = s.translate('sprout');
        String plantEmoji = "🌱";
        Color plantColor = Colors.lightGreen;

        if (level == 1) {
          plantState = s.translate('sapling');
          plantEmoji = "🌿";
          plantColor = Colors.green;
        } else if (level == 2) {
          plantState = s.translate('growing_tree');
          plantEmoji = "🌳";
          plantColor = Colors.teal;
        } else if (level >= 3) {
          plantState = s.translate('mature_tree');
          plantEmoji = "🍎";
          plantColor = Colors.orange;
        }

        return Card(
          color: isDarkMode ? ColorManager.darkCard : ColorManager.lightCard,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: plantColor.withOpacity(0.2),
              child: Text(plantEmoji, style: const TextStyle(fontSize: 22)),
            ),
            title: Text(
              item['word'],
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor),
            ),
            subtitle: Text(
              "${s.translate('growth_stage')}: $plantState",
              style: TextStyle(color: plantColor, fontWeight: FontWeight.w600),
            ),
            trailing: _buildWaterDroplet(level),
          ),
        );
      },
    );
  }

  Widget _buildWaterDroplet(int level) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Icon(
          index < level ? Icons.water_drop : Icons.water_drop_outlined,
          color: index < level ? Colors.blue : Colors.grey[400],
          size: 18,
        );
      }),
    );
  }
}
