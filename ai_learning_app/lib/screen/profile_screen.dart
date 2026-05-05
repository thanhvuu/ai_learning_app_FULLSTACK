import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <--- Import Provider
import '../providers/theme_provider.dart'; // <--- Import ThemeProvider của bạn
import '../providers/language_provider.dart'; // <--- Import LanguageProvider
import '../l10n/app_localizations.dart'; // <--- Import bộ dịch
import 'welcome_screen.dart';
class ProfileScreen extends StatefulWidget {
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
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Đã xóa biến isDarkMode ở đây vì bây giờ Provider sẽ quản lý nó!

  @override
  Widget build(BuildContext context) {
    // 1. LẮNG NGHE TRẠNG THÁI SÁNG/TỐI TỪ PROVIDER
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    // 2. LẮNG NGHE TRẠNG THÁI NGÔN NGỮ TỪ PROVIDER
    final langProvider = LanguageProvider.safeOf(context);
    final t = AppLocalizations(langProvider.languageCode);

    // 3. CHỈNH MÀU ĐỘNG THEO THEME
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B2A22);
    final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    String formattedXp = widget.xp >= 1000
        ? '${(widget.xp / 1000).toStringAsFixed(1)}k'
        : widget.xp.toString();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          t.translate('profile'),
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: textColor),
            onPressed: () => _showSnackBar(t.translate('opening_settings')),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          children: [
            _buildAvatarSection(t),
            const SizedBox(height: 15),
            Text(
              widget.username.isNotEmpty ? widget.username : t.translate('student'),
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 8),
            _buildLevelBadge(),
            const SizedBox(height: 30),

            // Truyền cardColor và textColor xuống các thẻ Thống kê
            Row(
              children: [
                _buildStatCard(Icons.bolt, Colors.tealAccent.shade700, formattedXp, t.translate('total_xp'), cardColor, textColor),
                const SizedBox(width: 10),
                _buildStatCard(Icons.menu_book, Colors.deepPurple, "48", t.translate('lessons'), cardColor, textColor),
                const SizedBox(width: 10),
                _buildStatCard(Icons.local_fire_department, Colors.deepOrange, widget.streak.toString(), t.translate('streak'), cardColor, textColor),
              ],
            ),
            const SizedBox(height: 35),

            _buildSectionTitle(t.translate('account')),
            _buildCardGroup(cardColor, [
              _buildListTile(Icons.person, t.translate('change_account_info'), textColor, onTap: () => _showSnackBar(t.translate('opening_account_info'))),
              _buildDivider(),
              _buildListTile(Icons.lock, t.translate('privacy_settings'), textColor, onTap: () => _showSnackBar(t.translate('opening_privacy'))),
            ]),
            const SizedBox(height: 25),

            _buildSectionTitle(t.translate('preferences')),
            _buildCardGroup(cardColor, [
              // NÚT CÔNG TẮC ĐÃ ĐƯỢC NỐI VỚI PROVIDER
              _buildSwitchTile(Icons.dark_mode, t.translate('dark_mode'), isDarkMode, textColor, (val) {
                themeProvider.toggleTheme(val); // <--- Gọi hàm đổi màu toàn app
                _showSnackBar(val ? t.translate('dark_mode_on') : t.translate('dark_mode_off'));
              }),
              _buildDivider(),
              // NÚT CHỌN NGÔN NGỮ — BẤM VÀO SẼ HIỂN THỊ DIALOG CHỌN
              _buildListTile(Icons.language, t.translate('language'), textColor, trailingText: langProvider.languageName, onTap: () => _showLanguageDialog(langProvider, t)),
              _buildDivider(),
              _buildListTile(Icons.notifications, t.translate('notifications'), textColor, onTap: () => _showSnackBar(t.translate('opening_notifications'))),
            ]),
            const SizedBox(height: 25),

            _buildSectionTitle(t.translate('other')),
            _buildCardGroup(cardColor, [
              _buildListTile(Icons.help_outline, t.translate('help_center'), textColor, onTap: () => _showSnackBar(t.translate('connecting_help'))),
              _buildDivider(),
              _buildListTile(Icons.info_outline, t.translate('about_us'), textColor, onTap: () => _showAboutDialog(t)),
            ]),
            const SizedBox(height: 35),

            _buildLogoutButton(context, cardColor, t),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- CÁC HÀM XỬ LÝ SỰ KIỆN ---

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: const Color(0xFF0F8A50),
        )
    );
  }

  // === DIALOG CHỌN NGÔN NGỮ MỚI ===
  void _showLanguageDialog(LanguageProvider langProvider, AppLocalizations t) {
    final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final Color dialogBg = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B2A22);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          t.translate('choose_language'),
          style: const TextStyle(color: Color(0xFF0F8A50), fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              flag: '🇻🇳',
              name: 'Tiếng Việt',
              code: 'vi',
              isSelected: langProvider.languageCode == 'vi',
              textColor: textColor,
              isDarkMode: isDarkMode,
              onTap: () {
                langProvider.setLanguage('vi');
                Navigator.pop(context);
                _showSnackBar('${t.translate('language_changed')} Tiếng Việt');
              },
            ),
            const SizedBox(height: 10),
            _buildLanguageOption(
              flag: '🇺🇸',
              name: 'English',
              code: 'en',
              isSelected: langProvider.languageCode == 'en',
              textColor: textColor,
              isDarkMode: isDarkMode,
              onTap: () {
                langProvider.setLanguage('en');
                Navigator.pop(context);
                _showSnackBar('${t.translate('language_changed')} English');
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
              ? const Color(0xFF0F8A50).withOpacity(0.1)
              : (isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFF4FAF5)),
          borderRadius: BorderRadius.circular(15),
          border: isSelected
              ? Border.all(color: const Color(0xFF0F8A50), width: 2)
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
                  color: isSelected ? const Color(0xFF0F8A50) : textColor,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF0F8A50), size: 24),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(AppLocalizations t) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(t.translate('about_app'), style: const TextStyle(color: Color(0xFF0F8A50), fontWeight: FontWeight.bold)),
          content: Text(t.translate('about_app_content')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(t.translate('close'), style: const TextStyle(color: Colors.grey)))
          ],
        )
    );
  }

  void _handleLogout(AppLocalizations t) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.logout, color: Colors.red),
              const SizedBox(width: 10),
              Text(t.translate('logout_confirm_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(t.translate('logout_confirm_message')),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(t.translate('cancel'), style: const TextStyle(color: Colors.grey))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                ); // Tắt Dialog
                _showSnackBar(t.translate('logout_success'));
              },
              child: Text(t.translate('logout_confirm_title'), style: const TextStyle(color: Colors.white)),
            )
          ],
        )
    );
  }

  // --- CÁC WIDGET GIAO DIỆN ĐÃ ĐƯỢC CẬP NHẬT MÀU SẮC ĐỘNG ---

  Widget _buildAvatarSection(AppLocalizations t) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF0F8A50), width: 2.5)),
          child: const CircleAvatar(radius: 50, backgroundColor: Color(0xFF1E3B4D), child: Icon(Icons.person, size: 60, color: Colors.white70)),
        ),
        Positioned(
          right: 0, bottom: 0,
          child: GestureDetector(
            onTap: () => _showSnackBar(t.translate('opening_gallery')),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF6A4CFF), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFF4FAF5), width: 3)),
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
      decoration: BoxDecoration(color: const Color(0xFFE2F1E8), borderRadius: BorderRadius.circular(20)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.military_tech, color: Color(0xFF0F8A50), size: 18),
          SizedBox(width: 5),
          Text("Level 12 | Intermediate", style: TextStyle(color: Color(0xFF1B2A22), fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  // Thêm biến cardColor và textColor
  Widget _buildStatCard(IconData icon, Color iconColor, String value, String label, Color cardColor, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 30),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 5),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 5),
      child: Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F8A50), letterSpacing: 1.2))),
    );
  }

  // Thêm biến cardColor
  Widget _buildCardGroup(Color cardColor, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Column(children: children),
    );
  }

  // Thêm biến textColor
  Widget _buildListTile(IconData icon, String title, Color textColor, {String? trailingText, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: textColor, size: 26),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: textColor)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) Padding(padding: const EdgeInsets.only(right: 8.0), child: Text(trailingText, style: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontWeight: FontWeight.w500))),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade500),
        ],
      ),
    );
  }

  // Thêm biến textColor
  Widget _buildSwitchTile(IconData icon, String title, bool value, Color textColor, ValueChanged<bool> onChanged) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: textColor, size: 26),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: textColor)),
      trailing: Switch(
          value: value,
          activeColor: Colors.white,
          activeTrackColor: const Color(0xFF0F8A50), // Sáng lên màu xanh khi bật
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey.shade300,
          onChanged: onChanged
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, indent: 60, endIndent: 20, color: Colors.grey.withOpacity(0.2));
  }

  // Thêm biến cardColor
  Widget _buildLogoutButton(BuildContext context, Color cardColor, AppLocalizations t) {
    return GestureDetector(
      onTap: () => _handleLogout(t),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: Color(0xFFD32F2F)),
            const SizedBox(width: 10),
            Text(t.translate('logout'), style: const TextStyle(color: Color(0xFFD32F2F), fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}