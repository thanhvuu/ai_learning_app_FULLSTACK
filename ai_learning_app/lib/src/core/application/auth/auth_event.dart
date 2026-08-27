import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Request checking current auth state from Hive cache and Firebase Auth
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
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
