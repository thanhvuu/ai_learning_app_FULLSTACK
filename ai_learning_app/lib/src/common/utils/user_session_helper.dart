import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_learning_app/src/core/application/auth/auth_bloc.dart';

class UserSessionHelper {
  UserSessionHelper._();

  /// Safely resolves the active username with cascade fallbacks:
  /// 1. AuthBloc state's user.name
  /// 2. FirebaseAuth currentUser.displayName
  /// 3. FirebaseAuth currentUser.email prefix (before '@')
  /// 4. Fallback 'Learner'
  static String getUsername([BuildContext? context]) {
    if (context != null) {
      try {
        final authUser = context.read<AuthBloc?>()?.state.user;
        if (authUser != null && authUser.username.trim().isNotEmpty) {
          return authUser.username.trim();
        }
      } catch (_) {}
    }

    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser?.displayName != null && fbUser!.displayName!.trim().isNotEmpty) {
      return fbUser.displayName!.trim();
    }

    if (fbUser?.email != null && fbUser!.email!.trim().isNotEmpty) {
      return fbUser.email!.split('@').first.trim();
    }

    return 'Learner';
  }

  /// Returns the current user's email if available.
  static String? getEmail() {
    return FirebaseAuth.instance.currentUser?.email;
  }
}
