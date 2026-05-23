import 'package:ai_learning_app/core/error/app_exception.dart';
import 'package:ai_learning_app/core/network/api_client.dart';
import 'package:ai_learning_app/core/result/result.dart';
import 'package:ai_learning_app/features/leaderboard/data/models/leaderboard_user_dto.dart';

abstract class LeaderboardRemoteDataSource {
  Future<Result<List<LeaderboardUserDto>>> fetchLeaderboard();
}

class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  const LeaderboardRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Result<List<LeaderboardUserDto>>> fetchLeaderboard() async {
    final response = await _apiClient.getList('/api/users/leaderboard');

    return response.when(
      success: (rows) {
        try {
          final users = rows
              .whereType<Map<String, dynamic>>()
              .map(LeaderboardUserDto.fromJson)
              .toList(growable: false);
          return Success(users);
        } catch (error, stackTrace) {
          return Failure(
            DataParsingException(
              'Cannot parse leaderboard response',
              cause: error,
              stackTrace: stackTrace,
            ),
          );
        }
      },
      failure: Failure.new,
    );
  }
}
