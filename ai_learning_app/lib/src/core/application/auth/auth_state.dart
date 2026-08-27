import 'package:equatable/equatable.dart';
import 'package:ai_learning_app/src/core/domain/entities/user_entity.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
  otpSent,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;
  final String? verificationId;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.verificationId,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get isError => status == AuthStatus.error;
  bool get isOtpSent => status == AuthStatus.otpSent;

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
    String? verificationId,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      verificationId: verificationId ?? this.verificationId,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, verificationId];
}
