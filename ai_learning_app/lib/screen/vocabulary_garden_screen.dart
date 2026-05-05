import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../l10n/app_localizations.dart';
import '../services/dictionary_helper.dart';
import 'flashcard_screen.dart';

class VocabularyGardenScreen extends StatefulWidget {
  const VocabularyGardenScreen({super.key});

  @override
  State<VocabularyGardenScreen> createState() => _VocabularyGardenScreenState();
}

class _VocabularyGardenScreenState extends State<VocabularyGardenScreen> {
  List<Map<String, dynamic>> _gardenWords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGarden();
  }

  Future<void> _loadGarden() async {
    var words = await DictionaryHelper.getGardenWords();
    setState(() {
      _gardenWords = words;
      _isLoading = false;
    });
  }

  // --- THUẬT TOÁN TƯỚI NƯỚC THÔNG MINH (SPACED REPETITION) ---
  List<Map<String, dynamic>> get _wordsToReview {
    int now = DateTime.now().millisecondsSinceEpoch;

    return _gardenWords.where((item) {
      int level = item['level'] ?? 0;
      int lastReviewed = item['last_reviewed'] ?? now;

      // Tính số giờ đã trôi qua kể từ lần cuối tương tác
      int hoursPassed = (now - lastReviewed) ~/ (1000 * 60 * 60);

      // QUY TẮC NHẮC LẠI:
      // (💡 MẸO: Để test ngay bây giờ, bạn có thể sửa các số 24, 72... thành số 0 nhé)
      if (level == 0 && hoursPassed >= 24) return true;  // Hạt giống 🌱: 1 ngày
      if (level == 1 && hoursPassed >= 72) return true;  // Mầm non 🌿: 3 ngày
      if (level == 2 && hoursPassed >= 168) return true; // Cây lớn 🌳: 7 ngày
      if (level == 3 && hoursPassed >= 720) return true; // Thu hoạch 🍎: 30 ngày

      return false; // Nếu chưa đến hạn thì không cần tưới!
    }).toList();
  }

  String _getPlantIcon(int level) {
    if (level == 0) return "🌱";
    if (level == 1) return "🌿";
    if (level == 2) return "🌳";
    return "🍎";
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final langProvider = LanguageProvider.safeOf(context);
    final t = AppLocalizations(langProvider.languageCode);
    const Color primaryGreen = Color(0xFF0F8A50);
    final Color bgColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF4F9F4);
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B2A22);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          t.translate('your_garden'),
          style: const TextStyle(color: primaryGreen, fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryGreen))
          : _gardenWords.isEmpty
          ? _buildEmptyGarden(textColor)
          : _buildGardenList(isDarkMode, textColor),

      // NÚT BẤM THÔNG MINH SẼ THAY ĐỔI THEO TRẠNG THÁI CÂY KHÁT NƯỚC
      floatingActionButton: _gardenWords.isEmpty
          ? null
          : _wordsToReview.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FlashcardScreen(reviewWords: _wordsToReview)),
          );
          if (result == true) _loadGarden();
        },
        backgroundColor: primaryGreen,
        icon: const Icon(Icons.water_drop, color: Colors.white),
        label: Text("${t.translate('water_trees')} ${_wordsToReview.length} ${t.translate('trees_unit')}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      )
          : FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(t.translate('all_watered_msg')))
          );
        },
        backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[400], // Chuyển màu xám nếu không có cây nào cần tưới
        icon: const Icon(Icons.check_circle, color: Colors.white),
        label: Text(t.translate('all_watered'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyGarden(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("🏜️", style: TextStyle(fontSize: 80)),
          const SizedBox(height: 20),
          Text(S.of(context, 'garden_empty'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 10),
          Text(S.of(context, 'garden_empty_desc'), textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildGardenList(bool isDarkMode, Color textColor) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 100),
      itemCount: _gardenWords.length,
      itemBuilder: (context, index) {
        var item = _gardenWords[index];
        bool needsWater = _wordsToReview.any((w) => w['word'] == item['word']);
        final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            // Nếu cây khát nước, viền sẽ phát sáng màu xanh dương nhạt
            border: needsWater ? Border.all(color: Colors.blue[200]!, width: 2) : null,
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? Colors.black26 : Colors.green.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5)
              )
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFE8F3ED),
                shape: BoxShape.circle
              ),
              child: Text(_getPlantIcon(item['level'] ?? 0), style: const TextStyle(fontSize: 20)),
            ),
            title: Text(
              item['word'] ?? "",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(
                item['meaning'] ?? "",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Hiển thị icon giọt nước kế bên cây đang khát
                if (needsWater)
                  const Icon(Icons.water_drop, color: Colors.blue, size: 24),
                const SizedBox(width: 5),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _removeWord(item['word']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _removeWord(String word) async {
    await DictionaryHelper.toggleSaveWord(word, "");
    _loadGarden();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${S.of(context, 'removed_from_garden')} '$word' ${S.of(context, 'from_garden')}", style: const TextStyle(color: Colors.white))));
    }
  }
}