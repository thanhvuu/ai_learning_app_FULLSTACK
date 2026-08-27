import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/domain/usecases/get_leaderboard.dart';
import 'discover_leaderboard_state.dart';

class DiscoverLeaderboardCubit extends Cubit<DiscoverLeaderboardState> {
  final GetLeaderboard _getLeaderboard;

  DiscoverLeaderboardCubit(this._getLeaderboard)
      : super(const DiscoverLeaderboardState());

  Future<void> loadLeaderboard() async {
    emit(state.copyWith(status: DiscoverStatus.loading, errorMessage: null));

    final result = await _getLeaderboard();

    result.when(
      success: (users) => emit(state.copyWith(
        status: DiscoverStatus.success,
        leaderboard: users,
      )),
      failure: (error) => emit(state.copyWith(
        status: DiscoverStatus.failure,
        errorMessage: error.message,
      )),
    );
  }
}
