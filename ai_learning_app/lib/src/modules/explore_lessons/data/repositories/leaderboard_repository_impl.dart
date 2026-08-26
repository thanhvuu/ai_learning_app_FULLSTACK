import 'package:ai_learning_app/src/core/domain/result.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/data/datasources/leaderboard_remote_data_source.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/domain/entities/leaderboard_user.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/domain/repositories/leaderboard_repository.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  const LeaderboardRepositoryImpl(this._remoteDataSource);

  final LeaderboardRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<LeaderboardUser>>> fetchLeaderboard() async {
    final result = await _remoteDataSource.fetchLeaderboard();
    return result.when(
      success: (dtoList) {
        final entities = dtoList.map((dto) => dto.toEntity()).toList(growable: false);
        return Success(entities);
      },
      failure: Failure.new,
    );
  }
}
