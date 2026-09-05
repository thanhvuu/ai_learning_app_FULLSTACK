import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_learning_app/generated/l10n.dart';
import 'package:ai_learning_app/src/common/extensions/build_context_ext.dart';
import 'package:ai_learning_app/src/common/theme/color_manager.dart';
import 'package:ai_learning_app/src/common/utils/service_locator.dart';
import 'package:ai_learning_app/src/core/application/auth/auth_bloc.dart';
import 'package:ai_learning_app/src/core/application/auth/auth_event.dart';
import 'package:ai_learning_app/src/core/application/language/language_cubit.dart';
import 'package:ai_learning_app/src/core/application/theme/theme_cubit.dart';
import 'package:ai_learning_app/src/modules/app/router/app_router.dart';

class ProfileScreen extends StatelessWidget {
  final String username;
  final int xp;
  final int streak;

  const ProfileScreen({
    super.key,
    required this.username,
    required this.xp,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isDarkMode = context.watch<ThemeCubit>().state.isDarkMode;
    final langState = context.watch<LanguageCubit>().state;
    final S s = S(langState.languageCode);

    final currentUsername = (authState.user?.username.isNotEmpty == true)
        ? authState.user!.username
        : (username.isNotEmpty ? username : s.translate('student'));
    final currentXp = authState.user?.totalXp ?? xp;
    final currentStreak = authState.user?.streak ?? streak;

    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color textColor = isDarkMode ? ColorManager.darkTextPrimary : ColorManager.lightTextPrimary;
    final Color cardColor = isDarkMode ? ColorManager.darkCard : ColorManager.lightCard;

    String formattedXp = currentXp >= 1000
        ? '${(currentXp / 1000).toStringAsFixed(1)}k'
        : currentXp.toString();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          s.translate('profile'),
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          children: [
            _buildAvatarSection(context, s),
            const SizedBox(height: 15),
            Text(
              currentUsername,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            _buildLevelBadge(),
            const SizedBox(height: 30),
            Row(
              children: [
                _buildStatCard(
                  Icons.bolt,
                  ColorManager.tealAccent,
                  formattedXp,
                  s.translate('total_xp'),
                  cardColor,
                  textColor,
                ),
                const SizedBox(width: 10),
                FutureBuilder<int>(
                  future: ServiceLocator.lessonRepository.getCachedLessonCount(),
                  builder: (context, snapshot) {
                    final lessonCount = snapshot.hasData ? snapshot.data!.toString() : '...';
                    return _buildStatCard(
                      Icons.menu_book,
                      ColorManager.purpleAccent,
                      lessonCount,
                      s.translate('lessons'),
                      cardColor,
                      textColor,
                    );
                  },
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  Icons.local_fire_department,
                  ColorManager.orangeAccent,
                  currentStreak.toString(),
                  s.translate('streak'),
                  cardColor,
                  textColor,
                ),
              ],
            ),
            const SizedBox(height: 35),
            _buildSectionTitle(s.translate('account')),
            _buildCardGroup(cardColor, [
              _buildListTile(
                Icons.person,
                s.translate('change_account_info'),
                textColor,
                onTap: () => _showEditProfileDialog(context, s, currentUsername),
              ),
              _buildDivider(),
              _buildListTile(
                Icons.lock,
                'Đổi mật khẩu',
                textColor,
                onTap: () => context.push(AppRoutes.changePassword),
              ),
              _buildDivider(),
              _buildListTile(
                Icons.delete_forever,
                'Xóa tài khoản',
                Colors.red,
                onTap: () => _handleDeleteAccount(context, s),
              ),
            ]),
            const SizedBox(height: 25),
            _buildSectionTitle(s.translate('preferences')),
            _buildCardGroup(cardColor, [
              _buildSwitchTile(
                Icons.dark_mode,
                s.translate('dark_mode'),
                isDarkMode,
                textColor,
                (val) {
                  context.read<ThemeCubit>().toggleTheme(val);
                  context.showSnackBar(
                    val
                        ? s.translate('dark_mode_on')
                        : s.translate('dark_mode_off'),
                  );
                },
              ),
              _buildDivider(),
              _buildListTile(
                Icons.language,
                s.translate('language'),
                textColor,
                trailingText: langState.languageName,
                onTap: () => _showLanguageDialog(context, s),
              ),
            ]),
            const SizedBox(height: 25),
            _buildSectionTitle(s.translate('other')),
            _buildCardGroup(cardColor, [
              _buildListTile(
                Icons.help_outline,
                s.translate('help_center'),
                textColor,
                onTap: () => context.push(AppRoutes.contact),
              ),
              _buildDivider(),
              _buildListTile(
                Icons.info_outline,
                s.translate('about_us'),
                textColor,
                onTap: () => _showAboutDialog(context, s),
              ),
              _buildDivider(),
              _buildListTile(
                Icons.privacy_tip_outlined,
                'Chính sách quyền riêng tư',
                textColor,
                onTap: () => _showPrivacyPolicyDialog(context, s),
              ),
            ]),
            const SizedBox(height: 35),
            _buildLogoutButton(context, cardColor, s),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, S s) {
    final isDarkMode = context.read<ThemeCubit>().state.isDarkMode;
    final currentCode = context.read<LanguageCubit>().state.languageCode;
    final Color dialogBg = isDarkMode ? ColorManager.darkCard : ColorManager.lightCard;
    final Color textColor = isDarkMode ? ColorManager.darkTextPrimary : ColorManager.lightTextPrimary;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          s.translate('choose_language'),
          style: const TextStyle(
            color: ColorManager.primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              flag: '🇻🇳',
              name: 'Tiếng Việt',
              code: 'vi',
              isSelected: currentCode == 'vi',
              textColor: textColor,
              isDarkMode: isDarkMode,
              onTap: () {
                context.read<LanguageCubit>().setLanguage('vi');
                Navigator.pop(dialogCtx);
                context.showSnackBar('${s.translate('language_changed')} Tiếng Việt');
              },
            ),
            const SizedBox(height: 10),
            _buildLanguageOption(
              flag: '🇺🇸',
              name: 'English',
              code: 'en',
              isSelected: currentCode == 'en',
              textColor: textColor,
              isDarkMode: isDarkMode,
              onTap: () {
                context.read<LanguageCubit>().setLanguage('en');
                Navigator.pop(dialogCtx);
                context.showSnackBar('${s.translate('language_changed')} English');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String flag,
    required String name,
    required String code,
    required bool isSelected,
    required Color textColor,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorManager.primaryGreen.withOpacity(0.1)
              : (isDarkMode
                  ? ColorManager.darkInputBg
                  : ColorManager.lightBackground),
          borderRadius: BorderRadius.circular(15),
          border: isSelected
              ? Border.all(color: ColorManager.primaryGreen, width: 2)
              : Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isSelected ? ColorManager.primaryGreen : textColor,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: ColorManager.primaryGreen,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, S s) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          s.translate('about_app'),
          style: const TextStyle(
            color: ColorManager.primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(s.translate('about_app_content')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              s.translate('close'),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, S s, String initialName) {
    final nameController = TextEditingController(text: initialName);
    final formKey = GlobalKey<FormState>();
    final isDarkMode = context.read<ThemeCubit>().state.isDarkMode;
    final dialogBg = isDarkMode ? ColorManager.darkCard : ColorManager.lightCard;
    final textColor = isDarkMode ? ColorManager.darkTextPrimary : ColorManager.lightTextPrimary;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.person, color: ColorManager.primaryGreen),
            const SizedBox(width: 10),
            Text(
              s.translate('change_account_info'),
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 18),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Tên hiển thị',
                  labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: ColorManager.primaryGreen, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tên không được để trống';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(s.translate('cancel'), style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorManager.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final newName = nameController.text.trim();
                Navigator.pop(dialogCtx);
                context.read<AuthBloc>().add(AuthProfileUpdated(username: newName));
                context.showSnackBar('Cập nhật thông tin thành công!');
              }
            },
            child: const Text('Lưu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context, S s) {
    final isDarkMode = context.read<ThemeCubit>().state.isDarkMode;
    final dialogBg = isDarkMode ? ColorManager.darkCard : ColorManager.lightCard;
    final textColor = isDarkMode ? ColorManager.darkTextPrimary : ColorManager.lightTextPrimary;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.privacy_tip_outlined, color: ColorManager.primaryGreen),
            const SizedBox(width: 10),
            Text(
              'Chính sách quyền riêng tư',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 18),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. Dữ liệu thu thập & Sử dụng',
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 6),
              Text(
                'Ứng dụng thu thập thông tin tài khoản (email, tên hiển thị) và tiến trình học tập (điểm XP, chuỗi ngày streak, bài học đã hoàn thành) nhằm đồng bộ kết quả cá nhân.',
                style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text(
                '2. Quyền Thiết bị',
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 6),
              Text(
                '• Micro: Được sử dụng độc quyền để nhận diện giọng nói khi thực hành phát âm (Speaking quiz). Ứng dụng không ghi âm hoặc lưu trữ file giọng nói của bạn ra bên ngoài.\n• Bộ nhớ / Ảnh: Được dùng khi bạn chọn tải tài liệu học tập hoặc thay đổi ảnh đại diện.',
                style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text(
                '3. Bảo mật & Xóa tài khoản',
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 6),
              Text(
                'Mật khẩu và thông tin của bạn được bảo mật an toàn. Bạn có toàn quyền xóa vĩnh viễn tài khoản và mọi dữ liệu liên quan bất kỳ lúc nào tại mục "Xóa tài khoản".',
                style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorManager.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(s.translate('close'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context, S s) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.logout, color: Colors.red),
            const SizedBox(width: 10),
            Text(
              s.translate('logout_confirm_title'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(s.translate('logout_confirm_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              s.translate('cancel'),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              if (context.mounted) {
                context.go(AppRoutes.welcome);
                context.showSnackBar(s.translate('logout_success'));
              }
            },
            child: Text(
              s.translate('logout_confirm_title'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDeleteAccount(BuildContext context, S s) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text(
              'Xóa tài khoản',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
        content: const Text(
          'Hành động này sẽ xóa vĩnh viễn tài khoản và toàn bộ tiến trình học tập của bạn. Bạn có chắc chắn muốn xóa không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              s.translate('cancel'),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<AuthBloc>().add(const AuthDeleteAccountRequested());
              if (context.mounted) {
                context.go(AppRoutes.welcome);
                context.showSnackBar('Tài khoản đã được xóa thành công.');
              }
            },
            child: const Text(
              'Xác nhận xóa',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context, S s) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ColorManager.primaryGreen, width: 2.5),
          ),
          child: const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF1E3B4D),
            child: Icon(Icons.person, size: 60, color: Colors.white70),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () => context.showSnackBar(s.translate('opening_gallery')),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ColorManager.purpleAccent,
                shape: BoxShape.circle,
                border: Border.all(color: ColorManager.lightBackground, width: 3),
              ),
              child: const Icon(Icons.edit, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE2F1E8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.military_tech, color: ColorManager.primaryGreen, size: 18),
          SizedBox(width: 5),
          Text(
            "Level 12 | Intermediate",
            style: TextStyle(
              color: ColorManager.lightTextPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    Color iconColor,
    String value,
    String label,
    Color cardColor,
    Color textColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 30),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: ColorManager.primaryGreen,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildCardGroup(Color cardColor, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile(
    IconData icon,
    String title,
    Color textColor, {
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: textColor, size: 26),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: textColor,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                trailingText,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade500),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    bool value,
    Color textColor,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: textColor, size: 26),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: textColor,
        ),
      ),
      trailing: Switch(
        value: value,
        activeColor: Colors.white,
        activeTrackColor: ColorManager.primaryGreen,
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: Colors.grey.shade300,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 60,
      endIndent: 20,
      color: Colors.grey.withOpacity(0.2),
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    Color cardColor,
    S s,
  ) {
    return GestureDetector(
      onTap: () => _handleLogout(context, s),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: ColorManager.error),
            const SizedBox(width: 10),
            Text(
              s.translate('logout'),
              style: const TextStyle(
                color: ColorManager.error,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
