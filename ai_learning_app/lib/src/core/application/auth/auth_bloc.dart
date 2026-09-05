import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_learning_app/src/core/domain/interfaces/i_auth_repository.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/user_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/datasources/remote/api/services/auth/models/login_request.dart';
import 'package:ai_learning_app/src/core/infrastructure/datasources/remote/api/services/auth/models/register_request.dart';
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
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLoginWithEmailSubmitted>(_onLoginWithEmailSubmitted);
    on<AuthRegisterWithEmailSubmitted>(_onRegisterWithEmailSubmitted);
    on<AuthUserStatsUpdated>(_onUserStatsUpdated);
    on<AuthProfileUpdated>(_onProfileUpdated);
    on<AuthUserProfileFetchRequested>(_onUserProfileFetchRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthDeleteAccountRequested>(_onDeleteAccountRequested);
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

  Future<void> _handleLogin(
    LoginRequest request,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    final result = await _authRepository.login(request);

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

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _handleLogin(event.request, emit);
  }

  Future<void> _onLoginWithEmailSubmitted(
    AuthLoginWithEmailSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    await _handleLogin(
      LoginRequest(
        emailOrUsername: event.email,
        password: event.password,
      ),
      emit,
    );
  }

  Future<void> _handleRegister(
    RegisterRequest request,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    final result = await _authRepository.register(request);

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

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _handleRegister(event.request, emit);
  }

  Future<void> _onRegisterWithEmailSubmitted(
    AuthRegisterWithEmailSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    await _handleRegister(
      RegisterRequest(
        username: event.username,
        email: event.email,
        password: event.password,
      ),
      emit,
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

  Future<void> _onProfileUpdated(
    AuthProfileUpdated event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _authRepository.updateProfileName(event.username);
    await result.when(
      success: (user) async {
        await _userDao.saveUser(user);
        emit(state.copyWith(user: user));
      },
      failure: (error) async {
        final currentUser = state.user;
        if (currentUser != null) {
          final updated = currentUser.copyWith(username: event.username);
          await _userDao.saveUser(updated);
          emit(state.copyWith(user: updated));
        }
      },
    );
  }

  Future<void> _onUserProfileFetchRequested(
    AuthUserProfileFetchRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _authRepository.fetchUserProfile(event.username);
    await result.when(
      success: (user) async {
        await _userDao.saveUser(user);
        emit(state.copyWith(user: user));
      },
      failure: (_) async {},
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> _onDeleteAccountRequested(
    AuthDeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    final result = await _authRepository.deleteAccount();
    result.when(
      success: (_) {
        emit(const AuthState(status: AuthStatus.unauthenticated));
      },
      failure: (error) {
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: error.message,
        ));
      },
    );
  }
}
