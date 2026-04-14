import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  Widget _buildTop3Podium() {
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
          if (rank2 != null) _buildAvatarItem(rank2, 2, 70, Colors.grey[400]!),
          const SizedBox(width: 15),

          // Hạng 1 (Chính giữa, To nhất)
          if (rank1 != null) _buildAvatarItem(rank1, 1, 95, Colors.amber),
          const SizedBox(width: 15),

          // Hạng 3 (Bên phải)
          if (rank3 != null) _buildAvatarItem(rank3, 3, 70, Colors.orange[800]!),
        ],
      ),
    );
  }

  // Widget con: Vẽ từng cái Avatar trên bục
  Widget _buildAvatarItem(dynamic user, int rank, double size, Color rankColor) {
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
                color: Colors.blueAccent, // Chỗ này sau thay bằng ảnh mảng
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        Text(
          "${user['totalXp']} XP",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700], fontSize: 13),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF5),
      appBar: AppBar(
        title: const Text('Leaderboard', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F8A50))),
        backgroundColor: const Color(0xFFF4FAF5),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false, // Ẩn nút back
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.deepPurpleAccent),
                const SizedBox(width: 5),
                const Text("Mùa 12", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F8A50)))
          : Column(
        children: [
          // Phần bục vinh quang Top 3
          _buildTop3Podium(),

          // Tiêu đề danh sách
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Chi tiết thứ hạng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Cập nhật 5 phút trước", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),

          // Danh sách từ hạng 4 trở đi
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              // Bỏ qua 3 người đầu (hoặc ít hơn nếu DB ít người)
              itemCount: leaderboard.length > 3 ? leaderboard.length - 3 : 0,
              itemBuilder: (context, idx) {
                int realIndex = idx + 3; // Lấy từ hạng 4 (index 3)
                final user = leaderboard[realIndex];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)],
                  ),
                  child: Row(
                    children: [
                      Text("${realIndex + 1}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
                      const SizedBox(width: 15),
                      const CircleAvatar(radius: 20, backgroundColor: Colors.blueGrey, child: Icon(Icons.person, color: Colors.white, size: 20)),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(user['username'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      Text("${user['totalXp']} XP", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(width: 10),
                      const Icon(Icons.keyboard_arrow_up, color: Colors.green), // Icon xu hướng
                    ],
                  ),
                );
              },
            ),
          ),

          // --- THANH STICKY HIỂN THỊ THỨ HẠNG BẢN THÂN ---
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0xFF0F8A50),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                // Vòng tròn thứ hạng của mình
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
                // Tên và thông báo
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
                // XP hiện tại
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