import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:ai_learning_app/src/core/domain/entities/cached_lesson_entity.dart';
import 'package:ai_learning_app/src/core/domain/entities/saved_word_entity.dart';
import 'package:ai_learning_app/src/core/domain/entities/sync_queue_entity.dart';
import 'package:ai_learning_app/src/core/domain/entities/translation_history_entity.dart';
import 'package:ai_learning_app/src/core/domain/entities/user_entity.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/cached_lesson_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/saved_word_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/sync_queue_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/translation_history_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/user_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/database_service.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);

    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(UserEntityAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(SavedWordEntityAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(CachedLessonEntityAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(TranslationHistoryEntityAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(SyncQueueEntityAdapter());

    await Future.wait([
      Hive.openBox<UserEntity>(DatabaseService.userBox),
      Hive.openBox<SavedWordEntity>(DatabaseService.savedWordsBox),
      Hive.openBox<CachedLessonEntity>(DatabaseService.cachedLessonsBox),
      Hive.openBox<TranslationHistoryEntity>(DatabaseService.translationHistoryBox),
      Hive.openBox<SyncQueueEntity>(DatabaseService.syncQueueBox),
    ]);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  setUp(() async {
    await DatabaseService.instance.clearAll();
  });

  group('UserDao Tests', () {
    final userDao = UserDao();

    test('saveUser and getCurrentUser works correctly', () async {
      expect(await userDao.getCurrentUser(), isNull);

      const user = UserEntity(
        id: 'u1',
        username: 'test_user',
        email: 'test@example.com',
        major: 'Information Technology',
        totalXp: 150,
        streak: 3,
      );

      await userDao.saveUser(user);
      final retrieved = await userDao.getCurrentUser();
      expect(retrieved, isNotNull);
      expect(retrieved?.username, 'test_user');
      expect(retrieved?.major, 'Information Technology');
      expect(retrieved?.totalXp, 150);
    });

    test('updateXpAndStreak updates totalXp and streak property', () async {
      const user = UserEntity(
        id: 'u1',
        username: 'test_user',
        email: 'test@example.com',
        totalXp: 10,
        streak: 1,
      );
      await userDao.saveUser(user);
      await userDao.updateXpAndStreak(totalXp: 50, streak: 3);

      final updated = await userDao.getCurrentUser();
      expect(updated?.totalXp, 50);
      expect(updated?.streak, 3);
    });
  });

  group('SavedWordDao Tests', () {
    final wordDao = SavedWordDao();

    test('toggleSaveWord saves and removes word', () async {
      const word = SavedWordEntity(
        id: 'algorithm',
        word: 'Algorithm',
        meaning: 'Thuật toán',
        level: 0,
      );

      await wordDao.toggleSaveWord(word);
      expect(await wordDao.isWordSaved('algorithm'), isTrue);

      await wordDao.toggleSaveWord(word);
      expect(await wordDao.isWordSaved('algorithm'), isFalse);
    });

    test('updateWordProgress adjusts level between 0 and 3', () async {
      await wordDao.updateWordProgress(
        word: 'Variable',
        currentLevel: 0,
        isRemembered: true,
      );
      var entry = await wordDao.findWord('variable');
      expect(entry?.level, 1);

      await wordDao.updateWordProgress(
        word: 'Variable',
        currentLevel: 1,
        isRemembered: false,
      );
      entry = await wordDao.findWord('variable');
      expect(entry?.level, 0);
    });
  });

  group('CachedLessonDao Tests', () {
    final lessonDao = CachedLessonDao();

    test('save lesson and query by major', () async {
      const lesson = CachedLessonEntity(
        id: 'lesson_101',
        topic: 'Flutter Basics',
        major: 'Information Technology',
        content: 'Lesson content here...',
        quizType: 'multiple_choice',
        vocabularies: [
          {'word': 'Widget', 'meaning': 'Thành phần giao diện'},
        ],
        questions: [],
        createdAt: 100000,
      );

      await lessonDao.insertOne(lesson);

      final itLessons = await lessonDao.getLessonsByMajor('Information Technology');
      expect(itLessons.length, 1);
      expect(itLessons.first.topic, 'Flutter Basics');

      final medicalLessons = await lessonDao.getLessonsByMajor('Medical & Healthcare');
      expect(medicalLessons.isEmpty, isTrue);
    });
  });

  group('TranslationHistoryDao & SyncQueueDao Tests', () {
    test('TranslationHistoryDao adds and retrieves sorted translations', () async {
      final transDao = TranslationHistoryDao();
      await transDao.addTranslation(
        const TranslationHistoryEntity(
          id: 't1',
          sourceText: 'Hello',
          translatedText: 'Xin chào',
          sourceLang: 'en',
          targetLang: 'vi',
          timestamp: 100,
        ),
      );
      await transDao.addTranslation(
        const TranslationHistoryEntity(
          id: 't2',
          sourceText: 'Goodbye',
          translatedText: 'Tạm biệt',
          sourceLang: 'en',
          targetLang: 'vi',
          timestamp: 200,
        ),
      );

      final history = await transDao.getRecentTranslations();
      expect(history.length, 2);
      expect(history.first.sourceText, 'Goodbye'); // sorted newest first
    });

    test('SyncQueueDao enqueues actions in FIFO order', () async {
      final syncDao = SyncQueueDao();
      await syncDao.enqueueAction(
        actionType: 'UPDATE_XP',
        payload: {'xp': 50},
      );

      final queue = await syncDao.getPendingActions();
      expect(queue.length, 1);
      expect(queue.first.actionType, 'UPDATE_XP');

      await syncDao.delete(queue.first.id);
      expect((await syncDao.getPendingActions()).isEmpty, isTrue);
    });
  });
}
