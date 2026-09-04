import 'package:injectable/injectable.dart';
import 'package:ai_learning_app/src/core/domain/result.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/domain/entities/leaderboard_user.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/domain/repositories/leaderboard_repository.dart';

@injectable
class GetLeaderboard {
  const GetLeaderboard(this._repository);

  final LeaderboardRepository _repository;

  Future<Result<List<LeaderboardUser>>> call() {
    return _repository.fetchLeaderboard();
  }
}
