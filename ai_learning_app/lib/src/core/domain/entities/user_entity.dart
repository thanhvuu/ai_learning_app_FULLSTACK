class UserEntity {
  final String id;
  final String username;
  final String email;
  final String? major;
  final int totalXp;
  final int streak;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    this.major,
    this.totalXp = 0,
    this.streak = 0,
  });

  UserEntity copyWith({
    String? id,
    String? username,
    String? email,
    String? major,
    int? totalXp,
    int? streak,
  }) {
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      major: major ?? this.major,
      totalXp: totalXp ?? this.totalXp,
      streak: streak ?? this.streak,
    );
  }
}
