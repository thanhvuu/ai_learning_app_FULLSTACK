import 'package:hive/hive.dart';
import 'base_entity.dart';

part 'user_entity.g.dart';

@HiveType(typeId: 1)
class UserEntity extends BaseEntity {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? major;

  @HiveField(4)
  final int totalXp;

  @HiveField(5)
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

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'major': major,
      'totalXp': totalXp,
      'streak': streak,
    };
  }

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      major: json['major']?.toString(),
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
    );
  }
}
