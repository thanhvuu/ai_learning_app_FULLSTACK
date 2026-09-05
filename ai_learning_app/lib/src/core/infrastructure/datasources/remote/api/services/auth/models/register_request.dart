import 'package:equatable/equatable.dart';

class RegisterRequest extends Equatable {
  final String username;
  final String email;
  final String password;

  const RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'username': username.trim(),
        'email': email.trim(),
        'password': password.trim(),
      };

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => RegisterRequest(
        username: json['username'] ?? '',
        email: json['email'] ?? '',
        password: json['password'] ?? '',
      );

  @override
  List<Object?> get props => [username, email, password];
}
