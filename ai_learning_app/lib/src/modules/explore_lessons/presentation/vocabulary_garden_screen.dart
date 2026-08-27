import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_learning_app/generated/l10n.dart';
import 'package:ai_learning_app/src/common/theme/color_manager.dart';
import 'package:ai_learning_app/src/common/utils/service_locator.dart';
import 'package:ai_learning_app/src/core/application/language/language_cubit.dart';
import 'package:ai_learning_app/src/core/application/theme/theme_cubit.dart';
import 'package:ai_learning_app/src/modules/app/router/app_router.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/application/vocabulary_garden_cubit/vocabulary_garden_cubit.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/application/vocabulary_garden_cubit/vocabulary_garden_state.dart';

class VocabularyGardenScreen extends StatelessWidget {
  const VocabularyGardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VocabularyGardenCubit(
        savedWordDao: ServiceLocator.savedWordDao,
      )..loadGarden(),
      child: const _VocabularyGardenView(),
    );
  }
}

class _VocabularyGardenView extends StatelessWidget {
  const _VocabularyGardenView();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeCubit>().state.isDarkMode;
    final langCode = context.watch<LanguageCubit>().state.languageCode;
    final S s = S(langCode);
    const Color primaryGreen = ColorManager.primaryGreen;
    final Color bgColor = isDarkMode
        ? ColorManager.darkBackground
        : ColorManager.lightBackground;
    final Color textColor = isDarkMode
        ? ColorManager.darkTextPrimary
        : ColorManager.lightTextPrimary;

    return BlocBuilder<VocabularyGardenCubit, VocabularyGardenState>(
      builder: (context, state) {
        final words = state.gardenWords;
        final wordsToReview = state.wordsToReview;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: Text(
              s.translate('garden_title'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: state.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: ColorManager.primaryGreen),
                )
              : words.isEmpty
                  ? _buildEmptyGarden(s, textColor)
                  : _buildGardenList(context, state, s, isDarkMode, textColor),
          floatingActionButton: words.isEmpty
              ? null
              : wordsToReview.isNotEmpty
                  ? FloatingActionButton.extended(
                      onPressed: () async {
                        final rawWords =
                            wordsToReview.map((w) => w.toJson()).toList();
                        final result = await context.push(
                          AppRoutes.flashcardQuiz,
                          extra: rawWords,
                        );
                        if (result == true && context.mounted) {
                          context.read<VocabularyGardenCubit>().loadGarden();
                        }
                      },
                      backgroundColor: primaryGreen,
                      icon: const Icon(Icons.water_drop, color: Colors.white),
                      label: Text(
                        "${s.translate('water_trees')} ${wordsToReview.length} ${s.translate('trees_unit')}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
        );
      },
    );
  }

  Widget _buildEmptyGarden(S s, Color textColor) {
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

  Widget _buildGardenList(
    BuildContext context,
    VocabularyGardenState state,
    S s,
    bool isDarkMode,
    Color textColor,
  ) {
    final words = state.gardenWords;
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: words.length,
      itemBuilder: (context, index) {
        final item = words[index];
        final level = item.level;

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
              item.word,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: textColor,
              ),
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
