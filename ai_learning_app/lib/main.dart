import 'package:ai_learning_app/screen/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screen/login_screen.dart';
import 'screen/welcome_screen.dart';
import 'screen/homescreen.dart';
import 'providers/quiz_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
      //boc app bang Provider
    MultiProvider( //MultiProvider chua nhieu provider
      //UserProvider (quản lý tên/avatar user), SettingsProvider (quản lý chế độ Dark Mode/Light Mode)
      providers: [
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: StartupGate());
  }
}

class StartupGate extends StatelessWidget {
  const StartupGate({super.key});
  //Ham doc shared preferences de kiem tra xem da dang nhap chua

  Future<bool> checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('first_time') ??
        true; // neu chua co gia tri thi tra ve true
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkFirstTime(),
      builder: (context, snapshot) {
        // Neu dang load thi hien thi loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        bool isFirstTime = snapshot.data ?? true;

        // Neu la lan dau thi hien thi welcome screen, nguoc lai hien thi login screen
        if (isFirstTime) {
          return WelcomeScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
