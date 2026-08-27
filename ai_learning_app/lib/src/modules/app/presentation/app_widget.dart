import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_learning_app/generated/l10n.dart';
import 'package:ai_learning_app/src/common/theme/app_theme.dart';
import 'package:ai_learning_app/src/common/utils/service_locator.dart';
import 'package:ai_learning_app/src/core/application/auth/auth_bloc.dart';
import 'package:ai_learning_app/src/core/application/auth/auth_event.dart';
import 'package:ai_learning_app/src/core/application/language/language_cubit.dart';
import 'package:ai_learning_app/src/core/application/language/language_state.dart';
import 'package:ai_learning_app/src/core/application/theme/theme_cubit.dart';
import 'package:ai_learning_app/src/core/application/theme/theme_state.dart';
import 'package:ai_learning_app/src/core/infrastructure/repositories/auth_repository_impl.dart';
import 'package:ai_learning_app/src/modules/app/router/app_router.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/application/discover_cubit/discover_leaderboard_cubit.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => LanguageCubit()),
        BlocProvider(
          create: (_) => AuthBloc(
            authRepository: AuthRepositoryImpl(
              userDao: ServiceLocator.userDao,
            ),
            userDao: ServiceLocator.userDao,
          )..add(const AuthCheckRequested()),
        ),
        BlocProvider(
          create: (_) => DiscoverLeaderboardCubit(ServiceLocator.getLeaderboard),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LanguageCubit, LanguageState>(
            builder: (context, langState) {
              return MaterialApp.router(
                routerConfig: AppRouter.router,
                title: 'AI Learning App',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeState.themeMode,
                locale: langState.locale,
                supportedLocales: S.supportedLocales,
                localizationsDelegates: S.localizationsDelegates,
              );
            },
          );
        },
      ),
    );
  }
}
