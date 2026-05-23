import 'package:flutter/material.dart';
import 'roadmap_screen.dart';
import 'homescreen.dart';
import 'package:http/http.dart' as http;
import 'package:ai_learning_app/core/config/api_config.dart';

class MajorSelectionScreen extends StatefulWidget {
  final String username;
  const MajorSelectionScreen({super.key, required this.username});

  @override
  State<MajorSelectionScreen> createState() => _MajorSelectionScreenState();
}

class _MajorSelectionScreenState extends State<MajorSelectionScreen> {
  bool isLoading = false;
  final List<Map<String, dynamic>> majors = [
    {"name": "Information Technology", "icon": Icons.computer, "color": Colors.blue},
    {"name": "Business & Finance", "icon": Icons.business_center, "color": Colors.orange},
    {"name": "Medical & Healthcare", "icon": Icons.medical_services, "color": Colors.red},
    {"name": "Travel & Tourism", "icon": Icons.flight, "color": Colors.green},
    {"name": "Engineering", "icon": Icons.engineering, "color": Colors.blueGrey},
    {"name": "Art & Design", "icon": Icons.palette, "color": Colors.purple},
    {"name": "Daily Conversation", "icon": Icons.chat, "color": Colors.teal},
    {"name": "IELTS/TOEIC Prep", "icon": Icons.school, "color": Colors.indigo},
  ];

  Future<void> _selectMajor(String majorName) async {
    setState(() => isLoading = true);
    
    try {
      final String url = "${ApiConfig.users}/update-major?username=${widget.username}&major=${Uri.encodeComponent(majorName)}";
      var response = await http.post(Uri.parse(url));

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => RoadmapScreen(username: widget.username, major: majorName),
        ));
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
        title: const Text("Chọn chuyên ngành học", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("Hãy chọn chủ đề bạn quan tâm để bắt đầu lộ trình học tập riêng biệt của mình:", 
                  style: TextStyle(fontSize: 16, color: Colors.grey)
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.3,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: majors.length,
                  itemBuilder: (context, index) {
                    final major = majors[index];
                    return InkWell(
                      onTap: isLoading ? null : () => _selectMajor(major['name']),
                      child: Container(
                        decoration: BoxDecoration(
                          color: major['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: major['color'].withOpacity(0.5), width: 2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(major['icon'], size: 40, color: major['color']),
                            const SizedBox(height: 10),
                            Text(major['name'], 
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold, color: major['color'], fontSize: 13)
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
            const Center(child: CircularProgressIndicator(color: Color(0xFF0F8A50))),
        ],
      ),
    );
  }
}
