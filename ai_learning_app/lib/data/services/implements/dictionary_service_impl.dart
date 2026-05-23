import 'dart:io';

import 'package:ai_learning_app/data/services/interfaces/dictionary_service.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DictionaryServiceImpl implements IDictionaryService {
  static Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbDir = await getDatabasesPath();
    final dbPath = join(dbDir, 'dict_hh.db');
    final exists = await databaseExists(dbPath);

    if (!exists) {
      await Directory(dirname(dbPath)).create(recursive: true);
      final data = await rootBundle.load('assets/database/dict_hh.db');
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(dbPath).writeAsBytes(bytes, flush: true);
    }

    final db = await openDatabase(dbPath);
    await db.execute('''
      CREATE TABLE IF NOT EXISTS saved_words (
        word TEXT PRIMARY KEY,
        meaning TEXT,
        level INTEGER DEFAULT 0,
        last_reviewed INTEGER
      )
    ''');
    return db;
  }

  @override
  Future<List<Map<String, dynamic>>> getGardenWords() async {
    final db = await _db;
    return db.query('saved_words', orderBy: 'last_reviewed DESC');
  }

  @override
  Future<bool> isWordSaved(String word) async {
    final db = await _db;
    final result = await db.query('saved_words', where: 'word = ?', whereArgs: [word.toLowerCase()]);
    return result.isNotEmpty;
  }

  @override
  Future<Map<String, dynamic>?> lookupWordOffline(String word) async {
    final db = await _db;
    final searchWord = word.trim().toLowerCase();
    final results = await db.rawQuery('SELECT * FROM av WHERE word = ? COLLATE NOCASE', [searchWord]);
    if (results.isEmpty) return null;

    final rawData = results.first;
    return {
      'word': rawData['word'] ?? searchWord,
      'phonetic': rawData['pronounce'] ?? '',
      'partOfSpeech': '',
      'meaning': rawData['description'] ?? rawData['html'] ?? 'Không có dữ liệu',
      'synonyms': [],
      'antonyms': [],
      'examples': [],
    };
  }

  @override
  Future<bool> toggleSaveWord(String word, String meaning) async {
    final db = await _db;
    final saved = await isWordSaved(word);
    if (saved) {
      await db.delete('saved_words', where: 'word = ?', whereArgs: [word.toLowerCase()]);
      return false;
    }

    await db.insert('saved_words', {
      'word': word.toLowerCase(),
      'meaning': meaning,
      'level': 0,
      'last_reviewed': DateTime.now().millisecondsSinceEpoch,
    });
    return true;
  }

  @override
  Future<void> updateWordProgress(String word, int currentLevel, bool isRemembered) async {
    final db = await _db;
    var newLevel = currentLevel;
    if (isRemembered) {
      newLevel = currentLevel < 3 ? currentLevel + 1 : 3;
    } else {
      newLevel = currentLevel > 0 ? currentLevel - 1 : 0;
    }

    await db.update(
      'saved_words',
      {'level': newLevel, 'last_reviewed': DateTime.now().millisecondsSinceEpoch},
      where: 'word = ?',
      whereArgs: [word],
    );
  }
}
