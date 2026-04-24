import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart'; // <--- Import Provider
import '../providers/theme_provider.dart'; // <--- Import ThemeProvider
import 'dart:io';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  List<dynamic> leaderboard = [];
  bool isLoading = true;

  // Tên user hiện tại (Dùng để tìm hạng của mình ở thanh dưới cùng)
  final String currentUsername = "Đặng Thanh Vũ";

  @override
  void initState() {
    super.initState();
    fetchLeaderboard();
  }

  // Hàm gọi API lấy danh sách Top 10
  Future<void> fetchLeaderboard() async {
    const String apiUrl = "http://10.0.2.2:8080/api/users/leaderboard";
    try {
      var response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          leaderboard = jsonDecode(utf8.decode(response.bodyBytes));
          isLoading = false;
        });
      }
    } catch (e) {
      print("Lỗi lấy bảng xếp hạng: $e");
      setState(() => isLoading = false);
    }
  }

  // --- HÀM VẼ BỤC VINH QUANG CHO TOP 3 ---
  Widget _buildTop3Podium(Color textColor) {
    if (leaderboard.isEmpty) return const SizedBox();

    // Trích xuất Top 3 (Kiểm tra an toàn nếu DB chưa đủ 3 người)
    var rank1 = leaderboard.isNotEmpty ? leaderboard[0] : null;
    var rank2 = leaderboard.length > 1 ? leaderboard[1] : null;
    var rank3 = leaderboard.length > 2 ? leaderboard[2] : null;

    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Hạng 2 (Bên trái)
          if (rank2 != null) _buildAvatarItem(rank2, 2, 70, Colors.grey[400]!, textColor),
          const SizedBox(width: 15),

          // Hạng 1 (Chính giữa, To nhất)
          if (rank1 != null) _buildAvatarItem(rank1, 1, 95, Colors.amber, textColor),
          const SizedBox(width: 15),

          // Hạng 3 (Bên phải)
          if (rank3 != null) _buildAvatarItem(rank3, 3, 70, Colors.orange[800]!, textColor),
        ],
      ),
    );
  }

  // Widget con: Vẽ từng cái Avatar trên bục (Đã thêm biến textColor)
  Widget _buildAvatarItem(dynamic user, int rank, double size, Color rankColor, Color textColor) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Vòng tròn Avatar
            Container(
              width: size,
              height: size,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: rankColor, width: rank == 1 ? 4 : 3),
                color: Colors.blueAccent, // Chỗ này sau thay bằng ảnh thật
              ),
              child: Icon(Icons.person, color: Colors.white, size: size * 0.6),
            ),
            // Huy hiệu thứ hạng
            Positioned(
              bottom: 0,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: rankColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  "$rank",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 8),
        Text(
          user['username'],
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor), // Đổi màu chữ theo Theme
        ),
        Text(
          "${user['totalXp']} XP",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[500], fontSize: 13), // Sửa xanh lá sáng hơn chút cho hợp nền tối
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tìm thứ hạng của bản thân
    int myIndex = leaderboard.indexWhere((u) => u['username'] == currentUsername);
    int myRank = myIndex >= 0 ? myIndex + 1 : 0;
    int myXp = myIndex >= 0 ? leaderboard[myIndex]['totalXp'] : 0;

    // ==========================================
    // BÍ KÍP MÀU ĐỘNG
    // ==========================================
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B2A22);
    final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color titleColor = isDarkMode ? Colors.greenAccent : const Color(0xFF0F8A50);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Leaderboard', style: TextStyle(fontWeight: FontWeight.bold, color: titleColor)),
        backgroundColor: Colors.transparent, // Để trong suốt để ăn theo màu bgColor
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Row(
              children: [
                Icon(Icons.star, color: isDarkMode ? Colors.deepPurple[200] : Colors.deepPurpleAccent),
                const SizedBox(width: 5),
                Text("Mùa 12", style: TextStyle(color: isDarkMode ? Colors.deepPurple[200] : Colors.deepPurple, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: titleColor))
          : Column(
        children: [
          // Phần bục vinh quang Top 3 (Truyền textColor vào)
          _buildTop3Podium(textColor),

          // Tiêu đề danh sách
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Chi tiết thứ hạng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                Text("Cập nhật 5 phút trước", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              ],
            ),
          ),

          // Danh sách từ hạng 4 trở đi
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: leaderboard.length > 3 ? leaderboard.length - 3 : 0,
              itemBuilder: (context, idx) {
                int realIndex = idx + 3;
                final user = leaderboard[realIndex];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  decoration: BoxDecoration(
                    color: cardColor, // Màu nền thẻ động
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: isDarkMode ? Colors.black54 : Colors.grey.withOpacity(0.1), blurRadius: 5)
                    ],
                  ),
                  child: Row(
                    children: [
                      Text("${realIndex + 1}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[500])),
                      const SizedBox(width: 15),
                      const CircleAvatar(radius: 20, backgroundColor: Colors.blueGrey, child: Icon(Icons.person, color: Colors.white, size: 20)),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(user['username'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                      ),
                      Text("${user['totalXp']} XP", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
                      const SizedBox(width: 10),
                      const Icon(Icons.keyboard_arrow_up, color: Colors.green),
                    ],
                  ),
                );
              },
            ),
          ),

          // --- THANH STICKY HIỂN THỊ THỨ HẠNG BẢN THÂN ---
          // Thanh này mình vẫn giữ màu Xanh lá đậm (hoặc hơi tối đi chút) để nó nổi bật dưới cùng màn hình
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF0A5E35) : const Color(0xFF0F8A50), // Tối màu xanh đi 1 chút nếu ở Dark Mode
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(
                    myRank > 0 ? "$myRank" : "-",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "THỨ HẠNG CỦA BẠN",
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10, letterSpacing: 1.2),
                      ),
                      Text(
                        currentUsername,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Cần nỗ lực hơn", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
                    Text(
                      "$myXp XP",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}