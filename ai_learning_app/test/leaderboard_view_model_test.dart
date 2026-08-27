import 'package:flutter_test/flutter_test.dart';
import 'package:ai_learning_app/src/core/domain/app_exception.dart';
import 'package:ai_learning_app/src/core/domain/result.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/application/discover_cubit/discover_leaderboard_cubit.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/application/discover_cubit/discover_leaderboard_state.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/domain/entities/leaderboard_user.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/domain/repositories/leaderboard_repository.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/domain/usecases/get_leaderboard.dart';

void main() {
  test('DiscoverLeaderboardCubit exposes leaderboard on success', () async {
    const repository = _FakeLeaderboardRepository(
      Success([
        LeaderboardUser(username: 'vu', totalXp: 100, wateredPlants: 5),
      ]),
    );
    final cubit = DiscoverLeaderboardCubit(const GetLeaderboard(repository));

    await cubit.loadLeaderboard();

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.errorMessage, isNull);
    expect(cubit.state.status, DiscoverStatus.success);
    expect(cubit.state.leaderboard.single.username, 'vu');
  });

  test('DiscoverLeaderboardCubit exposes readable error on failure', () async {
    const repository = _FakeLeaderboardRepository(
      Failure(AppException('Server is busy')),
    );
    final cubit = DiscoverLeaderboardCubit(const GetLeaderboard(repository));

    await cubit.loadLeaderboard();

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.status, DiscoverStatus.failure);
    expect(cubit.state.leaderboard, isEmpty);
    expect(cubit.state.errorMessage, 'Server is busy');
  });
}

class _FakeLeaderboardRepository implements LeaderboardRepository {
  const _FakeLeaderboardRepository(this.result);

  final Result<List<LeaderboardUser>> result;

  @override
  Future<Result<List<LeaderboardUser>>> fetchLeaderboard() async {
    return result;
  }
}
