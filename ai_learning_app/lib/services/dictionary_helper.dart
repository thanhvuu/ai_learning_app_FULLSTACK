import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DictionaryHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    // 1. Lấy đường dẫn bộ nhớ máy
    var dbDir = await getDatabasesPath();
    var dbPath = join(dbDir, "dict_hh.db");

    // 2. Kiểm tra xem file đã được copy ra bộ nhớ chưa
    bool exists = await databaseExists(dbPath);

    if (!exists) {
      print("Lần đầu chạy: Đang copy database từ assets ra điện thoại...");
      try {
        await Directory(dirname(dbPath)).create(recursive: true);
        // Đọc từ file assets
        ByteData data = await rootBundle.load("assets/database/dict_hh.db");
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        // Ghi ra bộ nhớ máy
        await File(dbPath).writeAsBytes(bytes, flush: true);
        print("Copy database thành công!");
      } catch (e) {
        print("Lỗi copy DB: $e");
      }
    }

    // 3. Mở database và TẠO THÊM BẢNG VƯỜN ƯƠM (nếu chưa có)
    Database db = await openDatabase(dbPath);
    await db.execute('''
      CREATE TABLE IF NOT EXISTS saved_words (
        word TEXT PRIMARY KEY,
        meaning TEXT,
        level INTEGER DEFAULT 0,
        last_reviewed INTEGER
      )
    ''');
    /*
      Giải thích cột:
      - word: Từ vựng
      - meaning: Nghĩa tiếng Việt
      - level: Cấp độ cây (0: Hạt giống, 1: Mầm, 2: Cây non, 3: Cây lớn, 4: Thu hoạch)
      - last_reviewed: Thời gian ôn tập lần cuối (để tính toán lịch lặp lại)
    */
    return db;
  }

  // HÀM TRA TỪ SIÊU TỐC
  static Future<Map<String, dynamic>?> lookupWordOffline(String word) async {
    final db = await database;
    String searchWord = word.trim().toLowerCase();

    try {
      // Đa số các database Anh-Việt trên Github dùng bảng tên 'av' (Anh-Việt)
      List<Map<String, dynamic>> results = await db.rawQuery(
          "SELECT * FROM av WHERE word = ? COLLATE NOCASE",
          [searchWord]
      );

      if (results.isNotEmpty) {
        var rawData = results.first;

        // Map lại dữ liệu để phù hợp với giao diện BottomSheet chúng ta đã làm
        return {
          "word": rawData['word'] ?? searchWord,
          "phonetic": rawData['pronounce'] ?? "", // Tuỳ database có cột này hay ko
          "partOfSpeech": "",
          // Thường dữ liệu nghĩa sẽ nằm ở cột 'description' hoặc 'html'
          "meaning": rawData['description'] ?? rawData['html'] ?? "Không có dữ liệu",
          "synonyms": [],
          "antonyms": [],
          "examples": []
        };
      }
    } catch (e) {
      print("Lỗi khi tra từ: $e");
    }
    return null; // Không tìm thấy
  }

  // ===================================================
  // CÁC HÀM XỬ LÝ VƯỜN ƯƠM TỪ VỰNG (SAVED WORDS)
  // ===================================================

  // Kiểm tra xem từ này đã được gieo mầm chưa
  static Future<bool> isWordSaved(String word) async {
    final db = await database;
    var result = await db.query('saved_words', where: 'word = ?', whereArgs: [word.toLowerCase()]);
    return result.isNotEmpty;
  }

  // Gieo mầm (Lưu) hoặc Nhổ bỏ (Xóa) từ vựng
  static Future<bool> toggleSaveWord(String word, String meaning) async {
    final db = await database;
    bool isSaved = await isWordSaved(word);

    if (isSaved) {
      // Đã lưu rồi thì xóa đi (Nhổ cây)
      await db.delete('saved_words', where: 'word = ?', whereArgs: [word.toLowerCase()]);
      return false; // Trả về trạng thái chưa lưu
    } else {
      // Chưa lưu thì thêm vào (Gieo hạt)
      await db.insert('saved_words', {
        'word': word.toLowerCase(),
        'meaning': meaning,
        'level': 0, // Bắt đầu từ Hạt giống
        'last_reviewed': DateTime.now().millisecondsSinceEpoch
      });
      return true; // Trả về trạng thái đã lưu
    }
  }

  // Lấy toàn bộ khu vườn để hiển thị lên màn hình (Dùng cho Bước 3)
  static Future<List<Map<String, dynamic>>> getGardenWords() async {
    final db = await database;
    return await db.query('saved_words', orderBy: 'last_reviewed DESC');
  }


  // Hàm cập nhật tiến độ học (Tưới nước)
  static Future<void> updateWordProgress(String word, int currentLevel, bool isRemembered) async {
    final db = await database;
    int newLevel = currentLevel;

    if (isRemembered) {
      // Nhớ thì tăng cấp (Tối đa là 3 - Thu hoạch 🍎)
      newLevel = currentLevel < 3 ? currentLevel + 1 : 3;
    } else {
      // Quên thì tụt 1 cấp (Thấp nhất là 0 - Hạt giống 🌱)
      newLevel = currentLevel > 0 ? currentLevel - 1 : 0;
    }

    await db.update(
      'saved_words',
      {
        'level': newLevel,
        'last_reviewed': DateTime.now().millisecondsSinceEpoch
      },
      where: 'word = ?',
      whereArgs: [word],
    );
  }
}