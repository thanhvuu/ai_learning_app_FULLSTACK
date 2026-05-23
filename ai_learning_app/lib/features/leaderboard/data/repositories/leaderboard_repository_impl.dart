import 'package:ai_learning_app/core/result/result.dart';
import 'package:ai_learning_app/features/leaderboard/data/datasources/leaderboard_remote_data_source.dart';
import 'package:ai_learning_app/features/leaderboard/domain/entities/leaderboard_user.dart';
import 'package:ai_learning_app/features/leaderboard/domain/repositories/leaderboard_repository.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  const LeaderboardRepositoryImpl(this._remoteDataSource);

  final LeaderboardRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<LeaderboardUser>>> fetchLeaderboard() async {
    final result = await _remoteDataSource.fetchLeaderboard();

    return result.when(
      success: (users) =>
          Success(users.map((user) => user.toEntity()).toList(growable: false)),
      failure: Failure.new,
    );
  }
}
