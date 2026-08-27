import 'package:ai_learning_app/src/core/domain/entities/user_entity.dart';
import '../base_dao.dart';
import '../database_service.dart';

class UserDao extends BaseDao<UserEntity> {
  UserDao() : super(DatabaseService.userBox);

  Future<UserEntity?> getCurrentUser() async {
    final all = await getAll();
    return all.isNotEmpty ? all.first : null;
  }

  Future<void> saveUser(UserEntity user) async {
    await clear();
    await insertOne(user);
  }

  Future<void> clearUser() async {
    await clear();
  }

  Future<void> updateXpAndStreak({required int totalXp, required int streak}) async {
    final current = await getCurrentUser();
    if (current != null) {
      await update(current.copyWith(totalXp: totalXp, streak: streak));
    }
  }
}
