import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_learning_app/src/core/domain/interfaces/i_auth_repository.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/user_dao.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthRepository _authRepository;
  final UserDao _userDao;

  AuthBloc({
    required IAuthRepository authRepository,
    required UserDao userDao,
  })  : _authRepository = authRepository,
        _userDao = userDao,
        super(const AuthState()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginWithEmailSubmitted>(_onLoginWithEmailSubmitted);
    on<AuthRegisterWithEmailSubmitted>(_onRegisterWithEmailSubmitted);
    on<AuthUserStatsUpdated>(_onUserStatsUpdated);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
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

  Future<void> _onLoginWithEmailSubmitted(
    AuthLoginWithEmailSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    final result = await _authRepository.signInWithEmailAndPassword(
      email: event.email,
      password: event.password,
    );

    result.when(
      success: (user) {
        emit(AuthState(status: AuthStatus.authenticated, user: user));
      },
      failure: (error) {
        emit(AuthState(
          status: AuthStatus.error,
          errorMessage: error.message,
          user: null,
        ));
      },
    );
  }

  Future<void> _onRegisterWithEmailSubmitted(
    AuthRegisterWithEmailSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    final result = await _authRepository.registerWithEmailAndPassword(
      username: event.username,
      email: event.email,
      password: event.password,
    );

    result.when(
      success: (user) {
        emit(AuthState(status: AuthStatus.authenticated, user: user));
      },
      failure: (error) {
        emit(AuthState(
          status: AuthStatus.error,
          errorMessage: error.message,
          user: null,
        ));
      },
    );
  }

  Future<void> _onUserStatsUpdated(
    AuthUserStatsUpdated event,
    Emitter<AuthState> emit,
  ) async {
    final currentUser = state.user ?? await _userDao.getCurrentUser();
    if (currentUser != null) {
      final updated = currentUser.copyWith(
        totalXp: event.totalXp,
        streak: event.streak,
      );
      await _userDao.saveUser(updated);
      emit(state.copyWith(user: updated));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
