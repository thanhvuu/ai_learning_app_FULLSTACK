import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import '../models/question_model.dart';

class DragDropQuizScreen extends StatefulWidget {
  final List<QuestionModel> questions;

  const DragDropQuizScreen({super.key, required this.questions});

  @override
  State<DragDropQuizScreen> createState() => _DragDropQuizScreenState();
}

class _DragDropQuizScreenState extends State<DragDropQuizScreen> {
  int currentIndex = 0;
  String? droppedWord;
  bool hasChecked = false;
  late List<String> currentOptions;

  // --- THÊM BIẾN TRÁI TIM ---
  int hearts = 3;

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  void _loadQuestion() {
    QuestionModel currentQ = widget.questions[currentIndex];
    currentOptions = [
      currentQ.optionA,
      currentQ.optionB,
      currentQ.optionC,
      currentQ.optionD,
    ];
    currentOptions.removeWhere((item) => item.isEmpty);
    currentOptions.shuffle();

    droppedWord = null;
    hasChecked = false;
  }

  void _nextQuestion() {
    if (currentIndex < widget.questions.length - 1) {
      setState(() {
        currentIndex++;
        _loadQuestion();
      });
    } else {
      _showCompletionDialog();
    }
  }

  // --- HÀM XỬ LÝ GAME OVER KHI HẾT TIM ---
  void _showGameOverDialog() {
    showDialog(
        context: context,
        barrierDismissible: false, // Không cho bấm ra ngoài để tắt
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Column(
            children: [
              Icon(Icons.heart_broken, color: Colors.red, size: 50),
              SizedBox(height: 10),
              Text("Hết lượt thử!", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text("Bạn đã hết trái tim ❤️. Hãy nghỉ ngơi, ôn tập lại và thử sức sau nhé!", textAlign: TextAlign.center),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.symmetric(vertical: 12)
                ),
                onPressed: () {
                  Navigator.pop(context); // Đóng popup
                  Navigator.pop(context); // Quay về màn hình Home
                },
                child: const Text("Về trang chủ", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        )
    );
  }

  void _showCompletionDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Tuyệt vời! 🎉", textAlign: TextAlign.center, style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          content: const Text("Bạn đã hoàn thành xuất sắc bài học này. Nhận ngay +150 XP!", textAlign: TextAlign.center),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("Trở về trang chủ", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text("Không có câu hỏi nào!")));
    }

    QuestionModel currentQ = widget.questions[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF5),
      appBar: AppBar(
        title: Text('Câu ${currentIndex + 1}/${widget.questions.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.green),

        // --- VẼ 3 TRÁI TIM LÊN GÓC PHẢI APPBAR ---
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Row(
              children: List.generate(3, (index) {
                return Icon(
                  index < hearts ? Icons.favorite : Icons.favorite_border, // Nhỏ hơn số tim hiện tại thì tô đỏ, ngược lại thì rỗng
                  color: Colors.red,
                  size: 26,
                );
              }),
            ),
          )
        ],

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: (currentIndex + 1) / widget.questions.length,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Kéo từ đúng vào chỗ trống:", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 40),

              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 15,
                children: [
                  Text(currentQ.sentenceStart, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),

                  DragTarget<String>(
                    onWillAcceptWithDetails: (details) => !hasChecked,
                    onAcceptWithDetails: (details) {
                      setState(() {
                        droppedWord = details.data;
                        hasChecked = false;
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      if (droppedWord != null) {
                        return GestureDetector(
                          onTap: () {
                            if (!hasChecked) setState(() => droppedWord = null);
                          },
                          child: _buildWordBlock(droppedWord!, isDropped: true),
                        );
                      }
                      return DottedBorder(
                        color: candidateData.isNotEmpty ? Colors.green : Colors.grey,
                        strokeWidth: 2,
                        dashPattern: const [6, 4],
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(15),
                        child: Container(
                          width: 80, height: 45,
                          alignment: Alignment.center,
                          color: candidateData.isNotEmpty ? Colors.green.withOpacity(0.1) : Colors.transparent,
                        ),
                      );
                    },
                  ),

                  Text(currentQ.sentenceEnd, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 50),

              Wrap(
                spacing: 15,
                runSpacing: 15,
                alignment: WrapAlignment.center,
                children: currentOptions.map((word) {
                  if (word == droppedWord) {
                    return Container(
                      width: 80, height: 45,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(15)),
                    );
                  }
                  return Draggable<String>(
                    data: word,
                    feedback: Material(color: Colors.transparent, child: _buildWordBlock(word, isDragging: true)),
                    childWhenDragging: Container(
                      width: 80, height: 45,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(15)),
                    ),
                    child: _buildWordBlock(word),
                  );
                }).toList(),
              ),

              const Spacer(),

              if (hasChecked)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: droppedWord == currentQ.correctAnswer ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        droppedWord == currentQ.correctAnswer ? Icons.check_circle : Icons.cancel,
                        color: droppedWord == currentQ.correctAnswer ? Colors.green : Colors.red,
                        size: 30,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          droppedWord == currentQ.correctAnswer ? "Tuyệt vời!" : "Sai rồi. Đáp án đúng là: ${currentQ.correctAnswer}",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: droppedWord == currentQ.correctAnswer ? Colors.green[800] : Colors.red[800]),
                        ),
                      )
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: droppedWord == null
                      ? null
                      : () {
                    // --- LOGIC TRỪ TIM KHI TRẢ LỜI SAI ---
                    if (hasChecked) {
                      if (hearts > 0) {
                        _nextQuestion(); // Chuyển câu tiếp theo
                      }
                    } else {
                      setState(() {
                        hasChecked = true;
                        // Nếu đáp án sai
                        if (droppedWord != currentQ.correctAnswer) {
                          hearts--; // Trừ 1 tim
                          if (hearts == 0) {
                            _showGameOverDialog(); // Hết tim thì bật Popup Game Over
                          }
                        }
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasChecked && droppedWord == currentQ.correctAnswer ? Colors.green : (hasChecked && droppedWord != currentQ.correctAnswer && hearts > 0 ? Colors.red : const Color(0xFF0F8A50)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: Text(
                    hasChecked ? "TIẾP TỤC" : "KIỂM TRA",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: droppedWord == null ? Colors.grey[500] : Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWordBlock(String word, {bool isDragging = false, bool isDropped = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isDropped ? Colors.green : Colors.grey[300]!, width: 2),
        boxShadow: isDragging
            ? [BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 10, spreadRadius: 2)]
            : [BoxShadow(color: Colors.grey[300]!, offset: const Offset(0, 4))],
      ),
      child: Text(
        word,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDropped ? Colors.green[800] : Colors.black87, decoration: TextDecoration.none),
      ),
    );
  }
}