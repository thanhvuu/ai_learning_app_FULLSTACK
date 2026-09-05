import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_learning_app/src/common/utils/service_locator.dart';
import 'package:ai_learning_app/src/modules/change_password/presentation/change_password_screen.dart';
import 'package:ai_learning_app/src/modules/contact/presentation/contact_screen.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/application/quiz_cubit/quiz_cubit.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/data/models/question_model.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/data/models/vocabulary_model.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/presentation/discover_screen.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/presentation/my_lessons_screen.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/presentation/quiz/drag_drop_quiz_screen.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/presentation/quiz/fill_blank_screen.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/presentation/quiz/flashcard_screen.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/presentation/quiz/multiple_choice_screen.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/presentation/quiz/quiz_screen.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/presentation/vocabulary_garden_screen.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/presentation/vocabulary_screen.dart';
import 'package:ai_learning_app/src/modules/forgot_password/presentation/forgot_password_screen.dart';
import 'package:ai_learning_app/src/modules/home/presentation/home_screen.dart';
import 'package:ai_learning_app/src/modules/login/presentation/login_screen.dart';
import 'package:ai_learning_app/src/modules/main_screen/presentation/main_screen.dart';
import 'package:ai_learning_app/src/modules/playlist/presentation/playlist_screen.dart';
import 'package:ai_learning_app/src/modules/profile/presentation/profile_screen.dart';
import 'package:ai_learning_app/src/modules/register/presentation/register_screen.dart';
import 'package:ai_learning_app/src/modules/splash/presentation/connectivity_gate.dart';
import 'package:ai_learning_app/src/modules/splash/presentation/no_internet_screen.dart';
import 'package:ai_learning_app/src/modules/splash/presentation/splash_screen.dart';
import 'package:ai_learning_app/src/modules/splash/presentation/startup_gate.dart';
import 'package:ai_learning_app/src/modules/splash/presentation/welcome_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String noInternet = '/no-internet';
  static const String startupGate = '/startup-gate';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String changePassword = '/change-password';
  static const String main = '/main';
  static const String home = '/home';
  static const String myLessons = '/my-lessons';
  static const String discover = '/discover';
  static const String profile = '/profile';
  static const String vocabulary = '/vocabulary';
  static const String vocabularyGarden = '/vocabulary-garden';
  static const String playlist = '/playlist';
  static const String contact = '/contact';
  static const String quiz = '/quiz';
  static const String dragDropQuiz = '/drag-drop-quiz';
  static const String multipleChoiceQuiz = '/multiple-choice-quiz';
  static const String fillBlankQuiz = '/fill-blank-quiz';
  static const String flashcardQuiz = '/flashcard-quiz';
}

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.initial,
    routes: [
      GoRoute(
        path: AppRoutes.initial,
        builder: (context, state) => const ConnectivityGate(),
      ),
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.startupGate,
        builder: (context, state) => const StartupGate(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.noInternet,
        builder: (context, state) {
          final extra = state.extra;
          return NoInternetScreen(
            onRetry: extra is Future<void> Function()? ? extra : null,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) {
          final extra = state.extra as String?;
          return ForgotPasswordScreen(initialEmail: extra);
        },
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.main,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final username = extra?['username'] ??
              state.uri.queryParameters['username'] ??
              'User';
          final initialIndex = extra?['initialIndex'] ??
              int.tryParse(state.uri.queryParameters['initialIndex'] ?? '0') ??
              0;

          return MainScreen(
            username: username,
            initialIndex: initialIndex,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final username = extra?['username'] ??
              state.uri.queryParameters['username'] ??
              'User';
          return HomeScreen(username: username);
        },
      ),
      GoRoute(
        path: AppRoutes.myLessons,
        builder: (context, state) {
          final extra = state.extra;
          final username = extra is String
              ? extra
              : state.uri.queryParameters['username'] ?? 'User';
          return MyLessonsScreen(username: username);
        },
      ),
      GoRoute(
        path: AppRoutes.discover,
        builder: (context, state) {
          final extra = state.extra;
          final username = extra is String
              ? extra
              : state.uri.queryParameters['username'] ?? 'User';
          return DiscoverScreen(username: username);
        },
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final username = extra?['username'] ??
              state.uri.queryParameters['username'] ??
              'User';
          final xp = extra?['xp'] ??
              int.tryParse(state.uri.queryParameters['xp'] ?? '0') ??
              0;
          final streak = extra?['streak'] ??
              int.tryParse(state.uri.queryParameters['streak'] ?? '0') ??
              0;
          return ProfileScreen(username: username, xp: xp, streak: streak);
        },
      ),
      GoRoute(
        path: AppRoutes.vocabulary,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final lessonId = extra?['lessonId'] as int? ?? 0;
          final topic = extra?['topic'] as String? ?? '';
          final content = extra?['content'] as String? ?? '';
          final vocabularies = extra?['vocabularies'] as List<VocabularyModel>? ?? [];
          final questions = extra?['questions'] as List<QuestionModel>? ?? [];
          final quizType = extra?['quizType'] as String? ?? 'multiple_choice';
          return VocabularyScreen(
            lessonId: lessonId,
            topic: topic,
            content: content,
            vocabularies: vocabularies,
            questions: questions,
            quizType: quizType,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.vocabularyGarden,
        builder: (context, state) => const VocabularyGardenScreen(),
      ),
      GoRoute(
        path: AppRoutes.playlist,
        builder: (context, state) {
          final extra = state.extra;
          final username = extra is String
              ? extra
              : state.uri.queryParameters['username'] ?? 'User';
          return PlaylistScreen(username: username);
        },
      ),
      GoRoute(
        path: AppRoutes.contact,
        builder: (context, state) => const ContactScreen(),
      ),
      GoRoute(
        path: AppRoutes.quiz,
        builder: (context, state) => BlocProvider(
          create: (_) => QuizCubit(
            totalQuestions: 10,
            quizRepository: ServiceLocator.quizRepository,
          ),
          child: const QuizScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.dragDropQuiz,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final rawQuestions = extra?['questions'];
          final questions = rawQuestions is List<QuestionModel>
              ? rawQuestions
              : (rawQuestions as List<dynamic>?)
                      ?.map((q) => q is QuestionModel
                          ? q
                          : QuestionModel.fromJson(q as Map<String, dynamic>))
                      .toList() ??
                  [];
          final lessonId = (extra?['lessonId'] as num?)?.toInt() ?? 0;
          return BlocProvider(
            create: (_) => QuizCubit(
              totalQuestions: questions.length,
              quizRepository: ServiceLocator.quizRepository,
            ),
            child: DragDropQuizScreen(questions: questions, lessonId: lessonId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.multipleChoiceQuiz,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final rawQuestions = extra?['questions'];
          final questions = rawQuestions is List<QuestionModel>
              ? rawQuestions
              : (rawQuestions as List<dynamic>?)
                      ?.map((q) => q is QuestionModel
                          ? q
                          : QuestionModel.fromJson(q as Map<String, dynamic>))
                      .toList() ??
                  [];
          final lessonId = (extra?['lessonId'] as num?)?.toInt() ?? 0;
          return BlocProvider(
            create: (_) => QuizCubit(
              totalQuestions: questions.length,
              quizRepository: ServiceLocator.quizRepository,
            ),
            child: MultipleChoiceScreen(questions: questions, lessonId: lessonId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.fillBlankQuiz,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final rawQuestions = extra?['questions'];
          final questions = rawQuestions is List<QuestionModel>
              ? rawQuestions
              : (rawQuestions as List<dynamic>?)
                      ?.map((q) => q is QuestionModel
                          ? q
                          : QuestionModel.fromJson(q as Map<String, dynamic>))
                      .toList() ??
                  [];
          final lessonId = (extra?['lessonId'] as num?)?.toInt() ?? 0;
          return BlocProvider(
            create: (_) => QuizCubit(
              totalQuestions: questions.length,
              quizRepository: ServiceLocator.quizRepository,
            ),
            child: FillBlankScreen(questions: questions, lessonId: lessonId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.flashcardQuiz,
        builder: (context, state) {
          final extra = state.extra;
          List<Map<String, dynamic>> reviewWords = [];
          if (extra is List<Map<String, dynamic>>) {
            reviewWords = extra;
          } else if (extra is Map<String, dynamic>) {
            reviewWords = (extra['reviewWords'] as List<dynamic>?)
                    ?.cast<Map<String, dynamic>>() ??
                [];
          }
          return BlocProvider(
            create: (_) => QuizCubit(
              totalQuestions: reviewWords.length,
              quizRepository: ServiceLocator.quizRepository,
            ),
            child: FlashcardScreen(reviewWords: reviewWords),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Không tìm thấy đường dẫn: ${state.uri.toString()}'),
      ),
    ),
  );
}
