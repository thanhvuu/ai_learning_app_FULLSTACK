import 'package:ai_learning_app/core/error/app_exception.dart';
import 'package:ai_learning_app/core/result/result.dart';
import 'package:ai_learning_app/features/leaderboard/domain/entities/leaderboard_user.dart';
import 'package:ai_learning_app/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:ai_learning_app/features/leaderboard/domain/usecases/get_leaderboard.dart';
import 'package:ai_learning_app/features/leaderboard/presentation/view_models/discover_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DiscoverViewModel exposes leaderboard on success', () async {
    final repository = _FakeLeaderboardRepository(
      const Success([
        LeaderboardUser(username: 'vu', totalXp: 100, wateredPlants: 5),
      ]),
    );
    final viewModel = DiscoverViewModel(GetLeaderboard(repository));

    await viewModel.loadLeaderboard();

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.errorMessage, isNull);
    expect(viewModel.leaderboard.single.username, 'vu');
  });

  test('DiscoverViewModel exposes readable error on failure', () async {
    final repository = _FakeLeaderboardRepository(
      const Failure(AppException('Server is busy')),
    );
    final viewModel = DiscoverViewModel(GetLeaderboard(repository));

    await viewModel.loadLeaderboard();

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.leaderboard, isEmpty);
    expect(viewModel.errorMessage, 'Server is busy');
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
