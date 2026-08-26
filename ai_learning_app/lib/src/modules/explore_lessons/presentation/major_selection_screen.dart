import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_learning_app/src/common/constants/api_constants.dart';
import 'package:ai_learning_app/src/common/theme/color_manager.dart';
import 'package:ai_learning_app/src/core/infrastructure/network/http_compat.dart' as http;
import 'package:ai_learning_app/src/modules/app/router/app_router.dart';

class MajorSelectionScreen extends StatefulWidget {
  final String username;
  const MajorSelectionScreen({super.key, required this.username});

  @override
  State<MajorSelectionScreen> createState() => _MajorSelectionScreenState();
}

class _MajorSelectionScreenState extends State<MajorSelectionScreen> {
  bool isLoading = false;
  final List<Map<String, dynamic>> majors = [
    {
      "name": "Information Technology",
      "icon": Icons.computer,
      "color": Colors.blue,
    },
    {
      "name": "Business & Finance",
      "icon": Icons.business_center,
      "color": Colors.orange,
    },
    {
      "name": "Medical & Healthcare",
      "icon": Icons.medical_services,
      "color": Colors.red,
    },
    {
      "name": "Tourism & Hospitality",
      "icon": Icons.flight_takeoff,
      "color": Colors.green,
    },
    {"name": "Daily Conversation", "icon": Icons.chat, "color": Colors.teal},
    {"name": "IELTS/TOEIC Prep", "icon": Icons.school, "color": Colors.indigo},
  ];

  Future<void> _selectMajor(String majorName) async {
    setState(() => isLoading = true);

    try {
      final String url =
          "${ApiConstants.users}/update-major?username=${widget.username}&major=${Uri.encodeComponent(majorName)}";
      var response = await http.post(Uri.parse(url));

      if (response.statusCode == 200) {
        if (!mounted) return;
        context.go(
          AppRoutes.roadmap,
          extra: {
            'username': widget.username,
            'major': majorName,
          },
        );
      } else {
        _showError("Không thể lưu chuyên ngành. Vui lòng thử lại!");
      }
    } catch (e) {
      _showError("Lỗi kết nối: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chọn chuyên ngành học",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "Chọn lĩnh vực bạn muốn tập trung phát triển vốn từ vựng và kỹ năng giao tiếp:",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: majors.length,
                  itemBuilder: (context, index) {
                    final major = majors[index];
                    return GestureDetector(
                      onTap: () => _selectMajor(major['name']),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (major['color'] as Color).withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (major['color'] as Color).withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: (major['color'] as Color)
                                  .withOpacity(0.1),
                              child: Icon(
                                major['icon'],
                                size: 30,
                                color: major['color'],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Text(
                                major['name'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          if (isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(
                  color: ColorManager.primaryGreen,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
