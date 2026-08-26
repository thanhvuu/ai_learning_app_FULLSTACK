import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_learning_app/generated/l10n.dart';
import 'package:ai_learning_app/src/common/theme/app_theme.dart';
import 'package:ai_learning_app/src/common/utils/service_locator.dart';
import 'package:ai_learning_app/src/core/application/auth_provider.dart';
import 'package:ai_learning_app/src/core/application/language_provider.dart';
import 'package:ai_learning_app/src/core/application/theme_provider.dart';
import 'package:ai_learning_app/src/modules/app/router/app_router.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/application/discover_view_model.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/application/quiz_view_model.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => DiscoverViewModel(ServiceLocator.getLeaderboard),
        ),
        ChangeNotifierProvider(create: (_) => QuizViewModel()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp.router(
            routerConfig: AppRouter.router,
            title: 'AI Learning App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: languageProvider.locale,
            supportedLocales: S.supportedLocales,
            localizationsDelegates: S.localizationsDelegates,
          );
        },
      ),
    );
  }
}
