import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ai_learning_app/generated/assets.gen.dart';
import 'interfaces/dictionary_dao.dart';

class SqfliteDictionaryDao implements DictionaryDao {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "dict_hh.db");

    final exists = await databaseExists(path);
    if (!exists) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      final data = await rootBundle.load(const $AssetsDatabaseGen().dictHh);
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
    }

    final db = await openDatabase(path, version: 1);
    await db.execute('''
      CREATE TABLE IF NOT EXISTS saved_words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT UNIQUE,
        meaning TEXT,
        level INTEGER DEFAULT 0,
        last_reviewed INTEGER DEFAULT 0
      )
    ''');
    return db;
  }

  @override
  Future<Map<String, dynamic>?> findDictionaryEntryByWord(String word) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'av',
      where: 'LOWER(word) = ?',
      whereArgs: [word.toLowerCase()],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  @override
  Future<Map<String, dynamic>?> findSavedWordByWord(String word) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'saved_words',
      where: 'LOWER(word) = ?',
      whereArgs: [word.toLowerCase()],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  @override
  Future<List<Map<String, dynamic>>> getSavedWords() async {
    final db = await database;
    return db.query('saved_words', orderBy: 'id DESC');
  }

  @override
  Future<void> insertSavedWord({
    required String word,
    required String meaning,
    required int level,
    required int lastReviewed,
  }) async {
    final db = await database;
    await db.insert('saved_words', {
      'word': word,
      'meaning': meaning,
      'level': level,
      'last_reviewed': lastReviewed,
    });
  }

  @override
  Future<void> updateSavedWordProgress({
    required String word,
    required int level,
    required int lastReviewed,
  }) async {
    final db = await database;
    await db.update(
      'saved_words',
      {'level': level, 'last_reviewed': lastReviewed},
      where: 'LOWER(word) = ?',
      whereArgs: [word.toLowerCase()],
    );
  }

  @override
  Future<void> deleteSavedWord(String word) async {
    final db = await database;
    await db.delete(
      'saved_words',
      where: 'LOWER(word) = ?',
      whereArgs: [word.toLowerCase()],
    );
  }
}
