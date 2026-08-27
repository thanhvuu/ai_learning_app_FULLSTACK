import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_learning_app/src/common/constants/api_constants.dart';
import 'package:ai_learning_app/src/core/domain/app_exception.dart';
import 'package:ai_learning_app/src/core/domain/entities/user_entity.dart';
import 'package:ai_learning_app/src/core/domain/interfaces/i_auth_repository.dart';
import 'package:ai_learning_app/src/core/domain/result.dart';
import 'package:ai_learning_app/src/core/infrastructure/databases/hive/daos/user_dao.dart';
import 'package:ai_learning_app/src/core/infrastructure/network/http_compat.dart' as http;

class AuthRepositoryImpl implements IAuthRepository {
  final FirebaseAuth _firebaseAuth;
  final UserDao _userDao;

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    required UserDao userDao,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _userDao = userDao;

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
  Future<Result<UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final username = credential.user?.displayName ?? email.split('@')[0];
      String? major;
      int totalXp = 0;
      int streak = 0;

      // Đồng bộ thông tin từ Backend nếu có
      try {
        final res = await http.post(
          Uri.parse("${ApiConstants.users}/login"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'password': password.trim()}),
        );
        if (res.statusCode == 200) {
          final data = jsonDecode(utf8.decode(res.bodyBytes));
          major = data['major'];
          totalXp = (data['totalXp'] as num?)?.toInt() ?? 0;
          streak = (data['streak'] as num?)?.toInt() ?? 0;
        }
      } catch (_) {}

      final userEntity = UserEntity(
        id: credential.user!.uid,
        username: username,
        email: email.trim(),
        major: major,
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
  Future<Result<UserEntity>> registerWithEmailAndPassword({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await credential.user?.updateDisplayName(username);

      try {
        await http.post(
          Uri.parse("${ApiConstants.users}/register"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': username,
            'email': email.trim(),
            'password': password.trim(),
          }),
        );
      } catch (_) {}

      final userEntity = UserEntity(
        id: credential.user!.uid,
        username: username,
        email: email.trim(),
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
      await _userDao.clearUser();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppException.unknown('Lỗi khi đăng xuất: $e'),
      );
    }
  }
}
