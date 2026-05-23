import 'package:ai_learning_app/data/models/leaderboard_user_model.dart';

abstract class LeaderboardService {
  Future<List<LeaderboardUserModel>> fetchLeaderboard();
}
