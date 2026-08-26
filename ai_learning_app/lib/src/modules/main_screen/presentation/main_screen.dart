import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_learning_app/src/common/constants/api_constants.dart';
import 'package:ai_learning_app/src/common/theme/color_manager.dart';
import 'package:ai_learning_app/src/core/application/theme_provider.dart';
import 'package:ai_learning_app/src/core/infrastructure/network/http_compat.dart' as http;
import 'package:ai_learning_app/src/modules/explore_lessons/presentation/discover_screen.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/presentation/my_lessons_screen.dart';
import 'package:ai_learning_app/src/modules/home/presentation/home_screen.dart';
import 'package:ai_learning_app/src/modules/profile/presentation/profile_screen.dart';

class MainScreen extends StatefulWidget {
  final String username;
  final String? major;
  final int initialIndex;

  const MainScreen({
    super.key,
    required this.username,
    this.major,
    this.initialIndex = 0,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  final GlobalKey<State<MyLessonsScreen>> _lessonsKey = GlobalKey();
  int _streak = 0;
  int _xp = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final String url = "${ApiConstants.users}/profile?username=${widget.username}";
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = jsonDecode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            _streak = data['streak'] ?? 0;
            _xp = data['totalXp'] ?? 0;
          });
        }
      }
    } catch (e) {
      debugPrint('Lỗi lấy dữ liệu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    const Color primaryGreen = ColorManager.primaryGreen;

    return Scaffold(
      backgroundColor: bgColor,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(
            username: widget.username,
            major: widget.major,
          ),
          MyLessonsScreen(key: _lessonsKey, username: widget.username),
          DiscoverScreen(username: widget.username),
          ProfileScreen(
            username: widget.username,
            xp: _xp,
            streak: _streak,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? ColorManager.darkCard : ColorManager.lightCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black54
                  : Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  Icons.home_rounded,
                  Icons.home_outlined,
                  "Home",
                  0,
                  primaryGreen,
                  isDarkMode,
                ),
                _buildNavItem(
                  Icons.menu_book_rounded,
                  Icons.menu_book_outlined,
                  "Lessons",
                  1,
                  primaryGreen,
                  isDarkMode,
                ),
                _buildNavItem(
                  Icons.explore_rounded,
                  Icons.explore_outlined,
                  "Discover",
                  2,
                  primaryGreen,
                  isDarkMode,
                ),
                _buildNavItem(
                  Icons.person_rounded,
                  Icons.person_outline_rounded,
                  "Profile",
                  3,
                  primaryGreen,
                  isDarkMode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
    int index,
    Color activeColor,
    bool isDarkMode,
  ) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (index == 1) {
          final dynamic lessonsState = _lessonsKey.currentState;
          if (lessonsState != null) {
            lessonsState.fetchMyLessons();
            lessonsState.fetchProgress();
          }
        }
        if (index == 3) {
          fetchUserData();
        }
      },
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive
                  ? activeColor
                  : (isDarkMode ? Colors.grey[500] : Colors.grey[500]),
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive
                    ? activeColor
                    : (isDarkMode ? Colors.grey[500] : Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
