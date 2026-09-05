import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:ai_learning_app/src/common/utils/service_locator.dart';
import 'package:ai_learning_app/src/core/domain/app_exception.dart';
import 'package:ai_learning_app/src/core/domain/entities/user_entity.dart';
import 'package:ai_learning_app/src/core/domain/interfaces/i_auth_repository.dart';
import 'package:ai_learning_app/src/core/domain/result.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/user_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/datasources/local/storage.dart';
import 'package:ai_learning_app/src/core/infrastructure/datasources/remote/api/services/auth/models/login_request.dart';
import 'package:ai_learning_app/src/core/infrastructure/datasources/remote/api/services/auth/models/register_request.dart';
import 'package:ai_learning_app/src/core/infrastructure/network/api_client.dart';

@LazySingleton(as: IAuthRepository)
class AuthRepositoryImpl implements IAuthRepository {
  final FirebaseAuth _firebaseAuth;
  final UserDao _userDao;
  final ApiClient _apiClient;

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    required UserDao userDao,
    ApiClient? apiClient,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _userDao = userDao,
        _apiClient = apiClient ?? ServiceLocator.apiClient;

  @override
  UserEntity? getCurrentUser() {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return UserEntity(
        id: user.uid,
        username: user.displayName ?? user.email?.split('@')[0] ?? '',
        email: user.email ?? '',
      );
    }
    return null;
  }

  Future<UserEntity?> getCachedUser() async {
    return _userDao.getCurrentUser();
  }

  @override
  Future<String?> getAccessToken() => Storage.accessToken;

  @override
  Future<void> setAccessToken(String? token) => Storage.setAccessToken(token);

  @override
  Future<Result<UserEntity>> login(LoginRequest request) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: request.emailOrUsername.trim(),
        password: request.password.trim(),
      );

      final token = await credential.user?.getIdToken();
      if (token != null) {
        await Storage.setAccessToken(token);
      }

      final username = credential.user?.displayName ?? request.emailOrUsername.split('@')[0];
      int totalXp = 0;
      int streak = 0;

      // Đồng bộ thông tin từ Backend nếu có
      try {
        final res = await _apiClient.post(
          '/api/users/login',
          data: request.toJson(),
        );
        res.when(
          success: (data) {
            if (data is Map) {
              totalXp = (data['totalXp'] as num?)?.toInt() ?? 0;
              streak = (data['streak'] as num?)?.toInt() ?? 0;
            }
          },
          failure: (_) {},
        );
      } catch (_) {}

      final userEntity = UserEntity(
        id: credential.user!.uid,
        username: username,
        email: credential.user?.email ?? request.emailOrUsername.trim(),
        totalXp: totalXp,
        streak: streak,
      );

      // Lưu vào Hive Cache
      await _userDao.saveUser(userEntity);

      return Result.success(userEntity);
    } on FirebaseAuthException catch (e) {
      return Result.failure(
        AppException.auth(e.message ?? 'Đăng nhập thất bại', code: e.code),
      );
    } catch (e) {
      return Result.failure(
        AppException.unknown('Lỗi hệ thống: $e'),
      );
    }
  }

  @override
  Future<Result<UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return login(LoginRequest(emailOrUsername: email, password: password));
  }

  @override
  Future<Result<UserEntity>> register(RegisterRequest request) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: request.email.trim(),
        password: request.password.trim(),
      );

      final token = await credential.user?.getIdToken();
      if (token != null) {
        await Storage.setAccessToken(token);
      }

      await credential.user?.updateDisplayName(request.username);

      try {
        await _apiClient.post(
          '/api/users/register',
          data: request.toJson(),
        );
      } catch (_) {}

      final userEntity = UserEntity(
        id: credential.user!.uid,
        username: request.username,
        email: request.email.trim(),
      );

      // Lưu vào Hive Cache
      await _userDao.saveUser(userEntity);

      return Result.success(userEntity);
    } on FirebaseAuthException catch (e) {
      return Result.failure(
        AppException.auth(e.message ?? 'Đăng ký thất bại', code: e.code),
      );
    } catch (e) {
      return Result.failure(
        AppException.unknown('Lỗi hệ thống: $e'),
      );
    }
  }

  @override
  Future<Result<UserEntity>> registerWithEmailAndPassword({
    required String username,
    required String email,
    required String password,
  }) {
    return register(RegisterRequest(
      username: username,
      email: email,
      password: password,
    ));
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(
        AppException.auth(e.message ?? 'Gửi email đặt lại mật khẩu thất bại', code: e.code),
      );
    } catch (e) {
      return Result.failure(
        AppException.unknown('Lỗi hệ thống: $e'),
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await Storage.clearAuth();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppException.unknown('Lỗi khi đăng xuất: $e'),
      );
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.delete();
      }
      await Storage.clearAuth();
      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return Result.failure(
          AppException.auth(
            'Hành động này cần xác thực lại. Vui lòng đăng nhập lại trước khi xóa tài khoản.',
            code: e.code,
          ),
        );
      }
      return Result.failure(
        AppException.auth(e.message ?? 'Lỗi khi xóa tài khoản', code: e.code),
      );
    } catch (e) {
      return Result.failure(
        AppException.unknown('Không thể xóa tài khoản: $e'),
      );
    }
  }

  @override
  Future<Result<UserEntity>> fetchUserProfile(String username) async {
    try {
      final result = await _apiClient.get(
        '/api/users/profile',
        queryParameters: {'username': username},
      );

      return await result.when(
        success: (data) async {
          int streak = 0;
          int totalXp = 0;
          if (data is Map) {
            streak = (data['streak'] as num?)?.toInt() ?? 0;
            totalXp = (data['totalXp'] as num?)?.toInt() ?? 0;
          }

          final cachedUser = await _userDao.getCurrentUser();
          final updatedUser = (cachedUser ??
                  UserEntity(
                    id: _firebaseAuth.currentUser?.uid ?? '',
                    username: username,
                    email: _firebaseAuth.currentUser?.email ?? '',
                  ))
              .copyWith(
            streak: streak,
            totalXp: totalXp,
          );

          await _userDao.saveUser(updatedUser);
          return Result.success(updatedUser);
        },
        failure: (err) async {
          final cachedUser = await _userDao.getCurrentUser();
          if (cachedUser != null) {
            return Result.success(cachedUser);
          }
          return Result.failure(err);
        },
      );
    } catch (e) {
      final cachedUser = await _userDao.getCurrentUser();
      if (cachedUser != null) {
        return Result.success(cachedUser);
      }
      return Result.failure(
          AppException.network('Lỗi tải thông tin người dùng: $e'));
    }
  }

  @override
  Future<Result<UserEntity>> updateProfileName(String newName) async {
    try {
      // 1. Update Firebase display name
      await _firebaseAuth.currentUser?.updateDisplayName(newName);

      // 2. Update Backend
      try {
        await _apiClient.put(
          '/api/users/profile',
          data: {'username': newName},
        );
      } catch (_) {}

      // 3. Update Hive cached user
      final cachedUser = await _userDao.getCurrentUser();
      final updatedUser = (cachedUser ??
              UserEntity(
                id: _firebaseAuth.currentUser?.uid ?? '',
                username: newName,
                email: _firebaseAuth.currentUser?.email ?? '',
              ))
          .copyWith(username: newName);

      await _userDao.saveUser(updatedUser);
      return Result.success(updatedUser);
    } catch (e) {
      return Result.failure(
          AppException.unknown('Lỗi cập nhật tên người dùng: $e'));
    }
  }
}
