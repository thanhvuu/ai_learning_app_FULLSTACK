import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_learning_app/src/common/extensions/build_context_ext.dart';
import 'package:ai_learning_app/src/common/theme/color_manager.dart';
import 'package:ai_learning_app/src/common/utils/service_locator.dart';
import 'package:ai_learning_app/src/modules/app/router/app_router.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/application/roadmap_cubit/roadmap_cubit.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/application/roadmap_cubit/roadmap_state.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/data/models/question_model.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/data/models/vocabulary_model.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/infrastructure/repositories/lesson_repository_impl.dart';

class RoadmapScreen extends StatelessWidget {
  final String major;
  final String username;

  const RoadmapScreen({super.key, required this.major, required this.username});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RoadmapCubit(
        lessonRepository: LessonRepositoryImpl(
          lessonDao: ServiceLocator.cachedLessonDao,
        ),
      )..loadRoadmap(major),
      child: _RoadmapView(major: major, username: username),
    );
  }
}

class _RoadmapView extends StatelessWidget {
  final String major;
  final String username;

  const _RoadmapView({required this.major, required this.username});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoadmapCubit, RoadmapState>(
      listener: (context, state) {
        if (state.status == RoadmapStatus.generatingLesson) {
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
                        "AI đang chuẩn bị từ vựng & bài tập...",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else if (state.status == RoadmapStatus.lessonReady &&
            state.generatedLesson != null) {
          Navigator.of(context, rootNavigator: true).pop(); // Close dialog
          final jsonResult = state.generatedLesson!;
          final vocabulariesJson = (jsonResult['vocabularies'] as List?) ?? [];
          final questionsJson = (jsonResult['questions'] as List?) ?? [];

          final vocabularies =
              vocabulariesJson.map((v) => VocabularyModel.fromJson(v)).toList();
          final questions =
              questionsJson.map((q) => QuestionModel.fromJson(q)).toList();

          context.push(
            AppRoutes.vocabulary,
            extra: {
              'vocabularies': vocabularies,
              'questions': questions,
              'lessonId': jsonResult['id'] ?? 0,
            },
          );
          context.read<RoadmapCubit>().resetLessonStatus();
        } else if (state.status == RoadmapStatus.failure) {
          if (ModalRoute.of(context)?.isCurrent != true) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          if (state.errorMessage != null) {
            context.showErrorSnackBar(state.errorMessage!);
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FA),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => context.safePop(),
            ),
            title: Text(
              "Lộ trình: $major",
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
          ),
          body: state.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: ColorManager.primaryGreen,
                  ),
                )
              : state.steps.isEmpty
                  ? const Center(
                      child: Text("Chưa có lộ trình cho chuyên ngành này"),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: 20,
                      ),
                      itemCount: state.steps.length,
                      itemBuilder: (context, index) {
                        final step = state.steps[index];
                        final isUnlocked = index == 0;
                        final double offset =
                            math.sin(index * 1.2) * 80;

                        return Center(
                          child: Transform.translate(
                            offset: Offset(offset, 0),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 40),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (isUnlocked) {
                                        context.read<RoadmapCubit>().startLesson(
                                              topic: step['topic'],
                                              username: username,
                                              major: major,
                                            );
                                      } else {
                                        context.showInfoSnackBar(
                                          "Hãy hoàn thành các bài học trước để mở khóa!",
                                        );
                                      }
                                    },
                                    child: Container(
                                      width: 85,
                                      height: 85,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isUnlocked
                                            ? ColorManager.primaryGreen
                                            : Colors.grey[300],
                                        boxShadow: [
                                          BoxShadow(
                                            color: isUnlocked
                                                ? ColorManager.primaryGreen
                                                    .withOpacity(0.4)
                                                : Colors.black12,
                                            blurRadius: 15,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 4,
                                        ),
                                      ),
                                      child: Icon(
                                        isUnlocked
                                            ? Icons.star_rounded
                                            : Icons.lock_outline_rounded,
                                        color: isUnlocked
                                            ? Colors.white
                                            : Colors.grey[500],
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      step['topic'] ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isUnlocked
                                            ? Colors.black87
                                            : Colors.grey[500],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }
}
