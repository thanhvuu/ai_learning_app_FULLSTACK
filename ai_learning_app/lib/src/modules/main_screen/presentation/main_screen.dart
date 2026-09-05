import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_learning_app/src/common/theme/color_manager.dart';
import 'package:ai_learning_app/src/core/application/auth/auth_bloc.dart';
import 'package:ai_learning_app/src/core/application/auth/auth_event.dart';
import 'package:ai_learning_app/src/core/application/theme/theme_cubit.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/presentation/discover_screen.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/presentation/my_lessons_screen.dart';
import 'package:ai_learning_app/src/modules/home/presentation/home_screen.dart';
import 'package:ai_learning_app/src/modules/profile/presentation/profile_screen.dart';

class MainScreen extends StatefulWidget {
  final String username;
  final int initialIndex;

  const MainScreen({
    super.key,
    required this.username,
    this.initialIndex = 0,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    context.read<AuthBloc>().add(AuthUserProfileFetchRequested(username: widget.username),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeCubit>().state.isDarkMode;
    final user = context.watch<AuthBloc>().state.user;
    final currentUsername = user?.username.isNotEmpty == true
        ? user!.username
        : widget.username;
    final currentXp = user?.totalXp ?? 0;
    final currentStreak = user?.streak ?? 0;

    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    const Color primaryGreen = ColorManager.primaryGreen;

    return Scaffold(
      backgroundColor: bgColor,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(
            username: currentUsername,
          ),
          MyLessonsScreen(username: currentUsername),
          DiscoverScreen(username: currentUsername),
          ProfileScreen(
            username: currentUsername,
            xp: currentXp,
            streak: currentStreak,
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
        if (index == 3) {
          context.read<AuthBloc>().add(
                AuthUserProfileFetchRequested(username: widget.username),
              );
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
