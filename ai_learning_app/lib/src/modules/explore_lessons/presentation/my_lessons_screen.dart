import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_learning_app/generated/l10n.dart';
import 'package:ai_learning_app/src/common/theme/color_manager.dart';
import 'package:ai_learning_app/src/common/utils/service_locator.dart';
import 'package:ai_learning_app/src/core/application/language/language_cubit.dart';
import 'package:ai_learning_app/src/core/application/theme/theme_cubit.dart';
import 'package:ai_learning_app/src/modules/app/router/app_router.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/application/my_lessons_cubit/my_lessons_cubit.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/application/my_lessons_cubit/my_lessons_state.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/data/models/question_model.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/data/models/vocabulary_model.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/infrastructure/repositories/lesson_repository_impl.dart';

class MyLessonsScreen extends StatelessWidget {
  final String username;
  const MyLessonsScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyLessonsCubit(
        lessonRepository: LessonRepositoryImpl(
          lessonDao: ServiceLocator.cachedLessonDao,
        ),
      )..loadLessons(username),
      child: _MyLessonsView(username: username),
    );
  }
}

class _MyLessonsView extends StatelessWidget {
  final String username;
  const _MyLessonsView({required this.username});

  String _getSubtitleForType(BuildContext context, String type) {
    final langCode = context.read<LanguageCubit>().state.languageCode;
    final s = S(langCode);
    if (type == 'drag_drop') return s.translate('drag_drop_type');
    if (type == 'multiple_choice') return s.translate('multiple_choice_type');
    if (type == 'fill_blank') return s.translate('fill_blank_type');
    return s.translate('study_material_type');
  }

  List<Color> _getGradientForType(String type) {
    if (type == 'drag_drop') {
      return const [Color(0xFF2E86C1), Color(0xFF85C1E9)];
    }
    if (type == 'multiple_choice') {
      return const [Color(0xFF935116), Color(0xFFE59866)];
    }
    if (type == 'fill_blank') {
      return const [Color(0xFF17202A), Color(0xFF5D6D7E)];
    }
    return const [Color(0xFF6A4CFF), Color(0xFFB39DDB)];
  }

  IconData _getIconForType(String type) {
    if (type == 'drag_drop') return Icons.drag_indicator;
    if (type == 'multiple_choice') return Icons.list_alt;
    if (type == 'fill_blank') return Icons.keyboard;
    return Icons.menu_book;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeCubit>().state.isDarkMode;
    final langCode = context.watch<LanguageCubit>().state.languageCode;
    final S s = S(langCode);
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color textColor = isDarkMode ? ColorManager.darkTextPrimary : ColorManager.lightTextPrimary;
    final Color cardColor = isDarkMode ? ColorManager.darkCard : ColorManager.lightCard;
    final Color subtitleColor = isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;
    const Color greenAccent = ColorManager.primaryGreen;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          s.translate('my_lessons'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: greenAccent,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: isDarkMode ? Colors.grey[800] : Colors.blue[100],
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
      body: BlocBuilder<MyLessonsCubit, MyLessonsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator(color: greenAccent));
          }

          final lessons = state.lessons;

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<MyLessonsCubit>().loadLessons(username);
            },
            color: greenAccent,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDailyGoalCard(
                    context,
                    cardColor,
                    textColor,
                    greenAccent,
                    isDarkMode,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        s.translate('active_courses'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          s.translate('view_all'),
                          style: const TextStyle(
                            color: greenAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (lessons.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          s.translate('no_lessons'),
                          style: TextStyle(color: subtitleColor),
                        ),
                      ),
                    ),
                  ...lessons.map(
                    (course) => _buildCourseCard(
                      context,
                      course,
                      cardColor,
                      textColor,
                      subtitleColor,
                      greenAccent,
                      isDarkMode,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailyGoalCard(
    BuildContext context,
    Color cardColor,
    Color textColor,
    Color greenAccent,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black54
                : Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context, 'daily_goal'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    "25",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: greenAccent,
                    ),
                  ),
                  Text(
                    "/45 min",
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.deepPurple.withOpacity(0.2)
                      : const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: isDarkMode
                          ? Colors.deepPurpleAccent
                          : Colors.deepPurple,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "3 ${S.of(context, 'day_streak')}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDarkMode
                            ? Colors.deepPurpleAccent
                            : Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 0.55,
                  strokeWidth: 10,
                  backgroundColor: isDarkMode
                      ? Colors.grey[800]
                      : const Color(0xFFE8F6EF),
                  valueColor: AlwaysStoppedAnimation<Color>(greenAccent),
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Text(
                    "55%",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(
    BuildContext context,
    Map<String, dynamic> course,
    Color cardColor,
    Color textColor,
    Color subtitleColor,
    Color greenAccent,
    bool isDarkMode,
  ) {
    final String type = course['quizType'] ?? 'multiple_choice';
    final double progress = ((course['progress'] as num?)?.toDouble() ?? 0.0).clamp(0.0, 1.0);
    final bool isCompleted = progress >= 1.0;
    final String title = course['title'] ?? course['topic'] ?? "Bài học";
    final String subtitle = _getSubtitleForType(context, type);
    final List<Color> gradient = _getGradientForType(type);
    final IconData icon = _getIconForType(type);

    final vocabulariesJson = (course['vocabularies'] as List?) ?? [];
    final questionsJson = (course['questions'] as List?) ?? [];

    final vocabularies = vocabulariesJson
        .map((v) => v is Map ? VocabularyModel.fromJson(Map<String, dynamic>.from(v)) : null)
        .whereType<VocabularyModel>()
        .toList();
    final questions = questionsJson
        .map((q) => q is Map ? QuestionModel.fromJson(Map<String, dynamic>.from(q)) : null)
        .whereType<QuestionModel>()
        .toList();

    return InkWell(
      onTap: () {
        context.push(
          AppRoutes.vocabulary,
          extra: {
            'lessonId': int.tryParse(course['id']?.toString() ?? '0') ?? 0,
            'topic': title,
            'content': course['content'] ?? "",
            'vocabularies': vocabularies,
            'questions': questions,
            'quizType': type,
          },
        );
      },
      borderRadius: BorderRadius.circular(25),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black54
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradient,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white.withOpacity(0.8),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: greenAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: greenAccent.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    isCompleted ? Icons.check : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context, 'progress'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: textColor,
                  ),
                ),
                Text(
                  "${(progress * 100).toInt()}%",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: greenAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(greenAccent),
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),
      ),
    );
  }
}
