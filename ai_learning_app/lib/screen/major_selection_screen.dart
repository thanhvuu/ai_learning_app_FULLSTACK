import 'package:flutter/material.dart';
import 'roadmap_screen.dart';
import 'homescreen.dart';

class MajorSelectionScreen extends StatefulWidget {
  final String username;
  const MajorSelectionScreen({super.key, required this.username});

  @override
  State<MajorSelectionScreen> createState() => _MajorSelectionScreenState();
}

class _MajorSelectionScreenState extends State<MajorSelectionScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chọn chuyên ngành học", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
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
                  onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (_) => HomeScreen(username: widget.username, major: major['name']),
                    ));
                  },
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
    );
  }
}
