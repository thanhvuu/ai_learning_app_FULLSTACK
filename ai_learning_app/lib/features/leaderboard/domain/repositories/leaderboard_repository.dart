import 'package:ai_learning_app/core/result/result.dart';
import 'package:ai_learning_app/features/leaderboard/domain/entities/leaderboard_user.dart';

abstract class LeaderboardRepository {
  Future<Result<List<LeaderboardUser>>> fetchLeaderboard();
}
