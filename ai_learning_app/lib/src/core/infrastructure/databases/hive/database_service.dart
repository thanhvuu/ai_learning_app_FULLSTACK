import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ai_learning_app/src/core/domain/entities/cached_lesson_entity.dart';
import 'package:ai_learning_app/src/core/domain/entities/saved_word_entity.dart';
import 'package:ai_learning_app/src/core/domain/entities/sync_queue_entity.dart';
import 'package:ai_learning_app/src/core/domain/entities/translation_history_entity.dart';
import 'package:ai_learning_app/src/core/domain/entities/user_entity.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  static const String userBox = 'user_box';
  static const String savedWordsBox = 'saved_words_box';
  static const String cachedLessonsBox = 'cached_lessons_box';
  static const String translationHistoryBox = 'translation_history_box';
  static const String syncQueueBox = 'sync_queue_box';

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    _registerAdapters();

    await Future.wait([
      openBox<UserEntity>(userBox),
      openBox<SavedWordEntity>(savedWordsBox),
      openBox<CachedLessonEntity>(cachedLessonsBox),
      openBox<TranslationHistoryEntity>(translationHistoryBox),
      openBox<SyncQueueEntity>(syncQueueBox),
    ]);

    _isInitialized = true;
    debugPrint('DatabaseService initialized successfully with all Hive boxes.');
  }

  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserEntityAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SavedWordEntityAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(CachedLessonEntityAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(TranslationHistoryEntityAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(SyncQueueEntityAdapter());
    }
  }

  Box<T> getBox<T>(String boxName) {
    if (!Hive.isBoxOpen(boxName)) {
      throw StateError('Box "$boxName" is not opened yet. Call initialize() first.');
    }
    return Hive.box<T>(boxName);
  }

  Future<Box<T>> openBox<T>(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<T>(boxName);
    }
    return await Hive.openBox<T>(boxName);
  }

  Future<void> clearAll() async {
    await Future.wait([
      if (Hive.isBoxOpen(userBox)) getBox<UserEntity>(userBox).clear(),
      if (Hive.isBoxOpen(savedWordsBox)) getBox<SavedWordEntity>(savedWordsBox).clear(),
      if (Hive.isBoxOpen(cachedLessonsBox)) getBox<CachedLessonEntity>(cachedLessonsBox).clear(),
      if (Hive.isBoxOpen(translationHistoryBox)) getBox<TranslationHistoryEntity>(translationHistoryBox).clear(),
      if (Hive.isBoxOpen(syncQueueBox)) getBox<SyncQueueEntity>(syncQueueBox).clear(),
    ]);
  }

  Future<void> close() async {
    await Hive.close();
    _isInitialized = false;
  }
}