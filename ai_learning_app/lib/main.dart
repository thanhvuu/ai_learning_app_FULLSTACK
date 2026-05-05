import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// Các màn hình của bạn
import 'screen/login_screen.dart';
import 'screen/welcome_screen.dart';

// Các Providers
import 'providers/quiz_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    // Bọc app bằng MultiProvider để chứa nhiều provider
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dùng Consumer để lắng nghe sự thay đổi từ ThemeProvider
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'AI Learning App',

          // --- Cấu hình giao diện Sáng (Light Theme) ---
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF4FAF5),
            primaryColor: const Color(0xFF0F8A50),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: Color(0xFF1B2A22)),
              titleTextStyle: TextStyle(color: Color(0xFF1B2A22), fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // --- Cấu hình giao diện Tối (Dark Theme) ---
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            primaryColor: const Color(0xFF18C070),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // --- Lắng nghe ThemeProvider để quyết định dùng Sáng hay Tối ---
          themeMode: themeProvider.themeMode,

          // Giữ nguyên luồng kiểm tra màn hình Welcome/Login của bạn
          home: const StartupGate(),
        );
      },
    );
  }
}

class StartupGate extends StatelessWidget {
  const StartupGate({super.key});

  // Hàm đọc shared preferences để kiểm tra xem đã mở app lần đầu chưa
  Future<bool> checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('first_time') ?? true; // nếu chưa có giá trị thì trả về true
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkFirstTime(),
      builder: (context, snapshot) {
        // Nếu đang load thì hiển thị loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF0F8A50)),
            ),
          );
        }
        bool isFirstTime = snapshot.data ?? true;

        // Nếu là lần đầu thì hiển thị welcome screen, ngược lại hiển thị login screen
        if (isFirstTime) {
          return const WelcomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}