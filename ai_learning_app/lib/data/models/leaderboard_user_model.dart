class LeaderboardUserModel {
  final String username;
  final int totalXp;
  final int wateredPlants;

  const LeaderboardUserModel({
    required this.username,
    required this.totalXp,
    required this.wateredPlants,
  });

  factory LeaderboardUserModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardUserModel(
      username: json['username']?.toString() ?? 'Unknown',
      totalXp: json['totalXp'] is int ? json['totalXp'] : int.tryParse('${json['totalXp']}') ?? 0,
      wateredPlants: json['wateredPlants'] is int ? json['wateredPlants'] : int.tryParse('${json['wateredPlants']}') ?? 0,
    );
  }
}
