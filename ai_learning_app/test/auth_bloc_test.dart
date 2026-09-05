import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:ai_learning_app/src/core/application/auth/auth_bloc.dart';
import 'package:ai_learning_app/src/core/application/auth/auth_event.dart';
import 'package:ai_learning_app/src/core/application/auth/auth_state.dart';
import 'package:ai_learning_app/src/core/domain/app_exception.dart';
import 'package:ai_learning_app/src/core/domain/entities/user_entity.dart';
import 'package:ai_learning_app/src/core/domain/interfaces/i_auth_repository.dart';
import 'package:ai_learning_app/src/core/domain/result.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/user_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/database_service.dart';
import 'package:ai_learning_app/src/core/infrastructure/datasources/remote/api/services/auth/models/login_request.dart';
import 'package:ai_learning_app/src/core/infrastructure/datasources/remote/api/services/auth/models/register_request.dart';

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

    test('AuthLoginRequested emits authenticated on valid LoginRequest', () async {
      fakeAuthRepository.loginResult = const Result.success(
        UserEntity(id: 'u-req-1', username: 'enterprise_user', email: 'ent@test.com'),
      );

      authBloc.add(const AuthLoginRequested(
        LoginRequest(emailOrUsername: 'ent@test.com', password: 'password123'),
      ));
      await pumpEventQueue();

      expect(authBloc.state.status, AuthStatus.authenticated);
      expect(authBloc.state.user?.username, 'enterprise_user');
    });

    test('AuthRegisterRequested emits authenticated on valid RegisterRequest', () async {
      fakeAuthRepository.registerResult = const Result.success(
        UserEntity(id: 'u-req-2', username: 'enterprise_reg', email: 'entreg@test.com'),
      );

      authBloc.add(const AuthRegisterRequested(
        RegisterRequest(username: 'enterprise_reg', email: 'entreg@test.com', password: 'password123'),
      ));
      await pumpEventQueue();

      expect(authBloc.state.status, AuthStatus.authenticated);
      expect(authBloc.state.user?.username, 'enterprise_reg');
    });

    test('AuthUserStatsUpdated updates user XP and streak in state and Hive', () async {
      const initialUser = UserEntity(id: 'u1', username: 'vu', email: 'vu@test.com');
      await userDao.saveUser(initialUser);

      authBloc.add(const AuthCheckRequested());
      await authBloc.stream.firstWhere((s) => s.status == AuthStatus.authenticated);

      authBloc.add(const AuthUserStatsUpdated(totalXp: 150, streak: 5));
      await authBloc.stream.firstWhere((s) => s.user?.totalXp == 150);

      expect(authBloc.state.user?.totalXp, 150);
      expect(authBloc.state.user?.streak, 5);
      final inDb = await userDao.getCurrentUser();
      expect(inDb?.totalXp, 150);
      expect(inDb?.streak, 5);
    });

    test('AuthProfileUpdated updates username in state and Hive', () async {
      const initialUser = UserEntity(id: 'u1', username: 'old_name', email: 'vu@test.com');
      await userDao.saveUser(initialUser);

      authBloc.add(const AuthCheckRequested());
      await authBloc.stream.firstWhere((s) => s.status == AuthStatus.authenticated);

      authBloc.add(const AuthProfileUpdated(username: 'new_name'));
      await authBloc.stream.firstWhere((s) => s.user?.username == 'new_name');

      expect(authBloc.state.user?.username, 'new_name');
      final inDb = await userDao.getCurrentUser();
      expect(inDb?.username, 'new_name');
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

    test('AuthDeleteAccountRequested deletes account and resets state to unauthenticated', () async {
      await userDao.saveUser(
        const UserEntity(id: 'u-del', email: 'del@test.com', username: 'DelUser'),
      );
      authBloc.add(const AuthCheckRequested());
      await pumpEventQueue();
      expect(authBloc.state.status, AuthStatus.authenticated);

      authBloc.add(const AuthDeleteAccountRequested());
      await pumpEventQueue();

      expect(authBloc.state.status, AuthStatus.unauthenticated);
      expect(fakeAuthRepository.deleteAccountCalled, isTrue);
    });
  });
}

class _FakeAuthRepository implements IAuthRepository {
  Result<UserEntity>? loginResult;
  Result<UserEntity>? registerResult;
  UserEntity? currentUser;
  String? token;
  bool signOutCalled = false;
  bool deleteAccountCalled = false;

  @override
  UserEntity? getCurrentUser() => currentUser;

  @override
  Future<String?> getAccessToken() async => token;

  @override
  Future<void> setAccessToken(String? newToken) async {
    token = newToken;
  }

  @override
  Future<Result<UserEntity>> login(LoginRequest request) async {
    return loginResult ?? const Result.failure(AppException('Error'));
  }

  @override
  Future<Result<UserEntity>> register(RegisterRequest request) async {
    return registerResult ?? const Result.failure(AppException('Error'));
  }

  @override
  Future<Result<UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return login(LoginRequest(emailOrUsername: email, password: password));
  }

  @override
  Future<Result<UserEntity>> registerWithEmailAndPassword({
    required String username,
    required String email,
    required String password,
  }) async {
    return register(RegisterRequest(
      username: username,
      email: email,
      password: password,
    ));
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

  @override
  Future<Result<void>> deleteAccount() async {
    deleteAccountCalled = true;
    return const Result.success(null);
  }

  @override
  Future<Result<UserEntity>> fetchUserProfile(String username) async {
    final user = currentUser ??
        UserEntity(
          id: '1',
          username: username,
          email: '$username@test.com',
          totalXp: 100,
          streak: 5,
        );
    return Result.success(user);
  }

  @override
  Future<Result<UserEntity>> updateProfileName(String newName) async {
    final user = (currentUser ??
            const UserEntity(
              id: '1',
              username: 'old',
              email: 'test@test.com',
            ))
        .copyWith(username: newName);
    currentUser = user;
    return Result.success(user);
  }
}
