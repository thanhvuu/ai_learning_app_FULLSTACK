import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ai_learning_app/firebase_options.dart';

// Các màn hình của bạn
import 'package:ai_learning_app/presentation/views/login_screen.dart';
import 'package:ai_learning_app/presentation/views/welcome_screen.dart';
import 'package:ai_learning_app/presentation/views/no_internet_screen.dart';

// Các Providers
import 'package:ai_learning_app/presentation/view_models/implements/quiz_viewmodel.dart';
import 'package:ai_learning_app/presentation/view_models/theme_view_model.dart';
import 'package:ai_learning_app/presentation/view_models/language_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    // Bọc app bằng MultiProvider để chứa nhiều provider
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuizViewModel()),
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

          // Luôn theo dõi trạng thái kết nối mạng
          home: const ConnectivityGate(),
        );
      },
    );
  }
}


class ConnectivityGate extends StatelessWidget {
  const ConnectivityGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final results = snapshot.data ?? const [ConnectivityResult.mobile];
        final hasInternet = !results.contains(ConnectivityResult.none);

        if (!hasInternet) {
          return const NoInternetScreen();
        }

        return const StartupGate();
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