import 'package:ai_learning_app/src/core/domain/result.dart';
import 'package:ai_learning_app/src/core/domain/entities/user_entity.dart';
import 'package:ai_learning_app/src/core/infrastructure/datasources/remote/api/services/auth/models/login_request.dart';
import 'package:ai_learning_app/src/core/infrastructure/datasources/remote/api/services/auth/models/register_request.dart';

abstract class IAuthRepository {
  Future<Result<UserEntity>> login(LoginRequest request);

  Future<Result<UserEntity>> register(RegisterRequest request);

  Future<Result<UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Result<UserEntity>> registerWithEmailAndPassword({
    required String username,
    required String email,
    required String password,
  });

  Future<String?> getAccessToken();

  Future<void> setAccessToken(String? token);

  Future<Result<void>> sendPasswordResetEmail(String email);

  Future<Result<void>> signOut();

  Future<Result<void>> deleteAccount();

  UserEntity? getCurrentUser();

  Future<Result<UserEntity>> fetchUserProfile(String username);

  Future<Result<UserEntity>> updateProfileName(String newName);
}
