import 'package:equatable/equatable.dart';
import 'package:ai_learning_app/src/core/infrastructure/datasources/remote/api/services/auth/models/login_request.dart';
import 'package:ai_learning_app/src/core/infrastructure/datasources/remote/api/services/auth/models/register_request.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Request checking current auth state from Hive cache and Firebase Auth
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Request login using LoginRequest model
class AuthLoginRequested extends AuthEvent {
  final LoginRequest request;

  const AuthLoginRequested(this.request);

  @override
  List<Object?> get props => [request];
}

/// Request registration using RegisterRequest model
class AuthRegisterRequested extends AuthEvent {
  final RegisterRequest request;

  const AuthRegisterRequested(this.request);

  @override
  List<Object?> get props => [request];
}

/// Request login with Email & Password
class AuthLoginWithEmailSubmitted extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginWithEmailSubmitted({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Request registration with Username, Email & Password
class AuthRegisterWithEmailSubmitted extends AuthEvent {
  final String username;
  final String email;
  final String password;

  const AuthRegisterWithEmailSubmitted({
    required this.username,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [username, email, password];
}

/// Request Google Sign-In (prepared for scaling)
class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

/// Request Apple Sign-In (prepared for scaling)
class AuthAppleSignInRequested extends AuthEvent {
  const AuthAppleSignInRequested();
}

/// Request Phone OTP (prepared for scaling)
class AuthPhoneOtpRequested extends AuthEvent {
  final String phoneNumber;

  const AuthPhoneOtpRequested({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

/// Verify Phone OTP (prepared for scaling)
class AuthPhoneOtpVerified extends AuthEvent {
  final String verificationId;
  final String smsCode;

  const AuthPhoneOtpVerified({
    required this.verificationId,
    required this.smsCode,
  });

  @override
  List<Object?> get props => [verificationId, smsCode];
}

/// Update user's stats (XP & Streak)
class AuthUserStatsUpdated extends AuthEvent {
  final int totalXp;
  final int streak;

  const AuthUserStatsUpdated({
    required this.totalXp,
    required this.streak,
  });

  @override
  List<Object?> get props => [totalXp, streak];
}

/// Request logout
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Update user profile (e.g. username)
class AuthProfileUpdated extends AuthEvent {
  final String username;

  const AuthProfileUpdated({required this.username});

  @override
  List<Object?> get props => [username];
}

/// Request fetching user profile from server / repository
class AuthUserProfileFetchRequested extends AuthEvent {
  final String username;

  const AuthUserProfileFetchRequested({required this.username});

  @override
  List<Object?> get props => [username];
}

/// Request permanent account deletion
class AuthDeleteAccountRequested extends AuthEvent {
  const AuthDeleteAccountRequested();
}
