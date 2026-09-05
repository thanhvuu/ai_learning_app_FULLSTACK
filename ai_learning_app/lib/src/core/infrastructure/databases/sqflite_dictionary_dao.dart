import 'dart:io';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ai_learning_app/generated/assets.gen.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/interfaces/dictionary_dao.dart';

@LazySingleton(as: DictionaryDao)
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

    return openDatabase(path, readOnly: true);
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
}
