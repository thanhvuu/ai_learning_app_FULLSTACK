import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ai_learning_app/src/core/application/auth/auth_bloc.dart';
import 'package:ai_learning_app/src/core/application/auth/auth_event.dart';
import 'package:ai_learning_app/src/core/application/auth/auth_state.dart';
import 'package:ai_learning_app/src/core/domain/app_exception.dart';
import 'package:ai_learning_app/src/core/domain/entities/user_entity.dart';
import 'package:ai_learning_app/src/core/domain/interfaces/i_auth_repository.dart';
import 'package:ai_learning_app/src/core/domain/result.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/user_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/database_service.dart';

void main() {
  late Directory tempDir;
  late UserDao userDao;
  late _FakeAuthRepository fakeAuthRepository;
  late AuthBloc authBloc;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_auth_bloc_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserEntityAdapter());
    }
    await Hive.openBox<UserEntity>(DatabaseService.userBox);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  setUp(() async {
    userDao = UserDao();
    await userDao.clear();
    fakeAuthRepository = _FakeAuthRepository();
    authBloc = AuthBloc(
      authRepository: fakeAuthRepository,
      userDao: userDao,
    );
  });

  tearDown(() async {
    await authBloc.close();
  });

  group('AuthBloc Tests', () {
    test('AuthCheckRequested emits unauthenticated when no user is cached or logged in', () async {
      authBloc.add(const AuthCheckRequested());
      await pumpEventQueue();

      expect(authBloc.state.status, AuthStatus.unauthenticated);
      expect(authBloc.state.user, isNull);
    });

    test('AuthCheckRequested emits authenticated when user is cached in Hive', () async {
      const user = UserEntity(
        id: 'u123',
        username: 'cached_user',
        email: 'cached@email.com',
      );
      await userDao.saveUser(user);

      authBloc.add(const AuthCheckRequested());
      await pumpEventQueue();

      expect(authBloc.state.status, AuthStatus.authenticated);
      expect(authBloc.state.user?.username, 'cached_user');
    });

    test('AuthLoginWithEmailSubmitted emits authenticated on valid credentials', () async {
      fakeAuthRepository.loginResult = const Result.success(
        UserEntity(id: 'u1', username: 'vu', email: 'vu@test.com'),
      );

      authBloc.add(const AuthLoginWithEmailSubmitted(
        email: 'vu@test.com',
        password: 'password123',
      ));
      await pumpEventQueue();

      expect(authBloc.state.status, AuthStatus.authenticated);
      expect(authBloc.state.user?.username, 'vu');
      expect(authBloc.state.errorMessage, isNull);
    });

    test('AuthLoginWithEmailSubmitted emits error on failure', () async {
      fakeAuthRepository.loginResult = const Result.failure(
        AppException.auth('Sai thông tin tài khoản'),
      );

      authBloc.add(const AuthLoginWithEmailSubmitted(
        email: 'wrong@test.com',
        password: 'wrong',
      ));
      await pumpEventQueue();

      expect(authBloc.state.status, AuthStatus.error);
      expect(authBloc.state.errorMessage, 'Sai thông tin tài khoản');
      expect(authBloc.state.user, isNull);
    });

    test('AuthRegisterWithEmailSubmitted emits authenticated on success', () async {
      fakeAuthRepository.registerResult = const Result.success(
        UserEntity(id: 'u2', username: 'new_user', email: 'new@test.com'),
      );

      authBloc.add(const AuthRegisterWithEmailSubmitted(
        username: 'new_user',
        email: 'new@test.com',
        password: 'password123',
      ));
      await pumpEventQueue();

      expect(authBloc.state.status, AuthStatus.authenticated);
      expect(authBloc.state.user?.username, 'new_user');
    });

    test('AuthUserStatsUpdated updates user XP and streak in state and Hive', () async {
      const initialUser = UserEntity(id: 'u1', username: 'vu', email: 'vu@test.com');
      await userDao.saveUser(initialUser);

      authBloc.add(const AuthCheckRequested());
      await pumpEventQueue();

      authBloc.add(const AuthUserStatsUpdated(totalXp: 150, streak: 5));
      await pumpEventQueue();

      expect(authBloc.state.user?.totalXp, 150);
      expect(authBloc.state.user?.streak, 5);
      final inDb = await userDao.getCurrentUser();
      expect(inDb?.totalXp, 150);
      expect(inDb?.streak, 5);
    });

    test('AuthLogoutRequested clears user state and calls signOut', () async {
      const user = UserEntity(id: 'u1', username: 'vu', email: 'vu@test.com');
      await userDao.saveUser(user);

      authBloc.add(const AuthCheckRequested());
      await pumpEventQueue();
      expect(authBloc.state.status, AuthStatus.authenticated);

      authBloc.add(const AuthLogoutRequested());
      await pumpEventQueue();

      expect(authBloc.state.status, AuthStatus.unauthenticated);
      expect(fakeAuthRepository.signOutCalled, isTrue);
    });
  });
}

class _FakeAuthRepository implements IAuthRepository {
  Result<UserEntity>? loginResult;
  Result<UserEntity>? registerResult;
  UserEntity? currentUser;
  bool signOutCalled = false;

  @override
  UserEntity? getCurrentUser() => currentUser;

  @override
  Future<Result<UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return loginResult ?? const Result.failure(AppException('Error'));
  }

  @override
  Future<Result<UserEntity>> registerWithEmailAndPassword({
    required String username,
    required String email,
    required String password,
  }) async {
    return registerResult ?? const Result.failure(AppException('Error'));
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    return const Result.success(null);
  }

  @override
  Future<Result<void>> signOut() async {
    signOutCalled = true;
    return const Result.success(null);
  }
}
