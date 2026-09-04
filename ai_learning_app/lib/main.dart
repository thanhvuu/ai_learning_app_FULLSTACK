import 'dart:async';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ai_learning_app/firebase_options.dart';
import 'package:ai_learning_app/src/common/utils/logger.dart';
import 'package:ai_learning_app/src/core/di/injection.dart';
import 'package:ai_learning_app/src/modules/app/presentation/app_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    AppLogger.error(details.exceptionAsString(), error: details.exception, stackTrace: details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    AppLogger.error('Unhandled platform error: $error', error: error, stackTrace: stackTrace);
    return true;
  };

  await runZonedGuarded(
    () async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      await configureDependencies();

      runApp(const AppWidget());
    },
    (error, stackTrace) {
      AppLogger.error('Unhandled zone error: $error', error: error, stackTrace: stackTrace);
    },
  );
}
