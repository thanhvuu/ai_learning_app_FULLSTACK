import 'package:hive_ce/hive.dart';
import 'package:ai_learning_app/src/core/domain/entities/cached_lesson_entity.dart';
import 'package:ai_learning_app/src/core/domain/entities/saved_word_entity.dart';
import 'package:ai_learning_app/src/core/domain/entities/sync_queue_entity.dart';
import 'package:ai_learning_app/src/core/domain/entities/translation_history_entity.dart';
import 'package:ai_learning_app/src/core/domain/entities/user_entity.dart';

extension HiveRegistrar on HiveInterface {
  void registerAdapters() {
    registerAdapter(CachedLessonEntityAdapter());
    registerAdapter(SavedWordEntityAdapter());
    registerAdapter(SyncQueueEntityAdapter());
    registerAdapter(TranslationHistoryEntityAdapter());
    registerAdapter(UserEntityAdapter());
  }
}
