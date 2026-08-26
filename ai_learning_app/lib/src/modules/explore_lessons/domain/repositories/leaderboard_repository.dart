import 'package:ai_learning_app/src/core/domain/result.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/domain/entities/leaderboard_user.dart';

abstract class LeaderboardRepository {
  Future<Result<List<LeaderboardUser>>> fetchLeaderboard();
}
