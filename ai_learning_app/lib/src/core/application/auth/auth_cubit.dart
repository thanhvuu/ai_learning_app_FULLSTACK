import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_learning_app/src/core/domain/interfaces/i_auth_repository.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/user_dao.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final IAuthRepository _authRepository;
  final UserDao _userDao;

  AuthCubit({
    required IAuthRepository authRepository,
    required UserDao userDao,
  })  : _authRepository = authRepository,
        _userDao = userDao,
        super(const AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final cachedUser = await _userDao.getCurrentUser();
    if (cachedUser != null) {
      emit(AuthState(status: AuthStatus.authenticated, user: cachedUser));
      return;
    }

    final currentUser = _authRepository.getCurrentUser();
    if (currentUser != null) {
      emit(AuthState(status: AuthStatus.authenticated, user: currentUser));
    } else {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<bool> login({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    final result = await _authRepository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return result.when(
      success: (user) {
        emit(AuthState(status: AuthStatus.authenticated, user: user));
        return true;
      },
      failure: (error) {
        emit(AuthState(
          status: AuthStatus.error,
          errorMessage: error.message,
          user: null,
        ));
        return false;
      },
    );
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    final result = await _authRepository.registerWithEmailAndPassword(
      username: username,
      email: email,
      password: password,
    );

    return result.when(
      success: (user) {
        emit(AuthState(status: AuthStatus.authenticated, user: user));
        return true;
      },
      failure: (error) {
        emit(AuthState(
          status: AuthStatus.error,
          errorMessage: error.message,
          user: null,
        ));
        return false;
      },
    );
  }

  Future<void> updateUserMajor(String major) async {
    if (state.user != null) {
      final updated = state.user!.copyWith(major: major);
      await _userDao.saveUser(updated);
      emit(state.copyWith(user: updated));
    }
  }

  Future<void> updateXpAndStreak({required int totalXp, required int streak}) async {
    if (state.user != null) {
      final updated = state.user!.copyWith(totalXp: totalXp, streak: streak);
      await _userDao.saveUser(updated);
      emit(state.copyWith(user: updated));
    }
  }

  Future<void> logout() async {
    await _authRepository.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
