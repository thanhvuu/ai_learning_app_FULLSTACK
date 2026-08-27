import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_learning_app/src/common/extensions/build_context_ext.dart';
import 'package:ai_learning_app/src/common/theme/color_manager.dart';
import 'package:ai_learning_app/src/common/utils/service_locator.dart';
import 'package:ai_learning_app/src/core/application/auth/auth_cubit.dart';
import 'package:ai_learning_app/src/modules/app/router/app_router.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/application/major_selection_cubit/major_selection_cubit.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/application/major_selection_cubit/major_selection_state.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/infrastructure/repositories/lesson_repository_impl.dart';

class MajorSelectionScreen extends StatelessWidget {
  final String username;
  const MajorSelectionScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MajorSelectionCubit(
        lessonRepository: LessonRepositoryImpl(
          lessonDao: ServiceLocator.cachedLessonDao,
        ),
      ),
      child: _MajorSelectionView(username: username),
    );
  }
}

class _MajorSelectionView extends StatelessWidget {
  final String username;
  const _MajorSelectionView({required this.username});

  static const List<Map<String, dynamic>> majors = [
    {
      "name": "Information Technology",
      "icon": Icons.computer,
      "color": Colors.blue,
    },
    {
      "name": "Business & Finance",
      "icon": Icons.business_center,
      "color": Colors.orange,
    },
    {
      "name": "Medical & Healthcare",
      "icon": Icons.medical_services,
      "color": Colors.red,
    },
    {
      "name": "Tourism & Hospitality",
      "icon": Icons.flight_takeoff,
      "color": Colors.green,
    },
    {"name": "Daily Conversation", "icon": Icons.chat, "color": Colors.teal},
    {"name": "IELTS/TOEIC Prep", "icon": Icons.school, "color": Colors.indigo},
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MajorSelectionCubit, MajorSelectionState>(
      listener: (context, state) {
        if (state.isSuccess && state.selectedMajor != null) {
          context.read<AuthCubit>().updateUserMajor(state.selectedMajor!);
          context.go(
            AppRoutes.roadmap,
            extra: {
              'username': username,
              'major': state.selectedMajor!,
            },
          );
        } else if (state.status == MajorSelectionStatus.failure &&
            state.errorMessage != null) {
          context.showErrorSnackBar(state.errorMessage!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Chọn chuyên ngành học",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      "Chọn lĩnh vực bạn muốn tập trung phát triển vốn từ vựng và kỹ năng giao tiếp:",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: majors.length,
                      itemBuilder: (context, index) {
                        final major = majors[index];
                        return GestureDetector(
                          onTap: () {
                            context.read<MajorSelectionCubit>().selectMajor(
                                  username: username,
                                  major: major['name'],
                                );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: (major['color'] as Color).withOpacity(0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (major['color'] as Color).withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: (major['color'] as Color)
                                      .withOpacity(0.1),
                                  child: Icon(
                                    major['icon'],
                                    size: 30,
                                    color: major['color'],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: Text(
                                    major['name'],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              if (state.isLoading)
                Container(
                  color: Colors.black45,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: ColorManager.primaryGreen,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
