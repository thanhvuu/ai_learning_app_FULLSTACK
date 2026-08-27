import 'package:equatable/equatable.dart';
import 'package:ai_learning_app/src/modules/explore_lessons/domain/entities/leaderboard_user.dart';

enum DiscoverStatus { initial, loading, success, failure }

class DiscoverLeaderboardState extends Equatable {
  final DiscoverStatus status;
  final List<LeaderboardUser> leaderboard;
  final String? errorMessage;

  const DiscoverLeaderboardState({
    this.status = DiscoverStatus.initial,
    this.leaderboard = const [],
    this.errorMessage,
  });

  bool get isLoading => status == DiscoverStatus.loading;

  DiscoverLeaderboardState copyWith({
    DiscoverStatus? status,
    List<LeaderboardUser>? leaderboard,
    String? errorMessage,
  }) {
    return DiscoverLeaderboardState(
      status: status ?? this.status,
      leaderboard: leaderboard ?? this.leaderboard,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, leaderboard, errorMessage];
}
