import 'package:ai_learning_app/core/result/result.dart';
import 'package:ai_learning_app/features/leaderboard/domain/entities/leaderboard_user.dart';
import 'package:ai_learning_app/features/leaderboard/domain/repositories/leaderboard_repository.dart';

class GetLeaderboard {
  const GetLeaderboard(this._repository);

  final LeaderboardRepository _repository;

  Future<Result<List<LeaderboardUser>>> call() {
    return _repository.fetchLeaderboard();
  }
}
