import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <--- Import Provider
import '../providers/theme_provider.dart'; // <--- Import ThemeProvider của bạn
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

    // 2. CHỈNH MÀU ĐỘNG THEO THEME
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
          "Profile",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: textColor),
            onPressed: () => _showSnackBar("Đang mở Cài đặt chung..."),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          children: [
            _buildAvatarSection(),
            const SizedBox(height: 15),
            Text(
              widget.username.isNotEmpty ? widget.username : "Học viên",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 8),
            _buildLevelBadge(),
            const SizedBox(height: 30),

            // Truyền cardColor và textColor xuống các thẻ Thống kê
            Row(
              children: [
                _buildStatCard(Icons.bolt, Colors.tealAccent.shade700, formattedXp, "TOTAL XP", cardColor, textColor),
                const SizedBox(width: 10),
                _buildStatCard(Icons.menu_book, Colors.deepPurple, "48", "LESSONS", cardColor, textColor),
                const SizedBox(width: 10),
                _buildStatCard(Icons.local_fire_department, Colors.deepOrange, widget.streak.toString(), "STREAK", cardColor, textColor),
              ],
            ),
            const SizedBox(height: 35),

            _buildSectionTitle("ACCOUNT"),
            _buildCardGroup(cardColor, [
              _buildListTile(Icons.person, "Change Account Info", textColor, onTap: () => _showSnackBar("Đang mở trang Đổi thông tin...")),
              _buildDivider(),
              _buildListTile(Icons.lock, "Privacy Settings", textColor, onTap: () => _showSnackBar("Đang mở Cài đặt bảo mật...")),
            ]),
            const SizedBox(height: 25),

            _buildSectionTitle("PREFERENCES"),
            _buildCardGroup(cardColor, [
              // NÚT CÔNG TẮC ĐÃ ĐƯỢC NỐI VỚI PROVIDER
              _buildSwitchTile(Icons.dark_mode, "Dark Mode", isDarkMode, textColor, (val) {
                themeProvider.toggleTheme(val); // <--- Gọi hàm đổi màu toàn app
                _showSnackBar(val ? "Đã bật Dark Mode" : "Đã tắt Dark Mode");
              }),
              _buildDivider(),
              _buildListTile(Icons.language, "Language", textColor, trailingText: "English", onTap: () => _showSnackBar("Tính năng đổi ngôn ngữ đang phát triển!")),
              _buildDivider(),
              _buildListTile(Icons.notifications, "Notifications", textColor, onTap: () => _showSnackBar("Đang mở Cài đặt thông báo...")),
            ]),
            const SizedBox(height: 25),

            _buildSectionTitle("OTHER"),
            _buildCardGroup(cardColor, [
              _buildListTile(Icons.help_outline, "Help Center", textColor, onTap: () => _showSnackBar("Đang kết nối đến Trung tâm hỗ trợ...")),
              _buildDivider(),
              _buildListTile(Icons.info_outline, "About Us", textColor, onTap: () => _showAboutDialog()),
            ]),
            const SizedBox(height: 35),

            _buildLogoutButton(context, cardColor),
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

  void _showAboutDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Về App", style: TextStyle(color: Color(0xFF0F8A50), fontWeight: FontWeight.bold)),
          content: const Text("Phiên bản 1.0.0\n\nỨng dụng học tập thông minh tích hợp AI, giúp bạn biến mọi tài liệu thành bài giảng tương tác.",),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Đóng", style: TextStyle(color: Colors.grey)))
          ],
        )
    );
  }

  void _handleLogout() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 10),
              Text("Đăng xuất", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text("Bạn có chắc chắn muốn đăng xuất khỏi tài khoản này không?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Hủy", style: TextStyle(color: Colors.grey))
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
                _showSnackBar("Đã đăng xuất thành công!");
              },
              child: const Text("Đăng xuất", style: TextStyle(color: Colors.white)),
            )
          ],
        )
    );
  }

  // --- CÁC WIDGET GIAO DIỆN ĐÃ ĐƯỢC CẬP NHẬT MÀU SẮC ĐỘNG ---

  Widget _buildAvatarSection() {
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
            onTap: () => _showSnackBar("Đang mở thư viện ảnh..."),
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
  Widget _buildLogoutButton(BuildContext context, Color cardColor) {
    return GestureDetector(
      onTap: _handleLogout,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Color(0xFFD32F2F)),
            SizedBox(width: 10),
            Text("Logout", style: TextStyle(color: Color(0xFFD32F2F), fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}