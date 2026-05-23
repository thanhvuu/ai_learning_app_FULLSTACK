import 'package:ai_learning_app/features/leaderboard/domain/entities/leaderboard_user.dart';

class LeaderboardUserDto {
  const LeaderboardUserDto({
    required this.username,
    required this.totalXp,
    required this.wateredPlants,
  });

  final String username;
  final int totalXp;
  final int wateredPlants;

  factory LeaderboardUserDto.fromJson(Map<String, dynamic> json) {
    return LeaderboardUserDto(
      username: json['username']?.toString() ?? 'Unknown',
      totalXp: _readInt(json['totalXp']),
      wateredPlants: _readInt(json['wateredPlants']),
    );
  }

  LeaderboardUser toEntity() {
    return LeaderboardUser(
      username: username,
      totalXp: totalXp,
      wateredPlants: wateredPlants,
    );
  }

  static int _readInt(Object? value) {
    if (value is int) return value;
    return int.tryParse('$value') ?? 0;
  }
}
