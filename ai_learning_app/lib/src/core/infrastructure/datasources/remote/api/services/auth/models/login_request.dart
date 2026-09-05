import 'package:equatable/equatable.dart';

class LoginRequest extends Equatable {
  final String emailOrUsername;
  final String password;

  const LoginRequest({
    required this.emailOrUsername,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'username': emailOrUsername.trim(),
        'password': password.trim(),
      };

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
        emailOrUsername: json['username'] ?? json['email'] ?? '',
        password: json['password'] ?? '',
      );

  @override
  List<Object?> get props => [emailOrUsername, password];
}
