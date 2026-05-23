import 'dart:io';

import 'package:ai_learning_app/data/dao/interfaces/dictionary_dao.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteDictionaryDao implements DictionaryDao {
  static const String _databaseName = 'dict_hh.db';
  static const String _savedWordsTable = 'saved_words';
  static const String _dictionaryTable = 'av';

  static Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbDir = await getDatabasesPath();
    final dbPath = join(dbDir, _databaseName);
    final exists = await databaseExists(dbPath);

    if (!exists) {
      await Directory(dirname(dbPath)).create(recursive: true);
      final data = await rootBundle.load('assets/database/$_databaseName');
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await File(dbPath).writeAsBytes(bytes, flush: true);
    }

    final db = await openDatabase(dbPath);
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_savedWordsTable (
        word TEXT PRIMARY KEY,
        meaning TEXT,
        level INTEGER DEFAULT 0,
        last_reviewed INTEGER
      )
    ''');
    return db;
  }

  @override
  Future<List<Map<String, dynamic>>> getSavedWords() async {
    final db = await _db;
    final rows = await db.query(
      _savedWordsTable,
      orderBy: 'last_reviewed DESC',
    );
    return rows.map(Map<String, dynamic>.from).toList();
  }

  @override
  Future<Map<String, dynamic>?> findSavedWordByWord(String word) async {
    final db = await _db;
    final rows = await db.query(
      _savedWordsTable,
      where: 'word = ?',
      whereArgs: [word],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Map<String, dynamic>.from(rows.first);
  }

  @override
  Future<Map<String, dynamic>?> findDictionaryEntryByWord(String word) async {
    final db = await _db;
    final rows = await db.rawQuery(
      'SELECT * FROM $_dictionaryTable WHERE word = ? COLLATE NOCASE LIMIT 1',
      [word],
    );
    if (rows.isEmpty) return null;
    return Map<String, dynamic>.from(rows.first);
  }

  @override
  Future<void> insertSavedWord({
    required String word,
    required String meaning,
    required int level,
    required int lastReviewed,
  }) async {
    final db = await _db;
    await db.insert(_savedWordsTable, {
      'word': word,
      'meaning': meaning,
      'level': level,
      'last_reviewed': lastReviewed,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> deleteSavedWord(String word) async {
    final db = await _db;
    await db.delete(_savedWordsTable, where: 'word = ?', whereArgs: [word]);
  }

  @override
  Future<void> updateSavedWordProgress({
    required String word,
    required int level,
    required int lastReviewed,
  }) async {
    final db = await _db;
    await db.update(
      _savedWordsTable,
      {'level': level, 'last_reviewed': lastReviewed},
      where: 'word = ?',
      whereArgs: [word],
    );
  }
}
